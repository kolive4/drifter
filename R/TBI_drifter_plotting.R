suppressPackageStartupMessages({
  library(XML)
  library(gpx)
  library(sf)
  library(dplyr)
  library(mapview)
  library(lubridate)
  library(here)
  library(cofbb)
  library(ggplot2)
  library(tidyr)
  library(ggpubr)
  library(patchwork)
  library(maree)
  library(leaflet)
})

#' @param x tbl of drift data that has point locations and time
#' @return tbl of drift data but with a new column of calculated speed
drift_speed = function(x) {
  if (FALSE) {
    x = tbl = dplyr::filter(drift_sf, drifter == "white", trial == "1")
  }
  x |>
    dplyr::group_by(drifter, trial) |>
    dplyr::group_map(function(tbl, key){
      # distance
      d = sf::st_distance(dplyr::slice(tbl, -1), dplyr::slice(tbl, -dplyr::n()), by_element = TRUE) |>
        as.vector()
      # elapsed time
      e_time = dplyr::slice(tbl, -1) |> dplyr::pull(Time) |> as.numeric() - 
        dplyr::slice(tbl, -dplyr::n()) |> dplyr::pull(Time) |> as.numeric() 
      
      tbl |>
        dplyr::slice(-dplyr::n()) |>
        dplyr::mutate(speed = d / e_time, distance = d)
    }, .keep = TRUE) |>
    dplyr::bind_rows()
}

#gpx----

gpx_path = "/mnt/s1/projects/ecocast/projects/koliveira/subprojects/gpx/TBI_drifts"

cofbb::get_table()
gom = cofbb::get_bb("gom", form = "sf")

casco = c(-70.312, -69.837, 43.565, 43.911) |>
  cofbb::bb_as_POLYGON() |>
  st_sfc(crs = 4326)
casco = st_sf(name = "casco_bay", geometry = casco)

coast = rnaturalearth::ne_coastline(scale = "large", returnclass = "sf")

ggplot() +
  geom_coastline(coast, bb = casco)

white_1 = read_gpx(file.path(gpx_path, "white/TBI_white1.GPX"))
white_2 = read_gpx(file.path(gpx_path, "white/TBI_white2.GPX"))
red1_2 = read_gpx(file.path(gpx_path, "red1/TBI_red1.GPX"))
red2_2 = read_gpx(file.path(gpx_path, "red2/TBI_red2.GPX"))

white_1_tibble = gpx_to_tibble(white_1)
white_2_tibble = gpx_to_tibble(white_2)
red1_2_tibble = gpx_to_tibble(red1_2)
red2_2_tibble = gpx_to_tibble(red2_2)

all_drifter_tibble = dplyr::bind_rows(white_1_tibble, 
                                      white_2_tibble, 
                                      red1_2_tibble,
                                      red2_2_tibble, 
                                      .id = "id") |>
  mutate(id = replace(id, id == 1, "white_1")) |>
  mutate(id = replace(id, id == 2, "white_2")) |>
  mutate(id = replace(id, id == 3, "red1_2")) |>
  mutate(id = replace(id, id == 4, "red2_2")) |>
  separate(col = id, c("drifter", "trial"), remove = FALSE)
  
drift_sf = gpx_to_sf(all_drifter_tibble) |>
  drift_speed()

edna_drift = ggplot() +
  #geom_coastline(coast, bb = casco) +
  geom_sf(data = drift_sf |> filter(trial == "1"), aes(color = speed), size = 1) +
  #scale_color_manual(values = drift_colors) +
  #geom_sf_label(data = label_coords, aes(label = name, geometry = geometry), nudge_x = 0.1) +
  # geom_sf(data = subset(drift_edna_sf, !is.na(sample)), aes(shape = sample), fill = "black", color = "black", size = 1.5) +
  #coord_sf(xlim = c(-70.9, -69.6)) +
  #scale_x_continuous(breaks = seq(from = -70.9, to = -69.60, by = 0.4)) +
  labs(x = "", y = "") +
  theme_classic()
edna_drift

drift = ggplot() +
  #geom_coastline(coast, bb = casco) +
  geom_sf(data = drift_sf |> filter(trial == "2"), aes(color = speed), size = 1) +
  #scale_color_manual(values = drift_colors) +
  #geom_sf_label(data = label_coords, aes(label = name, geometry = geometry), nudge_x = 0.1) +
  # geom_sf(data = subset(drift_edna_sf, !is.na(sample)), aes(shape = sample), fill = "black", color = "black", size = 1.5) +
  #coord_sf(xlim = c(-70.9, -69.6)) +
  #scale_x_continuous(breaks = seq(from = -70.9, to = -69.60, by = 0.4)) +
  labs(x = "", y = "") +
  theme_classic()
drift

group_cols = c("drifter", "trial")

drift_centroid = drift_edna_sf |>
  group_by(across(all_of(group_cols))) |>
  dplyr::summarise(geometry = sf::st_centroid(st_union(geometry)))

sample_centroid = drift_edna_sf |>
  subset(!is.na(sample)) |>
  group_by(across(all_of(group_cols))) |>
  dplyr::summarise(geometry = sf::st_centroid(st_union(geometry)))


cc1_drifts = drift_edna_sf |>
  filter(trial == "cc1") 
cc1_edna = drift_edna_sf |>
  filter(trial == "cc1") |>
  filter(!is.na(sample))
cc1_centroid_points = sample_centroid |>
  filter(trial == "cc1")
cc1_centroid = trial_centroid(cc1_drifts) |>
  centroid_colors() |>
  centroid_sizes() |>
  centroid_labels()
cc1_dist = centroid_distance(cc1_centroid)

cc2_drifts = drift_edna_sf |>
  filter(trial == "cc2")
cc2_edna = drift_edna_sf |>
  filter(trial == "cc2") |>
  filter(!is.na(sample))
cc2_centroid_points = sample_centroid |>
  filter(trial == "cc2")
cc2_centroid = trial_centroid(cc2_drifts) |>
  centroid_colors() |>
  centroid_sizes() |>
  centroid_labels()
cc2_dist = centroid_distance(cc2_centroid)

cc3_drifts = drift_edna_sf |>
  filter(trial == "cc3")
cc3_edna = drift_edna_sf |>
  filter(trial == "cc3") |>
  filter(!is.na(sample))
cc3_centroid_points = sample_centroid |>
  filter(trial == "cc3")
cc3_centroid = trial_centroid(cc3_drifts) |>
  centroid_colors() |>
  centroid_sizes() |>
  centroid_labels()
cc3_dist = centroid_distance(cc3_centroid)

drift_colors = c("rd1" = "pink", "wd" = "grey", "rd2" = "aquamarine4")

cc1_drift_plot = ggplot() +
  geom_sf(data = subset(cc1_drifts, is.na(sample)), aes(color = "grey"), size = 0.5) + 
  # scale_color_manual(values = drift_colors) +
  geom_sf(data = cc1_centroid, aes(color = coloring, size = size)) +
  geom_sf_text(data = cc1_centroid, aes(label = label), nudge_x = -0.0015) +
  scale_color_identity() +
  scale_size_identity() +
  geom_sf(data = cc1_centroid_points, aes(shape = sample), fill = "navy", color = "navy", size = 2) +
  labs(shape = "Sample Time Point") +
  ggtitle("2021 Drifts") +
  theme_bw() +
  coord_sf(xlim = c(-69.895, -69.865)) +
  scale_x_continuous(breaks = seq(from = -69.89, to = -69.87, by = 0.01)) +
  xlab("") +
  ylab("") +
  theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust=1),
        plot.title.position = "plot", plot.title = element_text(hjust = 0.5)) +
  annotate("text", x = Inf, y = -Inf, label = "Distance: 2.37 km", hjust = 1, vjust = -1.5)
cc1_drift_plot

cc2_drift_plot = ggplot() +
  geom_sf(data = subset(cc2_drifts, is.na(sample)), aes(color = "grey"), size = 1) + 
  # scale_color_manual(values = drift_colors) +
  geom_sf(data = cc2_centroid, aes(color = coloring, size = size)) +
  geom_sf_text(data = cc2_centroid, aes(label = label), nudge_x = -0.001) +
  scale_color_identity() +
  scale_size_identity() +
  geom_sf(data = cc2_centroid_points, aes(shape = sample), fill = "navy", color = "navy", size = 2) +
  labs(shape = "Sample Time Point") +
  ggtitle("2022 Drifts") +
  theme_bw() +
  coord_sf(xlim = c(-69.945, -69.925)) +
  scale_x_continuous(breaks = seq(from = -69.945, to = -69.925, by = 0.005)) +
  scale_y_continuous(breaks = seq(from = 41.654, to = 41.672, by = 0.003)) +
  xlab("") +
  ylab("") +
  theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust=1),
        plot.title.position = "plot", plot.title = element_text(hjust = 0.6)) +
  annotate("text", x = Inf, y = -Inf, label = "Distance: 1.51 km", hjust = 1, vjust = -1.5)
cc2_drift_plot

cc3_drift_plot = ggplot() +
  geom_sf(data = subset(cc3_drifts, is.na(sample)), aes(color = "grey"), size = 1) + 
  # scale_color_manual(values = drift_colors) +
  geom_sf(data = cc3_centroid, aes(color = coloring, size = size)) +
  geom_sf_text(data = cc3_centroid, aes(label = label), nudge_x = -0.001) +
  scale_color_identity() +
  scale_size_identity() +
  geom_sf(data = cc3_centroid_points, aes(shape = sample), fill = "navy", color = "navy", size = 2) +
  labs(shape = "Sample Time Point") +
  ggtitle("2023 Drifts") +
  theme_bw() +
  scale_x_continuous(breaks = seq(from = -69.966, to = -69.950, by = 0.004)) +
  xlab("") +
  ylab("") +
  theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust=1),
        plot.title.position = "plot", plot.title = element_text(hjust = 0.3)) +
  annotate("text", x = Inf, y = -Inf, label = "Distance: 1.51 km", hjust = 1, vjust = -1.5)
cc3_drift_plot

label_coords = dplyr::tibble(name = c("2021", "2022", "2023"), 
                               Latitude = c(42.12, 41.7, 41.55), 
                               Longitude = c(-69.8, -69.85, -69.9)) |>
  st_as_sf(coords = c("Longitude", "Latitude"), crs = 4326)


  