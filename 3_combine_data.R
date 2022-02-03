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
#osm_roads <- read_rds (file.path(dir_data, "OSM_roads/results/.rds"))

ind_s <- sample (0:max(point_data$row), max(point_data$row)/10)
#population_data_sampel <- population_data
gg_pd <- ggplot()+geom_sf(data=population_data %>% filter(row %in% ind_s),  aes(color=bra_pd_2020_1km_UNadj), alpha=0.5, size=0.5)
gg_assF <- ggplot()+geom_sf(data=ass_data  %>% filter(row %in% ind_s), aes(color=AssFederalY),alpha=0.5, size=0.5)
gg_assR <- ggplot(ass_data %>% filter(row %in% ind_s))+geom_sf(aes(color=AssReconhecimentoY),alpha=0.5, size=0.5)

gg_embargo <- ggplot()+geom_sf(data=embargoes %>% filter(row %in% ind_s), aes(color=embargoStartY),alpha=0.5, size=0.5)
gg_car <- ggplot()+geom_sf(data=car_p %>%  filter(row %in% ind_s), aes(color=tipo_imove),alpha=0.5, size=0.5)

gg_gaez <- ggplot()+geom_sf(data=suit %>% filter(row %in% ind_s), aes(color=GAEZ_SoySuitability),alpha=0.5, size=0.5)
gg_msuit<- ggplot()+geom_sf(data=suit %>% filter(row %in% ind_s), aes(color=MCropSuit), alpha=0.5, size=0.5)
gg_pa <- ggplot()+geom_sf(data=pa_ind %>% filter(row %in% ind_s), aes(color=PA_year),alpha=0.5, size=0.5)
gg_ind <- ggplot()+geom_sf(data=pa_ind %>% filter(row %in% ind_s), aes(color=Indigenous),alpha=0.5, size=0.5)

plots.list <- objects(patter="^gg")
for (i in 1:length(plots.list)){
  ggsave (file.path(dir_data,"plots",paste0(plots.list[i],".png")), plot=get(plots.list[i]))
}
i=3
ggsave (file.path(dir_data,"plots",paste0(plots.list[i],".png")), plot=get(plots.list[i]))
