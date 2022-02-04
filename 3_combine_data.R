## combine datasets

library (tidyverse)
library (sf)

dir_data <- "/Users/floriangollnow/Dropbox/ZDC_project/FEDE"

point_data <- read_rds (file.path(dir_data, "Points/points_data_sf.rds"))

#population densit
population_data <- read_rds (file.path(dir_data, "PopulationDensity/population_sf.rds"))
ass_data <- read_rds (file.path(dir_data, "assentamiento/results/point_ass_intersect.rds"))
embargoes <- read_rds (file.path(dir_data, "embargoes/result/Point_car_embargoed_allY.rds"))
car_p <- read_rds (file.path(dir_data, "CAR/results/point_car_sf.rds"))
suit <-  read_rds (file.path(dir_data, "suitability/suitability_sf.rds"))
pa_ind <-  read_rds (file.path(dir_data, "protected and Indigena/results/POINT_PA_IND_sf.rds"))
osm_roads <- read_rds (file.path(dir_data, "OSM_roads/results/point_distance_sf.rds"))

# ind_s <- sample (0:max(point_data$row), max(point_data$row)/10)
# #population_data_sampel <- population_data
# gg_pd <- ggplot()+geom_sf(data=population_data %>% filter(row %in% ind_s),  aes(color=bra_pd_2020_1km_UNadj), alpha=0.5, size=0.5)
# gg_assF <- ggplot()+geom_sf(data=ass_data  %>% filter(row %in% ind_s), aes(color=AssFederalY),alpha=0.5, size=0.5)
# gg_assR <- ggplot(ass_data %>% filter(row %in% ind_s))+geom_sf(aes(color=AssReconhecimentoY),alpha=0.5, size=0.5)
# 
# gg_embargo <- ggplot()+geom_sf(data=embargoes %>% filter(row %in% ind_s), aes(color=embargoStartY),alpha=0.5, size=0.5)
# gg_car <- ggplot()+geom_sf(data=car_p %>%  filter(row %in% ind_s), aes(color=tipo_imove),alpha=0.5, size=0.5)
# 
# gg_gaez <- ggplot()+geom_sf(data=suit %>% filter(row %in% ind_s), aes(color=GAEZ_SoySuitability),alpha=0.5, size=0.5)
# gg_msuit<- ggplot()+geom_sf(data=suit %>% filter(row %in% ind_s), aes(color=MCropSuit), alpha=0.5, size=0.5)
# gg_pa <- ggplot()+geom_sf(data=pa_ind %>% filter(row %in% ind_s), aes(color=PA_year),alpha=0.5, size=0.5)
# gg_ind <- ggplot()+geom_sf(data=pa_ind %>% filter(row %in% ind_s), aes(color=Indigenous),alpha=0.5, size=0.5)
# 
# gg_osmA <- ggplot()+geom_sf(data=osm_roads %>% filter(row %in% ind_s), aes(color=roadsA_r_dist_dis),alpha=0.5, size=0.5)
# gg_osmP <- ggplot()+geom_sf(data=osm_roads %>% filter(row %in% ind_s), aes(color=roadsP_r_dist_dis),alpha=0.5, size=0.5)
# gg_osmS <- ggplot()+geom_sf(data=osm_roads %>% filter(row %in% ind_s), aes(color=roadsS_r_dist_dis),alpha=0.5, size=0.5)


# plots.list <- objects(patter="^gg")
# for (i in 1:length(plots.list)){
#   ggsave (file.path(dir_data,"plots",paste0(plots.list[i],".png")), plot=get(plots.list[i]))
# }
# i=3
# ggsave (file.path(dir_data,"plots",paste0(plots.list[i],".png")), plot=get(plots.list[i]))

population_data.tb <- population_data %>% as_tibble() %>% select(-c(geometry, ID))
ass_data.tb <- ass_data %>% as_tibble() %>% select (-geometry) 
embargoes.tb <- embargoes %>% as_tibble() %>% select(-c(geometry, DAT_EMBARGO, DAT_DESEMBARGO))
car_p.tb <- car_p %>% as_tibble() %>% select (-geometry) %>% mutate (CAR_p = case_when (tipo_imove== "IRU"~TRUE,
                                                                     TRUE~FALSE)) %>% select (-c(tipo_imove, group))
suit.tb <- suit %>% as_tibble() %>% select (-c(geometry, ID)) %>% mutate(MCropSuit = case_when(is.na(MCropSuit) ~ 0,
                                                                                               TRUE ~ MCropSuit))

pa_ind.tb <- pa_ind %>% as_tibble() %>% select (-geometry)
osm_roads.tb <- osm_roads %>% as_tibble() %>% select(-c(geometry, ID)) %>% 
  rename (roadsAll_m = roadsA_r_dist_dis, roadsOther_m = roadsO_r_dist_dis,  roadsPrimary_m= roadsP_r_dist_dis, roadsSecondary_m= roadsS_r_dist_dis)

data_all <- population_data.tb%>% 
  left_join(ass_data.tb , by='row') %>% 
  left_join(embargoes.tb, by='row') %>%
  left_join(car_p.tb, by='row') %>%
  left_join(suit.tb, by='row') %>%
  left_join(pa_ind.tb, by='row') %>%
  left_join(osm_roads.tb, by='row')


point_data_c <- point_data %>% left_join(data_all, by="row")
names(point_data_c)

write_rds (point_data_c, file.path(dir_data, "Points/results/points_data_all_sf.rds"))
write_csv (point_data_c %>% as_tibble() %>% select(-geometry), file.path(dir_data, "Points/results/points_data_all.csv"))
write_csv (point_data_c %>% as_tibble() , file.path(dir_data, "Points/results/points_data_all_sf.csv"))
#write_sf (point_data_c, file.path(dir_data, "Points/results/points_data_all_sf.shp"))
#write_sf (point_data_c, file.path(dir_data, "Points/results/points_data_all_sf.geojson"))



