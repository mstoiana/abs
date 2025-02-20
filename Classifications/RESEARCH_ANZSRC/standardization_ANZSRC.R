
standardize_ANZSRC <- function(){
  start_time <- Sys.time()
  
  library(readxl)
  library(tidyverse)
  library(openssl)
  library(dplyr)
  library(here)

  base_path <- here()
  scripts_path <- here("Scripts", "data_Download.R")
  source(scripts_path)
  dest_path <- here("Classifications", "RESEARCH_ANZSRC", "Download")
  extract_path <- here("Classifications", "RESEARCH_ANZSRC", "Input")
  dest_path

  url <- "https://www.abs.gov.au/statistics/classifications/australian-and-new-zealand-standard-research-classification-anzsrc/2020/anzsrc2020_seo.xlsx"
  download_file(url, dest_path, extract_path, "anzsrc2020_seo.xlsx")
  url <- "https://www.abs.gov.au/statistics/classifications/australian-and-new-zealand-standard-research-classification-anzsrc/2020/anzsrc2020_for.xlsx"
  download_file(url, dest_path, extract_path, "anzsrc2020_for.xlsx")

# Load the data
  SEO_Data <- read_excel(file.path(extract_path, "anzsrc2020_seo.xlsx"), sheet = "Table 3", skip = 7)
  FOR_Data <- read_excel(file.path(extract_path, "anzsrc2020_for.xlsx"), sheet = "Table 3", skip = 7)
  
  colnames(SEO_Data) <- c("SEO_Division", "SEO_Group", "SEO_Objective", "SEO_Description")
  colnames(FOR_Data) <- c("FOR_Division", "FOR_Group", "FOR_Field", "FOR_Description")

  SEO_Divisions <- SEO_Data %>% select(SEO_Division,SEO_Group) %>% filter(!is.na(SEO_Division) & !is.na(SEO_Group))
  SEO_Groups <- SEO_Data %>% select(SEO_Group,SEO_Objective) %>% filter(!is.na(SEO_Group) & !is.na(SEO_Objective))
  SEO_Objectives <- SEO_Data %>% select(SEO_Objective,SEO_Description) %>% filter(!is.na(SEO_Objective) & !is.na(SEO_Description))

  FOR_Divisions <- FOR_Data %>% select(FOR_Division,FOR_Group) %>% filter(!is.na(FOR_Division) & !is.na(FOR_Group))
  FOR_Groups <- FOR_Data %>% select(FOR_Group,FOR_Field) %>% filter(!is.na(FOR_Group) & !is.na(FOR_Field))
  FOR_Fields <- FOR_Data %>% select(FOR_Field,FOR_Description) %>% filter(!is.na(FOR_Field) & !is.na(FOR_Description))

  SEO_Divisions$SEO_Divisions_Time <- today()
  SEO_Groups$SEO_Groups_Time <- today()
  SEO_Objectives$SEO_Objectives_Time <- today()

  FOR_Divisions$FOR_Divisions_Time <- today()
  FOR_Groups$FOR_Groups_Time <- today()
  FOR_Fields$FOR_Fields_Time <- today()

  SEO_Divisions$SEO_Divisions_Key <- openssl::md5(SEO_Divisions$SEO_Division)
  SEO_Groups$SEO_Groups_Key <- openssl::md5(SEO_Groups$SEO_Group)
  SEO_Objectives$SEO_Objectives_Key <- openssl::md5(SEO_Objectives$SEO_Objective)

  FOR_Divisions$FOR_Divisions_Key <- openssl::md5(as.character(FOR_Divisions$FOR_Division))
  FOR_Groups$FOR_Groups_Key <- openssl::md5(as.character(FOR_Groups$FOR_Group))
  FOR_Fields$FOR_Fields_Key <- openssl::md5(as.character(FOR_Fields$FOR_Field))
                                  
  SEO_Divisions <- SEO_Divisions %>% select(SEO_Divisions_Key, everything())
  SEO_Groups <- SEO_Groups %>% select(SEO_Groups_Key, everything())
  SEO_Objectives <- SEO_Objectives %>% select(SEO_Objectives_Key, everything())

  FOR_Divisions <- FOR_Divisions %>% select(FOR_Divisions_Key, everything())
  FOR_Groups <- FOR_Groups %>% select(FOR_Groups_Key, everything())
  FOR_Fields <- FOR_Fields %>% select(FOR_Fields_Key, everything())

  write_csv(SEO_Divisions, here("Classifications", "RESEARCH_ANZSRC", "Output", "SEO_Divisions.csv"))
  write_csv(SEO_Groups, here("Classifications", "RESEARCH_ANZSRC", "Output", "SEO_Groups.csv"))
  write_csv(SEO_Objectives, here("Classifications", "RESEARCH_ANZSRC", "Output", "SEO_Objectives.csv"))

  write_csv(FOR_Divisions, here("Classifications", "RESEARCH_ANZSRC", "Output", "FOR_Divisions.csv"))
  write_csv(FOR_Groups, here("Classifications", "RESEARCH_ANZSRC", "Output", "FOR_Groups.csv"))
  write_csv(FOR_Fields, here("Classifications", "RESEARCH_ANZSRC", "Output", "FOR_Fields.csv"))
  
  end_time <- Sys.time()
  
  print("ANZSRC Task Complete")
  print(paste0("Time taken: ", end_time - start_time))
}

standardize_ANZSRC()