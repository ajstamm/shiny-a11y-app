#' Prepare download file
#' 
#' @param df          Dataset.
#' @param display_id  Chart ID from user selection.
#' 
#' 

prep_visual_table <- function(df, display_id = NULL) {
  # set up ----
  d <- df
  add_vars <- c("subtopic", "month", "variable", "category", 
                "value", "upper_cl", "lower_cl", "count", "population", 
                "measure", "note", "label")
  for (i in add_vars) {
    if (!i %in% names(d)) d <- d |> 
        dplyr::mutate(!!dplyr::sym(i) := as.numeric(NA))
  }

  # test: COPD, display_id = "Chart 2"
  chart_id <- display_id # to avoid object naming conflicts
  if (!is.null(display_id)) {
    d <- dplyr::filter(d, grepl(paste(chart_id, "($| )", sep = ""), display_id)) 
  } 
  d <- dplyr::select(d, -display_id)
  d$year <- as.character(d$year)
  d$geo_id <- as.character(d$geo_id)

  # drop empty columns for calculations
  dt <- dplyr::select_if(d, ~ !all(is.na(.)))

  # numeric values ----
  # reformat numbers
  # note: formatC converts NA to "NA"; label_comma does not
  d <- dplyr::relocate(d, where(is.numeric), .after=last_col())
  if (d$topic[1] %in% c("COPD", "Heart Attacks")) {
    d$count <- scales::label_comma(accuracy = 0.1)(as.numeric(d$count))
  } else {
    d$count <- scales::label_comma(accuracy = 1)(as.numeric(d$count))
  }
  d$population <- scales::label_comma(accuracy = 1)(as.numeric(d$population))
  d$value <- scales::label_comma(accuracy = 0.1)(as.numeric(d$value))
  d$upper_cl <- scales::label_comma(accuracy = 0.1)(as.numeric(d$upper_cl))
  d$lower_cl <- scales::label_comma(accuracy = 0.1)(as.numeric(d$lower_cl))

  # strings ----
  # - if only one value for variable.
  #   - if value does not contain "by", rename "category" to value in variable
  #   - if value contains "by", split variable and category into new variables
  if (exists("variable", where = dt) & exists("category", where = dt)) {
    var <- unique(d$variable)
    if (length(var) == 1) {
      if (grepl(" by ", var)) {
        e <- d |> dplyr::mutate(id = dplyr::row_number(),
                                ct = stringr::str_count(variable, " by ") + 1) |>
          tidyr::separate_longer_delim(category, delim = " by ") |>
          tidyr::separate_longer_delim(variable, delim = " by ") |>
          dplyr::group_by(id) |> 
          dplyr::slice(seq(from = 1, to = dplyr::n(), by = unique(ct) + 1)) |>
          dplyr::ungroup()
        d <- dplyr::select(e, -id, -ct) 
      } 
      var_new <- names(table(d$variable))
      d <- tidyr::pivot_wider(d, names_from = variable, values_from = category) 
      for (i in var_new) {
        d <- tidyr::unnest(d, !!dplyr::sym(i))
        d <- dplyr::relocate(d, !!dplyr::sym(i), .after  = geo_name)
      }
    }
  }
  
  # measures
  # - if only one value for measure, rename "value" to value in measure
  meas <- unique(d$measure)
  if (length(meas) == 1) {
    if (exists("value", where = d)) vals <- "value" else vals <- "count"
    d <- tidyr::pivot_wider(d, names_from = "measure", values_from = vals)
  }
  
  # reorder string variables
  d <- dplyr::relocate(d, label, .after=last_col())
  d <- dplyr::relocate(d, note, .after=last_col())

  # geography ----
  gvars <- c("state", "county", "city", "school district", "water system", 
             "school", "zip code", "census tract")
  n <- names(d)[tolower(names(d)) %in% gvars]
  for (i in n) d <- dplyr::relocate(d, !!dplyr::sym(i), .after = geo_name)

  # - if only one value for geography,
  #   - if geo_name not blank, rename "geo_name" to value in geography
  #   - if geo_name blank, rename "geo_id" to value in geography
  # reorder geography variables
  geo <- unique(d$geography)
  if (length(geo) == 1) {
    if ("geo_name" %in% names(dt)) vals <- "geo_name" else vals <- "geo_id"
    d <- dplyr::rename(d, !!dplyr::sym(geo) := !!dplyr::sym(vals))
    d <- dplyr::select(d, -geography)
  }
  
  # clean up ----
  # fix variable names if needed
  names(d) <- stringr::str_to_sentence(names(d))
  if (exists("Geo_id", where = d)) d <- dplyr::rename(d, Geo_ID = Geo_id)
  if (sum(grepl("-", d$Year)) > 0) d <- dplyr::rename(d, Years = Year)
  d <- dplyr::rename(d, Upper_CL = Upper_cl, Lower_CL = Lower_cl)

  d <- dplyr::select_if(d, ~ !all(is.na(.)))

  # return ----
  return(d)
}


