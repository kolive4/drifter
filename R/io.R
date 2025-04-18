# #' Funciton to read GPX files
# #' 
# #' @export
# #' @param filename filename(s) of GPX file
# #' @param form output format (sf, tbl)
# #' @param which one of (routes, tracks, waypoints)
# #' @return either a tibble or sf object of a GPX object
# read_gpx1 = function(filename = list.files(system.file("ex_data", package = "drifter"), full# .names = TRUE), 
#                     form = c("tibble", "sf")[1],
#                     which = c("routes", "tracks", "waypoints")[2]){
#   x = lapply(filename, function(fname){
#     y = gpx::read_gpx(fname)[[which[1]]] 
#     y = lapply(names(y), function(nm){
#       y[[nm]] |>
#         dplyr::as_tibble() |>
#         dplyr::mutate(name = nm, .before = 1) 
#     }) |>
#       dplyr::bind_rows()
#   }) |>
#     dplyr::bind_rows()
#   
#   if (tolower(form[1]) == "sf") {
#     x = sf::st_as_sf(x,
#                      coords = c("Longitude", 
#                                 "Latitude"), 
#                      crs = 4326)
#   }
#   
#   return(x)
# }

#' Function to determine the filetype given a filename
#' 
#' @export
#' @param filename name of the file
#' @return chr
detect_filetype = function(filename){
  r = if (grepl("^.*\\.gpx$", filename[1])) {
    "gpx"
  } else if (grepl("^.*\\.csv$", filename[1])) {
    "csv"
  } else if (grepl("^.*\\.gpkg$", filename[1])) {
    "gpkg"
  } else {
    stop("Filetype not detected: ", filename[1])
  }
  return(r)
}

#' Import any track object as an sf object
#' 
#' @param filename name of track file
#' @param type chr, declares what the data format is (gpx, csv, ...)
#' @param ... additional params to import_*
import_tracks = function(filename, type = detect_filetype(filename), ...){
  x = switch(type, 
             "gpx" = import_gpx(filename, ...)[["tracks"]],
             "csv" = import_csv(filename, ...),
             "gpkg" = sf::read_sf(filename, ...),
             stop("Filetype not supported", filename[1]))
  return(x)
}


#' function to deal with time column formatting
#' 
#' @param x sf table
#' @param coords date_time coordinate column name
#' @param tz time zone
#' @return updated table if error not thrown, with a date_time_ column
import_date_time = function(x, coords, tz = "UTC"){
  if (!coords[1] %in% colnames(x)) {
    stop("Coordinates not found in data object", coords[1])
  }
  x = x |>
    dplyr::mutate(date_time_ = lubridate::ymd_hms(.data[[coords[1]]],
                                                  tz = tz))
}

