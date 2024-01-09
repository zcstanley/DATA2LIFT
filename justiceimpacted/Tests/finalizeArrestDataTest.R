# -----------------------------------------------------------------------------
# Informal Tests for Distributed Arrests Data
# Author: Zofia C. Stanley
# Date: Jan 9, 2024
#
# Description:
# This script performs tests on the distributed arrest data to ensure data integrity:
#   1. Matching of total distributed arrests with total counts by state.
#   2. Verification of no negative or NaN values in distributed arrests.
#   3. Data types and structure validation.
# -----------------------------------------------------------------------------

# --------------------
# Load Processed Data
# --------------------
load("justiceimpacted/ProcessedData/arrestDataByPUMA.Rdata")
load("justiceimpacted/ProcessedData/processedArrestData.Rdata")

# --------------------
# Test 1: Total Distributed Arrests Match Total Counts by State
# --------------------
test_total_distributed_arrests <- function() {
  total_distributed_arrests_by_state <- arrestData %>%
    st_drop_geometry() %>%
    group_by(state) %>%
    summarise(total_distributed = sum(count))
  
  total_counts_by_state <- processedArrestData %>%
    ungroup() %>%
    select(state, total_count_state) %>%
    unique() 
  
  comparison <- inner_join(total_distributed_arrests_by_state, total_counts_by_state, by = "state") %>%
    mutate(test_passed = abs(total_distributed - total_count_state) < 1e-6)
  
  if (all(comparison$test_passed == TRUE)) {
    print("Distributed arrests match total arrest counts for all states.")
  } else {
    warning("Distributed arrests DO NOT match total arrest counts for some states.") 
    print(comparison, n=51)
  }
}

# --------------------
# Test 2: No Negative or NaN Values in Distributed Arrests
# --------------------
test_negative_nan_values <- function() {
  if (!all(arrestData$count >= 0 & !is.nan(arrestData$count))) {
    warning("Negative or NaN values test failed.")
  } else {
    print("Negative or NaN values test passed.")
  }
}


# --------------------
# Test 3: Data Types and Structure Validation
# --------------------
test_data_types_structure <- function() {
  expected_cols <- c("state", "PUMA", "count", "arrest_per_pop", "arrest_density", "geometry")
  if (!all(expected_cols %in% names(arrestData))) {
    warning("Column names test failed.")
  } else if (!is.numeric(arrestData$count) || 
              !is.numeric(arrestData$arrest_per_pop) || 
              !is.numeric(arrestData$arrest_density)) {
    warning("Data types test failed.")
  } else {
    print("Data types and structure test passed.")
  }
}

# --------------------
# Execute the tests
# --------------------
test_total_distributed_arrests()
test_negative_nan_values()
test_data_types_structure()
