##
# Main File
##

rm(list=ls())

### Paths ####
pd1 = "Docs/Data/Dataset1.- DatosConsumoAlimentarioMAPAporCCAA.txt" #Consumo
pd2 = "Docs/Data/Dataset2.- Precios Semanales Observatorio de Precios Junta de Andalucia.txt" #Precio

pd4 = "Docs/Data/Dataset4.- Comercio Exterior de Esp.txt"
pd5 = "Docs/Data/Dataset5_Coronavirus_cases.txt" #Covid

### Libraries ####
library(tidyverse)
library(magrittr)
library(lubridate)
library(forecast)
library(ggrepel)
library(rgdal)
library(broom)
library(plotly)
### Datasets ####

#### 1.Consumo ####
data1 = read.csv(pd1, sep = "|", dec = ",")

data1 %<>% select(c(Ano = ï..AÃ.o, Mes, CCAA, Producto,
                    Volumen = Volumen..miles.de.kg., Valor = Valor..miles.de.â... , 
                    Precio_Medio = Precio.medio.kg, Penetracion = `PenetraciÃ³n....`,
                    Cons_cpt = Consumo.per.capita, Gasto_cpt = Gasto.per.capita))

data1 %<>%
  select(-Penetracion, -Valor)

data1 %<>%
  filter(CCAA == "Total Nacional")

data1 %<>%
  mutate(Fecha = parse_date(paste(Mes, Ano), locale = locale("es"), format = "%B %Y"))

data1 %<>%
  filter(Producto != "CHIRIMOYA")

data1 %<>%
  group_by(Producto) %>%
  mutate(Volumen = scale(Volumen),
         Precio = scale(Precio_Medio),
         Consumo = scale(Cons_cpt),
         Gasto = scale(Gasto_cpt)) %>%
  ungroup()

# prod = "TOTAL PATATAS"
# var = "Volumen"

covindex <- function(prod = "CEBOLLAS", var = "Precio" , plt = FALSE) {
  
  data1 = data1 %>% filter(Producto == prod) %>%
    select(Fecha, var)
  preCovid <- filter(data1, Fecha <= "2020-02-01")
  postCovid <- filter(data1, Fecha >= "2020-02-01")
  st <- ts(preCovid[,2], start = 2018, frequency = 12)
  arimaPred <- forecast(st, h = 10)
  postCovid[,3] <- as.vector(arimaPred$mean)[1:nrow(postCovid)]
  index <- sum(postCovid[,2] - postCovid[,3]) / nrow(postCovid)
  if(plt) {
    plot <- ggplot(data = postCovid) +
      geom_line(data = preCovid, mapping = aes_string(x = "Fecha", y = var)) +
      geom_line(aes_string(x = "Fecha", y = var), color = "tomato") +
      geom_line(aes_string(x = "Fecha", y = "...3"), linetype = "dashed") +
      geom_ribbon(aes_string(ymin = var, ymax = "...3", x = "Fecha"), alpha = 0.2) +
      ggtitle(prod)
    return(list(index = index, plot = plot))
  } else {
    return(list(index = index))
  }
}

#covindex("CEBOLLAS", "Precio", plt = TRUE)$plot

tabla <- matrix(nrow = 50, ncol = 4, dimnames = list(unique(data1$Producto), colnames(data1)[c(5,10,11,12)]))

for(prods in unique(data1$Producto)) {
  for(inds in colnames(data1)[c(5,10,11,12)]) {
    tabla[prods, inds] <- covindex(prods, inds)$index
  }
}

acpFit2 <- prcomp(tabla[,c(1,3,4)], center = TRUE, scale = TRUE)

tabla2 <- data.frame(acpFit2$x[,1], tabla[,2])

hcComplete <- hclust(dist(tabla2), method = "complete")

hcCut <- as.factor(cutree(hcComplete, 2))
tabla2 <- cbind(tabla2, hcCut)

cluster <- ggplot(tabla2) +
  geom_point(aes(x = -acpFit2.x...1., y = tabla...2., color = hcCut)) +
  labs(color = "Grupo") +
  ggtitle("Separación por clusters", subtitle = "Cluster jerárquico con 2 grupos") +
  geom_text_repel(aes(x = -acpFit2.x...1., y = tabla...2., label = row.names(tabla2), color = hcCut), label.size = 0.5, max.overlaps = 30) +
  ylab("Índice Precio") +
  xlab("Índice Consumo")

#### 2.Precios ####
data2 = read.csv(pd2, sep = "|", dec = ",")

data2 %<>% mutate(Inicio = dmy(ï..INICIO), Fin = dmy(FIN)) %>%
  select(Inicio, Fin, Sector = SECTOR, Producto = PRODUCTO,
         Posicion = POSICION, Precio = PRECIO)

#### 4.Comercio Exterior ####
data4 = read.csv(pd4, sep = "|")

data4 %<>% mutate(Inicio = my(ï..PERIOD)) %>%
  select(Inicio, Pais = REPORTER, Producto = PRODUCT,
         Accion = FLOW, Unidad = INDICATORS, Valor = Value) %>%
  filter(Valor != ":") %>% 
  mutate(Valor = as.numeric(Valor)) %>%  #se introducen NA's al hacer numeric
  drop_na(Valor)

for (i in seq(nrow(data4))){
  if (str_starts(data4$Pais[i], "Ger")){
    data4$Pais[i] = "Germany"
  }
  else if (str_starts(data4$Pais[i], "Fr")){
    data4$Pais[i] = "France"
  }
  else if (str_starts(data4$Pais[i], "It")){
    data4$Pais[i] = "Italy"
  }
  else if (str_starts(data4$Pais[i], "Bel")){
    data4$Pais[i] = "Belgium"
  }
}

### Comercio Exterior #####
data4 %>% 
  mutate(Ano = year(Inicio)) %>%
  group_by(Pais, Ano, Accion, Unidad) %>% 
  summarise(total = sum(Valor)) -> pais_ano

getImportacionesPorPais = function(pais = "Germany") {
  
  plot1 = pais_ano %>%
    filter(Pais == pais, Unidad == "VALUE_IN_EUROS") %>%
    ggplot(aes(x = Ano, y = total)) +
    geom_bar(stat = "identity") +
    ggtitle(pais)+
    facet_grid(.~Accion)
  
  return(plot1)
}

# getImportacionesPorPais("Austria")

# Mapa CCAA
datos_mapa = read.csv(pd1, sep = "|", dec = ",")

datos_mapa <- datos_mapa[,-c(6,8,9,10,11,12)] #Eliminamos columnas que no interesan
datos_mapa <- datos_mapa %>% filter(CCAA != "Total Nacional", ï..AÃ.o == c(2019,2020), Mes == c("Marzo", "Abril", "Mayo"))
datos_mapa <- datos_mapa %>%
  group_by(ï..AÃ.o, CCAA) %>%
  summarise(TrimPrice = mean(Precio.medio.kg), TrimVol = mean(Volumen..miles.de.kg.)) %>%
  pivot_wider(names_from = ï..AÃ.o, values_from = c(TrimPrice, TrimVol), values_fill = 0) %>%
  mutate(VarPrice = (TrimPrice_2020-TrimPrice_2019)/TrimPrice_2019,
         VarVol = (TrimVol_2020-TrimVol_2019)/TrimVol_2019)

#Comprobamos que el archivo existe
file.exists("Docs/Data/Comunidades_Autonomas_ETRS89_30N.shp")
shapefile_ccaa <- readOGR(dsn = "Docs/Data/Comunidades_Autonomas_ETRS89_30N.shp")

data_ccaa <- tidy(shapefile_ccaa)

nombres_ccaa <- tibble(shapefile_ccaa$Texto) %>% 
  mutate(id = as.character(seq(0, nrow(.)-1)))

data_ccaa_mapa <- data_ccaa %>% 
  left_join(nombres_ccaa, by = "id") %>% 
  rename(CCAA = `shapefile_ccaa$Texto`)

unique(data_ccaa_mapa$CCAA)

data_ccaa_mapa$CCAA <- ifelse(data_ccaa_mapa$CCAA == "AndalucÃ­a", "Andalucia", data_ccaa_mapa$CCAA)
data_ccaa_mapa$CCAA <- ifelse(data_ccaa_mapa$CCAA == "Islas Baleares", "Baleares", data_ccaa_mapa$CCAA)
data_ccaa_mapa$CCAA <- ifelse(data_ccaa_mapa$CCAA == "Castilla y LeÃ³n", "Castilla Leon", data_ccaa_mapa$CCAA)
data_ccaa_mapa$CCAA <- ifelse(data_ccaa_mapa$CCAA == "Comunidad Valenciana", "Valencia", data_ccaa_mapa$CCAA)
data_ccaa_mapa$CCAA <- ifelse(data_ccaa_mapa$CCAA == "Comunidad de Madrid", "Madrid", data_ccaa_mapa$CCAA)
data_ccaa_mapa$CCAA <- ifelse(data_ccaa_mapa$CCAA == "PaÃ­s Vasco", "Pais Vasco", data_ccaa_mapa$CCAA)
data_ccaa_mapa$CCAA <- ifelse(data_ccaa_mapa$CCAA == "AragÃ³n", "Aragon", data_ccaa_mapa$CCAA)
data_ccaa_mapa$CCAA <- ifelse(data_ccaa_mapa$CCAA == "Castilla - La Mancha", "Castilla La Mancha", data_ccaa_mapa$CCAA)
data_ccaa_mapa$CCAA <- ifelse(data_ccaa_mapa$CCAA == "RegiÃ³n de Murcia", "Murcia", data_ccaa_mapa$CCAA)
data_ccaa_mapa$CCAA <- ifelse(data_ccaa_mapa$CCAA == "Principado de Asturias", "Asturias", data_ccaa_mapa$CCAA)
data_ccaa_mapa$CCAA <- ifelse(data_ccaa_mapa$CCAA == "Comunidad Foral de Navarra", "Navarra", data_ccaa_mapa$CCAA)

data_ccaa_mapa <- data_ccaa_mapa %>% 
  left_join(datos_mapa, by = "CCAA")

##########################
#### FUNCIONA ###########
#########################
final_map <- data_ccaa_mapa %>%
  ggplot(aes(x = long, y = lat, group = group, fill = VarPrice, text=paste('CCAA:', CCAA))) +
  geom_polygon(color = "black") +
  scale_fill_viridis_c(option = "C") +
  theme_void() +
  theme(panel.background = element_rect(size= 0.5, color = "white", fill = "white")) +
  labs(title = "CCAA", subtitle = "España")
final_map <- ggplotly(final_map)