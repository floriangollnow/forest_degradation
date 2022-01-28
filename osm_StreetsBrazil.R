#osm roads

if(!require("osmdata")) install.packages("osmdata")if(!require("tidyverse")) install.packages("tidyverse")
if(!require("sf")) install.packages("sf")
if(!require("ggmap")) install.packages("ggmap")
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
(available_tags("highway"))
?getbb
test <- getbb("Cuiaba",featuretype = "settlement" )
str(test)
state <- ne_states(country="Brazil", returnclass="sf") 
state <- state %>% filter (code_hasc=="BR.PA"| code_hasc=="BR.MT"| code_hasc=="BR.RO")
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

all_roads <- osmdata_sf(q)

all_roads_lines <- (all_roads$osm_lines)


write_rds (all_roads, file.path(dir_data, "OSM_roads.rds"))
write_sf (all_roads, file.path(dir_data, "OSM_roads.geojson"))
# 
# ,


# ,

