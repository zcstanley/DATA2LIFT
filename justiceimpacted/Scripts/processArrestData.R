# -----------------------------------------------------------------------------
# Distribute Youth Arrests to PUMAs Based on Age, Sex, and Race Proportions
# Author: Zofia Stanley
# Date: Dec 22, 2023
#
# Description:
# This script accomplishes the following tasks:
#   - Load datasets: fbi arrest data, PUMS data, and PUMA shapefiles.
# -----------------------------------------------------------------------------

# --------------------
# Import required libraries
# --------------------
library(dplyr)
library(readr)

# Define state abbreviations
state_abbreviations <- c(
  "AL", "AK", "AZ", "AR", "CA", "CO", "CT", "DE", "FL", "GA", 
  "HI", "ID", "IL", "IN", "IA", "KS", "KY", "LA", "ME", "MD", 
  "MA", "MI", "MN", "MS", "MO", "MT", "NE", "NV", "NH", "NJ", 
  "NM", "NY", "NC", "ND", "OH", "OK", "OR", "PA", "RI", "SC", 
  "SD", "TN", "TX", "UT", "VT", "VA", "WA", "WV", "WI", "WY", "DC"
)

# Function to read files for a given category
read_files <- function(category) {
  file_paths <- paste0("justiceimpacted/RawData/ArrestData/fbi_arrest_", state_abbreviations, "_", category, ".csv")
  lapply(file_paths, read_csv, col_types = cols()) %>%
    bind_rows()
}

# Read "male" and "female" files together and "race" files separately
sex_data <- rbind(read_files("male"), read_files("female"))
race_data <- read_files("race")

# Select ages between 16 and 24 inclusive
youth_ages <- as.character(seq(16, 24))
sex_data <- sex_data %>% 
  filter(age %in% youth_ages) 
  
# Rename race categories
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

# Convert counts to proportions
race_data <- race_data %>%
  group_by(state) %>%
  mutate(race_prop = count / sum(count))


sex_data <- sex_data %>%
  # Calculate the total count for each state
  group_by(state) %>%
  mutate(total_count_state = sum(count)) %>%
  ungroup() %>%
  # Now, calculate the proportion for each age/sex combination within each state
  group_by(state, age, sex) %>%
  mutate(age_sex_prop = count / total_count_state)



