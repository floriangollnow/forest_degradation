library (tidyverse)
library (sf)
library(geojsonsf)

dir_data <- "/Users/floriangollnow/Dropbox/ZDC_project/FEDE/Points"

points <- read_csv(file.path(dir_data, "coded_ancillary_1km_grid_prodes_year_10-13-2021_full.csv"))
points
names(points)

points_sf<-geojson_sf(points$.geo)
plot(points_sf)
points_sf
points_sf_data <- points_sf %>% bind_cols(points %>% select(-c(`system:index`, `.geo`, `...1`))) 
points_sf_data

points_sf_data %>% select(x,y)
write_rds (points_sf_data, file.path(dir_data, "points_sf.rds"))
