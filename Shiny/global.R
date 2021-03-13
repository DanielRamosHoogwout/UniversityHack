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

#### 5.Covid ####
data5 = read.csv(pd5, sep = "|", dec = ",")

data5 %<>% mutate(Date = dmy(dateRep)) %>% 
  select(c(Territory = countriesAndTerritories, Code = countryterritoryCode,
           Continent = continentExp, Date, Cases = cases, Death = deaths,
           Cumulative = Cumulative_number_for_14_days_of_COVID.19_cases_per_100000,
           Pop = popData2019)) %>%
  drop_na(Pop)


### Comercio Exterior #####

pais_ano %>%
  filter(stringr::str_starts(Pais, "Germany"), Unidad == "VALUE_IN_EUROS") %>%
  ggplot(aes(x = Ano, y = total)) +
  geom_bar(stat = "identity") +
  facet_grid(.~Accion)