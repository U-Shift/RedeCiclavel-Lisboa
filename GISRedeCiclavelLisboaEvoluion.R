#Definir o workspace
getwd()
#setwd("D:/GIS/Ciclovias_CML/RedeCiclavel-Lisboa")

library(tidyverse)
library(sf)
#library(cartography)
library(mapview)

library(readxl)
library(reshape2)
library(ggthemes)
library(RColorBrewer)
library(ggmap)
library(maptools)
library(rgeos)
library(ggthemes)
library(purrr)


### importar shapefiles Lisboa e Ciclovias###
#Importar ficheiros shapefile
LisboaLimite <-st_read("data/Lisboa_limite.gpkg")
st_transform(LisboaLimite,  crs = 4326)
# attr(LisboaLimite, "sf_column") = "geometry"
# colnames(LisboaLimite)[colnames(LisboaLimite)=="geom"] <- "geometry"
# st_write(LisboaLimite, "data/Lisboa_limitegeo.gpkg", append=F)
# LisboaLimitegeo = st_read("data/Lisboa_limitegeo.gpkg")

Ciclovias <-st_read("data/CicloviasOld.shp")
mapview(Ciclovias)
sum(Ciclovias$lenght)

#actualizar para 2020 a partir do server da CML
Ciclovias2020 = st_read("https://opendata.arcgis.com/datasets/440b7424a6284e0b9bf11179b95bf8d1_0.geojson")
#Ciclovias2020 <-st_read("data/Ciclovias2020.Rds")
st_write(Ciclovias2020, "Ciclovias2020.shp")

#meter tracejado o que não é segregado
Ciclovias$TIPOLOGIA = as.character(Ciclovias$TIPOLOGIA)
table(Ciclovias$TIPOLOGIA)
Ciclovias$TIPOLOGIA[Ciclovias$TIPOLOGIA=="Faixa Ciclavel (Contraflow)"] = "Ciclovia segregada"
Ciclovias$TIPOLOGIA[Ciclovias$TIPOLOGIA=="Faixa Ciclavel"] = "Ciclovia segregada"
Ciclovias$TIPOLOGIA[Ciclovias$TIPOLOGIA=="Pista Ciclavel Bidirecional"] = "Ciclovia segregada"
Ciclovias$TIPOLOGIA[Ciclovias$TIPOLOGIA=="Pista Ciclavel Unidirecional"] = "Ciclovia segregada"
Ciclovias$TIPOLOGIA[Ciclovias$TIPOLOGIA=="Zona de Coexistencia"] = "30+Bici"
Ciclovias$TIPOLOGIA[Ciclovias$TIPOLOGIA=="Bus+Bici"] = "30+Bici"
Ciclovias= Ciclovias[Ciclovias$TIPOLOGIA!="Ponte",]

#Ciclovias$TIPOLOGIA[Ciclovias$OBJECTID==2142] = "Ciclovia segregada" #parque urbano vale da montanha
#Ciclovias = Ciclovias %>% group_by(DESIGNACAO, TIPOLOGIA, ANO) %>% summarise(do_union=T) # nao tem o nome
Ciclovias$lenght = st_length(Ciclovias)
sum(Ciclovias$lenght)



#ficar só com as segregadas e 30+bici
Ciclovias2020$TIPOLOGIA = as.character(Ciclovias2020$TIPOLOGIA)
table(Ciclovias2020$TIPOLOGIA)
Ciclovias2020$TIPOLOGIA[Ciclovias2020$TIPOLOGIA=="Faixas Cicláveis ou Contrafluxos"] = "Ciclovia segregada"
Ciclovias2020$TIPOLOGIA[Ciclovias2020$TIPOLOGIA=="Pista Ciclável Bidirecional"] = "Ciclovia segregada"
Ciclovias2020$TIPOLOGIA[Ciclovias2020$TIPOLOGIA=="Pistas Cicláveis Unidirecionais"] = "Ciclovia segregada"
Ciclovias2020$TIPOLOGIA[Ciclovias2020$TIPOLOGIA=="Zona de Coexistência"] = "30+Bici"
Ciclovias2020= Ciclovias2020[Ciclovias2020$TIPOLOGIA!="Trilho",]
Ciclovias2020= Ciclovias2020[Ciclovias2020$TIPOLOGIA!="Percurso Ciclo-pedonal",]
Ciclovias2020$TIPOLOGIA[Ciclovias2020$OBJECTID==2142] = "Ciclovia segregada" #parque urbano vale da montanha
Ciclovias2020 = Ciclovias2020 %>% group_by(DESIGNACAO, TIPOLOGIA, ANO) %>% summarise(do_union=T)
Ciclovias2020$lenght = st_length(Ciclovias2020)
sum(Ciclovias2020$lenght)
Ciclovias2020nome = Ciclovias2020
#Ciclovias2020 = Ciclovias2020[,c(2,4)]

#mostrar num mapa interactivo
mapview(Ciclovias2020, zcol="TIPOLOGIA", color = greens, lwd=1.5, hide=T, legend=F) +
  mapview(Ciclovias, zcol="TIPOLOGIA", color = greens, lwd=1.5, hide=T, legend=T)

#alguma coisa está mal, porque em 2020 só mostra 96,2km e em 2018 mostra 92,6km


#adicionar ano acumulado
Ciclovias$AnoT <- Ciclovias$Ano
Cic01 <- filter(Ciclovias,AnoT=="2001")
Cic01$AnoT <- "2001"
Cic02<-Cic01
Cic02$AnoT <- "2002"
Cic03 <- rbind(Cic02,filter(Ciclovias,AnoT=="2003"))
Cic03$AnoT <- "2003"
Cic03 <- Cic03[-c(4,5),] #remover corte do campo grande (construção do estádio Alvalade)
Cic04<-Cic03
Cic04$AnoT <- "2004"
Cic05 <- rbind(Cic04,filter(Ciclovias,AnoT=="2005"))
Cic05$AnoT <- "2005"
Cic06<-Cic05
Cic06$AnoT <- "2006"
Cic07<-Cic06
Cic07$AnoT <- "2007"
Cic08 <- rbind(Cic07,filter(Ciclovias,AnoT=="2008"))
Cic08$AnoT <- "2008"
Cic09 <- rbind(Cic08,filter(Ciclovias,AnoT=="2009"))
Cic09$AnoT <- "2009"
Cic10 <- rbind(Cic09,filter(Ciclovias,AnoT=="2010"))
Cic10$AnoT <- "2010"
Cic11 <- rbind(Cic10,filter(Ciclovias,AnoT=="2011"))
Cic11$AnoT <- "2011"
Cic12 <- rbind(Cic11,filter(Ciclovias,AnoT=="2012"))
Cic12$AnoT <- "2012"
Cic13 <- rbind(Cic12,filter(Ciclovias,AnoT=="2013"))
Cic13$AnoT <- "2013"
Cic13 <- Cic13[-c(62),] #substituiçao do bici+bus da avenida da liberdade pelas laterais
Cic14 <- rbind(Cic13,filter(Ciclovias,AnoT=="2014"))
Cic14$AnoT <- "2014"
Cic15<-Cic14
Cic15$AnoT <- "2015"
Cic16 <- rbind(Cic15,filter(Ciclovias,AnoT=="2016"))
Cic16$AnoT <- "2016"
Cic17 <- rbind(Cic16,filter(Ciclovias,AnoT=="2017"))
Cic17$AnoT <- "2017"
Cic18 <- rbind(Cic17,filter(Ciclovias,AnoT=="2018"))
Cic18$AnoT <- "2018"


# 
# listaAnos = seq(1:20)+2000
# nomeAnos = paste0("Ciclo",listaAnos)
# 
# function(){
#   for (i in listaAnos){
#     TABELA = Ciclovias %>% subset(AnoT=="i") %>% rbind(listaAnos[i-1]) %>% arrange(Ano)
#   }
# }
#   
# for (i in 2001:2020){
#   Ciclovias %>% subset(AnoT=="i") %>% rbind(Cic02) %>% arrange(Ano)
#   
# }
#   setNames(
#     lapply(2001:2020, function(i) make_df(i,i)),
#     paste0("Ciclo", 2001:2020))
# 
# 
# Cic01 = Ciclovias %>% subset(AnoT=="2001")
# Cic02 = Cic01
# Cic02$AnoT = "2002" #não se passou nada
# Cic03 = Ciclovias %>% subset(AnoT=="2003") %>% rbind(Cic02) %>% arrange(Ano)
# Cic03$AnoT = "2003"
# 
# make_df <- function(n,var) {data.frame( a=(1:n)+var,b=(1:n)-var,c=(1:n)/var) }
# 
# mylist <- setNames( 
#   lapply(1:100, function(n) make_df(n,n)) ,  # the dataframes
#   paste0("d_", 1:100))   # the names for access



#Todos em que houve alteração
Ciclovias2018<- rbind(Cic01,Cic03,Cic05,Cic08,Cic09,Cic10,Cic11,Cic12,Cic13,Cic14,Cic16,Cic17,Cic18) #Tabela final
#Adicionar anos nulos
Ciclovias2018T<- rbind(Cic01,Cic02,Cic03,Cic04,Cic05,Cic06,Cic07,Cic08,Cic09,Cic10,Cic11,Cic12,Cic13,Cic14,Cic15,Cic16,Cic17,Cic18) #Tabela final

#remover o que não interessa
rm(Cic01,Cic02,Cic03,Cic04,Cic05,Cic06,Cic07,Cic08,Cic09,
   Cic10,Cic11,Cic12,Cic13,Cic14,Cic15,Cic16,Cic17,Cic18) 


# #Agrupar anos intervalos, por mandatos
# Ciclovias2018$Anos <- "2001 - 2008"
# Ciclovias2018$Anos[Ciclovias2018$AnoT == "2009"] <- "2009 - 2012"
# Ciclovias2018$Anos[Ciclovias2018$AnoT == "2010"] <- "2009 - 2012"
# Ciclovias2018$Anos[Ciclovias2018$AnoT == "2011"] <- "2009 - 2012"
# Ciclovias2018$Anos[Ciclovias2018$AnoT == "2012"] <- "2009 - 2012"
# Ciclovias2018$Anos[Ciclovias2018$AnoT == "2013"] <- "2013 - 2016"
# Ciclovias2018$Anos[Ciclovias2018$AnoT == "2014"] <- "2013 - 2016"
# Ciclovias2018$Anos[Ciclovias2018$AnoT == "2016"] <- "2013 - 2016"
# Ciclovias2018$Anos[Ciclovias2018$AnoT == "2017"] <- "2017 - 2018"
# Ciclovias2018$Anos[Ciclovias2018$AnoT == "2018"] <- "2017 - 2018"

#Adicionar campo com extensão da rede acumulada
CicloviasKM <-Ciclovias2018T[,c(2,4)]
st_geometry(CicloviasKM) <- NULL
CicloviasKM <-group_by(CicloviasKM,AnoT)
CicloviasKM <-summarise_at(CicloviasKM,c(1), sum, na.rm=TRUE)
CicloviasKM$Km <- round(CicloviasKM$lenght/1000,digits = 0)
CicloviasKM$Kmkm <- "km"
CicloviasKM$Kms <- paste(CicloviasKM$Km,CicloviasKM$Kmkm, sep=" ")

#join shapefile com table
#Pontos2 <- merge(GIScontagens,Pontos, by.x="Local", by.y="Names")


##gráficos## 

#em facets
ggplot()+geom_sf(data=LisboaLimite,aes(),color = NA)+
  geom_sf(data=Ciclovias,aes(linetype =factor(Segregado,levels=c("Sim","Nao"))),color="#33A02C",size=1.1,alpha=0.2,show.legend=F)+
  #geom_sf(data=Pontos,aes(),color="#92324f",size=1.5)+
  facet_wrap(~Ano, nrow=3) +mapThemeFacets()
#em facets acumulado ALL years
ggplot()+geom_sf(data=LisboaLimite,aes(),color = NA)+
  geom_sf(data=Ciclovias2018T,aes(),color="#33A02C",size=1.1,alpha=0.2,show.legend=F)+
  facet_wrap(~AnoT, nrow=3) +mapThemeFacets()
##all years facets, com legenda acumulada km
ggplot()+geom_sf(data=LisboaLimite,aes(),color = NA)+
  geom_sf(data=Ciclovias2018T,aes(),color="#33A02C",size=1.1,alpha=0.2,show.legend=F)+
  facet_wrap(~AnoT, nrow=3) +mapThemeFacets() + geom_text(data=CicloviasKM,aes(x=-84000,y=-107000,label=Kms), inherit.aes=FALSE) 


#em facets acumulado Grupos de anos
ggplot()+geom_sf(data=LisboaLimite,aes(),color = NA)+
  geom_sf(data=Ciclovias2018,aes(linetype =factor(Segregado,levels=c("Sim","Nao"))),color="#33A02C",size=1.1,alpha=0.2,show.legend=F)+
  #geom_sf(data=Pontos,aes(),color="#92324f",size=1.5)+
  facet_wrap(~Anos, nrow=2) +mapThemeFacets()
ggsave("RedeCiclavel_AnosGroup.png", units="cm",width=20, height=18, dpi=600)


#como está muito lento, fazer merge das ciclovias por anos
CicloviasAnos <-group_by(Ciclovias2018T,AnoT)
CicloviasAnos <-summarise_at(CicloviasAnos,c(2), sum, na.rm=TRUE)
CicloviasAnos<-st_union(CicloviasAnos, by_feature=T)

CicloviasAnocada <-group_by(Ciclovias,Ano)
CicloviasAnocada <-summarise_at(CicloviasAnocada,c(2), sum, na.rm=TRUE)
CicloviasAnocada<-st_union(CicloviasAnocada, by_feature=T)
CicloviasAnocada <-CicloviasAnocada[-c(15),]
CicloviasAnocada$Ano <- as.character(CicloviasAnocada$Ano)




# #Gif dos anos sem km, verde e com separação se segregado, por piada
# RedeCiclavelLxVerde <- function(Year){
#   ggplot()+geom_sf(data=LisboaLimite,aes(),color = NA)+
#     geom_sf(data=filter(Ciclovias2018T,AnoT==Year),aes(linetype =factor(Segregado,levels=c("Sim","Nao"))),color="#33A02C",size=1.1,alpha=0.2,show.legend=F)+
#     facet_wrap(~AnoT, nrow=1) +mapTheme()
#   ggsave(filename=paste0(Year,".png"), units="cm",width=20, height=18, dpi=600)
# }
# seq(from = "2001", to="2018", by=1) %>% 
#   map_df(RedeCiclavelLxVerde)

#com construção realçada, e km
ggplot()+geom_sf(data=LisboaLimite,aes(),color = NA)+
  geom_sf(data=CicloviasAnos,aes(fill =AnoT),size=1,alpha=0.2,show.legend=F) +
  geom_sf(data=filter(Ciclovias,Ano=="2001"),aes(),color="#33A02C",size=1.1,alpha=0.2,show.legend=F) +
  geom_sf(data=filter(Ciclovias,Ano=="2003"),aes(),color="#33A02C",size=1.1,alpha=0.2,show.legend=F) +
  geom_sf(data=filter(Ciclovias,Ano=="2005"),aes(),color="#33A02C",size=1.1,alpha=0.2,show.legend=F) +
  geom_sf(data=filter(Ciclovias,Ano=="2008"),aes(),color="#33A02C",size=1.1,alpha=0.2,show.legend=F) +
  geom_sf(data=filter(Ciclovias,Ano=="2009"),aes(),color="#33A02C",size=1.1,alpha=0.2,show.legend=F) +
  geom_sf(data=filter(Ciclovias,Ano=="2010"),aes(),color="#33A02C",size=1.1,alpha=0.2,show.legend=F) +
  geom_sf(data=filter(Ciclovias,Ano=="2011"),aes(),color="#33A02C",size=1.1,alpha=0.2,show.legend=F) +
  geom_sf(data=filter(Ciclovias,Ano=="2012"),aes(),color="#33A02C",size=1.1,alpha=0.2,show.legend=F) +
  geom_sf(data=filter(Ciclovias,Ano=="2013"),aes(),color="#33A02C",size=1.1,alpha=0.2,show.legend=F) +
  geom_sf(data=filter(Ciclovias,Ano=="2014"),aes(),color="#33A02C",size=1.1,alpha=0.2,show.legend=F) +
  geom_sf(data=filter(Ciclovias,Ano=="2016"),aes(),color="#33A02C",size=1.1,alpha=0.2,show.legend=F) +
  geom_sf(data=filter(Ciclovias,Ano=="2017"),aes(),color="#33A02C",size=1.1,alpha=0.2,show.legend=F) +
  geom_sf(data=filter(Ciclovias,Ano=="2018"),aes(),color="#33A02C",size=1.1,alpha=0.2,show.legend=F) +
  facet_wrap(~AnoT, nrow=3)+ geom_text(data=CicloviasKM,aes(x=-84000,y=-107000,label=Kms), inherit.aes=FALSE) + mapTheme()

#em tons de cinza
ggplot()+geom_sf(data=LisboaLimite,aes(),color = NA)+
  geom_sf(data=CicloviasAnos,aes(fill =AnoT),color="grey70",size=1,alpha=0.2,show.legend=F) +
  geom_sf(data=filter(Ciclovias,Ano=="2001"),aes(),color="black",size=1.1,alpha=0.2,show.legend=F) +
  geom_sf(data=filter(Ciclovias,Ano=="2003"),aes(),color="black",size=1.1,alpha=0.2,show.legend=F) +
  geom_sf(data=filter(Ciclovias,Ano=="2005"),aes(),color="black",size=1.1,alpha=0.2,show.legend=F) +
  geom_sf(data=filter(Ciclovias,Ano=="2008"),aes(),color="black",size=1.1,alpha=0.2,show.legend=F) +
  geom_sf(data=filter(Ciclovias,Ano=="2009"),aes(),color="black",size=1.1,alpha=0.2,show.legend=F) +
  geom_sf(data=filter(Ciclovias,Ano=="2010"),aes(),color="black",size=1.1,alpha=0.2,show.legend=F) +
  geom_sf(data=filter(Ciclovias,Ano=="2011"),aes(),color="black",size=1.1,alpha=0.2,show.legend=F) +
  geom_sf(data=filter(Ciclovias,Ano=="2012"),aes(),color="black",size=1.1,alpha=0.2,show.legend=F) +
  geom_sf(data=filter(Ciclovias,Ano=="2013"),aes(),color="black",size=1.1,alpha=0.2,show.legend=F) +
  geom_sf(data=filter(Ciclovias,Ano=="2014"),aes(),color="black",size=1.1,alpha=0.2,show.legend=F) +
  geom_sf(data=filter(Ciclovias,Ano=="2016"),aes(),color="black",size=1.1,alpha=0.2,show.legend=F) +
  geom_sf(data=filter(Ciclovias,Ano=="2017"),aes(),color="black",size=1.1,alpha=0.2,show.legend=F) +
  geom_sf(data=filter(Ciclovias,Ano=="2018"),aes(),color="black",size=1.1,alpha=0.2,show.legend=F) +
  facet_wrap(~AnoT, nrow=3)+ geom_text(data=CicloviasKM,aes(x=-84000,y=-107000,label=Kms), inherit.aes=FALSE) + mapThemeFacets()



#criar elementos vazios nos anos em que nao aconteceu nada, para mostrar no gif
teste <-data.frame(Ano=c(2002,2004,2006,2007,2015))
teste$Ano <-as.integer(teste$Ano)
teste$TIPOLOGIA <-as.character(NA)
teste$lenght <-as.numeric(NA)
teste$geometry<-st_sfc(st_multilinestring())
teste$AnoT <-teste$Ano 
teste$Segregado <-as.character(NA)
teste <- teste[,c(2,3,1,4,5,6)]
teste2<-st_sf(teste)
st_crs(teste2) <-4326
CicloviasGif<-Ciclovias
CicloviasGif<-rbind(CicloviasGif, teste2) 

#GIF em tons cinza, com kms acumulados
RedeCiclavelLxkm <- function(Year){
  ggplot()+geom_sf(data=LisboaLimite,aes(),color = NA)+
    geom_sf(data=filter(CicloviasAnos,AnoT==Year),aes(fill =AnoT),color="grey70",size=1,alpha=0.2,show.legend=F) +
    geom_sf(data=filter(CicloviasGif,Ano==Year),aes(),color="black",size=1.1,alpha=0.2,show.legend=F) +
    facet_wrap(~AnoT, nrow=1)+ geom_text(data=filter(CicloviasKM,AnoT==Year),aes(x=-84000,y=-107000,label=Kms), size=6,inherit.aes=FALSE) + mapTheme()
  ggsave(filename=paste0(Year,"km.png"), units="cm",width=20, height=18, dpi=600)
}
seq(from = "2001", to="2018", by=1) %>% 
  map_df(RedeCiclavelLxkm)

rm(teste)
rm(teste2)


class(CicloviasActual)
st_crs(CicloviasActual) <- 4326 #meter a projecção WGS84
st_write(CicloviasActual,"CicloviasActual.shp")

class(CicloviasAnos)
st_crs(CicloviasAnos) <- 4326 #meter a projecção WGS84
st_write(CicloviasAnos,"D:/rosa/Dropbox/EixosActivos_CML/Dados_EixosCiclaveis/2a campanha/Dados/R/CicloviasAnos.shp")

#gravar em shp as ciclovias de 2016, de 2017 e 2018
st_write(CicloviasAnos[CicloviasAnos$AnoT=="2016", ],"RedeCiclavel_2016.shp")
st_write(CicloviasGif[CicloviasGif$Ano=="2017", ],"RedeCiclavel_2017.shp")
st_write(CicloviasGif[CicloviasGif$Ano=="2018", ],"RedeCiclavel_2018.shp")
