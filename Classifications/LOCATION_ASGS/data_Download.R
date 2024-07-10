library(httr)
library(readr)

#base_path <- "C:/Users/joshu/OneDrive/Documents/GIthub/abs/"
#dest_path <- paste0(base_path, "Classifications/LOCATION_ASGS/Download/")
#extract_path <- paste0(base_path, "Classifications/LOCATION_ASGS/Input/")

unzip_file <- function(zip_path, dest_path){
  unzip(zip_path, exdir = dest_path)
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

#read from csv function
url_from_csv <- function(csv_path, dest_path, extract_pat){
  urls_df <- read_csv(csv_path, skip = 1, col_names = c("url", "file_name"))
  for (i in 1:nrow(urls_df)) {
    download_file(urls_df$url[i], dest_path, extract_path, urls_df$file_name[i])
  }
}
url_from_csv(paste0(base_path, "Classifications/LOCATION_ASGS/Download/data_source.csv"), dest_path, extract_path)
