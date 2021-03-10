library(tidyverse)
library(magrittr)
library(lubridate)
#Comparamos los kilos comercializados del dataset 3 con la caída de
#turistas/ ocupacion de los hoteles

#Cargamos datasets mercados
df3_mad <- read.csv("../data/Dataset3a_Datos_MercaMadrid.txt", sep = "|", dec = ",")
df3_bcn <- read.csv("../data/Dataset3b_Datos_MercaBarna.txt", sep = "|", dec = ",")

#Cargamos datasets numero turístas
df_tur <- read.csv("../data/nturistas_comunidad.csv", sep = ";", dec=",")
#Separamos el string año + M + mes
df_tur <- df_tur %>% separate(Periodo, c("YEAR","MONTH"), sep = "M")
df_tur$YEAR <- as.numeric(df_tur$YEAR)
df_tur$MONTH <- as.numeric(df_tur$MONTH)
#Eliminamos los separadores de miles
df_tur$Total <- gsub('[.]', '', df_tur$Total)
df_tur$Total <- as.numeric(df_tur$Total)

#Cargamos datasetcovid con limpieza
data5 = read.csv("../data/Dataset5_Coronavirus_cases.txt", sep = "|", dec = ",")
summary(data5) # NA's en pop y cumulative

data5 %<>% mutate(Date = dmy(dateRep)) %>% 
  select(c(Territory = countriesAndTerritories, Code = countryterritoryCode,
           Continent = continentExp, Date, Cases = cases, Death = deaths,
           Cumulative = Cumulative_number_for_14_days_of_COVID.19_cases_per_100000,
           Pop = popData2019)) %>%
  drop_na(Pop)

#Filtramos por España
covid_spain <- data5 %>%
  filter(Territory=="Spain")
#Arreglamos la fecha para tenerla como en el otro formato PUTADE
covid_spain <- covid_spain %>%
  mutate(day = day(Date), MONTH = month(Date), YEAR = year(Date)) %>%
  group_by(MONTH,YEAR) %>%
  summarise(casos = sum(Cases))

#Voy a comprobar solo madrid y bcn
volume_mad <- df3_mad %>%
  select(product, YEAR, MONTH, Volumen) %>%
  group_by(YEAR, MONTH) %>%
  summarise(volume =sum(Volumen))

volume_bcn <- df3_bcn %>%
  select(product, YEAR, MONTH, Volumen) %>%
  group_by(YEAR, MONTH) %>%
  summarise(volume =sum(Volumen))

all_mad <- left_join(volume_mad, covid_spain)
all_mad <- all_mad %>% 
  mutate(fecha = make_date(year = YEAR, month = MONTH))
