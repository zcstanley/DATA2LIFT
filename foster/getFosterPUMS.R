# -----------------------------------------------------------------------------
# Census Data Retrieval, Transformation and Geographical Integration
# Author: Chad M. Topaz
# Date: Sep 19, 2023
#
# Description:
# This script accomplishes the following tasks:
#   - Imports required libraries.
#   - Specifies census API key and fetches PUMS data by state.
#   - Processes and transforms raw data.
#   - Integrates geographical data.
#   - Stores the finalized data.
# -----------------------------------------------------------------------------

# --------------------
# Import required libraries
# --------------------
library(tidyverse)
library(tidycensus)
library(tigris)
library(pbmcapply)

# --------------------
# Data retrieval settings
# --------------------
# Define state abbreviations
state_abbreviations <- tolower(c(
  "AL", "AK", "AZ", "AR", "CA", "CO", "CT", "DE", "FL", "GA", 
  "HI", "ID", "IL", "IN", "IA", "KS", "KY", "LA", "ME", "MD", 
  "MA", "MI", "MN", "MS", "MO", "MT", "NE", "NV", "NH", "NJ", 
  "NM", "NY", "NC", "ND", "OH", "OK", "OR", "PA", "RI", "SC", 
  "SD", "TN", "TX", "UT", "VT", "VA", "WA", "WV", "WI", "WY", "DC"
))

# Set census API key
census_api_key("985901667535f61f5ea97bfbf8e4fdfcd8c743c4")

# Function to get data by state
getDataByState <- function(state, year, max_retries = 5) {
  vars <- c("AGEP", "RAC1P", "HISP", "SEX", "ST", "PUMA")
  retries <- 1
  
  while (retries <= max_retries) {
    tryCatch({
      data <- get_pums(variables = vars, year = year, state = state, survey = "acs1") %>%
        filter(AGEP <= 20)
      
      if (any(sapply(data, class) == "list")) {
        stop("Nonatomic columns detected.")
      }
      return(data)
      
    }, error = function(e) {
      if (retries == max_retries) {
        warning(paste("Fetching data for state", state, "failed after", max_retries, "attempts. Returning empty data frame."))
        return(data.frame())
      }
      warning(paste("Error fetching data for state", state, "on attempt", retries, ". Retrying in 5 seconds. Error message:", e$message))
      Sys.sleep(5)
      retries <- retries + 1
    })
  }
}

# Fetch and process data
rawdata_list <- pbmclapply(state_abbreviations, function(state) {
  getDataByState(state, 2021)
}, mc.cores = 23)

rawdata <- bind_rows(rawdata_list)

# ----------------------------------------
# Option to save/load PUMS data as needed
# ----------------------------------------
#save(rawdata, file = "foster/RawData/fosterRawPUMSData.Rdata")
load("foster/RawData/fosterRawPUMSData.Rdata") 

# ----------------------------------------------------------------------------------------------
# Data transformation - Note that foster data does not contain race data for Hispanic children
# ----------------------------------------------------------------------------------------------
pumsData <- rawdata %>% 
  mutate(
    race = case_when(
      HISP > 1 ~ "Hispanic",
      RAC1P == 1 ~ "white",
      RAC1P == 2 ~ "Black",
      RAC1P %in% c(3,5) ~ "Indigenous",
      RAC1P == 6 ~ "Asian",
      RAC1P == 7 ~ "Pacific",
      RAC1P == 9 ~ "Multi",
      TRUE ~ "Other"
    ),
    sex = if_else(SEX == 1, "male", "female")
  ) %>%
  rename(age = AGEP, state_code = ST, count = PWGTP) %>%
  select(state_code, PUMA, age, sex, race, count) %>%
  group_by(state_code, PUMA, age, sex, race) %>%
  summarise(count = sum(count)) %>%
  ungroup
  
fipsLookup <- fips_codes %>%
  select(state, state_code) %>%
  unique %>%
  mutate(state = tolower(state)) %>%
  filter(state %in% state_abbreviations)

pumsData <- merge(pumsData, fipsLookup) %>%
  select(-state_code) %>%
  relocate(state, PUMA, age, sex, race, count)

# --------------------
# Geographical data integration
# --------------------
pumaShapes <- do.call(rbind, pbmclapply(state_abbreviations, function(state) {
  tigris::pumas(state = state, year = 2021, cb = FALSE)
}, mc.cores = 23))

pumaShapes <- pumaShapes %>%
  rename(state_code = STATEFP10, PUMA = PUMACE10) %>%
  select(state_code, PUMA, geometry)

pumaShapes <- merge(pumaShapes, fipsLookup) %>%
  select(-state_code) %>%
  relocate(state, PUMA, geometry)


# --------------------
# Store the finalized data
# --------------------
save(pumsData, file = "foster/ProcessedData/pumsData.Rdata")
save(pumaShapes, file = "foster/ProcessedData/pumaShapes.Rdata")