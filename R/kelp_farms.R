kelp_farms_coords <- list(
  "STG_DC2x" = matrix(c(
    -69.276050, 43.943291,
    -69.276179, 43.942862,
    -69.272413, 43.942128,
    -69.272215, 43.942546,
    -69.276050, 43.943291
  ), ncol = 2, byrow = TRUE),
  
  "STG_DC3x" = matrix(c(
    -69.276517,43.942627, 
    -69.276667,43.942210, 
    -69.272837,43.941414, 
    -69.272665, 43.941808,
    -69.276517,43.942627
    ), ncol = 2, byrow = TRUE),
  
  "CAS_CHAN" = matrix(c(
    -70.140147, 43.713738,  
    -70.139117, 43.713474,  
    -70.136328, 43.715847,  
    -70.137315, 43.716126,  
    -70.140147, 43.713738   
  ), ncol = 2, byrow = TRUE),
  
  "CAS_ELC" = matrix(c(
    -70.143709, 43.711427,  
    -70.143216, 43.711210,  
    -70.141263, 43.713862,  
    -70.141757, 43.714079,  
    -70.143709, 43.711427   
  ), ncol = 2, byrow = TRUE),
  
  "CAS_CHEB2" = matrix(c(
    -70.149138, 43.720360,  
    -70.148752, 43.720159,  
    -70.146198, 43.722547,  
    -70.146542, 43.722748,  
    -70.149138, 43.720360   
  ), ncol = 2, byrow = TRUE)
)

#' Function to create polygons out of the kelp farm coords above
#' @param x list of kelp farms and their coordinates
#' @param crs coordinate reference system
#' @return list of kelp farm polygons
create_kelp_farm_polygons <- function(kelp_farms_coords, crs = 4326) {
  farm_polygons <- lapply(names(kelp_farms_coords), function(farm_name) {
    coords <- kelp_farms_coords[[farm_name]]
    polygon <- st_polygon(list(coords))
    st_sf(
      name = farm_name,
      geometry = st_sfc(polygon, crs = crs)
    )
  })
  
  do.call(rbind, farm_polygons)
}
