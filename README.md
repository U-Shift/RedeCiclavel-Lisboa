Rede Ciclável Liboa - Mapa animado
================
*RFélix*

RedeCiclavel-Lisboa
===================

Mapa animado com a evolução da rede ciclável em Lisboa desde 2001 \#\#\# A informação base está disponível no site de geodados da CML: <http://geodados.cm-lisboa.pt/datasets/440b7424a6284e0b9bf11179b95bf8d1_0>

Este repositório contém duas funções:
-------------------------------------

-   GIF com evolução da rede ciclável em Lisboa, desde 20201
-   Mapa interactivo em html com slide para visualizar ao longo dos anos

GIF interactivo
===============

### Peparação dos dados

Importar packages

``` r
library(tidyverse)
```

    ## -- Attaching packages --------------------------------------------- tidyverse 1.3.0 --

    ## v ggplot2 3.3.0     v purrr   0.3.4
    ## v tibble  2.1.3     v dplyr   0.8.5
    ## v tidyr   1.0.2     v stringr 1.4.0
    ## v readr   1.3.1     v forcats 0.4.0

    ## Warning: package 'ggplot2' was built under R version 3.6.3

    ## Warning: package 'purrr' was built under R version 3.6.3

    ## Warning: package 'dplyr' was built under R version 3.6.3

    ## -- Conflicts ------------------------------------------------ tidyverse_conflicts() --
    ## x dplyr::filter() masks stats::filter()
    ## x dplyr::lag()    masks stats::lag()

``` r
library(sf)
```

    ## Warning: package 'sf' was built under R version 3.6.3

    ## Linking to GEOS 3.8.0, GDAL 3.0.4, PROJ 6.3.1

``` r
library(mapview)
```

    ## Warning: package 'mapview' was built under R version 3.6.3

Importar shapefiles Lisboa

``` r
#Limites de Lisboa
LisboaLimite <-st_read("data/Lisboa_limite.gpkg")
```

    ## Reading layer `Lisboa_limite2' from data source `D:\GIS\Ciclovias_CML\RedeCiclavel-Lisboa\data\Lisboa_limite.gpkg' using driver `GPKG'
    ## Simple feature collection with 1 feature and 4 fields
    ## geometry type:  MULTIPOLYGON
    ## dimension:      XY
    ## bbox:           xmin: -95412.91 ymin: -107892 xmax: -83126.32 ymax: -96313.35
    ## projected CRS:  ETRS89 / Portugal TM06

``` r
st_transform(LisboaLimite,  crs = 4326)
```

    ## Simple feature collection with 1 feature and 4 fields
    ## geometry type:  MULTIPOLYGON
    ## dimension:      XY
    ## bbox:           xmin: -9.229836 ymin: 38.69141 xmax: -9.089955 ymax: 38.79676
    ## geographic CRS: WGS 84
    ##   DICOFRE Freguesia Concelho Distrito                           geom
    ## 1  110660   Estrela   LISBOA   LISBOA MULTIPOLYGON (((-9.187505 3...

Importar rede ciclável

``` r
CicloviasATUAL = st_read("https://opendata.arcgis.com/datasets/440b7424a6284e0b9bf11179b95bf8d1_0.geojson") #actualizar para 2020 a partir do server da CML
```

    ## Reading layer `Ciclovias' from data source `https://opendata.arcgis.com/datasets/440b7424a6284e0b9bf11179b95bf8d1_0.geojson' using driver `GeoJSON'
    ## Simple feature collection with 684 features and 28 fields
    ## geometry type:  LINESTRING
    ## dimension:      XY
    ## bbox:           xmin: -9.228815 ymin: 38.69188 xmax: -9.090616 ymax: 38.7956
    ## geographic CRS: WGS 84

``` r
#st_write(CicloviasATUAL, "data/Ciclovias072020.shp")

#alterei alguns segmentos no QGIS, principalmente anos que não estão correctos na BD oficial
Ciclovias <-st_read("data/Ciclovias2020Julho.gpkg") #voltar a importar
```

    ## Reading layer `Ciclovias2020Julho' from data source `D:\GIS\Ciclovias_CML\RedeCiclavel-Lisboa\data\Ciclovias2020Julho.gpkg' using driver `GPKG'
    ## Simple feature collection with 199 features and 3 fields
    ## geometry type:  MULTILINESTRING
    ## dimension:      XY
    ## bbox:           xmin: -9.228815 ymin: 38.69188 xmax: -9.091449 ymax: 38.79549
    ## geographic CRS: WGS 84

Acertar geometria

``` r
sum(Ciclovias$lenght, na.rm=T)
```

    ## [1] 146806.3

``` r
#(calma, há segmentos que foram destruídos entretanto)

#recalcular geometria
Ciclovias$lenght = st_length(Ciclovias) 
sum(Ciclovias$lenght) #acaba por ter 119,9 km
```

    ## 119968.2 [m]

<!-- #ver num mapa -->
<!-- mapview(Ciclovias) #todas -->
<!-- ## Reclassificar ciclovias em segregadas (uni e bi-direccionais) e banalizadas (30+bici, zona de coexistência) -->
<!-- #meter tracejado o que não é segregado -->
<!-- Ciclovias$TIPOLOGIA = as.character(Ciclovias$TIPOLOGIA) -->
<!-- table(Ciclovias$TIPOLOGIA) -->
<!-- Ciclovias$TIPOLOGIA[Ciclovias$TIPOLOGIA=="Faixa Ciclavel (Contraflow)"] = "Ciclovia segregada" -->
<!-- Ciclovias$TIPOLOGIA[Ciclovias$TIPOLOGIA=="Faixa Ciclavel"] = "Ciclovia segregada" -->
<!-- Ciclovias$TIPOLOGIA[Ciclovias$TIPOLOGIA=="Pista Ciclavel Bidirecional"] = "Ciclovia segregada" -->
<!-- Ciclovias$TIPOLOGIA[Ciclovias$TIPOLOGIA=="Pista Ciclavel Unidirecional"] = "Ciclovia segregada" -->
<!-- Ciclovias$TIPOLOGIA[Ciclovias$TIPOLOGIA=="Ponte"] = "Ciclovia segregada" -->
<!-- Ciclovias$TIPOLOGIA[Ciclovias$TIPOLOGIA=="Zona de Coexistencia"] = "30+Bici" -->
<!-- Ciclovias$TIPOLOGIA[Ciclovias$TIPOLOGIA=="Bus+Bici"] = "30+Bici" -->
<!-- table(Ciclovias$TIPOLOGIA)  -->
Including Plots
---------------

You can also embed plots, for example:

![](README_files/figure-markdown_github/pressure-1.png)

Note that the `echo = FALSE` parameter was added to the code chunk to prevent printing of the R code that generated the plot.
