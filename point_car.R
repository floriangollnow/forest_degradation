#in private property?

library(tidyverse)
library(sf)
library(rnaturalearth)
sf::sf_use_s2(FALSE) # issue with spehrical geometries of CAR data

point_dir <- 
car_data <- "~/shared_epl/public/ONGOING_RESEARCH/ZDCinBrazil/Deregulation_Covid/DATA/pa_br_car_2021"
dir_car <- "~/Data/car"
point_data <- "~/Data/Points"

point_row <- read_rds(file.path(point_data, "points_row_sf.rds"))
#MT
MT_car <- read_sf (file.path(car_data, "uf_MT/uf_MT.shp"))
MT_car <- MT_car %>% st_transform(crs = st_crs(point_row))
# filter properties
MT_car_p <- MT_car %>% filter (tipo_imove=="IRU")

#PA
PA_car <- read_sf (file.path(car_data, "uf_PA/uf_PA.shp"))
PA_car <- PA_car %>% st_transform(crs = st_crs(point_row))
PA_car_p <- PA_car %>% filter (tipo_imove=="IRU")
#RO
RO_car <- read_sf (file.path(car_data, "uf_RO/uf_RO.shp"))
RO_car <- RO_car %>% st_transform(crs = st_crs(point_row))
RO_car_p <- RO_car %>% filter (tipo_imove=="IRU")

#CAR - bind properties
CAR_p <- rbind(RO_car_p %>% select(), MT_car_p %>% select(), PA_car_p %>% select())

#MT_point_row <-  point_row %>%  st_crop (MT_box)
# intersect

#in 10 itterations again
ind <- point_row %>% nrow()/100
for (i in 1:100){
  timestamp()
  print(i)
  point_a <- point_row %>% filter (row >= ind*(i-1) & row< ind*i)
  if (i==1){
  point_car <- point_a %>% st_intersects (CAR_p, sparse = FALSE)# true false intersection
  point_car.tb <- tibble(CAR_iru= points_car[,1]) 
  }else {
    tmp <- point_a %>% st_intersects (CAR_p, sparse = FALSE)# true false intersection
    tmp.tb <- tibble(CAR_iru= tmp[,1]) 
    point_car.tb <-  point_car.tb %>% bind_rows(tmp.tb)
  }
  timestamp()
  }
  
point_car_sf <- point_row %>% bind_cols(points_car.tb)
write_rds (point_car_sf, file.path (dir_car , "point_car_sf.rds"))