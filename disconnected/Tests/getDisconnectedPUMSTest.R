# -----------------------------------------------------------------------------
# Informal Tests to assesses the integrity of the PUMS data integration process.
# Author: Zofia C. Stanley
# Date: Jan 9, 2024
#
# Description:
# This script performs several informal tests on disconnectedDataByPUMA.Rdata:
#   1. Data type and structure validation.
#   2. Checks for negative or NaN values in counts.
#   3. Verification of disconnected count. 
# -----------------------------------------------------------------------------

# Load libraries
library(dplyr)

# Load the processed data
load("disconnected/ProcessedData/disconnectedDataByPUMA.RData")
load("RawData/PUMSRawData.Rdata") 


# --------------------
# Test 1: Data Types and Structure Validation
# --------------------
test_data_types_structure <- function() {
  expected_cols <- c("state", "PUMA", "count", "disconnected_per_pop", "disconnected_density", "geometry")
  
  # Checking if all expected columns are present
  if (!all(expected_cols %in% names(disconnectedData))) {
    warning("Column names test failed.")
  } else {
    print("Column names test passed.")
  }
  
  # Checking if specific columns are of numeric type
  if (!is.numeric(disconnectedData$count)) {
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
  if (!all(disconnectedData$count >= 0 & !is.nan(disconnectedData$count))) {
    warning("Negative or NaN values test failed.")
  } else {
    print("Negative or NaN values test passed.")
  }
}

# --------------------
# Test 3: Data Filtering and Counting Accuracy
# --------------------
test_data_filtering_and_counting <- function() {
  disconnected_test <- rawPumsData %>%
    filter(AGEP >= 16 & AGEP <= 24 & SCH == 1 & ESR %in% c(3, 6)) %>%
    summarise(test_count = sum(PWGTP))
  
  if (disconnected_test$test_count == sum(disconnectedData$count)) {
    print("Data filtering and counting test passed.")
  } else {
    warning("Data filtering and counting test failed.")
  }
}


# --------------------
# Execute the tests
# --------------------
test_data_types_structure()
test_negative_nan_values()
test_data_filtering_and_counting()

