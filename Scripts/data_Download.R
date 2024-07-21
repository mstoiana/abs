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
    file.remove(full_dest_path)
  }
}

#' @param c_year The census year for which data is being requested.
#' @param c_pack The specific data pack of interest within the census data.
#' @param c_geo The geographical classification of the data (e.g., national, state).
#' @param c_area The specific area for which data is required.
#' @param dest_path The file path where the downloaded zip file should be saved.
#' @param extract_path The directory path where the contents of the zip file should be extracted.
#' @param metadata A boolean flag indicating whether to retain only metadata files in the extraction directory.
#'                 If TRUE, only files containing "Metadata" in their name are retained, and all others are deleted.
#'
#' @details The function constructs a download URL using the provided parameters and calls an external function
#'          `download_file` to handle the download and extraction process. After extraction, if the `metadata` parameter
#'          is set to TRUE, the function iterates through the extracted files, removing any that do not pertain to
#'          metadata. This is useful for users interested only in the metadata files and not in the full dataset.
#'
#' @return None.
#'
#' @examples
#' download_census_data("2021", "G01", "NAT", "AUS", "path/to/download", "path/to/extract", TRUE)
#' This example downloads the 2021 National Census G01 data pack for Australia, extracts it, and retains only metadata files.

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
