# ----------<>----------<>----------<>----------<>----------<>---------- #
# author:  abby stamm                                                    #
# date:    august 2024                                                   #
# purpose: create minimal shiny app using palmer penguins data to test   #
#          text customization and keyboard and screen reader navigation  #
# goal:    1. side menu with drop-down and text input                    #
#          2. chart(s) with varied colors, symbols, patterns             #
#          3. responsive table                                           #
#          4. text that can change color, size, spacing                  #
#          5. dynamic table and download file for each chart             #
#          6. aria text for everything                                   #
# ----------<>----------<>----------<>----------<>----------<>---------- #

# load shiny ----
library(shiny)


# set up ----
files <- list.files("R/", pattern = ".R$") # isolate "*.R" files only
for (i in files) source(paste0("R/", i)) # load all R files in the folder
penguins <- describe_penguins()

# UI ----
ui <- fluidPage(
  # Set language attribute for accessibility
  tags$html(lang = "en"),
  # titlePanel(), or explicit with
  tags$title("WCAG with penguins"),
  
  # shinya11y::use_tota11y(),
  
  # Application title
  h1("Exploring Web Content Accessibility Guidelines (WCAG)"), 
     # style = "color: white; height: 0px;"
  h2("with palmer penguins", style = "color: green"),

  sidebarLayout(
    sidebar(penguins),
    main(penguins)
  )
)


# server ----
server <- function(input, output) {
  filtered_data <- reactive({
    df <- filter_penguins(input, df = penguins)
    return(df)
  })

  # data tables
  output$all_penguins <- DT::renderDT({
    df <- filtered_data() 
    if (ncol(df) > 1) {
      df <- df |> 
        dplyr::mutate(individual_id = paste('<details><summary aria-label="', 
                                   study_name, individual_id, sample_number, 
                                   '">', individual_id, '</summary></details>'))
    }
    dt <- table_penguins(df)
    return(dt)
  }, server = FALSE)
  
  output$sum_penguins <- DT::renderDT({
    df <- filtered_data() 
    df <- summarize_penguins(df)
    dt <- table_penguins(df)
    return(dt)
  }, server = FALSE)
  
  # about data
  output$text_play <- renderText({ 
    msg <- paste("To modify the formatting of this paragraph,",
                 "select alternate colors and values in the sidebar to the left.",
                 "Text will change in real time.")
    about <- format_text(input, message = msg)
    return(about)
  })
  
  output$sources_list <- renderText({ 
    src <- content_sources()
    return(src)
  })
  
  output$font_matrix <- DT::renderDT({ 
    fnt <- font_size_color_matrix()
    return(fnt)
  })
  
  
  # bar charts
  # output$bar_texture <- shiny::renderPlot({
  #   df <- filtered_data() 
  #   
  #   return(p)
  # })
  
  output$bar_chart <- ggiraph::renderGirafe({
    df <- filtered_data() 
    if (ncol(df) > 1) {
      if (input$bar_fill == 'Plain') {
        p <- draw_bar(df, input)
      } else {
        p <- draw_textured_bar(df, input)
      }
      g <- ggiraph::girafe(ggobj = p) 
    } else {
      g <- plotly_empty_plot(paste("No data are available for these filters.",
                                   "Please select different filters."))
    }
    return(g)
  })
  
  output$bar_table <- DT::renderDT({
    df <- filtered_data() 
    df <- bar_table(df)
    DT::datatable(df, extensions = c('Responsive'), selection = "single",
                  escape = FALSE, options = list(dom = 't'),
                  class = 'cell-border stripe', rownames = FALSE)
  })
  
  # line charts
  output$line_chart <- plotly::renderPlotly({
    df <- filtered_data() 
    if (ncol(df) > 1) {
      p <- draw_line(df, input)
    } else {
      p <- plotly_empty_plot(paste("No data are available for these filters.",
                                   "Please select different filters."))
    }
    
    return(p)
  })
  
  output$line_table <- DT::renderDT({
    df <- filtered_data() 
    df <- line_table(df)
    DT::datatable(df, extensions = c('Responsive'), selection = "single",
                  escape = FALSE, options = list(dom = 't'),
                  class = 'cell-border stripe', rownames = FALSE)
  })
}

# run app ----
shinyApp(ui = ui, server = server)

