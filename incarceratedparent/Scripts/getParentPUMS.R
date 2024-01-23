# -----------------------------------------------------------------------------
# Census Data Retrieval, Transformation and Geographical Integration
# Author: Zofia C. Stanley
# Date: Jan 22, 2023
#
# Description:
# This script fetches PUMS data by state for parents of children aged 15-17.
# We assume that parents of children in this age range are 30-50 years old.
# -----------------------------------------------------------------------------

# --------------------
# Import required libraries
# --------------------
library(tidyverse)     # For data manipulation and visualization
library(tidycensus)    # For working with census data

# ----------------------------------------
# Load PUMS data from a saved Rdata file
# ----------------------------------------
load("RawData/PUMSRawData.Rdata") 

# Define state abbreviations for processing
state_abbreviations <- c(
  "AL", "AK", "AZ", "AR", "CA", "CO", "CT", "DE", "FL", "GA", 
  "HI", "ID", "IL", "IN", "IA", "KS", "KY", "LA", "ME", "MD", 
  "MA", "MI", "MN", "MS", "MO", "MT", "NE", "NV", "NH", "NJ", 
  "NM", "NY", "NC", "ND", "OH", "OK", "OR", "PA", "RI", "SC", 
  "SD", "TN", "TX", "UT", "VT", "VA", "WA", "WV", "WI", "WY", "DC"
)

# ---------------------
# Data Transformation 
# ---------------------
# Process and filter PUMS data for parents (assumed 30-59), and transform race and sex data
pumsData <- rawPumsData %>% 
  filter(AGEP >= 30 & AGEP <= 59) %>%
  mutate(
    race = case_when(
      HISP > 1 ~ "Hispanic",
      RAC1P == 1 ~ "white",
      RAC1P == 2 ~ "Black",
      RAC1P %in% c(3,4,5) ~ "Indigenous",
      RAC1P %in% c(6,7) ~ "AsianPacific",
      RAC1P == 9 ~ "Multi",
      TRUE ~ "Other"
    ),
    sex = if_else(SEX == 1, "male", "female")
  ) %>%
  rename(age = AGEP, state_code = ST, count = PWGTP) %>%
  select(state_code, PUMA, age, sex, race, count) %>%
  group_by(state_code, PUMA, age, sex, race) %>%
  summarise(count = sum(count), .groups = 'drop') %>%
  ungroup

# Create a lookup table for state FIPS codes
fipsLookup <- fips_codes %>%
  select(state, state_code) %>%
  unique 

# Merge PUMS data with FIPS codes to integrate geographical data
pumsData <- merge(pumsData, fipsLookup) %>%
  select(-state_code) %>%
  relocate(state, PUMA, age, sex, race, count)

# --------------------
# Store the finalized data
# --------------------
save(pumsData, file = "incarceratedparent/ProcessedData/pumsData.Rdata")