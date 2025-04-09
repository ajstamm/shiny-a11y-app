library(shiny)

# add term definitions 
# state: collapsed or expanded
# modal table: instructions/warning of what to expect
# how to create accessibility widget
# spell out DSI in TS-relations slide
# dragon - news blurb requesting testers?
# dry run: ~45 minutes, so can extend ~15 minutes more
# dark mode native to browsers, but better if site specific
data(iris)
df <- iris

# Define UI for app that draws a histogram ----
sidebar <- function(df) {
  sidebarPanel(
  # Sidebar panel for inputs 
    # Input: Slider for the number of bins ----
    sliderInput(inputId = "bins", label = "Number of bins:",
                min = 2, max = 30, value = 15),
    # keyboard focus not visible in slider
    # keyboard does not work at all with double-headed slider
    # "Enter the number of bins to display in the chart (2 to 30):"
    # textInput("bins", value = 20, placeholder = 10, 
    #           label = "Number of bins:"),
    # "Select your desired iris species:"
    selectInput("species", label = "Iris species:", selectize = FALSE,  # 
                choices = c("all", unique(as.character(df$Species))),
                selected = "all"),
    # Select your desired measurement:"
    selectInput("measure", label = "Measurement:",  # selectize = FALSE, 
                choices = names(df)[1:4], selected = names(df)[1]),
  )
}

main <- function(df) {
  # main panel
  mainPanel(
    h2("Histogram of iris measurements"),
    textOutput("hist_desc"),
    plotOutput("hist_plot")
    # could also add table and data download
  )
}

ui <- fluidPage(
  # dashboard set-up ----
  # test with shinya11y
  # shinya11y::use_tota11y(),
  # Add language at the top of the UI
  tags$html(lang = "en"),
  # App title 
  tags$title("Fun with irises"),
  h1("Fun with irises"),
  # dashboard layout ----
  sidebarLayout(
    sidebar(df),
    main(df)
  )
)
 
# Define server logic 
server <- function(input, output) {
  output$hist_plot <- renderPlot({
    if (!input$species == "all") {
      i <- iris[which(iris$Species == input$species), ]
    } else {
      i <- iris
    }
    if (is.na(input$measure)) input$measure <- "Sepal.Width"
    lims <- iris[ , input$measure]
    x <- i[ , input$measure]
    m <- gsub("[.]", " ", input$measure)
    bins <- seq(min(lims), max(lims), length.out = input$bins + 1)
    p <- hist(x, breaks = bins, col = "#007bc2", border = "white",
         xlab = input$measure,
         main = paste("Histogram of", m, "for", input$species, "irises"),
         xlim = c(min(lims), max(lims)))
    return(p)
    },
    alt = reactive({
      i <- iris
      if (!input$species == "all") i <- i[which(i$Species == input$species), ]
      # if (is.na(input$measure)) input$measure <- "Sepal.Width"
      m <- gsub("[.]", " ", input$measure)
      x <- i[ , input$measure]
      s <- input$species
      aria <- paste("Histogram of", m, "in centimeters for", s, "irises.", m, 
                    "ranges from", min(x), "to", max(x), "with mean of", 
                    round(mean(x), digits = 2), "and mode of", 
                    paste(DescTools::Mode(x), collapse = ", "))
      return(aria)
  }))
  # add a plot description
  output$hist_desc <- renderText({
    i <- iris
    if (!input$species == "all") i <- i[which(i$Species == input$species), ]
    if (is.na(input$measure)) input$measure <- "Sepal.Width"
    x <- i[ , input$measure]
    m <- gsub("[.]", " ", input$measure)
    s <- input$species
    desc <- paste("Below is a histogram of", m, "for", s, "irises.", m, "for", 
                  s, "irises ranges from", min(x), "cm to", max(x), 
                  "cm with mean of", round(mean(x), digits = 2), "cm and mode of", 
                  paste(DescTools::Mode(x), collapse = ", "), "cm.")
    return(desc)
  })
}

shinyApp(ui = ui, server = server)