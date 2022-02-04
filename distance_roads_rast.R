library (tidyverse)
library (sf)
library(terra)
library(whitebox)
#library(raster)
#extracting population density data for each point between 2000 and 2020 using terra package

dir_points <- "/Users/floriangollnow/Dropbox/ZDC_project/FEDE/Points"
dir_roads <- "/Users/floriangollnow/Dropbox/ZDC_project/FEDE/OSM_roads/results"

#roads
roads <- read_rds (file.path (dir_roads, "PA_roads_all_tiles_u_s2FALSE.rds")) 
unique(roads$highway)
roadsP <- roads %>% filter (highway=="motorway" |highway=="primary"|highway=="primary_link" |highway=="trunk") 
roadsP <- roadsP %>% transmute(primary=1)
roadsP_v <- roadsP %>% vect() 
# use popd raster 
dir_pop <- "/Users/floriangollnow/Dropbox/ZDC_project/FEDE/PopulationDensity/"
files_pop <- dir (dir_pop, pattern = ".tif$")
i=1
pop <- rast(file.path (dir_pop, files_pop[i] ))


roadsP_r <- rast (pop) 
roadsP_r <- roadsP_r %>% crop(roadsP_v )


roadsP_r_dist<- distance (roadsP_r_ag)
plot(roadsP_r_dist / 1000)
roadsP_r_dist_dis<- disagg (roadsP_r_dist, fact=2,method='bilinear')
roadsP_r_dist_dis<- disagg (roadsP_r_dist_dis, fact=2,method='bilinear')
roadsP_r_dist_dis<- disagg (roadsP_r_dist_dis, fact=2,method='bilinear')
roadsP_r_dist_dis
#roadsP_r_dist_dis<- disagg (roadsP_r_dist_dis, fact=2,method='bilinear')
plot(roadsP_r_dist_dis / 1000)
writeRaster(roadsP_r_dist_dis,file.path (dir_roads, "test_dist_raster.tif"))




files_pop <- dir (dir_pop, pattern = ".tif$")
# read each population density raster seperately and extract values based on SpatVector derived from sf 
for (i in 1:length(files_pop)){
  print (i)
  print (length(files_pop))
  pop <- rast(file.path (dir_pop, files_pop[i] ))
  points_pop <- terra::extract( pop, points_v, fun=NULL, method='simple')
  if (i==1){
    pop_data <- as_tibble(points_pop)
  }else {
    pop_data <- pop_data %>% left_join(as_tibble(points_pop ), by="ID")
  }
}
