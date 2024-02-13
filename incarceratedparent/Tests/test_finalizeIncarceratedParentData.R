# -----------------------------------------------------------------------------
# Unit Tests for Distributing Incarcerated Parents to PUMAs
# Author: Zofia C. Stanley
# Date: Feb 6, 2024
#
# Description:
# This test script ensures the integrity and correctness of the functions used in 
# the process of distributing incarcerated parents to PUMAs (Public Use Microdata Areas). 
# The tests validate data structures, calculations, and spatial data integrity, 
# covering aspects like age, sex, race proportions, and geospatial data consistency.
# -----------------------------------------------------------------------------

# Load libraries
library(testthat)
library(tidyverse)
library(tidycensus)    
library(sf)            

# Indicate that we are in testing mode
testing <- TRUE

# Source script
source("incarceratedparent/Scripts/finalizeIncarceratedParentData.R", local=TRUE)

# -----------------------------------------
# Test calculate_pums_prop_data 
# -----------------------------------------

# Sample data for testing
sample_pumsData <- data.frame(
  state = c("State1", "State1", "State1", "State2"),
  PUMA = c(100, 100, 200, 100),
  age = c(25, 34, 25, 25),
  sex = c("male", "female", "male", "male"),
  race = c("Race1", "Race2", "Race1", "Race1"),
  count = c(100, 200, 300, 100)
)

# 1.1. Test for Correct Age Grouping
test_that("calculate_pums_prop_data assigns correct age groups", {
  result <- calculate_pums_prop_data(sample_pumsData)
  # Check if 25-year-olds are correctly mapped to "25-29" and 34-year-olds to "30-34"
  expect_true(all(result$age[sample_pumsData$age == 25] == "25-29"))
  expect_true(all(result$age[sample_pumsData$age == 34] == "30-34"))
})

# 1.2. Test for Correct Proportion Calculation
test_that("calculate_pums_prop_data calculates proportions correctly", {
  result <- calculate_pums_prop_data(sample_pumsData)
  result <- as.data.frame(result) %>% mutate(age = as.character(age))
  expected_result <- data.frame(
    state = c("State1", "State1", "State1", "State2"),
    PUMA = c(100, 100, 200, 100),
    age = c("25-29", "30-34", "25-29", "25-29"),
    sex = c("male", "female", "male", "male"),
    race = c("Race1", "Race2", "Race1", "Race1"),
    puma_prop = c(.25, 1, .75, 1)
  )
  expect_equal(result, expected_result)
})

# 1.3. Test for Data Structure and Column Types
test_that("calculate_pums_prop_data returns correct data structure", {
  result <- calculate_pums_prop_data(sample_pumsData)
  expect_is(result, "data.frame")
  expect_true(all(c("state", "PUMA", "age", "sex", "race", "puma_prop") %in% names(result)))
  expect_is(result$puma_prop, "numeric")
})

# -----------------------------------------
# Test distribute_prisoners_to_pumas
# -----------------------------------------
# Sample data for testing
sample_prisonersByStateAgeSexRace <- data.frame(
  state = c("New York", "California", "Texas"),
  age = c("25-29", "30-34", "25-29"),
  sex = c("male", "female", "male"),
  race = c("Race1", "Race2", "Race1"),
  count = c(200, 300, 400)
)
sample_pumsPropData <- data.frame(
  state = c("NY", "CA", "TX"),
  PUMA = c(100, 300, 400),
  age = c("25-29", "30-34", "25-29"),
  sex = c("male", "female", "male"),
  race = c("Race1", "Race2", "Race1"),
  puma_prop = c(0.5, 0.3, 0.4)
)

# 2.1. Test for Correct State Abbreviation Conversion
test_that("distribute_prisoners_to_pumas converts state names correctly", {
  result <- distribute_prisoners_to_pumas(sample_prisonersByStateAgeSexRace, sample_pumsPropData)
  expect_true(all(result$state %in% state.abb))  # Check if all state names are in abbreviation form
})

# 2.2. Test for Correct Calculation
test_that("distribute_prisoners_to_pumas calculates distributed prisoners correctly", {
  result <- distribute_prisoners_to_pumas(sample_prisonersByStateAgeSexRace, sample_pumaPropData)
  expected_prisoners <- sample_prisonersByStateAgeSexRace$count * sample_pumaPropData$puma_prop
  expect_equal(result$prisoners, expected_prisoners)
})

# 2.3. Test for Data Structure and Column Types
test_that("distribute_prisoners_to_pumas returns correct data structure", {
  result <- distribute_prisoners_to_pumas(sample_prisonersByStateAgeSexRace, sample_pumaPropData)
  expect_is(result, "data.frame")
  expect_true(all(c("state", "PUMA", "age", "sex", "race", "prisoners") %in% names(result)))
  expect_is(result$prisoners, "numeric")
})

# -----------------------------------------
# Test distribute_missing_to_pumas
# -----------------------------------------
# Sample data for testing
sample_prisonersByStateAgeSexRace <- data.frame(
  state = c("New York", "New York"),
  age = c("25-29", "30-34"),
  sex = c("male", "female"),
  race = c("Race1", "Race2"),
  count = c(200, 300)
)
sample_pumsPropData <- data.frame(
  state = c("NY", "NY"),
  PUMA = c(100, 200),
  age = c("25-29", "25-29"),
  sex = c("male", "male"),
  race = c("Race1", "Race1"),
  puma_prop = c(0.6, 0.4)
)
sample_distributedPrisonerData <- data.frame(
  state = c("NY", "NY"),
  PUMA = c(100, 200),
  age = c("25-29", "25-29"),
  sex = c("male", "male"),
  race = c("Race1", "Race1"),
  prisoners = c(120, 80)
)

# 3.1. Test for Maintaining Total Prisoner Count
test_that("distribute_missing_to_pumas maintains total prisoner count", {
  result <- distribute_missing_to_pumas(sample_pumsPropData, sample_prisonersByStateAgeSexRace, sample_distributedPrisonerData)
  total_count_before <- sum(sample_prisonersByStateAgeSexRace$count)
  total_count_after <- sum(result$count)
  expect_equal(total_count_before, total_count_after)
})

# 3.2. Test for Data Structure and Column Types
test_that("distribute_missing_to_pumas returns correct data structure", {
  result <- distribute_missing_to_pumas(sample_pumaPropData, sample_prisonersByStateAgeSexRace, sample_distributedPrisonerData)
  expect_is(result, "data.frame")
  expect_true(all(c("state", "PUMA", "sex", "race", "count") %in% names(result)))
  expect_is(result$count, "numeric")
})

# -----------------------------------------
# Test add_other_race_category
# -----------------------------------------
# Sample data for testing
sample_olderChildrenPerPrisoner <- data.frame(
  sex = c("male", "female", "male"),
  race = c("Race1", "Race2", "Race1"),
  children_per_prisoner = c(2, 3, 4)
)

# 4.1. Test for 'Other' Category Inclusion
test_that("add_other_race_category includes 'Other' category", {
  result <- add_other_race_category(sample_olderChildrenPerPrisoner)
  expect_true(any(result$race == "Other" & result$sex == "female"))
  expect_true(any(result$race == "Other" & result$sex == "male"))
})

# 4.2. Test for Correct Mean Calculation
test_that("add_other_race_category calculates correct mean for 'Other'", {
  result <- add_other_race_category(sample_olderChildrenPerPrisoner)
  expected_mean_male <- mean(sample_olderChildrenPerPrisoner$children_per_prisoner[sample_olderChildrenPerPrisoner$sex == "male"])
  expected_mean_female <- mean(sample_olderChildrenPerPrisoner$children_per_prisoner[sample_olderChildrenPerPrisoner$sex == "female"])
  expect_equal(result$children_per_prisoner[result$race == "Other" & result$sex == "male"], expected_mean_male)
  expect_equal(result$children_per_prisoner[result$race == "Other" & result$sex == "female"], expected_mean_female)
})

# 4.3. Test for Data Structure and Column Types
test_that("add_other_race_category returns correct data structure", {
  result <- add_other_race_category(sample_olderChildrenPerPrisoner)
  expect_is(result, "data.frame")
  expect_true(all(c("sex", "race", "children_per_prisoner") %in% names(result)))
  expect_is(result$children_per_prisoner, "numeric")
})

# 4.4. Test for Preservation of Original Data
test_that("add_other_race_category preserves original data", {
  result <- add_other_race_category(sample_olderChildrenPerPrisoner)
  expect_true(all(sample_olderChildrenPerPrisoner$sex %in% result$sex))
  expect_true(all(sample_olderChildrenPerPrisoner$race %in% result$race))
})

# -----------------------------------------
# Test calculate_children_with_incarcerated_parent
# -----------------------------------------
# Sample data for testing
sample_prisonerData <- data.frame(
  state = c("NY", "NY", "TX"),
  PUMA = c(100, 100, 200),
  sex = c("male", "female", "male"),
  race = c("Race1", "Race2", "Race1"),
  count = c(200, 300, 150)
)

sample_olderChildrenPerPrisoner <- data.frame(
  sex = c("male", "female", "male"),
  race = c("Race1", "Race2", "Race2"),
  children_per_prisoner = c(2, 3, 4)
)

# 5.1. Test for Correct Calculation
test_that("calculate_children_with_incarcerated_parent calculates correctly", {
  result <- calculate_children_with_incarcerated_parent(sample_prisonerData, sample_olderChildrenPerPrisoner)
  result <- as.data.frame(result)
  expected_result <- data.frame(
    state = c("NY", "TX"),
    PUMA = c(100,  200),
    count = c(200 * 2 + 300 * 3, 150 * 2)  # Calculated as prisoner count * children_per_prisoner
  )
  expect_equal(result, expected_result)
})

# 5.2. Test for Data Structure and Column Types
test_that("calculate_children_with_incarcerated_parent returns correct data structure", {
  result <- calculate_children_with_incarcerated_parent(sample_prisonerData, sample_olderChildrenPerPrisoner)
  expect_is(result, "data.frame")
  expect_true(all(c("state", "PUMA", "count") %in% names(result)))
  expect_is(result$count, "numeric")
})

# -----------------------------------------
# Test calculate_puma_pop
# -----------------------------------------
# Sample data for testing
sample_rawPumsData <- data.frame(
  ST = c("01", "01", "02"),
  PUMA = c(100, 100, 200),
  AGEP = c(15, 18, 17),
  PWGTP = c(100, 200, 150)
)

sample_fips_codes <- data.frame(
  state = c("State1", "State1", "State2"),
  state_code = c("01", "01", "02")
)

# Mock the fips_codes dataset
fips_codes <- sample_fips_codes

# 6.1. Test for Correct Population Calculation
test_that("calculate_puma_pop calculates population correctly", {
  result <- calculate_puma_pop(sample_rawPumsData)
  filtered_rawPumsData <- sample_rawPumsData[sample_rawPumsData$AGEP >= 15 & sample_rawPumsData$AGEP <= 17, ]
  expected_pop <- aggregate(PWGTP ~ ST + PUMA, data = filtered_rawPumsData, sum)
  expect_equal(result$total_pop[result$state == "State1" & result$PUMA == 100], expected_pop$PWGTP[expected_pop$ST == "01" & expected_pop$PUMA == 100])
})

# 6.2. Test for Correct Merging with FIPS Codes
test_that("calculate_puma_pop merges with FIPS codes correctly", {
  result <- calculate_puma_pop(sample_rawPumsData)
  # Check if the state names are merged correctly
  expect_true(all(result$state %in% sample_fips_codes$state))
})

# 6.3. Test for Data Structure and Column Types
test_that("calculate_puma_pop returns correct data structure", {
  result <- calculate_puma_pop(sample_rawPumsData)
  expect_is(result, "data.frame")
  expect_true(all(c("state", "PUMA", "total_pop") %in% names(result)))
  expect_is(result$total_pop, "numeric")
})

# 6.4. Test for Non-Negative Values
test_that("calculate_puma_pop returns non-negative values", {
  result <- calculate_puma_pop(sample_rawPumsData)
  expect_true(all(result$total_pop >= 0))
})

rm(fips_codes)

# -----------------------------------------
# Test calculate_incarcerated_parent_per_pop
# -----------------------------------------
# Sample data for testing
sample_childrenIncarceratedParentData <- data.frame(
  state = c("NY", "NY", "TX"),
  PUMA = c(100, 200, 200),
  count = c(200, 300, 150)
)

sample_pumaPopData <- data.frame(
  state = c("NY", "NY", "TX"),
  PUMA = c(100, 200, 200),
  total_pop = c(1000, 2000, 1500)
)

# 7.1. Test for Correct Calculation
test_that("calculate_incarcerated_parent_per_pop calculates correctly", {
  result <- calculate_incarcerated_parent_per_pop(sample_childrenIncarceratedParentData, sample_pumaPopData)
  expected_result <- data.frame(
    state = c("NY", "NY", "TX"),
    PUMA = c(100, 200, 200),
    incarcerated_parent_per_pop = c(200 / (1000 / 1000), 300 / (2000 / 1000), 150 / (1500 / 1000))
  )
  expect_equal(result$incarcerated_parent_per_pop, expected_result$incarcerated_parent_per_pop)
})

# 7.2. Test for Data Structure and Column Types
test_that("calculate_incarcerated_parent_per_pop returns correct data structure", {
  result <- calculate_incarcerated_parent_per_pop(sample_childrenIncarceratedParentData, sample_pumaPopData)
  expect_is(result, "data.frame")
  expect_true(all(c("state", "PUMA", "incarcerated_parent_per_pop") %in% names(result)))
  expect_is(result$incarcerated_parent_per_pop, "numeric")
})

# 7.3. Test for Non-Negative Values
test_that("calculate_incarcerated_parent_per_pop returns non-negative values", {
  result <- calculate_incarcerated_parent_per_pop(sample_childrenIncarceratedParentData, sample_pumaPopData)
  expect_true(all(result$incarcerated_parent_per_pop >= 0))
})

# -----------------------------------------
# Test calculate_incarcerated_parent_density
# -----------------------------------------
# Create sample polygons with unit area
polygon1 <- st_polygon(list(rbind(c(0, 0), c(1, 0), c(1, 1), c(0, 1), c(0, 0))))
polygon2 <- st_polygon(list(rbind(c(2, 2), c(3, 2), c(3, 3), c(2, 3), c(2, 2))))
polygon3 <- st_polygon(list(rbind(c(4, 4), c(5, 4), c(5, 5), c(4, 5), c(4, 4))))

# Create a simple feature collection (sf) object
sample_pumaShapes <- st_sf(state = c("ny", "ny", "tx"), 
                           geometry = st_sfc(polygon1, polygon2, polygon3),
                           crs = 32618) # projected crs so that all squares have unit area

# Sample data for testing
sample_incarceratedParentData <- data.frame(
  state = c("NY", "NY", "TX"),
  PUMA = c(100, 100, 200),
  count = c(200, 300, 150)
)

# 8.1. Test for Correct State Name Conversion
test_that("calculate_incarcerated_parent_density converts state names correctly", {
  result <- calculate_incarcerated_parent_density(sample_pumaShapes, sample_incarceratedParentData)
  expect_true(all(result$state == toupper(result$state)))  # Check if all state names are in uppercase
})

# 8.2. Test for Correct Density Calculation
test_that("calculate_incarcerated_parent_density calculates density correctly", {
  result <- calculate_incarcerated_parent_density(sample_pumaShapes, sample_incarceratedParentData)
  expect_equal(result$count * 1e6, result$incarcerated_parent_density)
})

# 8.3. Test for Data Structure and Column Types
test_that("calculate_incarcerated_parent_density returns correct data structure", {
  result <- calculate_incarcerated_parent_density(sample_pumaShapes, sample_incarceratedParentData)
  expect_is(result, "sf")  # Expect a simple feature (sf) object
  expect_true(all(c("state", "PUMA", "count", "incarcerated_parent_density") %in% names(result)))
  expect_is(result$incarcerated_parent_density, "numeric")
})

# 8.4. Test for Geospatial Data Integrity
test_that("calculate_incarcerated_parent_density maintains spatial data structure", {
  result <- calculate_incarcerated_parent_density(sample_pumaShapes, sample_incarceratedParentData)
  expect_true(inherits(result, "sf"))
  expect_s3_class(result$geometry, "sfc")
})


# --------------------------------------------------
# Test data inputs: olderChildrenPerPrisoner
# --------------------------------------------------
# Load the data
load("incarceratedparent/ProcessedData/olderChildrenPerPrisoner.Rdata")

# 1.1. Check for Required Columns
test_that("olderChildrenPerPrisoner has the correct columns", {
  expect_true(all(c("sex", "race", "children_per_prisoner") %in% names(olderChildrenPerPrisoner)))
})

# 1.2. Check Sex Categories
test_that("Sex is male or female", {
  expect_true(all(olderChildrenPerPrisoner$sex %in% c("female", "male")))
})

# 1.3. Check Race Categories
test_that("Race categories are as expected", {
  expected_races <- c("AsianPacific", "Black", "Hispanic", "Indigenous", "Multi", "white")
  expect_true(all(olderChildrenPerPrisoner$race %in% expected_races))
})

# 1.4. Check for NA values
test_that("There are no NA values", {
  expect_true(!any(is.na(olderChildrenPerPrisoner)))
})

rm(olderChildrenPerPrisoner)

# --------------------------------------------------
# Test data inputs: prisonersByStateAgeSexRace
# --------------------------------------------------
# Load the data
load("incarceratedparent/ProcessedData/prisonersByStateAgeSexRace.Rdata")

# 2.1. Check for Required Columns
test_that("prisonersByStateAgeSexRace has the correct columns", {
  expect_true(all(c("state", "age", "sex", "race", "count") %in% names(prisonersByStateAgeSexRace)))
})

# 2.2. Check State Name Formatting using Regex
test_that("State names are formatted correctly", {
  # Regex pattern for state name: one or more words starting with a capital letter, possibly separated by spaces
  pattern <- "^[A-Z][a-z]+(?: [A-Z][a-z]+)*$"
  expect_true(all(grepl(pattern, prisonersByStateAgeSexRace$state)))
})

# 2.3. Check Sex Categories
test_that("Sex is male or female", {
  expect_true(all(prisonersByStateAgeSexRace$sex %in% c("female", "male")))
})

# 2.4. Check Race Categories
test_that("Race categories are as expected", {
  expected_races <- c("AsianPacific", "Black", "Hispanic", "Indigenous", "Multi", "Other", "white")
  expect_true(all(prisonersByStateAgeSexRace$race %in% expected_races))
})

# 2.5. Check for NA values
test_that("There are no NA values", {
  expect_true(!any(is.na(prisonersByStateAgeSexRace)))
})

rm(prisonersByStateAgeSexRace)

# --------------------------------------------------
# Test data inputs: pumsData
# --------------------------------------------------
# Load the data
load("incarceratedparent/ProcessedData/pumsData.Rdata") 

# 3.1. Test for Correct Column Names
test_that("pumsData has correct column names", {
  expected_col_names <- c("state", "PUMA", "age", "sex", "race", "count")
  expect_equal(names(pumsData), expected_col_names)
})

# 3.2. Test for Age Range
test_that("pumsData has age >= 18", {
  expect_true(all(pumsData$age >= 18))
})

# 3.3. Test for Sex Values
test_that("pumsData has correct sex values", {
  expect_true(all(pumsData$sex %in% c("female", "male")))
})

# 3.4. Test for Race Values
test_that("pumsData has correct race values", {
  expected_races <- c("Multi", "white", "Other", "Indigenous", "Black", "AsianPacific", "Hispanic")
  expect_true(all(pumsData$race %in% expected_races))
})

rm(pumsData)

# --------------------------------------------------
# Test data inputs: pumaShapes
# --------------------------------------------------
# Load the data
load("foster/ProcessedData/pumaShapes.Rdata")   

# 4.1. Test for Required Columns
test_that("pumaShapes has correct column names", {
  expected_col_names <- c("state", "PUMA", "geometry")
  expect_equal(names(pumaShapes), expected_col_names)
})

# 4.2. Test for Correct State Name Conversion
test_that("pumaShapes converts state names correctly", {
  expect_true(all(pumaShapes$state == tolower(pumaShapes$state))) # Assuming state names should be in lowercase
})

# 4.3. Test for Geospatial Data Integrity
test_that("pumaShapes maintains spatial data structure", {
  expect_true(inherits(pumaShapes, "sf"))
  expect_true(all(st_is_valid(pumaShapes)))
})

rm(pumaShapes)

# --------------------------------------------------
# Test data inputs: rawPumsData
# --------------------------------------------------
# Load the data
load("RawData/PUMSRawData.Rdata")

# 5.1. Test for Correct Column Names
test_that("rawPumsData has correct column names", {
  expected_col_names <- c("PWGTP", "AGEP", "PUMA", "ST", "SEX", "RAC1P")
  expect_true(all(expected_col_names %in% colnames(rawPumsData)))
})

# 5.2. Test for Sex Values
test_that("pumsData has correct sex values", {
  expect_true(all(rawPumsData$SEX %in% c(1, 2)))
})

rm(rawPumsData)

