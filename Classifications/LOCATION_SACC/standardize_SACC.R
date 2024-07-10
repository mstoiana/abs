library(readxl)
library(tidyverse)
library(openssl)
library(dplyr)

base_path <- "C:/Users/joshu/OneDrive/Documents/GIthub/abs/"
scripts_path <- paste0(base_path, "/Scripts/data_Download.R")
source(scripts_path)
dest_path <- paste0(base_path, "Classifications/Location_SACC/Download/")
extract_path <- paste0(base_path, "Classifications/Location_SACC/Input/")

url <- "https://www.abs.gov.au/statistics/classifications/standard-australian-classification-countries-sacc/2016/sacc_12690do0001_202402.xlsx"
download_file(url, dest_path, extract_path, "sacc_12690do0001_202402.xlsx")

Data <- read_excel("C:/Users/joshu/OneDrive/Documents/GIthub/abs/Classifications/LOCATION_SACC/Input/sacc_12690do0001_202402.xlsx", sheet = "Table 1.3", skip = 4)
colnames(Data) <- c("Major_Group", "Minor_Group", "Countries", "Countries_Description")

Major_Group <- Data %>% select(Major_Group, Minor_Group) %>% filter(!is.na(Major_Group) & !is.na(Minor_Group))
Minor_Group <- Data %>% select(Minor_Group, Countries) %>% filter(!is.na(Minor_Group) & !is.na(Countries))
Countries <- Data %>% select(Countries, Countries_Description) %>% filter(!is.na(Countries) & !is.na(Countries_Description))

#add a Date column to all Dataframes that has current Date
Major_Group$Major_Group_Date <- today()
Minor_Group$Minor_Group_Date <- today()
Countries$Countries_Date <- today()

Major_Group$Major_Group_Key <- openssl::md5(as.character(Major_Group$Major_Group))
Minor_Group$Minor_Group_Key <- openssl::md5(as.character(Minor_Group$Minor_Group))
Countries$Countries_Key <- openssl::md5(as.character(Countries$Countries))

Major_Group <- Major_Group %>% select(Major_Group_Key, everything())
Minor_Group <- Minor_Group %>% select(Minor_Group_Key, everything())
Countries <- Countries %>% select(Countries_Key, everything())
#write to CSV

write_csv(Major_Group, "C:/Users/joshu/OneDrive/Documents/GIthub/abs/Classifications/LOCATION_SACC/Output/SACC_Major_Group.csv")
write_csv(Minor_Group, "C:/Users/joshu/OneDrive/Documents/GIthub/abs/Classifications/LOCATION_SACC/Output/SACC_Minor_Group.csv")
write_csv(Countries, "C:/Users/joshu/OneDrive/Documents/GIthub/abs/Classifications/LOCATION_SACC/Output/SACC_Countries.csv")
