library(readxl)
library(tidyverse)
library(openssl)
library(dplyr)
library(data.table)
base_path <- "C:/Users/joshu/OneDrive/Documents/GIthub/abs/"
scripts_path <- paste0(base_path, "/Scripts/data_Download.R")
source(scripts_path)
dest_path <- paste0(base_path, "Census/Metadata/Download/")
extract_path <- paste0(base_path, "Census/Metadata/Input/")

download_census_data("2021", "GCP", "SA2", "AUS", dest_path, extract_path, TRUE)
#get list of all files in directory Census/Metadata/Input/Metadata
extract_path <- paste0(extract_path, "Metadata/")
files <- list.files(extract_path, full.names = TRUE) # Get full paths
#select from files list file with geog in it
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

# Apply the function to your dataframe


geog_def <- read_excel_sheets(geog_def_source)
data_def <- read_excel_sheets(data_def_source)
#write a function to go through each table and seperate all the row with the same column value into seperate dataframes with the name of the column value
#if a dataframe already exists with the same name, append the rows to the existing dataframe if they are not in it already
library(data.table)

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
        # Combine existing and new data frames, then remove duplicates
        combined_df <- rbind(split_dfs[[category_name]], cat_df)
        # Ensure the combined data frame is unique
        unique_combined_df <- unique(combined_df)
        split_dfs[[category_name]] <- unique_combined_df
      } else {
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






#


#https://www.abs.gov.au/census/find-census-data/datapacks/download/2021_GCP_SA2_for_AUS_short-header.zip