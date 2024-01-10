# -----------------------------------------------------------------------------
# Informal tests to check the scraped foster data for consistency and accuracy.
# Author: Zofia C. Stanley
# Date: Jan 10, 2024
#
# Description:
# This script performs several informal tests on the scrapedFosterData dataset
# to ensure its integrity. These tests include:
#   1. Checking if the age_sex_race_prop totals to 1 for a given state.
#   2. Validating the data types and structure of the dataset.
#   3. Checking for any negative or NaN values in age_sex_race_prop.
#   4. Check that proportions are between 0 and 1.
#   5. Check that race categories are as expected. 
#   6. Check that total counts are consistent within states.
# -----------------------------------------------------------------------------

# Load the processed data
load("foster/ProcessedData/scrapedFosterData.RData")

# --------------------
# Test 1: Proportion Sum for a Given State
# --------------------
test_proportion_sum <- function() {
  # Calculating the sum of age_sex_race_prop for the state "al"
  sum_for_state_al <- sum(scrapedFosterData %>% 
                            filter(state == "al") %>%
                            pull(age_sex_race_prop))
  
  # Checking if the sum is approximately 1
  if (abs(sum_for_state_al - 1) < 1e-6) {
    print("Proportion sum test for state AL passed.")
  } else {
    warning("Proportion sum test for state AL failed.")
  }
}

# --------------------
# Test 2: Data Types and Structure Validation
# --------------------
test_data_types_structure <- function() {
  expected_cols <- c("state", "age", "sex", "race", "total_foster", "age_sex_race_prop")
  
  if (!all(expected_cols %in% names(scrapedFosterData))) {
    warning("Column names test failed.")
  } else if (!is.numeric(scrapedFosterData$total_foster) || 
             !is.numeric(scrapedFosterData$age_sex_race_prop)) {
    warning("Data types test failed.")
  } else {
    print("Data types and structure test passed.")
  }
}

# --------------------
# Test 3: Negative or NaN Values Check in Proportions
# --------------------
test_negative_nan_values <- function() {
  if (!all(scrapedFosterData$age_sex_race_prop >= 0 & 
           !is.nan(scrapedFosterData$age_sex_race_prop))) {
    warning("Negative or NaN values test failed.")
  } else {
    print("Negative or NaN values test passed.")
  }
}

# --------------------
# Test 4: Check Proportions are between 0 and 1
# --------------------
test_prop_bounds <- function() {
  valid_age_sex_race_prop <- all(scrapedFosterData$age_sex_race_prop >= 0 & scrapedFosterData$age_sex_race_prop <= 1)
  
  if (valid_age_sex_race_prop) {
    print("Proportions between 0 and 1 test passed.")
  } else {
    warning("Proportions between 0 and 1 test failed.")
  }
}

# --------------------
# Test 5: Race Category Renaming
# --------------------
test_race_renaming <- function() {
  expected_races <- c("Indigenous", "Asian", "Black", "Pacific", "Hispanic", "white", "Other", "Multi")
  if (all(scrapedFosterData$race %in% expected_races)) {
    print("Race renaming successful.")
  } else {
    warning("Race renaming failed.")
  }
}

# --------------------
# Test 6: Single Value of total_count_state per State
# --------------------
test_total_count_consistency <- function() {
  inconsistent_states <- scrapedFosterData %>%
    group_by(state) %>%
    summarize(is_consistent = n_distinct(total_foster) == 1) %>%
    filter(is_consistent == FALSE) %>%
    pull(state)
  
  if (length(inconsistent_states) == 0) {
    print("All states have a consistent total_count_state.")
  } else {
    warning(paste("Inconsistent total_count_state found in states:", paste(inconsistent_states, collapse = ", ")))
  }
}

# --------------------
# Execute the tests
# --------------------
test_proportion_sum()
test_data_types_structure()
test_negative_nan_values()
test_prop_bounds()
test_race_renaming()
test_total_count_consistency()



