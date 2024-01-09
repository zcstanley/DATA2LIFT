# -----------------------------------------------------------------------------
# Informal Tests for Justice Impacted Code
# Author: Zofia Stanley
# Date: Dec 22, 2023
#
# Description:
# This script performs several informal tests on the processedArrestData dataset
# to ensure its integrity. These tests include:
#   1. Checking if the age_sex_race_prop totals to 1 for a given state.
#   2. Validating the data types and structure of the dataset.
#   3. Checking for any negative or NaN values in age_sex_race_prop.
#   4. Check that proportions are between 0 and 1.
#   5. Check that race categroies are as expected. 
#   6. Check that total counts are consistent within states.
# -----------------------------------------------------------------------------

# Load the processed data
load("justiceimpacted/ProcessedData/processedArrestData.RData")

# --------------------
# Test 1: Proportion Sum for a Given State
# --------------------
# Calculating the sum of age_sex_race_prop for the state "AL"
sum_for_state_al <- sum(processedArrestData %>% 
                          filter(state == "AL") %>%
                          pull(age_sex_race_prop))

# Checking if the sum is approximately 1
test_state_al <- abs(sum_for_state_al - 1) < 1e-6

# Using if statement to check the condition and provide appropriate feedback
if (test_state_al) {
  print("Proportion sum test for state AL passed.")
} else {
  warning("Proportion sum test for state AL failed.")
}

# --------------------
# Test 2: Data Types and Structure Validation
# --------------------
# Defining expected column names
expected_cols <- c("state", "age", "sex", "race", "total_count_state", "age_sex_race_prop")

# Checking if all expected columns are present
test_cols <- all(expected_cols %in% names(processedArrestData))

# Checking if specific columns are of numeric type
test_types <- is.numeric(processedArrestData$total_count_state) && 
  is.numeric(processedArrestData$age_sex_race_prop)

# Using if statements to provide appropriate feedback
if (test_cols) {
  print("Column names test passed.")
} else {
  warning("Column names test failed.")
}

if (test_types) {
  print("Data types test passed.")
} else {
  warning("Data types test failed.")
}

# --------------------
# Test 3: Negative or NaN Values Check in Proportions
# --------------------
# Checking for negative or NaN values in age_sex_race_prop
test_negative_nan <- all(processedArrestData$age_sex_race_prop >= 0 & 
                           !is.nan(processedArrestData$age_sex_race_prop))

# Using if statement to provide appropriate feedback
if (test_negative_nan) {
  print("Negative or NaN values test passed.")
} else {
  warning("Negative or NaN values test failed.")
}


# --------------------
# Test 4: Check Proportions are between 0 and 1
# --------------------
# Function to test if proportions in age_sex_race_prop, age_sex_prop, and race_prop are between 0 and 1
test_prop_bounds <- function() {
  valid_age_sex_race_prop <- all(processedArrestData$age_sex_race_prop >= 0 & processedArrestData$age_sex_race_prop <= 1)
  valid_age_sex_prop <- all(processedArrestData$age_sex_prop >= 0 & processedArrestData$age_sex_prop <= 1)
  valid_race_prop <- all(processedArrestData$race_prop >= 0 & processedArrestData$race_prop <= 1)
  
  if (valid_age_sex_race_prop && valid_age_sex_prop && valid_race_prop) {
    print("Proportions between 0 and 1 test passed for all categories.")
  } else {
    warning("Proportions between 0 and 1 test failed for one or more categories.")
  }
}

# Execute the test
test_prop_bounds()


# --------------------
# Test 5: Race Category Renaming
# --------------------
test_race_renaming <- function() {
  expected_races <- c("white", "Black", "Indigenous", "Asian", "Pacific", "Other")
  if (all(processedArrestData$race %in% expected_races)) {
    print("Race renaming successful.")
  } else {
    warning("Race renaming failed.")
  }
}

# Execute the test
test_race_renaming()

# --------------------
# Test 6: Single Value of total_count_state per State
# --------------------
# Function to test if total_count_state has a single value within each state
test_total_count_consistency <- function() {
  # Group data by state and check if total_count_state is consistent within each group
  inconsistent_states <- processedArrestData %>%
    group_by(state) %>%
    summarize(is_consistent = n_distinct(total_count_state) == 1) %>%
    filter(is_consistent == FALSE) %>%
    pull(state)
  
  # Checking if any states have inconsistent total_count_state
  if (length(inconsistent_states) == 0) {
    print("All states have a consistent total_count_state.")
  } else {
    warning(paste("Inconsistent total_count_state found in states:", paste(inconsistent_states, collapse = ", ")))
  }
}

# Execute the test
test_total_count_consistency()




