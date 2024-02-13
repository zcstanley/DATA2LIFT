# -----------------------------------------------------------------------------
# Test Suite for SPI Data Validation
# Author: Zofia C. Stanley
# Date: Feb 6, 2024
#
# Description:
#   This test suite validates the integrity of the data tables processed from the
#   BJS report "Parents in Prison and Their Minor Children: Survey of Prison Inmates, 2016" 
#   into a long format. 
# -----------------------------------------------------------------------------

# Load necessary libraries
library(testthat)
library(reshape2)
library(dplyr)
library(tidyr)

# --------------------------------------------------
# Test data output: incarceratedParentPercent
# --------------------------------------------------
# Load the data
load("incarceratedparent/RawData/incarceratedParentPercentData.Rdata")

# 1.1. Check for Required Columns
test_that("incarceratedParentPercent has the correct columns", {
  expect_true(all(c("jurisdiction", "race", "sex", "percent") %in% names(incarceratedParentPercent)))
  expect_true(is.numeric(incarceratedParentPercent$percent))
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
  expect_true(all( incarceratedParentPercent$percent >=0 & incarceratedParentPercent$percent <=100 ))
})

rm(incarceratedParentPercent)

# --------------------------------------------------
# Test data output: childrenByParentSex
# --------------------------------------------------
# Load the data
load("incarceratedparent/RawData/childrenByParentSexData.Rdata")

# 2.1. Check for Required Columns
test_that("childrenByParentSex has the correct columns", {
  expect_true(all(c("jurisdiction", "sex", "percent", "count_children") %in% names(childrenByParentSex)))
  expect_true(is.character(childrenByParentSex$count_children))
  expect_true(is.numeric(childrenByParentSex$percent))
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
  expect_true(all( childrenByParentSex$percent >=0 & childrenByParentSex$percent<=100 ))
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
  expect_true(is.character(childAge$percent))
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
  expect_true(is.character(numPrisoners16$count))
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