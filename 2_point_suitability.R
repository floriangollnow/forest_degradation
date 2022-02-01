library (tidyverse)
library (sf)
library(terra)


dir_points <- "/Users/floriangollnow/Dropbox/ZDC_project/FEDE/Points"
dir_gaez <- "/Users/floriangollnow/Dropbox/ZDC_project/FEDE/suitability/GAEZ"
dir_apt <- "/Users/floriangollnow/Dropbox/ZDC_project/FEDE/suitability/MechanizedCrop/"
dir_out <- "/Users/floriangollnow/Dropbox/ZDC_project/FEDE/suitability"

gaez <- rast (file.path(dir_gaez,"GAEZ_SoySuitability.tif") )
apt <- rast (file.path(dir_apt,"apt.tif")) # be aware of the different projection

  
points <- read_rds (file.path (dir_points, "points_row_sf.rds")) 
points <- points %>% mutate (ID=row+1)
points_v <- points %>% vect() 
points_v_2 <- points %>% st_transform (crs=crs(apt, proj=T)) %>% vect() # use same projectoion asn apt raster


gaez <- rast (file.path(dir_gaez,"GAEZ_SoySuitability.tif") )
apt <- rast (file.path(dir_apt,"apt.tif"))

points_gaez<- terra::extract( gaez, points_v, fun=NULL, method='simple')
points_apt <- terra::extract( apt, points_v_2, fun=NULL, method='simple')

points_suit <- as_tibble(points_gaez) %>% left_join(as_tibble(points_apt), by="ID")
points_suit 
summary (points_suit)
unique(points_suit$apt)
points_suit <- points_suit %>% rename(MCropSuit = apt)

points_data <- points %>% left_join(points_suit, by="ID")

write_rds(points_data, file.path (dir_out, "suitability_sf.rds"))
