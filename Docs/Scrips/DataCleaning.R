##
# Data Cleaning
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
# data1 = read.csv(pd1, sep = "|", dec = ",")
summary(data1) # 120 NA's en penetración

data1 = read_delim(pd1, delim = "|", locale = locale(decimal_mark = ","))

data1 %<>% select(c(Año, Mes, CCAA, Producto, Volumen = `Volumen (miles de kg)`,
                    Valor = `Valor (miles de €)`, Precio = `Precio medio kg`,
                    Penetracion = `Penetración (%)`, Cons_cpt = `Consumo per capita`,
                    Gasto_cpt = `Gasto per capita`))

## Unidades
# Volumen: en miles de kg, litros o unidades en caso de huevos
# Valor: en miles de €
# Penetración: % de hogares que lo compran

str(data1)

#### 2.Precios ####
data2 = read.csv(pd2, sep = "|", dec = ",")
summary(data2) # NA's en pop y cumulative
unique(data2$SECTOR)
unique(data2$PRODUCTO)
unique(data2$GRUPO)
table(data2$SECTOR)
table(data2$GRUPO)
unique(data2$TIPO)
prop.table(table(data2$SUBTIPO)) # Muchos sin especificar o NA's
prop.table(table(data2$FORMATO)) # 90% NA's
unique(data2$UNIDAD) # 100% €/kg

# Sector y Grupo informan lo mismo siendo sector más específico

data2 %<>% mutate(Inicio = dmy(ï..INICIO), Fin = dmy(FIN)) %>%
  select(Inicio, Fin, Sector = SECTOR, Producto = PRODUCTO,
         Posicion = POSICION, Precio = PRECIO)

#### 4.Comercio Exterior ####
data4 = read_delim(pd4, delim = "|", locale = locale(decimal_mark = ","))
unique(data4$PARTNER) # Solo "ES"

data4 %<>% select(Inicio = PERIOD, Pais = REPORTER, Producto = PRODUCT,
                  Accion = FLOW, Unidad = INDICATORS, Valor = Value) %>%
  filter(Valor != ":") %>% 
  mutate(Valor = as.numeric(Valor)) %>%  #se introducen NA's al hacer numeric
  drop_na(Valor)

summary(data4)
table(data4$Producto)
as.numeric(data4$Valor)
table(data4$Pais)

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



#### 5.Covid ####
data5 = read.csv(pd5, sep = "|", dec = ",")
summary(data5) # NA's en pop y cumulative


data5 %<>% mutate(Date = dmy(dateRep)) %>% 
  select(c(Territory = countriesAndTerritories, Code = countryterritoryCode,
           Continent = continentExp, Date, Cases = cases, Death = deaths,
           Cumulative = Cumulative_number_for_14_days_of_COVID.19_cases_per_100000,
           Pop = popData2019)) %>%
  drop_na(Pop)
###
# No creo que necesitemos todos los territorios. 
# Los que no tienen población registrada eliminados sin miedo
###
str(data5)


