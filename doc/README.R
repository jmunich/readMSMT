## ----setup, include=FALSE-----------------------------------------------------
knitr::opts_chunk$set(echo = TRUE)
library(tidyverse)
library(readxl)
library(readMSMT)

## ---- eval=FALSE--------------------------------------------------------------
#  devtools::install_github("jmunich/readMSMT")

## -----------------------------------------------------------------------------
library(readMSMT)

## -----------------------------------------------------------------------------
## Pozn. pro práci se speciálními charaktery, jako jsou písmena s háčky, lze aktivovat funkci set_cz(), nebo její aktivaci specifikovat ve funkci form_codes(cz = TRUE). Funkce není nezbytná pro fungování balíčku 
set_cz()
guide <- form_codes()
print(guide)

## ---- eval = FALSE------------------------------------------------------------
#  map_folders()

## ---- eval = FALSE------------------------------------------------------------
#  map_folders(location = "E:/EDU/Data/data/MSMT/") ## Vložte vlastní adresu

## ---- eval = FALSE------------------------------------------------------------
#  my_map <- map_folders(location = "E:/EDU/Data/data/MSMT/", save_map = "E:/EDU/Data/", return_map = TRUE)

## ---- eval = FALSE------------------------------------------------------------
#  my_map <- map_folders(save_map = FALSE, return_map = TRUE)

## -----------------------------------------------------------------------------
my_map <- readRDS("E:/EDU/Data/MSMT_data_map.RDATA")

## ---- eval = FALSE------------------------------------------------------------
#  my_map <- readRDS("MSMT_data_map.RDATA")

## -----------------------------------------------------------------------------
my_map$meta_data

## -----------------------------------------------------------------------------
## Prvních třicet proměnných první tabulky
head(my_map$varlist[[1]], 30)

## -----------------------------------------------------------------------------
tibble_list <- get_variables(variables = c("r15013","r15013a"), # Vektor vyhledávaných proměnných
              map = my_map, # Mapa dat: není-li specifikována, funkce se ji pokusí najít v pracovním direktoriáři. Lze uvézt i adresu souboru obsahujícího mapu.
              joint = c("izo","red_izo"), # Názvy dalších proměnných, které budou zahrnuty do výběru. Defaultně obsahuje základní identifikátory
              forms = "v08", # Vektor (nebo samostatný character) určující žádoucí výkazy. Prázdný argument prohledá všechny výkazy
              years = c("12","13","14","15","16","17","18") # Vektor obsahující žádoucí roky. Prázdný argument prohledá všechny roky
              )

## -----------------------------------------------------------------------------
tibble_list$variables$v0812a_2
tibble_list$variables$v0813a_2

## -----------------------------------------------------------------------------
long_data <- dplyr::bind_rows(tibble_list$variables)
long_data

## -----------------------------------------------------------------------------
adresy<-read_excel("E:/EDU/Data/data/IZOCODES/Adresar.xlsx")%>%
  select(RED_IZO, Území, ORP)%>%
  mutate_all(as.character)
names(adresy)<-tolower(names(adresy))

joint <- left_join(long_data,adresy, by = "red_izo")
unique(joint$území)
print(joint)

## -----------------------------------------------------------------------------
ggplot(joint, aes(x = as.numeric(year), y=log(r15013), color=substr(území, 1,4), fill=substr(území, 1,4)))+
  geom_count()+theme(legend.position = "none")+geom_line(aes(group=red_izo))

