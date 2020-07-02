
library(shiny)
library(sf)
library(leaflet)
library(dplyr)


# Define UI for application that draws a map
CICLOVIAS = readRDS("CicloviasAnos.Rds")# loading the data. It has the timestamp, lon, lat, and the accuracy (size of circles)
#CICLOVIAS$AnoT=factor(CICLOVIAS$AnoT)

ui = fluidPage(
  sliderInput(inputId = "Ano", "Ano:", 
              min(CICLOVIAS$AnoT, na.rm = t),
              max(CICLOVIAS$AnoT, na.rm = t),
              value = 2001,
              step = 1,
              width = 1000),
  leafletOutput(outputId = "map",
                height = 520)
)
server = function(input, output) {
  output$map = renderLeaflet({
    leaflet() %>%
      addProviderTiles("CartoDB.Positron", group="mapa")%>%
      addProviderTiles("Esri.WorldImagery", group="satélite")%>%
      addPolylines(data = CICLOVIAS[CICLOVIAS$AnoT == input$Ano &
                                      CICLOVIAS$TIPOLOGIA == "Percurso Ciclo-pedonal", ],
                   color = "#AFD4A0",
                   weight = 1.5,
                   dashArray = 10,
                   opacity = 3,
                   group = "Percurso Ciclo-pedonal") %>% 
      addPolylines(data = CICLOVIAS[CICLOVIAS$AnoT == input$Ano &
                                      CICLOVIAS$TIPOLOGIA == "Nao dedicada", ],
                   color = "#AFD4A0",
                   weight = 2,
                   opacity = 3,
                   group = "30+Bici ou Não dedicada")%>%
      addPolylines(data = CICLOVIAS[CICLOVIAS$AnoT == input$Ano &
                                      CICLOVIAS$TIPOLOGIA == "Ciclovia segregada", ],
                   color = "#1A7832",
                   weight = 2,
                   opacity = 3,
                   group = "Ciclovias")%>%
      addLayersControl(overlayGroups = c("Ciclovias","30+Bici ou Não dedicada","Percurso Ciclo-pedonal"),
                       baseGroups = c("mapa", "satélite"),
                       options = layersControlOptions(collapsed = F))%>%
      addLegend(position = "bottomright", colors = c("#1A7832","#AFD4A0"), 
                labels = c("Ciclovia segregada", "Segemento não dedicado"))
      
      })

    
}
shinyApp(ui, server)

# Run the application 
shinyApp(ui = ui, server = server)

