# Author: Abby Stamm & Eric Kvale
# Date: March 2025
# Purpose: workshop script for ShinyConf 2025

# load data ----
library(shiny)
data(iris)
df <- iris

# define sidebar ----
sidebar <- function(df) {
  sidebarPanel(
    # Input slider for the number of bins
    sliderInput(inputId = "bins", label = "Number of bins:",
                min = 2, max = 29, value = 15),
    # keyboard focus not visible in slider
    # keyboard does not work at all with double-headed slider
    # add clearer instructions
    selectInput("species",  # selectize = FALSE, 
                label = "Iris species:", 
                choices = c("all", unique(as.character(df$Species))),
                selected = "all")
  )
}

# define main panel ----
main <- function(df) {
  mainPanel(
    # add dashboard orientation 
    # add text description of plot

    plotOutput("hist_plot")
    # could also add table and data download
  )
}

ui <- fluidPage(
  # dashboard set-up ----
  # test with shinya11y

  # Add language at the top of the UI

  # App title 

  h1("Fun with irises"),
  # dashboard layout ----
  sidebarLayout(
    sidebar(df),
    main(df)
  )
)


# Define server logic required to draw a histogram ----
server <- function(input, output) {
  output$hist_plot <- renderPlot({
    i <- iris
    if (!input$species == "all") i <- i[which(i$Species == input$species), ]
    # handle when input$bins is missing
    b <- as.numeric(input$bins)
    bins <- seq(2, 4.4, length.out = b + 1)
    # add aria text
    p <- hist(i$Sepal.Width, breaks = bins, col = "#005bc2", border = "white",
              main = paste("Histogram of sepal widths for", 
                           input$species, "irises."),
              xlab = "Sepal width", xlim = c(2, 4.5))
    return(p)
  })
  # add description of plot (non-image data)
  
}

shinyApp(ui = ui, server = server)
# Author: Abby Stamm & Eric Kvale
# Date: March 2025
# Purpose: workshop script for ShinyConf 2025

# load data ----
library(shiny)
data(iris)
df <- iris

# define sidebar ----
sidebar <- function(df) {
  sidebarPanel(
    # Input slider for the number of bins
    # sliderInput(inputId = "bins", label = "Number of bins:",
    #             min = 2, max = 29, value = 15),
    textInput("bins", value = 15, placeholder = 10,
              label = "Enter the number of bins to display in the chart (2 to 29):"),
    # keyboard focus not visible in slider
    # keyboard does not work at all with double-headed slider
    # add clearer instructions
    # selectize definition
    selectInput("species", selectize = FALSE, 
                label = "Select an iris species to display in the chart:", 
                choices = c("all", unique(as.character(df$Species))),
                selected = "all")
  )
}

# define main panel ----
main <- function(df) {
  mainPanel(
    # add dashboard orientation 
    h2("Drawing an interactive histogram of iris sepal widths"),
    # add instructions for dashboard
    p("Select items in the user input box (above or to the left of the plot)
       to select the iris species and number of bins displayed."),
    # add text description of plot
    textOutput("hist_desc"),

    plotOutput("hist_plot")
    # could also add table and data download
  )
}

ui <- fluidPage(
  # dashboard set-up ----
  # test with shinya11y
  shinya11y::use_tota11y(),

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


# Define server logic required to draw a histogram ----
server <- function(input, output) {
  output$hist_plot <- renderPlot({
    i <- iris
    if (!input$species == "all") i <- i[which(i$Species == input$species), ]
    # handle when input$bins is missing
    b <- as.numeric(input$bins)
    if (is.na(b)) b <- 10
    bins <- seq(2, 4.4, length.out = b + 1)
    # add aria text
    p <- hist(i$Sepal.Width, breaks = bins, col = "#005bc2", border = "white",
              main = paste("Histogram of sepal widths for", 
                           input$species, "irises."),
              xlab = "Sepal width", xlim = c(2, 4.5))
    return(p)
    },
    alt = reactive({
      i <- iris
      if (!input$species == "all") i <- i[which(i$Species == input$species), ]
      aria <- paste("Histogram of sepal widths in centimeters for", 
                    input$species, "irises.", "Sepal widths range from", 
                    min(i$Sepal.Width), "to", max(i$Sepal.Width), 
                    "with a mean of", mean(i$Sepal.Width))
      return(aria)
  }))

  # add description of plot (non-image data)
  output$hist_desc <- renderText({
    i <- iris
    if (!input$species == "all") i <- i[which(i$Species == input$species), ]
    desc <- paste("Below is a histogram of sepal widths for", input$species, 
                  "irises. Sepal widths for", input$species, 
                  "irises range from", min(i$Sepal.Width), "cm to", 
                  max(i$Sepal.Width), "cm with a mean of", 
                  round(mean(i$Sepal.Width), digits = 2), "cm.")
    return(desc)
  })
}

shinyApp(ui = ui, server = server)
