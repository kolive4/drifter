#' Extract a track segments
#' 
#' @export
#' @param trkseg xmlnode_set of one or more "trkpt" elements
#' @return a character matrix with unnamed columns Longitude, Latitude, Elevation and Time
gpx.extract_trksegs = function(trkseg){
  r = xml2::xml_children(trkseg) |>
    lapply(
      function(trkpt){
        cc = xml2::xml_children(trkpt)
        c(xml2::xml_attrs(trkpt),
          xml2::xml_text(cc[[1]]),
          xml2::xml_text(cc[[2]]) ) |>
          unname()
      }
    )
  do.call(rbind, r)
}


#' Extract one or more tracks
#' 
#' @export
#' @param x xml_nodeset of one or more "trk" nodes
#' @return a table with Name, Longitude, Latitude, Elevation and Time
gpx.extract_tracks = function(x){
  r = lapply(x,
             function(trk){
               trk = xml2::xml_children(trk)
               nms = sapply(trk, xml2::xml_name)
               name = trk[nms == "name"] |> xml2::xml_text()
               trkseg = trk[nms == "trkseg"]
               r = gpx.extract_trksegs(trkseg)
               r = cbind(matrix(name, ncol = 1, nrow = nrow(r)),
                         r)
               r
             }) 
  r = do.call(rbind, r)
  colnames(r) = c("Name", "Latitude", "Longitude", "Elevation", "Time")
  dplyr::as_tibble(r)
}


#' Read a GPX file
#' 
#' This is inspired by the [gpx R package](https://cran.r-project.org/web/packages/gpx/index.html)
#' 
#' @export
#' @param filename chr the name of the file to read
#' @param form chr one of "table" or "sf"
#' @param crs when casting to "sf", use this crs
#' @return a 4 element list with filename, routes, tracks and waypoints
#'   One or more of the last three might be NULL.
import_gpx = function(filename = "cape_cod_complicated.GPX",
                    form = c("table", "sf")[2],
                    crs = 4326){
  xx = xml2::read_xml(filename) |>
    xml2::xml_children()
  
  nms = sapply(xx, xml2::xml_name)
  tracks = gpx.extract_tracks(xx[nms == "trk"]) |>
    dplyr::mutate(Time = lubridate::parse_date_time(.data$Time, 
                                                    c("YmdHMOS", "YmdHMS"), 
                                                    tz = "UTC"))
  #dplyr::mutate(Time = as.POSIXct(.data$Time, format = "%Y-%m-%dT%H:%M:%SZ", tz = "UTC"))
  if (tolower(form) == "sf") tracks = sf::st_as_sf(tracks,
                                                   coords = c("Longitude", "Latitude"),
                                                   crs = crs)
  
  list(filename = filename, 
       routes = NULL, 
       tracks = tracks,
       waypoints = NULL)
}