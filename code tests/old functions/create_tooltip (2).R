#' create chart tooltips
#' 
#' @param d       Dataset
#' @param measure Measure from user input
#' 
#' 
# test code:
# df <- readRDS("vs_app/data/mom_risks.Rds")
# d <- create_tooltip(df, "Count")

create_tooltip <- function(d, measure) {
  vars <- c("Value", "UCL", "LCL", "Measure", "Annotation", "Population")
  for (i in vars) {
    if (!i %in% names(d)) d <- d |> 
        dplyr::mutate(!!dplyr::sym(i) := as.numeric(NA))
  }
  d <- d |> 
    dplyr::mutate(
      Year = as.character(Year),
      dplyr::across(c(Count, Population), formatC, big.mark=",", format = "f", 
                    digits = 0),
      dplyr::across(where(is.numeric), formatC, big.mark=",", format = "f", 
                    digits = 1),
      Annotation = ifelse(is.na(Annotation) | Annotation == "NA", "", Annotation))
  d <- d |> 
    dplyr::mutate(
      tt_topic = paste0("<b>", Topic, ":</b> ", Group),
      tt_year = paste0("<b>Year:</b> ", Year),
      tt_var = paste0("<b>", Variable, ":</b> ", Category),
      tt_count = ifelse(is.na(Value), Measure, "Count"),
      tt_count = ifelse(is.na(tt_count), "Count", tt_count),
      tt_count = ifelse(Annotation == "Suppressed" | is.na(Count) | Count == "NA", "NA",
                        paste0("<b>", tt_count, ":</b> ", Count)),
      tt_pop = ifelse(is.na(Population) | Population == "NA", "NA", 
                      paste0("<b>Population:</b> ", Population)),
      tt_note = ifelse(Annotation %in% c("", "NA") | is.na(Annotation), "NA", 
                       paste0("<b>Annotation:</b> ", Annotation)))
  if (grepl("(R|r)ate", measure)) {
    d <- d |> 
      dplyr::mutate(
        tt_val = ifelse(Annotation == "Suppressed" | is.na(Value) | Value == "NA", "NA", 
                        paste0("<b>", Measure, ":</b> ", Value)),
        tt_ci = ifelse(is.na(LCL) | LCL == "NA", "NA", 
                       paste0("(", LCL, " - ", UCL, ")")))
  } else if (grepl("(P|p)ercent", measure)) {
    d <- d |> 
      dplyr::mutate(
        tt_val = ifelse(Annotation == "Suppressed" | is.na(Value) | Value == "NA", "NA", 
                        paste0("<b>", Measure, ":</b> ", Value, "%")),
        tt_ci = ifelse(is.na(LCL) | LCL == "NA", "NA", 
                       paste0("(", LCL, "% - ", UCL, "%)")))
  } else if (grepl("Rank", measure)) {
    d <- d |> 
      dplyr::mutate(
        tt_val = ifelse(is.na(Value) | Value == "NA", "NA", 
                        paste0("<b>Rank:</b> ", as.numeric(Value))),
        tt_ci = "NA")
  } else {
    d <- d |> dplyr::mutate(tt_val = "NA", tt_ci = "NA")
  }
  d <- d |> 
    dplyr::mutate(
      tt_vci = ifelse(tt_val == "NA", "NA", 
               ifelse(tt_ci == "NA", tt_val, paste(tt_val, tt_ci))), 
      tooltip = paste0(tt_year, "\n", tt_topic, "\n", tt_var, "\n", 
                       tt_count, "\n", tt_pop, "\n", tt_vci, "\n", 
                       tt_note, "\n"),
      tooltip = gsub("NA\n", "", tooltip),
      count = as.numeric(gsub(",", "", Count)), 
      value= as.numeric(gsub(",", "", Value))
    )
  
  return(d)
}

