# -----------------------------------------------------------------------------
# Informal Tests for Justice Impacted Code
# Author: Zofia C. Stanley
# Date: Jan 8, 2024
#
# Description:
# This script performs several informal tests on the pumsData.Rdata
# -----------------------------------------------------------------------------

# Load the processed data
load("justiceimpacted/ProcessedData/pumsData.RData")


# --------------------
# Test 1: Data Types and Structure Validation
# --------------------
# Defining expected column names
expected_cols <- c("state", "PUMA", "age", "sex", "race", "count")

# Checking if all expected columns are present
test_cols <- all(expected_cols %in% names(pumsData))

# Checking if specific columns are of numeric type
test_types <- is.numeric(pumsData$count)

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
# Test 2: Negative or NaN Values Check in Count
# --------------------
# Checking for negative or NaN values in count
test_negative_nan <- all(pumsData$count >= 0 & 
                           !is.nan(pumsData$count))

# Using if statement to provide appropriate feedback
if (test_negative_nan) {
  print("Negative or NaN values test passed.")
} else {
  warning("Negative or NaN values test failed.")
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

# Execute the test
test_race_renaming()
