#assentamientis

library(tidyverse)
library(sf)
sf_use_s2(FALSE)
library(lubridate)
library(nngeo)

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

assF_d <- assF_d %>% st_crop(st_bbox(point_row))
assF_d <- assF_d %>%  nngeo::st_remove_holes()
assF_d <- assF_d %>%  st_make_valid()

assR_d <- assR_d %>% st_crop(st_bbox(point_row))
assR_d <- assR_d %>%  nngeo::st_remove_holes()
assR_d <- assR_d %>%  st_make_valid()


#in 10 tiles
# assF
ind <- point_row %>% nrow()/10
for (i in 1:10){
  print(i)
  point_a <- point_row %>% filter (row >= ind*(i-1) & row< ind*i)
  point_assF <- point_a %>% st_intersection (assF_d)
  write_rds (point_assF, file.path (dir_as , paste0("processing/","point_assF_d",i,"_sf.rds")))
  assign(paste0("point_assF_d_",i), point_assF)
}
for (i in 1:10){
  if (i==1){
    point_assF_all <- read_rds (file.path(dir_as,paste0("processing/","point_assF_d",i,"_sf.rds") ))
  }else {
    tmp <- read_rds (file.path(dir_as,paste0("processing/","point_assF_d",i,"_sf.rds") ))
    point_assF_all <- rbind(point_assF_all, tmp)
  }
}
#assR
for (i in 1:10){
  print(i)
  point_a <- point_row %>% filter (row >= ind*(i-1) & row< ind*i)
  point_assR <- point_a %>% st_intersection (assR_d)
  write_rds (point_assR, file.path (dir_as , paste0("processing/","point_assR_d",i,"_sf.rds")))
  assign(paste0("point_assF_d_",i), point_assR)
}
for (i in 1:10){
  if (i==1){
    point_assR_all <- read_rds (file.path(dir_as,paste0("processing/","point_assR_d",i,"_sf.rds") ))
  }else {
    tmp <- read_rds (file.path(dir_as,paste0("processing/","point_assR_d",i,"_sf.rds") ))
    point_assR_all <- rbind(point_assR_all, tmp)
  }
}
point_assF <- point_assF %>% select(-data_de_cr)
point_assR <- point_assR %>% select(-data_de_cr)


point_row_result <- point_row %>% left_join(point_assF %>% as_tibble() %>% select(-geometry), by = 'row') %>% 
  left_join(point_assR %>% as_tibble() %>% select(-geometry), by = 'row')
write_rds (point_row_result , file.path(dir_as, "results/point_ass_intersect.rds"))
write_sf (point_row_result , file.path(dir_as, "results/point_ass_intersect.geojson"))
