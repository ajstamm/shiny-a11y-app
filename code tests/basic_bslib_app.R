# Author: Abby Stamm & Eric Kvale
# Date: March 2025
# Purpose: workshop script for ShinyConf 2025
# 
# Terminology
#   - shiny:
#   - server:
#   - ui: 
#   - sidebar:
#   - bslib: 
#   - input: 
#   - output: 
#   - tags:
#   - html: 
#   - uiOutput:
#   - shinyApp: 
#   - div: 

library(shiny)
data(iris)

# Define UI for app that draws a histogram ----
ui <- bslib::page_sidebar(
  # App set-up ----
  title = "Fun with irises",
  # shinya11y test
  
  # Sidebar panel for inputs ----
  sidebar = bslib::sidebar(
    # slider for the number of histogram bins
    # convert to text box
    sliderInput(inputId = "bins",
                label = "Number of bins:", # improve label
                min = 2, max = 30, value = 15),
    # drop-down to select species
    selectInput("species",  
                # selectize = FALSE, # fix aria text
                label = "Iris species:", # improve label
                choices = c("All", unique(as.character(iris$Species))),
                selected = "All"),
  ),
  
  # Output: Histogram ----
  # add dashboard instructions
  plotOutput("hist_plot")
  # switch tab order or reflow order
)

# Define server logic required to draw a histogram ----
server <- function(input, output) {
  output$hist_plot <- renderPlot({
    i <- iris
    if (!input$species == "All") i <- i[which(i$Species == input$species), ]
    # handle when input$bins is missing
    b <- input$bins
    bins <- seq(min(iris$Sepal.Width), max(iris$Sepal.Width), 
                length.out = as.numeric(b) + 1)
    # add aria text
    hist(i$Sepal.Width, breaks = bins, col = "#007bc2", border = "white",
         xlab = "Sepal width", main = "Histogram of sepal widths",
         xlim = c(min(iris$Sepal.Width), max(iris$Sepal.Width)))
  })
  # add description of plot (non-image data)
}

shinyApp(ui = ui, server = server)
