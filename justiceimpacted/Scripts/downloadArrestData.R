# -----------------------------------------------------------------------------
# Download FBI Arrest Data
# Author: Zofia C. Stanley
# Date: Dec 20, 2023
#
# Description:
# This script uses the FBI's Crime Data API to download arrest
# data by age/sex and race for each state in parallel.
# -----------------------------------------------------------------------------

# Load necessary libraries
library(httr)
library(jsonlite)
library(tidyverse)
library(pbmcapply)
library(parallel)

# Define state postal abbreviations
state_abbreviations <- c("AL", "AK", "AZ", "AR", "CA", "CO", "CT", "DE", "FL", "GA", 
                         "HI", "ID", "IL", "IN", "IA", "KS", "KY", "LA", "ME", "MD", 
                         "MA", "MI", "MN", "MS", "MO", "MT", "NE", "NV", "NH", "NJ", 
                         "NM", "NY", "NC", "ND", "OH", "OK", "OR", "PA", "RI", "SC", 
                         "SD", "TN", "TX", "UT", "VT", "VA", "WA", "WV", "WI", "WY", "DC")

# Define categories
categories <- c("male", "female", "race")

# API key
api_key <- "750Nyw7eNAnXPgd6jsYcDiVXchidefZpbNU6pNRd"

# Base URL of the FBI's API
base_url <- "https://api.usa.gov/crime/fbi/cde/"

# Generate endpoint URL
generate_endpoint <- function(state_abbreviation, category, key = api_key) {
  paste0("arrest/state/", state_abbreviation, "/all/", category, "?from=2022&to=2022&API_KEY=", key)
}

# Generate filename for saving the data
generate_filename <- function(state_abbreviation, category) {
  paste0("justiceimpacted/RawData/ArrestData/fbi_arrest_", state_abbreviation, "_", category, ".csv")
}

# Function to download and transform data
download_data <- function(state, category) {
  full_url <- paste0(base_url, generate_endpoint(state, category))
  response <- GET(full_url, add_headers(`Authorization` = paste0("Bearer ", api_key)))
  
  if (status_code(response) == 200) {
    # Convert JSON response to a data frame
    data_json <- fromJSON(content(response, "text"), flatten = TRUE)
    
    # Transform data into a long format
    if (category == "race") {
      long_data <- data_json$data %>%
        pivot_longer(
          cols = -c(data_year, offense),  # Exclude data_year and offense columns from reshaping
          names_to = "race",
          values_to = "count"
        ) %>%
        mutate(state = state)  # Add state column
    } else {
      # For sex category
      long_data <- data_json$data %>%
        pivot_longer(
          cols = -c(data_year, offense),  # Exclude data_year and offense columns from reshaping
          names_to = "age",
          values_to = "count"
        ) %>%
        mutate(sex = category, state = state)  # Add sex and state columns
    }
    
    # Write the transformed data to CSV file
    write.csv(long_data, generate_filename(state, category), row.names = FALSE)
    return(paste("Data successfully fetched and transformed for state", state, "and category", category))
  } else {
    return(paste("Failed to fetch data for state", state, "and category", category, ": Error Code", status_code(response)))
  }
}

# Generate combinations of states and categories
combinations <- expand.grid(state = state_abbreviations, category = categories)

# Run parallel processing
results <- pbmclapply(1:nrow(combinations), function(i) {
  download_data(combinations$state[i], combinations$category[i])
}, mc.cores = detectCores()-1)


# View results
print(results)