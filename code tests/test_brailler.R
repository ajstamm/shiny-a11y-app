# test braille to text to table

# dataset ----
d <- tibble::tibble(id = 1:1000, 
                    raw = rnorm(n = 1000, mean = 50, sd = 15),
                    round = round(raw))

pg <- palmerpenguins::penguins  # Load the penguins dataset directly
library(ggplot2)

g <- pg |> dplyr::filter(grepl("Gentoo", species))


tactileR::brl_begin(file='tactile.pdf', pt=11, paper='special', font='BRL')
d <- bills_df(pg, species = "All Penguins",
              x = "bill_depth_mm", y = "body_mass_g", degrees = 3)
p <- plot(d$x, d$y, col = "white", xlab = "Bill depth (mm)",
          ylab = "Body mass (g)", main = "Penguin bill depth by body mass")
lines(d$x, d$y)
tactileR::brl_end()

braille_table_hist(var = g$bill_depth_mm, var_name = "bill_depth_mm")






# functions ----
braille_desc_box <- function(var) {
  # boxplot ----
  p <- boxplot(d$round, col = "blue")
  txt <- gsub("with the title: with the title:", "with the title:", 
              utils::capture.output(BrailleR::VI(p)))
  
  ## outliers ----
  outliers <- gsub("[a-zA-Z:]", " ", txt[grepl(" outlier ", txt)])
  outliers <- trimws(gsub(" +", " ", outliers))
  if (nchar(outliers) > 0) {
    outliers <- as.numeric(unlist(stringr::str_split(outliers, pattern = " ")))
    outliers <- paste(outliers[order(outliers)], collapse = ", ")
  } else {
    outliers = "none"
  }
  outliers <- paste("* Outliers:", outliers)
  
  ## box ----
  
  edges <- gsub("[a-zA-Z:]", " ", txt[grepl("^which ", txt)])
  edges <- trimws(gsub(" +", " ", edges))
  edges <- as.numeric(unlist(stringr::str_split(edges, pattern = " ")))
  
  edge1 <- paste("* First quartile:", edges[1])
  edge3 <- paste("* Third quartile:", edges[2])
  
  median <- gsub("[a-zA-Z,]", " ", txt[grepl("median", txt)])
  median <- trimws(gsub(" +", " ", median))
  median <- as.numeric(unlist(stringr::str_split(median, pattern = " ")))[1]
  
  median <- paste("* Median:", median)
  
  # The whiskers extend to 2700 and 6300 from the ends of the box,
  # which are at 3550 and 4750
  # The median, 4050 is 42 % from the lower end of the box to the upper end.
  
  ## whiskers ----
  
  whiskers <- gsub("[a-zA-Z,]", " ", txt[grepl(" whiskers ", txt)])
  whiskers <- trimws(gsub(" +", " ", whiskers))
  whiskers <- as.numeric(unlist(stringr::str_split(whiskers, pattern = " ")))
  
  # ~ round(mean(d$raw) + c(-1, 1) * 2.5 * sd(d$raw))
  
  whisker1 <- paste("* Lower whisker end:", whiskers[1])
  whisker2 <- paste("* Upper whisker end:", whiskers[2])
  
  ## table ----
  desc <- paste(whisker1, edge1, median, edge3, whisker2, sep = "\n")
  return(desc)
}


braille_desc_box(var = pg$body_mass_g)
