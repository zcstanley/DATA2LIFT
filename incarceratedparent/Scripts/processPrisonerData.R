# -----------------------------------------------------------------------------
# Process data on incarcerated persons from SPI and NPS.
# Author: Zofia Stanley
# Date: Jan 19, 2024
#
# Description:
# This script loads SPI the following data and reformats it into a long format. 
#   1. Percent of prisoners who are parents by sex and race.
#   2. Number of children with incarcerated parent by sex of parent. 
#   3. Percent of children with incarcerated parent by age of child and sex of parent.
#   4. Number of prisoners by sex and race.
# -----------------------------------------------------------------------------

# Load necessary libraries
library(reshape2)
library(dplyr)
library(tidyr)

# -----------------------------------------------------------------------------
# Process and clean data for incarcerated parent percentages
# -----------------------------------------------------------------------------

# Read the CSV file, skip unnecessary rows and fix header
data <- read.csv("incarceratedparent/RawData/SPI/pptmcspi16stt03.csv", skip = 12, header = FALSE)

# Select relevant columns and rows
data <- data[c(1, 2, 3, 6, 9, 12)]
colnames(data) <- c('jurisdiction', 'race', 'male_percent', 'male_standarderrror', 'female_percent', 'female_standarderror')

# Fill jurisdiction values downward to replace empty cells
data$jurisdiction[data$jurisdiction == ""] <- NA
data <- data %>% fill(jurisdiction, .direction = 'down')

# Remove rows with no information
data <- data %>% drop_na()

# Clean race names (remove extra characters and notes)
data$race <- gsub("/b\\*?$", "", data$race)
data$race <- trimws(data$race)

# Melt the data to long format for incarcerated parent percentages
incarceratedParentPercent <- melt(data, id.vars = c("jurisdiction", "race"),
                  measure.vars = c("male_percent", "male_standarderrror", "female_percent", "female_standarderror"),
                  variable.name = "variable", value.name = "value")

# Extract 'sex' and 'measure' information from variable names
incarceratedParentPercent$sex <- ifelse(grepl("female", incarceratedParentPercent$variable), "female", "male")
incarceratedParentPercent$measure <- ifelse(grepl("percent", incarceratedParentPercent$variable), "percent", "standard_error")

# Drop the original 'variable' column as it's no longer needed
incarceratedParentPercent$variable <- NULL

# Ensure 'measure' column correctly differentiates between 'percent' and 'standard_error'
incarceratedParentPercent$measure <- ifelse(grepl("percent", incarceratedParentPercent$measure), "percent", "standard_error")

# Use dcast to spread the 'percent' and 'standard_error' into separate columns
incarceratedParentPercent <- dcast(incarceratedParentPercent, jurisdiction + race + sex ~ measure, value.var = "value")

# Rename race categories for clarity
incarceratedParentPercent <- incarceratedParentPercent %>% 
  mutate(
    race = case_when(
      race == "White" ~ "white",
      race == "Black" ~ "Black",
      race == "Hispanic" ~ "Hispanic",
      race == "American Indian/Alaska Native" ~ "Indigenous",
      race == "Asian/Native Hawaiian/Other Pacific Islander" ~ "AsianPacific",
      race == "Two or more races" ~ "Multi",
      TRUE ~ "Other"
    ), 
    jurisdiction = case_when(
      jurisdiction == "State prisoners" ~ "state",
      jurisdiction == "Federal prisoners" ~ "federal",
    ))  

# Save reformatted data
save(incarceratedParentPercent, file = "incarceratedparent/RawData/incarceratedParentPercentData.Rdata")

# -----------------------------------------------------------------------------
# Process and clean data for children by parent sex
# -----------------------------------------------------------------------------

# Read in file with estimates of number of children by sex of prisoner
data <- read.csv("incarceratedparent/RawData/SPI/pptmcspi16stt02.csv", skip = 12, header = FALSE)

# Select relevant columns and rows
data <- data[c(1, 3, 4, 7, 10, 11)]
colnames(data) <- c('jurisdiction', 'sex', 'parent_percent', 'parent_standarderrror', 'count_children', 'children_standarderror')

# Fill jurisdiction values
data$jurisdiction[data$jurisdiction == ""] <- NA
data <- data %>% fill(jurisdiction, .direction = 'down')

# Remove rows with no information and filter out empty 'sex' entries
childrenByParentSex <- data %>%
  drop_na() %>%
  filter(sex != "") %>%
  mutate(
    jurisdiction = tolower(jurisdiction),
    sex = tolower(gsub("\\*?$", "", sex)), 
  )

# Save reformatted data
save(childrenByParentSex, file = "incarceratedparent/RawData/childrenByParentSexData.Rdata")

# -----------------------------------------------------------------------------
# Process and clean data for child age distribution
# -----------------------------------------------------------------------------

# Read the CSV file, skip unnecessary rows and fix header
data <- read.csv("incarceratedparent/RawData/SPI/pptmcspi16stt04.csv", skip = 11, header = FALSE)

# Select relevant columns and filter rows for age categories
data <- data[c(1, 5, 8, 14, 17)]
colnames(data) <- c('child_age', 'male_state', 'female_state', 'male_federal', 'female_federal')
data <- data[grepl("^Younger than 1|1-4|5-9|10-14|15-17$", data$child_age), ]

# Melt the data to long format for child age distribution
childAge <- melt(data, id.vars = "child_age", variable.name = "jurisdiction_sex", value.name = "percent")

# Split the 'jurisdiction_sex' column into 'jurisdiction' and 'sex'
childAge <- childAge %>%
  separate(jurisdiction_sex, into = c("sex", "jurisdiction"), sep = "_") 

# Save reformatted data
save(childAge, file = "incarceratedparent/RawData/childAgeData.Rdata")

# -----------------------------------------------------------------------------
# Process and clean data for number of prisoners by sex and race
# -----------------------------------------------------------------------------

# Read CSV file containing number of prisoners by sex and race
data <- read.csv("incarceratedparent/RawData/SPI/pptmcspi16stat01.csv", skip = 12, header = FALSE)

# Select relevant columns and rows
data <- data[c(1, 2, 4, 5)]
colnames(data) <- c('jurisdiction', 'race', 'male', 'female')

# Fill jurisdiction values
data$jurisdiction[data$jurisdiction == ""] <- NA
data <- data %>% fill(jurisdiction, .direction = 'down')

# Remove rows with no information
data <- data %>%
  filter(race != "") %>%
  mutate(
    race = gsub("\\*?$", "", race),
    race = case_when(
        race == "White" ~ "white",
        race == "Black" ~ "Black",
        race == "Hispanic" ~ "Hispanic",
        race == "American Indian/Alaska Native" ~ "Indigenous",
        race == "Asian/Native Hawaiian/Other Pacific Islander" ~ "AsianPacific",
        race == "Two or more races" ~ "Multi",
        TRUE ~ "Other"
    ),
    jurisdiction = case_when(
      jurisdiction == "State prisoners" ~ "state",
      jurisdiction == "Federal prisoners" ~ "federal"
    )
  )

# Melt the data to long format for number of prisoners
numPrisoners16 <- melt(data, id.vars = c("jurisdiction", "race"),
                                  measure.vars = c("male", "female"),
                                  variable.name = "sex", value.name = "count")
# Save reformatted data
save(numPrisoners16, file = "incarceratedparent/RawData/numPrisoners2016Data.Rdata")
