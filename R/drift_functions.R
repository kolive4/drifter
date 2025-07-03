#' Function for mapping
#' 
#' @param data coastline object from rnaturalearth
#' @param bb bounding box coordinates for cropping
#' @param ... arguments passable to geom_sf
#' @return x, ggplot layer

geom_coastline = function(coast = rnaturalearth::ne_coastline(scale = "small", returnclass = "sf"), bb = NULL, ...) {
  x = ggplot2::geom_sf(data = sf::st_crop(coast, bb), aes(), colour = "black")
  
  x
}

#' Function to convert gpx track to tibble for manipulation
#' @param gpx gpx object
#' 
#' @return tibble version of gpx
gpx_to_tibble = function(gpx) {
  trax_tibble = gpx[[2]][[1]] |>
    as_tibble()
  trax_tibble
}

#' Function to convert the gpx track to an sf object for plotting
#' @param trax_tibble gpx object as a tibble
#' 
#' @return sf object of gpx track
gpx_to_sf = function(trax_tibble) {
  trax_sf = trax_tibble |>
    sf::st_as_sf(coords = c("Longitude", 
                            "Latitude"), crs = 4326)
  trax_sf
}



load_cc1 = function(){
 read_sf("/mnt/s1/projects/ecocast/projects/koliveira/gpx/cc1_drift_centroid.gpkg")
}

test_cc1 = function(x = load_cc1()){
  ctr = trial_centroid(x)
  xx = split(df, df$drifter) |>
    lapply(function(x){
      dplyr::arrange(x, Time) |>
      dplyr::mutate(order = seq_len(n()))
    })

  x = xx[[1]]
  
  

  dx = sapply(seq(from = 2, to = nrow(x)),
              function(i){
                sf::st_distance(slice(x,i-1), slice(x,i))
              })
  dctr = sapply(seq(from = 2, to = nrow(ctr)),
                function(i){
                  sf::st_distance(slice(ctr,i-1), slice(ctr,i))
                })
  
  
  
}

plot_track = function(x, cex = 0.5){
  plot(st_geometry(x), axes = T, reset = F, type = "l")
  text(x, labels = x$order, cex = cex)
}



#' function to find centroid of drifts
#' 
#' @param df dataframe of gpx points of drifters for one trial
#' @return sf centroid linestring
trial_centroid = function(df = load_cc1()) {
  xx = split(df, df$drifter) |>
    lapply(function(x){
      dplyr::arrange(x, Time)|>
        dplyr::mutate(order = seq_len(n()), .before = 1)
    })
  min_t = sapply(xx, function(x){
    min(x$Time)
  }) |>
    sort(decreasing = TRUE)
  
  xx = xx[names(min_t)]
  
  #find the closest time between t1 and a vector of t2
  closest_time = function(t1, t2){
    which.min(abs(t1 - t2))
  }
  
  x = xx[[1]] |>
    dplyr::rowwise() |>
    group_map(function(tbl, key, b2, b3){
      ib2 = closest_time(tbl$Time, b2$Time)
      ib3 = closest_time(tbl$Time, b3$Time)
      
      center_point = dplyr::bind_rows(tbl, dplyr::slice(b2, ib2), dplyr::slice(b3, ib3)) |>
        sf::st_as_sfc() |>
        sf::st_union() |>
        sf::st_centroid()
      
      sf::st_geometry(tbl) <- sf::st_geometry(center_point)
      
      tbl$drifter = "centroid"
      
      return(tbl)
    }, b2 = xx[[2]], b3 = xx[[3]]) |>
    dplyr::bind_rows()
  
}


#' Function to assign colors to centroid points
#' 
#' @param x centroid points sf object
#' @return centroid points sf object with colors
centroid_colors = function(x){
  x$coloring = "darkorange"
  x$coloring[1] = "green3"
  x$coloring[nrow(x)] = "red"
  
  return(x)
}

#' Function to assign a size to centroid points
#' 
#' @param x centroid points sf object
#' @return centroid points sf object with point sizes
centroid_sizes = function(x){
  x$size = 0.5
  x$size[1] = 3
  x$size[nrow(x)] = 3
  
  return(x)
}

#' Function to add an A and B label to first and last point of centroid line
#' 
#' @param x centroid points sf object
#' @return centroid points sf object with A and B label on first and last points
centroid_labels = function(x){
  x$label = ""
  x$label[1] = "A"
  x$label[nrow(x)] = "B"
  
  return(x)
}

#' Function to calculate distance between start and end points
#' 
#' @param x centroid points df
#' @return distance between start and end points
centroid_distance = function(x){
  
 sapply(seq(from = 2, to = nrow(x)),
              function(i){
                sf::st_distance(slice(x,i-1), slice(x,i))
              }) |>
    sum()
  
  
  #x = cc1_centroid
 # dist = sf::st_union(x) |>
 #   sf::st_cast("LINESTRING") |>
 #   st_length()
 # return(dist)
  
  #a = x$geometry[1]
  #b = x$geometry[nrow(x)]
  #
  #dist_km = sf::st_distance(a, b)/1000
  #
  #return(dist_km)
}


#' Draw a drifter as a leaflet polyline
leaflet_drifter = function(x){
  y = sf::st_union(x) |>
    sf::st_cast("LINESTRING")
  leaflet::leaflet(data = y) |>
    leaflet::addTiles() |>
    leaflet::addScaleBar() |>
    leaflet::addPolylines(color = "orange")
    #leaflet::addCircleMarkers(data = x) |>
    #leaflet::addPopups(data = x, popup = htmltools::htmlEscape(x$order))
}
