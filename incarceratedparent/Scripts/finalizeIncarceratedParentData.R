# -----------------------------------------------------------------------------
# Distribute Incarcerated Parents to PUMAs Based on Age, Sex, and Race Proportions
# Author: Zofia C. Stanley
# Date: Dec 22, 2023
#
# Description:
# This script processes and integrates parental incarceration data with PUMA (Public Use 
# Microdata Area) data. It calculates the distribution of incarcerated parents among 
# PUMAs based on demographic proportions of age, sex, and race.
# -----------------------------------------------------------------------------

# --------------------
# Import required libraries
# --------------------
library(tidyverse)     # For data manipulation and visualization
library(tidycensus)    # For working with census data
library(sf)            # For handling spatial data

# -----------------------------------------
# Distribute Incarcerated Persons to PUMAs
# -----------------------------------------

calculate_pums_prop_data <- function(pumsData) {
  # Define breaks and labels for the age categories
  age_breaks <- c(18, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65, Inf)
  age_labels <- c("18-19", "20-24", "25-29", "30-34", "35-39", "40-44", "45-49", "50-54", "55-59", "60-64", "65 or older")

  # Calculate the proportion of each demographic group in each PUMA
  pumsPropData <- pumsData %>%
    mutate(age = cut(age, breaks = age_breaks, labels = age_labels, right = FALSE)) %>%
    group_by(state, PUMA, age, sex, race) %>%
    summarise(count = sum(count)) %>%
    ungroup() %>%
    group_by(state, age, sex, race) %>%
    mutate(puma_prop = count / sum(count)) %>% # Proportion of each group in each PUMA
    select(-count)

  return(pumsPropData)
}

distribute_prisoners_to_pumas <- function(prisonersByStateAgeSexRace, pumsPropData){
  # Convert full state names to abbreviations in prisonersByStateAgeSexRace 
  prisonersByStateAgeSexRace <- prisonersByStateAgeSexRace %>%
    mutate(state = state.abb[match(state, state.name)])

  # Join prisoner data with PUMS data to distribute prisoners across PUMAs
  distributedPrisonerData <- inner_join(prisonersByStateAgeSexRace, pumsPropData) %>%
    mutate(prisoners = count * puma_prop) %>%  # Calculate distributed prisoners
    select(-count, -puma_prop)
  
  return(distributedPrisonerData)
}

# ----------------------------
# Handle Missing Combinations
# ----------------------------
distribute_missing_to_pumas <- function(pumsPropData, prisonersByStateAgeSexRace, distributedPrisonerData){
  # Determine the total number of PUMAs per state for missing data distribution
  pumaMetaData <- pumsPropData %>%
    group_by(state) %>%
    mutate(total_pumas = n_distinct(PUMA)) %>% # Total PUMAs per state
    select(state, PUMA, total_pumas) %>%
    unique()
  
  # Convert full state names to abbreviations in prisonersByStateAgeSexRace 
  prisonersByStateAgeSexRace <- prisonersByStateAgeSexRace %>%
    mutate(state = state.abb[match(state, state.name)])

  # Distribute missing demographic combinations evenly across PUMAs
  missingDistributed <- anti_join(prisonersByStateAgeSexRace, pumsPropData, by = c("state", "age", "sex", "race")) %>%
    left_join(pumaMetaData, by = "state") %>%
    mutate(distributed_count = count / total_pumas) %>%  # Even distribution of missing data
    select(-total_pumas, -count) %>%
    rename(prisoners = distributed_count)

  # Aggregate prisoner data for each PUMA
  prisonerData <- bind_rows(distributedPrisonerData, missingDistributed)  %>%
    group_by(state, PUMA, sex, race) %>%
    summarise(count = sum(prisoners))  # Sum of prisoners in each PUMA
  
  return(prisonerData)
}

# ----------------------------
# Estimate Children per Prisoner
# ----------------------------

add_other_race_category <- function(olderChildrenPerPrisoner){
  # Add "Other" rows with average values by sex
  otherChildrenPerPrisoner <- olderChildrenPerPrisoner %>%
    group_by(sex) %>%
    summarise(children_per_prisoner = mean(children_per_prisoner)) %>%
    mutate(race = "Other")

  # Combine the original and new "Other" rows
  olderChildrenPerPrisoner <- bind_rows(olderChildrenPerPrisoner, otherChildrenPerPrisoner)
  
  return(olderChildrenPerPrisoner)
}

calculate_children_with_incarcerated_parent <- function(prisonerData, olderChildrenPerPrisoner){
  # Compute the number of children with an incarcerated parent
  childrenIncarceratedParentData <- merge(prisonerData, olderChildrenPerPrisoner, by = c("sex", "race")) %>%
    mutate(children_with_incarcerated_parent = count * children_per_prisoner) %>%
    group_by(state, PUMA) %>%
    summarise(count = sum(children_with_incarcerated_parent)) 

  return(childrenIncarceratedParentData)
}

# ----------------------------------
# Merge in population information
# ----------------------------------

calculate_puma_pop <- function(rawPumsData){
  # Count children 15-17 years old
  pumaPopData <- rawPumsData %>%
    filter(AGEP >= 15 & AGEP <= 17) %>%
    group_by(ST, PUMA) %>%
    summarise(total_pop = sum(PWGTP)) %>%
    select(ST, PUMA, total_pop) %>%
    rename(state_code = ST) %>%
    ungroup()

  # Create a lookup table for state FIPS codes
  fipsLookup <- fips_codes %>%
    select(state, state_code) %>%
    unique 

  # Merge PUMS data with FIPS codes to integrate geographical data
  pumaPopData <- merge(pumaPopData, fipsLookup) %>%
    select(-state_code) 
  
  return(pumaPopData)
}

calculate_incarcerated_parent_per_pop <- function(childrenIncarceratedParentData, pumaPopData){
  # Compute children with incarcerated parent per 1,000 children (aged 15-17)
  incarceratedParentData <- merge(childrenIncarceratedParentData, pumaPopData) %>%
    mutate(incarcerated_parent_per_pop = count/(total_pop/1000)) %>%
    select(-total_pop)
  
  return(incarceratedParentData)
}

# ----------------------------------
# Merge in geographical information
# ----------------------------------
calculate_incarcerated_parent_density <- function(pumaShapes, incarceratedParentData){
  pumaShapes <- pumaShapes %>%
    mutate(state = toupper(state))

  # Compute density of children with an incarcerated parent
  incarceratedParentData <- merge(incarceratedParentData, pumaShapes) %>%
    st_as_sf() %>%
    mutate(puma_area = st_area(.) / 1e6,
         incarcerated_parent_density = count/puma_area) %>%
    select(-puma_area) %>%
    mutate(incarcerated_parent_density = as.numeric(incarcerated_parent_density))
  
  return(incarceratedParentData)
}

# ----------------------------------
# Save final children with an incarcerated parent data
# ----------------------------------
# Main execution logic (only run when not testing)
if (!exists("testing")) {
  # Load data
  load("incarceratedparent/ProcessedData/olderChildrenPerPrisoner.Rdata")
  load("incarceratedparent/ProcessedData/prisonersByStateAgeSexRace.Rdata")
  load("incarceratedparent/ProcessedData/pumsData.Rdata")         
  load("foster/ProcessedData/pumaShapes.Rdata")   
  load("RawData/PUMSRawData.Rdata")
  
  # Call functions
  pumsPropData <- calculate_pums_prop_data(pumsData) 
  distributedPrisonerData <- distribute_prisoners_to_pumas(prisonersByStateAgeSexRace, pumaPropData)
  prisonerData <- distribute_missing_to_pumas(pumsPropData, prisonersByStateAgeSexRace, distributedPrisonerData)
  olderChildrenPerPrisoner <- add_other_race_category(olderChildrenPerPrisoner)
  childrenIncarceratedParentData <- calculate_children_with_incarcerated_parent(prisonerData, olderChildrenPerPrisoner)
  pumaPopData <- calculate_puma_pop(rawPumsData)
  incarceratedParentData <- calculate_incarcerated_parent_per_pop(childrenIncarceratedParentData, pumaPopData)
  
  # Save data
  save(incarceratedParentData, file = "incarceratedparent/ProcessedData/incarceratedParentDataByPUMA.Rdata")
  write.csv(incarceratedParentData %>% st_drop_geometry(), file = "incarceratedparent/ProcessedData/incarceratedParentDataByPUMA.csv")
}