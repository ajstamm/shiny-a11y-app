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
    p <- hist(i$Sepal.Width, breaks = bins, 
              col = "#005bc2", border = "white",
              main = paste("Histogram of sepal widths for", 
                           input$species, "irises."),
              xlab = "Sepal width", xlim = c(2, 4.5))
    return(p)
  })
  # add description of plot (non-image data)
  
}

shinyApp(ui = ui, server = server)
