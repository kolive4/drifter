#' Function to create a bounding box table
#' @export
#' @param name chr, abbreviated name of bb location
#' @param xmin num, min longitude
#' @param xmax num, max longitude
#' @param ymin num, min latitude
#' @param ymax num, max latitude
#' @param long_name chr, long name of bb location
#' @return bounding box table
get_bb_table = function(name = c("casco", "chcv", "stgeo", "mecoast"),
                        xmin = c(-70.288, -70.167931, -69.301235, -70.288),
                        xmax = c(-69.715072, -70.102219, -69.246169, -69.016407),
                        ymin = c(43.549256, 43.701498, 43.921795, 43.549256),
                        ymax = c(43.921978, 43.723947, 43.9558, 44.137128),
                        long_name = c("TBI-Casco Bay", "TBI-Chandler Cove", "TBI-St. George River", "ME coast to St. George")){
  dplyr::tibble(
    name = name,
    xmin = xmin,
    xmax = xmax,
    ymin = ymin,
    ymax = ymax,
    long_name = long_name
  )
}

#' Function that takes one element of the table and returns a bbox
#' 
#' @export
#' @param n name of bounding box
#' @return a bounding box object to be used with st_crop or other manipulations
get_bbox = function(n){
  x = get_bb_table() |>
    dplyr::filter(.data$name == n) |>
    dplyr::select(-dplyr::all_of(c("name", "long_name"))) |>
    unlist()

  x_sf = sf::st_sf(name = n,
                 geom = sf::st_sfc(cofbb::bb_as_POLYGON(x), crs = 4326))
  
  x_bbox = sf::st_bbox(x_sf)
  
  return(x_bbox)
}

