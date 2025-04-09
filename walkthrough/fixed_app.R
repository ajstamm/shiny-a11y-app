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
    # keyboard focus not visible in slider
    # keyboard does not work at all with double-headed slider
    # "Enter the number of bins to display in the chart (2 to 29):"
    textInput("bins", value = 15, placeholder = 10,
              label = "Number of bins:"),
    # add clearer instructions
    selectInput("species", selectize = FALSE, 
                label = "Select an iris species to display in the chart:",  
                choices = c("all", unique(as.character(iris$Species))),
                selected = "all"),
  )
}

# define main panel ----
main <- function(df) {
  mainPanel(
    # add text description of plot
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
 

server <- function(input, output) {
  output$hist_plot <- renderPlot({
    i <- iris
    if (!input$species == "all") i <- i[which(i$Species == input$species), ]
    b <- input$bins
    if (is.na(as.numeric(b))) b <- 10
    bins <- seq(min(iris$Sepal.Width), max(iris$Sepal.Width), 
                length.out = as.numeric(b) + 1)
    # alt text for plot
    p <- hist(i$Sepal.Width, breaks = bins, col = "#007bc2", border = "white",
              main = paste("Histogram of sepal widths for", 
                           input$species, "irises."),
              xlab = "Sepal width", xlim = c(2, 4.5))
    
    # add alt text to plot
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
  # add a plot description
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
