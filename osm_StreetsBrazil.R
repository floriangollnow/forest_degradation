# osm roads
# date January 28 2022
# roads for MT, PA, RO
# author: florian gollnow

devtools::install_github("ropensci/rnaturalearthdata")
devtools::install_github("ropensci/rnaturalearthhires")
library(httr)    
set_config(use_proxy(url="10.3.100.207",port=8080))
#load packages
library(tidyverse)
library(osmdata)
library(sf)
remotes::install_github("MatthewJWhittle/spatialutils")
library(spatialutils)
#library(ggmap)

library(rnaturalearth)
library(rnaturalearthhires)

dir_data <- "~/Data/roads"

head(available_features())
#(available_tags("highway"))
#?getbb
#test <- getbb("Cuiaba",featuretype = "settlement" )
#str(test)

# PA
state <- ne_states(country="Brazil", returnclass="sf") 
state <- state %>% filter (code_hasc=="BR.PA")#| code_hasc=="BR.MT"| code_hasc=="BR.RO")
ggplot()+geom_sf(data=state)
bb_box_state <- st_bbox(state) 
bb_box_state.m <- matrix (bb_box_state, byrow = F, ncol = 2)
rownames(bb_box_state.m)<- c("x","y")
colnames(bb_box_state.m)<- c("min","max")

str(bb_box_state.m)

q <- bb_box_state.m%>%
  opq()%>%
  add_osm_features(
    features = c ("\"highway\"=\"motorway\"",
                  "\"highway\"=\"trunk\"",
                  "\"highway\"=\"primary\"",
                   "\"highway\"=\"secondary\"",
                   "\"highway\"=\"tertiary\"",
                   "\"highway\"=\"unclassified\"",
                   "\"highway\"=\"track\"",
                   "\"highway\"=\"road\""))

PA_all_roads <- osmdata_sf(q)

PA_all_roads_lines <- (PA_all_roads$osm_lines)
ggplot()+geom_sf(data=state) +geom_sf(data=PA_all_roads$osm_lines)
write_rds(PA_all_roads, "/Users/floriangollnow/Dropbox/ZDC_project/FEDE/OSM_roads/processing/PA_roads.rds") 
#PA_all_roads<-read_rds("/Users/floriangollnow/Dropbox/ZDC_project/FEDE/OSM_roads/processing/PA_roads.rds")

#MT 1
state <- ne_states(country="Brazil", returnclass="sf") 
state <- state %>% filter (code_hasc=="BR.MT")#| code_hasc=="BR.MT"| code_hasc=="BR.RO")
ggplot()+geom_sf(data=state)
bb_box_state <- st_bbox(state) 
bb_box_state_tile <- split_bbox(bb_box_state,2,1)
bb_box_state.m <- matrix (bb_box_state_tile[[1]], byrow = F, ncol = 2)
rownames(bb_box_state.m)<- c("x","y")
colnames(bb_box_state.m)<- c("min","max")

str(bb_box_state.m)


q <- bb_box_state.m%>%
  opq()%>%
  add_osm_features(
    features = c ("\"highway\"=\"motorway\"",
                  "\"highway\"=\"trunk\"",
                  "\"highway\"=\"primary\"",
                  "\"highway\"=\"secondary\"",
                  "\"highway\"=\"tertiary\"",
                  "\"highway\"=\"unclassified\"",
                  "\"highway\"=\"track\"",
                  "\"highway\"=\"road\""))

MT1_all_roads <- osmdata_sf(q)

MT1_all_roads_lines <- (MT1_all_roads$osm_lines)
ggplot()+geom_sf(data=state) + geom_sf(data=MT1_all_roads$osm_lines)
write_rds(MT1_all_roads, "/Users/floriangollnow/Dropbox/ZDC_project/FEDE/OSM_roads/processing/MT1_roads.rds") 

#MT2
bb_box_state.m <- matrix (bb_box_state_tile[[2]], byrow = F, ncol = 2)
rownames(bb_box_state.m)<- c("x","y")
colnames(bb_box_state.m)<- c("min","max")

str(bb_box_state.m)

q <- bb_box_state.m%>%
  opq()%>%
  add_osm_features(
    features = c ("\"highway\"=\"motorway\"",
                  "\"highway\"=\"trunk\"",
                  "\"highway\"=\"primary\"",
                  "\"highway\"=\"secondary\"",
                  "\"highway\"=\"tertiary\"",
                  "\"highway\"=\"unclassified\"",
                  "\"highway\"=\"track\"",
                  "\"highway\"=\"road\""))

MT2_all_roads <- osmdata_sf(q)

MT2_all_roads_lines <- (MT2_all_roads$osm_lines)
ggplot()+geom_sf(data=state) + geom_sf(data=MT2_all_roads$osm_lines)
write_rds(MT2_all_roads, "/Users/floriangollnow/Dropbox/ZDC_project/FEDE/OSM_roads/processing/MT2_roads.rds") 


# RO
state <- ne_states(country="Brazil", returnclass="sf") 
state <- state %>% filter (code_hasc=="BR.RO")#| code_hasc=="BR.MT"| code_hasc=="BR.RO")
#ggplot()+geom_sf(data=state)
bb_box_state <- st_bbox(state) 
bb_box_state.m <- matrix (bb_box_state, byrow = F, ncol = 2)
rownames(bb_box_state.m)<- c("x","y")
colnames(bb_box_state.m)<- c("min","max")

str(bb_box_state.m)

q <- bb_box_state.m%>%
  opq()%>%
  add_osm_features(
    features = c ("\"highway\"=\"motorway\"",
                  "\"highway\"=\"trunk\"",
                  "\"highway\"=\"primary\"",
                  "\"highway\"=\"secondary\"",
                  "\"highway\"=\"tertiary\"",
                  "\"highway\"=\"unclassified\"",
                  "\"highway\"=\"track\"",
                  "\"highway\"=\"road\""))

RO_all_roads <- osmdata_sf(q)
RO_all_roads_lines <- (RO_all_roads$osm_lines)
ggplot()+geom_sf(data=state) + geom_sf(data=RO_all_roads$osm_lines)
write_rds(RO_all_roads, "/Users/floriangollnow/Dropbox/ZDC_project/FEDE/OSM_roads/processing/RO_roads.rds") 

## plot them all
state <- ne_states(country="Brazil", returnclass="sf") 

state <- state %>% filter (code_hasc=="BR.RO"| code_hasc=="BR.MT"| code_hasc=="BR.RO")

ggplot()+geom_sf(data=state) + 
  geom_sf(data=RO_all_roads$osm_lines)+
  geom_sf(data=MT1_all_roads$osm_lines)+
  geom_sf(data=MT2_all_roads$osm_lines)+
  geom_sf(data=PA_all_roads$osm_lines)


## cleaning: 
## combine and st_line_merge
names(MT1_all_roads$osm_lines)
names(MT2_all_roads$osm_lines)
MT_roads <- rbind (MT1_all_roads$osm_lines %>% select(c("osm_id","highway")), MT2_all_roads$osm_lines %>%  select(c("osm_id","highway")))
MT_roads_merge <- MT_roads %>% st_union()

OSM_roads <- rbind(MT_roads_merge,PA_all_roads$osm_lines %>% select(c("osm_id","highway")), RO_all_roads$osm_lines %>%  select(c("osm_id","highway")))
OSM_roads_merge <- OSM_roads %>% st_union()
write_rds(OSM_roads_merge, "/Users/floriangollnow/Dropbox/ZDC_project/FEDE/OSM_roads/results/OSM_roads.rds") 

  

