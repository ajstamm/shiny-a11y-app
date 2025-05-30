# -------<>----------<>----------<>----------<>----------<>------ #
# author:  abby stamm                                             #
# date:    started august 2024                                    #
# purpose: create minimal shiny app using palmer penguins data    #
#          to test text customization and keyboard and screen     #
#          reader navigation                                      #
# goal:    1. side menu with drop-down and text input             #
#          2. chart(s) with varied colors, symbols, patterns      #
#          3. responsive table                                    #
#          4. text that can change color, size, spacing           #
#          5. dynamic table and download file for each chart      #
#          6. aria text for everything                            #
# -------<>----------<>----------<>----------<>----------<>------ #

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

  # data table: individual ----
  output$table_individual_title <- renderText({ 
    my_title <- paste("<h2>", "Table of individual penguin data for", 
                      input$species, "species", "</h2>")
    return(HTML(my_title))
  })
  
  output$table_individual_filters <- renderText({ 
    my_filters <- filters_text(input)
    return(HTML(my_filters))
  })
  
  output$table_individual_penguins <- DT::renderDT({
    df <- filtered_data() 
    if (ncol(df) > 1) {
      df <- df |> 
        dplyr::mutate(individual_id = 
                        paste('<details><summary aria-label="', 
                              study_name, individual_id, 
                              sample_number, '">', 
                              individual_id, '</summary></details>'))
    }
    dt <- table_penguins(df)
    return(dt)
  }, server = FALSE)
  
  # data table: summary ----
  output$table_sum_title <- renderText({ 
    my_title <- paste("<h2>", "Table of penguin counts by region,", 
                      "island, species, and sex", "</h2>")
    return(HTML(my_title))
  })
  
  output$table_sum_filters <- renderText({ 
    my_filters <- filters_text(input)
    return(HTML(my_filters))
  })
  
  output$table_sum_penguins <- DT::renderDT({
    df <- filtered_data() 
    df <- summarize_penguins(df)
    dt <- table_penguins(df)
    return(dt)
  }, server = FALSE)
  
  # text formatting ----
  output$text_play <- renderText({ 
    msg <- paste("To modify the formatting of this paragraph,",
                 "select alternate colors and values in the", 
                 "sidebar to the left.",
                 "Text will change in real time.")
    about <- format_text(input, message = msg)
    return(about)
  })
  
  output$text_pass <- renderText({
    ratio <- ratio_check(input)
    return(ratio)
  })
  
  output$sources_list <- renderText({ 
    src <- content_sources()
    return(src)
  })
  
  output$font_matrix <- DT::renderDT({ 
    fnt <- font_size_color_matrix()
    return(fnt)
  })
  
  
  # bar charts ----
  output$bar_title <- renderText({ 
    my_title <- paste("<h2>", "Bar chart of", input$species, 
                      "species by island", "</h2>")
    return(HTML(my_title))
  })
  
  output$bar_filters <- renderText({ 
    my_filters <- filters_text(input)
    return(HTML(my_filters))
  })
  
  output$bar_chart <- ggiraph::renderGirafe({
    df <- filtered_data() 
    if (ncol(df) > 1) {
      p <- draw_bar(df, input)
      g <- ggiraph::girafe(ggobj = p) 
      alt_text <- paste("Bar chart of number of penguins of each", 
                        "species on each island.",
                        "For species and counts, check the table",
                        "below.")
        
      g <- htmlwidgets::onRender(g, paste("
          function(el, x) {
            el.setAttribute('role', 'img');
            el.setAttribute('aria-label', '", alt_text, "');
          }")
      )
    } else {
      p <- gg_empty_plot(message = 
                           paste("No penguins are available for",
                                 "these filters.", "\n", 
                                 "Please select different filters."))
      g <- p
    }

    return(g)
  })
  
  output$bar_table <- DT::renderDT({
    df <- filtered_data() 
    df <- bar_table(df)
    names(df) <- tools::toTitleCase(gsub("_", " ", names(df)))
    DT::datatable(df, extensions = c('Responsive'), escape = FALSE, 
                  selection = "single", options = list(dom = 't'),
                  class = 'cell-border stripe', rownames = FALSE)
  })
  
  output$bar_dl <- shiny::downloadHandler(
    filename = function() {
      filename = "counts-bar-species-island.csv"
      return(filename)
    },
    content = function(file) {
      df <- filtered_data()
      df <- bar_table(df)
      write.csv(df, file, row.names = FALSE, na = "")
    }
  )
  
  # line charts ----
  output$line_title <- renderText({ 
    my_title <- paste("<h2>", "Line chart of", input$species, 
                      "species by year hatched", "</h2>")
    return(HTML(my_title))
  })

  output$line_filters <- renderText({ 
    my_filters <- filters_text(input)
    return(HTML(my_filters))
  })

  output$line_chart <- plotly::renderPlotly({
    df <- filtered_data() 
    if (ncol(df) > 1) {
      p <- draw_line(df, input)
      alt_text <- paste("Line chart of number of penguins of each",
                        "species by year hatched.",
                        "For species and counts, check the table",
                        "below.")
      
      p <- htmlwidgets::onRender(p, paste("
        function(el, x) {
          el.setAttribute('role', 'img');
          el.setAttribute('aria-label', '", alt_text, "');
        }")
      )
    } else {
      p <- plotly_empty_plot(paste("No data are available for",
                                   "these filters. Please select",
                                   "different filters."))
    }
    
    return(p)
  })
  
  output$line_table <- DT::renderDT({
    df <- filtered_data() 
    df <- line_table(df)
    names(df) <- tools::toTitleCase(gsub("_", " ", names(df)))
    DT::datatable(df, extensions = c('Responsive'), escape = FALSE, 
                  selection = "single", options = list(dom = 't'),
                  class = 'cell-border stripe', rownames = FALSE)
  })
  
  output$line_dl <- shiny::downloadHandler(
    filename = function() {
      filename = "counts-line-species-year.csv"
      return(filename)
    },
    content = function(file) {
      df <- filtered_data()
      df <- line_table(df)
      write.csv(df, file, row.names = FALSE, na = "")
    }
  )

}

# run app ----
shinyApp(ui = ui, server = server)

