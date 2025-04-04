#' Funciton to read GPX files
#' 
#' @export
#' @param filename filename(s) of GPX file
#' @param form output format (sf, tbl)
#' @param which one of (routes, tracks, waypoints)
#' @return either a tibble or sf object of a GPX object
read_gpx = function(filename = list.files(system.file("ex_data", package = "drifter"), full.names = TRUE), 
                    form = c("tibble", "sf")[1],
                    which = c("routes", "tracks", "waypoints")[2]){
  x = lapply(filename, function(fname){
    y = gpx::read_gpx(fname)[[which[1]]] 
    y = lapply(names(y), function(nm){
      y[[nm]] |>
        dplyr::as_tibble() |>
        dplyr::mutate(name = nm, .before = 1) 
    }) |>
      dplyr::bind_rows()
  }) |>
    dplyr::bind_rows()
  
  if (tolower(form[1]) == "sf") {
    x = sf::st_as_sf(x,
                     coords = c("Longitude", 
                                "Latitude"), 
                     crs = 4326)
  }
  
  return(x)
}
