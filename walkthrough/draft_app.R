library(shiny)
data(iris)

# Define UI for app that draws a histogram ----
ui <- bslib::page_sidebar(
  
  # App title ----
  title = "Fun with irises",
  # Sidebar panel for inputs ----
  sidebar = bslib::sidebar(
    # Input: Slider for the number of bins ----
    sliderInput(
      inputId = "bins",
      label = "Number of bins:",
      min = 1,
      max = 50,
      value = 30
    ),
    selectInput("species", label = "Iris species:", selectize = FALSE,  # 
                choices = c("All", unique(as.character(iris$Species))),
                selected = "All"),
    selectInput("measure", label = "Iris species:",  # selectize = FALSE, 
                choices = names(iris)[1:4], selected = names(iris)[1]),
  ),
  # Output: Histogram ----
  h2("Histogram of iris sepal widths"),
  plotOutput(outputId = "hist_plot")
)
 
# Define server logic required to draw a histogram ----
server <- function(input, output) {
  # Histogram of the Old Faithful Geyser Data ----
  # with requested number of bins
  # This expression that generates a histogram is wrapped in a call
  # to renderPlot to indicate that:
  #
  # 1. It is "reactive" and therefore should be automatically
  #    re-executed when inputs (input$bins) change
  # 2. Its output type is a plot
  output$hist_plot <- renderPlot({
    if (!input$species == "All") {
      i <- iris[which(iris$Species == input$species), ]
    } else {
      i <- iris
    }
    lims <- iris[ , input$measure]
    x <- i[ , input$measure]
    bins <- seq(min(lims), max(lims), length.out = input$bins + 1)
    hist(x, breaks = bins, col = "#007bc2", border = "white",
         xlab = input$measure,
         main = "Histogram of sepal lengths",
         xlim = c(min(lims), max(lims)))
  })
}
shinyApp(ui = ui, server = server)