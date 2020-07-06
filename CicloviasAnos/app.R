
library(shiny)
#library(shinymanager)
library(shinyWidgets)
library(sf)
library(leaflet)
library(dplyr)
#library(htmltools)


#bases de dados
CICLOVIAS = readRDS("CicloviasAnos.Rds")# loading the data. It has the timestamp, lon, lat, and the accuracy (size of circles)
#CICLOVIAS$AnoT=factor(CICLOVIAS$AnoT)


#conteúdo da parte de cima do mapa
slider = column(9,shinyWidgets::sliderTextInput(inputId = "Ano", "Ano:", 
                     min(CICLOVIAS$AnoT, na.rm = t),
                     max(CICLOVIAS$AnoT, na.rm = t),
                     selected = "2010",
                     choices = as.character(seq(2001,2020)),
                   # sep = "",
                   # grid = T,
                     animate = animationOptions(interval = 2000),
                     width = "100%"
                      )             
                )


kilometros = column(3, "kilómetros"
                    #inserir aqui a tabela de total km por tipologia
                    )


# Define UI for application that draws a map
# estrutura da página

ui = 
  fluidPage(
    navbarPage("Ciclovias em Lisboa",
               tabPanel("Mapa",
                fluidRow(slider,
                        kilometros
                        ),
  
                tags$style(type = "text/css", "#map {height: calc(100vh - 190px) !important;}"), #mapa com a altura da janela do browser menos as barras de cima
                leafletOutput(outputId = "map")
                                 ),
   tabPanel("GIF",
             h2("GIF animado da evolução da rede ciclável"),
             br(),
             "_work in progress_"),
  
   tabPanel("Sobre",
            h2("texto com coisas"),
            br(),
            "texto com ainda mais coisas"),

   tabPanel("Código",icon = icon("github"),
            a(href = "https://github.com/U-Shift/RedeCiclavel-Lisboa", "Link para o repositório"),  
            br(),
            div("Se detectares erros indica aqui :)")
            )
        
    ) #fecha o navbar 
) #fecha a estrutura do ui


## magia começa aqui ##

server = function(input, output) {

  
  output$map = renderLeaflet({
    leaflet() %>%
      addProviderTiles("CartoDB.Positron", group="mapa")%>%
      addProviderTiles("Esri.WorldImagery", group="satélite")%>%
      fitBounds(-9.25,38.692,-9.06,38.793) %>%       
      addLayersControl(overlayGroups = c("Ciclovias","30+Bici ou Não dedicada","Percurso Ciclo-pedonal"),
                       baseGroups = c("mapa", "satélite"),
                       options = layersControlOptions(collapsed = F))%>%
      hideGroup(c("Percurso Ciclo-pedonal")) %>% 
      addLegend(position = "bottomright", colors = c("#1A7832","#AFD4A0"), 
                labels = c("Ciclovia segregada", "Segemento não dedicado"))
      
      })
  
  observe({
    leafletProxy("map") %>% 
      clearShapes() %>% 
      addMapPane("abaixo", zIndex = 200) %>% # shown below
      addMapPane("acima", zIndex = 300) %>% # shown above
      addPolylines(data = CICLOVIAS[CICLOVIAS$AnoT == input$Ano &
                                      CICLOVIAS$TIPOLOGIA == "Ciclovia segregada", ],
                   color = "#1A7832",
                   weight = 3,
                   opacity = 1,
                   smoothFactor = 1, 
                   options = pathOptions(pane = "acima"),
                   popup = ~DESIGNACAO,
                   group = "Ciclovias") %>% 
      addPolylines(data = CICLOVIAS[CICLOVIAS$AnoT == input$Ano &
                                      CICLOVIAS$TIPOLOGIA == "Nao dedicada", ],
                   color = "#AFD4A0",
                   weight = 2,
                   opacity = 1,
                   smoothFactor = 1, 
                   options = pathOptions(pane = "abaixo"),
                   group = "30+Bici ou Não dedicada")%>%
      addPolylines(data = CICLOVIAS[CICLOVIAS$AnoT == input$Ano &
                                      CICLOVIAS$TIPOLOGIA == "Percurso Ciclo-pedonal", ],
                   color = "#AFD4A0",
                   weight = 1.5,
                   dashArray = 10,
                   opacity = 1,
                   smoothFactor = 1, 
                   options = pathOptions(pane = "abaixo"),
                   group = "Percurso Ciclo-pedonal")
    
  })

}



# Run the application 
shinyApp(ui = ui, server = server)

