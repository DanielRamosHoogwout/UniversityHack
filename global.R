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
         Consumo = scale(Cons_cpt),
         Precio = scale(Precio)) %>%
  ungroup()

covindex <- function(prod = "CEBOLLAS", var = "Volumen" , plt = FALSE) {
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
      geom_line(aes_q(x = as.name("Fecha"), y = as.name(var), color = "tomato"), size = 1.2) +
      geom_line(aes_q(x = as.name("Fecha"), y = as.name("...3"), linetype = "dashed"), size = 1.2) +
      geom_ribbon(aes_string(ymin = var, ymax = "...3", x = "Fecha"), alpha = 0.2, fill = "tomato") +
      geom_vline(xintercept = as.Date("2020-02-01"), alpha = 0.5, linetype = 3) +
      ggtitle(prod) +
      scale_color_manual(name = "Valor Real", values = c("tomato" = "tomato"), labels = c("")) +
      scale_linetype_manual(name = "Predicción", values = c("dashed" = "dashed"), labels = c("")) +
      theme(panel.background = element_rect(fill = NA),
            axis.text.y = element_blank(),
            axis.ticks.y = element_blank(),
            axis.line = element_line(size = 1, linetype = "solid"),
            legend.position = "right")
    rangplot <- ggplot_build(plot)$layout$panel_scales_y[[1]]$range$range
    plot <- plot +
      geom_label(label = "PRE-COVID", y = rangplot[1] + 0.14 * (rangplot[2] - rangplot[1]), x = as.Date("2019-11-01")) +
      geom_label(label = "COVID", y = rangplot[1] + 0.14 * (rangplot[2] - rangplot[1]), x = as.Date("2020-04-19")) +
      geom_label(label = "Febrero 2020", y = rangplot[1] + 0.06 * (rangplot[2] - rangplot[1]), x = as.Date("2020-02-01"))
    return(list(index = index, plot = plot))
  } else {
    return(list(index = index))
  }
}

##################### CLUSTERING

tabla <- matrix(nrow = 50, ncol = 3, dimnames = list(unique(data1.1$Producto), colnames(data1.1)[c(5, 10, 6)]))

# for(prods in unique(data1.1$Producto)) {
#   for(inds in colnames(data1.1)[c(5, 10, 6)]) {
#     tabla[prods, inds] <- covindex(prods, inds)$index
#   }
# }
# 
# prcomp(tabla, center = TRUE, scale = TRUE)
# acpFit <- prcomp(tabla, center = TRUE, scale = TRUE)
# summary(acpFit)$importance
# 
# tablaacp <- as.data.frame(acpFit$x[,c(1,2)])
# 
# tablasc <- scale(tabla)
# 
# tablasc
# tablaacp
# tabla
# 
# scales <- attributes(tablasc)$`scaled:center` / attributes(tablasc)$`scaled:scale`
# scales
# acpFit$rotation[,1]
# acpFit$rotation[,2]
# rv <- t(acpFit$rotation[,1]) %*% scales # recta vertical
# rh <- -t(acpFit$rotation[,2]) %*% scales # recta horizontal
# 
# tablaacp[,1] <- -tablaacp[,1]
# 
# set.seed(1)
# WCSS <- vector()
# for(i in 1:10) {
#   WCSS[i] <- sum(kmeans(tablaacp, i)$withinss)
# }
# dataWCSS <- tibble(K = 1:10, WCSS)
# ggplot(dataWCSS, mapping = aes(x = K, y = WCSS)) +
#   geom_line() +
#   geom_point() +
#   geom_point(x = 3, y = WCSS[3], size = 3) +
#   scale_x_continuous(breaks = 1:10) +
#   ggtitle("Método del codo", subtitle = "Elección del K óptimo")
# 
# kmCluster <- kmeans(tablaacp, 3)
# kmCut <- as.factor(kmCluster$cluster)
# 
# tablaacp <- bind_cols(tablaacp, kmCut)
# 
# ggplot(tablaacp) +
#   theme(panel.background = element_rect(fill = "#EDEDED"),
#         panel.border = element_rect(color = "black", fill = NA),
#         panel.grid = element_line(color = "#EDEDED"),
#         axis.text = element_blank(),
#         axis.ticks = element_blank()) +
#   geom_vline(xintercept = t(acpFit$rotation[,1]) %*% scales) +
#   geom_hline(yintercept = -t(acpFit$rotation[,2]) %*% scales) +
#   geom_label(label = "EFECTO POSITIVO", y = -0.35, x = -2.15, fill = "#B9FF73") +
#   geom_label(label = "EFECTO NEGATIVO", y = -0.606, x = -2.15, fill = "#FF7373") +
#   geom_label(label = "EFECTO POSITIVO", y = 1.7, x = -0.35, fill = "#B9FF73") +
#   geom_label(label = "EFECTO NEGATIVO", y = 1.7, x = -1.57, fill = "#FF7373") +
#   geom_point(aes(x = PC1, y = PC2, color = kmCut), show.legend = F) +
#   labs(color = "Grupo") +
#   ggtitle("Agrupación de productos agroalimentarios en función del efecto del COVID-19", subtitle = "Clustering con 3 grupos") +
#   geom_text_repel(aes(x = PC1, y = PC2, label = row.names(tablaacp), color = kmCut), size = 4, max.overlaps = 30, show.legend = F) +
#   ylab("Índice Precio") +
#   xlab("Índice Cantidad") +
#   geom_label(label = "CANTIDAD", y = 1.7, x = -0.9463244) +
#   geom_label(label = "PRECIO", y = -0.4784479, x = -2.15) +
#   scale_color_manual(values = c("#727911", "#117279", "#DF4ADC"))

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
data_ccaa_mapa$CCAA <- ifelse(data_ccaa_mapa$CCAA == "CataluÃ±a", "Cataluña", data_ccaa_mapa$CCAA)

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

