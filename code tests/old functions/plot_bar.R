#' Plot name rank over time
#' 
#' @param d       Dataset
#' @param topic   Topic from user input
#' @param measure Measure from user input
#' @param year    Year selected in user input
#' 
# test code:
# df <- readRDS("vs_app/data/mom_risks.Rds")
# p <- plot_bar(d = df, topic = "Race/Ethnicity", variable = "Plural Births", 
#               measure = "Count", year = 2022)
#

plot_bar <- function(d, topic, variable, measure, year) {
  d <- d |> 
    dplyr::filter(Year == year, Topic == topic, Variable == variable) |>
    dplyr::mutate(Group = gsub(", ", ",\n", Group))
  
  if (length(unique(d$Group) > 1)) {
    d <- dplyr::mutate(d, x = Group)
    x_lab <- topic
  } else {
    d <- dplyr::mutate(d, x = Variable)
    x_lab <- unique(d$Group)
  }
  
  f <- readr::read_csv("data/factor_key.csv") |>
    dplyr::filter(var == variable)
  if (nrow(f) == 1) {
    l <- unlist(stringr::str_split(f$levels, pattern = ";"))
    d <- d |> 
      dplyr::mutate(Category = factor(Category, levels = l))
  }
  if (measure %in% d$Measure) d <- d |> dplyr::filter(Measure == measure)

  d <- create_tooltip(d, measure)

  if (grepl("Count|Number", measure)) {
    d <- d |> dplyr::mutate(val = as.numeric(gsub(",", "", Count)))
  } else {
    d <- d |> dplyr::mutate(val = as.numeric(Value))
  } 
  
  p <- plotly::plot_ly(d, x = ~x, y = ~val, color = ~Category,
               type = 'bar', text = ~tooltip, hoverinfo = "text", 
               textposition = "none") |>
    plotly::layout(xaxis = list(title = x_lab),
                   yaxis = list(title = measure, rangemode = 'tozero'))  |>
       plotly::config(displaylogo = FALSE, # displayModeBar = FALSE,
                      modeBarButtonsToRemove = list(
                        'pan2d',     # Remove pan (drag)
                        'resetScale2d',  # Remove reset axes
                        'zoom2d',    # Remove select zoom
                        'zoomIn2d',  # Remove zoom in
                        'zoomOut2d', # Remove zoom out
                        'lasso2d',   # Remove lasso select
                        'autoScale2d',  # Remove autoscale
                        "compareData",
                        "hoverClosestCartesian",
                        "hoverCompareCartesian",
                        'select2d'   # Remove box select
                      )) 
  
  return(p)
}


