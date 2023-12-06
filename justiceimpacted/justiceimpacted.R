# -----------------------------------------------------------------------------
# Justice Impacted Youth
# Author: Chad M. Topaz
# Date: Oct 26, 2023
#
# Description:
# This script accomplishes the following tasks:
#   - INSERT HERE
# -----------------------------------------------------------------------------

# --------------------
# Import required libraries
# --------------------
library(tidyverse)
library(tidycensus)
library(tigris)
library(pbmcapply)

# --------------------
# Read data
# --------------------

data01 <- readRDS("justiceimpacted/nibrs_arrestee_segment_2021.rds")
data02 <- readRDS("justiceimpacted/nibrs_group_b_arrest_report_segment_2021.rds")

# --------------------
# Restrict and combine data
# --------------------
data03 <- data01 %>%
  select(state_abb, age_of_arrestee, sex_of_arrestee, race_of_arrestee,
         ethnicity_of_arrestee) %>%
  rename(state = state_abb,
         age = age_of_arrestee,
         sex = sex_of_arrestee,
         race = race_of_arrestee,
         ethnicity = ethnicity_of_arrestee) %>%
  filter(age >= 16 & age <= 24)

data04 <- data02 %>%
  select(state_abb, age_of_arrestee, sex_of_arrestee, race_of_arrestee,
         ethnicity_of_arrestee) %>%
  rename(state = state_abb,
         age = age_of_arrestee,
         sex = sex_of_arrestee,
         race = race_of_arrestee,
         ethnicity = ethnicity_of_arrestee) %>%
  filter(age >= 16 & age <= 24)

data05 <- rbind(data03, data04)

# --------------------
# Handle missing data
# --------------------

data06 <- data05 %>%
  mutate(
    ethnicity = ifelse(ethnicity == "unknown", NA, ethnicity),
    race = ifelse(race == "unknown", NA, race)
  ) %>%
  drop_na

# Examine missing percentages by state

# Counting the number of records per state before dropping NAs
original_counts <- data05 %>%
  group_by(state) %>%
  tally(name = "original_count")

# Counting the number of records per state after dropping NAs
new_counts <- data06 %>%
  group_by(state) %>%
  tally(name = "new_count")

# Joining the counts and calculating the percentage excluded
percentage_excluded <- original_counts %>%
  inner_join(new_counts, by = "state") %>%
  mutate(percentage_excluded = (original_count - new_count) / original_count)

# This is bad! We will not be able to use ethnicity data
  
# --------------------
# Recode variables for consistency
# --------------------
data06 <- data05 %>%
  mutate(race = case_when(
    race == "american indian/alaskan native" ~ "Indigenous",
    race == "asian" ~ "Asian",
    race == "black" ~ "Black",
    race == "native hawaiian or other pacific islander" ~ "Pacific",
    race == "white" ~ "White",
    race == "unknown" ~ NA_character_,
    TRUE ~ race
  ))