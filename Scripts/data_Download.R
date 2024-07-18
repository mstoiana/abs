library(httr)
library(readr)
library(readxl)

#base_path <- "C:/Users/joshu/OneDrive/Documents/GIthub/abs/"
#dest_path <- paste0(base_path, "Classifications/LOCATION_ASGS/Download/")
#extract_path <- paste0(base_path, "Classifications/LOCATION_ASGS/Input/")

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
    # Optionally, delete the ZIP file after unzipping
    file.remove(full_dest_path)
  }
}
#https://www.abs.gov.au/census/find-census-data/datapacks/download/2021_GCP_SA1_for_AUS_short-header.zip


download_census_data <- function(c_year, c_pack, c_geo, c_area, dest_path, extract_path, metadata){
  url <- paste0("https://www.abs.gov.au/census/find-census-data/datapacks/download/", c_year, "_", c_pack, "_", c_geo, "_for_", c_area, "_short-header.zip")
  file_name <- paste0(c_year, "_", c_pack, "_", c_geo, "_for_", c_area, "_short-header.zip")
  download_file(url, dest_path, extract_path, file_name)
  files <- list.files(extract_path, full.names = TRUE) # Get full paths
  if (metadata == TRUE){
    for (file_path in files){
      if (!grepl("Metadata", file_path)){
        if (file.info(file_path)$isdir){
          # Use unlink to remove directories
          unlink(file_path, recursive = TRUE)
        } else {
          # Use file.remove for files
          file.remove(file_path)
        }
      }
    }
  }
}




#read from excel function
url_from_excel <- function(excel_path, dest_path, extract_path){
  urls_df <- read_excel(excel_path, skip = 1, col_names = c("url", "file_name"))
  for (i in 1:nrow(urls_df)) {
    download_file(urls_df$url[i], dest_path, extract_path, urls_df$file_name[i])
  }
}

#Example
#url_from_excel(paste0(base_path, "Classifications/LOCATION_ASGS/Download/MB_Data_source.xlsx"), dest_path, extract_path)
