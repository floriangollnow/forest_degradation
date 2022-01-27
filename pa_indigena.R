library (tidyverse)
library (sf)  
library(nngeo)


dir_data <- "~/Data/Points"

dir_terr <- "~/Data/protected and Indigena/"


pa <- read_sf (file.path(dir_terr, "pa/UC_Fed_Atualizado_novembro_2020/UC_Fed_nov_2020.shp"))
indMT <- read_sf (file.path(dir_terr, "/indigena/ti_sirgas(MT)/ti_sirgas.shp"))
indPA <- read_sf (file.path(dir_terr, "/indigena/ti_sirgas(PA)/ti_sirgas.shp"))
indRO <- read_sf (file.path(dir_terr, "/indigena/ti_sirgas(RO)/ti_sirgas.shp"))
ind <- rbind(indMT, indPA, indRO)
#plot(ind)


# points 
point <- read_rds(file.path(dir_data, "points_row_sf.rds"))

#repair
pa <- pa %>% st_transform(crs=4326)
pa <- pa %>%  nngeo::st_remove_holes()
pa <- pa %>%  st_make_valid()
pa <- pa %>% st_crop(st_bbox(point))
pa <- pa %>%  nngeo::st_remove_holes()
pa <- pa %>%  st_make_valid()

ind <- ind %>% st_transform(crs=4326)
ind <- ind %>%  nngeo::st_remove_holes() 
ind <- ind %>%  st_make_valid()
ind_u <- ind %>% st_union()
ind_u
ind_u <- ind_u %>%  st_make_valid()
ind_u <- ind_u %>% st_as_sf () %>% mutate (Ind=TRUE)

#intersect
##############
# indigena
#############

point_ind <- point %>% st_intersects (ind_u, sparse = FALSE)
head(point_ind)
point_ind.tb <- tibble(Indigenous= point_ind[,1])
point_ind_sf <- point %>% bind_cols(point_ind.tb)
write_rds (point_ind_sf, file.path (dir_terr , "point_ind_sf.rds"))

############
# PAs
###########
pa_a <- pa %>% select(anoCriacao) 
pa_a <- pa_a %>% st_union(by_feature=TRUE)

ind <- point %>% nrow()/10
for (i in 4:10){
  print(i)
  point_a <- point %>% filter (row >= ind*(i-1) & row< ind*i)
  point_pa <- point_a %>% st_intersection (pa_a)
  write_rds (point_pa, file.path (dir_terr , paste0("point_pa",i,"_sf.rds")))
  assign(paste0("point_",i), point_pa)
}
for (i in 1:10){
  if (i==1){
    point_pa_all <- read_rds (file.path(dir_terr,paste0("point_pa",i,"_sf.rds") ))
  }else {
    tmp <- read_rds (file.path(dir_terr,paste0("point_pa",i,"_sf.rds") ))
    point_pa_all <- rbind(point_pa_all, tmp)
  }
}
write_rds (point_pa_all, file.path (dir_terr , "point_pa_all_sf.rds"))
unique( point_pa_all$anoCriacao)


################
# combine all points and pa and ind
################
point_pa_all.tb <- point_pa_all %>% as_tibble() %>% select(-geometry) %>% rename (PA_year = "anoCriacao")

point_2pa <- point %>% left_join(point_pa_all.tb, by="row")

#point_ind_sf <- read_rds (file.path (dir_terr , "point_ind_sf.rds"))
point_ind_sf.db <- point_ind_sf %>% as_tibble() %>% select(-geometry)
point_2pa_ind <- point_2pa %>% left_join(point_ind_sf.db, by="row")

write_rds (point_pa_all, file.path (dir_terr , "POINT_PA_IND_sf.rds"))



