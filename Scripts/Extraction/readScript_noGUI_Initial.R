if (!requireNamespace("rsdmx", quietly = TRUE)) {
  install.packages("rsdmx")
}
if (!requireNamespace("uuid", quietly = TRUE)) {
  install.packages("uuid")
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
#read sdmx func
read_sdmx_data <- function(providerId = "ABS", resource = "data", flowRef = "ALC", startDate = NULL, endDate = NULL) {
  # Prepare the parameters for readSDMX
  params <- list(providerId = providerId, resource = resource, flowRef = flowRef)
  
  # Add date parameters if provided
  if (!is.null(startDate) && startDate != "") {
    params$start <- startDate
  }
  if (!is.null(endDate) && endDate != "") {
    params$end <- endDate
  }
  
  # Fetch the data using the readSDMX function
  sdmx_data <- do.call(readSDMX, params)
  
  # Convert the data to a data frame
  data_df <- as.data.frame(sdmx_data)
  
  return(data_df)
}
# Example usage of the function
# data <- read_sdmx_data()


#bronze metadata func
create_metadata <- function(data_df) {
  #add columns for id and process time
  data_df$process_id <- UUIDgenerate()
  data_df$load_datetime <- Sys.time()
  
  return(data_df)
}
# Example usage
# create_metadata(data)


