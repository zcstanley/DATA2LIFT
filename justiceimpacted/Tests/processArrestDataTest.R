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
print(paste("Proportion sum test for state AL passed:", test_state_al))

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

# Printing test results
print(paste("Column names test passed:", test_cols))
print(paste("Data types test passed:", test_types))

# --------------------
# Test 3: Negative or NaN Values Check in Proportions
# --------------------
# Checking for negative or NaN values in age_sex_race_prop
test_negative_nan <- all(processedArrestData$age_sex_race_prop >= 0 & 
                           !is.nan(processedArrestData$age_sex_race_prop))

# Printing test result
print(paste("Negative or NaN values test passed:", test_negative_nan))



