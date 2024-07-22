standardize_ASCCEG <- function() {
  start_time <- Sys.time()
  
  library(readxl)
  library(tidyverse)
  library(openssl)
  library(dplyr)
  library(here)
  
  base_path <- here()
  scripts_path <- file.path(base_path, "Scripts", "data_Download.R")
  source(scripts_path)
  dest_path <- file.path(base_path, "Classifications", "DEMOGRAPHIC_ASCCEG", "Download")
  extract_path <- file.path(base_path, "Classifications", "DEMOGRAPHIC_ASCCEG", "Input")

  url <- "https://www.abs.gov.au/statistics/classifications/australian-standard-classification-cultural-and-ethnic-groups-ascceg/2019/12490do0001_201912.xls"
  download_file(url, dest_path, extract_path, "12490do0001_201912.xls")

  Data <- read_excel(file.path(base_path, "Classifications", "DEMOGRAPHIC_ASCCEG", "Input", "12490do0001_201912.xls"), sheet = "Table 1.3", skip = 4)
  Supplementary_Data <- read_excel(file.path(base_path, "Classifications", "DEMOGRAPHIC_ASCCEG", "Input", "12490do0001_201912.xls"), sheet = "Table 2", skip = 3)
  
  colnames(Data) <- c("Broad_Group", "Narrow_Group","Group_Code","Cultural_Ethnic_Group")
  colnames(Supplementary_Data) <- c("Supplementary_Code", "Code_Description")

  Broad_Group <- Data %>% select(Broad_Group,Narrow_Group) %>% filter(!is.na(Broad_Group) & !is.na(Narrow_Group))
  Narrow_Group <- Data %>% select(Narrow_Group,Group_Code) %>% filter(!is.na(Narrow_Group) & !is.na(Group_Code))
  Cultural_Ethnic_Group <- Data %>% select(Group_Code, Cultural_Ethnic_Group) %>% filter(!is.na(Group_Code) & !is.na(Cultural_Ethnic_Group))
  Supplementary_Group <- Supplementary_Data %>% filter(!is.na(Supplementary_Code) & !is.na(Code_Description))

  Broad_Group$Broad_Group_Date <- today()
  Narrow_Group$Narrow_Group_Date <- today()
  Cultural_Ethnic_Group$Cultural_Ethnic_Group_Date <- today()
  Supplementary_Group$Supplementary_Group_Date <- today()

  Broad_Group$Broad_Group_Key <- openssl::md5(as.character(Broad_Group$Broad_Group))
  Narrow_Group$Narrow_Group_Key <- openssl::md5(as.character(Narrow_Group$Narrow_Group))
  Cultural_Ethnic_Group$Cultural_Ethnic_Group_Key <- openssl::md5(as.character(Cultural_Ethnic_Group$Cultural_Ethnic_Group))
  Supplementary_Group$Supplementary_Group_Key <- openssl::md5(as.character(Supplementary_Group$Supplementary_Code))

  Broad_Group <- Broad_Group %>% select(Broad_Group_Key, everything())
  Narrow_Group <- Narrow_Group %>% select(Narrow_Group_Key, everything())
  Cultural_Ethnic_Group <- Cultural_Ethnic_Group %>% select(Cultural_Ethnic_Group_Key, everything())
  Supplementary_Group <- Supplementary_Group %>% select(Supplementary_Group_Key, everything())
  
  write_csv(Broad_Group, file.path(base_path, "Classifications", "DEMOGRAPHIC_ASCCEG", "Output", "ASCCEG_Broad_Group.csv"))
  write_csv(Narrow_Group, file.path(base_path, "Classifications", "DEMOGRAPHIC_ASCCEG", "Output", "ASCCEG_Narrow_Group.csv"))
  write_csv(Cultural_Ethnic_Group, file.path(base_path, "Classifications", "DEMOGRAPHIC_ASCCEG", "Output", "ASCCEG_Cultural_Ethnic_Group.csv"))
  write_csv(Supplementary_Group, file.path(base_path, "Classifications", "DEMOGRAPHIC_ASCCEG", "Output", "ASCCEG_Supplementary_Group.csv"))
  
  end_time <- Sys.time()
  
  print("ASCCEG Task Complete")
  print(paste0("Time taken: ", end_time - start_time))
}

standardize_ASCCEG()