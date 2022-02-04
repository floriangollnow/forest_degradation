library (tidyverse)
library (sf)
library(terra)

dir_points <- "/Users/floriangollnow/Dropbox/ZDC_project/FEDE/Points"
dir_roads <- "/Users/floriangollnow/Dropbox/ZDC_project/FEDE/OSM_roads/results"
dir_points <- "~/Data/Points"
dir_roads <- "~/Data/OSM_roads/results"


points <- read_rds (file.path (dir_points, "points_row_sf.rds")) 
points <- points %>% mutate (ID=row+1)
points_v <- points %>% vect() 


# use popd raster as reference
dir_pop <- "/Users/floriangollnow/Dropbox/ZDC_project/FEDE/PopulationDensity/"
dir_pop <- "~/Data/PopulationDensity/"
files_pop <- dir (dir_pop, pattern = ".tif$")
i=1
pop <- rast(file.path (dir_pop, files_pop[i] ))

#roads
roads <- read_rds (file.path (dir_roads, "PA_roads_all_tiles_u_s2FALSE.rds")) 
unique(roads$highway)

#primary
roadsP <- roads %>% filter (highway=="motorway" |highway=="primary"|highway=="primary_link" |highway=="trunk") 
roadsP <- roadsP %>% transmute(road=1)
roadsP_v <- roadsP %>% vect() 

# secondary 
roadsS <- roads %>% filter (highway=="secondary" ) 
roadsS <- roadsS %>% transmute(road=1)
roadsS_v <- roadsS %>% vect() 

# other
roadsO <- roads %>% filter (highway=="tertiary" |highway=="track"|highway=="unclassified" ) 
roadsO <- roadsO %>% transmute(road=1)
roadsO_v <- roadsO %>% vect() 

# any
roadsA <- roads 
roadsA <- roadsA %>% transmute(road=1)
roadsA_v <- roadsA %>% vect() 


# rasterize
raster_r <- rast (pop) #%>% disagg(fact=10)
raster_r <- raster_r %>% crop(roadsA_v )
roadsP_r  <- rasterize(roadsP_v, raster_r)
roadsS_r  <- rasterize(roadsS_v, raster_r)
roadsO_r  <- rasterize(roadsO_v, raster_r)
roadsA_r  <- rasterize(roadsA_v, raster_r)

#aggregate
roadsP_r_ag  <- aggregate(roadsP_r,fact=8, fun=max, na.rm=TRUE)
roadsS_r_ag  <- aggregate(roadsS_r,fact=8, fun=max, na.rm=TRUE)
roadsO_r_ag  <- aggregate(roadsO_r,fact=8, fun=max, na.rm=TRUE)
roadsA_r_ag  <- aggregate(roadsA_r,fact=8, fun=max, na.rm=TRUE)

#distance
roadsP_r_dist<- distance (roadsP_r_ag)
roadsS_r_dist<- distance (roadsS_r_ag)
roadsO_r_dist<- distance (roadsO_r_ag)
roadsA_r_dist<- distance (roadsA_r_ag)

#bilinear dissagregation to original 
roadsP_r_dist_dis<- disagg (roadsP_r_dist, fact=2,method='bilinear')
roadsP_r_dist_dis<- disagg (roadsP_r_dist_dis, fact=2,method='bilinear')
roadsP_r_dist_dis<- disagg (roadsP_r_dist_dis, fact=2,method='bilinear')
roadsP_r_dist_dis
plot(roadsP_r_dist_dis / 1000)
writeRaster(roadsP_r_dist_dis,file.path (dir_roads, "PrimaryR_dist_raster.tif"))
#roadsP_r_dist_dis <-rast(file.path (dir_roads, "PrimaryR_dist_raster.tif"))


roadsS_r_dist_dis<- disagg (roadsS_r_dist, fact=2,method='bilinear')
roadsS_r_dist_dis<- disagg (roadsS_r_dist_dis, fact=2,method='bilinear')
roadsS_r_dist_dis<- disagg (roadsS_r_dist_dis, fact=2,method='bilinear')
roadsS_r_dist_dis
plot(roadsS_r_dist_dis / 1000)
writeRaster(roadsS_r_dist_dis,file.path (dir_roads, "SecondaryR_dist_raster.tif"))

roadsO_r_dist_dis<- disagg (roadsO_r_dist, fact=2,method='bilinear')
roadsO_r_dist_dis<- disagg (roadsO_r_dist_dis, fact=2,method='bilinear')
roadsO_r_dist_dis<- disagg (roadsO_r_dist_dis, fact=2,method='bilinear')
roadsO_r_dist_dis
plot(roadsO_r_dist_dis / 1000)
writeRaster(roadsO_r_dist_dis,file.path (dir_roads, "OtherR_dist_raster.tif"))


roadsA_r_dist_dis<- disagg (roadsA_r_dist, fact=2,method='bilinear')
roadsA_r_dist_dis<- disagg (roadsA_r_dist_dis, fact=2,method='bilinear')
roadsA_r_dist_dis<- disagg (roadsA_r_dist_dis, fact=2,method='bilinear')
roadsA_r_dist_dis
plot(roadsA_r_dist_dis / 1000)
writeRaster(roadsA_r_dist_dis,file.path (dir_roads, "AllR_dist_raster.tif"))

## point overlay
# read each distance raster separately and extract values based on SpatVector derived from sf 
files_distance <- objects(pattern = "dist_dis$") 
for (i in 1:length(files_distance)){
  print (i)
  print (length(files_distance))
  dist <- get(files_distance[i])
  names(dist) <- files_distance[i]
  points_dist <- terra::extract(dist, points_v, fun=NULL, method='simple')
  if (i==1){
    dist_data <- as_tibble(points_dist)
  }else {
    dist_data <- dist_data %>% left_join(as_tibble(points_dist ), by="ID")
  }
}

points_data <- points %>% left_join(dist_data, by="ID")
write_rds(points_data, file.path (dir_roads, "point_distance_sf.rds"))

