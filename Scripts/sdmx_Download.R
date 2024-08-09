if (!requireNamespace("rsdmx", quietly = TRUE)) {
  install.packages("rsdmx")
}

library(rsdmx)

#Set static variables
providerId <- "ABS"
resource <- "data"

read_sdmx_data <- function(providerId = "ABS", resource = "data", flowRef = "ALC", startDate = NULL, endDate = NULL) {
  # Construct args for rsdmx
  args <- list(providerId = providerId, resource = resource, flowRef = flowRef)
  
  # Call readSDMX with the constructed argument list
  sdmx <- do.call(readSDMX, args)
  data_df <- as.data.frame(sdmx)
  
  return(data_df)
}

# save file to csv function
save_to_csv <- function(data, file_path) {
  write.csv(data, file = file_path)
}


url <- "https://api.data.abs.gov.au/data/ABS,POP_PROJ_REGION,1.0.0/32+31+3.2+1+3.TT.1.1.1.1.A?startPeriod=2022&dimensionAtObservation=AllDimensions"
sdmx_data <- readSDMX(url)