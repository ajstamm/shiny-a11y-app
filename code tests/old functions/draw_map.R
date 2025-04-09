#' Draw a county map
#' 
#' Draw a simple county map in Leaflet.
#' Designed to only work if "County" is the selected variable filter.
#' 
#' @param d    Dataset
#' @param year Year selected in user input
#' 
#' 
# test code:
# df <- readRDS("vs_app/data/birth_counts.Rds")
# p <- draw_map(df, 2022)

draw_map <- function(d, year) {
  layer <- tigris::counties(state = "MN") |>
    dplyr::select(NAME, STATEFP, COUNTYFP) |> 
    dplyr::mutate(county = tolower(NAME),
                  county = gsub("^st. ", "saint ", county)) 
  d <- d |> 
    dplyr::filter(Year == year, Variable == "County") |>
    dplyr::mutate(county = tolower(Category),
                  tooltip = paste(Topic, ":", Group, "\n", Variable, ":", 
                                  Category, "\n", Count))
  f <- dplyr::left_join(layer, d, by = "county")
  
  p <- leaflet::leaflet(f)
  # add base layer
  p <- leaflet::addProviderTiles(p, leaflet::providers$OpenTopoMap,
                                 options = leaflet::providerTileOptions(
                                   maxNativeZoom = 17, maxZoom = 20), 
                                 group = "Base Map (OSM)")
  # add indicator
  p <- leaflet::addPolygons(p, data = f$geometry, # color = cols$p_dis_bpov,
                            opacity = 0.7, fillOpacity = 0.4, weight = 1,
                            popup = paste("<b>County:</b>", f$Category, "<br>", 
                                          "<b>Number of births:</b>", f$Count, "<br>",
                                          "<b>Year:</b>", f$Year))
  return(p)
}

# d <- d |> dplyr::filter(year == 2022, var_1 == "County")
# p <- draw_map(d)
