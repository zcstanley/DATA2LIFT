# -----------------------------------------------------------------------------
# Distribute Youth Arrests to PUMAs Based on Age, Sex, and Race Proportions
# Author: Zofia Stanley
# Date: Dec 22, 2023
#
# Description:
# This script loads FBI arrest data, PUMS data, and PUMA shapefiles.
# It processes these datasets to distribute youth arrests based on age, sex, 
# and race proportions.
# -----------------------------------------------------------------------------

# --------------------
# Import required libraries
# --------------------
library(dplyr)
library(readr)

# --------------------
# Define state abbreviations
# --------------------
state_abbreviations <- c(
  "AL", "AK", "AZ", "AR", "CA", "CO", "CT", "DE", "FL", "GA", 
  "HI", "ID", "IL", "IN", "IA", "KS", "KY", "LA", "ME", "MD", 
  "MA", "MI", "MN", "MS", "MO", "MT", "NE", "NV", "NH", "NJ", 
  "NM", "NY", "NC", "ND", "OH", "OK", "OR", "PA", "RI", "SC", 
  "SD", "TN", "TX", "UT", "VT", "VA", "WA", "WV", "WI", "WY", "DC"
)

# --------------------
# Function to read FBI arrest data files for a given category
# --------------------
read_files <- function(category) {
  file_paths <- paste0("justiceimpacted/RawData/ArrestData/fbi_arrest_", state_abbreviations, "_", category, ".csv")
  lapply(file_paths, read_csv, col_types = cols()) %>%
    bind_rows()
}

# --------------------
# Read and prepare sex and race data
# --------------------

# Combine "male" and "female" data into one dataframe
sex_data <- rbind(read_files("male"), read_files("female"))

# Read "race" data
race_data <- read_files("race")

# Filter sex data to include only youth ages (16-24)
youth_ages <- as.character(seq(16, 24))
sex_data <- sex_data %>% 
  filter(age %in% youth_ages)

# Rename race categories for clarity
race_data <- race_data %>% 
  mutate(
    race = case_when(
      race == "White" ~ "white",
      race == "Black or African American" ~ "Black",
      race == "American Indian or Alaska Native" ~ "Indigenous",
      race == "Asian" ~ "Asian",
      race == "Native Hawaiian" ~ "Pacific",
      TRUE ~ "Other"
    ))

# --------------------
# Convert counts to proportions
# --------------------

# Calculate race proportions per state
race_data <- race_data %>%
  group_by(state) %>%
  mutate(race_prop = count / sum(count)) %>%
  select(-offense, -data_year)

# Calculate age and sex proportions per state
sex_data <- sex_data %>%
  group_by(state) %>%
  mutate(total_count_state = sum(count)) %>%
  ungroup() %>%
  group_by(state, age, sex) %>%
  mutate(age_sex_prop = count / total_count_state) %>%
  select(-offense, -data_year)

# --------------------
# Merge dataframes and calculate combined proportions
# --------------------

# Combine age, sex, and race data into a single dataframe
processedArrestData <- sex_data %>%
  select(-count) %>%
  inner_join(race_data %>% select(-count), by = "state") %>%
  group_by(state, age, sex, race, total_count_state) %>%
  mutate(age_sex_race_prop = age_sex_prop * race_prop)

# --------------------
# Save the processed data
# --------------------

# Save the final combined dataset to an Rdata file
save(processedArrestData, file = "justiceimpacted/ProcessedData/processedArrestData.Rdata")


