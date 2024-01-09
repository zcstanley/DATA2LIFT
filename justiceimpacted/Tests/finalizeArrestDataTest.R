# -----------------------------------------------------------------------------
# Informal Tests for Distributed Arrests Data
# Author: Zofia C. Stanley
# Date: Dec 22, 2023
#
# Description:
# This script performs tests on the distributed arrest data to ensure data integrity.
# -----------------------------------------------------------------------------

# --------------------
# Load Processed Data
# --------------------
# Load the distributed arrest data
load("justiceimpacted/ProcessedData/arrestDataByPUMA.Rdata")

# Load the processed arrest data
load("justiceimpacted/ProcessedData/processedArrestData.Rdata")

# --------------------
# Test 1: Total Distributed Arrests Match Total Counts by State
# --------------------
# Calculate the total number of distributed arrests by state
total_distributed_arrests_by_state <- arrestData %>%
  st_drop_geometry() %>%
  group_by(state) %>%
  summarise(total_distributed = sum(count))

# Calculate the total counts from processedArrestData
total_counts_by_state <- processedArrestData %>%
  ungroup() %>%
  select(state, total_count_state) %>%
  unique() 

# Join and compare the totals
comparison <- inner_join(total_distributed_arrests_by_state, total_counts_by_state, by = "state")
comparison %>%
  mutate(test_passed = abs(total_distributed - total_count_state) < 1e-6)


# Print the comparison and check for any test failures
#print(comparison)
all_tests_passed <- all(comparison$test_passed == TRUE)

# Using if statement to provide appropriate feedback
if (all_tests_passed) {
  print("Distributed arrests match total arrest counts for all states.")
} else {
  warning("Distributed arrests DO NOT match total arrest counts for some states.") 
  print(comparison, n=51)
}

# --------------------
# Test 2: No Negative or NaN Values in Distributed Arrests
# --------------------
# Check for negative or NaN values in arrestData
test_negative_nan <- all(arrestData$count >= 0 & !is.nan(arrestData$count))

if (test_negative_nan) {
  print("Negative or NaN values test passed.")
} else {
  warning("Negative or NaN values test failed.")
}

# --------------------
# Test 3: Data Types and Structure Validation
# --------------------
# Defining expected column names
expected_cols <- c("state", "PUMA", "count", "arrest_per_pop", "arrest_density", "geometry")

# Checking if all expected columns are present
test_cols <- all(expected_cols %in% names(arrestData))

# Checking if specific columns are of numeric type
test_types <- is.numeric(arrestData$count) && 
  is.numeric(arrestData$arrest_per_pop) && 
  is.numeric(arrestData$arrest_density)

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

