library(tidyverse)
library(magrittr)
library(lubridate)
#Comparamos los kilos comercializados del dataset 3 con la caída de
#turistas/ ocupacion de los hoteles

#Cargamos datasets mercados
df3_mad <- read.csv("../data/Dataset3a_Datos_MercaMadrid.txt", sep = "|", dec = ",")
df3_bcn <- read.csv("../data/Dataset3b_Datos_MercaBarna.txt", sep = "|", dec = ",")
df2 <- read.csv("../data/Dataset2.- Precios Semanales Observatorio de Precios Junta de Andalucia.txt", sep = "|", dec = ",")

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

#Unimos madrid y covid
all_mad <- left_join(volume_mad, covid_spain)
all_mad <- all_mad %>% 
  mutate(fecha = make_date(year = YEAR, month = MONTH))
#Cambiamos NA por 0
all_mad$casos <- ifelse(is.na(all_mad$casos),0,all_mad$casos)
#Normalizamos entre 0 y 1
all_mad$volume <- (all_mad$volume-min(all_mad$volume))/(max(all_mad$volume)-min(all_mad$volume))
all_mad$casos <- (all_mad$casos-min(all_mad$casos))/(max(all_mad$casos)-min(all_mad$casos))

all_mad %>% ggplot(aes(x=fecha, y=volume)) +
  geom_line(col= 'red')+
  geom_point() +
  geom_line(aes(y = casos))

#Unimos madrid y turistas
df_tur <- df_tur %>%
  filter(Comunidades.autónomas=="Total")
all_tur <- left_join(volume_mad, df_tur)
all_tur <- all_tur %>% 
  mutate(fecha = make_date(year = YEAR, month = MONTH))

#Normalizamos entre 0 y 1
all_tur$volume <- (all_tur$volume-min(all_tur$volume))/(max(all_tur$volume)-min(all_tur$volume))
all_tur$Total <- (all_tur$Total-min(all_tur$Total))/(max(all_tur$Total)-min(all_tur$Total))

all_tur %>% ggplot(aes(x=fecha, y=volume)) +
  geom_line(col= 'red')+
  geom_point() +
  geom_line(aes(y = Total))
cor(all_tur$volume,all_tur$Total)

#Dataset 2

cebolla <- df2 %>% filter(PRODUCTO=="CEBOLLA", POSICION=="Mercas")
cebolla$FIN <- parse_date(cebolla$FIN, "%d/%m/%Y")
cebolla <- cebolla %>%
  mutate(MONTH = month(FIN), YEAR = year(FIN))

cebolla <- cebolla %>%
  group_by(MONTH,YEAR) %>%
  summarise(precio = mean(PRECIO))

#Precio cebolla vs Mercamadrid
cebolla_mad <- left_join(volume_mad, cebolla)
cebolla_mad <- cebolla_mad %>% 
  mutate(fecha = make_date(year = YEAR, month = MONTH))
cebolla_mad$volume <- (cebolla_mad$volume-min(cebolla_mad$volume))/(max(cebolla_mad$volume)-min(cebolla_mad$volume))
cebolla_mad$precio <- (cebolla_mad$precio-min(cebolla_mad$precio))/(max(cebolla_mad$precio)-min(cebolla_mad$precio))

cebolla_mad %>% ggplot(aes(x=fecha, y=volume)) +
  geom_line(col= 'red')+
  geom_point() +
  geom_line(aes(y = precio))

#Precio cebolla vs covid
cebolla_covid <- left_join(cebolla, covid_spain)
cebolla_covid$casos <- ifelse(is.na(cebolla_covid$casos),0,cebolla_covid$casos)
cebolla_covid <- cebolla_covid %>% 
  mutate(fecha = make_date(year = YEAR, month = MONTH))

cebolla_covid$casos <- (cebolla_covid$casos-min(cebolla_covid$casos))/(max(cebolla_covid$casos)-min(cebolla_covid$casos))
cebolla_covid$precio <- (cebolla_covid$precio-min(cebolla_covid$precio))/(max(cebolla_covid$precio)-min(cebolla_covid$precio))

cebolla_covid %>% ggplot(aes(x=fecha, y=precio)) +
  geom_line(col= 'red')+
  geom_point() +
  geom_line(aes(y = casos))
#######################################################################

cebolla <- df2 %>% filter(PRODUCTO=="AGUACATE", POSICION=="Mercas")
cebolla$FIN <- parse_date(cebolla$FIN, "%d/%m/%Y")
cebolla <- cebolla %>%
  mutate(MONTH = month(FIN), YEAR = year(FIN))

cebolla <- cebolla %>%
  group_by(MONTH,YEAR) %>%
  summarise(precio = mean(PRECIO))

#Precio cebolla vs Mercamadrid
cebolla_mad <- left_join(volume_mad, cebolla)
cebolla_mad <- cebolla_mad %>% 
  mutate(fecha = make_date(year = YEAR, month = MONTH))
cebolla_mad$volume <- (cebolla_mad$volume-min(cebolla_mad$volume))/(max(cebolla_mad$volume)-min(cebolla_mad$volume))
cebolla_mad$precio <- (cebolla_mad$precio-min(cebolla_mad$precio))/(max(cebolla_mad$precio)-min(cebolla_mad$precio))

cebolla_mad %>% ggplot(aes(x=fecha, y=volume)) +
  geom_line(col= 'red')+
  geom_point() +
  geom_line(aes(y = precio))

#Precio cebolla vs covid
cebolla_covid <- left_join(cebolla, covid_spain)
cebolla_covid$casos <- ifelse(is.na(cebolla_covid$casos),0,cebolla_covid$casos)
cebolla_covid <- cebolla_covid %>% 
  mutate(fecha = make_date(year = YEAR, month = MONTH))

cebolla_covid$casos <- (cebolla_covid$casos-min(cebolla_covid$casos))/(max(cebolla_covid$casos)-min(cebolla_covid$casos))
cebolla_covid$precio <- (cebolla_covid$precio-min(cebolla_covid$precio))/(max(cebolla_covid$precio)-min(cebolla_covid$precio))

cebolla_covid %>% ggplot(aes(x=fecha, y=precio)) +
  geom_line(col= 'red')+
  geom_point() +
  geom_line(aes(y = casos))

##################################
#Turismo covid OJO CON EL DF_TUR tiene que estar recien cargado
df_tur %<>% filter(Comunidades.autónomas=="04 Balears, Illes")
tur_covid <- left_join(df_tur, covid_spain)
tur_covid$casos <- ifelse(is.na(tur_covid$casos),0,tur_covid$casos)
tur_covid <- tur_covid %>% 
  mutate(fecha = make_date(year = YEAR, month = MONTH))

tur_covid$casos <- (tur_covid$casos-min(tur_covid$casos))/(max(tur_covid$casos)-min(tur_covid$casos))
tur_covid$Total <- (tur_covid$Total-min(tur_covid$Total))/(max(tur_covid$Total)-min(tur_covid$Total))

tur_covid %>% ggplot(aes(x=fecha, y=Total)) +
  geom_line(col= 'red')+
  geom_point() +
  geom_line(aes(y = casos))

######################################
#Cluster
####################################

verduras <- df2 %>% filter(POSICION=="Mercas")
verduras$FIN <- parse_date(verduras$FIN, "%d/%m/%Y")
verduras <- verduras %>%
  mutate(MONTH = month(FIN), YEAR = year(FIN))

verduras <- verduras %>%
  group_by(MONTH,YEAR,PRODUCTO) %>%
  summarise(precio = mean(PRECIO))

#Precio verduras vs Mercamadrid
verduras_mad <- left_join(volume_mad, verduras)
