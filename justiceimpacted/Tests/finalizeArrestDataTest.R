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
load("justiceimpacted/ProcessedData/arrestDistributedData.Rdata")

# Load the processed arrest data
load("justiceimpacted/ProcessedData/processedArrestData.Rdata")

# --------------------
# Test 1: Total Distributed Arrests Match Total Counts by State
# --------------------
# Calculate the total number of distributed arrests by state
total_distributed_arrests_by_state <- arrestData %>%
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
print(comparison)
all_tests_passed <- all(comparison$test_passed == TRUE)
print(paste("All state tests passed:", all_tests_passed))

# --------------------
# Test 2: No Negative or NaN Values in Distributed Arrests
# --------------------
# Check for negative or NaN values in arrestData
test_negative_nan <- all(arrestData$count >= 0 & !is.nan(arrestData$count))
print(paste("Negative or NaN values test passed:", test_negative_nan))
