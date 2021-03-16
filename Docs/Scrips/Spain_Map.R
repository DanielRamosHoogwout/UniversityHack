#Mapa españa
library(tidyverse)
library(rgdal) # para importar archivos shapefiles
library(broom) # Para transformar los archivos shapefiles
library(highcharter)

#Cargamos dataset 1
pd1 = "../Data/Dataset1.- DatosConsumoAlimentarioMAPAporCCAA.txt" #Consumo
data1 = read.csv(pd1, sep = "|", dec = ",")
summary(data1) # 120 NA's en penetración
# MUCHOS VALORES 0

data1 <- data1[,-c(6,8,9,10,11,12)] #Eliminamos columnas que no interesan
data1 <- data1 %>% filter(CCAA != "Total Nacional", ï..AÃ.o == c(2019,2020), Mes == c("Marzo", "Abril", "Mayo"))
data1 <- data1 %>%
  group_by(ï..AÃ.o, CCAA) %>%
  summarise(TrimPrice = mean(Precio.medio.kg), TrimVol = mean(Volumen..miles.de.kg.)) %>%
  pivot_wider(names_from = ï..AÃ.o, values_from = c(TrimPrice, TrimVol), values_fill = 0) %>%
  mutate(VarPrice = (TrimPrice_2020-TrimPrice_2019)/TrimPrice_2019,
         VarVol = (TrimVol_2020-TrimVol_2019)/TrimVol_2019)

#Comprobamos que el archivo existe
file.exists("../Data/Comunidades_Autonomas_ETRS89_30N.shp")
shapefile_ccaa <- readOGR(dsn = "../Data/Comunidades_Autonomas_ETRS89_30N.shp")

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
  left_join(data1, by = "CCAA")

##########################
#### FUNCIONA ###########
#########################
data_ccaa_mapa %>%
  ggplot(aes(x = long, y = lat, group = group, fill = VarPrice)) +
  geom_polygon(color = "black") +
  scale_fill_viridis_c(option = "C") +
  theme_void() +
  theme(panel.background = element_rect(size= 0.5, color = "white", fill = "white")) +
  labs(title = "CCAA", subtitle = "España")
