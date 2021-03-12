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
library(ggplot2)

### Datasets ####

#### 1.Consumo ####
data1 = read.csv(pd1, sep = "|", dec = ",")
summary(data1) # 120 NA's en penetración

data1 %<>% select(c(Ano = ï..AÃ.o, Mes, CCAA, Producto,
                    Volumen = Volumen..miles.de.kg., Valor = Valor..miles.de.â... , 
                    Precio_Medio = Precio.medio.kg, Penetracion = `PenetraciÃ³n....`,
                    Cons_cpt = Consumo.per.capita, Gasto_cpt = Gasto.per.capita))

#### 4.Comercio Exterior ####
data4 = read.csv(pd4, sep = "|")
unique(data4$PARTNER) # Solo "ES"

data4 %<>% mutate(Inicio = my(ï..PERIOD)) %>%
  select(Inicio, Pais = REPORTER, Producto = PRODUCT,
         Accion = FLOW, Unidad = INDICATORS, Valor = Value) %>%
  filter(Valor != ":") %>% 
  mutate(Valor = as.numeric(Valor)) %>%  #se introducen NA's al hacer numeric
  drop_na(Valor)

summary(data4)
table(data4$Producto)
as.numeric(data4$Valor)
table(data4$Pais)

#### 5.Covid ####
data5 = read.csv(pd5, sep = "|", dec = ",")
summary(data5) # NA's en pop y cumulative


data5 %<>% mutate(Date = dmy(dateRep)) %>% 
  select(c(Territory = countriesAndTerritories, Code = countryterritoryCode,
           Continent = continentExp, Date, Cases = cases, Death = deaths,
           Cumulative = Cumulative_number_for_14_days_of_COVID.19_cases_per_100000,
           Pop = popData2019)) %>%
  drop_na(Pop)

str(data5)


## Exportaciones 
data4 %>% 
  mutate(Ano = year(Inicio)) %>%
  group_by(Pais, Ano, Accion, Unidad) %>% 
  summarise(total = sum(Valor)) -> pais_ano

pais_ano %>%
  filter(Pais == "Austria", Unidad == "VALUE_IN_EUROS") %>%
  ggplot(aes(x = Ano, y = total)) +
  geom_bar(stat = "identity") +
  facet_grid(.~Accion)

pais_ano %>%
  filter(Unidad == "VALUE_IN_EUROS", Accion == "IMPORT") %>%
  ggplot(aes(x = Ano, y = total)) +
  geom_bar(stat = "identity") +
  facet_grid(.~Pais)

pais_ano %>%
  filter(stringr::str_starts(Pais, "Fr"), Unidad == "VALUE_IN_EUROS") %>%
  ggplot(aes(x = Ano, y = total)) +
  geom_bar(stat = "identity") +
  facet_grid(.~Accion)

data4 %>% 
  mutate(Ano = year(Inicio)) %>%
  group_by(Pais, Ano, Accion, Unidad, Producto) %>% 
  summarise(total = sum(Valor)) %>%
  filter(stringr::str_starts(Producto, "Tomatoes"), Unidad == "VALUE_IN_EUROS") %>%
  facet_grid(.~Accion)
