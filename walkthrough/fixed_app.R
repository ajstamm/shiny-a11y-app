# need to switch to irises

library(shiny)
library(bslib)
 
 
ui <- page_sidebar(
 
  # Add language at the top of the UI
  tags$html(lang = "en"),

  title = "Hello Accessible Shiny!",
  sidebar = sidebar(
    #Presentation Notes: Double sided standards don't work. (Or we couldn't figure it out)
    sliderInput(
      inputId = "bins",
      label = "Number of bins:",
      min = 1,
      max = 50,
      value = 30
    )
  ),
  #Change uiOutput to match div container.
  uiOutput("histogramContainer")
)
 
server <- function(input, output) {
  output$distPlot <- renderPlot({
    x    <- faithful$waiting
    bins <- seq(min(x), max(x), length.out = input$bins + 1)
    hist(x, breaks = bins, col = "#007bc2", border = "white",
         xlab = "Waiting time to next eruption (in mins)",
         main = "Histogram of waiting times")
  })
  # Dynamic aria-label with bins
  output$histogramContainer <- renderUI({
    tags$div(
      `aria-label` = paste("Histogram displaying the distribution of waiting times between Old Faithful eruptions using", input$bins, "bins."),
      plotOutput(outputId = "distPlot")
    )
  })
}
 
shinyApp(ui = ui, server = server)