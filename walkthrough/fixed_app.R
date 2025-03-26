# need to switch to irises

library(shiny)
library(bslib)
 
 
ui <- page_sidebar(
  # test with shinya11y
  shinya11y::use_tota11y(),
 
  # Add language at the top of the UI
  tags$html(lang = "en"),

  # App title ----
  title = "Fun with irises",
  # sidebar
  sidebar = bslib::sidebar(
    textInput("bins", value = 20, placeholder = 10, 
              label = "Enter the number of bins to display in the chart:"),
    selectInput("species", selectize = FALSE, 
                label = "Select an iris species to display in the chart:",  
                choices = c("All", unique(as.character(iris$Species))),
                selected = "All"),
  ),
  # outputs to main panel
  h2("Drawing an interactable histogram of iris sepal widths"),
  p("Select items in the sidebar to control the iris species and number of bins 
     displayed. If the sidebar is not visible, click the chevron ('>') in the 
     upper left cornerof the plot to open the sidebar."),
  plotOutput("hist_plot")
)
 
server <- function(input, output) {
  output$hist_plot <- renderPlot({
    if (!input$species == "All") {
      i <- iris[which(iris$Species == input$species), ]
    } else {
      i <- iris
    }
    bins <- seq(min(iris$Sepal.Width), max(iris$Sepal.Width), 
                length.out = as.numeric(input$bins) + 1)
    hist(i$Sepal.Width, breaks = bins, col = "#007bc2", border = "white",
         xlab = "Sepal width", main = "Histogram of sepal widths",
         xlim = c(min(iris$Sepal.Width), max(iris$Sepal.Width)))
  })
}
 
shinyApp(ui = ui, server = server)