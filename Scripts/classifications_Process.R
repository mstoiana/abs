retrieve_Classifications <- function() {
  start_time <- Sys.time()
  
  if (!require("readxl")) {
    install.packages("readxl")
  }
  
  if (!require("tidyverse")) {
    install.packages("tidyverse")
  }
  
  if (!require("openssl")) {
    install.packages("openssl")
  }
  
  if (!require("dplyr")) {
    install.packages("dplyr")
  }
  
  if (!require("here")) {
    install.packages("here")
  }
  
  library(readxl)
  library(tidyverse)
  library(openssl)
  library(dplyr)
  library(here)

  source(here("Classifications", "DEMOGRAPHIC_ASCCEG", "standardization_ASCCEG.R"))
  source(here("Classifications", "DEMOGRAPHIC_ASCRG", "standardization_ASCRG.R"))
  source(here("Classifications", "DEMOGRAPHIC_ASCL", "standardization_ASCL.R"))
  source(here("Classifications", "EDUCATION_ASCED", "standardization_ASCED.R"))
  source(here("Classifications", "LOCATION_ASGS", "standardization_ASGS.R"))
  source(here("Classifications", "LOCATION_SACC", "standardization_SACC.R"))
  source(here("Classifications", "OCCUPATION_ANZSCO", "standardization_ANZSCO.R"))
  source(here("Classifications", "RESEARCH_ANZSRC", "standardization_ANZSRC.R"))
  
  standardize_ASCCEG()
  standardize_ASCRG()
  standardize_ASCL()
  standardize_ASCED()
  standardize_ASGS()
  standardize_SACC()
  standardize_ANZSCO()
  standardize_ANZSRC()
  
  end_time <- Sys.time()
  
  print("All Classification Tasks Complete")
  print(paste0("Time taken: ", end_time - start_time))
}

retrieve_Classifications()