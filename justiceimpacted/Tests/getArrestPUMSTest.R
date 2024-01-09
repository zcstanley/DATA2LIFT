# -----------------------------------------------------------------------------
# Informal Tests to assesses the integrity of the PUMS data integration process.
# Author: Zofia C. Stanley
# Date: Jan 9, 2024
#
# Description:
# This script performs several informal tests on the pumsData.Rdata:
#   1. Data type and structure validation.
#   2. Checks for negative or NaN values in counts.
#   3. Verification of correct race category renaming.
# -----------------------------------------------------------------------------

# Load the processed data
load("justiceimpacted/ProcessedData/pumsData.RData")


# --------------------
# Test 1: Data Types and Structure Validation
# --------------------
test_data_types_structure <- function() {
  expected_cols <- c("state", "PUMA", "age", "sex", "race", "count")
  
  # Checking if all expected columns are present
  if (!all(expected_cols %in% names(pumsData))) {
    warning("Column names test failed.")
  } else {
    print("Column names test passed.")
  }
  
  # Checking if specific columns are of numeric type
  if (!is.numeric(pumsData$count)) {
    warning("Data types test failed.")
  } else {
    print("Data types test passed.")
  }
}

# --------------------
# Test 2: Negative or NaN Values Check in Count
# --------------------
test_negative_nan_values <- function() {
  # Checking for negative or NaN values in count
  if (!all(pumsData$count >= 0 & !is.nan(pumsData$count))) {
    warning("Negative or NaN values test failed.")
  } else {
    print("Negative or NaN values test passed.")
  }
}

# --------------------
# Test 3: Race Category Renaming
# --------------------
test_race_renaming <- function() {
  expected_races <- c("white", "Black", "Indigenous", "Asian", "Pacific", "Other")
  if (all(pumsData$race %in% expected_races)) {
    print("Race renaming successful.")
  } else {
    warning("Race renaming failed.")
  }
}

# --------------------
# Execute the tests
# --------------------
test_data_types_structure()
test_negative_nan_values()
test_race_renaming()
