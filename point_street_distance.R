#point_to street_distance

library(tidyverse)
library(sf)
sf_use_s2(FALSE) 

#dir_data <- "/Users/floriangollnow/Dropbox/ZDC_project/FEDE/Points"
dir_data<- "~/Data/Points"
#dir_osm <- "/Users/floriangollnow/Dropbox/ZDC_project/FEDE/OSM_roads/processing/"
dir_osm <- "~/Data/OSM_roads/results/"

point_row <- read_rds(file.path(dir_data, "points_row_sf.rds"))
roads <- read_rds(file.path (dir_osm, "PA_roads_all_tiles_u_s2FALSE.rds"))

roads <- roads %>% filter (highway!="primary_link")# don't know why this is in there

timestamp()

point_row <- point_row %>% mutate (group= rep(1:1001, each=nrow(point_row)/1000, length.out=nrow(point_row) ))

for (i in 1:1001){
  timestamp()
  print(i)
  point_a <- point_row %>% filter (group ==i)
  if (i==1){
    point_to_road <- point_a %>% st_distance( roads, by_element = FALSE)
    point_to_road.tb <- point_to_road %>% as_tibble()
    names(point_to_road.tb) <- paste0("dist_",unique(roads_u$highway))
    print (point_to_road.tb)
  }else {
    tmp <- point_a %>% st_distance( roads, by_element = FALSE)
    tmp.tb <- tmp %>% as_tibble()
    names(tmp.tb) <- paste0("dist_",unique(roads$highway))
    point_to_road.tb  <-  point_to_road.tb  %>% bind_rows(tmp.tb)
  }
  timestamp()
}



# point_to_road <- points %>% st_distance( roads, by_element = FALSE)
# point_to_road.tb <- point_to_road %>% as_tibble()
# names(point_to_road.tb) <- paste0("dist_",unique(roads_u$highway))
# timestamp()

point_data <- cbind (point_row, point_to_road.tb)
point_data
write_rds (point_data, file.path (dir_osm, "point_road_dist_m.rds"))
write_sf (point_data, file.path(dir_osm,"point_road_dist_m.geojson"))

