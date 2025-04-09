#' Plot a map
#' 
#' @param df           Dataset
#' @param map_id       Filter value from the dataset "display_id" field 
#' @param geo_type     Geography to plot (County, ZIP code, school district)
#' @param plot_type    Plot type. Relevant values include "map" and 
#'                     "divergent-map" 
#' @param legend_title Title for the legend (If NULL, defaults to measure value)
#' @param color_var    Variable to use for choropleth groups, if defined (if 
#'                     NULL, the function creates it dynamically from breaks)
#' @param breaks       Category bin limits, if defined (if NULL, the function 
#'                     creates four natural jenks bins dynamically)
#' @param values       Numeric category to plot
#' @param geos         Map layer to display, if defined (If NULL, the function 
#'                     pulls from tigris or MNGeo based on geo_type)
#' @param diverge      Whole number between 0 and 100 representing the percent 
#'                     difference from the mean (Relevant only for divergent maps)
#' @param levels       Factor levels for categorical variables.
#' 
#'                
#' @examples
#' # example code
#' df <- read.csv("Restructured data/copd/full_data_hosp.csv")
#' draw_map(df = df, map_id = "Map 1", geo_type = "County")
#' draw_map(df = df, map_id = "Map 2", geo_type = "zip code")
#'                         
#' @export

# for hatched polygons
# devtools::install_github("statnmap/HatchedPolygons")
# https://rpubs.com/dieghernan/559092
# natural jenks
# classint & bammtools give the same results, bammtools much faster
# b <- classInt::classIntervals(df$value, n = 4, style = "jenks")$brks
# b <- BAMMtools::getJenksBreaks(df$value, 5, subset = NULL)

# add school map layer
# add divergent color scheme option in code and settings file
#     plot_type = "divergent-map" (use this function if type contains "map")


draw_map_points <- function(df, map_id, geo_type, plot_type = "map", diverge = 20,
                            legend_title = NULL, color_var = NULL, levels = NULL,
                            breaks = NULL, values = "value", geos = NULL,
                            overlay = FALSE) {
  # set up environment and filter data ----
  d <- df
  options(tigris_use_cache = TRUE)
  if (is.null(legend_title) | is.na(legend_title)) legend_title <- d$measure[1]
  geo_type <- tolower(geo_type)
        
  # load map layer if needed ----
  if (is.null(geos)) {
          if (geo_type == "county") {
            geos <- tigris::counties(state = "MN", year = 2020, cb = TRUE)
            geos <- dplyr::mutate(geos, geo_id = as.character(GEOID))
            geos <- dplyr::select(geos, geo_id, geo_names = NAMELSAD)
          } else if (geo_type == "census tract") {
            geos <- tigris::tracts(state = "MN", year = 2020, cb = TRUE)
            geos <- dplyr::mutate(geos, geo_id = as.character(GEOID),
                                  geo_names = geo_id)
            geos <- dplyr::select(geos, geo_id, geo_names)
          } else if (geo_type == "zip code") {
            geos <- tigris::zctas(year = 2020, cb = TRUE)
            geos <- dplyr::mutate(geos, geo_id = as.character(GEOID20),
                                  geo_names = geo_id)
            geos <- dplyr::select(geos, geo_id, geo_names)
            geos <- dplyr::filter(geos, geo_id %in% d$geo_id) 
          } else if (geo_type == "school district") {
            geos <- sf::st_read("data/school_districts/school_district_boundaries.shp", 
                                quiet = TRUE) 
            geos <- dplyr::mutate(geos, geo_id = as.character(FORMID),
                                  geo_names = SHORTNAME)
            geos <- dplyr::select(geos, geo_id, geo_names)
          } else if (geo_type == "school") {
            geos <- sf::st_read("data/schools/school_program_locations.shp") 
            geos <- dplyr::mutate(geos, geo_id = as.character(FORMID),
                                  geo_names = GISNAME)
            geos <- dplyr::select(geos, geo_id, geo_names)
          } else if (geo_type == "child care") {
            geos <- sf::st_read("data/child_care/econ_child_care.shp", quiet = TRUE) 
            geos <- dplyr::mutate(geos, geo_id = as.character(License_Nu),
                                  geo_names = Name_of_Pr)
            geos <- dplyr::select(geos, geo_id, geo_names)
          } else if (grepl("water system", tolower(geo_type))) {
            geos <- sf::st_read("data/CWS/water_systems.shp", quiet = TRUE) 
            geos <- dplyr::mutate(geos, geo_id = as.character(pws_id),
                                  geo_names = pws_name)
            geos <- dplyr::select(geos, geo_id, geo_names)
          }
        }
  geos <- sf::st_transform(geos, 4326)
        
  # prep data ----
        # may not work properly for school district - needs testing
        # for testing water: d$geo_id <- paste0("MN", d$geo_id)
  d <- dplyr::mutate(d, geo_id = as.character(geo_id))
  d <- dplyr::filter(d, grepl(map_id, display_id), geo_id %in% geos$geo_id)
        # move create_tooltip to after joins to include SES?
  d <- create_tooltip(d = d)
  d <- dplyr::mutate(d, tip = gsub("\\n", "<br>", tip), 
                     note = ifelse(is.na(note), "NA", note))
  d$my_values <- unlist(d[, values])

  # prep color_by ----
  if (is.null(color_var) | is.na(color_var)) {
    my_col <- NULL 
  } else {
    if (!color_var %in% names(d) | sum(is.na(d[, color_var])) > 0) {
        my_col <- NULL
    } else my_col <- color_var 
  }

  if (sum(!(d[, my_col] %in% c("", "NA")) | is.na(d[, my_col])) == 0 | 
      is.null(my_col)) {
    if (is.null(breaks) & plot_type == "map") {
      breaks <- BAMMtools::getJenksBreaks(d$my_values, 5, subset = NULL)[2:4]
    } else if (is.null(breaks)) {
      my_mean <- mean(d$my_values, na.rm = TRUE)
      d$pct_dif <- d$my_values/my_mean
      breaks <- c((100 - diverge) / 100, (100 + diverge) / 100, 
                  max(d$pct_dif, na.rm = TRUE))
    }
    if (length(breaks) == 2) {
      breaks <- c(breaks, max(d$my_values, na.rm = TRUE) + 1)
    }
    # create color scale if missing
    if (plot_type == "map") {
      d <- dplyr::mutate(d, geo_id = as.character(geo_id),
                         cats = ifelse(my_values < breaks[1], "cat 1", 
                                ifelse(my_values < breaks[2], "cat 2", 
                                ifelse(my_values < breaks[3], "cat 3", 
                                "cat 4"))))
            
    # create legend labels
    if (grepl("count|population|number", tolower(legend_title))) {
      leg_dig <- 0
    } else {
      leg_dig <- 1
    }
    if (grepl("percent", tolower(legend_title))) {
      leg_unit <- "%"
    } else {
      leg_unit <- ""
    }
            
    s <- dplyr::group_by(d, cats) 
    s <- dplyr::summarise(s, min = min(my_values, na.rm = TRUE), 
                          min_lbl = formatC(min, big.mark=",", 
                                            format = "f", digits = leg_dig),
                          min_lbl = paste0(min_lbl, leg_unit),
                          max = max(my_values, na.rm = TRUE),
                          max_lbl = formatC(max, big.mark=",", 
                                            format = "f", digits = leg_dig),
                          max_lbl = paste0(max_lbl, leg_unit))
    s <- dplyr::filter(s, !is.na(cats))
    # if measure is percent, add % tag?
    s <- dplyr::mutate(s, leg_label = paste(min_lbl, max_lbl, sep = " - "))
    s <- dplyr::mutate(s, leg_fact = factor(leg_label, levels = s$leg_label))
    d <- dplyr::full_join(d, s, by = "cats")
    d <- dplyr::mutate(d, color_by = leg_label)
  } else {
      my_mean <- mean(d$my_values, na.rm = TRUE)
      legend_labels <- c(paste0(diverge, "% or more below mean of"), 
                         paste0("Within ", diverge, "% of mean of"),
                         paste0(diverge, "% or more above mean of"))
      legend_labels <- paste(legend_labels, round(my_mean, digits = 1))
      d$pct_dif <- d$my_values / my_mean
      d <- dplyr::mutate(d, 
                  leg_label = ifelse(pct_dif < breaks[1], legend_labels[1],
                              ifelse(pct_dif < breaks[2], legend_labels[2],
                                     legend_labels[3])),
                  leg_fact = factor(leg_label, levels = legend_labels), 
                  color_by = leg_label)
    }
  } else {
    d$color_by <- unlist(d[, my_col])
    if (!is.null(levels)) {
      if (!is.na(levels)) {
        lvl <- unlist(stringr::str_split(levels, pattern = "; "))
        d <- dplyr::mutate(d, leg_fact = factor(color_by, levels = lvl))
      }
    }
  }
  if (!suppressWarnings(is.null(d$leg_fact))) {
    legend_labels <- unique(d$leg_fact[order(d$leg_fact)])
  } else {
    legend_labels <- factor(unique(d$color_by))
  }
  d <- dplyr::arrange(d, color_by, geo_id)
  t <- length(legend_labels)
        
  # create color palette ----
  if (plot_type == "map") {
    colors <- RColorBrewer::brewer.pal(n = t * 2, name = "Blues")
    if (length(colors) > 3) colors <- c(colors, "#011655")
    colors <- colors[seq(from = 2, to = length(colors), by = 2)]
    names(colors) <- legend_labels
  } else {
    colors <- RColorBrewer::brewer.pal(n = 3, name = "RdYlBu")
    names(colors) <- levels(legend_labels)
  }
        
  if (sum(grepl("suppressed", tolower(d$note))) > 0) {
    d <- dplyr::mutate(d, 
      color_by = ifelse(grepl("suppressed", tolower(note)), 
                        "Data suppressed", color_by))
      colors <- c(colors, `Data suppressed` = "grey")
      levels(legend_labels) <- c(levels(legend_labels), "Data suppressed")
  }
  if (sum(grepl("no data|data not", tolower(d$note))) > 0 | 
      sum(is.na(d$color_by)) > 0) {
    d <- dplyr::mutate(d, color_by = ifelse(!is.na(color_by), color_by,
                                            "No data available"))
    colors <- c(colors, `No data available` = "white")
    levels(legend_labels) <- c(levels(legend_labels), "No data available")
  }
        
  if (is.numeric(d$color_by)) {
    d <- dplyr::mutate(d, bin = color_by)
  } else {
    d <- dplyr::mutate(d, bin = factor(color_by, levels = levels(legend_labels)))
  }
        
  # assign color palettes ----
  border_color <- "grey"
  pal <- leaflet::colorNumeric(palette = colors, na.color = "darkgrey", 
                               domain = as.numeric(d$bin))
  # create map data ----
  g <- dplyr::right_join(geos, d, by = "geo_id")
  g <- dplyr::mutate(g, geo_name = ifelse(is.na(geo_name) | geo_name == "", 
                                          geo_names, geo_name))
        
  # add overlay layers ----
  # want the overlay by geography so ecologic and topic data can be joined
  # if (d$topic[1] %in% c("Childhood lead exposure")) {
  if (overlay & geo_type == "county") {
    s <- readr::read_csv("data/lead_risk_factors_county.csv") |>
      dplyr::select(geo_id, dplyr::contains(" ")) |>
      dplyr::mutate(geo_id = as.character(geo_id))
    ns <- names(s)
          
    g <- dplyr::left_join(g, s, by = "geo_id") # }
  }

  # draw leaflet map ----
  m <- leaflet::leaflet(g)
        # options = leaflet::leafletOptions( # zoomControl = FALSE,
        #                                   minZoom = 5, maxZoom = 10)
  m <- leaflet::addProviderTiles(m, 
                leaflet::providers$CartoDB.PositronNoLabels,
                options = leaflet::providerTileOptions(opacity = 0.95)) 
  m <- leaflet::addProviderTiles(m, 
                leaflet::providers$CartoDB.Voyager,
                options = leaflet::providerTileOptions(opacity = 0.55))
  m <- leaflet::addProviderTiles(m, 
                leaflet::providers$CartoDB.PositronOnlyLabels,
                options = leaflet::providerTileOptions(opacity = 0.85))
  
  # add data to map ----
  x <- sf::st_geometry_type(geos)
  if (sum(grepl("POINT", x)) > 0) {
    if (length(x) > 1000) {
      m <- leaflet::addCircleMarkers(m, data = g, stroke = TRUE, radius = 5,
                    fillColor = ~pal(as.numeric(bin)), fillOpacity = 1, weight = 1, 
                    color = "black", label = ~lapply(tip, htmltools::HTML),
                    clusterOptions = leaflet::markerClusterOptions())
    } else {
      l <- list()
      for (i in 1:length(legend_labels)) {
        t <- dplyr::filter(g, color_by == legend_labels[i])
        m <- leaflet::addCircleMarkers(m, data = t, stroke = TRUE, radius = 5,
                      fillColor = ~pal(as.numeric(bin)), fillOpacity = 1, weight = 1,
                      color = "black", label = ~lapply(tip, htmltools::HTML))
      }
    }
  } else {
    m <- leaflet::addPolygons(m, data = g, color = border_color, opacity = 0.4, 
                  label = ~lapply(tip, htmltools::HTML), smoothFactor = 0.5, 
                  weight = ifelse(geo_type == "county", 1.2, 1),
                  fillColor = ~pal(as.numeric(bin)), fillOpacity = 0.75)
  }
        
  # add overlays to map ----
  # d$topic[1] %in% c("Childhood lead exposure")
  if (overlay & geo_type == "county") {
    angles <- c(45, 135, 22.5, 112.5, 67.5, 157.5, 0, 90)
    for (i in 2:length(ns)) {
      t <- dplyr::filter(g, !!dplyr::sym(ns[i]))
      h <- HatchedPolygons::hatched.SpatialPolygons(t, density = 6, 
                                                    angle = angles[i - 1]) 
      m <- leaflet::addPolylines(m, data = h, color = "black", 
                                 weight = 1, group = ns[i])
      m <- leaflet::addPolygons(m, data = h, fill = NA, 
                                color = "black", weight = 1, group = ns[i])
      m <- leaflet::addLayersControl(m, overlayGroups = ns[2:length(ns)],
                    options = leaflet::layersControlOptions(collapsed = FALSE))
    }
  }
      
  # add legend ----
  my_title <- paste('<span style="color: #5d5d5d;", 
                    "font-size: 100%;">{legend_title}</span>')
  # map is misassigning levels and colors, again
  # legend is correct, but data are not 
  # - factors off in raw data? - adds a darker grey?
  colors <- colors[!is.na(names(colors))]
  if (sum(grepl("POINT", x)) > 0) {
          m <- leaflegend::addLegendSymbol(m, position = "topleft", 
                           title = legend_title, width = 10,
                           values = d$color_by, # labels = names(colors), 
                           shape = rep("circle", length(colors)), 
                           color = "black", fillColor = colors)
        } else {
    m <- leaflet::addLegend(m, title = glue::glue(my_title), 
                  position = "topleft", colors = colors, opacity = 0.81,
                  labels = levels(legend_labels))
  }
  # use leaflegend and png files to create hatched legend items?

  # add map functionality ----
  m <- leaflet.extras::addSearchOSM(m, 
       options = leaflet.extras::searchOptions(position = "topright")) 
  m <- leaflet.extras::addControlGPS(m,
       options = leaflet.extras::gpsOptions(position = "topright", 
                                 maxZoom = 11, activate = FALSE, 
                                 autoCenter = TRUE, setView = TRUE))
  # return ----
  return(m)
}

