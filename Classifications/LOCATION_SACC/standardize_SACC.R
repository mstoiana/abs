library(readxl)
library(tidyverse)
library(openssl)
library(dplyr)

#import CSV
#read excel file sheet Table 1.3
#data <- read_excel(file_path, sheet = sheet_name, skip = skip)
data <- read_excel("C:/Users/joshu/OneDrive/Documents/GIthub/abs/Classifications/LOCATION_SACC/Input/sacc_12690do0001_202402.xlsx", sheet = "Table 1.3", skip = 4)
colnames(data) <- c("Major_group", "Minor_group", "Countries", "Description")

Major_group <- data %>% select(Major_group, Minor_group) %>% filter(!is.na(Major_group) & !is.na(Minor_group))
Minor_group <- data %>% select(Minor_group, Countries) %>% filter(!is.na(Minor_group) & !is.na(Countries))
Countries <- data %>% select(Countries, Description) %>% filter(!is.na(Countries) & !is.na(Description))

Major_group$key <- openssl::md5(as.character(Major_group$Major_group))
Minor_group$key <- openssl::md5(as.character(Minor_group$Minor_group))
Countries$key <- openssl::md5(as.character(Countries$Countries))

Major_group <- Major_group %>% select(key, everything())
Minor_group <- Minor_group %>% select(key, everything())
Countries <- Countries %>% select(key, everything())
#write to CSV

write_csv(Major_group, "C:/Users/joshu/OneDrive/Documents/GIthub/abs/Classifications/LOCATION_SACC/Output/SACC_Major_group.csv")
write_csv(Minor_group, "C:/Users/joshu/OneDrive/Documents/GIthub/abs/Classifications/LOCATION_SACC/Output/SACC_Minor_group.csv")
write_csv(Countries, "C:/Users/joshu/OneDrive/Documents/GIthub/abs/Classifications/LOCATION_SACC/Output/SACC_Countries.csv")


#read Table 1.3
