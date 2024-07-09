library(readxl)
library(tidyverse)
library(openssl)
library(dplyr)

#function to import csv 
import_csv <- function (path) {
  data <- read_csv(path)
  return(data)
}

#download zip file from address and then extract to path
# download_extract_zip <- function (url, path) {
#   download.file(url, "temp.zip")
#   unzip("temp.zip", exdir = path)
#   #delete the zip file
#   file.remove("temp.zip")
# }
# download_extract_zip("https://www.abs.gov.au/AUSSTATS/subscriber.nsf/log?openagent&1270055001_mb_2016_nsw_csv.zip&1270.0.55.001&Data%20Cubes&1FC672E70A77D52FCA257FED0013A0F7&0&July%202016&12.07.2016&Latest", "C:/Users/joshu/OneDrive/Documents/GIthub/abs/Classifications/LOCATION_ASGS/Input/")

#import all states meshblock lists
NSW <- import_csv("C:/Users/joshu/OneDrive/Documents/GIthub/abs/Classifications/LOCATION_ASGS/Input/MB_2016_NSW.csv")
VIC <- import_csv("C:/Users/joshu/OneDrive/Documents/GIthub/abs/Classifications/LOCATION_ASGS/Input/MB_2016_VIC.csv")
QLD <- import_csv("C:/Users/joshu/OneDrive/Documents/GIthub/abs/Classifications/LOCATION_ASGS/Input/MB_2016_QLD.csv")
SA <- import_csv("C:/Users/joshu/OneDrive/Documents/GIthub/abs/Classifications/LOCATION_ASGS/Input/MB_2016_SA.csv")
WA <- import_csv("C:/Users/joshu/OneDrive/Documents/GIthub/abs/Classifications/LOCATION_ASGS/Input/MB_2016_WA.csv")
TAS <- import_csv("C:/Users/joshu/OneDrive/Documents/GIthub/abs/Classifications/LOCATION_ASGS/Input/MB_2016_TAS.csv")
NT <- import_csv("C:/Users/joshu/OneDrive/Documents/GIthub/abs/Classifications/LOCATION_ASGS/Input/MB_2016_NT.csv")
ACT <- import_csv("C:/Users/joshu/OneDrive/Documents/GIthub/abs/Classifications/LOCATION_ASGS/Input/MB_2016_ACT.csv")
OT <- import_csv("C:/Users/joshu/OneDrive/Documents/GIthub/abs/Classifications/LOCATION_ASGS/Input/MB_2016_OT.csv")

#create lists of all states
states <- list(NSW, VIC, QLD, SA, WA, TAS, NT, ACT, OT)
#read data function to split into 7 subsections, one for,MB, SA1, SA2, SA3, SA4, GCCSA and State, with the  being unique

read_data <- function(data) {
  Meshblock <- data %>% select(MB_CODE_2016, MB_CATEGORY_NAME_2016, SA1_MAINCODE_2016)
  SA1 <- data %>% select(SA1_MAINCODE_2016, SA1_7DIGITCODE_2016, SA2_MAINCODE_2016, SA2_5DIGITCODE_2016, SA2_NAME_2016)
  SA2 <- data %>% select(SA2_MAINCODE_2016, SA2_5DIGITCODE_2016, SA2_NAME_2016, SA3_CODE_2016, SA3_NAME_2016)
  SA3 <- data %>% select(SA3_CODE_2016, SA3_NAME_2016, SA4_CODE_2016, SA4_NAME_2016, GCCSA_CODE_2016, GCCSA_NAME_2016, STATE_CODE_2016, STATE_NAME_2016)
  SA4 <- data %>% select(SA4_CODE_2016, SA4_NAME_2016, GCCSA_CODE_2016, GCCSA_NAME_2016, STATE_CODE_2016, STATE_NAME_2016)
  GCCSA <- data %>% select(GCCSA_CODE_2016, GCCSA_NAME_2016, STATE_CODE_2016, STATE_NAME_2016)
  #get unique state code and name
  State <- data %>% select(STATE_CODE_2016,STATE_NAME_2016)
  return(list(Meshblock, SA1, SA2, SA3, SA4, GCCSA, State))
}
#apply read_data function to all states
states <- lapply(states, read_data)
#collate all the SA1,SA2,SA3,SA4,GCCSA and State dataframes into dataframes for each 
#only get unique values

SA1 <- bind_rows(lapply(states, function(x) x[[2]])) %>% distinct()
SA2 <- bind_rows(lapply(states, function(x) x[[3]])) %>% distinct()
SA3 <- bind_rows(lapply(states, function(x) x[[4]])) %>% distinct()
SA4 <- bind_rows(lapply(states, function(x) x[[5]])) %>% distinct()
GCCSA <- bind_rows(lapply(states, function(x) x[[6]])) %>% distinct()
State <- bind_rows(lapply(states, function(x) x[[7]])) %>% distinct()
#add a Date column to all dataframes that has current Date
SA1$SA1_Date <- today()
SA2$SA2_Date <- today()
SA3$SA3_Date <- today()
SA4$SA4_Date <- today()
GCCSA$GCCSA_Date <- today()
State$State_Date <- today()

#create a column in front for the ssl md5 hash called SA1_Key
SA1$SA1_Key <- openssl::md5(as.character(SA1$SA1_MAINCODE_2016))
SA2$SA2_Key <- openssl::md5(as.character(SA2$SA2_MAINCODE_2016))
SA3$SA3_Key <- openssl::md5(as.character(SA3$SA3_CODE_2016))
SA4$SA4_Key <- openssl::md5(as.character(SA4$SA4_CODE_2016))
GCCSA$GCCSA_Key <- openssl::md5(as.character(GCCSA$GCCSA_CODE_2016))
State$State_Key <- openssl::md5(as.character(State$STATE_CODE_2016))

SA1 <- SA1 %>% select(SA1_Key, everything())
SA2 <- SA2 %>% select(SA2_Key, everything())
SA3 <- SA3 %>% select(SA3_Key, everything())
SA4 <- SA4 %>% select(SA4_Key, everything())
GCCSA <- GCCSA %>% select(GCCSA_Key, everything())
State <- State %>% select(State_Key, everything())
#collate meshblock dataframes into one
Meshblock <- bind_rows(lapply(states, function(x) x[[1]]))
Meshblock$Meshblock_Date <- today()
#create a new column for the ssl md5 hash called Key that adds the MB code and SA1 code
Meshblock$Meshblock_Key <- openssl::md5(as.character(Meshblock$MB_CODE_2016))
Meshblock <- Meshblock %>% select(Meshblock_Key, everything())
#write to CSV
write_csv(SA1, "C:/Users/joshu/OneDrive/Documents/GIthub/abs/Classifications/LOCATION_ASGS/Output/ASGS_SA1.csv")
write_csv(SA2, "C:/Users/joshu/OneDrive/Documents/GIthub/abs/Classifications/LOCATION_ASGS/Output/ASGS_SA2.csv")
write_csv(SA3, "C:/Users/joshu/OneDrive/Documents/GIthub/abs/Classifications/LOCATION_ASGS/Output/ASGS_SA3.csv")
write_csv(SA4, "C:/Users/joshu/OneDrive/Documents/GIthub/abs/Classifications/LOCATION_ASGS/Output/ASGS_SA4.csv")
write_csv(GCCSA, "C:/Users/joshu/OneDrive/Documents/GIthub/abs/Classifications/LOCATION_ASGS/Output/ASGS_GCCSA.csv")
write_csv(State, "C:/Users/joshu/OneDrive/Documents/GIthub/abs/Classifications/LOCATION_ASGS/Output/ASGS_State.csv")
write_csv(Meshblock, "C:/Users/joshu/OneDrive/Documents/GIthub/abs/Classifications/LOCATION_ASGS/Output/ASGS_MB.csv")
#TODO
#AUTOMATE DOWNLOAD & EXTRACTION OF CSV


