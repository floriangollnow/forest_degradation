# intersect embargoes aeas (embargoes_w_car.R) with points!

library (tidyverse)
library (sf)  
library(lubridate)

dir_data <- "~/Data/Points"
dir_emb <- "~/Data/embargoes/result"

point <- read_rds(file.path(dir_data, "points_row_sf.rds"))
embargoes <- read_rds(file.path(dir_emb, "Car_embargoed_all_data.rds"))
names(embargoes)

#keep
#DAT_EMBARGO
#DAT_DESEMBARGO
embargoes_date <- embargoes %>% select(DAT_EMBARGO, DAT_DESEMBARGO) %>%  mutate(embargoStartY = year(dmy_hms(DAT_EMBARGO)) ,
         embargoEndY = year(dmy_hms(DAT_DESEMBARGO))) 

point_emb <- point %>%  st_intersection(embargoes_date)
write_rds(file.path(point_emb, "Point_car_embargoed_allY.rds"))
write_sf(file.path(point_emb, "Point_car_embargoed_allY.geojson"))