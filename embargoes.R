##
# read embargoes file
# clean coordinates
# convert lat long if exchanged
# convert to sf object
# save spatial embargo data

library (tidyverse)
library (sf)
library(rnaturalearth)
library(lwgeom)

dir_data <- "/Users/floriangollnow/Dropbox/ZDC_project/FEDE/embargoes"
braz <- ne_countries(country="Brazil", scale = "medium", returnclass = "sf")

st_crs(braz)
braz_bb <- st_bbox(braz)
ggplot(data = braz) + geom_sf() +labs( x = "Longitude", y = "Latitude")

# <- read_csv(file.path (dir_data, "areas_embargadas.csv"), col_types = "cccccccccccccccccccccccccccc")
emb2 <- read_csv2(file.path (dir_data, "termo_embargo_17_01_2022.csv"))
nrow(emb2)

#unique(emb$`UF Infração`) 
#emb <- emb %>% filter (`UF Infração`=="MT" | `UF Infração`=="PA"| `UF Infração`=="RO")
str(emb)
## convert lat and lone coordinates
#emb <- emb %>% mutate(Latitude2=gsub (",",".", Latitude),Longitude2=gsub (",",".", Longitude) )
#emb <- emb %>% mutate(Latitude2= as.numeric(Latitude2), Longitude2= as.numeric(Longitude2))
# filter NA and 0s
#emb_ll <- emb %>% filter (!is.na(Latitude2), !is.na(Longitude2), Latitude2!=0, Longitude2!=0)
emb_ll <- emb2 %>% filter (!is.na(NUM_LATITUDE_TAD), !is.na(NUM_LONGITUDE_TAD), NUM_LATITUDE_TAD!=0, NUM_LONGITUDE_TAD!=0)

#emb_ll %>% select(Latitude2, Longitude2) %>% View()


## check for confusion between long and lat
# check if lon, lat fit into bounding box (Brazil), if yes, leave as is, if not check if they would fit if lon=lat and lat=lon, if yes, change, otherwise NA
# emb_ll3 <- emb_ll %>% mutate(Longitude3 = case_when(Longitude2 <= braz_bb$xmax & Longitude2 >= braz_bb$xmin &
#                                                      Latitude2 <= braz_bb$ymax & Latitude2 >= braz_bb$ymin ~ Longitude2,
#                                                    Latitude2 <= braz_bb$xmax & Latitude2 >= braz_bb$xmin &
#                                                      Longitude2 <= braz_bb$ymax & Longitude2 >= braz_bb$ymin ~ Latitude2,
#                                                    TRUE ~ NA_real_),
#                             Latitude3 = case_when(Longitude3 == Longitude2~ Latitude2,
#                                                   Longitude3 == Latitude2 ~ Longitude2,
#                                                   TRUE ~ NA_real_))

# emb_ll3 <- emb_ll %>% mutate(Longitude3 = case_when(NUM_LONGITUDE_TAD <= braz_bb$xmax & NUM_LONGITUDE_TAD >= braz_bb$xmin &
#                                                      NUM_LATITUDE_TAD <= braz_bb$ymax & NUM_LATITUDE_TAD >= braz_bb$ymin ~ NUM_LONGITUDE_TAD,
#                                                    NUM_LATITUDE_TAD <= braz_bb$xmax & NUM_LATITUDE_TAD >= braz_bb$xmin &
#                                                      NUM_LONGITUDE_TAD <= braz_bb$ymax & NUM_LONGITUDE_TAD >= braz_bb$ymin ~ NUM_LATITUDE_TAD,
#                                                    TRUE ~ NA_real_),
#                             Latitude3 = case_when(Longitude3 == NUM_LONGITUDE_TAD~ NUM_LATITUDE_TAD,
#                                                   Longitude3 == NUM_LATITUDE_TAD ~ NUM_LONGITUDE_TAD,
#                                                   TRUE ~ NA_real_))
# 
# filter NA
emb_ll3 <- emb_ll3 %>% filter (!is.na(Latitude3), !is.na(Longitude3))
# emb_ll3 %>% select(Latitude2, Longitude2) %>% View()
emb_ll3$`Data de Inserção na Lista` %>% unique()
emb_ll3$`Data alteração` %>% unique()
emb_ll3$Status %>% unique()

# select only forest violations
emb_ll3_f <- emb_ll3 %>% mutate(Floresta = str_detect(Infração, "floresta")) 
emb_ll3_f <- emb_ll3_f %>% filter(Floresta==TRUE)
emb_ll3_f$`Data de Inserção na Lista` %>% unique()
emb_ll3$`Data alteração` %>% unique()
emb_ll3$Status %>% unique()
emb_ll3_f$Infração %>% unique()




#convert to sf
emb_sf <- emb_ll3_f %>%
  st_as_sf(coords = c("Longitude3", "Latitude3"), crs=4326)
ggplot(emb_sf)+geom_sf(aes())

emb_sf <- emb2 %>% filter(!is.na(NUM_LONGITUDE_TAD),!is.na(NUM_LATITUDE_TAD)) %>%
  st_as_sf(coords = c("NUM_LONGITUDE_TAD", "NUM_LATITUDE_TAD"), crs=4326)
ggplot(emb_sf)+geom_sf(aes())

emb_sf <- emb2 %>% filter(!is.na(NUM_LONGITUDE_TAD),!is.na(NUM_LATITUDE_TAD)) %>%
  st_as_sf(coords = c("NUM_LONGITUDE_TAD", "NUM_LATITUDE_TAD"), crs=4326)
#write
write_sf(emb_sf, file.path (dir_data, "embargoes_sf.shp"))
write_sf(emb_sf, file.path (dir_data, "embargoes_sf2.geojson"))
write_rds(emb_sf, file.path (dir_data, "embargoes_sf2.rds"))


###############################################

emb_poly <- emb2 %>% mutate (row=1:nrow(emb2))
nrow(emb_poly)#81976
emb_poly <- emb2 %>% mutate (Polygon=!is.na (GEOM_AREA_EMBARGADA))



write_csv2(emb_poly, file.path (dir_data, "termo_embargo_17_01_2022_poly.csv"))
emb_poly <- emb_poly %>% filter (!is.na (GEOM_AREA_EMBARGADA))



nrow(emb_poly) #32116
emb_poly <- emb_poly %>% filter (str_ends(GEOM_AREA_EMBARGADA, pattern = "[/)]"))
nrow(emb_poly) #31367 ## i am excluding many here

emb_poly <- emb_poly %>% mutate (WKS = case_when (str_detect(GEOM_AREA_EMBARGADA, pattern = "[/(]{2}")&
                                                             str_ends(GEOM_AREA_EMBARGADA, pattern = "[/)]{2}", negate=T) ~ paste0(GEOM_AREA_EMBARGADA, ")"),
                                                  str_detect(GEOM_AREA_EMBARGADA, pattern = "[/(]{3}")&
                                                    str_ends(GEOM_AREA_EMBARGADA, pattern = "[/)]{3}", negate=T)~ paste0(GEOM_AREA_EMBARGADA, ")"),
                                                  TRUE ~ GEOM_AREA_EMBARGADA),
                                 WKS = case_when ( str_detect(WKS, pattern = "[/(]{3}")&
                                                     str_ends(WKS, pattern = "[/)]{3}", negate=T)~ paste0(WKS, ")"),
                                                   TRUE ~ WKS))


emb_poly$GEOM_AREA_EMBARGADA[1]

str_starts(emb_poly$GEOM_AREA_EMBARGADA[1], "POLYGON")

# repair polygons
emb_poly


emb_poly2 <- emb_poly %>% select(GEOM_AREA_EMBARGADA, WKS , row)%>% st_as_sf (wkt="WKS")
st_is_valid(emb_poly2)
emb_poly2 <- emb_poly2 %>% st_buffer(0)
emb_poly2 <- st_make_valid(emb_poly2)
emb_poly3 <- emb_poly2 %>% filter(st_is_valid(emb_poly2)) 
write_sf(emb_poly2, file.path (dir_data, "embargoes_poly_sf_broken.geojson"))

ggplot(emb_poly3)+geom_sf(aes())
write_sf(emb_poly3, file.path (dir_data, "embargoes_poly_sf.shp"))
write_sf(emb_poly3, file.path (dir_data, "embargoes_poly_sf.geojson"))
write_rds(emb_poly3, file.path (dir_data, "embargoes_poly_sf.rds"))

