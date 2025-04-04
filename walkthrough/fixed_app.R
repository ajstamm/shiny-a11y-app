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
    # keyboard focus not in slider
    textInput("bins", value = 20, placeholder = 10, 
              label = "Enter the number of bins to display in the chart 
                       (2 to 30):"),
    selectInput("species", selectize = FALSE, 
                label = "Select an iris species to display in the chart:",  
                choices = c("all", unique(as.character(iris$Species))),
                selected = "all"),
  ),
  # outputs to main panel
  h2("Drawing an interactable histogram of iris sepal widths"),
  p("Select items in the sidebar to control the iris species and number of bins 
     displayed. If the sidebar is not visible, click the chevron ('>') in the 
     upper left corner of the plot to open the sidebar."),
  textOutput("hist_desc"),
  plotOutput("hist_plot")
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
              xlab = "Sepal width", 
              main = paste("Histogram of sepal widths for", 
                           input$species, "irises."),
              xlim = c(min(iris$Sepal.Width), max(iris$Sepal.Width)))
    
    # add alt text to plot
    return(p)
  },
  alt = reactive({
    i <- iris
    if (!input$species == "all") i <- i[which(i$Species == input$species), ]
    aria <- paste("Histogram of sepal widths in centimeters for", 
                  input$species, "irises.",
                  "Sepal widths range from", min(i$Sepal.Width), 
                  "to", max(i$Sepal.Width), "with a mean of", 
                  mean(i$Sepal.Width), "and a mode of", 
                  DescTools::Mode(i$Sepal.Width))
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
                  round(mean(i$Sepal.Width), digits = 2), 
                  "cm and a mode of", DescTools::Mode(i$Sepal.Width), "cm.")
    return(desc)
  })
}
 
shinyApp(ui = ui, server = server)