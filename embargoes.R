##
# read embargoes file
# clean coordinates
# convert lat long if exchanged
# convert to sf object
# save spatial embargo data

library (tidyverse)
library (sf)


dir_data <- "/Users/floriangollnow/Dropbox/ZDC_project/FEDE/embargoes"
ama_legal <- "/Users/floriangollnow/Dropbox/ZDC_project/FEDE/Admin/AmazoniaLegal"
ama <- read_sf(file.path(ama_legal,"Amazonia_Legal_2020.shp" )) %>% st_transform(crs = 4326)
st_crs(ama)
ama_bb <- st_bbox(ama)
plot(ama)
# read all as character
emb <- read_csv(file.path (dir_data, "areas_embargadas.csv"), col_types = "cccccccccccccccccccccccccccc")
unique(emb$`UF Infração`) 
emb <- emb %>% filter (`UF Infração`=="MT" | `UF Infração`=="PA"| `UF Infração`=="RO")
str(emb)
## convert lat and lone coordinates
emb <- emb %>% mutate(Latitude2=gsub (",",".", Latitude),Longitude2=gsub (",",".", Longitude) )
emb <- emb %>% mutate(Latitude2= as.numeric(Latitude2), Longitude2= as.numeric(Longitude2))
# filter NA and 0s
emb_ll <- emb %>% filter (!is.na(Latitude2), !is.na(Longitude2), Latitude2!=0, Longitude2!=0)
#emb_ll %>% select(Latitude2, Longitude2) %>% View()


## check for confusion between long and lat
# check if lon, lat fit into bounding box (Legal Amazon), if yes, leave as is, if not check if they would fit if lon=lat and lat=lon, if yes, changem, otherwise NA
emb_ll3 <- emb_ll %>% mutate(Longitude3 = case_when(Longitude2 <= ama_bb$xmax & Longitude2 >= ama_bb$xmin &
                                                     Latitude2 <= ama_bb$ymax & Latitude2 >= ama_bb$ymin ~ Longitude2,
                                                   Latitude2 <= ama_bb$xmax & Latitude2 >= ama_bb$xmin &
                                                     Longitude2 <= ama_bb$ymax & Longitude2 >= ama_bb$ymin ~ Latitude2,
                                                   TRUE ~ NA_real_),
                            Latitude3 = case_when(Latitude2 <= ama_bb$ymax & Latitude2 >= ama_bb$ymin & 
                                                    Longitude2 <= ama_bb$xmax & Longitude2 >= ama_bb$xmin ~ Latitude2,
                                                  Longitude2 <= ama_bb$ymax & Longitude2 >= ama_bb$ymin & 
                                                    Latitude2 <= ama_bb$xmax & Latitude2 >= ama_bb$xmin ~ Longitude2,
                                                  TRUE ~ NA_real_))

# filter NA
emb_ll3 <- emb_ll3 %>% filter (!is.na(Latitude3), !is.na(Longitude3))
# emb_ll3 %>% select(Latitude2, Longitude2) %>% View()

#convert to sf
emb_sf <- emb_ll3 %>%
  st_as_sf(coords = c("Longitude3", "Latitude3"), crs=4326)

#write
write_sf(emb_sf, file.path (dir_data, "embargoes_sf.shp"))
write_rds(emb_sf, file.path (dir_data, "embargoes_sf.rds"))

