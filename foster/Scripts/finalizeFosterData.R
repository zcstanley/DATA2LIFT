# -----------------------------------------------------------------------------
# Distribute Foster Children to PUMAs Based on Age, Sex, and Race Proportions
# Author: Chad M. Topaz, Zofia Stanley
# Date: Dec 14, 2023
#
# Description:
# This script accomplishes the following tasks:
#   - Load datasets: scraped foster data, PUMS data, and PUMA shapefiles.
#   - Convert proportions to counts for foster data.
#   - Calculate the proportion of each PUMA by age, sex, and race.
#   - Distribute foster children among PUMAs according to demographic proportions.
# -----------------------------------------------------------------------------

# --------------------
# Import required libraries
# --------------------
library(tidyverse)
library(tidycensus)
library(sf)

# --------------------
# Load data
# --------------------
load("foster/ProcessedData/scrapedFosterData.Rdata")
load("foster/ProcessedData/pumsData.Rdata")

# --------------------------------
# Distribute foster kids to PUMAS
# --------------------------------
# Convert props to counts in foster data
scrapedFosterData <- scrapedFosterData %>%
  mutate(count = prop * total_state) %>%
  select(-prop, -total_state)

# Calculate the proportion of each PUMA for a given combination of age/sex/race
# e.g. of all the 1 y/o Black girls in a given state, what fraction are in a given PUMA?
pumsData <- pumsData %>%
  group_by(state, age, sex, race) %>%
  mutate(puma_prop = count / sum(count)) %>%
  select(-count)

# Create a new dataframe by joining the two dataframes on the common columns (state, age, sex, race)
distributedFosterData <- inner_join(scrapedFosterData, pumsData) %>%
  mutate(foster = count * puma_prop) %>%
  select(-count, -puma_prop)

# ----------------------------
# Handle missing combinations
# ----------------------------
# Identify the total number of PUMAs for each state
pumaMetaData <- pumsData %>%
  group_by(state) %>%
  mutate(total_pumas = n_distinct(PUMA)) %>%
  select(state, PUMA, total_pumas) %>%
  unique()

# Identify missing combinations and distribute children
missingDistributed <- anti_join(scrapedFosterData, pumsData, by = c("state", "age", "sex", "race")) %>%
  left_join(pumaMetaData, by = "state") %>%
  mutate(distributed_count = count / total_pumas) %>%
  select(-total_pumas, -count) %>%
  rename(foster = distributed_count)

# Total up foster kids in each PUMA
fosterData <- bind_rows(distributedFosterData, missingDistributed)  %>%
  group_by(state, PUMA) %>%
  summarise(count = sum(foster))

# -----------------------
# Save
# -----------------------
save(fosterData, file = "foster/ProcessedData/fosterProcessedData.Rdata")
