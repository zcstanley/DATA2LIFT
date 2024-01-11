# -----------------------------------------------------------------------------
# Informal Tests for Downloading Foster Data
# Author: Zofia C. Stanley
# Date: Jan 10, 2024
#
# Description:
# This script tests whether all of the expected foster files have been downloaded 
# and verifies their size.
# -----------------------------------------------------------------------------

# Load necessary libraries for tests
library(httr)  # For file size and existence checks

# --------------------
# Define state postal abbreviations 
# --------------------
state_abbreviations <- tolower(c(
  "AL", "AK", "AZ", "AR", "CA", "CO", "CT", "DE", "FL", "GA", 
  "HI", "ID", "IL", "IN", "IA", "KS", "KY", "LA", "ME", "MD", 
  "MA", "MI", "MN", "MS", "MO", "MT", "NE", "NV", "NH", "NJ", 
  "NM", "NY", "NC", "ND", "OH", "OK", "OR", "PA", "RI", "SC", 
  "SD", "TN", "TX", "UT", "VT", "VA", "WA", "WV", "WI", "WY", "DC"
))

# --------------------
# Test 1: File Existence Check
# --------------------
test_file_existence <- function() {
  all_files_exist <- TRUE
  
  for (state in state_abbreviations) {
    file_path <- paste0("foster/RawData/pdf/", state, ".pdf")
    
    if (!file.exists(file_path)) {
      warning(paste("File does not exist:", file_path))
      all_files_exist <- FALSE
    }
  }
  
  if (all_files_exist) {
    print("All expected PDF files exist.")
  } else {
    warning("Some expected PDF files are missing.")
  }
}

# --------------------
# Test 2: File Size Check
# --------------------
test_file_size <- function() {
  for (state in state_abbreviations) {
    file_path <- paste0("foster/RawData/pdf/", state, ".pdf")
    
    if (file.exists(file_path)) {
      file_size <- file.info(file_path)$size
      
      if (file_size < 200 * 1024 || file_size > 4 * 1024 * 1024) {
        warning(paste("File size out of range (200 KB - 4 MB):", file_path))
      }
    }
  }
  
  print("File size check completed.")
}


# --------------------
# Execute the tests
# --------------------
test_file_existence()
test_file_size()

