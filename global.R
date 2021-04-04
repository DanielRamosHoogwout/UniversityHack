##
# Main File
##

rm(list=ls())

### Paths ####
pd1 = "Docs/Data/Dataset1.- DatosConsumoAlimentarioMAPAporCCAA.txt" # Consumo
pd4 = "Docs/Data/Dataset4.- Comercio Exterior de Esp.txt" # Comercio Exterior

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

data1 <- read_delim(pd1, delim = "|", locale = locale(decimal_mark = ","))

data1 %<>% select(c(Año, Mes, CCAA, Producto, Volumen = `Volumen (miles de kg)`,
                    Valor = `Valor (miles de €)`, Precio = `Precio medio kg`,
                    Penetracion = `Penetración (%)`, Cons_cpt = `Consumo per capita`,
                    Gasto_cpt = `Gasto per capita`))

data1.1 <- data1 %>%
  select(-Penetracion, -Valor) %>%
  filter(CCAA == "Total Nacional") %>%
  mutate(Fecha = parse_date(paste(Mes, Año), locale = locale("es"), format = "%B %Y")) %>%
  filter(Producto != "CHIRIMOYA") %>%
  group_by(Producto) %>%
  mutate(Volumen = scale(Volumen),
         Precio = scale(Precio),
         Consumo = scale(Cons_cpt),
         Gasto = scale(Gasto_cpt)) %>%
  ungroup()

covindex <- function(prod = "CEBOLLAS", var = "Precio" , plt = FALSE) {
  data1.1 = data1.1 %>% filter(Producto == prod) %>%
    select(Fecha, var)
  preCovid <- filter(data1.1, Fecha <= "2020-02-01")
  postCovid <- filter(data1.1, Fecha >= "2020-02-01")
  st <- ts(preCovid[,2], start = 2018, frequency = 12)
  arimaPred <- forecast(st, h = 10)
  postCovid[,3] <- as.vector(arimaPred$mean)[1:nrow(postCovid)]
  index <- sum(postCovid[,2] - postCovid[,3]) / nrow(postCovid)
  if(plt) {
    plot <- ggplot(data = postCovid) +
      geom_line(data = preCovid, mapping = aes_string(x = "Fecha", y = var), size = 1.2) +
      geom_line(aes_string(x = "Fecha", y = var), color = "tomato", size = 1.2) +
      geom_line(aes_string(x = "Fecha", y = "...3"), linetype = "dashed", size = 1.2) +
      geom_ribbon(aes_string(ymin = var, ymax = "...3", x = "Fecha"), alpha = 0.2, fill = "tomato") +
      geom_vline(xintercept = as.Date("2020-02-01"), alpha = 0.5, linetype = 3) +
      geom_label(label = "PRE-COVID", y = -0.6, x = as.Date("2019-11-01")) +
      geom_label(label = "COVID", y = -0.6, x = as.Date("2020-04-05")) +
      geom_label(label = "Febrero 2020", y = -0.87, x = as.Date("2020-02-01")) +
      ggtitle(prod) +
      theme(panel.background = element_rect(fill = "white",colour = "grey50"),
            axis.text.y = element_blank(),
            axis.ticks.y = element_blank(),
            axis.line = element_line(size = 1, linetype = "solid"))
    return(list(index = index, plot = plot))
  } else {
    return(list(index = index))
  }
}

#covindex("CEBOLLAS", "Precio", plt = TRUE)$plot

tabla <- matrix(nrow = 50, ncol = 4, dimnames = list(unique(data1.1$Producto), colnames(data1.1)[c(5,6,10,11)]))

###################### ERROR!

# for(prods in unique(data1.1$Producto)) {
#   for(inds in colnames(data1.1)[c(5, 6, 10, 11)]) {
#     tabla[prods, inds] <- covindex(prods, inds)$index
#   }
# }
# 
# 
# acpFit2 <- prcomp(tabla[,c(1,3,4)], center = TRUE, scale = TRUE)
# 
# tabla2 <- data.frame(acpFit2$x[,1], tabla[,2])
# 
# hcComplete <- hclust(dist(tabla2), method = "complete")
# 
# hcCut <- as.factor(cutree(hcComplete, 2))
# tabla2 <- cbind(tabla2, hcCut)
# 
# cluster <- ggplot(tabla2) +
#   geom_point(aes(x = -acpFit2.x...1., y = tabla...2., color = hcCut)) +
#   labs(color = "Grupo") +
#   ggtitle("Separación por clusters", subtitle = "Cluster jerárquico con 2 grupos") +
#   geom_text_repel(aes(x = -acpFit2.x...1., y = tabla...2., label = row.names(tabla2), color = hcCut), label.size = 0.5, max.overlaps = 30) +
#   ylab("Índice Precio") +
#   xlab("Índice Consumo")

#### 4.Comercio Exterior ####

data4 = read_delim(pd4, delim = "|", locale = locale(decimal_mark = ","))

data4 %<>% select(Inicio = PERIOD, Pais = REPORTER, Producto = PRODUCT,
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
  filter(!str_starts(Pais, "European")) %>%
  mutate(Año = year(my(Inicio))) %>%
  group_by(Pais, Año, Accion, Unidad) %>% 
  summarise(total = sum(Valor)) -> pais_ano

getImportacionesPorPais_euros = function(pais = "Germany") {
  
  plot1 = pais_ano %>%
    filter(Pais == pais, Unidad == "VALUE_IN_EUROS") %>%
    ggplot(aes(x = Año, y = total)) +
    geom_bar(stat = "identity", aes(fill = Accion), show.legend = F) +
    ggtitle(pais) +
    facet_grid(.~Accion)
  
  return(plot1)
}

getImportacionesPorPais_kg = function(pais = "Germany") {
  
  plot2 = pais_ano %>%
    filter(Pais == pais, Unidad == "QUANTITY_IN_100KG") %>%
    ggplot(aes(x = Año, y = total)) +
    geom_bar(stat = "identity", aes(fill = Accion), show.legend = F) +
    ggtitle(pais) +
    facet_grid(.~Accion)
  
  return(plot2)
}

pais_ano %>%
  filter(Pais == "Italy", Unidad == "VALUE_IN_EUROS") %>%
  ggplot(aes(x = Año, y = total)) +
  geom_bar(stat = "identity", aes(fill = Accion),
           show.legend = F) +
  ggtitle("Italy") +
  facet_grid(.~Accion)



getImportacionesPorPais_kg("Austria")

### Mapa CCAA ####

# datos_mapa = read_delim(pd1, delim = "|", locale = locale(decimal_mark = ","))
# 
# datos_mapa %<>% select(c(Año, Mes, CCAA, Producto, Volumen = `Volumen (miles de kg)`,
#                     Valor = `Valor (miles de €)`, Precio = `Precio medio kg`,
#                     Penetracion = `Penetración (%)`, Cons_cpt = `Consumo per capita`,
#                     Gasto_cpt = `Gasto per capita`))

datos_mapa <- data1[,-c(6,8,9,10)] #Eliminamos columnas que no interesan
datos_mapa <- datos_mapa %>% filter(CCAA != "Total Nacional", Año == c(2019,2020), Mes == c("Marzo", "Abril", "Mayo"))
datos_mapa <- datos_mapa %>%
  group_by(Año, CCAA) %>%
  summarise(TrimPrice = mean(Precio), TrimVol = mean(Volumen)) %>%
  pivot_wider(names_from = Año, values_from = c(TrimPrice, TrimVol), values_fill = 0) %>%
  mutate(VarPrice = (TrimPrice_2020-TrimPrice_2019)/TrimPrice_2019,
         VarVol = (TrimVol_2020-TrimVol_2019)/TrimVol_2019)

#Comprobamos que el archivo existe
file.exists("Docs/Mapa/Comunidades_Autonomas_ETRS89_30N.shp")
shapefile_ccaa <- readOGR(dsn = "Docs/Mapa/Comunidades_Autonomas_ETRS89_30N.shp")

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
#### Map ###########
#########################

final_map <- data_ccaa_mapa %>%
  ggplot(aes(x = long, y = lat, group = group, fill = VarPrice, text=paste('CCAA:', CCAA))) +
  geom_polygon(color = "black") +
  scale_fill_viridis_c(option = "C") +
  theme_void() +
  theme(panel.background = element_rect(size= 0.5, color = "white", fill = "white")) +
  labs(title = "CCAA", subtitle = "España")
final_map <- ggplotly(final_map)

