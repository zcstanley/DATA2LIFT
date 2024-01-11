# -----------------------------------------------------------------------------
# Informal Tests for Distributed Foster Data
# Author: Zofia C. Stanley
# Date: Jan 9, 2024
#
# Description:
# This script performs tests on the distributed foster data to ensure data integrity:
#   1. Matching of total distributed foster before and after processing.
#   2. Verification of no negative or NaN values in distributed foster counts.
#   3. Data types and structure validation.
# -----------------------------------------------------------------------------

# --------------------------
# Import required libraries
# --------------------------
library(tidyverse)
library(tidycensus)
library(sf)

# --------------------
# Load Processed Data
# --------------------
load("foster/ProcessedData/scrapedFosterData.Rdata")
load("foster/ProcessedData/fosterDataByPUMA.Rdata")

# --------------------
# Test 1: Check that the number of foster kids is the same before and after processing
# --------------------
test_total_distributed_fosters <- function() {
  preprocessTotals <- scrapedFosterData %>%
    rename(total_pre = total_foster) %>%
    select(state, total_pre) %>%
    unique()
  
  postprocessTotals <- st_drop_geometry(fosterData) %>%
    group_by(state) %>%
    summarise(total_post = sum(count)) %>%
    ungroup()
  
  totals <- merge(preprocessTotals, postprocessTotals) %>%
    mutate(diff = total_pre - total_post) 
  
  
  if (any(abs(totals$diff) > 1)) {
    warning("Data processing does not preserve the total number of foster youth.")
  } else {
    print("Data processing preserves the total number of foster youth.")
  }
  
}

# --------------------
# Test 2: No Negative or NaN Values in Distributed Arrests
# --------------------
test_negative_nan_values <- function() {
  if (!all(fosterData$count >= 0 & !is.nan(fosterData$count))) {
    warning("Negative or NaN values test failed.")
  } else {
    print("Negative or NaN values test passed.")
  }
}


# --------------------
# Test 3: Data Types and Structure Validation
# --------------------
test_data_types_structure <- function() {
  expected_cols <- c("state", "PUMA", "count", "foster_per_pop", "foster_density", "geometry")
  if (!all(expected_cols %in% names(fosterData))) {
    warning("Column names test failed.")
  } else if (!is.numeric(fosterData$count) || 
             !is.numeric(fosterData$foster_per_pop) || 
             !is.numeric(fosterData$foster_density)) {
    warning("Data types test failed.")
  } else {
    print("Data types and structure test passed.")
  }
}

# --------------------
# Execute the tests
# --------------------
test_total_distributed_fosters()
test_negative_nan_values()
test_data_types_structure()
