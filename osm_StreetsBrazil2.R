# osm roads
# date January 29 2022
# roads for MT, PA, RO
# author: florian gollnow

#devtools::install_github("ropensci/rnaturalearthdata")
#devtools::install_github("ropensci/rnaturalearthhires")

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
state <- state %>% filter (code_hasc=="BR.PA"| code_hasc=="BR.MT"| code_hasc=="BR.RO")
ggplot()+geom_sf(data=state)
bb_box_state <- st_bbox(state) 
bb_box_state_tile <- split_bbox(bb_box_state,4,4)# see funtion in file x_split_box.R

# download all data in tiles
for (i in 1:length(bb_box_state_tile)){
timestamp()
print(paste("Starting",i, "from", length(bb_box_state_tile)))
bb_box_state.m <- matrix (bb_box_state_tile [[i]], byrow = F, ncol = 2)
rownames(bb_box_state.m)<- c("x","y")
colnames(bb_box_state.m)<- c("min","max")
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
write_rds(PA_all_roads, paste0("/Users/floriangollnow/Dropbox/ZDC_project/FEDE/OSM_roads/processing/PA_roads_tile_",i,".rds")) 
assign( paste0("PA_all_roads_tile_",i), PA_all_roads_lines)
print(paste("Finished",i, "from", length(bb_box_state_tile)))
timestamp()
Sys.sleep(time=900)
}
# combine all tiles
for (i in 1:16){
  print(i)
  if (i==1){
    all_roads_c <- PA_all_roads_tile_1 %>% select(c("osm_id","highway"))
  }
  tmp <- get(paste0("PA_all_roads_tile_", i))%>% select(c("osm_id","highway"))
  all_roads_c <- rbind(all_roads_c, tmp)
}
ggplot(all_roads_c %>% filter (highway=="primary"|highway=="motorway"|highway=="trunk")) +geom_sf()

write_rds(all_roads_c, "/Users/floriangollnow/Dropbox/ZDC_project/FEDE/OSM_roads/results/PA_roads_all_tiles.rds")
write_sf(all_roads_c, "/Users/floriangollnow/Dropbox/ZDC_project/FEDE/OSM_roads/results/PA_roads_all_tiles.geojson")

# union by feature with st_union
sf_use_s2(FALSE)
#roads_c  <- read_rds(file.path (dir_data, "results/PA_roads_all_tiles_u.rds"))
roads_u <- roads_c %>% 
  group_by(highway) %>%
  summarise(geometry = sf::st_union(geometry)) %>%
  ungroup()
roads_u
#all_roads_c_u <- all_roads_c %>% st_union(by_feature=TRUE)
write_rds(all_roads_c_u, "/Users/floriangollnow/Dropbox/ZDC_project/FEDE/OSM_roads/results/PA_roads_all_tiles_u.rds")
write_sf(all_roads_c_u, "/Users/floriangollnow/Dropbox/ZDC_project/FEDE/OSM_roads/results/PA_roads_all_tiles_u.geojson")
write_sf(all_roads_c_u, "/Users/floriangollnow/Dropbox/ZDC_project/FEDE/OSM_roads/results/PA_roads_all_tiles_u.shp")


