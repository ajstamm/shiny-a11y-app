# author: Abby Stamm
# date: August 2024
# purpose: functions for sample dashboard

line_table <- function(df) {
  if (ncol(df) > 1) {
    df <- df |> dplyr::mutate(year = as.numeric(substr(date_egg, 1, 4))) |>
      dplyr::group_by(species, year) |>
      dplyr::summarise(count = dplyr::n(), .groups = "drop") 
  } else {
    df <- data.frame(Message = paste("There are no valid penguins for these", 
                                     "filters. Please select different filters."))
  }
  return(df)
}

draw_line <- function(df, input) {
  d <- df |> line_table() |>
    dplyr::mutate(species = gsub("\\(", "\n(", species),
                  tip = paste("Species:", species, "\n", 
                              "Year hatched:", year, "\n", 
                              "Count:", count),
                  spec = gsub(" .+", "", species)) |> data.frame()
  # rownames(d) <- paste0(d$spec, ": ", d$count)
  
  mymode <- tolower(gsub(" ", "", input$line_display)) 
      # "lines+markers", "lines"
  mypal <- input$chart_palette # colorbrewer

  if (input$line_type == "No" & input$marker_type == "No") {
    p <- plotly::plot_ly(d, x = ~year, y = ~count, color = ~species,
                         colors = mypal, linetype = NULL, name = ~species, 
                         type = 'scatter', mode = mymode, text = ~tip,
                         connectgaps = FALSE, symbol = NULL,
                         hoverinfo = "text", textposition = "none")
  } else if (input$line_type == "No") {
    p <- plotly::plot_ly(d, x = ~year, y = ~count, color = ~species,
                         colors = mypal, linetype = NULL, name = ~species, 
                         type = 'scatter', mode = mymode, text = ~tip,
                         connectgaps = FALSE, symbol = ~species,
                         hoverinfo = "text", textposition = "none")
  } else if (input$marker_type == "No") {
    p <- plotly::plot_ly(d, x = ~year, y = ~count, color = ~species,
                         colors = mypal, linetype = ~species, name = ~species, 
                         type = 'scatter', mode = mymode, text = ~tip,
                         connectgaps = FALSE, symbol = NULL,
                         hoverinfo = "text", textposition = "none")
  } else {
    p <- plotly::plot_ly(d, x = ~year, y = ~count, color = ~species,
                         colors = mypal, linetype = ~species, name = ~species, 
                         type = 'scatter', mode = mymode, text = ~tip,
                         connectgaps = FALSE, symbol = ~species,
                         hoverinfo = "text", textposition = "none") 
  }
  if (input$chart_label == "Yes") {
    p <- p |> # plotly::layout(annotations = as.character(d$count)) # |>
      plotly::add_annotations(x = d$year, y = d$count, yshift = 10,
                              text = d$count, xref = "x", yref = "y",
                              # text = paste0(d$species, ": ", d$count),
                              showarrow = FALSE) # |>
      # plotly::add_text(textfont = t, textposition = "top right")
  }
  return(p)
}
