library (tidyverse)
library (sf)
#library(geojsonsf)

dir_data <- "/Users/floriangollnow/Dropbox/ZDC_project/FEDE/Points"
dir_data<- "~/Data/Points"

points <- read_csv(file.path(dir_data, "coded_ancillary_1km_grid_prodes_year_10-13-2021_full.csv"))
points <- points %>% select(-c(`system:index`, `.geo`)) %>% rename(row=`...1`)
names(points)

points_sf <- points %>%
  st_as_sf(coords = c("x", "y"), crs=4326)

#points_sf<-geojson_sf(points$.geo)
#plot(points_sf)
#points_sf
#points_sf_data <- points_sf %>% bind_cols(points %>% select(-c(`system:index`, `.geo`, `...1`))) 
#points_sf_data

#points_sf_data %>% select(x,y)
write_rds (points_sf, file.path(dir_data, "points_data_sf.rds"))
write_rds (points_sf %>% select (row), file.path(dir_data, "points_row_sf.rds"))
