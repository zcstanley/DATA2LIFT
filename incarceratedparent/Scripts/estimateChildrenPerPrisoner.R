# -----------------------------------------------------------------------------
# Estimate Number of Children Aged 15-17 per State Prisoner by Sex and Race
# Author: Zofia C. Stanley
# Date: Jan 22, 2024
#
# Description:
# This script estimates the number of children aged 15-17 per state prisoner by sex and race of the prisoner. 
# It uses data from the 2021 "Parents in Prison and Their Minor Children: Survey of Prison Inmates, 2016" report.
#
# Assumption:
# The distribution of children aged 15-17 among the races and sexes of incarcerated parents 
# is proportional to the distribution of the incarcerated parents themselves.
#
# Citation:
# Maruschak, L. M., & Bronson, J. (2021). Parents in Prison and Their Minor Children: Survey of Prison Inmates, 
# 2016 (NCJ 252645). Bureau of Justice Statistics. https://www.bjs.gov/index.cfm?ty=pbdetail&iid=7317
# -----------------------------------------------------------------------------

# Load necessary libraries
library(reshape2)
library(dplyr)
library(tidyr)


# -----------------------------------------------------------------------------
# Step 1: Compute the number of children aged 15-17 who have a parent incarcerated in a state prison by sex of the parent.
# -----------------------------------------------------------------------------
compute_older_children_by_parent_sex <- function(childrenByParentSex, childAge) {
  # Percent of recorded children 15-17 whose parent is in state prison
  childAgeState <- childAge %>% 
    filter(jurisdiction == "state", child_age == "15-17") %>%
    rename(percent_by_age = percent)

  # Number of recorded children with a parent in state prison by sex of incarcerated parent
  childrenByParentSexState <- childrenByParentSex %>% 
    filter(jurisdiction == "state") %>%
    rename(percent_parent = percent)

  # Number of children 15-17 with a parent incarcerated in state prison
  olderChildrenByParentSex <- merge(childrenByParentSexState, childAgeState, by = c("jurisdiction", "sex")) %>% 
    mutate(
      count_children = as.numeric(gsub(",", "", count_children)), # Remove commas from count_children
      percent_by_age = as.numeric(percent_by_age) / 100, # Convert percent to proportion
      children_15_17 = count_children * percent_by_age # Calculate number of children 15-17
    ) %>%
    select("sex", "children_15_17")
  
  return(olderChildrenByParentSex)
}

# -----------------------------------------------------------------------------
# Step 2: Compute the number of incarcerated parents in state prisons by sex and race.
# -----------------------------------------------------------------------------
compute_incarcerated_parent_count <- function(incarceratedParentPercent, numPrisoners16) {
  incarceratedParentCount <- merge(incarceratedParentPercent, numPrisoners16, by = c("jurisdiction", "race", "sex")) %>%
    filter(jurisdiction == "state") %>%
    mutate(
      count = as.numeric(gsub(",", "", count)),
      percent = as.numeric(percent) / 100,
      num_incarcerated_parents = percent * count # Calculate number of incarcerated parents
    ) %>%
    select("race", "sex", "num_incarcerated_parents")
  
  return(incarceratedParentCount)
}

# -----------------------------------------------------------------------------
# Step 3: Compute the number of children aged 15-17 with an incarcerated parent by sex and race of the parent.
# -----------------------------------------------------------------------------
compute_children_by_parent_sex_race <- function(incarceratedParentCount, olderChildrenByParentSex) {
  # Sum the number of incarcerated parents by sex
  totalIncarceratedParentsBySex <- incarceratedParentCount %>%
    group_by(sex) %>%
    summarize(total_parents = sum(num_incarcerated_parents))

  # Calculate the proportion of incarcerated parents for each race and sex
  mergedData <- merge(incarceratedParentCount, totalIncarceratedParentsBySex, by = "sex") %>%
    mutate(parent_proportion = num_incarcerated_parents / total_parents)

  # Calculate the number of older children (15-17) by race and sex
  olderChildrenByParentSexRace <- merge(mergedData, olderChildrenByParentSex, by = "sex") %>%
    mutate(children_15_17_by_race_sex = parent_proportion * children_15_17) %>%
    select(race, sex, children_15_17_by_race_sex)
  
  return(olderChildrenByParentSexRace)
}

# -----------------------------------------------------------------------------
# Step 4: Compute number of children aged 15-17 per state prisoner by sex and race.
# -----------------------------------------------------------------------------
compute_children_per_prisoner <- function(olderChildrenByParentSexRace, numPrisoners16) {
  
  # Ensure the 'count' in numPrisoners16 is numeric
  numPrisoners <- numPrisoners16 %>%
    mutate(count = as.numeric(gsub(",", "", count))) %>%
    filter(jurisdiction == "state") %>%
    select(-jurisdiction)

  # Compute number of older children per prisoner
  olderChildrenPerPrisoner <- merge(olderChildrenByParentSexRace, numPrisoners, by = c("race", "sex")) %>%
    mutate(children_per_prisoner = children_15_17_by_race_sex / count) %>%
    select(race, sex, children_per_prisoner)
  
  return(olderChildrenPerPrisoner)
}

# ----------------
# Save final data
# ----------------
# Main execution logic (only run when not testing)
if (!exists("testing")) {
  # Load required datasets
  load("incarceratedparent/RawData/incarceratedParentPercentData.Rdata")
  load("incarceratedparent/RawData/childrenByParentSexData.Rdata")
  load("incarceratedparent/RawData/childAgeData.Rdata")
  load("incarceratedparent/RawData/numPrisoners2016Data.Rdata")
  
  # Call functions 
  olderChildrenByParentSex <- compute_older_children_by_parent_sex(childrenByParentSex, childAge)
  incarceratedParentCount <- compute_incarcerated_parent_count(incarceratedParentPercent, numPrisoners16)
  olderChildrenByParentSexRace <- compute_children_by_parent_sex_race(incarceratedParentCount, olderChildrenByParentSex)
  olderChildrenPerPrisoner <- compute_children_per_prisoner(olderChildrenByParentSexRace, numPrisoners16)

  # Save final data
  save(olderChildrenPerPrisoner, file = "incarceratedparent/ProcessedData/olderChildrenPerPrisoner.Rdata")
}



