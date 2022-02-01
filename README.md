# forest_degradation
## To do:
 - combine datasets



## Done
- Prepare points data for data extraction  
- Extract [Population](https://www.worldpop.org/geodata/listing?id=77) - some NaNs present.   
- Extract Soy Suitability ([GAEZ](https://www.gaez.iiasa.ac.at/), [Aptitude for mechanized crops derived from Soares-Filho et al 2014](https://www.csr.ufmg.br/forestcode/) )  (GAEZ: Values between 1-9, 9: Water,8 not Suitable, 8 Very Marginal, 6 Marginal, 5 Moderate, 4 Medium, 3 Good, 2 High, 1 Very High [] recommending <=4 for suitable)/ Aptidue for Mechanized crop production values between 0 an 2, 0 not aptidute, 1 low aptidude, 2 high aptidude [recomending >=1 for suitable])
- [Protected areas](https://www.gov.br/icmbio/pt-br/servicos/geoprocessamento/mapa-tematico-e-dados-geoestatisticos-das-unidades-de-conservacao-federais) YEAR/NA
- [Indigenous lands](https://www.gov.br/funai/pt-br/atuacao/terras-indigenas/geoprocessamento-e-mapas)  TRUE/FALSE
- Embargoed areas (intersection of [IBAMA](https://servicos.ibama.gov.br/ctf/publico/areasembargadas/ConsultaPublicaAreasEmbargadas.php) list and CAR) embargoStartY/embargoEndY
- public land  (CAR)
- private land (CAR)
- distance to main [roads](https://wiki.openstreetmap.org/wiki/Key:highway)  (motorway, trunk, primary)
- distance to secondary [roads](https://wiki.openstreetmap.org/wiki/Key:highway)  (secondary)
- distance to any [road](https://wiki.openstreetmap.org/wiki/Key:highway)  (all categories)

