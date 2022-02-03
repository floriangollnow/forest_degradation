# read embargo area
# extract polygons
# if no polygon is provided or data is corrupted see if it contains a coordinate
# if coordinates are provided, intersect with properties of car
# add property polygon to embargoed area
# 
# two columns: embargo start year, embargo end year

#car data for MT, PA, RO. only use properties filter (tipo_imove=="IRU") excluding settlements
#
library(tidyverse)
library(sf)
library(rnaturalearth)
sf::sf_use_s2(FALSE) # issue with spehrical geometries of CAR data

dir_data <- "~/Data/embargoes"
embargoes_data <- "~/shared_epl/public/ONGOING_RESEARCH/ZDCinBrazil/Data/Embargoes"
car_data <- "~/shared_epl/public/ONGOING_RESEARCH/ZDCinBrazil/Deregulation_Covid/DATA/pa_br_car_2021"

emb <- read_csv2(file.path (embargoes_data, "termo_embargo_17_01_2022.csv"))
emb_row <- emb %>% mutate (row=1:nrow(emb))

emb_poly <- emb_row %>% mutate (Polygon=!is.na (GEOM_AREA_EMBARGADA))
emb_poly <- emb_poly %>% filter (str_ends(GEOM_AREA_EMBARGADA, pattern = "[/)]"))# exclude fully corrupted
# repair whats possible by adding )
emb_poly <- emb_poly %>% mutate (geometry = case_when (str_detect(GEOM_AREA_EMBARGADA, pattern = "[/(]{2}")&
                                                         str_ends(GEOM_AREA_EMBARGADA, pattern = "[/)]{2}", negate=T) ~ paste0(GEOM_AREA_EMBARGADA, ")"),
                                                       str_detect(GEOM_AREA_EMBARGADA, pattern = "[/(]{3}")&
                                                         str_ends(GEOM_AREA_EMBARGADA, pattern = "[/)]{3}", negate=T)~ paste0(GEOM_AREA_EMBARGADA, ")"),
                                                       TRUE ~ GEOM_AREA_EMBARGADA),
                                 geometry = case_when ( str_detect(geometry, pattern = "[/(]{3}")&
                                                          str_ends(geometry, pattern = "[/)]{3}", negate=T)~ paste0(geometry, ")"),
                                                        TRUE ~ geometry))



emb_poly2 <- emb_poly %>% select(row, GEOM_AREA_EMBARGADA, geometry , row)%>% st_as_sf (wkt="geometry", crs = st_crs(4326))
all(st_is_valid(emb_poly2))
emb_poly2 <- emb_poly2 %>% st_buffer(0)
emb_poly2 <- st_make_valid(emb_poly2)
emb_poly3 <- emb_poly2 %>% filter(st_is_valid(emb_poly2)) # only keep valid polygons

## save polygon data set from IBAMA
write_rds (emb_poly3 , file.path(dir_data, "processing/emb_poly3.rds"))


######## which locations can be recuperated using CAR
# which rows were excluded based on missing or corrupted polygons and do they have coordinates?
ind_poly <- emb_poly3 %>% as_tibble () %>% select (-c(GEOM_AREA_EMBARGADA, WKS ))
ind_poly <- ind_poly %>% mutate(poly=TRUE)

emb_row_check <- emb_row %>% left_join(ind_poly) 
## keep only those that have no polygon and Lat Long
emb_2intersect <- emb_row_check %>%  filter(is.na (poly),!is.na(NUM_LATITUDE_TAD), !is.na(NUM_LONGITUDE_TAD ))
unique(emb_2intersect$poly)


#####
# convert IBAMA coordinates to sf
# correct LAT/LONG confusion if there (if coordinates do not fit into Brazil, test if they would with turned LAT/LONG)

# use brazil as bounding box 
braz <- ne_countries(country="Brazil", scale = "medium", returnclass = "sf")
st_crs(braz)
braz_bb <- st_bbox(braz)

## check for confusion between long and lat
# check if lon, lat fit into bounding box (Brazil), if yes, leave as is, if not check if they would fit if lon=lat and lat=lon, if yes, change, otherwise NA
emb_2intersect_latlong <- emb_2intersect %>% mutate(Longitude3 = case_when(NUM_LONGITUDE_TAD <= braz_bb$xmax & NUM_LONGITUDE_TAD >= braz_bb$xmin &
                                                                             NUM_LATITUDE_TAD <= braz_bb$ymax & NUM_LATITUDE_TAD >= braz_bb$ymin ~ NUM_LONGITUDE_TAD,
                                                                           NUM_LATITUDE_TAD <= braz_bb$xmax & NUM_LATITUDE_TAD >= braz_bb$xmin &
                                                                             NUM_LONGITUDE_TAD <= braz_bb$ymax & NUM_LONGITUDE_TAD >= braz_bb$ymin ~ NUM_LATITUDE_TAD,
                                                                           TRUE ~ NA_real_),
                                                    Latitude3 = case_when(Longitude3 == NUM_LONGITUDE_TAD~ NUM_LATITUDE_TAD,
                                                                          Longitude3 == NUM_LATITUDE_TAD ~ NUM_LONGITUDE_TAD,
                                                                          TRUE ~ NA_real_))
emb_2intersect_latlong <- emb_2intersect_latlong %>% filter (!is.na(Latitude3), !is.na(Longitude3))# filter NA -> coordinates outside Brazils bounding box

# convert to sf 
emb_2intersect_latlong_sf <- emb_2intersect_latlong %>%
  st_as_sf(coords = c("Longitude3", "Latitude3"), crs=4326)
ggplot(emb_2intersect_latlong_sf )+geom_sf(aes())



### 
### intersect points from IBAMA with CAR properties for MT, PA, RO

# MT 
MT_car <- read_sf (file.path(car_data, "uf_MT/uf_MT.shp"))
MT_car <- MT_car %>% st_transform(crs = st_crs(emb_2intersect_latlong_sf))
MT_box <- MT_car %>% st_bbox()
# filter properties
MT_car_p <- MT_car %>% filter (tipo_imove=="IRU")
MT_emb_2intersect_latlong_sf <- emb_2intersect_latlong_sf %>%  st_crop (MT_box)
# intersect
MT_car_embargoed <- sf::st_intersection ( MT_car_p %>% select(id),  MT_emb_2intersect_latlong_sf) 
MT_car_embargoed_poly <- MT_car_p %>% select(id) %>% inner_join(as_tibble (MT_car_embargoed )%>% select(-geometry), by="id")# keep polygons, not points!
write_rds (MT_car_embargoed_poly, file.path(dir_data, "processing/MT_car_embargoed.rds"))

# PA
PA_car <- read_sf (file.path(car_data, "uf_PA/uf_PA.shp"))
PA_car <- PA_car %>% st_transform(crs = st_crs(emb_2intersect_latlong_sf))
PA_box <- PA_car %>% st_bbox()
# filter properties
PA_car_p <- PA_car %>% filter (tipo_imove=="IRU")
PA_emb_2intersect_latlong_sf <- emb_2intersect_latlong_sf %>%  st_crop (PA_box)
# intersect
PA_car_embargoed <- st_intersection (PA_car_p, PA_emb_2intersect_latlong_sf) 
PA_car_embargoed_poly <- PA_car_p %>% select(id) %>% inner_join(as_tibble (PA_car_embargoed )%>% select(-geometry), by="id")
write_rds (PA_car_embargoed_poly, file.path(dir_data, "processing/PA_car_embargoed.rds"))

# RO 
RO_car <- read_sf (file.path(car_data, "uf_RO/uf_RO.shp"))
RO_car <- RO_car %>% st_transform(crs = st_crs(emb_2intersect_latlong_sf))
RO_box <- RO_car %>% st_bbox()
# filter properties
RO_car_p <- RO_car %>% filter (tipo_imove=="IRU")
RO_emb_2intersect_latlong_sf <- emb_2intersect_latlong_sf %>%  st_crop (RO_box)
# intersect
RO_car_embargoed <- st_intersection (RO_car_p, RO_emb_2intersect_latlong_sf) 
RO_car_embargoed_poly <- RO_car_p %>% select(id) %>% inner_join(as_tibble (RO_car_embargoed )%>% select(-geometry), by="id")
write_rds (RO_car_embargoed_poly, file.path(dir_data, "processing/RO_car_embargoed.rds"))

### combine polygon data keeping only the the id and row
CAR_embargoe <-  rbind(MT_car_embargoed_poly %>% select (id, row), PA_car_embargoed_poly %>% select (id, row), RO_car_embargoed_poly%>% select (id, row))
CAR_embargoe_row <- CAR_embargoe %>% select (row)# 
CAR_embargoe


#############################
#add polysi from embargo data
CAR_embargoe_all <- CAR_embargoe %>% select(row) %>% rbind(emb_poly3 %>% select(row)) %>% arrange (row)
write_rds (CAR_embargoe_all, file.path(dir_data, "processing/Car_embargoed_all.rds"))

########################
# add embargod polygons - data includes embargoed polygons from Ibama and if ibama provided coordinates, but no polygon, the intersecting CAR polygon
CAR_embargoe_all_data <- CAR_embargoe_all %>% mutate(source="CAR") %>% left_join (emb_row %>% mutate (source="ibama"), by="row") 
write_rds (CAR_embargoe_all_data, file.path(dir_data, "result/Car_embargoed_all_data.rds"))
write_sf (CAR_embargoe_all_data, file.path(dir_data, "result/Car_embargoed_all_data.geojson"))

