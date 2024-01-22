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

# Load required datasets
load("incarceratedparent/RawData/incarceratedParentPercentData.Rdata")
load("incarceratedparent/RawData/childrenByParentSexData.Rdata")
load("incarceratedparent/RawData/childAgeData.Rdata")
load("incarceratedparent/RawData/numPrisoners2016Data.Rdata")

# -----------------------------------------------------------------------------
# Step 1: Compute the number of children aged 15-17 who have a parent incarcerated in a state prison by sex of the parent.
# -----------------------------------------------------------------------------
# Filter data for state jurisdiction and children aged 15-17
childAgeState <- childAge %>% 
  filter(jurisdiction == "state", child_age == "15-17") %>%
  rename(percent_by_age = percent)

# Filter data for state jurisdiction
childrenByParentSexState <- childrenByParentSex %>% 
  filter(jurisdiction == "state") %>%
  rename(percent_parent = percent)

# Calculate number of children aged 15-17
olderChildrenByParentSex <- merge(childrenByParentSexState, childAgeState, by = c("jurisdiction", "sex")) %>% 
  mutate(
    count_children = as.numeric(gsub(",", "", count_children)), # Remove commas from count_children
    percent_by_age = as.numeric(percent_by_age) / 100, # Convert percent to proportion
    children_15_17 = count_children * percent_by_age # Calculate number of children 15-17
  ) %>%
  select("sex", "children_15_17")

# -----------------------------------------------------------------------------
# Step 2: Compute the number of incarcerated parents in state prisons by sex and race.
# -----------------------------------------------------------------------------
incarceratedParentCount <- merge(incarceratedParentPercent, numPrisoners16, by = c("jurisdiction", "race", "sex")) %>%
  filter(jurisdiction == "state") %>%
  mutate(
    count = as.numeric(gsub(",", "", count)),
    percent = as.numeric(percent) / 100,
    num_incarcerated_parents = percent * count # Calculate number of incarcerated parents
  ) %>%
  select("race", "sex", "num_incarcerated_parents")

# -----------------------------------------------------------------------------
# Step 3: Compute the number of children aged 15-17 with an incarcerated parent by sex and race of the parent.
# -----------------------------------------------------------------------------
# Sum the number of incarcerated parents by sex
totalIncarceratedParentsBySex <- incarceratedParentCount %>%
  group_by(sex) %>%
  summarise(total_parents = sum(num_incarcerated_parents))

# Calculate the proportion of incarcerated parents for each race and sex
mergedData <- merge(incarceratedParentCount, totalIncarceratedParentsBySex, by = "sex") %>%
  mutate(parent_proportion = num_incarcerated_parents / total_parents)

# Calculate the number of older children (15-17) by race and sex
olderChildrenByParentSexRace <- merge(mergedData, olderChildrenByParentSex, by = "sex") %>%
  mutate(children_15_17_by_race_sex = parent_proportion * children_15_17) %>%
  select(race, sex, children_15_17_by_race_sex)

# -----------------------------------------------------------------------------
# Step 4: Compute number of children aged 15-17 per state prisoner by sex and race.
# -----------------------------------------------------------------------------
# Ensure the 'count' in numPrisoners16 is numeric
numPrisoners <- numPrisoners16 %>%
  mutate(count = as.numeric(gsub(",", "", count))) %>%
  filter(jurisdiction == "state") %>%
  select(-jurisdiction)

# Compute number of older children per prisoner
olderChildrenPerPrisoner <- merge(olderChildrenByParentSexRace, numPrisoners, by = c("race", "sex")) %>%
  mutate(children_per_prisoner = children_15_17_by_race_sex / count) %>%
  select(race, sex, children_per_prisoner)

# ----------------
# Save final data
# ----------------
save(olderChildrenPerPrisoner, file = "incarceratedparent/ProcessedData/olderChildrenPerPrisoner.Rdata")



