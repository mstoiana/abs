standardize_ASCRG <- function() {
  start_time <- Sys.time()

  library(readxl)
  library(tidyverse)
  library(openssl)
  library(dplyr)
  library(here)
  
  base_path <- here()
  scripts_path <- here("Scripts", "data_Download.R")
  source(scripts_path)
  dest_path <- here("Classifications", "DEMOGRAPHIC_ASCRG", "Download")
  extract_path <- here("Classifications", "DEMOGRAPHIC_ASCRG", "Input")

  url <- "https://www.abs.gov.au/statistics/classifications/australian-standard-classification-religious-groups/mar-2024/ASCRG_12660DO0001_202303.xlsx"
  download_file(url, dest_path, extract_path, "ASCRG_12660DO0001_202303.xlsx")

  Data <- read_excel(here("Classifications", "DEMOGRAPHIC_ASCRG", "Input", "ASCRG_12660DO0001_202303.xlsx"), sheet = "Table 1.3", skip = 4)
  Supplementary_Data <- read_excel(here("Classifications", "DEMOGRAPHIC_ASCRG", "Input", "ASCRG_12660DO0001_202303.xlsx"), sheet = "Table 2", skip = 4)
  
  colnames(Data) <- c("Broad_Group", "Narrow_Group","Group_Code","Religious_Group")
  colnames(Supplementary_Data) <- c("Supplementary_Code", "Supplementary_Label")

  Broad_Group <- Data %>% select(Broad_Group,Narrow_Group) %>% filter(!is.na(Broad_Group) & !is.na(Narrow_Group))
  Narrow_Group <- Data %>% select(Narrow_Group,Group_Code) %>% filter(!is.na(Narrow_Group) & !is.na(Group_Code))
  Religious_Group <- Data %>% select(Group_Code, Religious_Group) %>% filter(!is.na(Group_Code) & !is.na(Religious_Group))
  Supplementary_Data <- Supplementary_Data %>% filter(!is.na(Supplementary_Code) & !is.na(Supplementary_Label))
  
  Broad_Group$Broad_Group_Date <- today()
  Narrow_Group$Narrow_Group_Date <- today()
  Religious_Group$Religious_Group_Date <- today()
  Supplementary_Data$Supplementary_Date <- today()

  Broad_Group$Broad_Group_Key <- openssl::md5(as.character(Broad_Group$Broad_Group))
  Narrow_Group$Narrow_Group_Key <- openssl::md5(as.character(Narrow_Group$Narrow_Group))
  Religious_Group$Religious_Group_Key <- openssl::md5(as.character(Religious_Group$Religious_Group))
  Supplementary_Data$Supplementary_Key <- openssl::md5(as.character(Supplementary_Data$Supplementary_Code))

  Broad_Group <- Broad_Group %>% select(Broad_Group_Key, everything())
  Narrow_Group <- Narrow_Group %>% select(Narrow_Group_Key, everything())
  Religious_Group <- Religious_Group %>% select(Religious_Group_Key, everything())
  Supplementary_Data <- Supplementary_Data %>% select(Supplementary_Key, everything())

  write_csv(Broad_Group, here("Classifications", "DEMOGRAPHIC_ASCRG", "Output", "ASCRG_Broad_Group.csv"))
  write_csv(Narrow_Group, here("Classifications", "DEMOGRAPHIC_ASCRG", "Output", "ASCRG_Narrow_Group.csv"))
  write_csv(Religious_Group, here("Classifications", "DEMOGRAPHIC_ASCRG", "Output", "ASCRG_Religious_Group.csv"))
  write_csv(Supplementary_Data, here("Classifications", "DEMOGRAPHIC_ASCRG", "Output", "ASCRG_Supplementary_Data.csv"))
  
  end_time <- Sys.time()
  
  print("ASCRG Task Complete")
  print(paste0("Time taken: ", end_time - start_time))
}

standardize_ASCRG()