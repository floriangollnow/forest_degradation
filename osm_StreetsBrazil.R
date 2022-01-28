#osm roads

if(!require("osmdata")) install.packages("osmdata")
if(!require("tidyverse")) install.packages("tidyverse")
if(!require("sf")) install.packages("sf")
if(!require("ggmap")) install.packages("ggmap")
#load packages
library(tidyverse)
library(osmdata)
library(sf)
library(ggmap)

library(rnaturalearth)
dir_data <- "~/Data/roads"
head(available_features())
(available_tags("highway"))
?getbb
 <- getbb("Novo Progresso",featuretype = "settlement" )

state <- ne_states(country="Brazil", returnclass="sf") 
state <- state %>% filter (code_hasc=="BR.PA")#| code_hasc=="BR.MT"| code_hasc=="BR.RO")
bb_box_state <- st_bbox(state) 
bb_box_state.m <- matrix (bb_box_state, byrow = F, ncol = 2)


q <- bb_box_state.m %>%
  opq()%>%
  add_osm_features(
    features = c ("\"highway\"=\"motorway\"",
                  "\"highway\"=\"trunk\"",
                  "\"highway\"=\"primary\""))

all_roads2 <- osmdata_sf(q)

all_roads <- st_to_sf (all_roads)
write_rds (all_roads, file.path(dir_data, "OSM_roads.rds"))
write_sf (all_roads, file.path(dir_data, "OSM_roads.geojson"))
# 
# ,


# ,
# "\"highway\"=\"secondary\"",
# "\"highway\"=\"tertiary\"",
# "\"highway\"=\"unclassified\"",
# "\"highway\"=\"track\"",
# "\"highway\"=\"road\"")
