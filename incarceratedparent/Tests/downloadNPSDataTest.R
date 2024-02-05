# -----------------------------------------------------------------------------
# Tests for Downloading NPS Report Data
# Author: Zofia C. Stanley
# Date: Jan 24, 2024
#
# Description:
# This script tests whether files have been downloaded.
# -----------------------------------------------------------------------------

# Load the testthat library
library(testthat)

# Test Case 1: Check if the .zip file is unzipped successfully
extraction_dir <- "incarceratedparent/RawData/NPS"
test_that("Files are unzipped", {
  # Check if the extraction directory exists
  expect_true(dir.exists(extraction_dir), info = "The extraction directory should exist.")
  
  # Check if the extraction directory is not empty
  extracted_files <- list.files(extraction_dir)
  expect_true(length(extracted_files) > 0, info = "The extraction directory should not be empty.")
})