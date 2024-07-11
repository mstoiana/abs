standardize_MB <- function(base_path) {
  start_time <- Sys.time()

  library(readxl)
  library(tidyverse)
  library(openssl)
  library(dplyr)
  library(readr)

  scripts_path <- paste0(base_path, "/Scripts/data_Download.R")
  source(scripts_path)
  dest_path <- paste0(base_path, "Classifications/LOCATION_ASGS/Download/")
  extract_path <- paste0(base_path, "Classifications/LOCATION_ASGS/Input/")

  url_from_excel(paste0(base_path, "Classifications/LOCATION_ASGS/Download/MB_Data_source.xlsx"), dest_path, extract_path)
  url_from_excel(paste0(base_path, "Classifications/LOCATION_ASGS/Download/LGA_Data_source.xlsx"), dest_path, extract_path)
  
 
  import_csv <- function(file_path) {
    data <- read_csv(file_path)
    return(data)
  }

#import all states meshblock lists
  NSW <- import_csv(paste0(base_path, "Classifications/LOCATION_ASGS/Input/MB_2016_NSW.csv"))
  VIC <- import_csv(paste0(base_path, "Classifications/LOCATION_ASGS/Input/MB_2016_VIC.csv"))
  QLD <- import_csv(paste0(base_path, "Classifications/LOCATION_ASGS/Input/MB_2016_QLD.csv"))
  SA <- import_csv(paste0(base_path, "Classifications/LOCATION_ASGS/Input/MB_2016_SA.csv"))
  WA <- import_csv(paste0(base_path, "Classifications/LOCATION_ASGS/Input/MB_2016_WA.csv"))
  TAS <- import_csv(paste0(base_path, "Classifications/LOCATION_ASGS/Input/MB_2016_TAS.csv"))
  NT <- import_csv(paste0(base_path, "Classifications/LOCATION_ASGS/Input/MB_2016_NT.csv"))
  ACT <- import_csv(paste0(base_path, "Classifications/LOCATION_ASGS/Input/MB_2016_ACT.csv"))
  OT <- import_csv(paste0(base_path, "Classifications/LOCATION_ASGS/Input/MB_2016_OT.csv"))

#import all LGA lists
  LGA_NSW <- import_csv(paste0(base_path, "Classifications/LOCATION_ASGS/Input/LGA_2020_NSW.csv"))
  LGA_VIC <- import_csv(paste0(base_path, "Classifications/LOCATION_ASGS/Input/LGA_2020_VIC.csv"))
  LGA_QLD <- import_csv(paste0(base_path, "Classifications/LOCATION_ASGS/Input/LGA_2020_QLD.csv"))
  LGA_SA <- import_csv(paste0(base_path, "Classifications/LOCATION_ASGS/Input/LGA_2020_SA.csv"))
  LGA_WA <- import_csv(paste0(base_path, "Classifications/LOCATION_ASGS/Input/LGA_2020_WA.csv"))
  LGA_TAS <- import_csv(paste0(base_path, "Classifications/LOCATION_ASGS/Input/LGA_2020_TAS.csv"))
  LGA_NT <- import_csv(paste0(base_path, "Classifications/LOCATION_ASGS/Input/LGA_2020_NT.csv"))
  LGA_ACT <- import_csv(paste0(base_path, "Classifications/LOCATION_ASGS/Input/LGA_2020_ACT.csv"))
  LGA_OT <- import_csv(paste0(base_path, "Classifications/LOCATION_ASGS/Input/LGA_2020_OT.csv"))

#Import non abs data
  UCL_Data <- import_csv(paste0(base_path, "Classifications/LOCATION_ASGS/Input/SA1_UCL_SOSR_SOS_2016_AUST.csv"))
  SUA_Data <- import_csv(paste0(base_path, "Classifications/LOCATION_ASGS/Input/SA2_SUA_2016_AUST.csv"))

  SA1_UCL <- UCL_Data %>% select(SA1_MAINCODE_2016, SA1_7DIGITCODE_2016, UCL_CODE_2016,UCL_NAME_2016, SOSR_CODE_2016, SOSR_NAME_2016, SOS_CODE_2016, SOS_NAME_2016)
  SA2_SUA <- SUA_Data %>% select(SA2_MAINCODE_2016, SA2_5DIGITCODE_2016, SA2_NAME_2016, SUA_CODE_2016, SUA_NAME_2016)
  SOSR <- UCL_Data %>% select(SOSR_CODE_2016, SOSR_NAME_2016, SOS_CODE_2016, SOS_NAME_2016)

#create lists of all states
  states <- list(NSW, VIC, QLD, SA, WA, TAS, NT, ACT, OT)

#list of all LGAs
  LGAs <- list(LGA_NSW, LGA_VIC, LGA_QLD, LGA_SA, LGA_WA, LGA_TAS, LGA_NT, LGA_ACT, LGA_OT)

#read data function to split into 7 subsections, one for,MB, SA1, SA2, SA3, SA4, GCCSA and State, with the  being unique
  read_data <- function(data) {
    Meshblock <- data %>% select(MB_CODE_2016, MB_CATEGORY_NAME_2016, SA1_MAINCODE_2016)
    SA1 <- data %>% select(SA1_MAINCODE_2016, SA1_7DIGITCODE_2016, SA2_MAINCODE_2016, SA2_5DIGITCODE_2016)
    SA2 <- data %>% select(SA2_MAINCODE_2016, SA2_5DIGITCODE_2016, SA2_NAME_2016, SA3_CODE_2016)
    SA3 <- data %>% select(SA3_CODE_2016, SA3_NAME_2016, SA4_CODE_2016, SA4_NAME_2016, GCCSA_CODE_2016, GCCSA_NAME_2016, STATE_CODE_2016)
    SA4 <- data %>% select(SA4_CODE_2016, SA4_NAME_2016, GCCSA_CODE_2016, GCCSA_NAME_2016, STATE_CODE_2016)
    GCCSA <- data %>% select(GCCSA_CODE_2016, GCCSA_NAME_2016, STATE_CODE_2016)
   #get unique state code and name
    State <- data %>% select(STATE_CODE_2016,STATE_NAME_2016)
    return(list(Meshblock, SA1, SA2, SA3, SA4, GCCSA, State))
  }

#apply read_data function to all states
  states <- lapply(states, read_data)

#collate all the LGA dataframes into one
  LGA <- bind_rows(LGAs) %>% distinct()
  LGA <- LGA %>% select(LGA_CODE_2020, LGA_NAME_2020, MB_CODE_2016,STATE_CODE_2016)

#collate all the SA1,SA2,SA3,SA4,GCCSA and State dataframes into dataframes for each 
#only get unique values
  SA1 <- bind_rows(lapply(states, function(x) x[[2]])) %>% distinct()
  SA2 <- bind_rows(lapply(states, function(x) x[[3]])) %>% distinct()
  SA3 <- bind_rows(lapply(states, function(x) x[[4]])) %>% distinct()
  SA4 <- bind_rows(lapply(states, function(x) x[[5]])) %>% distinct()
  GCCSA <- bind_rows(lapply(states, function(x) x[[6]])) %>% distinct()
  State <- bind_rows(lapply(states, function(x) x[[7]])) %>% distinct()
#distinct the other dataframes
  SA1_UCL <- SA1_UCL %>% distinct()
  SA2_SUA <- SA2_SUA %>% distinct()
  SOSR <- SOSR %>% distinct()
#collate meshblock dataframes into one
  Meshblock <- bind_rows(lapply(states, function(x) x[[1]]))
#add a Date column to all dataframes that has current Date
  SA1$SA1_Date <- today()
  SA2$SA2_Date <- today()
  SA3$SA3_Date <- today()
  SA4$SA4_Date <- today()
  GCCSA$GCCSA_Date <- today()
  State$State_Date <- today()
  SA1_UCL$SA1_UCL_Date <- today()
  SA2_SUA$SA2_SUA_Date <- today()
  SOSR$SOSR_Date <- today()
  Meshblock$Meshblock_Date <- today()
  LGA$LGA_Date <- today()

#create a column in front for the ssl md5 hash called SA1_Key
  SA1$SA1_Key <- openssl::md5(as.character(SA1$SA1_MAINCODE_2016))
  SA2$SA2_Key <- openssl::md5(as.character(SA2$SA2_MAINCODE_2016))
  SA3$SA3_Key <- openssl::md5(as.character(SA3$SA3_CODE_2016))
  SA4$SA4_Key <- openssl::md5(as.character(SA4$SA4_CODE_2016))
  GCCSA$GCCSA_Key <- openssl::md5(as.character(GCCSA$GCCSA_CODE_2016))
  State$State_Key <- openssl::md5(as.character(State$STATE_CODE_2016))
  SA1_UCL$SA1_UCL_Key <- openssl::md5(as.character(SA1_UCL$SA1_MAINCODE_2016))
  SA2_SUA$SA2_SUA_Key <- openssl::md5(as.character(SA2_SUA$SA2_MAINCODE_2016))
  SOSR$SOSR_Key <- openssl::md5(as.character(SOSR$SOSR_CODE_2016))
  Meshblock$Meshblock_Key <- openssl::md5(as.character(Meshblock$MB_CODE_2016))
  LGA$LGA_Key <- openssl::md5(as.character(LGA$LGA_CODE_2020))

  SA1 <- SA1 %>% select(SA1_Key, everything())
  SA2 <- SA2 %>% select(SA2_Key, everything())
  SA3 <- SA3 %>% select(SA3_Key, everything())
  SA4 <- SA4 %>% select(SA4_Key, everything())
  GCCSA <- GCCSA %>% select(GCCSA_Key, everything())
  State <- State %>% select(State_Key, everything())
  SA1_UCL <- SA1_UCL %>% select(SA1_UCL_Key, everything())
  SA2_SUA <- SA2_SUA %>% select(SA2_SUA_Key, everything())
  SOSR <- SOSR %>% select(SOSR_Key, everything())
  Meshblock <- Meshblock %>% select(Meshblock_Key, everything())
  LGA <- LGA %>% select(LGA_Key, everything())

#write to CSV
  write_csv(LGA, paste0(base_path, "Classifications/LOCATION_ASGS/Output/ASGS_LGA.csv"))
  write_csv(SA1, paste0(base_path, "Classifications/LOCATION_ASGS/Output/ASGS_SA1.csv"))
  write_csv(SA2, paste0(base_path, "Classifications/LOCATION_ASGS/Output/ASGS_SA2.csv"))
  write_csv(SA3, paste0(base_path, "Classifications/LOCATION_ASGS/Output/ASGS_SA3.csv"))
  write_csv(SA4, paste0(base_path, "Classifications/LOCATION_ASGS/Output/ASGS_SA4.csv"))
  write_csv(GCCSA, paste0(base_path, "Classifications/LOCATION_ASGS/Output/ASGS_GCCSA.csv"))
  write_csv(State, paste0(base_path, "Classifications/LOCATION_ASGS/Output/ASGS_State.csv"))
  write_csv(SA1_UCL, paste0(base_path, "Classifications/LOCATION_ASGS/Output/ASGS_SA1_UCL.csv"))
  write_csv(SA2_SUA, paste0(base_path, "Classifications/LOCATION_ASGS/Output/ASGS_SA2_SUA.csv"))
  write_csv(SOSR, paste0(base_path, "Classifications/LOCATION_ASGS/Output/ASGS_SOSR.csv"))
  write_csv(Meshblock, paste0(base_path, "Classifications/LOCATION_ASGS/Output/ASGS_Meshblock.csv"))
 
  end_time <- Sys.time()
 
  print("MB Task Complete")
  print(paste0("Time taken: ", end_time - start_time))
}

standardize_MB("C:/Users/Josh/OneDrive/Documents/GIthub/abs/")

