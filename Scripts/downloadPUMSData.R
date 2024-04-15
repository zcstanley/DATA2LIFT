# -----------------------------------------------------------------------------
# PUMS Data Retrieval
# Author: Chad M. Topaz, Zofia C. Stanley
# Date: Apr 10, 2024
#
# Description:
# This code downloads PUMS data for the following variables:
#    "AGEP", "SCH", "ESR", "RAC1P", "HISP", "SEX", "ST", "PUMA"
# -----------------------------------------------------------------------------

# -------------------------
# Load necessary libraries
# -------------------------
library(tidycensus)
library(tidyverse)
library(pbmcapply)  # parallel version of lapply
library(parallel)

# -----------------------------------
# Set census api key
# -----------------------------------
census_api_key("d48d2c6fa999265383738be2b1f48aed4900866a")

# -----------------------------------
# Define state postal abbreviations 
# -----------------------------------
state_abbreviations <- c("AL", "AK", "AZ", "AR", "CA", "CO", "CT", "DE", "FL", "GA", 
                 "HI", "ID", "IL", "IN", "IA", "KS", "KY", "LA", "ME", "MD", 
                 "MA", "MI", "MN", "MS", "MO", "MT", "NE", "NV", "NH", "NJ", 
                 "NM", "NY", "NC", "ND", "OH", "OK", "OR", "PA", "RI", "SC", 
                 "SD", "TN", "TX", "UT", "VT", "VA", "WA", "WV", "WI", "WY", "DC")


# -------------------------------------------------------------------------
# Define function to get data for a specific state with retries on failure
# -------------------------------------------------------------------------
getDataByState <- function(state, year, max_retries = 3) {
  # Define the required variables from ACS (see ReadMe for description of each variable)
  vars <- c("AGEP", "SCH", "ESR", "RAC1P", "HISP", "SEX", "ST", "PUMA")
  
  retries <- 1
  
  while (retries <= max_retries) {
    tryCatch({
      # Retrieve the data for the given year and state with specified variables
      data <- get_pums(variables = vars, year = year, state = state, survey = "acs1")
      return(data)
    }, error = function(e) {
      if (retries == max_retries) {
        warning(paste("Fetching data for state", state, "failed after", max_retries, "attempts. Returning empty data frame."))
        return(data.frame())  # Return an empty data frame
      }
      retries <- retries + 1
    })
  }
}

# ----------------------------------------
# Fetch data (use pbmclapply to fetch data in parallel)
# ----------------------------------------
rawdata_list <- lapply(state_abbreviations, function(state) {
  getDataByState(state, 2021)
})

# -------------------------------------------------
# Combine all the data into one data frame and save
# -------------------------------------------------
rawPumsData <- bind_rows(rawdata_list)
save(rawPumsData, file = "RawData/PUMSRawData.Rdata") 