##
# Main File
##

rm(list=ls())

### Paths ####
pd1 = "../Data/Dataset1.- DatosConsumoAlimentarioMAPAporCCAA.txt" #Consumo
pd2 = "Data/Dataset2.- Precios Semanales Observatorio de Precios Junta de Andalucia.txt" #Precio

pd4 = "Data/Dataset4.- Comercio Exterior de España.txt"
pd5 = "Data/Dataset5_Coronavirus_cases.txt" #Covid

### Libraries ####
library(tidyverse)
library(magrittr)
library(lubridate)
library(forecast)
library(ggrepel)

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
  mutate(scVolumen = scale(Volumen),
         scPrecio_Medio = scale(Precio_Medio),
         scCons_cpt = scale(Cons_cpt),
         scGasto_cpt = scale(Gasto_cpt)) %>%
  ungroup()

prod = "TOTAL PATATAS"
var = "scVolumen"
covindex <- function(df, prod, var, plt = FALSE) {
  df %<>%
    filter(Producto == prod) %>%
    select(Fecha, var)
  preCovid <- filter(df, Fecha <= "2020-02-01")
  postCovid <- filter(df, Fecha >= "2020-02-01")
  st <- ts(preCovid[,2], start = 2018, frequency = 12)
  arimaPred <- forecast(st, h = 10)
  postCovid[,3] <- as.vector(arimaPred$mean)[1:nrow(postCovid)]
  index <- sum(postCovid[,2] - postCovid[,3]) / nrow(postCovid)
  if(plt) {
    plot <- ggplot(data = postCovid) +
      geom_line(data = preCovid, mapping = aes_string(x = "Fecha", y = var)) +
      geom_line(aes_string(x = "Fecha", y = var), color = "tomato") +
      geom_line(aes_string(x = "Fecha", y = "...3"), linetype = "dashed") +
      geom_ribbon(aes_string(ymin = var, ymax = "...3", x = "Fecha"), alpha = 0.2)
    return(list(index = index, plot = plot))
  } else {
    return(list(index = index))
  }
}

covindex(data1, "CEBOLLAS", "scPrecio_Medio", plt = TRUE)

tabla <- matrix(nrow = 50, ncol = 4, dimnames = list(unique(data1$Producto), colnames(data1)[10:13]))

for(prods in unique(data1$Producto)) {
  for(inds in colnames(data1)[10:13]) {
    tabla[prods, inds] <- covindex(data1, prods, inds)$index
  }
}

acpFit2 <- prcomp(tabla[,c(1,3,4)], center = TRUE, scale = TRUE)

tabla2 <- data.frame(acpFit2$x[,1], tabla[,2])

hcComplete <- hclust(dist(tabla2), method = "complete")

hcCut <- as.factor(cutree(hcComplete, 2))
tabla2 <- cbind(tabla2, hcCut)

ggplot(tabla2) +
  geom_point(aes(x = acpFit2.x...1., y = tabla...2., color = hcCut)) +
  labs(color = "Grupo") +
  ggtitle("Separación por clusters", subtitle = "k-means clustering con 3 grupos") +
  geom_text_repel(aes(x = acpFit2.x...1., y = tabla...2., label = row.names(tabla2), color = hcCut), size = 2, max.overlaps = 30)

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
