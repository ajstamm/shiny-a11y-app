# sonify and BrailleR functions
# author: abby stamm (with starting code from Eric Kvale)
# date: January 2025

bills_df <- function(df, species, x, y, degrees = 3) {
  df$x <- unlist(df[, x])
  df$y <- unlist(df[, y])
  if (!grepl("All", species)) {
    peng <- gsub(" .+", "", species)
    df <- dplyr::filter(df, grepl(peng, species)) 
  }
  lm <- glm(y ~ poly(x, degree = degrees, raw = TRUE), family = "gaussian", 
            data = df)
  x <- seq(floor(min(df$x, na.rm = TRUE)), ceiling(max(df$x, na.rm = TRUE)), 1) 
  y <- predict(lm, list(x), type = "response")
  d <- data.frame(x = x, y = y) 
  return(d)
}

var_to_label <- function(var_name) {
  lbl <- unlist(stringr::str_split(var_name, pattern = "_"))
  lbl <- paste(tools::toTitleCase(lbl[1]), 
               tools::toTitleCase(lbl[2]), 
               paste0("(", lbl[3], ")"))
  return(lbl)

}

bills_plot <- function(df, species, x, y, degrees = 3) {
  d <- bills_df(df, species, x, y, degrees)
  lbl_x <- var_to_label(x)
  lbl_y <- var_to_label(y)
  title <- paste("Model of", lbl_x, "by", lbl_y, "for", species)
  p <- ggplot2::ggplot(d, aes(x = x, y = y)) +
       geom_point(size = 2, alpha = 0.7) +
       geom_line() +
       labs(title = title, y = lbl_y, x = lbl_x) +
       theme_minimal() 
  return(p)
}

# bills_plot(df = df, species = "Chinstrap Penguins", x = "flipper_length_mm", 
#            y = "body_mass_g", degrees = 4)

braille_table_hist <- function(var, var_name) {
  var <- var[!is.na(var)]
  p <- hist(var, col = "lightblue")
  txt <- gsub("with the title: with the title:", "with the title:", 
              utils::capture.output(BrailleR::VI(p)))
  bins <- gsub("[a-zA-Z,]|\\.$", " ", txt[grepl("It has ", txt)])
  bins <- trimws(gsub(" +", " ", bins))
  cuts <- as.numeric(unlist(stringr::str_split(bins, pattern = " ")))
  names(cuts) <- c("bins", "min", "max")
  bin_size <- unname((cuts["max"] - cuts["min"]) / cuts["bins"])
    
  tbl <- data.frame(desc = txt[grepl("^mid = ", txt)])
  
  tbl <- 
    dplyr::mutate(tbl,
                  min = (seq(from = cuts["min"] * 100, 
                             to = (cuts["max"] - bin_size) * 100,
                            by = bin_size * 100)) / 100,
                  max = (seq(from = (cuts["min"] + bin_size) * 100, 
                             to = cuts["max"] * 100,
                            by = bin_size * 100)) / 100,
                  count = as.numeric(gsub(".+count = ", "", desc)),
                  bin = paste(min, "-", max)) |>
    dplyr::select(bin, count)
  
  var_name <- unlist(stringr::str_split(var_name, pattern = "_"))
  var_name <- paste(tools::toTitleCase(var_name[1]), 
                    tools::toTitleCase(var_name[2]), 
                    paste0("(", var_name[3], ")"))

  names(tbl) <- c(paste("Range of", var_name), "Number of penguins")
  return(tbl)
}

braille_desc_box <- function(var) {
  var <- var[!is.na(var)]
  p <- boxplot(var, col = "blue")
  txt <- gsub("with the title: with the title:", "with the title:", 
              utils::capture.output(BrailleR::VI(p)))
  
  ## outliers ----
  outliers <- gsub("[a-zA-Z:]", " ", txt[grepl(" outlier ", txt)])
  outliers <- trimws(gsub(" +", " ", outliers))
  if (length(outliers) > 0) {
    outliers <- as.numeric(unlist(stringr::str_split(outliers, pattern = " ")))
    outliers <- paste(outliers[order(outliers)], collapse = ", ")
  } else {
    outliers = "none"
  }
  outliers <- paste("<li> Outliers:", outliers)
  
  ## box ----
  
  edges <- gsub("[a-zA-Z:]", " ", txt[grepl("^which ", txt)])
  edges <- trimws(gsub(" +", " ", edges))
  edges <- as.numeric(unlist(stringr::str_split(edges, pattern = " ")))
  
  edge1 <- paste("<li> First quartile:", edges[1])
  edge3 <- paste("<li> Third quartile:", edges[2])
  
  median <- gsub("[a-zA-Z,]", " ", txt[grepl("median", txt)])
  median <- trimws(gsub(" +", " ", median))
  median <- as.numeric(unlist(stringr::str_split(median, pattern = " ")))[1]
  
  median <- paste("<li> Median:", median)
  
  # The whiskers extend to 2700 and 6300 from the ends of the box,
  # which are at 3550 and 4750
  # The median, 4050 is 42 % from the lower end of the box to the upper end.
  
  ## whiskers ----
  
  whiskers <- gsub("[a-zA-Z,]", " ", txt[grepl(" whiskers ", txt)])
  whiskers <- trimws(gsub(" +", " ", whiskers))
  whiskers <- as.numeric(unlist(stringr::str_split(whiskers, pattern = " ")))
  
  # ~ round(mean(d$raw) + c(-1, 1) * 2.5 * sd(d$raw))
  
  whisker1 <- paste("<li> Lower whisker end:", whiskers[1])
  whisker2 <- paste("<li> Upper whisker end:", whiskers[2])
  
  ## table ----
  desc <- paste("<h4>Summary statistics</h4>", 
                "<ul>", whisker1, edge1, median, edge3, whisker2, 
                outliers, "</ul>", sep = "\n")
  return(HTML(desc))
}

table_display <- function(df) {
  if (ncol(df) == 1) { # no valid penguins
    dt <- DT::datatable(df, rownames = FALSE,
                        class = 'cell-border stripe',
                        options = list(paging = FALSE, searching = FALSE))
  } else {
    dt <- DT::datatable(df, extensions = c('Responsive'), escape = FALSE,
                        selection = "single", rownames = FALSE, 
                        options = list(responsive = TRUE, pageLength = 5,
                                       autoWidth = TRUE,
                                       columnDefs = list(list(targets = '_all', 
                                                              width = '20%'))),
                        class = 'cell-border stripe') 
  }
  return(dt)
}



generate_filename <- function(input, type = "data", package = "brailler") { 
  # Initialize the filename with a base name
  f <- c(type)
  if (package == "sonify") {
    peng <- gsub(" .+", "", input$species_sonify)
    if (!peng == "All") f <- c(f, peng)
    f <- c(f, input$x_sonify, input$y_sonify, input$degrees_sonify, "degrees")
  } else if (package == "brailler") {
    peng <- gsub(" .+", "", input$species_brailler)
    if (!peng == "All") f <- c(f, peng)
    f <- c(f, input$x_brailler)
  } 
  f <- paste(f, collapse = "-")
  if (type == "data") {
    f <- paste0(f, ".csv")
  } else {
    f <- paste0(f, ".pdf")
  }
  return(f)
}

