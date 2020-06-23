Rede Ciclável Liboa - Mapa animado
================

Mapa animado com a evolução da rede ciclável em Lisboa desde 2001 </br> A informação base está disponível no site de geodados da CML: <http://geodados.cm-lisboa.pt/datasets/440b7424a6284e0b9bf11179b95bf8d1_0>

Este repositório contém duas funções:
-------------------------------------

-   GIF com evolução da rede ciclável em Lisboa, desde 20201
-   Mapa interactivo em html com slide para visualizar ao longo dos anos

GIF interactivo
===============

### Peparação dos dados

#### Importar packages

``` r
library(tidyverse)
library(sf)
library(mapview)
```

#### Importar shapefiles Lisboa

``` r
#Limites de Lisboa
LisboaLimite <-st_read("data/Lisboa_limite.gpkg")
LisboaLimite = LisboaLimite[,c(3,5)] %>% st_transform(LisboaLimite,  crs = 4326)
```

#### Importar rede ciclável

``` r
#actualizar para 2020 a partir do server da CML
CicloviasATUAL = st_read("https://opendata.arcgis.com/datasets/440b7424a6284e0b9bf11179b95bf8d1_0.geojson") 
```

    ## Reading layer `Ciclovias' from data source `https://opendata.arcgis.com/datasets/440b7424a6284e0b9bf11179b95bf8d1_0.geojson' using driver `GeoJSON'
    ## Simple feature collection with 684 features and 28 fields
    ## geometry type:  LINESTRING
    ## dimension:      XY
    ## bbox:           xmin: -9.228815 ymin: 38.69188 xmax: -9.090616 ymax: 38.7956
    ## geographic CRS: WGS 84

``` r
#st_write(CicloviasATUAL[,c(4,7,19)], "data/Ciclovias072020.shp") #data deste mês
```

Alterei alguns segmentos no QGIS, principalmente anos que não estão correctos na BD oficial.

``` r
#voltar a importar
Ciclovias <-st_read("data/Ciclovias2020Julho.gpkg")
```

    ## Reading layer `Ciclovias2020Julho' from data source `D:\GIS\Ciclovias_CML\RedeCiclavel-Lisboa\data\Ciclovias2020Julho.gpkg' using driver `GPKG'
    ## Simple feature collection with 199 features and 3 fields
    ## geometry type:  MULTILINESTRING
    ## dimension:      XY
    ## bbox:           xmin: -9.228815 ymin: 38.69188 xmax: -9.091449 ymax: 38.79549
    ## geographic CRS: WGS 84

##### Acertar geometria

``` r
#recalcular geometria
Ciclovias$lenght = st_length(Ciclovias) 
sum(Ciclovias$lenght)
```

    ## 119968.2 [m]

``` r
# calma, há segmentos que foram destruídos entretanto
```

#### Ver num mapa

Todas as ciclovias que existiram

``` r
mapview::mapview(Ciclovias)
```

![](README_files/figure-markdown_github/unnamed-chunk-6-1.png)

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
