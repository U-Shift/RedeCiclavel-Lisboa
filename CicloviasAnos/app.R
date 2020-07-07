
library(shiny)
library(shinyWidgets)
library(sf)
library(leaflet)
library(dplyr)
library(ggplot2)
library(units)
#library(shinymanager)
#library(htmltools)


#bases de dados
CICLOVIAS = readRDS("CicloviasAnos.Rds") #rede
QUILOMETROS = readRDS("CicloviasKM.Rds") #extensão



#conteúdo das páginas


## sobre

## codigo


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

nada = column(1, offset = 0, style="padding:0px;")

kilometros = column(2, 
                    tags$h4("Extensão da rede"),
                    tags$h5(textOutput("kmsciclovias")),
                    tags$h5(textOutput("kmsoutras"))
                    #converter para tabela?
                    )


# Define UI for application that draws a map
# estrutura da página

ui = 
  fluidPage(
    navbarPage("Ciclovias em Lisboa",
               tabPanel("Mapa",icon = icon("map"),
                fluidRow(slider,
                         nada,
                         kilometros
                         ),
  
                tags$style(type = "text/css", "#map {height: calc(100vh - 190px) !important;}"), #mapa com a altura da janela do browser menos as barras de cima
                leafletOutput(outputId = "map")
                                 ),
   tabPanel("GIF",icon = icon("play-circle"),
            h2("Evolução da rede ciclável em Lisboa"),
            br(),
            fluidRow(column(8, offset = 3,
            img(src="http://web.tecnico.ulisboa.pt/~rosamfelix/gis/contagens/RedeCiclavelLisboa2020.gif", align = "center",height="500px")
            # img(src="pasta/RedeCiclavelLisboa2020.gif", align = "center",height="500px")
                )) #alterar pelo path correcto!
            ),
  
   tabPanel("Gráfico",icon = icon("chart-bar"),
            h2("Extensão das ciclovias por ano"),
            br(),
            fluidRow(column(8, offset = 2,
                 tags$style(type = "text/css", "#grafico {height: calc(100vh - 200px) !important;}"), #altura responsive
                 plotOutput("grafico")
            ))
            ),
   
   tabPanel("Sobre",icon = icon("info"),
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


########## magia começa aqui ###############

server = function(input, output) {

  #mapa
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
                   popup = ~DESIGNACAO,
                   group = "30+Bici ou Não dedicada")%>%
      addPolylines(data = CICLOVIAS[CICLOVIAS$AnoT == input$Ano &
                                      CICLOVIAS$TIPOLOGIA == "Percurso Ciclo-pedonal", ],
                   color = "#AFD4A0",
                   weight = 1.5,
                   dashArray = 10,
                   opacity = 1,
                   smoothFactor = 1, 
                   options = pathOptions(pane = "abaixo"),
                   popup = ~DESIGNACAO,
                   group = "Percurso Ciclo-pedonal")
    
  })
  
  #tabela dos quilómetros
  output$kmsciclovias <- renderText({
    paste0("Ciclovias segregadas: ",
      QUILOMETROS$Kms[QUILOMETROS$AnoT == input$Ano & QUILOMETROS$TIPOLOGIA == "Ciclovia segregada"])
  })
  output$kmsoutras <- renderText({
    paste0("30+Bici ou Não dedicada: ",
           QUILOMETROS$Kms[QUILOMETROS$AnoT == input$Ano & QUILOMETROS$TIPOLOGIA == "Nao dedicada"])
  })
  
  #gráfico
  output$grafico <- renderPlot({
   ggplot(QUILOMETROS[QUILOMETROS$TIPOLOGIA!="Percurso Ciclo-pedonal",],
          aes(factor(AnoT), drop_units(lenght), fill=factor(TIPOLOGIA, levels=c("Nao dedicada","Ciclovia segregada")))
          ) +
      geom_bar(stat="identity") +
      scale_fill_manual(values= c("#AFD4A0","#1A7832"), "Tipologia: ") +
      scale_y_continuous(breaks = seq(0,100,20)) +
      theme_minimal() +
      theme(axis.text.x = element_text(angle=90, vjust = 0.5),
            text = element_text(size = 16),
            legend.position="bottom") +
    labs(x="Ano",
         y="Extensão [km]"
         # title="Extensão da rede ciclável",
         # subtitle="Comprimento da rede ciclável em Lisboa, acumulado por ano"
         )
    })
  
}



# Run the application 
shinyApp(ui = ui, server = server)

