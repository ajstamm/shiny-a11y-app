#' Generate dynamic chart titles
#' 
#' @param input List of filter settings
#' 
#' 


generate_subtitle <- function(input) {
  # Check each filter and append its value to the string if active
  if (!is.null(input$content)) {
    active_filters <- paste("Content area =", input$content)
  }
  if (!is.null(input$topic) && !input$topic == "All") {
    active_filters <- c(active_filters, paste("Topic =", input$topic))
  }
  if (!is.null(input$group) && !input$group == "All") {
    active_filters <- c(active_filters, paste("Group =", input$group))
  }
  if (!is.null(input$variable) && !input$variable == "All") {
    active_filters <- c(active_filters, paste("Variable =", input$variable))
  }
  if (!is.null(input$category) && !input$category == "All") {
    active_filters <- c(active_filters, paste("Category =", input$category))
  }
  if (!is.null(input$measure) && !input$measure == "All") {
    active_filters <- c(active_filters, paste("Measure =", input$measure))
  }
  if (!is.null(input$year) && !input$year == "All") {
    active_filters <- c(active_filters, paste("Year =", input$year))
  }
  if (length(active_filters) > 0) {
    subtitle <- paste("<i>Filters:</i>", paste(active_filters, collapse = "; "))
  } else {
    subtitle <- "<i>Filters: None</i>"
  }
  
  return(subtitle)
}
