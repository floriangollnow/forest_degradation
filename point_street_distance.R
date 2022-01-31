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

# any_road type
point_to_road <- points %>% st_distance( roads_u, by_element = FALSE)
point_to_road <- apply(point_roads2, 1,min)
point_to_road.tb <- tibble(disRoads=point_roads)
point_to_road.tb
## highways and primary roads
primary <- roads_u %>% filter (highway== "motorway"|highway== "trunk"|highway== "primary"| highway== "primary_link")
point_to_primary <- points %>% st_distance( primary, by_element = FALSE)
point_to_primary <- apply(point_roads2, 1,min)
point_to_primary.tb <- tibble (disPrimaryRoad= point_to_primary)

## secondary roads
secondary <- roads_u %>% filter (highway== "secondary")
point_to_secondary <- points %>% st_distance( secondary, by_element = FALSE)
point_to_secondary <- apply(point_roads2, 1,min)
point_to_secondary.tb <- tibble (disPrimaryRoad= point_to_secondary)

point_data <- cbind (points, point_to_road.tb, point_to_primary.tb, point_to_secondary.tb)
point_data
write_rds (point_data, "/Users/floriangollnow/Dropbox/ZDC_project/FEDE/OSM_roads/results/point_road_dist_m.rds")
write_sf (point_data, "/Users/floriangollnow/Dropbox/ZDC_project/FEDE/OSM_roads/results/point_road_dist_m.geojson")

