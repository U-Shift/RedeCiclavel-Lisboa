slideano =  ggplot()+
    mapTheme()+
    #mapa base
    geom_sf(LisboaLimite, mapping = aes(), color = NA) +
    #ciclovias naquele ano
    geom_sf(data=subset(CICLOVIAS,TIPOLOGIA=="Nao dedicada" & AnoT==2022),aes(),
            color="#AFD4A0",size=1.1,show.legend=F) + 
  geom_sf(data=subset(CICLOVIAS,TIPOLOGIA=="Ciclovia dedicada" & AnoT==2022),aes(),
          color="#1A7832",size=1.1,show.legend=F) +
    #aplicar o estilo com o ano em cima
    facet_wrap(~AnoT, nrow=1)+
    #adicionar o contador de km
    geom_text(data=subset(CicloviasKMredux,AnoT==2022),
              aes(x=-9.1,y=38.692,label=Kms), size=6,inherit.aes=FALSE)
  
slideano

  #gravar cada imagem
  ggsave(slideano, filename=paste0(2022,"km.png"),
         units="cm", width=18, height=18, dpi=300)
  