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
  base_path <- here::here()
  
  source(paste0(base_path, "/Classifications/DEMOGRAPHIC_ASCCEG/standardization_ASCCEG.R"))
  source(paste0(base_path, "/Classifications/DEMOGRAPHIC_ASCRG/standardization_ASCRG.R"))
  source(paste0(base_path, "/Classifications/DEMOGRAPHIC_ASCL/standardization_ASCL.R"))
  source(paste0(base_path, "/Classifications/EDUCATION_ASCED/standardization_ASCED.R"))
  source(paste0(base_path, "/Classifications/LOCATION_ASGS/standardization_ASGS.R"))
  source(paste0(base_path, "/Classifications/LOCATION_SACC/standardization_SACC.R"))
  source(paste0(base_path, "/Classifications/OCCUPATION_ANZSCO/standardization_ANZSCO.R"))
  source(paste0(base_path, "/Classifications/RESEARCH_ANZSRC/standardization_ANZSRC.R"))
  
  standardize_ASCCEG(base_path)
  standardize_ASCRG(base_path)
  standardize_ASCL(base_path)
  standardize_ASCED(base_path)
  standardize_ASGS(base_path)
  standardize_SACC(base_path)
  standardize_ANZSCO(base_path)
  standardize_ANZSRC(base_path)
  
  end_time <- Sys.time()
  
  print("All Classification Tasks Complete")
  print(paste0("Time taken: ", end_time - start_time))
}

retrieve_Classifications()