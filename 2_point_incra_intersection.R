#assentamientis

library(tidyverse)
library(sf)
library(lubridate)

dir_as <- "/Users/floriangollnow/Dropbox/ZDC_project/FEDE/assentamiento"
dir_p <- "/Users/floriangollnow/Dropbox/ZDC_project/FEDE/Points"

assF <- read_sf (file.path(dir_as, "Assentamento Federal/Assentamento Federal.shp"))
assF %>% names()
assF_d <- assF %>% select(data_de_cr) %>% mutate(AssFederalY = year(dmy(data_de_cr)))

assR <- read_sf (file.path(dir_as, "Assentamento Reconhecimento/Assentamento Reconhecimento.shp"))
assR %>% names()
assR_d <- assR %>% select(data_de_cr) %>% mutate(AssReconhecimentoY = year(dmy(data_de_cr)))

point_row <- read_rds (file.path(dir_p, "points_row_sf.rds"))

#intersect
assF_d <- assF_d %>% st_transform(crs=st_crs(point_row))
assR_d <- assR_d %>% st_transform(crs=st_crs(point_row))
point_assF <- point_row %>% st_intersection (assF_d)
point_assR <- point_row %>% st_intersection (assR_d)

point_row_result <- point_row %>% left_join(point_assF, by = 'row') %>% left_join(point_assR, by = 'row')
write_rds (point_row_results , file.path(dir_as, "results/point_ass_intersect.rds"))
write_sf (point_row_results , file.path(dir_as, "results/point_ass_intersect.geojson"))
