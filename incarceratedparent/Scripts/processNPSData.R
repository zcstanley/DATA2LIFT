# -----------------------------------------------------------------------------
# Process data on incarcerated persons from the BJS report: "Prisoners in 2022 - Statistical Tables".
# Author: Zofia C. Stanley
# Date: Jan 23, 2024
#
# Description:
# This script loads tables from the report and reformats it into a long format. 
#   1. Number of state prisoners by state and sex.
#   2. Percent of state prisoners by age, within each sex/race category.
#   4. Number of state prisoners by state and race.
#
# Citation:
# Carson, E.A. & Kluckow, M. (2023). Prisoners in 2022 – Statistical Tables. 
# Bureau of Justice Statistics. https://bjs.ojp.gov/library/publications/prisoners-2022-statistical-tables
#
# -----------------------------------------------------------------------------

# Load necessary libraries
library(reshape2)
library(dplyr)
library(tidyr)

# -------------------------------------------------------
# Reformat data on state prisoners by state and sex
# -------------------------------------------------------

# Read and clean data
data <- read.csv("incarceratedparent/RawData/NPS/p22stt02.csv", skip = 15, header = FALSE)
data2022 <- data[c(2, 8, 9)]
colnames(data2022) <- c("state", "male", "female")
data2022 <- data2022 %>%
  mutate(
    state = gsub("/.$", "", state),
    male = as.numeric(gsub(",", "", male)),
    female = as.numeric(gsub(",", "", female))
  ) %>%
  drop_na()

# Convert to long format
prisonersByStateSex <- melt(data2022, id.vars = "state", variable.name = "sex", value.name = "count")

# Save data
save(prisonersByStateSex, file = "incarceratedparent/RawData/prisonersByStateSex.Rdata")

# -------------------------------------------------------
# Reformat data on state prisoners by age, sex, and race
# -------------------------------------------------------

# Read and select data
data <- read.csv("incarceratedparent/RawData/NPS/p22stt11.csv", skip = 11, header = FALSE, fileEncoding="Windows-1252")
selected_data <- data %>%
  select(1, 7, seq(9, 17, by = 2), seq(21, 31, by = 2))

# Set and clean column names
column_names <- as.character(unlist(selected_data[1, ]))
selected_data <- selected_data[-1, ]
transformed_column_names <- column_names %>%
  gsub("/.*$", "", .) %>%  # Remove / followed by any characters at the end of the words
  gsub("American Indian/Alaska Native", "Indigenous", .) %>%  
  gsub("White", "white", .) %>%
  gsub("Age", "age", .)  

# Add suffixes to indicate sex
transformed_column_names[2:7] <- paste0(transformed_column_names[2:7], "_male")
transformed_column_names[8:13] <- paste0(transformed_column_names[8:13], "_female")
colnames(selected_data) <- transformed_column_names

# Filter and reshape data
selected_data <- selected_data %>%
  filter(age != "" & white_male != "") 
prisonersByAgeSexRace <- selected_data %>%
  pivot_longer(
    cols = -age,  # Select all columns except 'age' for reshaping
    names_to = c("race", "sex"),  
    names_sep = "_",
    values_to = "percent_by_sex_race"
  ) %>%
  mutate(percent_by_sex_race = na_if(percent_by_sex_race, "^"))

# Save data
save(prisonersByAgeSexRace, file = "incarceratedparent/RawData/prisonersByAgeSexRace.Rdata")

# -------------------------------------------------------
# Reformat data on state prisoners by state and race
# -------------------------------------------------------

# Read and select data
data <- read.csv("incarceratedparent/RawData/NPS/p22stat01.csv", skip = 10, header = FALSE)
selected_data <- data[c(-1, -3)]

# Set and clean column names
column_names <- as.character(unlist(selected_data[1, ]))
selected_data <- selected_data[-1, ]
transformed_column_names <- column_names %>%
  gsub("/.*$", "", .) 
transformed_column_names[1] <- "state"
colnames(selected_data) <- transformed_column_names

# Clean and reshape data
selected_data <- selected_data %>%
  mutate(
    state = gsub("/.*$", "", state)
  ) %>%
  filter(state != "") %>%
  mutate(across(-state, ~ gsub(",", "", .x)),
         across(-state, ~ gsub("[~/]", "0", .x)),
         across(-state, as.numeric)
         )
prisonersByStateRace <- selected_data %>%
  pivot_longer(
    cols = -state,  # Select all columns except 'state' for reshaping
    names_to = c("race"), 
    values_to = "count"
  ) 

# Save data
save(prisonersByStateRace, file = "incarceratedparent/RawData/prisonersByStateRace.Rdata")
