standardize_ASCED <- function() {
  start_time <- Sys.time()
  
  library(readxl)
  library(tidyverse)
  library(openssl)
  library(dplyr)
  library(here)

  base_path <- here()
  scripts_path <- here("Scripts", "data_Download.R")
  source(scripts_path)
  dest_path <- here("Classifications", "Education_ASCED", "Download")
  extract_path <- here("Classifications", "Education_ASCED", "Input")

  url <- "https://www.abs.gov.au/statistics/classifications/australian-standard-classification-education-asced/2001/1272.0%20australian%20standard%20classification%20of%20education%20%28asced%29%20structures.xlsx"
  download_file(url, dest_path, extract_path, "1272.0 australian standard classification of education (asced) structures.xlsx")

  Level_Data <- read_excel(here("Classifications", "Education_ASCED", "Input", "1272.0 australian standard classification of education (asced) structures.xlsx"), sheet = "Table 1", skip = 4)
  Field_Data <- read_excel(here("Classifications", "Education_ASCED", "Input", "1272.0 australian standard classification of education (asced) structures.xlsx"), sheet = "Table 2", skip = 4)
  
  colnames(Level_Data) <- c("Broad_Level","Narrow_Level","Detailed_Level", "Level_Description")
  colnames(Field_Data) <- c("Broad_Fields","Narrow_Fields","Detailed_Fields", "Field_Description")

  Broad_Level <- Level_Data %>% select(Broad_Level, Narrow_Level) %>% filter(!is.na(Broad_Level) & !is.na(Narrow_Level))
  Narrow_Level <- Level_Data %>% select(Narrow_Level, Detailed_Level) %>% filter(!is.na(Narrow_Level) & !is.na(Detailed_Level))
  Detailed_Level <- Level_Data %>% select(Detailed_Level, Level_Description) %>% filter(!is.na(Detailed_Level) & !is.na(Level_Description))

  Broad_Fields <- Field_Data %>% select(Broad_Fields, Narrow_Fields) %>% filter(!is.na(Broad_Fields) & !is.na(Narrow_Fields))
  Narrow_Fields <- Field_Data %>% select(Narrow_Fields, Detailed_Fields) %>% filter(!is.na(Narrow_Fields) & !is.na(Detailed_Fields))
  Detailed_Fields <- Field_Data %>% select(Detailed_Fields, Field_Description) %>% filter(!is.na(Detailed_Fields) & !is.na(Field_Description))

#add a Date column to all dataframes that has current Date
  Broad_Level$Broad_Level_Date <- today()
  Narrow_Level$Narrow_Level_Date <- today()
  Detailed_Level$Detailed_Level_Date <- today()

  Broad_Fields$Broad_Fields_Date <- today()
  Narrow_Fields$Narrow_Fields_Date <- today()
  Detailed_Fields$Detailed_Fields_Date <- today()

  Broad_Level$Broad_Level_Key <- openssl::md5(as.character(Broad_Level$Broad_Level))
  Narrow_Level$Narrow_Level_Key <- openssl::md5(as.character(Narrow_Level$Narrow_Level))
  Detailed_Level$Detailed_Level_Key <- openssl::md5(as.character(Detailed_Level$Detailed_Level))

  Broad_Fields$Broad_Fields_Key <- openssl::md5(as.character(Broad_Fields$Broad_Fields))
  Narrow_Fields$Narrow_Fields_Key <- openssl::md5(as.character(Narrow_Fields$Narrow_Fields))
  Detailed_Fields$Detailed_Fields_Key <- openssl::md5(as.character(Detailed_Fields$Detailed_Fields))

  Broad_Level <- Broad_Level %>% select(Broad_Level_Key, everything())
  Narrow_Level <- Narrow_Level %>% select(Narrow_Level_Key, everything())
  Detailed_Level <- Detailed_Level %>% select(Detailed_Level_Key, everything())

  Broad_Fields <- Broad_Fields %>% select(Broad_Fields_Key, everything())
  Narrow_Fields <- Narrow_Fields %>% select(Narrow_Fields_Key, everything())
  Detailed_Fields <- Detailed_Fields %>% select(Detailed_Fields_Key, everything())

#write to CSV
  write_csv(Broad_Level, here("Classifications", "Education_ASCED", "Output", "ASCED_Broad_Level.csv"))
  write_csv(Narrow_Level, here("Classifications", "Education_ASCED", "Output", "ASCED_Narrow_Level.csv"))
  write_csv(Detailed_Level, here("Classifications", "Education_ASCED", "Output", "ASCED_Detailed_Level.csv"))

  write_csv(Broad_Fields, here("Classifications", "Education_ASCED", "Output", "ASCED_Broad_Fields.csv"))
  write_csv(Narrow_Fields, here("Classifications", "Education_ASCED", "Output", "ASCED_Narrow_Fields.csv"))
  write_csv(Detailed_Fields, here("Classifications", "Education_ASCED", "Output", "ASCED_Detailed_Fields.csv"))
  
  end_time <- Sys.time()
  
  print("ASCED Task Complete")
  print(paste0("Time taken: ", end_time - start_time))
}

standardize_ASCED()