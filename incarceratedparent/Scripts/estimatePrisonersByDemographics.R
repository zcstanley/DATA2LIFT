# -----------------------------------------------------------------------------
# Estimate Number of State Prisoners by State, Sex, Race, and Age
# Author: Zofia C. Stanley
# Date: Jan 23, 2024
#
# Description:
#   This script estimates the number of state prisoners by state, sex, race, and age. 
#   It uses data from the BJS report "Prisoners in 2022 - Statistical Tables".
#
# Assumptions:
#   1. Race and sex are independent, so that the proportion of prisoners of a certain race 
#      is the same for both males and females in each state.
#   2. Multiracial prisoners have the same age distribution as prisoners classified
#      as "Other".
#
# Citation:
#   Carson, E.A. & Kluckow, M. (2023). Prisoners in 2022 – Statistical Tables. Bureau of Justice Statistics. 
#   https://bjs.ojp.gov/library/publications/prisoners-2022-statistical-tables
# -----------------------------------------------------------------------------

# Load necessary libraries
library(reshape2)
library(dplyr)
library(tidyr)

# --------------------------------------------------
# Estimate state prisoners by state, race, and sex. 
# --------------------------------------------------
calculate_proportion_by_race <- function(prisonersByStateRace) {
  # Calculate total prisoners by state
  totalPrisonersByState <- prisonersByStateRace %>%
    group_by(state) %>%
    summarize(total_count = sum(count))

  # Calculate proportion of each race in each state
  proportionByRace <- prisonersByStateRace %>%
    left_join(totalPrisonersByState, by = "state") %>%
    mutate(proportion = count / total_count) %>%
    select(state, race, proportion)
  
  return(proportionByRace)
}

estimate_prisoners_by_sex_race <- function(prisonersByStateSex, proportionByRace) {
  # Compute number of prisoners by state, sex, and race
  estimatedPrisonersBySexRace <- prisonersByStateSex %>%
    left_join(proportionByRace, by = "state", relationship = "many-to-many") %>%
    mutate(estimated_count = count * proportion) %>%
    select(state, sex, race, estimated_count)
  return(estimatedPrisonersBySexRace)
}

# ------------------------------------------------------
# Estimate state prisoners by state, race, sex, and age. 
# ------------------------------------------------------

prepare_state_race_sex_data <- function(estimatedPrisonersBySexRace) {
  # Match and re-categorize race categories
  estimatedPrisonersBySexRace <- estimatedPrisonersBySexRace %>%
    mutate(race = case_when(
      race == "White" ~ "white",
      race == "American Indian" ~ "Indigenous",
      race == "Asian" ~ "AsianPacific",
      race == "Native Hawaiian" ~ "AsianPacific",
      race == "Two or more races" ~ "Multi",
      race == "Unknown" ~ "Other",
      race == "Did not report" ~ "Other",
      TRUE ~ race  # Keeps the race category unchanged if it doesn't match any of the above
    )) %>%
    group_by(state, sex, race) %>%
    summarize(count = sum(estimated_count)) %>%
    ungroup()
  return(estimatedPrisonersBySexRace)
}
  
prepare_age_sex_race_data <- function(prisonersByAgeSexRace) {
  # Match and re-categorize race categories
  selectedPrisonersByAgeSexRace <- prisonersByAgeSexRace %>%
    mutate(
      race = case_when(
        race == "American Indian" ~ "Indigenous",
        race == "Asian" ~ "AsianPacific",
        TRUE ~ race  # Keeps the race category unchanged if it doesn't match any of the above
    )) %>%
    bind_rows(
      prisonersByAgeSexRace %>%
        filter(race == "Other") %>%
        mutate(race = "Multi") # Use age distribution "Other" for new row "Multi"
    ) %>%
    mutate(
      age = gsub("–", "-", age), 
      percent_by_sex_race = replace_na(as.numeric(percent_by_sex_race), 0) / 100
    ) 
  return(selectedPrisonersByAgeSexRace)
}

compute_state_prisoners_by_age_sex_race <- function(estimatedPrisonersBySexRace, selectedPrisonersByAgeSexRace) {
  # Compute state prisoners by state, sex, race and age
  prisonersByStateAgeSexRace <- merge(estimatedPrisonersBySexRace, selectedPrisonersByAgeSexRace, by = c("sex", "race")) %>%
    mutate(result = count * percent_by_sex_race) %>%
    select(state, age, sex, race, result) %>%
    rename(count = result)
  return(prisonersByStateAgeSexRace)
}

# ----------------
# Save final data
# ----------------
# Main execution logic (only run when not testing)
if (!exists("testing")) {
  # Load required datasets
  load("incarceratedparent/RawData/prisonersByStateRace.Rdata")
  load("incarceratedparent/RawData/prisonersByAgeSexRace.Rdata")
  load("incarceratedparent/RawData/prisonersByStateSex.Rdata")
  
  # Call functions
  proportionByRace <- calculate_proportion_by_race(prisonersByStateRace) 
  estimatedPrisonersBySexRace <- estimate_prisoners_by_sex_race(prisonersByStateSex, proportionByRace)
  estimatedPrisonersBySexRace <- prepare_state_race_sex_data(estimatedPrisonersBySexRace)
  selectedPrisonersByAgeSexRace <- prepare_age_sex_race_data(prisonersByAgeSexRace) 
  prisonersByStateAgeSexRace <- compute_state_prisoners_by_age_sex_race(estimatedPrisonersBySexRace, selectedPrisonersByAgeSexRace) 
  
  # Save data
  save(prisonersByStateAgeSexRace, file = "incarceratedparent/ProcessedData/prisonersByStateAgeSexRace.Rdata")
}
