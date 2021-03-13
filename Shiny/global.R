##
# Main File
##

rm(list=ls())

### Paths ####
pd1 = "Data/Dataset1.- DatosConsumoAlimentarioMAPAporCCAA.txt" #Consumo
pd2 = "Data/Dataset2.- Precios Semanales Observatorio de Precios Junta de Andalucia.txt" #Precio

pd4 = "Data/Dataset4.- Comercio Exterior de España.txt"
pd5 = "Data/Dataset5_Coronavirus_cases.txt" #Covid

### Libraries ####
library(tidyverse)
library(magrittr)
library(lubridate)

### Datasets ####

#### 1.Consumo ####
data1 = read.csv(pd1, sep = "|", dec = ",")

data1 %<>% select(c(Ano = ï..AÃ.o, Mes, CCAA, Producto,
                    Volumen = Volumen..miles.de.kg., Valor = Valor..miles.de.â... , 
                    Precio_Medio = Precio.medio.kg, Penetracion = `PenetraciÃ³n....`,
                    Cons_cpt = Consumo.per.capita, Gasto_cpt = Gasto.per.capita))

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
