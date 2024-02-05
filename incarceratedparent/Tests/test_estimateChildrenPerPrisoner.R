# Load libraries 
library(testthat)
library(reshape2)
library(dplyr)
library(tidyr)

# Indicate that we are in testing mode
testing <- TRUE

# Source script
source("incarceratedparent/Scripts/estimateChildrenPerPrisoner.R", local=TRUE)

# Define the context for the tests
context("Tests for compute_children_per_prisoner function")

# -----------------------------------------------------------------------------
# Step 1: Compute the number of children aged 15-17 who have a parent incarcerated in a state prison by sex of the parent.
# -----------------------------------------------------------------------------
# Mock data
childrenByParentSex <- data.frame(
  jurisdiction = c("state", "state", "federal"),
  sex = c("male", "female", "male"),
  count_children = c("1,000,000", "100,000", "200,000"),
  percent = c(45.0, 55.0, 50.0)
) 
childAge <- data.frame(
  jurisdiction = c("state", "state", "state", "federal"),
  sex = c("male", "female", "female", "female"), 
  child_age = c("15-17", "10-14", "15-17", "Younger than 1"),
  percent = c(15, 30, 20, 1)
)

# 1.1. Correctness of Output
test_that("compute_older_children_by_parent_sex computes older children by parent sex correctly", {
  result <- compute_older_children_by_parent_sex(childrenByParentSex, childAge)
  expected_result <- data.frame(sex = c("female", "male"), children_15_17 = c(20000, 150000))
  expect_true(all.equal(result, expected_result, ignore_row_order = TRUE, ignore_col_order = TRUE), 
              info = "The data frames are not identical. Check row order.")
})

# 1.2. Data Types
test_that("compute_older_children_by_parent_sex handles correct data types", {
  result <- compute_older_children_by_parent_sex(childrenByParentSex, childAge)
  expect_is(result, "data.frame")
  expect_true(all(c("sex", "children_15_17") %in% names(result)))
  expect_is(result$children_15_17, "numeric")
})

# 1.3. Filtering Logic
test_that("compute_older_children_by_parent_sex filters data by jurisdiction and child age correctly", {
  result <- compute_older_children_by_parent_sex(childrenByParentSex, childAge)
  expect_equal(nrow(result), 2) # Expecting rows for male and female in 'state' jurisdiction
  expect_true(all(result$sex %in% c("male", "female")))
})

# -----------------------------------------------------------------------------
# Step 2: Compute the number of incarcerated parents in state prisons by sex and race.
# -----------------------------------------------------------------------------

# Mock data
incarceratedParentPercent <- data.frame(
  jurisdiction = c("state", "state", "federal"),
  race = c("Multi", "Multi", "Indigenous"),
  sex = c("male", "female", "male"),
  percent = c(50, 40, 30)
)
numPrisoners16 <- data.frame(
  jurisdiction = c("state", "state", "federal"),
  race = c("Multi", "Multi", "Indigenous"),
  sex = c("male", "female", "male"),
  count = c("100,000", "10,000", "2,000")
)

# 2.1. Correctness of Output
test_that("compute_incarcerated_parent_count computes incarcerated parent count correctly", {
  result <- compute_incarcerated_parent_count(incarceratedParentPercent, numPrisoners16)
  expected_result <- data.frame(
    race = c("Multi", "Multi"),
    sex = c("female", "male"),
    num_incarcerated_parents = c(4000, 50000)  # 40% of 100,000 and 50% of 10,000
  )
  expect_true(all.equal(result, expected_result, ignore_row_order = TRUE, ignore_col_order = TRUE), 
              info = "The data frames are not identical. Check row order.")
})

# 2.2. Column Existence and Types
test_that("compute_incarcerated_parent_count handles correct data types", {
  result <- compute_incarcerated_parent_count(incarceratedParentPercent, numPrisoners16)
  expect_is(result, "data.frame")
  expect_true(all(c("race", "sex", "num_incarcerated_parents") %in% names(result)))
  expect_is(result$num_incarcerated_parents, "numeric")
})


# 2.3. Merging Logic
test_that("compute_incarcerated_parent_count merge operation works correctly", {
  result <- compute_incarcerated_parent_count(incarceratedParentPercent, numPrisoners16)
  expect_equal(nrow(result), 2)  # Expecting only 2 rows as there are only 2 matching 'state' jurisdictions
  expect_true(all(result$sex %in% c("male", "female")))
})

# -----------------------------------------------------------------------------
# Step 3: Compute the number of children aged 15-17 with an incarcerated parent by sex and race of the parent.
# -----------------------------------------------------------------------------
# Mock data
incarceratedParentCount <- data.frame(
  race = c("Multi", "Multi", "AsianPacific", "AsianPacific"),
  sex = c("male", "female", "male", "female"),
  num_incarcerated_parents = c(60000, 7000, 40000, 3000)
)
olderChildrenByParentSex <- data.frame(
  sex = c("male", "female"),
  children_15_17 = c(20000, 1000)
)

# 3.1. Correctness of Output
test_that("compute_children_by_parent_sex_race computes children by parent sex and race correctly", {
  result <- compute_children_by_parent_sex_race(incarceratedParentCount, olderChildrenByParentSex)
  expected_result <- data.frame(
    race = c("Multi", "AsianPacific", "Multi", "AsianPacific"),
    sex = c("female", "female", "male", "male"),
    children_15_17_by_race_sex = c(700, 300, 12000, 8000)  # e.g. Multi/female = 1000 * (7000)/(7000 + 3000)
  )
  expect_true(all.equal(result, expected_result, ignore_row_order = TRUE, ignore_col_order = TRUE), 
              info = "The data frames are not identical. Check row order.")
})

# 3.2. Column Existence and Types
test_that("compute_children_by_parent_sex_race final data structure is correct", {
  result <- compute_children_by_parent_sex_race(incarceratedParentCount, olderChildrenByParentSex)
  expect_is(result, "data.frame")
  expect_true(all(c("race", "sex", "children_15_17_by_race_sex") %in% names(result)))
  expect_is(result$children_15_17_by_race_sex, "numeric")
})

# 3.3. Data Merging
test_that("compute_children_by_parent_sex_race merge operations work correctly", {
  result <- compute_children_by_parent_sex_race(incarceratedParentCount, olderChildrenByParentSex)
  expect_equal(nrow(result), nrow(incarceratedParentCount))  # Number of rows should match the input
  expect_true(all(result$sex %in% olderChildrenByParentSex$sex))  # Sex should match between data frames
})

# 3.4. Proportion Calculation
test_that("compute_children_by_parent_sex_race proportion calculation is correct", {
  result <- compute_children_by_parent_sex_race(incarceratedParentCount, olderChildrenByParentSex)
  # Check if proportions are calculated correctly (this is a sample check, adjust the logic as needed)
  expect_equal(result$children_15_17_by_race_sex[1], 1000 * 7000/(7000 + 3000))
  expect_equal(result$children_15_17_by_race_sex[2], 1000 * 3000/(7000 + 3000))
})

# -----------------------------------------------------------------------------
# Step 4: Compute number of children aged 15-17 per state prisoner by sex and race.
# -----------------------------------------------------------------------------
# Mock data
olderChildrenByParentSexRace <- data.frame(
  race = c("Multi", "Multi", "AsianPacific", "AsianPacific"),
  sex = c("male", "female", "male", "female"),
  children_15_17_by_race_sex = c(12000, 700, 8000, 300)
)
numPrisoners16 <- data.frame(
  jurisdiction = c("state", "state", "state", "state"),
  race = c("Multi", "Multi", "AsianPacific", "AsianPacific"),
  sex = c("male", "female", "male", "female"),
  count = c("120,000", "3,500", "64,000", "3,000")
)

# 4.1. Correctness of Output
test_that("compute_children_per_prisoner computes children per prisoner correctly", {
  result <- compute_children_per_prisoner(olderChildrenByParentSexRace, numPrisoners16)
  expected_result <- data.frame(
    race = c("AsianPacific", "AsianPacific", "Multi", "Multi"),
    sex = c("female", "male", "female", "male"),
    children_per_prisoner = c(0.1, 0.125, 0.2, 0.1)  
  )
  expect_true(all.equal(result, expected_result, ignore_row_order = TRUE, ignore_col_order = TRUE), 
              info = "The data frames are not identical. Check row order.")
})

# 4.2. Data Structure and Types
test_that("compute_children_per_prisoner final data structure is correct", {
  result <- compute_children_per_prisoner(olderChildrenByParentSexRace, numPrisoners16)
  expect_is(result, "data.frame")
  expect_true(all(c("race", "sex", "children_per_prisoner") %in% names(result)))
  expect_is(result$children_per_prisoner, "numeric")
})

# 4.3. Data Merging
test_that("compute_children_per_prisoner merge operations work correctly", {
  result <- compute_children_per_prisoner(olderChildrenByParentSexRace, numPrisoners16)
  expect_equal(nrow(result), nrow(olderChildrenByParentSexRace))  # Number of rows should match the input
  expect_true(all(result$race %in% numPrisoners16$race))  # Races should match between data frames
})

# --------------------------------------------------
# Test data inputs: incarceratedParentPercent
# --------------------------------------------------

# Load the data
load("incarceratedparent/RawData/incarceratedParentPercentData.Rdata")

# 1.1. Check for Required Columns
test_that("incarceratedParentPercent has the correct columns", {
  expect_true(all(c("jurisdiction", "race", "sex", "percent") %in% names(incarceratedParentPercent)))
})

# 1.2. Check Jurisdictions
test_that("Jurisdictions are as expected", {
  expect_true(all(incarceratedParentPercent$jursidiction %in% c("state", "federal")))
})

# 1.3. Check Race Categories
test_that("Race categories are as expected", {
  expected_races <- c("Indigenous", "AsianPacific", "Black", "Hispanic", "Multi", "white")
  expect_true(all(incarceratedParentPercent$race %in% expected_races))
})

# 1.4. Check for NA values
test_that("There are no NA values", {
  expect_true(!any(is.na(incarceratedParentPercent)))
  expect_true(!any(incarceratedParentPercent$percent == "NA"))
})

# 1.5. Check for out of bounds values
test_that("Percents are between 0 and 100", {
  expect_true(all( as.numeric(incarceratedParentPercent$percent) >=0 & as.numeric(incarceratedParentPercent$percent)<=100 ))
})

rm(incarceratedParentPercent)

# --------------------------------------------------
# Test data inputs: childrenByParentSex
# --------------------------------------------------

# Load the data
load("incarceratedparent/RawData/childrenByParentSexData.Rdata")

# 2.1. Check for Required Columns
test_that("childrenByParentSex has the correct columns", {
  expect_true(all(c("jurisdiction", "sex", "percent", "count_children") %in% names(childrenByParentSex)))
})

# 2.2. Check Jurisdictions
test_that("Jurisdictions are as expected", {
  expect_true(all(childrenByParentSex$jursidiction %in% c("state", "federal")))
})

# 2.3. Check for NA values
test_that("There are no NA values", {
  expect_true(!any(is.na(childrenByParentSex)))
  expect_true(!any(childrenByParentSex$percent == "NA"))
  expect_true(!any(childrenByParentSex$children_count == "NA"))
})

# 2.4. Check for out of bounds values
test_that("Percents are between 0 and 100", {
  expect_true(all( as.numeric(childrenByParentSex$percent) >=0 & as.numeric(childrenByParentSex$percent)<=100 ))
})

rm(childrenByParentSex)

# --------------------------------------------------
# Test data inputs: childAge
# --------------------------------------------------

# Load the data
load("incarceratedparent/RawData/childAgeData.Rdata")

# 3.1. Check for Required Columns
test_that("childAge has the correct columns", {
  expect_true(all(c("jurisdiction", "child_age", "sex", "percent") %in% names(childAge)))
})

# 3.2. Check Jurisdictions
test_that("Jurisdictions are as expected", {
  expect_true(all(childAge$jursidiction %in% c("state", "federal")))
})

# 3.4. Check Sex Categories
test_that("Sex categories are as expected", {
  expect_true(all(childAge$sex %in% c("female", "male")))
})

# 3.5. Check for NA values
test_that("There are no NA values", {
  expect_true(!any(is.na(childAge)))
  expect_true(!any(childAge$percent == "NA"))
})

# 3.6. Check for out of bounds values
test_that("Percents are between 0 and 100", {
  expect_true(all( as.numeric(childAge$percent) >=0 & as.numeric(childAge$percent)<=100 ))
})

rm(childAge)

# --------------------------------------------------
# Test data inputs: numPrisoners16
# --------------------------------------------------

# Load the data
load("incarceratedparent/RawData/numPrisoners2016Data.Rdata")

# 4.1. Check for Required Columns
test_that("numPrisoners16 has the correct columns", {
  expect_true(all(c("jurisdiction", "race", "sex", "count") %in% names(numPrisoners16)))
})

# 4.2. Check Jurisdictions
test_that("Jurisdictions are as expected", {
  expect_true(all(numPrisoners16$jursidiction %in% c("state", "federal")))
})

# 4.3. Check Sex Categories
test_that("Sex categories are as expected", {
  expect_true(all(numPrisoners16$sex %in% c("female", "male")))
})

# 4.4. Check Race Categories
test_that("Race categories are as expected", {
  expected_races <- c("Indigenous", "AsianPacific", "Black", "Hispanic", "Multi", "white")
  expect_true(all(numPrisoners16$race %in% expected_races))
})

# 4.5. Check for NA values
test_that("There are no NA values", {
  expect_true(!any(is.na(numPrisoners16)))
  expect_true(!any(numPrisoners16$count == "NA"))
})

rm(numPrisoners16)



