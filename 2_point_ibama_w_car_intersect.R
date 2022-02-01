# intersect embargoes aeas (embargoes_w_car.R) with points!

library (tidyverse)
library (sf)  
sf::sf_use_s2(FALSE)# otherwise geometry issues - and assuming planar LAT/LONG seems fine to me
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

point_emb_all <- point %>% left_join(point_emb %>% as_tibble() %>% select(-geometry), by="row")

write_rds(point_emb_all,file.path(dir_emb, "Point_car_embargoed_allY.rds"))
write_sf(point_emb_all, file.path(dir_emb, "Point_car_embargoed_allY.geojson"))
