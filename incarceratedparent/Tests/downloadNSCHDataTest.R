# -----------------------------------------------------------------------------
# Tests for Downloading NSCH Data
# Author: Zofia C. Stanley
# Date: Jan 24, 2024
#
# Description:
# This script tests whether files have been downloaded.
# -----------------------------------------------------------------------------

# Load the testthat library
library(testthat)

# Define the variables for the directory and file name
data_dir <- "incarceratedparent/RawData"
file_name <- "nsch_data.xlsx"
dest_file_path <- file.path(data_dir, file_name)

# Test Case 1: Check if the specified file exists
test_that("Specified file exists", {
  # Check if the file exists
  expect_true(file.exists(dest_file_path), info = paste("The file", dest_file_path, "should exist."))
})
