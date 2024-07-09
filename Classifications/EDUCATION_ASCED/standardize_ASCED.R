library(readxl)
library(tidyverse)
library(openssl)
library(dplyr)

#import CSV and read both Table 1 and Table 2
#data <- read_excel(file_path, sheet = sheet_name, skip = skip)

level_data <- read_excel("C:/Users/joshu/OneDrive/Documents/GIthub/abs/Classifications/EDUCATION_ASCED/Input/1272.0 australian standard classification of education (asced) structures.xlsx", sheet = "Table 1", skip = 4)
field_data <- read_excel("C:/Users/joshu/OneDrive/Documents/GIthub/abs/Classifications/EDUCATION_ASCED/Input/1272.0 australian standard classification of education (asced) structures.xlsx", sheet = "Table 2", skip = 4)

colnames(level_data) <- c("Broad_Level","Narrow_Level","Detailed_Level", "Description")
colnames(field_data) <- c("Broad_Fields","Narrow_Fields","Detailed_Fields", "Description")

Broad_Level <- level_data %>% select(Broad_Level, Narrow_Level) %>% filter(!is.na(Broad_Level) & !is.na(Narrow_Level))
Narrow_Level <- level_data %>% select(Narrow_Level, Detailed_Level) %>% filter(!is.na(Narrow_Level) & !is.na(Detailed_Level))
Detailed_Level <- level_data %>% select(Detailed_Level, Description) %>% filter(!is.na(Detailed_Level) & !is.na(Description))

Broad_Fields <- field_data %>% select(Broad_Fields, Narrow_Fields) %>% filter(!is.na(Broad_Fields) & !is.na(Narrow_Fields))
Narrow_Fields <- field_data %>% select(Narrow_Fields, Detailed_Fields) %>% filter(!is.na(Narrow_Fields) & !is.na(Detailed_Fields))
Detailed_Fields <- field_data %>% select(Detailed_Fields, Description) %>% filter(!is.na(Detailed_Fields) & !is.na(Description))

#add a date column to all dataframes that has current date
Broad_Level$date <- as.Date(Sys.time())
Narrow_Level$date <- as.Date(Sys.time())
Detailed_Level$date <- as.Date(Sys.time())

Broad_Fields$date <- as.Date(Sys.time())
Narrow_Fields$date <- as.Date(Sys.time())
Detailed_Fields$date <- as.Date(Sys.time())

Broad_Level$Broad_Level_key <- openssl::md5(as.character(Broad_Level$Broad_Level))
Narrow_Level$Narrow_Level_key <- openssl::md5(as.character(Narrow_Level$Narrow_Level))
Detailed_Level$Detailed_Level_key <- openssl::md5(as.character(Detailed_Level$Detailed_Level))

Broad_Fields$Broad_Fields_key <- openssl::md5(as.character(Broad_Fields$Broad_Fields))
Narrow_Fields$Narrow_Fields_key <- openssl::md5(as.character(Narrow_Fields$Narrow_Fields))
Detailed_Fields$Detailed_Fields_key <- openssl::md5(as.character(Detailed_Fields$Detailed_Fields))

Broad_Level <- Broad_Level %>% select(Broad_Level_key, everything())
Narrow_Level <- Narrow_Level %>% select(Narrow_Level_key, everything())
Detailed_Level <- Detailed_Level %>% select(Detailed_Level_key, everything())

Broad_Fields <- Broad_Fields %>% select(Broad_Fields_key, everything())
Narrow_Fields <- Narrow_Fields %>% select(Narrow_Fields_key, everything())
Detailed_Fields <- Detailed_Fields %>% select(Detailed_Fields_key, everything())

#write to CSV

write_csv(Broad_Level, "C:/Users/joshu/OneDrive/Documents/GIthub/abs/Classifications/EDUCATION_ASCED/Output/EDUCATION_ASCED_LEVEL/ASCED_Broad_Level.csv")
write_csv(Narrow_Level, "C:/Users/joshu/OneDrive/Documents/GIthub/abs/Classifications/EDUCATION_ASCED/Output/EDUCATION_ASCED_LEVEL/ASCED_Narrow_Level.csv")
write_csv(Detailed_Level, "C:/Users/joshu/OneDrive/Documents/GIthub/abs/Classifications/EDUCATION_ASCED/Output/EDUCATION_ASCED_LEVEL/ASCED_Detailed_Level.csv")

write_csv(Broad_Fields, "C:/Users/joshu/OneDrive/Documents/GIthub/abs/Classifications/EDUCATION_ASCED/Output/EDUCATION_ASCED_FIELD/ASCED_Broad_Fields.csv")
write_csv(Narrow_Fields, "C:/Users/joshu/OneDrive/Documents/GIthub/abs/Classifications/EDUCATION_ASCED/Output/EDUCATION_ASCED_FIELD/ASCED_Narrow_Fields.csv")
write_csv(Detailed_Fields, "C:/Users/joshu/OneDrive/Documents/GIthub/abs/Classifications/EDUCATION_ASCED/Output/EDUCATION_ASCED_FIELD/ASCED_Detailed_Fields.csv")


                                                                                  

