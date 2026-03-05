# Author: Abby Stamm & Eric Kvale
# Date: February 2026
# Purpose: workshop script for R/Medicine 2026

library(shiny)
library(ggplot2)
library(dplyr)
data(iris)

# Define UI for app that draws a histogram ----
ui <- bslib::page_sidebar(
  # App set-up ----
  # App title 
  # tags$title("Fun with irises"),
  h1("Fun with irises"),

  # shinya11y test
  shinya11y::use_tota11y(),
  
  # Add language at the top of the UI
  # tags$html(lang = "en"),
  
  # Sidebar panel for inputs ----
  sidebar = bslib::sidebar(
    # add table of contents
    # h2("Contents"),
    # p("Select each tab to view its content."),
    # tags$ul(
    #   tags$li(strong(actionLink("link_tab_intro", "Introduction")), 
    #           "- Information about the dashboard"),
    #   tags$li(strong(actionLink("link_tab_bar", "Barplot")), 
    #           "- Bar chart of iris species"),
    #   tags$li(strong(actionLink("link_tab_hist", "Histogram")), 
    #           "- Histogram of the selected measurement")
    # ),
    # remove select items for intro
    # dropdown to select species
    # conditionalPanel(
    #   condition = "input.my_tabs != 'tab_intro'",
    selectInput("species",  
                # fix aria text
                # selectize = FALSE, 
                # improve label
                label = "Iris species:", 
                # label = "Choose one or all Iris species:", 
                choices = c("All", unique(as.character(iris$Species))),
                selected = "All"),
    selectInput("measure",
                # fix aria text
                # selectize = FALSE, 
                # improve label
                label = "Measure:", 
                # label = "Select the measurement to filter on for the chart:", 
                choices = names(iris)[1:4],
                selected = names(iris)[1]),
    # slider for minimum and maximum value of measure
    # convert to textbox
    # conditionalPanel(
    #   condition = "input.my_tabs == 'tab_hist'",
    uiOutput("select_measure"),
    # slider for the number of histogram bins
    # convert to textbox
    # remove for bar chart/intro
    sliderInput(inputId = "bins",
                # improve label
                label = "Number of bins:",
                min = 1, max = 20, value = 10)
    #   )
    # )
),
  
  # Output: Histogram ----
  mainPanel(
    tabsetPanel(id = "my_tabs", 
                # tab_intro ----
                # add dashboard instructions
                tabPanel(title = "Introduction", value = "tab_intro", 
                  p("This dashboard is designed to demonstrate some simple ways 
                     to make your Shiny app more accessible. Here are some 
                     things to consider."),
                  h3("Accessible sidebar"),
                  tags$ul(
                    tags$li("Is there a sitemap, table of contents, or other 
                             easy to navigate list of elements?"),
                    tags$li("Is the dashboard's primary language defined?"),
                    tags$li("Are the filters in the sidebar relevant for the 
                             currently selected tab?"),
                    tags$li("Are the filters well defined?"),
                    tags$li("Are the filters keyboard accessible?")),
                  h3("Accessible charts"),
                  tags$ul(
                    tags$li("Do the chart colors cotrast sufficiently?"),
                    tags$li("Are the font size and spacing appropriate?"),
                    tags$li("Do the title and axis labels exist? Are they easy 
                             to read?"),
                    tags$li("Does the alternate text exist and make sense?"),
                    tags$li("Are there alternate ways to access chart data?"))
                ),
                tabPanel(title = "Barplot", value = "tab_bar", 
                  # h2("Drawing an interactive barplot of iris measurements"),
                  # add navigation instructions
                  # p('Select filters in the sidebar to control iris species, 
                  #    measure, and measure limits to display. If the sidebar 
                  #    is not visible, open it by clicking the chevron (">") 
                  #    or "toggle sidebar" label.'),
                  # add a plot description
                  # htmlOutput("bar_desc"), 
                  plotOutput("bar_plot"),
                  # add a table of the data
                  # dataTableOutput("bar_table")
                ),
                tabPanel(title = "Histogram", value = "tab_hist", 
                  # h2("Drawing an interactive histogram of iris measurements"),
                  # add navigation instructions
                  # p('Select filters in the sidebar to control iris species, 
                  #    measure, and measure limits to display. If the sidebar 
                  #    is not visible, open it by clicking the chevron (">") 
                  #    or "toggle sidebar" label.'),
                  # add a plot description
                  # htmlOutput("hist_desc"), 
                  plotOutput("hist_plot"),
                  # add a table of the data
                  # dataTableOutput("hist_table")
                ),
    )
  )
)
 
# Define server logic required to draw a histogram ----
server <- function(input, output, session) {
  output$select_measure <- shiny::renderUI({
    meas <- if (is.na(input$measure)) "Sepal.Length" else input$measure
    i <- iris
    i$measure <- i[, meas]
    sliderInput("range", paste("Range of", input$measure, "to display"), 
                min = min(i$measure), max = max(i$measure), 
                value = c(min(i$measure), max(i$measure)))
    # splitLayout(
    #   textInput("range_min", label = HTML("Minimum<br>", meas, ":"), 
    #             placeholder = min(i$measure), value = min(i$measure)),
    #   textInput("range_max", label = HTML("Maximum<br>", meas, ":"), 
    #             placeholder = max(i$measure), value = max(i$measure))
    # )
  })
  
  filtered_data <- shiny::reactive({
    if (!input$species == "All") {
      d <- iris[which(iris$Species == input$species), ]
    } else {
      d <- iris
    }
    d$measure <- d[, input$measure]
    d <- dplyr::filter(d, measure >= input$range[1], 
                       measure <= input$range[2])
    # d <- dplyr::filter(d, measure >= input$range_min, 
    #                    measure <= input$range_max)
    return(d)
  })
  
  output$hist_plot <- renderPlot({
    d <- filtered_data()
    b <- if (!is.na(input$bins)) input$bins else 30
    bins <- seq(min(d$measure), max(d$measure), length.out = as.numeric(b) + 1)
    hist(d$measure, breaks = bins, col = "#003865", border = "white",
         xlab = input$measure, main = paste("Histogram of", input$measure),
         xlim = c(min(d$measure), max(d$measure)))
  },
  # alt = reactive({
  #   d <- filtered_data()
  #   aria <- paste("Histogram of", input$measure, "in centimeters for", 
  #                 input$species, "irises.", input$measure, "ranges from", 
  #                 min(d$measure), "to", max(d$measure), "cm.",
  #                 "Refer to the table below the chart for values displayed.")
  #   return(aria)
  # })
  )
  
  output$bar_plot <- renderPlot({
    d <- filtered_data() |> dplyr::group_by(Species) |> 
         dplyr::summarise(Count = n(), .groups = "drop")
    ggplot(data = d, aes(x = Species, y = Count)) +
         geom_bar(stat = "identity", fill = "#003865") +
         labs(title = "Frequency chart of iris species") +
         theme_minimal() + 
         theme(axis.text  = element_text(size = 14),
               axis.title = element_text(size = 16), 
               plot.title = element_text(size = 18))
  },
  # alt = reactive({
  #   d <- filtered_data()
  #   aria <- paste("Barplot of", input$species, "irises filtered on", 
  #                 min(d$measure), "to", max(d$measure), input$measure, "cm.",
  #                 "Refer to the table below the chart for values displayed.")
  #   return(aria)
  # })
  )
  
  # chart descriptions ----
  # output$bar_desc <- shiny::renderText({
  #   d <- filtered_data()
  #   desc <- paste("This bar chart shows", input$species, 
  #                 "irises filtered on", input$measure, "ranging from", 
  #                 min(d$measure), "to", max(d$measure), "centimeters.")
  #   return(paste("<p>", HTML(desc), "</p>"))
  # })
  # output$hist_desc <- shiny::renderText({
  #   d <- filtered_data()
  #   desc <- paste("This histogram shows", input$measure, "ranging from", 
  #                 min(d$measure), "to", max(d$measure), "cm for", 
  #                 input$species, "irises. The median is", 
  #                 median(d$measure), "cm and the mean is", 
  #                 round(mean(d$measure), digits = 2), "cm.")
  #   return(paste("<p>", HTML(desc), "</p>"))
  # })

  # internal navigation links ----
  # observeEvent(input$link_tab_bar, {
  #   updateTabsetPanel(session, inputId = "my_tabs", selected = "tab_bar")
  # })
  # observeEvent(input$link_tab_hist, {
  #   updateTabsetPanel(session, inputId = "my_tabs", selected = "tab_hist")
  # })
  # observeEvent(input$link_tab_intro, {
  #   updateTabsetPanel(session, inputId = "my_tabs", selected = "tab_intro")
  # })
  
  # tables ----
  # output$hist_table <- DT::renderDT({
  #   b <- if (!is.na(input$bins)) as.numeric(input$bins) else 10
  #   d <- filtered_data() |> dplyr::mutate(Bins = cut(measure, b)) |>
  #     dplyr::group_by(Bins) |> dplyr::summarise(Count = n(), .groups = "drop")
  #   dt <- DT::datatable(d, rownames = FALSE, class = 'cell-border stripe',
  #                       options = list(pageLength = 10, searching = FALSE))
  #   return(dt)
  # })
  # output$bar_table <- DT::renderDT({
  #   d <- filtered_data() |> dplyr::group_by(Species) |> 
  #     dplyr::summarise(Count = n(), .groups = "drop")
  #   dt <- DT::datatable(d, rownames = FALSE, class = 'cell-border stripe',
  #                       options = list(paging = FALSE, searching = FALSE))
  #   return(dt)
  # })
}

shinyApp(ui = ui, server = server)
