# -----------------------------------------------------------------------------
# Census Data Retrieval, Transformation and Geographical Integration
# Author: Zofia C. Stanley
# Date: Jan 9, 2024
#
# Description:
# This script computes the number of disconnected youth per PUMA. Disconnected
# youth are persons between 16 and 24 years of age who are neither attending 
# nor employed. This script fetches PUMS data by state, processes 
# and transforms the raw data, integrates geographical data, and stores the 
# finalized data.
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
load("foster/ProcessedData/pumaShapes.Rdata")

# ---------------------
# Count disconnected youth
# ---------------------
disconnectedData <- rawPumsData %>%
  filter(AGEP >= 16 & AGEP <= 24 & SCH == 1 & ESR %in% c(3, 6)) %>%
  rename(age = AGEP, state_code = ST, count = PWGTP) %>%
  select(state_code, PUMA, age, count) %>%
  group_by(state_code, PUMA) %>%
  summarise(count = sum(count), .groups = 'drop') %>%
  ungroup

# ----------------------------------
# Merge in population information
# ----------------------------------
# Process and filter PUMS data for youth ages 16-24
pumaPopData <- rawPumsData %>% 
  select("PWGTP", "AGEP", "PUMA", "ST") %>%
  filter(AGEP >= 16 & AGEP <= 24) %>%
  rename(age = AGEP, state_code = ST, count = PWGTP) %>%
  group_by(state_code, PUMA) %>%
  summarise(total_pop = sum(count), .groups = 'drop') %>%
  ungroup

# Compute disconnected youth per 1,000 youth aged 16-24
disconnectedData <- merge(disconnectedData, pumaPopData) %>%
  mutate(disconnected_per_pop = count/(total_pop/1000)) %>%
  select(-total_pop) 

# ---------------------------------------------
# Get state abbreviations from state codes
# ---------------------------------------------
# Create a lookup table for state FIPS codes
fipsLookup <- fips_codes %>%
  select(state, state_code) %>%
  unique 

# Merge PUMS data with FIPS codes to integrate geographical data
disconnectedData <- merge(disconnectedData, fipsLookup) %>%
  select(-state_code) %>%
  mutate(state = tolower(state)) 

# ---------------------------------------------
# Merge the PUMS data with the PUMA shapefiles
# ---------------------------------------------
disconnectedData <- left_join(pumaShapes, disconnectedData, by = c("state", "PUMA")) %>%
  st_as_sf() %>%
  mutate(puma_area = st_area(.) / 1e6,
         disconnected_density = count/puma_area) %>%
  select(-puma_area) %>%
  mutate(disconnected_density = as.numeric(disconnected_density))

# ------------------------------------------
# Save or load processed data, as necessary
# ------------------------------------------
save(disconnectedData, file = "disconnected/ProcessedData/disconnectedDataByPUMA.Rdata") 
write.csv(disconnectedData %>% st_drop_geometry(), file = "disconnected/ProcessedData/disconnectedDataByPUMA.csv")

