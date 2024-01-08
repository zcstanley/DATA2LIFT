# -----------------------------------------------------------------------------
# Distribute Youth Arrests to PUMAs Based on Age, Sex, and Race Proportions
# Author: Zofia C. Stanley
# Date: Dec 22, 2023
#
# Description:
# This script processes and integrates arrest data with PUMA (Public Use 
# Microdata Area) data. It calculates the distribution of youth arrests among 
# PUMAs based on demographic proportions of age, sex, and race.
# -----------------------------------------------------------------------------

# --------------------
# Import required libraries
# --------------------
library(tidyverse)     # For data manipulation and visualization
library(tidycensus)    # For working with census data
library(sf)            # For handling spatial data

# --------------------
# Load Processed Data
# --------------------
load("justiceimpacted/ProcessedData/processedArrestData.Rdata") # Arrest data
load("justiceimpacted/ProcessedData/pumsData.Rdata")            # PUMS data

# --------------------------------
# Distribute Arrests to PUMAs
# --------------------------------
# Convert proportion data to counts in arrest data and ensure age is numeric
processedArrestData <- processedArrestData %>% 
  ungroup() %>%
  mutate(
    count = age_sex_race_prop * total_count_state,  # Convert proportions to counts
    age = as.numeric(age)                           # Convert age to numeric
  ) %>%
  select(state, age, sex, race, count)

# Calculate the proportion of each demographic group in each PUMA
pumsData <- pumsData %>%
  group_by(state, age, sex, race) %>%
  mutate(puma_prop = count / sum(count)) %>% # Proportion of each group in each PUMA
  select(-count)

# Join arrest data with PUMS data to distribute arrests across PUMAs
distributedArrestData <- inner_join(processedArrestData, pumsData) %>%
  mutate(arrests = count * puma_prop) %>%  # Calculate distributed arrests
  select(-count, -puma_prop)

# ----------------------------
# Handle Missing Combinations
# ----------------------------
# Determine the total number of PUMAs per state for missing data distribution
pumaMetaData <- pumsData %>%
  group_by(state) %>%
  mutate(total_pumas = n_distinct(PUMA)) %>% # Total PUMAs per state
  select(state, PUMA, total_pumas) %>%
  unique()

# Distribute missing demographic combinations evenly across PUMAs
missingDistributed <- anti_join(processedArrestData, pumsData, by = c("state", "age", "sex", "race")) %>%
  left_join(pumaMetaData, by = "state") %>%
  mutate(distributed_count = count / total_pumas) %>%  # Even distribution of missing data
  select(-total_pumas, -count) %>%
  rename(arrests = distributed_count)

# Aggregate final arrest data for each PUMA
arrestData <- bind_rows(distributedArrestData, missingDistributed)  %>%
  group_by(state, PUMA) %>%
  summarise(count = sum(arrests))  # Sum of arrests in each PUMA

# -----------------------
# Save the Final Data
# -----------------------
save(arrestData, file = "justiceimpacted/ProcessedData/arrestDistributedData.Rdata")  # Save final dataset



