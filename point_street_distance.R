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

points1_10 <- points %>% filter(row<=9)


point_roads <- points1_10 %>% st_distance( roads, by_element = TRUE) 
