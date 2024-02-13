# -----------------------------------------------------------------------------
# Test Suite for NPS Data Validation
# Author: Zofia C. Stanley
# Date: Feb 6, 2024
#
# Description:
#   This test suite validates the integrity of the data tables processed from the
#   BJS report "Prisoners in 2022 - Statistical Tables" into a long format. 
# -----------------------------------------------------------------------------

# Load necessary libraries
library(testthat)
library(reshape2)
library(dplyr)
library(tidyr)

# --------------------------------------------------
# Test data outputs: prisonersByStateRace
# --------------------------------------------------
# Load the data
load("incarceratedparent/RawData/prisonersByStateRace.Rdata")

# 1.1. Check for Required Columns
test_that("prisonersByStateRace has the correct columns", {
  expect_true(all(c("state", "race", "count") %in% names(prisonersByStateRace)))
  expect_true(is.numeric(prisonersByStateRace$count))
})

# 1.2. Check State Name Formatting using Regex
test_that("State names are formatted correctly", {
  # Regex pattern for state name: one or more words starting with a capital letter, possibly separated by spaces
  pattern <- "^[A-Z][a-z]+(?: [A-Z][a-z]+)*$"
  expect_true(all(grepl(pattern, prisonersByStateRace$state)))
})

# 1.3. Check Race Categories
test_that("Race categories are as expected", {
  expected_races <- c(
    "White", "Black", "Hispanic", "American Indian", "Asian", 
    "Native Hawaiian", "Two or more races", "Other", "Unknown", "Did not report"
  )
  expect_true(all(prisonersByStateRace$race %in% expected_races))
})

# 1.4. Check for NA values
test_that("There are no NA or negative values", {
  expect_true(!any(is.na(prisonersByStateRace)))
  expect_true(all(prisonersByStateRace$count >= 0))
  
})

rm(prisonersByStateRace)


# --------------------------------------------------
# Test data outputs: prisonersByStateSex
# --------------------------------------------------
# Load the data
load("incarceratedparent/RawData/prisonersByStateSex.Rdata")

# 2.1. Check for Required Columns
test_that("prisonersByStateSex has the correct columns", {
  expect_true(all(c("state", "sex", "count") %in% names(prisonersByStateSex)))
  expect_true(is.numeric(prisonersByStateSex$count))
})

# 2.2. Check State Name Formatting using Regex
test_that("State names are formatted correctly", {
  # Regex pattern for state name: one or more words starting with a capital letter, possibly separated by spaces
  pattern <- "^[A-Z][a-z]+(?: [A-Z][a-z]+)*$"
  expect_true(all(grepl(pattern, prisonersByStateSex$state)))
})

# 2.3. Check Sex Categories
test_that("Sex is male or female", {
  expect_true(all(prisonersByStateSex$sex %in% c("female", "male")))
})

# 2.4. Check for NA values
test_that("There are no NA or negative values", {
  expect_true(!any(is.na(prisonersByStateSex)))
  expect_true(all(prisonersByStateSex$count >= 0))
})

rm(prisonersByStateSex)

# --------------------------------------------------
# Test data outputs: prisonersByAgeSexRace
# --------------------------------------------------
# Load the data
load("incarceratedparent/RawData/prisonersByAgeSexRace.Rdata")

# 3.1. Check for Required Columns
test_that("prisonersByAgeSexRace has the correct columns", {
  expect_true(all(c("age", "race", "sex", "percent_by_sex_race") %in% names(prisonersByAgeSexRace)))
  expect_true(is.character(prisonersByAgeSexRace$percent_by_sex_race))
})

# 3.2. Check Sex Categories
test_that("Sex is male or female", {
  expect_true(all(prisonersByAgeSexRace$sex %in% c("female", "male")))
})

# 3.3. Check Race Categories
test_that("Race categories are as expected", {
  expected_races <- c("white", "Black", "Hispanic", "American Indian", "Asian","Other")
  expect_true(all(prisonersByAgeSexRace$race %in% expected_races))
})

# 3.4. Test that the sum of percent_by_sex_race for each sex/race combination is close to 100
test_that("Sum of percent_by_sex_race for each sex/race combination is 100", {
  # Replace NA with 0 and calculate the total percentage for each sex/race combination
  totals <- prisonersByAgeSexRace %>%
    mutate(percent_by_sex_race = replace_na(as.numeric(percent_by_sex_race), 0)) %>%
    group_by(sex, race) %>%
    summarize(total = sum(percent_by_sex_race), .groups = "drop")
  # Check if the total is 100 for each sex/race combination
  expect_true(all(totals$total > 99 & totals$total < 101), info = "The total percent_by_sex_race for each sex/race combination should be (close to) 100.")
})

rm(prisonersByAgeSexRace)