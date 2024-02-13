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

# ---------------------
# Data Transformation 
# ---------------------
# Process and filter PUMS data for incarcerated persons, and transform race and sex data
pumsData <- rawPumsData %>% 
  filter(AGEP >= 18) %>%
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