if (!requireNamespace("rsdmx", quietly = TRUE)) {
  install.packages("rsdmx")
}
if (!requireNamespace("uuid", quietly = TRUE)) {
  install.packages("uuid")
}
if (!requireNamespace("encrypter", quietly = TRUE)) {
  install.packages("encryptr")
}
if (!requireNamespace("dplyr", quietly = TRUE)) {
  install.packages("dplyr")
}
#variables
providerId <- "ABS"
resource <- "data"
flowRef <- "ALC"
startDate <- NULL
endDate <- NULL
#functions
# Load the necessary library
library(rsdmx)
library(uuid)
library(encryptr)
library(dplyr)
#read sdmx func
read_sdmx_data <- function(providerId = "ABS", resource = "data", flowRef = "ALC", startDate = NULL, endDate = NULL) {
  # Construct args for rsdmx
  args <- list(providerId = providerId, resource = resource, flowRef = flowRef)
  
  # Call readSDMX with the constructed argument list
  sdmx <- do.call(readSDMX, args)
  data_df <- as.data.frame(sdmx)
  
  return(data_df)
}

# Example usage of the function
# data <- read_sdmx_data()

#read local data func
read_csv <- function(file_path) {
  data_df <- read.csv(file_path, stringsAsFactors = FALSE)
  
  return(data_df)
}
#Example usage
#df <- read_csv("C:/Users/User/Documents/data.csv")

#write to csv func
save_csv  <- function(data_df, file_path) {
  write.csv(data_df, file_path, row.names = FALSE)
}
#Example usage
#save_csv(df,"C:/Users/User/Documents/data.csv")



