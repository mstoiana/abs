#INSTALL PACKAGES
install.packages("httr")
install.packages("readxl")
install.packages("here")
install.packages("dplyr")
install.packages("ggplot2")
install.packages("openssl")
install.packages("tidyverse")

library(httr)
library(readxl)
library(here)
library(dplyr)
library(ggplot2)
library(openssl)
library(tidyverse)

unzip_file <- function(zip_path, dest_path){
  unzip(zip_path, exdir = dest_path)
}

import_csv <- function(file_path) {
  data <- read_csv(file_path)
  return(data)
}

download_file <- function(url, dest_path, extract_path, file_name){
  # Ensure the destination directory exists
  if (!dir.exists(dest_path)) {
    dir.create(dest_path, recursive = TRUE)
  }
  
  full_dest_path <- file.path(dest_path, file_name)
  # Adjust extract_path to not append file_name directly
  GET(url, write_disk(full_dest_path, overwrite = TRUE))
  
  if (grepl(".zip$", full_dest_path)){
    unzip_file(full_dest_path, extract_path)
    file.remove(full_dest_path)
  }
}

url <- "https://api.data.abs.gov.au/data/ABS,POP_PROJ_REGION,1.0.0/32+31+3.2+1+3.TT.....A?startPeriod=2022&format=csv"
download_file(url, here("data"), here("data"), "ABS_PROJ_REGION_QLD.csv")
#import as dataframe

data <- read_csv(here("data", "ABS_PROJ_REGION_QLD.csv"))
data_df <- as.data.frame(data)
#fertility = 3/2/1
#expectancy = 1/2
#migration = 1/2/3/4
#interstate = 1/2/3
#Rest of qld =3
#brisbane = 32

#select only the REGION, SEX_ABS, MORTALITY, NOM, NIM, TIME_PERIOD, OBS_VALUE columns
colnames(data_df)
data_df <- data_df %>% select(REGION, FERTILITY, SEX_ABS, MORTALITY, NOM, NIM, TIME_PERIOD, OBS_VALUE)
#split the data by region, region 32 is brisbane, region 3 is rest of qld and remove the REGION column
#create a primary key column using ssh for the data using the OBS_VALUE column
data_df$GROWTH_KEY <- md5(as.character(data_df$OBS_VALUE))
data_df$DATE_RETRIEVED <- today()

brisbane_df <- data_df %>% filter(REGION == 32) %>% select(-REGION)
rest_of_qld_df <- data_df %>% filter(REGION == 3) %>% select(-REGION)
brisbane_df_filtered_1 <- brisbane_df %>% filter(FERTILITY == 1, MORTALITY == 1, NOM == 1, NIM == 1, SEX_ABS == 3)

# Filter Brisbane data for MORTALITY of 2, NOM of 2, NIM of 2, and SEX_ABS of 3
brisbane_df_filtered_2 <- brisbane_df %>% filter(FERTILITY == 2, MORTALITY == 2, NOM == 2, NIM == 2, SEX_ABS == 3)
brisbane_df_filtered_3 <- brisbane_df %>% filter(FERTILITY == 3, MORTALITY == 2, NOM == 3, NIM == 3, SEX_ABS == 3)

# Combine the filtered data and add a new column to distinguish the groups
brisbane_df_filtered_1$Group <- "FERTILITY = 1, MORTALITY=1, NOM=1, NIM=1"
brisbane_df_filtered_2$Group <- "FERTILITY = 2,MORTALITY=2, NOM=2, NIM=2"
brisbane_df_filtered_3$Group <- "FERTILITY = 3,MORTALITY=2, NOM=3, NIM=3"
combined_df <- bind_rows(brisbane_df_filtered_1, brisbane_df_filtered_2, brisbane_df_filtered_3)

# Plot the filtered data
ggplot(combined_df, aes(x = TIME_PERIOD, y = OBS_VALUE, color = Group)) +
  geom_smooth(method = "loess") +  # Use a smooth plot
  labs(title = "Population over next 50 years in Brisbane",
       x = "Time Period",
       y = "Population") +
  theme_minimal()

#save to csv 
write.csv(data_df, "abs_pop_proj_data_QLD.csv")
write.csv(brisbane_df, "abs_pop_proj_data_brisbane.csv")
write.csv(rest_of_qld_df, "abs_pop_proj_data_rest_of_qld_df.csv")