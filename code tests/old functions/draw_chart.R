#' Draw a chart
#' 
#' Draw one of several charts. This code has been rewritten to reflect the 
#' July 2024 proposed dataset structure.
#' 
#' @param df               Dataset.
#' @param chart_id         Chart ID from user selection.
#' @param plot_type        Plot type. Relevant values include "bar", 
#'                         "bar-flip", "stacked-bar", and "line". 
#'                         (Note maps use a separate function.)
#' @param x_col            X-axis variable.
#' @param y_col            Y-axis variable.
#' @param color_by         Categorical variable to color data by in the chart.
#' @param icd_change_year  ICD change year, if defined.
#' @param x_lab            X-axis label, if custom. (Defaults to the "variable" 
#'                         value for bar charts and the x-axis variable for 
#'                         line charts.)
#' @param y_lab            Y-axis label, if custom. (Defaults to the "measure" 
#'                         value.)
#' @param legend_title     Title for the legend. (Defaults to the "measure" 
#'                         value.)
#' @param levels           Factor levels for categorical variables.
#' 
#' 

draw_chart <- function(df, chart_id, plot_type  = "bar", 
                       x_col = "category", y_col = "value", 
                       color_by = NULL, icd_change_year = NULL, 
                       x_lab = NULL, y_lab = NULL, 
                       legend_title = NULL, levels = NULL) {
  # prep dataset ----
  d <- dplyr::filter(df, display_id == chart_id) |> create_tooltip()

  # y values and label ----
  if (is.null(y_lab)) {
    y_lab <- d$measure[1]
  } else if (is.na(y_lab)) {
    y_lab <- d$measure[1]
  } 
  y_lab <- gsub("_| per .+", " ", tools::toTitleCase(y_lab)) 
  y_lab <- trimws(y_lab)
  if (grepl("(r|R)ate", y_lab)) {
    if (length(unique(d$measure)) > 1) y_lab <- "Rate"
    # change this to read actual rate name later
    if (sum(grepl("Birth|Natality", c(d$datafeed, d$topic, d$subtopic)), 
            na.rm = TRUE) > 0) {
      y_lab <- paste(y_lab, "per 1,000")
    } else if (sum(grepl("Hosp|(v|V)isit", c(d$datafeed, d$topic, d$subtopic)), 
            na.rm = TRUE) > 0) {
      y_lab <- paste(y_lab, "per 10,000")
    } else if (sum(grepl("Death|Mortality", c(d$datafeed, d$topic, d$subtopic)), 
            na.rm = TRUE) > 0) {
      y_lab <- paste(y_lab, "per 100,000")
    }
  } else if (grepl("Count|Number", y_lab)) { 
    if (length(unique(d$measure)) > 1) y_lab = "Count"
  } 
  d <- d |> dplyr::mutate(val = gsub(",", "", unname(unlist(d[, y_col]))),
                          y_col = round(as.numeric(val), digits = 1))
  d$y_label <- y_lab

  
  # x values and legend ----
  if (is.na(color_by)) color_by <- ""
  if (grepl("bar", plot_type)) {
    if (!x_col == "category") {
      d$x_col <- unlist(d[, x_col])
      if (color_by == "category") {
        d$color_lab <- d$category
        d$shape_lab <- d$category
      } else {
        d$color_lab <- "All"
        d$shape_lab <- "All"
      }
      d$category <- d[, x_col]
      d$variable <- tools::toTitleCase(x_col)
      if (grepl("^geo", x_col)) d$variable <- "Geography"
    }
  }
  if (grepl("bar", plot_type) | color_by == "category") {
    if (is.null(legend_title)) {
      legend_title <- d$variable[1]
    } else if (is.na(legend_title)) {
      legend_title <- d$variable[1]
    }
    legend_title <- stringr::str_wrap(legend_title, width = 30)
    vars <- unique(d$variable)
  
    if (grepl(" by ", vars[1])) {
      d <- d |> dplyr::mutate(id = dplyr::row_number(),
                                ct = stringr::str_count(variable, " by ") + 1) |>
        tidyr::separate_longer_delim(category, delim = " by ") |>
        tidyr::separate_longer_delim(variable, delim = " by ") |>
        dplyr::group_by(id) |> 
        dplyr::slice(seq(from = 1, to = dplyr::n(), by = unique(ct) + 1)) |>
        dplyr::ungroup()
      vars <- unique(d$variable)
    } 
    d <- tidyr::pivot_wider(d, names_from = variable, values_from = category)
    
    show_legend  <- FALSE
    if (grepl("line", plot_type)) {
      d$x_col <- unname(unlist(d[, x_col]))
      d$color_lab <- unlist(d[, vars[1]])
      d$shape_lab <- unlist(d[, vars[length(vars)]])
      if (is.null(x_lab)) {
        x_lab <- gsub("_", " ", tools::toTitleCase(x_col))
      }
      show_legend <- TRUE
    } else if (grepl("bar", plot_type)) {
      if (is.null(d$x_col)) {
        d$x_col <- unlist(d[, vars[1]])
        d$color_lab <- unlist(d[, vars[length(vars)]])
        d$shape_lab <- unlist(d[, vars[length(vars)]])
      }
      if (is.null(x_lab)) {
        x_lab <- gsub("_", " ", tools::toTitleCase(vars[1]))
      } else if (is.na(x_lab)) {
        x_lab <- gsub("_", " ", tools::toTitleCase(vars[1]))
      }
      x_labels <- names(table(d$x_col))
      if (length(vars) > 1 | !sum(d$color_lab == d$x_col, na.rm = TRUE) > 0) 
        show_legend <- TRUE
    }
  } else {
    show_legend  <- TRUE
    d$x_col <- unname(unlist(d[, x_col]))
    d$color_lab <- unlist(d[, color_by])
    d$shape_lab <- unlist(d[, color_by])
    if (is.null(x_lab) | is.na(x_lab)) {
      x_lab <- gsub("_", " ", tools::toTitleCase(x_col))
    }
  }
  if (is.na(x_lab) & plot_type == "line") {
    x_lab <- tools::toTitleCase(x_col)
  }
  d$x_label <- x_lab

  if (!is.null(levels)) {
    if (!is.na(levels)) {
      lvl <- unlist(stringr::str_split(levels, pattern = "; "))
      if (identical(d$shape_lab, d$color_lab)) { 
        d$shape_lab <- factor(d$shape_lab, levels = lvl)
      }
      d$color_lab <- factor(d$color_lab, levels = lvl)
    }
  }
  
  # colors ----
  margins <- list(l = 100, r = 100, b = 100, t = 20, pad = 10)
  # reordered, from RColorBrewer::brewer.pal(12, "Paired")[c(2,4,6,8,10,12)]
  colors <-  c("#FF7F00", "#6A3D9A", "#1F78B4", "#E31A1C", "#33A02C", "#B15928") 
  # colors <- c("#003865", "#78BE21", "#008EAA", "#0D5257", "#8D3F2B", "#5D295F", "#53565A")
  colors <- c("#003865", "#68A51D", "#008EAA", "#0D5257", "#8D3F2B", "#5D295F", "#53565A")
  colors <- unname(colors)[1:length(unique(d$color_lab))]

  # plot data ----
  if (grepl("bar", plot_type)) {
    if (plot_type == "bar") {
      if (!identical(as.character(d$color_lab), as.character(d$x_col))) {
        p <- plotly::plot_ly(d, x = ~x_col, y = ~y_col, color = ~color_lab,
                             type = 'bar', text = ~tip, hoverinfo = "text", 
                             textposition = "none", colors = colors) 
      } else {
        p <- plotly::plot_ly(d, x = ~x_col, y = ~y_col, color = ~color_lab,
                             type = 'bar', text = ~tip, hoverinfo = "text", 
                             textposition = "none", colors = colors[1]) 
      }
    } else if (plot_type == "stacked-bar") {
      if (!identical(as.character(d$color_lab), as.character(d$x_col))) {
        p <- plotly::plot_ly(d, x = ~x_col, y = ~y_col, color = ~color_lab,
                             type = 'bar', text = ~tip, hoverinfo = "text", 
                             textposition = "none", colors = colors, 
                             stroke = "white", strokes = "white") 
      } else {
        p <- plotly::plot_ly(d, x = ~x_col, y = ~y_col, color = ~color_lab,
                             type = 'bar', text = ~tip, hoverinfo = "text", 
                             textposition = "none", colors = colors[1], 
                             stroke = "white", strokes = "white") 
      }
      p <- p |> plotly::layout(barmode = 'stack')
    } else if (plot_type == "bar-flip") {
      p <- plotly::plot_ly(d, x = ~x_col, y = ~y_col, color = ~color_lab,
                           type = 'bar', text = ~tip, hoverinfo = "text", 
                           textposition = "none", colors = colors,
                           orientation = 'h') 
    } 
    p <- p |>
      plotly::layout(xaxis = list(ticktext = x_labels,
                                  title = list(text = x_lab)),
                     yaxis = list(title = list(text = y_lab)))
  } else if (plot_type == "line") {
    p <- plot_trend(d = d, my_colors = colors, icd_year = icd_change_year,
                    levels = levels)
  }

  # add layout ----
  p <- p |> 
    plotly::layout(dragmode = "pan", margin = margins,
                   font = list(family = "Arial", color = "black"),
                   # legend = list(title = list(text = legend_title,
                   #                            font = list(size = 18)),
                   #               font = list(size = 16)), 
                   xaxis = list(tickfont = list(size = 16),
                                title = list(standoff = 20, 
                                             font = list(size = 18))),
                   yaxis = list(title = list(standoff = 20, 
                                             font = list(size = 18)), 
                                rangemode = "tozero",
                                tickfont = list(size = 16))) 
  # for some reason this works better when called after above layout
  p <- p |> 
    plotly::layout(hoverlabel = list(bgcolor = "white", 
                                     font = list(size = 14))) 

  if (show_legend) {
    p <- p |> 
      plotly::layout(legend = list(title = list(text = legend_title,
                                                font = list(size = 18)),
                                  font = list(size = 16)))
  } else {
    p <- p |> 
      plotly::layout(showlegend = FALSE)
  }
  
  # add configuration ----
  p <- p |>
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
  
  # return ----
  return(p)
}
