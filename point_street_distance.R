#point_to street_distance

library(tidyverse)
library(sf)
sf_use_s2(FALSE) 

dir_data <- "/Users/floriangollnow/Dropbox/ZDC_project/FEDE/Points"

dir_osm <- "/Users/floriangollnow/Dropbox/ZDC_project/FEDE/OSM_roads/processing/"

points <- read_rds(file.path(dir_data, "points_row_sf.rds"))
roads <- read_rds(file.path (dir_osm, "PA_roads_all_tiles_u.rds"))
roads_u <- roads %>% 
  group_by(highway) %>%
  summarise(geometry = sf::st_union(geometry)) %>%
  ungroup()
roads_u
write_rds (roads_u, "/Users/floriangollnow/Dropbox/ZDC_project/FEDE/OSM_roads/results/PA_roads_all_tiles_u2_s2off.rds")

points1_10 <- points %>% filter(row<=2)

#https://gis.stackexchange.com/questions/225102/calculate-distance-between-points-and-nearest-polygon-in-r
# any_road type
timestamp()

point_to_road <- points %>% st_distance( roads_u, by_element = FALSE)
point_to_road.tb <- point_to_road %>% as_tibble()
names(point_to_road.tb) <- paste0("dist_",unique(roads_u$highway))
timestamp()

point_data <- cbind (points, point_to_road.tb)
point_data
write_rds (point_data, "/Users/floriangollnow/Dropbox/ZDC_project/FEDE/OSM_roads/results/point_road_dist_m.rds")
write_sf (point_data, "/Users/floriangollnow/Dropbox/ZDC_project/FEDE/OSM_roads/results/point_road_dist_m.geojson")

