library(readxl)
library(tidyverse)
library(openssl)
library(dplyr)
library(data.table)
library(here)

base_path <- here()
scripts_path <- here("Scripts", "data_Download.R")
source(scripts_path)
dest_path <- here("Census", "Metadata", "Download")
extract_path <- here("Census", "Metadata", "Input")
output_path <- here("Census", "Metadata", "Output")

# Create directories if they do not exist
paths <- list(dest_path, extract_path, output_path)
lapply(paths, function(path) {
  if (!dir.exists(path)) {
    dir.create(path, recursive = TRUE)
  }
})

download_census_data("2021", "GCP", "SA2", "AUS", dest_path, extract_path, TRUE)
extract_path <- here("Census", "Metadata", "Input", "Metadata")
files <- list.files(extract_path, full.names = TRUE) # Get full paths
geog_def_source <- files[grepl("geog", files)]
data_def_source <- files[grepl("DataPack", files)]

#read each table in the excel file and create dataframe based on tablename
read_excel_sheets <- function(file) {
  tables <- excel_sheets(file)
  dataframes <- list()
  for (table in tables) {
    dataframes[[table]] <- read_excel(file, sheet = table)
  }
  return(dataframes)
}
setColumns <- function(df) {
  for (col in 1:ncol(df)) {
    # Find the first non-NA value in the column
    firstNonNAIndex <- which(!is.na(df[[col]]))[1]
    
    # Check if there is a non-NA value
    if (!is.na(firstNonNAIndex)) {
      # Set the column name to the first non-NA value
      colnames(df)[col] <- as.character(df[firstNonNAIndex, col])
    }
  }
  return(df)
}

geog_def <- read_excel_sheets(geog_def_source)
data_def <- read_excel_sheets(data_def_source)

split_data_frames <- function(df_list) {
  split_dfs <- list()
  
  for (name in names(df_list)) {
    df <- df_list[[name]]
    print(paste("Processing data frame:", name))
    
    # Ensure df is a data.table
    setDT(df)
    
    # Split the data frame by the first column (assuming it's the category column)
    split_list <- split(df, df[[1]])
    
    for (category_name in names(split_list)) {
      cat_df <- split_list[[category_name]]
      
      # Check if this category already exists in split_dfs
      if (category_name %in% names(split_dfs)) {
        # If so, Combine existing and new data frames, then remove duplicates
        combined_df <- rbind(split_dfs[[category_name]], cat_df)
        # Ensure the combined data frame is unique
        unique_combined_df <- unique(combined_df)
        split_dfs[[category_name]] <- unique_combined_df
      } else {
        #if this is first occurence of category, add it to the list
        split_dfs[[category_name]] <- cat_df
      }
    }
  }
  
  return(split_dfs)
}

split_list_of_dfs <- split_data_frames(geog_def)

#process data definitions 
data_def_process <- function(data_def) {
  #process table 1
  data_def[[1]] <- data_def[[1]][!is.na(data_def[[1]][,2]),]
  data_def[[1]] <- setColumns(data_def[[1]])
  data_def[[1]] <- data_def[[1]][-1,]
  #process table 2
  data_def[[2]] <- data_def[[2]][!is.na(data_def[[2]][,2]),]
  data_def[[2]] <- setColumns(data_def[[2]])
  data_def[[2]] <- data_def[[2]][-1,]
  return(data_def)
}
data_def <- data_def_process(data_def)

#export data def as two seperate csvs
write.csv(data_def[1], here(output_path, "data_def_tables.csv"), row.names = FALSE)
write.csv(data_def[2], here(output_path, "data_def_columns.csv"), row.names = FALSE)
output_path <- here("Census", "Metadata", "Output", "AGSS")

# Check if the directory exists, if not, create it
if (!dir.exists(output_path)) {
  dir.create(output_path, recursive = TRUE)
}

for (name in names(split_list_of_dfs)) {
  df <- split_list_of_dfs[[name]]
  write.csv(df, paste0(output_path, name, ".csv"), row.names = FALSE)
}
#read each csv and create a column called AGSS_Key
files <- list.files(output_path, full.names = TRUE)
for (file in files) {
  df <- fread(file)
  df$AGSS_Key <- file
  #add value to the AGSS_key which is the AGSS_Code_2021 
  df$AGSS_Key <- openssl::md5(as.character(df$AGSS_Code_2021))
  write.csv(df, file, row.names = FALSE)
}