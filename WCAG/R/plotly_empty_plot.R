# Function to create an empty plot with a message
plotly_empty_plot <- function(message) {
  p <- plotly::plot_ly(height = 100) |>
    plotly::add_annotations(text = message, x = 0.5, y = 0.5, showarrow = FALSE, 
                            xref = "paper", yref = "paper") |>
    plotly::layout(xaxis = list(zeroline = FALSE, showticklabels = FALSE, 
                                showgrid = FALSE, visible = FALSE),
                   yaxis = list(zeroline = FALSE, showticklabels = FALSE, 
                                showgrid = FALSE, visible = FALSE))
  return(p)
}


