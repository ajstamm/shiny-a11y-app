#' Format the appendix
#' 
#' @param file Markdown file containing the appendix content

# function to handle appendix 
# p <- prep_about(file = "vs_app/tech_notes.md")

read_about <- function(file = "tech_notes.md") {
  appendix <- readLines(file)
  headers <- appendix[grepl("# Appendix ", appendix)]
  items <- DescTools::SplitAt(appendix, which(appendix %in% headers))
  # first list item element is first element; can drop
  items <- items[2:length(items)] 
  items <- lapply(items, function(x) { 
    # t <- paste(x[3:length(x)], collapse = "<br>")
    t <- x[3:length(x)]
    t <- shiny::markdown(t)
    return(t)
  })
  names(items) <- trimws(gsub("#", "", headers))
  return(items)
}

prep_about <- function(items) {
  names(items) <- paste("<summary>", names(items), "</summary>")
  items <- paste("<details>", names(items), items, "</details>")
  md <- paste(unlist(unname(items)), collapse = " ")
  return(md)
}

