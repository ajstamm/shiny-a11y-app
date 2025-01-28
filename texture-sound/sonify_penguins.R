# Load necessary libraries ----
library(shiny)
library(ggplot2)
library(sonify)
library(BrailleR)
library(dplyr)
library(plotly)
# library(palmerpenguins)  # This package contains the penguins dataset
library(shinythemes)  # For themes

source("R/functions.R")
source("R/ui_functions.R")


## Generate dnorm() dataset ----
normal_data <- data.frame(index = 1:100, 
                          normal_data = dnorm(1:100, mean = 50, sd = 10))

## Load penguin dataset ----
penguins <- palmerpenguins::penguins  # Load the penguins dataset directly

# Define UI ----
ui <- fluidPage(
  theme = shinytheme("united"),  # Apply the "united" theme for a modern look
  # Application title
  titlePanel("Sound, Touch, and Text: Accessible Data Exploration in R"),
  # dashboard content
  main_ui()
)

# Define server logic ----
server <- function(input, output, session) {
  
  ## Sonification Tab ----
  # Normal distribution plot
  output$normal_dist_plot <- plotly::renderPlotly({
    p <- ggplot(normal_data, aes(x = index, y = normal_data)) +
      geom_point(size = 2, alpha = 0.7) +
      geom_line() +
      labs(title = "Normal Distribution Created by dnorm()", 
           y = "Density", x = "Index") +
      theme_minimal()
    
    plotly::ggplotly(p)
  })
  
  # Button to play sonification of normal distribution
  observeEvent(input$play_sonify_normal, {
    sonify(normal_data$normal_data, 
           flim = c(450, as.numeric(input$freq_high_sonify)), 
           duration = as.numeric(input$duration_sonify))
  })
  
  # Penguin data filtering
  filtered_data_sonify <- reactive({
    t <- dplyr::filter(penguins, !is.na(bill_length_mm))
    if (!grepl("All", input$species_sonify)) {
      peng <- gsub(" .+", "", input$species_sonify)
      t <- dplyr::filter(t, grepl(peng, species)) 
    }
    t <- dplyr::mutate(t, index = row_number()) # Create index column
    return(t)
  })
  
  output$sonify_penguin_plot <- plotly::renderPlotly({
    df <- filtered_data_sonify()
    p <- bills_plot(df, species = input$species_sonify,
                    x = input$x_sonify, y = input$y_sonify,
                    degrees = input$degrees_sonify)
    q <- plotly::ggplotly(p)
    return(q)
  })
  
  output$download_model <- downloadHandler(
    filename = function() {
      filename = generate_filename(input = input, type = "model", 
                                   package = "sonify")
      return(filename)
    },
    content = function(file) {
      df <- filtered_data_sonify()
      d <- bills_df(df, species = input$species_sonify,
                    x = input$x_sonify, y = input$y_sonify,
                    degrees = input$degrees_sonify)
      lbl_x <- var_to_label(input$x_sonify)
      lbl_y <- var_to_label(input$y_sonify)
      title <- paste("Model of", lbl_x, "\n by", lbl_y, 
                     "\n for", input$species_sonify)
      tactileR::brl_begin(file = generate_filename(input = input, 
                                                   type = "model", 
                                                   package = "sonify"), 
                          pt = 11, paper = 'special', font = 'BRL')
        p <- plot(d$x, d$y, col = "white", xlab = lbl_x, ylab = lbl_y, 
                  main = title)
        lines(d$x, d$y)
      tactileR::brl_end()
    }
  )
  
  output$download_boxplot <- downloadHandler(
    filename = function() {
      filename = generate_filename(input = input, type = "boxplot", 
                                   package = "brailler")
      return(filename)
    },
    content = function(file) {
      df <- filtered_data_brailler()
      lbl_x <- var_to_label(input$x_brailler)
      title <- paste("Boxplot of", x_var, "\n for", input$species_brailler)
      tactileR::brl_begin(file = generate_filename(input = input, 
                                                   type = "boxplot", 
                                                   package = "brailler"), 
                          pt = 11, paper = 'special', font = 'BRL')
      x <- unlist(df[, input$x_brailler])
      p <- boxplot(x, xlab = input$species_brailler, ylab = x_var, 
                   main = title)
      tactileR::brl_end()
    }
  )

  output$download_histogram <- downloadHandler(
    filename = function() {
      filename = generate_filename(input = input, type = "histogram", 
                                   package = "brailler")
      return(filename)
    },
    content = function(file) {
      df <- filtered_data_brailler()
      lbl_x <- var_to_label(input$x_brailler)
      title <- paste("Histogram of", lbl_x, "\n for", input$species_brailler)
      tactileR::brl_begin(file = generate_filename(input = input, 
                                                   type = "histogram", 
                                                   package = "brailler"), 
                          pt = 11, paper = 'special', font = 'BRL')
        x <- unlist(df[, input$x_brailler])
        p <- hist(x, xlab = lbl_x, main = title)
      tactileR::brl_end()
    }
  )

  
  # Button to play sonification of penguin data
  observeEvent(input$play_sonify_penguin, {
    df <- filtered_data_sonify()
    d <- bills_df(df, species = input$species_sonify,
                  x = input$x_sonify, y = input$y_sonify,
                  degrees = input$degrees_sonify)
    if (nrow(d) > 0) {
      sonify(x = d$x, y = d$y, 
             flim = c(450, as.numeric(input$freq_high_sonify)), 
             duration = as.numeric(input$duration_sonify))
    } else {
      showNotification("No data available to sonify for this species.", 
                       type = "warning")
    }
  })
  
  ## Data Textualization (BrailleR) Tab ----
  filtered_data_brailler <- reactive({
    t <- dplyr::filter(penguins, !is.na(bill_length_mm))
    if (!grepl("All", input$species_brailler)) {
      peng <- gsub(" .+", "", input$species_brailler)
      t <- dplyr::filter(t, grepl(peng, species)) 
    }
    t <- dplyr::mutate(t, index = row_number()) # Create index column
    return(t)
  })
  
  # Create and display the histogram using BrailleR
  output$hist_plot <- renderPlot({
    df <- filtered_data_brailler()
    lbl_x <- var_to_label(input$x_brailler)
    title <- paste("Histogram of", lbl_x, "for", input$species_brailler)
    x <- unlist(df[, input$x_brailler])
    hist(x, xlab = lbl_x, col = "lightblue", main = title)
  })
  
  # Capture and display the BrailleR text output for the histogram
  output$hist_description <- renderText({
    df <- filtered_data_brailler()
    # Avoid repeating "with the title" twice
    lbl_x <- var_to_label(input$x_brailler)
    x <- unlist(df[, input$x_brailler])
    p <- hist(x, xlab = lbl_x, col = "lightblue")
    txt <- gsub("with the title: with the title:", "with the title:", 
                capture.output(VI(p)))
    txt <- paste('<p style="color: blue;">', txt, '</p>')
    return(HTML(txt))
  })
  
  output$hist_table <- DT::renderDT({
    df <- filtered_data_brailler() 
    df <- braille_table_hist(var = unlist(df[, input$x_brailler]),
                             var_name = input$x_brailler)
    dt <- table_display(df)
    return(dt)
  }, server = FALSE)

  
  # Create and display the boxplot using BrailleR
  output$box_plot <- renderPlot({
    df <- filtered_data_brailler()
    lbl_x <- var_to_label(input$x_brailler)
    title <- paste("Boxplot of", lbl_x, "for", input$species_brailler)
    x <- unlist(df[, input$x_brailler])
    boxplot(x, ylab = lbl_x, xlab = "Index", main = title)
  })
  
  # Capture and display the BrailleR text output for the boxplot
  output$box_description <- renderText({
    df <- filtered_data_brailler()
    # Ensure proper labeling for x and y axes
    lbl_x <- var_to_label(input$x_brailler)
    x <- unlist(df[, input$x_brailler])
    p <- boxplot(x, xlab = "Index", ylab = lbl_x)
    txt <- capture.output(VI(p))
    txt <- paste('<p style="color: blue;">', txt, '</p>')
    return(HTML(txt))
  })
  
  output$box_summary <- renderText({
    df <- filtered_data_brailler() 
    desc <- braille_desc_box(unlist(df[, input$x_brailler]))
    desc <- (desc)
    return(desc)
  })

}

# Run the application ----
shinyApp(ui = ui, server = server)
