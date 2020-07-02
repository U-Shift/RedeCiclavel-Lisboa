
library(shiny)
#library(shinymanager)
library(sf)
library(leaflet)
library(dplyr)


# Define UI for application that draws a map
CICLOVIAS = readRDS("CicloviasAnos.Rds")# loading the data. It has the timestamp, lon, lat, and the accuracy (size of circles)
#CICLOVIAS$AnoT=factor(CICLOVIAS$AnoT)
#credentials = readRDS("credentials.Rds") #load passwordmatch

ui = fluidPage(
  sliderInput(inputId = "Ano", "Ano:", 
              min(CICLOVIAS$AnoT, na.rm = t),
              max(CICLOVIAS$AnoT, na.rm = t),
              value = 2001,
              step = 1,
              sep = "",
              ticks = F,
              animate = T,
              width = 1000),
  leafletOutput(outputId = "map",
                height = 520)
)

#ui <- secure_app(ui) #para iniciar com password


server = function(input, output) {
  # #login
  #  res_auth <- secure_server(
  #   check_credentials = check_credentials(credentials)
  # )
  # 
  # output$auth_output <- renderPrint({
  #   reactiveValuesToList(res_auth)
  # })
  
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



# Run the application 
shinyApp(ui = ui, server = server)

