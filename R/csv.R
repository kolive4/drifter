#' Function to import CSV with tracks/point locations along a track
#' 
#' @export
#' @param filename name of file
#' @param crs coordinate reference system
#' @param coords names of coordinates and date_time columns
#' @param tz chr, time zone
#' @param ... who knows
#' @return a table or sf object
import_csv = function(filename, 
                      crs = 4326, 
                      coords = c("longitude", "latitude", "date_time"), 
                      tz = "UTC",
                      ...){
  x = readr::read_csv(filename, ...) |>
    sf::st_as_sf(coords = coords[1:2], crs = crs) |>
    import_date_time(coords = coords[3],
                     tz = tz)
  
  return(x)
}