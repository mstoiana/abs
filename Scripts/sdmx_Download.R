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

read_sdmx_data(,,"")