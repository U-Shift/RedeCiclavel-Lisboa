
library(shiny)
library(shinyWidgets)
library(sf)
library(leaflet)
library(htmltools)
library(dplyr)
library(ggplot2)
library(plotly)
library(units)
library(rmarkdown)
library(knitr)
#library(htmltools)


#bases de dados
CICLOVIAS = readRDS("CicloviasAnos.Rds") #rede
QUILOMETROS = readRDS("CicloviasKM.Rds") #extensão

addResourcePath(prefix = "gif", directoryPath = "/srv/shiny-server/ciclovias/gif")
addResourcePath(prefix = "info", directoryPath = "/srv/shiny-server/ciclovias/info")

# conteúdo da parte de cima do mapa
slider = column(9,shinyWidgets::sliderTextInput(inputId = "Ano", "Ano:", 
                     min(CICLOVIAS$AnoT, na.rm = t),
                     max(CICLOVIAS$AnoT, na.rm = t),
                     selected = "2013",
                     choices = as.character(seq(2001,2024)),
                   # sep = "",
                   # grid = T,
                     animate = animationOptions(interval = 2002),
                     width = "100%"
                      )             
                )

nada = column(1, offset = 0, style="padding:0px;")

kilometros = column(2, 
                    tags$h4("Extensão da rede"),
                    tags$h5(textOutput("kmsciclovias")),
                    tags$h5(textOutput("kmsoutras")),
                    tags$h5(textOutput("kmspedonal"))
                    #converter para tabela?
                    )
  


#criar o rmd
# rmarkdown::render(input = "info/preparacao.Rmd",
#                   output_format = "html_document",
#                   output_file = "/srv/shiny-server/ciclovias/info/preparacao.html")
# xml2::write_html(rvest::html_node(xml2::read_html("/srv/shiny-server/ciclovias/info/preparacao.html"), "body"), file = "/srv/shiny-server/ciclovias/info/preparacao2.html")

# Define UI for application that draws a map
# estrutura da página

ui = 
  fluidPage(
    tags$head(
      tags$script(src = 'highlight.pack.js'),
      tags$script(src = 'shiny-showcase.js'),
      tags$link(rel = "stylesheet", type = "text/css", href = "rstudio.css")
    ),
    
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
            img(src = "gif/RedeCiclavelLisboa2024.gif", align = "center",height="500px") 
            #tags$video(src = "gif/RedeCiclavelLisboa2020.mp4", align = "center",height="500px")
                ))
            ),
  
   tabPanel("Gráfico",icon = icon("chart-bar"),
            h2("Extensão das ciclovias por ano"),
            br(),
            fluidRow(column(8, offset = 2,
                 tags$style(type = "text/css", "#grafico {height: calc(100vh - 200px) !important;}"), #altura responsive
                 plotlyOutput("grafico")
            ))
            ),
   
   tabPanel("Sobre",icon = icon("info"),
            includeMarkdown("info/sobre.Rmd")
            ),
   
   navbarMenu("Código",icon = icon("github"),
          
              tabPanel("Processamento dos dados",
                     #  uiOutput("preparacao")
                       includeMarkdown("info/preparacao2024.Rmd")
                     # includeHTML("info/preparacao2.html")
                      ),
              
              tabPanel("GIF animado",
                       includeMarkdown("info/GIFciclovias.Rmd")
                      ),
              
              tabPanel("Github",
                      h1(a("Repositório de código aberto", href = "https://github.com/U-Shift/RedeCiclavel-Lisboa", target="_blank")),  
                      br(),br(),
                      div("Contribui para melhorar este site."),
                      div("Se detectares erros indica aqui :)")
                     )
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
                labels = c("Ciclovia dedicada", "Segemento não dedicado"))       
      })
  
  observe({
    leafletProxy("map") %>% 
      clearShapes() %>% 
      addMapPane("abaixo", zIndex = 200) %>% # shown below
      addMapPane("acima", zIndex = 300) %>% # shown above
      addPolylines(data = CICLOVIAS[CICLOVIAS$AnoT == input$Ano &
                                      CICLOVIAS$TIPOLOGIA == "Ciclovia dedicada", ],
                   color = "#1A7832",
                   weight = 3,
                   opacity = 1,
                   smoothFactor = 1, 
                   options = pathOptions(pane = "acima"),
                   label = ~DESIGNACAO,
                   popup = sprintf("<strong>%s</strong><br>%s<br>Ano: %s<br>Extensão: %s metros", # ver o pq do %s ou %g: https://rdrr.io/r/base/sprintf.html
                                   CICLOVIAS$DESIGNACAO[CICLOVIAS$AnoT == input$Ano & CICLOVIAS$TIPOLOGIA == "Ciclovia dedicada"],
                                   CICLOVIAS$TIPOLOGIA[CICLOVIAS$AnoT == input$Ano & CICLOVIAS$TIPOLOGIA == "Ciclovia dedicada"],
                                   CICLOVIAS$ANO[CICLOVIAS$AnoT == input$Ano & CICLOVIAS$TIPOLOGIA == "Ciclovia dedicada"],
                                   round(CICLOVIAS$lenght[CICLOVIAS$AnoT == input$Ano & CICLOVIAS$TIPOLOGIA == "Ciclovia dedicada"] *1000)) |> #em metros 
                     lapply(htmltools::HTML),
                   group = "Ciclovias") %>% 
      addPolylines(data = CICLOVIAS[CICLOVIAS$AnoT == input$Ano &
                                      CICLOVIAS$TIPOLOGIA == "Nao dedicada", ],
                   color = "#AFD4A0",
                   weight = 2,
                   opacity = 1,
                   smoothFactor = 1, 
                   options = pathOptions(pane = "abaixo"),
                   label = ~DESIGNACAO,
                   popup = sprintf("<strong>%s</strong><br>%s<br>Ano: %s<br>Extensão: %s metros", # ver o pq do %s ou %g: https://rdrr.io/r/base/sprintf.html
                                   CICLOVIAS$DESIGNACAO[CICLOVIAS$AnoT == input$Ano & CICLOVIAS$TIPOLOGIA == "Nao dedicada"],
                                   CICLOVIAS$TIPOLOGIA[CICLOVIAS$AnoT == input$Ano & CICLOVIAS$TIPOLOGIA == "Nao dedicada"],
                                   CICLOVIAS$ANO[CICLOVIAS$AnoT == input$Ano & CICLOVIAS$TIPOLOGIA == "Nao dedicada"],
                                   round(CICLOVIAS$lenght[CICLOVIAS$AnoT == input$Ano & CICLOVIAS$TIPOLOGIA == "Nao dedicada"] *1000)) |> #em metros 
                     lapply(htmltools::HTML),
                   group = "30+Bici ou Não dedicada")%>%
      addPolylines(data = CICLOVIAS[CICLOVIAS$AnoT == input$Ano &
                                      CICLOVIAS$TIPOLOGIA == "Percurso Ciclo-pedonal", ],
                   color = "#AFD4A0",
                   weight = 1.5,
                   dashArray = 10,
                   opacity = 1,
                   smoothFactor = 1, 
                   options = pathOptions(pane = "abaixo"),
                   label = ~DESIGNACAO,
                   popup = sprintf("<strong>%s</strong><br>%s<br>Ano: %s<br>Extensão: %s metros", # ver o pq do %s ou %g: https://rdrr.io/r/base/sprintf.html
                                   CICLOVIAS$DESIGNACAO[CICLOVIAS$AnoT == input$Ano & CICLOVIAS$TIPOLOGIA == "Percurso Ciclo-pedonal"],
                                   CICLOVIAS$TIPOLOGIA[CICLOVIAS$AnoT == input$Ano & CICLOVIAS$TIPOLOGIA == "Percurso Ciclo-pedonal"],
                                   CICLOVIAS$ANO[CICLOVIAS$AnoT == input$Ano & CICLOVIAS$TIPOLOGIA == "Percurso Ciclo-pedonal"],
                                   round(CICLOVIAS$lenght[CICLOVIAS$AnoT == input$Ano & CICLOVIAS$TIPOLOGIA == "Percurso Ciclo-pedonal"] *1000)) |> #em metros 
                     lapply(htmltools::HTML),
                   group = "Percurso Ciclo-pedonal")
    
  })
  
  #tabela dos quilómetros
  output$kmsciclovias <- renderText({
    paste0("Ciclovias dedicadas: ",
      QUILOMETROS$Kms[QUILOMETROS$AnoT == input$Ano & QUILOMETROS$TIPOLOGIA == "Ciclovia dedicada"])
  })
  output$kmsoutras <- renderText({
    paste0("30+Bici ou Não dedicada: ",
           QUILOMETROS$Kms[QUILOMETROS$AnoT == input$Ano & QUILOMETROS$TIPOLOGIA == "Nao dedicada"])
  })
  output$kmspedonal <- renderText({
    paste0("Ciclo-pedonal: ",
           QUILOMETROS$Kms[QUILOMETROS$AnoT == input$Ano & QUILOMETROS$TIPOLOGIA == "Percurso Ciclo-pedonal"])
  })
  
  #gráfico
  grafico = ggplot(QUILOMETROS[QUILOMETROS$TIPOLOGIA!="Percurso Ciclo-pedonal" & QUILOMETROS$Kms!="0 km",],
          aes(factor(AnoT), drop_units(lenght), fill=factor(TIPOLOGIA, levels=c("Nao dedicada","Ciclovia dedicada")))
          ) +
      geom_bar(stat="identity") +
      guides(fill=guide_legend(reverse=TRUE), colour=guide_legend(reverse=TRUE)) +
      scale_fill_manual(values= c("#AFD4A0","#1A7832"), "Tipologia: ") +
      scale_y_continuous(breaks = seq(0,160,20)) +
      theme_minimal() +
      theme(axis.text.x = element_text(angle=90, vjust = 0.5),
            text = element_text(size = 16))+
    labs(x="Ano",
         y="Extensão [km]"
         # title="Extensão da rede ciclável",
         # subtitle="Comprimento da rede ciclável em Lisboa, acumulado por ano"
         )
  grafico = ggplotly(grafico)  %>%
    layout(legend = list(orientation = "h", y=1.1, x=0.05,  traceorder = "reversed"),
           hovermode = "x") %>% #para aparecer legenda logo em ambos
    style(hoverinfo = "y")
  output$grafico <- renderPlotly({grafico
   
    })
  
  #markdown dos códigos
  # output$preparacao <- renderUI({
  #   shiny::renderUI(includeHTML("/srv/shiny-server/ciclovias/info/preparacao2.html"))
  #   })
}



# Run the application 
shinyApp(ui = ui, server = server)

