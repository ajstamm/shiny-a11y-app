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
# tags, html, uiOutput, div, server, ui, shinyApp function, libraries shiny and bslib

library(shiny)
data(iris)

# Define UI for app that draws a histogram ----
ui <- bslib::page_sidebar(
  # App set-up ----
  title = "Fun with irises",
  
  # shinya11y test
  
  # Sidebar panel for inputs ----
  sidebar = bslib::sidebar(
    # slider for the number of hisogram bins
    # convert to textbox
    sliderInput(
      inputId = "bins",
      # improve label
      label = "Number of bins:",
      min = 1,
      max = 50,
      value = 30
    ),
    # dropdown to select species
    selectInput("species",  
                # fix aria text
                # selectize = FALSE, 
                # improve label
                label = "Iris species:", 
                choices = c("All", unique(as.character(iris$Species))),
                selected = "All"),
  ),
  
  # Output: Histogram ----
  # add dashboard instructions
  plotOutput("hist_plot")
)
 
# Define server logic required to draw a histogram ----
server <- function(input, output) {
  output$hist_plot <- renderPlot({
    if (!input$species == "All") {
      i <- iris[which(iris$Species == input$species), ]
    } else {
      i <- iris
    }
    # handle when input$bins is missing
    b <- input$bins
    bins <- seq(min(iris$Sepal.Width), max(iris$Sepal.Width), 
                length.out = as.numeric(b) + 1)
    hist(i$Sepal.Width, breaks = bins, col = "#007bc2", border = "white",
         xlab = "Sepal width", main = "Histogram of sepal widths",
         xlim = c(min(iris$Sepal.Width), max(iris$Sepal.Width)))
  })
}

shinyApp(ui = ui, server = server)