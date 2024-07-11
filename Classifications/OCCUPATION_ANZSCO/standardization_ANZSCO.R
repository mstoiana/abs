standardize_ANZSCO <- function(base_path){
  start_time <- Sys.time()

  library(readxl)
  library(tidyverse)
  library(openssl)
  library(dplyr)

  scripts_path <- paste0(base_path, "/Scripts/data_Download.R")
  source(scripts_path)
  dest_path <- paste0(base_path, "Classifications/OCCUPATION_ANZSCO/Download/")
  extract_path <- paste0(base_path, "Classifications/OCCUPAITON_ANZSCO/Input/")

  url <- "https://www.abs.gov.au/statistics/classifications/anzsco-australian-and-new-zealand-standard-classification-occupations/2022/anzsco%202022%20structure%20062023.xlsx"
  download_file(url, dest_path, extract_path, "1220.0 anzsco version 1.3 structure v1.xlsx")

  Occupation_Data <- read_excel(paste0(base_path, "Classifications/OCCUPATION_ANZSCO/Input/1220.0 anzsco version 1.3 structure v1.xlsx"), sheet = "Table 5", skip = 4)
  Major_Group_Data <- read_excel(paste0(base_path, "Classifications/OCCUPATION_ANZSCO/Input/1220.0 anzsco version 1.3 structure v1.xlsx"), sheet = "Table 1", skip = 4)
  Sub_Major_Group_Data <- read_excel(paste0(base_path, "Classifications/OCCUPATION_ANZSCO/Input/1220.0 anzsco version 1.3 structure v1.xlsx"), sheet = "Table 2", skip = 4)
  Minor_Group_Data <- read_excel(paste0(base_path, "Classifications/OCCUPATION_ANZSCO/Input/1220.0 anzsco version 1.3 structure v1.xlsx"), sheet = "Table 3", skip = 4)
  Unit_Group_Data <- read_excel(paste0(base_path, "Classifications/OCCUPATION_ANZSCO/Input/1220.0 anzsco version 1.3 structure v1.xlsx"), sheet = "Table 4", skip = 4)

  colnames(Occupation_Data) <- c("Major_Group", "Sub_Major_Group", "Minor_Group","Unit_Group","Occupation_Code","Description","Skill_Level")
  colnames(Major_Group_Data) <- c("Major_Group", "Description","Predominant_Skill_Levels")
  colnames(Sub_Major_Group_Data) <- c("Major_Group", "Sub_Major_Group", "Description","Predominant_Skill_Levels")
  colnames(Minor_Group_Data) <- c("Major_Group", "Sub_Major_Group", "Minor_Group", "Description","Predominant_Skill_Levels")
  colnames(Unit_Group_Data) <- c("Major_Group", "Sub_Major_Group", "Minor_Group", "Unit_Group", "Description","Skill_Levels")

#create function to go through and 
#standardize the Data
  Major_Group_Data <- Major_Group_Data %>% select(Major_Group, Description, Predominant_Skill_Levels) %>% filter(!is.na(Major_Group) & !is.na(Description))
  Sub_Major_Group_Data <- Sub_Major_Group_Data %>% select(Sub_Major_Group, Description, Predominant_Skill_Levels) %>% filter(!is.na(Description))
  Minor_Group_Data <- Minor_Group_Data %>% select(Minor_Group, Description, Predominant_Skill_Levels) %>% filter(!is.na(Minor_Group) & !is.na(Description))
  Unit_Group_Data <- Unit_Group_Data %>% select(Unit_Group, Description, Skill_Levels) %>% filter(!is.na(Unit_Group) & !is.na(Description))
  Occupation_Data <- Occupation_Data %>% select(Occupation_Code, Description, Skill_Level) %>% filter(!is.na(Occupation_Code) & !is.na(Description) & !is.na(Skill_Level))

#add a date column to all Dataframes that has current date
  Major_Group_Data$Major_Group_Date <- today()
  Sub_Major_Group_Data$Sub_Major_Group_Date <- today()
  Minor_Group_Data$Minor_Group_Date <- today()
  Unit_Group_Data$Unit_Group_Date <- today()
  Occupation_Data$Occupation_Date <- today()

  Major_Group_Data$Major_Group_Key <- openssl::md5(as.character(Major_Group_Data$Major_Group))
  Sub_Major_Group_Data$Sub_Major_Group_Key <- openssl::md5(as.character(Sub_Major_Group_Data$Sub_Major_Group))
  Minor_Group_Data$Minor_Group_Key <- openssl::md5(as.character(Minor_Group_Data$Minor_Group))
  Unit_Group_Data$Unit_Group_Key <- openssl::md5(as.character(Unit_Group_Data$Unit_Group))
  Occupation_Data$Occupation_Code_Key <- openssl::md5(as.character(Occupation_Data$Occupation_Code))

  Major_Group_Data <- Major_Group_Data %>% select(Major_Group_Key, everything())
  Sub_Major_Group_Data <- Sub_Major_Group_Data %>% select(Sub_Major_Group_Key, everything())
  Minor_Group_Data <- Minor_Group_Data %>% select(Minor_Group_Key, everything())
  Unit_Group_Data <- Unit_Group_Data %>% select(Unit_Group_Key, everything())
  Occupation_Data <- Occupation_Data %>% select(Occupation_Code_Key, everything())

#write to CSV
  write_csv(Major_Group_Data, paste0(base_path, "Classifications/OCCUPATION_ANZSCO/Output/ANZSCO_Major_Group.csv"))
  write_csv(Sub_Major_Group_Data, paste0(base_path, "Classifications/OCCUPATION_ANZSCO/Output/ANZSCO_Sub_Major_Group.csv"))
  write_csv(Minor_Group_Data, paste0(base_path, "Classifications/OCCUPATION_ANZSCO/Output/ANZSCO_Minor_Group.csv"))
  write_csv(Unit_Group_Data, paste0(base_path, "Classifications/OCCUPATION_ANZSCO/Output/ANZSCO_Unit_Group.csv"))
  write_csv(Occupation_Data, paste0(base_path, "Classifications/OCCUPATION_ANZSCO/Output/ANZSCO_Occupation_Code.csv"))
  
  end_time <- Sys.time()
  
  print("ANZSCO Task Complete")
  print(paste0("Time taken: ", end_time - start_time))
}

standardize_ANZSCO("C:/Users/Josh/OneDrive/Documents/GIthub/abs/")