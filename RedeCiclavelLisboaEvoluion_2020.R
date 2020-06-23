#Definir o workspace
getwd()
#setwd("D:/GIS/Ciclovias_CML/RedeCiclavel-Lisboa")

library(tidyverse)
library(sf)
library(mapview)


### importar shapefiles Lisboa e Ciclovias ###
#Importar ficheiros shapefile
LisboaLimite <-st_read("data/Lisboa_limite.gpkg")
st_transform(LisboaLimite,  crs = 4326)

#actualizar para 2020 a partir do server da CML
CicloviasATUAL = st_read("https://opendata.arcgis.com/datasets/440b7424a6284e0b9bf11179b95bf8d1_0.geojson")
#st_write(CicloviasATUAL, "data/Ciclovias072020.shp")
#alterei alguns segmentos no QGIS, principalmente anos que não estão correctos na BD oficial
Ciclovias <-st_read("data/Ciclovias2020Julho.gpkg")


#acertar geometria
sum(Ciclovias$lenght, na.rm=T) #têm 146,8 km (calma, há segmetnos que foram destruídos entretanto)
Ciclovias$lenght = st_length(Ciclovias) #recalcular geometria
sum(Ciclovias$lenght) #acaba por ter 119,9 km

#ver num mapa
mapview(Ciclovias) #todas

## Reclassificar ciclovias em segregadas (uni e bi-direccionais) e banalizadas (30+bici, zona de coexistência)
#meter tracejado o que não é segregado
Ciclovias$TIPOLOGIA = as.character(Ciclovias$TIPOLOGIA)
table(Ciclovias$TIPOLOGIA)
Ciclovias$TIPOLOGIA[Ciclovias$TIPOLOGIA=="Faixa Ciclavel (Contraflow)"] = "Ciclovia segregada"
Ciclovias$TIPOLOGIA[Ciclovias$TIPOLOGIA=="Faixa Ciclavel"] = "Ciclovia segregada"
Ciclovias$TIPOLOGIA[Ciclovias$TIPOLOGIA=="Pista Ciclavel Bidirecional"] = "Ciclovia segregada"
Ciclovias$TIPOLOGIA[Ciclovias$TIPOLOGIA=="Pista Ciclavel Unidirecional"] = "Ciclovia segregada"
Ciclovias$TIPOLOGIA[Ciclovias$TIPOLOGIA=="Ponte"] = "Ciclovia segregada"
Ciclovias$TIPOLOGIA[Ciclovias$TIPOLOGIA=="Zona de Coexistencia"] = "30+Bici"
Ciclovias$TIPOLOGIA[Ciclovias$TIPOLOGIA=="Bus+Bici"] = "30+Bici"
table(Ciclovias$TIPOLOGIA) 




