# forest_degradation
Data preparation

Extracting values for point locations in MT, PA, RO, Brazil 

## Done
- 0 Prepare point data for data extraction  
- 1/2 Extract [Population](https://www.worldpop.org/geodata/listing?id=77) - some NaNs present.   
- 1/2 Extract Soy Suitability ([GAEZ](https://www.gaez.iiasa.ac.at/), [Aptitude for mechanized crops derived from Soares-Filho et al 2014](https://www.csr.ufmg.br/forestcode/) )  (GAEZ: Values between 1-9, 9: Water,8 not Suitable, 8 Very Marginal, 6 Marginal, 5 Moderate, 4 Medium, 3 Good, 2 High, 1 Very High [] recommending <=4 for suitable)/ Aptitude for Mechanized crop production values between 0 an 2, 0 not aptitude, 1 low aptidude, 2 high aptidude [recomending >=1 for suitable])
- 1/2 [Protected areas](https://www.gov.br/icmbio/pt-br/servicos/geoprocessamento/mapa-tematico-e-dados-geoestatisticos-das-unidades-de-conservacao-federais) YEAR/NA
- 1/2 [Indigenous lands](https://www.gov.br/funai/pt-br/atuacao/terras-indigenas/geoprocessamento-e-mapas)  TRUE/FALSE
- 1/2 Embargoed areas (intersection of [IBAMA](https://servicos.ibama.gov.br/ctf/publico/areasembargadas/ConsultaPublicaAreasEmbargadas.php) list and CAR) embargoStartY/embargoEndY (careful, 3 embargoes are set in the future > 2022)
- 1/2 Incra Settlement [Federal](https://certificacao.incra.gov.br/csv_shp/export_shp.py) and [Reconhecimiento](https://certificacao.incra.gov.br/csv_shp/export_shp.py) 
- 1/2 private land (CAR)
- 1/2 distance to main [roads](https://wiki.openstreetmap.org/wiki/Key:highway)  (motorway, trunk, primary)
- 1/2 distance to secondary [roads](https://wiki.openstreetmap.org/wiki/Key:highway)  (secondary)
- 1/2 distance to any [road](https://wiki.openstreetmap.org/wiki/Key:highway)  (all categories)
- 3 combine data sets

# tbd
- public land  (CAR) (needs to be defined in long dataset as !Car (TRUE/FALSE), !Incra (Year), !PA (Year), !Indigenous (TRUE/FALSE))
