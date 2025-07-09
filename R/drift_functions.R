#' Function for mapping the coastline
#' 
#' @export
#' @param coast coastline object from rnaturalearth
#' @param bb bounding box coordinates for cropping
#' @param ... arguments passable to geom_sf
#' @return x, ggplot layer

geom_coastline = function(coast = rnaturalearth::ne_coastline(scale = "small", returnclass = "sf"), bb = NULL, ...) {
  x = ggplot2::geom_sf(data = sf::st_crop(coast, bb), ggplot2::aes(), colour = "black")
  
  x
}

#' Function to convert gpx track to tibble for manipulation
#' 
#' @export
#' @param gpx gpx object
#' @return tibble version of gpx
gpx_to_tibble = function(gpx) {
  trax_tibble = gpx[[2]][[1]] |>
    tibble::as_tibble()
  trax_tibble
}

#' Function to convert the gpx track to an sf object for plotting
#' 
#' @export
#' @param trax_tibble gpx object as a tibble
#' @return sf object of gpx track
gpx_to_sf = function(trax_tibble) {
  trax_sf = trax_tibble |>
    sf::st_as_sf(coords = c("Longitude", 
                            "Latitude"), crs = 4326)
  trax_sf
}

# load_cc1 = function(){
#  sf::read_sf("/mnt/s1/projects/ecocast/projects/koliveira/gpx/cc1_drift_centroid.gpkg")
# }
# test_cc1 = function(x = load_cc1()){
#   ctr = trial_centroid(x)
#   xx = split(df, df$drifter) |>
#     lapply(function(x){
#       dplyr::arrange(x, Time) |>
#       dplyr::mutate(order = seq_len(dplyr::n()))
#     })
#   x = xx[[1]]
#   dx = sapply(seq(from = 2, to = nrow(x)),
#               function(i){
#                 sf::st_distance(dplyr::slice(x,i-1), dplyr::slice(x,i))
#               })
#   dctr = sapply(seq(from = 2, to = nrow(ctr)),
#                 function(i){
#                   sf::st_distance(dplyr::slice(ctr,i-1), dplyr::slice(ctr,i))
#                 })
# }
plot_track = function(x, cex = 0.5){
  plot(sf::st_geometry(x), axes = T, reset = F, type = "l")
  graphics::text(x, labels = x$order, cex = cex)
}



#' Function to find centroid of drifts
#' 
#' @export
#' @param df dataframe of gpx points of drifters for one trial
#' @return sf centroid linestring
trial_centroid = function(df = import_tracks()) {
  xx = split(df, df$drifter) |>
    lapply(function(x){
      dplyr::arrange(x, .data$Time)|>
        dplyr::mutate(order = seq_len(dplyr::n()), .before = 1)
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
    dplyr::group_map(function(tbl, key, b2, b3){
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
#' @export
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
#' @export
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
#' @export
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
#' @export
#' @param x centroid points df
#' @return distance between start and end points
centroid_distance = function(x){
  
 sapply(seq(from = 2, to = nrow(x)),
              function(i){
                sf::st_distance(dplyr::slice(x,i-1), dplyr::slice(x,i))
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
#' 
#' @export
#' @param x sf object, drifter track
#' @return leaflet map with drifter track
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



#' Function to calculate drift speed given a table of drifter points
#' 
#' @export
#' @param x tbl of drift data that has point locations and time
#' @return tbl of drift data but with a new column of calculated speed (m/s) and great circle distance
drift_speed = function(x) {
  if (FALSE) {
    x = tbl = tbi_1
  }
  x |>
    dplyr::group_by(.data$Name) |>
    dplyr::group_map(function(tbl, key){
      coords_start = sf::st_coordinates(dplyr::slice(tbl, -dplyr::n()))
      coords_end   = sf::st_coordinates(dplyr::slice(tbl, -1))
      # distance
      d = sf::st_distance(dplyr::slice(tbl, -1), dplyr::slice(tbl, -dplyr::n()), by_element = TRUE) |>
        as.vector()
      # elapsed time
      e_time = dplyr::slice(tbl, -1) |> dplyr::pull(.data$Time) |> as.numeric() - 
        dplyr::slice(tbl, -dplyr::n()) |> dplyr::pull(.data$Time) |> as.numeric() 
      #direction in degrees
      bearings = geosphere::bearing(coords_start, coords_end)
      
      tbl |>
        dplyr::slice(-dplyr::n()) |>
        dplyr::mutate(speed = d / e_time, 
                      distance = d,
                      direction = (bearings + 360) %% 360)
    }, .keep = TRUE) |>
    dplyr::bind_rows()
}

#' Function that given a GPX file of track points, will output the convex hull polygon of interest
#' 
#' @export
#' @param x sf, drift data
#' @param d num, buffer distance in meters around the track
#' @return sf, a convex hull polygon object
drift_area = function(x, d){
  if(FALSE){
    tbi_1 = import_gpx(filename = "/mnt/ecocast/projects/koliveira/subprojects/drifter/inst/ex_data/TBI_drifts/TBI_drifts_28_03_2025.GPX",
                       form = "sf") |>
      purrr::pluck("tracks") |>
      drift_speed()
    x = tbi_1
    d = 100
  }
  stats = x |>
    dplyr::summarise(
      avg_speed = mean(.data$speed, na.rm = TRUE),
      avg_direction = mean(.data$direction, na.rm = TRUE)
    ) |>
    sf::st_drop_geometry()
  
  sf::sf_use_s2(T)
  x_area = x |>
    sf::st_union() |>
    sf::st_buffer(dist = units::as_units(d, "m")) |>
    sf::st_convex_hull() |>
    sf::st_sf() |>
    dplyr::mutate(
      avg_speed = stats$avg_speed,
      avg_direction = stats$avg_direction
    )
  
  return(x_area)
}

#' Function that when given a polygon with an averaged speed and direction and a sinking rate, shows what depth kelp particles are at at a given distance within a polygon
#' 
#' @export
#' @param area sf polygon, area polygon of interest 
#' @param sink_rate num, rate of sinking in m/s
#' @param start_depth num, kelp planting depth in m
#' @param max_depth num, static depth in m
#' @param farms sf polygon, kelp farm
#' @return stars object with particle depths
particle_depth = function(area, sink_rate, start_depth, max_depth, farms){
  if (FALSE) {
    area = tbi_3_area
    sink_rate = 0.0005
    start_depth = 2
    max_depth = 13
    farms = farms |>
      dplyr::filter(stringr::str_starts(name, "STG"))
  }
  
  crs_proj = 32619
  area_proj = sf::st_transform(area, crs_proj)
  farms_proj = sf::st_transform(farms, crs_proj)
  
  grid_pts = sf::st_make_grid(area_proj, cellsize = 1, what = "centers") |>
    sf::st_sf() |>
    sf::st_intersection(area_proj)
  
  grid_pts$distance = sf::st_distance(grid_pts, farms_proj) |>
    apply(1, min)
  
  h_v = area$avg_speed # drift speed (m/s)
  
  grid_pts$depth = -pmin(grid_pts$distance / sqrt((h_v^2) + (sink_rate^2)) * sink_rate + start_depth, max_depth)
  
  depth_stars = stars::st_rasterize(grid_pts["depth"]) |>
    sf::st_crop(area_proj) |>
    stars::st_warp(crs = 4326)
  
  return(depth_stars)
}