#' Plot trends over time
#' 
#' @param d        Dataset
#' @param topic    Topic from user input
#' @param measure  Measure from user input
#' @param content  Content from user input
#' @param variable Variable from user input
#' 
# test code:
# df <- readRDS("vs_app/data/mom_risks.Rds")
# p <- plot_trend(d = df, content = "Pregnancy", topic = "State", 
#                 measure = "Number of Live Births", variable = "Pregnancies")
# df <- data.frame(Year = c("2000-2004", "2010-2014", "2015-2019"),
#                  Topic = rep("Aaron", 3), Variable = rep("Sex", 3),
#                  Group = rep("X", 3), Category = rep("X", 3),
#                  Measure = rep("Rank", 3), Count = 1:3, Value = 3:5)
# df <- readRDS("vs_app/data/birth_names.Rds")
# p <- plot_trend(d = df, content = "Birth names", topic = "Aaron", 
#                 measure = "Rank", variable = "Sex")

plot_trend <- function(d, content, variable, topic, measure) {
  d <- dplyr::filter(d, Topic == topic, Variable == variable)
  f <- readr::read_csv("data/factor_key.csv") |> dplyr::filter(var == variable)
  if (nrow(f) == 1) {
    l <- unlist(stringr::str_split(f$levels, pattern = ";"))
    d <- dplyr::mutate(d, Category = factor(Category, levels = l))
  }
  d <- d |>
    dplyr::mutate(Year = as.character(Year),
                  Year_first = as.numeric(substr(Year, 1, 4)),
                  Year_last = as.numeric(substr(Year, 6, 9)), 
                  Year_last = ifelse(is.na(Year_last), Year_first, Year_last), 
                  Year_range = Year_last - Year_first + 1, 
                  Year_range = ifelse(is.na(Year_range), 1, Year_range))  
  yf <- as.numeric(gsub(",", "", d$Year_first))
  yf <- yf[is.finite(yf)]
  yf_min <- min(yf)
  yf_max <- max(yf)
  yl <- as.numeric(gsub(",", "", d$Year_last))
  yl <- yl[is.finite(yl)]
  yl_min <- min(yl)
  yl_max <- max(yl)
  yr <- as.numeric(d$Year_range)[1]
  y <- data.frame(Year_first = seq(from = yf_min, to = yf_max, by = yr),
                  Year_last = seq(from = yl_min, to = yl_max, by = yr)) |>
    dplyr::mutate(Year = ifelse(Year_first == Year_last, 
                                as.character(Year_first),
                                paste(Year_first, Year_last, sep = "-")))
  
  s <- d |> dplyr::group_by(Category, Measure) |> dplyr::slice(1) |>
    dplyr::select(Category, Measure) |> dplyr::cross_join(y)
  
  d <- create_tooltip(d, measure = measure) |>
    dplyr::mutate(Year_first = as.numeric(gsub(",", "", Year_first)),
                  Year_last = as.numeric(gsub(",", "", Year_last))) |>
    dplyr::full_join(s, by = c("Year", "Category", "Measure", "Year_first",
                               "Year_last")) |>
    dplyr::arrange(Category, Measure, Year)

  my_y <- measure
  
  if (grepl("Rate", measure)) {
    d <- dplyr::mutate(d, val = as.numeric(gsub(",", "", Value)))
    if (length(unique(d$Measure)) > 1) my_y <- "Rate"
    # change this to read actual rate name later
    if (grepl("Birth|Natality|Mother", content)) {
      my_y <- paste(my_y, "per 1,000")
    } else if (grepl("Death|Mortality", content)) {
      my_y <- paste(my_y, "per 100,000")
    } 
  } else if (grepl("Count|Number", measure)) { 
    d <- dplyr::mutate(d, val = as.numeric(gsub(",", "", Count)))
    if (length(unique(d$Measure)) > 1) my_y = "Count"
  } else {
    d <- dplyr::mutate(d, val = as.numeric(gsub(",", "", Value)))
  }
  autorange <- TRUE
  
  if (content == "Birth names") { 
    if (measure == "Rank") autorange <- "reversed"
    d <- d |> dplyr::mutate(colors = Category)
  } else {
    d <- d |> dplyr::mutate(colors = Measure)
  }
  
  rows <- length(unique(d$Year))
  skips <- floor(rows / 8)
  yf <- d$Year_first[order(d$Year_first)]
  yf <- unique(yf)[seq(from = 1, to = rows, by = skips)]
  yl <- d$Year[order(d$Year)]
  yl <- unique(yl)[seq(from = 1, to = rows, by = skips)]
  
  p <- plot_ly(d, x = ~Year_first, y = ~val, color = ~colors,
               type = 'scatter', mode = "lines+markers", text = ~tooltip,
               connectgaps = FALSE, name = ~colors, hoverinfo = "text", 
               textposition = "none") |> 
     layout(xaxis = list(title = "Year", tickvals = yf, ticktext = yl),
            yaxis = list(title = my_y, autorange = autorange, 
                         rangemode = 'tozero'))  |>
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

