# -----------------------------------------------------------------------------
# Test Suite for pumsData Validation
# Author: Zofia C. Stanley
# Date: Feb 6, 2024
#
# Description:
#   This test suite validates the integrity of the pumsData dataset used in the
#   distribution of incarcerated parents to PUMAs based on age, sex, and race proportions.
#   It ensures correct column names and types, appropriate age ranges, sex and race
#   values, and checks for negative or NaN values in the 'count' column.
# -----------------------------------------------------------------------------

# --------------------------------------------------
# Test data: pumsData
# --------------------------------------------------
# Load the data
load("incarceratedparent/ProcessedData/pumsData.Rdata") 

# 1. Test for Correct Column Names
test_that("pumsData has correct column names and types", {
  expected_col_names <- c("state", "PUMA", "age", "sex", "race", "count")
  expect_equal(names(pumsData), expected_col_names)
  expect_true(is.numeric(pumsData$count))
})

# 2. Test for Age Range
test_that("pumsData has age >= 18", {
  expect_true(all(pumsData$age >= 18))
})

# 3. Test for Sex Values
test_that("pumsData has correct sex values", {
  expect_true(all(pumsData$sex %in% c("female", "male")))
})

# 4. Test for Race Values
test_that("pumsData has correct race values", {
  expected_races <- c("Multi", "white", "Other", "Indigenous", "Black", "AsianPacific", "Hispanic")
  expect_true(all(pumsData$race %in% expected_races))
})

# 5. Test for NA and negative values
test_that("pumsData has no negative or NaN values in 'count'", {
  # Check that all 'count' values are non-negative and not NaN
  expect_true(all(pumsData$count >= 0 & !is.nan(pumsData$count)), 
              info = "There are negative or NaN values in the 'count' column.")
})

# Remove data from environment
rm(pumsData)


