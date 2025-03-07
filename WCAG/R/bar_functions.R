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
  # names(df) <- tools::toTitleCase(gsub("_", " ", names(df)))
  return(df)
}

draw_bar <- function(df, input) {
  mypal <- input$chart_palette
  df <- bar_table(df) |>
    dplyr::mutate(species = gsub("\\(", "\n(", species), 
                  tip = paste("<b>Species:</b>", as.character(species), 
                              "<br><b>Island:</b>", as.character(island), 
                              "<br><b>Count</b>:", count))
  # alt text for the chart ----
  alt_text <- paste("Bar chart of number of penguins of each species on each",
                    "island. For species and counts, check the table below.")
  # draw chart ----
  p <- ggplot2::ggplot(df, ggplot2::aes(x = factor(island), y = count,
                                        text = tip, fill = species,
                                        image = species)) +
    ggiraph::geom_bar_interactive(ggplot2::aes(tooltip = tip),
                                  stat = "identity", color = input$bar_border,
                                  position = ggplot2::position_dodge(
                                             preserve = "single"))
  # conditional: if relevant add textures ----
  if (!input$bar_fill == 'Plain') {
    images <- paste0("textures/", c("x", "diamond", "ringoffset"), "_white.png")
    p <- p +
      ggtextures::geom_textured_bar(stat = "identity", color = input$bar_border,
                                    position = ggplot2::position_dodge(
                                               preserve = "single")) +
      ggtextures::scale_image_manual(values = images) 
  }
  # theme ----
  p <- p +
    ggplot2::theme_minimal() + 
    ggplot2::scale_fill_brewer(palette = mypal) +
    ggplot2::labs(x = "Island by species", y = "Count", alt = alt_text) +
    ggplot2::theme(text = ggplot2::element_text(size=10), # all text
                   axis.text = ggplot2::element_text(size=10), # axis text
                   axis.title = ggplot2::element_text(size=12), # axis titles
                   plot.title = ggplot2::element_text(size=16), # plot title
                   legend.text = ggplot2::element_text(size=10), # legend text
                   legend.title = ggplot2::element_text(size=12)) # legend title 
  # add label if required
  if (input$chart_label == "Yes") {
    p <- p + ggplot2::geom_text(ggplot2::aes(label = count, y = count + 2, 
                                             x = island), 
                                position = ggplot2::position_dodge(0.9)) 
  }

  
  return(p)
}

draw_textured_bar <- function(df, input) {
  mypal <- input$chart_palette
  # read images
  images <- paste0("textures/", c("x", "diamond", "ringoffset"), "_white.png")
  # draw plot (plotly can't read textures)
  p <- ggplot2::ggplot(df, ggplot2::aes(x = factor(island), y = count,
                                        fill = species, image = species)) +
    ggiraph::geom_bar_interactive(ggplot2::aes(tooltip = tip), fill = NA,
                                  stat = "identity", color = input$bar_border, 
                                  position = ggplot2::position_dodge(
                                             preserve = "single")) +
    ggtextures::geom_textured_bar(stat = "identity", color = input$bar_border,
                                  position = ggplot2::position_dodge(
                                             preserve = "single")) +
    ggtextures::scale_image_manual(values = images) +
    ggplot2::theme_minimal() + 
    ggplot2::scale_fill_brewer(palette = mypal) +
    ggplot2::labs(x = "Species by island", y = "Count") +
    ggplot2::theme(text = ggplot2::element_text(size=10), # all text
                   axis.text = ggplot2::element_text(size=10), # axis text
                   axis.title = ggplot2::element_text(size=12), # axis titles
                   plot.title = ggplot2::element_text(size=14), # plot title
                   legend.text = ggplot2::element_text(size=10), # legend text
                   legend.title = ggplot2::element_text(size=12)) # legend title 
  return(p)
}
