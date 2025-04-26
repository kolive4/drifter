#' Function to match US tide stations to drift centroids
#' 
#' @export
#' @param x sf table of one (or more) drift track(s)
#' @param n number of closest stations to be returned
#' @param grouping_id if there are multiple tracks, which column defines the grouping variable
#' @return the maree tide station table, sorted from closest to furthest from average drift track lat/long
tide.find_closest_station = function(x = import_tracks(), n = 10, grouping_id = "Name"){
  if (!requireNamespace("maree")) {
    stop("Please install the maree package first")
  }
  tide_stations = maree::fetch_locations() |>
    sf::st_as_sf(coords = c("Longitude", "Latitude"), crs = 4326)
  
  y = x |>
    dplyr::group_by(.data[[grouping_id]]) |>
    dplyr::group_map(function(tbl, key){
      if(FALSE){
        tbl = dplyr::filter(x, Name == .data$Name[1])
      }
      centroid = tbl |>
        sf::st_union() |>
        sf::st_centroid()
      
      d = sf::st_distance(centroid, tide_stations, which = "Great Circle") |>
        as.numeric()
      
      id = order(d) |>
        head(n = n)
      
      id_tide = tide_stations |>
        dplyr::slice(id) |>
        dplyr::mutate(.Name = key$Name, .before = 1)
      
      return(id_tide)
    }) |>
    dplyr::bind_rows()
  
  return(y)
}
