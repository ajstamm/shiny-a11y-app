# author: Abby Stamm
# date: August 2024
# purpose: functions for sample dashboard

bar_table <- function(df) {
  if (ncol(df) > 1) {
    df <- df |> dplyr::group_by(species, island) |>
      dplyr::summarize(count = dplyr::n(), .groups = "drop")
  } else {
    df <- data.frame(Message = paste("There are no valid penguins for these", 
                                     "filters. Please select different filters."))
  }
  return(df)
}

draw_bar <- function(df, input) {
  mypal <- input$chart_palette
  df <- bar_table(df) |>
    dplyr::mutate(species = gsub("\\(", "\n(", species), 
                  tip = paste("Species:", species, "\n", 
                              "Island:", island, "\n", 
                              "Count:", count))
  
  p <- ggplot2::ggplot(df, ggplot2::aes(x = factor(island), y = count,
                                        text = tip, fill = species,
                                        image = species)) +
    ggplot2::geom_bar(stat = "identity", color = input$bar_border,
                      position = ggplot2::position_dodge(
                                 preserve = "single")) +
    ggplot2::scale_fill_brewer(palette = mypal) +
    ggplot2::labs(x = "Island by species", y = "Count") +
    ggplot2::theme_minimal() + 
    ggplot2::theme(text = ggplot2::element_text(size=10), # all text
                   axis.text = ggplot2::element_text(size=10), # axis text
                   axis.title = ggplot2::element_text(size=12), # axis titles
                   plot.title = ggplot2::element_text(size=16), # plot title
                   legend.text = ggplot2::element_text(size=10), # legend text
                   legend.title = ggplot2::element_text(size=12)) # legend title 
  
  if (input$chart_label == "Yes") {
    p <- p + ggplot2::geom_text(ggplot2::aes(label = count, y = count + 2, 
                                             x = island), 
                                position = ggplot2::position_dodge(0.9)) 
  }

  return(p)
}

draw_textured_bar <- function(df, input) {
  # read images
  images <- c(Biscoe = "diaginal_forward_large_white", 
              Dream = "crosshatch_large_white",
              Torgersen = "diaginal_backward_large_white")
  ipath <- "textures/"
  # ipath <- "a11y/penguins/textures/"
  images <- paste0(ipath, images, ".png")
  mypal <- input$chart_palette
  
  # prep data
  df <- bar_table(df) |>
    dplyr::mutate(species = gsub("\\(", "\n(", species))

  # draw plot (plotly can't read textures)
  p <- ggplot2::ggplot(df, ggplot2::aes(x = factor(island), y = count,
                                        fill = species, image = species)) +
    ggtextures::geom_textured_bar(stat = "identity", color = input$bar_border,
                                  position = ggplot2::position_dodge(
                                             preserve = "single")) +
    ggtextures::scale_image_manual(values = images) +
    ggplot2::scale_fill_brewer(palette = mypal) +
    ggplot2::labs(x = "Species by island", y = "Count") +
    ggplot2::theme_minimal() + 
    ggplot2::theme(text = ggplot2::element_text(size=14), # all text
                   axis.text = ggplot2::element_text(size=14), # axis text
                   axis.title = ggplot2::element_text(size=18), # axis titles
                   plot.title = ggplot2::element_text(size=20), # plot title
                   legend.text = ggplot2::element_text(size=14), # legend text
                   legend.title = ggplot2::element_text(size=18)) # legend title 
  
  if (input$chart_label == "Yes") {
    p <- p + ggplot2::geom_text(ggplot2::aes(label = count, y = count + 2, 
                                             x = island), 
                                position = ggplot2::position_dodge(0.9)) 
  }
  
  return(p)
}
