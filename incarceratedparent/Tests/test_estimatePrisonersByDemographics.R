# Load libraries
library(testthat)
library(reshape2)
library(dplyr)
library(tidyr)

# Indicate that we are in testing mode
testing <- TRUE

# Source script
source("incarceratedparent/Scripts/estimatePrisonersByDemographics.R", local=TRUE)

# --------------------------------------------------
# Test function calculate_proportion_by_race
# --------------------------------------------------

# Sample data for testing
sample_prisoners <- data.frame(
  state = c("State1", "State1", "State2", "State2"),
  race = c("Race1", "Race2", "Race1", "Race2"),
  count = c(200, 300, 150, 350)
)

# 1.1. Test for Correct Proportions
test_that("calculate_proportion_by_race calculates correct proportions", {
  result <- calculate_proportion_by_race(sample_prisoners)
  expected_result <- data.frame(
    state = c("State1", "State1", "State2", "State2"),
    race = c("Race1", "Race2", "Race1", "Race2"),
    proportion = c(0.4, 0.6, 0.3, 0.7)  # calculated proportions
  )
  expect_equal(result, expected_result)
})

# 1.2. Test for Handling of Empty Input
test_that("calculate_proportion_by_race handles empty input", {
  result <- calculate_proportion_by_race(data.frame(state = character(), race = character(), count = numeric()))
  expect_equal(nrow(result), 0)
  expect_equal(ncol(result), 3)
})

# 1.3. Data Types
test_that("calculate_proportion_by_race handles correct data types", {
  result <- calculate_proportion_by_race(sample_prisoners)
  # Check the result is a data frame
  expect_is(result, "data.frame")
  # Check for the existence of expected columns
  expect_true(all(c("state", "race", "proportion") %in% names(result)))
  # Check the data type of each column
  expect_is(result$state, "character", info = "State column should be of type character")
  expect_is(result$race, "character", info = "Race column should be of type character")
  expect_is(result$proportion, "numeric", info = "Proportion column should be of type numeric")
})

# 1.4. Test for Handling of Non-Numeric `count`
test_that("calculate_proportion_by_race handles non-numeric count", {
  sample_prisoners_with_na <- sample_prisoners
  sample_prisoners_with_na$count[1] <- NA  # Introduce an NA
  result <- calculate_proportion_by_race(sample_prisoners_with_na)
  expect_true(any(is.na(result$proportion)))
})

# --------------------------------------------------
# Test function estimate_prisoners_by_sex_race
# --------------------------------------------------

# Sample data for testing
sample_prisonersByStateSex <- data.frame(
  state = c("State1", "State1", "State2"),
  sex = c("male", "female", "male"),
  count = c(200, 300, 150)
)

sample_proportionByRace <- data.frame(
  state = c("State1", "State1", "State2"),
  race = c("Race1", "Race2", "Race1"),
  proportion = c(0.4, 0.6, 0.3)
)

# 2.1. Test for Correct Calculation
test_that("estimate_prisoners_by_sex_race calculates correctly", {
  result <- estimate_prisoners_by_sex_race(sample_prisonersByStateSex, sample_proportionByRace)
  # Check if the function calculates the estimated_count correctly
  expected_result <- data.frame(
    state = c("State1", "State1", "State1", "State1", "State2"),
    sex   = c("male",   "male",   "female", "female", "male"),
    race  = c("Race1",  "Race2",  "Race1",  "Race2",  "Race1"),
    estimated_count = c(80, 120, 120, 180, 45)  # calculated proportions
  )
  expect_equal(result, expected_result)
})


# 2.2. Test for Data Structure and Column Types
test_that("estimate_prisoners_by_sex_race returns correct data structure", {
  result <- estimate_prisoners_by_sex_race(sample_prisonersByStateSex, sample_proportionByRace)
  expect_is(result, "data.frame")
  expect_true(all(c("state", "sex", "race", "estimated_count") %in% names(result)))
  expect_is(result$estimated_count, "numeric")
})

# 2.3. Test for Correct Join Operation
test_that("estimate_prisoners_by_sex_race performs correct join operation", {
  result <- estimate_prisoners_by_sex_race(sample_prisonersByStateSex, sample_proportionByRace)
  expect_equal(nrow(result), 5) # Expecting 4 rows for State1 and 1 row for State2
  expect_true(all(result$sex %in% c("male", "female")))
})

# --------------------------------------------------
# Test function prepare_state_race_sex_data
# --------------------------------------------------

# Sample data for testing
sample_estimatedPrisonersBySexRace <- data.frame(
  state = c("State1", "State1", "State2", "State2", "State1"),
  sex = c("male", "female", "male", "female", "male"),
  race = c("White", "American Indian", "Asian", "Native Hawaiian", "White"),
  estimated_count = c(200, 300, 150, 350, 100)
)

# 3.1. Test for Correct Race Recategorization
test_that("prepare_state_race_sex_data recategorizes race correctly", {
  result <- prepare_state_race_sex_data(sample_estimatedPrisonersBySexRace)
  expected_races <- c("white", "Indigenous", "AsianPacific")
  expect_true(all(result$race %in% expected_races))
})

# 3.2. Test for Aggregation of Count
test_that("prepare_state_race_sex_data aggregates count correctly", {
  result <- prepare_state_race_sex_data(sample_estimatedPrisonersBySexRace)
  # For 'State1' and 'male', 'White' should be aggregated to 'white' and their counts summed
  expect_equal(result$count[result$state == "State1" & result$sex == "male" & result$race == "white"], 300)
  # Check that count is preserved with no aggregation
  expect_equal(result$count[result$state == "State2" & result$sex == "female" & result$race == "AsianPacific"], 350)
})

# 3.3. Test for Unique State/Sex/Race Combinations
test_that("prepare_state_race_sex_data has unique state/sex/race combinations", {
  result <- prepare_state_race_sex_data(sample_estimatedPrisonersBySexRace)
  expect_equal(nrow(result), length(unique(paste(result$state, result$sex, result$race))))
})

# 3.4. Test for Data Structure and Column Types
test_that("prepare_state_race_sex_data returns correct data structure", {
  result <- prepare_state_race_sex_data(sample_estimatedPrisonersBySexRace)
  expect_is(result, "data.frame")
  expect_true(all(c("state", "sex", "race", "count") %in% names(result)))
  expect_is(result$count, "numeric")
})

# --------------------------------------------------
# Test function prepare_age_sex_race_data
# --------------------------------------------------

# Sample data for testing
sample_prisonersByAgeSexRace <- data.frame(
  sex = c("male", "female", "male", "female"),
  race = c("American Indian", "Asian", "Other", "Other"),
  age = c("20–24", "18–19", "20–24", "18–19"),
  percent_by_sex_race = c("50", "30", NA, "20")
)

# 4.1. Test for Correct Race Recategorization
test_that("prepare_age_sex_race_data recategorizes race correctly", {
  result <- prepare_age_sex_race_data(sample_prisonersByAgeSexRace)
  expected_races <- c("Indigenous", "AsianPacific", "Other", "Multi")
  expect_true(all(result$race %in% expected_races))  
})

# 4.2. Test for Correct Handling of Age Format
test_that("prepare_age_sex_race_data handles age format correctly", {
  result <- prepare_age_sex_race_data(sample_prisonersByAgeSexRace)
  # Check if none of the ages have the longer dash '–'
  expect_true(all(!grepl("–", result$age)), 
              info = "Ages should not contain the longer dash symbol '–'")
})

# 4.3. Test for Handling of Missing Data in `percent_by_sex_race`
test_that("prepare_age_sex_race_data handles missing percent_by_sex_race correctly", {
  result <- prepare_age_sex_race_data(sample_prisonersByAgeSexRace)
  expect_equal(result$percent_by_sex_race[3], 0)  # NA should be replaced by 0
})

# 4.4. Test for Data Structure and Column Types
test_that("prepare_age_sex_race_data returns correct data structure", {
  result <- prepare_age_sex_race_data(sample_prisonersByAgeSexRace)
  expect_is(result, "data.frame")
  expect_true(all(c("sex", "race", "age", "percent_by_sex_race") %in% names(result)))
  expect_is(result$percent_by_sex_race, "numeric")
})

# 4.5. Test for Correctness of Row Binding
test_that("prepare_age_sex_race_data binds rows correctly", {
  original_row_count <- nrow(sample_prisonersByAgeSexRace)
  other_row_count <- nrow(sample_prisonersByAgeSexRace %>% filter(race == "Other"))
  result <- prepare_age_sex_race_data(sample_prisonersByAgeSexRace)
  expected_row_count <- original_row_count + other_row_count  # Expecting original rows plus "Other" as "Multi"
  expect_equal(nrow(result), expected_row_count)
})

# --------------------------------------------------
# Test function compute_state_prisoners_by_age_sex_race
# --------------------------------------------------

# Sample data for testing
sample_estimatedPrisonersBySexRace <- data.frame(
  state = c("State1", "State1", "State2"),
  sex = c("male", "female", "male"),
  race = c("Race1", "Race2", "Race1"),
  count = c(200, 300, 150)
)

sample_selectedPrisonersByAgeSexRace <- data.frame(
  sex = c("male", "female"),
  race = c("Race1", "Race2"),
  age = c("20-24", "18-19"),
  percent_by_sex_race = c(0.5, 0.3)
)

# 5.1. Test for Correct Calculation
test_that("compute_state_prisoners_by_age_sex_race calculates correctly", {
  result <- compute_state_prisoners_by_age_sex_race(sample_estimatedPrisonersBySexRace, sample_selectedPrisonersByAgeSexRace)
  # Sort result by estimated_count
  result <- result[order(result$count), ]
  
  # Check if the function calculates the 'count' correctly
  expected_result <- data.frame(
    state = c("State1", "State1", "State2"),
    age = c("20-24", "18-19", "20-24"),
    sex = c("male", "female", "male"),
    race = c("Race1", "Race2", "Race1"),
    count = c(100, 90, 75)
  )   
  # Sort expected_result by estimated_count
  expected_result <- expected_result[order(expected_result$count), ]

  # Reset rownames to avoid mismatches due to ordering
  rownames(result) <- NULL
  rownames(expected_result) <- NULL
  
  expect_equal(result, expected_result)
})

# 5.2. Test for Data Structure and Column Types
test_that("compute_state_prisoners_by_age_sex_race returns correct data structure", {
  result <- compute_state_prisoners_by_age_sex_race(sample_estimatedPrisonersBySexRace, sample_selectedPrisonersByAgeSexRace)
  expect_is(result, "data.frame")
  expect_true(all(c("state", "age", "sex", "race", "count") %in% names(result)))
  expect_is(result$count, "numeric")
})

# --------------------------------------------------
# Test data inputs: prisonersByStateRace
# --------------------------------------------------

# Load the data
load("incarceratedparent/RawData/prisonersByStateRace.Rdata")

# 1.1. Check for Required Columns
test_that("prisonersByStateRace has the correct columns", {
  expect_true(all(c("state", "race", "count") %in% names(prisonersByStateRace)))
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
test_that("There are no NA values", {
  expect_true(!any(is.na(prisonersByStateRace)))
})

rm(prisonersByStateRace)


# --------------------------------------------------
# Test data inputs: prisonersByStateSex
# --------------------------------------------------

# Load the data
load("incarceratedparent/RawData/prisonersByStateSex.Rdata")

# 2.1. Check for Required Columns
test_that("prisonersByStateSex has the correct columns", {
  expect_true(all(c("state", "sex", "count") %in% names(prisonersByStateSex)))
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
test_that("There are no NA values", {
  expect_true(!any(is.na(prisonersByStateSex)))
})

rm(prisonersByStateSex)

# --------------------------------------------------
# Test data inputs: prisonersByAgeSexRace
# --------------------------------------------------

# Load the data
load("incarceratedparent/RawData/prisonersByAgeSexRace.Rdata")

# 3.1. Check for Required Columns
test_that("prisonersByAgeSexRace has the correct columns", {
  expect_true(all(c("age", "race", "sex", "percent_by_sex_race") %in% names(prisonersByAgeSexRace)))
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

