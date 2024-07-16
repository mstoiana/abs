library(dplyr)

cleaned_data <- raw_data %>% distinct()

cleaned_data <- raw_data %>%
  mutate(across(everything(), ~ ifelse(is.na(.), mean(., nam.rm = TRUE), .)))

cleaned_data <- raw_data %>%
  mutate(across(where(is.character), tolower))

