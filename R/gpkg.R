#' function to import geopackages (.gpkg)
#' 
#' @export
#' @param filename name of the file
#' @param coords date time coordinate column name
#' @param tz chr, time zone
#' @return sf table
import_gpkg = function(filename,
                       coords = "date_time",
                       tz = "UTC"){
  x = sf::read_sf(filename) |>
    import_date_time(coords = coords,
                     tz = tz)
  return(x)
}