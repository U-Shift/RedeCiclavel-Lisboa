Rede Ciclável Liboa - Mapa animado
================

Mapa animado com a evolução da rede ciclável em Lisboa desde 2001 </br>

A informação base está disponível no site de geodados da CML:
<https://geodados-cml.hub.arcgis.com/datasets/rede-cicl%C3%A1vel/>

### Este repositório contém três funções:

- Processamento dos dados disponibilizados pela CML
- GIF com evolução da rede ciclável em Lisboa, desde 2001 -
  [ir](https://github.com/U-Shift/RedeCiclavel-Lisboa#gif-com-evolução)
- Mapa interactivo em html com slide para visualizar evolução longo dos
  anos -
  [ir](https://github.com/U-Shift/RedeCiclavel-Lisboa#mapa-interactivo-por-anos)

# Processamento dos dados

#### Importar rede ciclável

``` r
#actualizar para 2022 a partir do server da CML
CicloviasATUAL = st_read("https://services.arcgis.com/1dSrzEWVQn5kHHyK/arcgis/rest/services/Ciclovias/FeatureServer/0/query?outFields=*&where=1%3D1&f=geojson") 
```

#### Processo

O processo envolve limpeza, remoção de repetidos, reclassifiação de
tipologia, tratamento especial de segmentos que foram alterados ao longo
dos anos.

> Última atualização a 12.Dezembro.2022

## GIF com evolução

[Ver
código](https://github.com/U-Shift/RedeCiclavel-Lisboa/blob/master/GIFciclovias.Rmd),
usando a informação processada aqui.  
Resultado em
[RedeCiclavelLisboa2022.gif](http://shiny.rosafelix.bike/ciclovias/gif/RedeCiclavelLisboa2022.gif)

## Mapa interactivo por anos

[ver
código](https://github.com/U-Shift/RedeCiclavel-Lisboa/blob/master/CicloviasAnos/app.R),
usando a informação processada aqui.  
Resultado em
[shiny.rosafelix.bike/ciclovias](http://shiny.rosafelix.bike/ciclovias)
