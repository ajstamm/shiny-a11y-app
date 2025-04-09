#' Plot trends over time
#' 
#' @param d          Dataset
#' @param my_colors  Vector of colors for plot lines
#' @param icd_year   ICD change year, if defined
#' 
#' 

plot_trend <- function(d, my_colors, icd_year = NULL, levels = NULL) {
  # handle time ----
  if (d$x_label[1] == "Month") {
    x <- mean(nchar(d$month), na.rm = TRUE)
    if (x == 3) {
      d <- dplyr::mutate(d, x_col = factor(x_col, levels = month.abb))
    } else if (x > 3) {
      d <- dplyr::mutate(d, x_col = factor(x_col, levels = month.name))
    }
    d <- dplyr::arrange(d, color_lab, shape_lab, measure, x_col)
  } else {
    d <- d |> 
      dplyr::mutate(Year = as.character(x_col),
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
    
    s <- d |> dplyr::group_by(color_lab, shape_lab, measure) |> dplyr::slice(1) |>
      dplyr::select(color_lab, shape_lab, measure) |> dplyr::cross_join(y)
    
    d <- d |> 
      dplyr::mutate(Year_first = as.numeric(gsub(",", "", Year_first)),
                    Year_last = as.numeric(gsub(",", "", Year_last))) |>
      dplyr::full_join(s, by = c("Year", "color_lab", "shape_lab", "measure", 
                                 "Year_first", "Year_last")) |>
      dplyr::arrange(color_lab, shape_lab, measure, x_col) |> 
      dplyr::mutate(x_col = Year_first)
  }

  # y labels ----
  my_y <- trimws(d$y_label[1])
  if (grepl("(r|R)ate", d$y_label[1])) {
    d <- d |> dplyr::mutate(val = as.numeric(gsub(",", "", value)))
    if (length(unique(d$measure)) > 1) my_y <- "Rate"
    # change this to read actual rate name later
    my_y <- gsub(" per .+", "", my_y)
    if (sum(grepl("Birth|Natality", c(d$datafeed, d$topic, d$subtopic)),
            na.rm = TRUE) > 0) {
      my_y <- paste(my_y, "per 1,000")
    } else if (sum(grepl("Hosp|(v|V)isit", c(d$datafeed, d$topic, d$subtopic)),
            na.rm = TRUE) > 0) {
      my_y <- paste(my_y, "per 10,000")
    } else if (sum(grepl("Death|Mortality", c(d$datafeed, d$topic, d$subtopic)),
            na.rm = TRUE) > 0) {
      my_y <- paste(my_y, "per 100,000")
    }
  } else if (grepl("Count|Number", d$y_label[1])) {
    d <- d |> dplyr::mutate(val = as.numeric(gsub(",", "", count)))
    if (length(unique(d$measure)) > 1) my_y = "Count"
  } else {
    d <- d |> dplyr::mutate(val = as.numeric(gsub(",", "", value)))
  }
  
  d <- d |> dplyr::rowwise() |>
    dplyr::mutate(name_lab = paste(unique(c(color_lab, shape_lab)), 
                                          collapse = ", "))

  # axis settings ----
  rows <- length(unique(d$x_col))
  skips <- floor(rows / 8)
  if (d$x_label[1] == "Month") {
    yl <- names(table(d$x_col))
    yf <- 1:length(yl)
    my_x <- "Month"
  } else {
    yf <- d$Year_first[order(d$Year_first)]
    yf <- unique(yf)[seq(from = 1, to = rows, by = skips)]
    yl <- d$Year[order(d$Year)]
    yl <- unique(yl)[seq(from = 1, to = rows, by = skips)]
    my_x <- "Year"
  }
  
  # icd year ----
  if (!is.null(icd_year) & !is.na(icd_year)) {
    d <- d |> dplyr::mutate(x_col = ifelse(x_col == icd_year, NA, x_col))
  }
  
  # name label
  d <- d |> dplyr::rowwise() |>
    dplyr::mutate(name_lab = paste(unique(c(color_lab, shape_lab)), 
                                   collapse = ", "))
  
  if (!is.null(levels)) {
    if (!is.na(levels)) {
      lvl <- unlist(stringr::str_split(levels, pattern = "; "))
      d$name_lab <- factor(d$name_lab, levels = lvl)
    }
  }

  # plot data ----
  if (identical(d$color_lab, d$shape_lab)) {
    p <- plotly::plot_ly(d, x = ~x_col, y = ~y_col, connectgaps = FALSE, 
                         mode = "lines+markers", type = 'scatter', text = ~tip, 
                         hoverinfo = "text", textposition = "none",
                         symbol = ~color_lab, color = ~color_lab, 
                         colors = my_colors, linetype = ~color_lab) 

  } else {
    p <- plotly::plot_ly(d, x = ~x_col, y = ~y_col, connectgaps = FALSE, 
                         mode = "lines+markers", type = 'scatter', text = ~tip, 
                         hoverinfo = "text", textposition = "none",
                         symbol = ~shape_lab, color = ~color_lab, 
                         # name doesn't order by factor level
                         # name = ~factor(name_lab, levels = lvl), 
                         name = ~name_lab, # breaks factor order
                         colors = my_colors, linetype = ~color_lab) 

  }
  if (!is.null(icd_year) & !is.na(icd_year)) {
    p <- p |>
      plotly::layout(shapes = list(list(type = "line", yref = "y0",
                                        y0 = 0, y1 = max(d$y_col, na.rm = TRUE),
                                        x0 = icd_year, x1 = icd_year,
                                        line = list(color = "grey", dash="dot"))))
  }
  p <- p |>
    plotly::layout(xaxis = list(ticklen = 0, tickvals = yl, ticktext = yl,
                                title = list(text = my_x)),
                   yaxis = list(title = list(text = my_y))) 

  # return ----
  return(p)
}

