library (tidyverse)
library (sf)
library(terra)

#extracting population density data for each point between 2000 and 2020 using terra package

dir_points <- "/Users/floriangollnow/Dropbox/ZDC_project/FEDE/Points"
dir_pop <- "/Users/floriangollnow/Dropbox/ZDC_project/FEDE/PopulationDensity/"

points <- read_rds (file.path (dir_points, "points_row_sf.rds")) 
points <- points %>% mutate (ID=row+1)
points_v <- points %>% vect() 


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

#View(pop_data)
# combine output with sf point file based on row numbers starting at 1 (ID column)
points_data <- points %>% left_join(pop_data, by="ID")
write_rds(points_data, file.path (dir_pop, "population_sf.rds"))
