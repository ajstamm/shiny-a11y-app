#' create chart tooltips
#' 
#' This function creates dynamic tooltips for maps and charts based on the 
#' data available.
#' 
#' @param d       Dataset
#' 
#' 
# test code:
# df <- readRDS("vs_app/data/mom_risks.Rds")
# d <- create_tooltip(df, "Count")

create_tooltip <- function(d) {
  # add variables ----
  
  # variables missing from some datasets 
  add_vars <- c("subtopic", "month", "variable", "category", 
                "value", "upper_cl", "lower_cl", "count", "population", 
                "measure", "note", "label")
  all_vars <- c(add_vars, 
                # in all datasets
                "display_id", "topic", "datafeed", "year", 
                "geography", "geo_id", "geo_name", 
                # process variables
                "geometry", "min", "max", "cats", "my_values", 
                "color_by", "x", "y", "val", "leg_label", "geo_names")    

  nvars <- names(d)[!names(d) %in% all_vars]

  for (i in add_vars) {
    if (!i %in% names(d)) d <- d |> 
        dplyr::mutate(!!dplyr::sym(i) := as.numeric(NA))
  }
  
  # format standard variables ----
  d <- d |> 
    dplyr::mutate(
      geo_id = as.character(geo_id),
      dplyr::across(where(is.logical), as.numeric),
      count = as.numeric(gsub(",", "", count)),
      population = as.numeric(gsub(",", "", population)),
      year = as.character(year),
      population = formatC(population, big.mark=",", format = "f", digits = 0),
      note = ifelse(is.na(note) | note == "NA", "", note),
      label = ifelse(is.na(label) | label == "NA", "", label))
  
  if (d$topic[1] %in% c("COPD", "Heart Attacks")) {
    d <- d |> dplyr::mutate(count = formatC(count, big.mark=",", format = "f", 
                                            digits = 1))
  } else {
    d <- d |> dplyr::mutate(count = formatC(count, big.mark=",", format = "f", 
                                            digits = 0))
  }
  
  # set up tooltip parts ----
  d <- d |> 
    dplyr::mutate(
      dplyr::across(where(is.numeric), formatC, big.mark=",", format = "f",
                    digits = 1),
      tt_topic = ifelse(is.na(subtopic) | subtopic %in% c("", "NA"), 
                        paste0("<b>", topic, ":</b> ", datafeed),
                        paste0("<b>", topic, ":</b> ", datafeed, ", ", 
                               subtopic)),
      tt_year = paste("<b>Year:</b>", year),
      tt_month = ifelse(is.na(month) | month == "NA", "NA", 
                      paste("<b>Month:</b>", month)),
      tt_var = ifelse(is.na(category) | trimws(category) %in% c("", "NA"), 
                      "NA", paste0("<b>", variable, ":</b> ", category)),
      tt_count = ifelse(is.na(value), measure, "Count"),
      tt_count = ifelse(is.na(tt_count), "Count", tt_count),
      tt_count = ifelse(note == "Suppressed" | is.na(count) | count == "NA", 
                        "NA", paste0("<b>", tt_count, ":</b> ", count)),
      tt_pop = ifelse(is.na(population) | population == "NA", "NA", 
                      paste("<b>Population:</b>", population)),
      tt_note = ifelse(note %in% c("", "NA") | is.na(note), "NA", 
                       paste("<b>Note:</b>", note)),
      tt_label = ifelse(label %in% c("", "NA") | is.na(label), "NA", 
                        paste("<b>Label:</b>", label)),
      tt_extra = "") 
  

  # add extra variables to note ----
  if (length(nvars) > 0) {
    for (i in nvars) {
      d <- dplyr::mutate(d, 
             tt_extra = ifelse(is.na(!!dplyr::sym(i)) | !!dplyr::sym(i) == "", 
                               "NA\n", paste0(tt_extra, "<b>", i, ":</b> ", 
                                            !!dplyr::sym(i), "\n")))
    }
  }
  
  # handle measure, if relevant ----
  if (grepl(" rate| concentration", tolower(d$measure[1]))) {
    d <- d |> 
      dplyr::mutate(
        tt_val = ifelse(note == "Suppressed" | is.na(value) | value == "NA", "NA", 
                        paste0("<b>", measure, ":</b> ", value)),
        tt_cl = ifelse(is.na(lower_cl) | lower_cl == "NA", "NA", 
                       paste0("(", lower_cl, " - ", upper_cl, ")")))
  } else if (grepl("(P|p)ercent", d$measure[1])) {
    d <- d |> 
      dplyr::mutate(
        tt_val = ifelse(note == "Suppressed" | is.na(value) | value == "NA", "NA", 
                        paste0("<b>", measure, ":</b> ", value, "%")),
        tt_cl = ifelse(is.na(lower_cl) | lower_cl == "NA", "NA", 
                       paste0("(", lower_cl, "% - ", upper_cl, "%)")))
  } else if (grepl("Rank", d$measure[1])) {
    d <- d |> 
      dplyr::mutate(
        tt_val = ifelse(is.na(value) | value == "NA", "NA", 
                        paste("<b>Rank:</b>", as.numeric(value))),
        tt_cl = "NA")
  } else if (grepl("(N|n)umber|(C|c)ount", d$measure[1])) {
    d <- d |> 
      dplyr::mutate(
        tt_val = ifelse(is.na(value) | value == "NA", "NA", 
                        paste0("<b>", measure, ":</b> ", value)),
        tt_cl = "NA")
  } else {
    d <- d |> dplyr::mutate(tt_val = "NA", tt_cl = "NA")
  }
  
  # create tooltips ----
  d <- d |> 
    dplyr::mutate(
      tt_note = paste0(tt_extra, tt_note),
      tt_vci = ifelse(tt_val == "NA", "NA", 
               ifelse(tt_cl == "NA", tt_val, paste(tt_val, tt_cl))), 
      tip = paste0(tt_topic, "\n", tt_year, "\n", tt_month, "\n", 
                   tt_var, "\n", tt_count, "\n", tt_pop, "\n", 
                   tt_vci, "\n", tt_note, "\n", tt_label))
  d <- d |> 
    dplyr::mutate(
      tip = gsub("\nNA", "", tip),
      count = as.numeric(gsub(",", "", count)), 
      value= as.numeric(gsub(",", "", value))
    )
  
  # add geography ----
  if (!tolower(d$geography[1]) %in% c("state", "region")) {
    d <- dplyr::mutate(d,
      geo_name = ifelse(is.na(geo_name) | trimws(geo_name) == "", 
                        geo_id, geo_name),
      tt_geo = paste0("<b>", tools::toTitleCase(geography), ":</b> ", 
                      geo_name, "\n"),
      tip = paste0(tt_geo, tip))
  }
  
  # return ----
  return(d)
}

