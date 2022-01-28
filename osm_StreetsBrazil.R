#osm roads

devtools::install_github("ropensci/rnaturalearthdata")
devtools::install_github("ropensci/rnaturalearthhires")
#load packages
library(tidyverse)
library(osmdata)
library(sf)
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
# ggplot()+geom_sf(data=state) geom_sf(data=PA_all_roads$osm_lines)


#MT
state <- state %>% filter (code_hasc=="BR.MT")#| code_hasc=="BR.MT"| code_hasc=="BR.RO")
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

MT_all_roads <- osmdata_sf(q)

MT_all_roads_lines <- (MT_all_roads$osm_lines)
#ggplot()+geom_sf(data=state) geom_sf(data=MT_all_roads$osm_lines)


# RO
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

ggplot()+geom_sf(data=state) + 
  geom_sf(data=RO_all_roads$osm_lines)+
  geom_sf(data=MT_all_roads$osm_lines)+
  geom_sf(data=PA_all_roads$osm_lines)
  

