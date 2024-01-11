# -----------------------------------------------------------------------------
# Informal Tests for Downloading Arrest Data
# Author: Zofia C. Stanley
# Date: Jan 9, 2024
#
# Description:
# This script tests whether all of the expected arrest files have been downloaded 
# and verifies their size.
# -----------------------------------------------------------------------------

# Load necessary libraries
library(httr)  

# Define state postal abbreviations
state_abbreviations <- c("AL", "AK", "AZ", "AR", "CA", "CO", "CT", "DE", "FL", "GA", 
                         "HI", "ID", "IL", "IN", "IA", "KS", "KY", "LA", "ME", "MD", 
                         "MA", "MI", "MN", "MS", "MO", "MT", "NE", "NV", "NH", "NJ", 
                         "NM", "NY", "NC", "ND", "OH", "OK", "OR", "PA", "RI", "SC", 
                         "SD", "TN", "TX", "UT", "VT", "VA", "WA", "WV", "WI", "WY", "DC")

# Define categories (male, female, race)
categories <- c("male", "female", "race")

# Function to generate filename for saving the data
generate_filename <- function(state_abbreviation, category) {
  # Construct the file path using the state abbreviation and category
  paste0("justiceimpacted/RawData/ArrestData/fbi_arrest_", state_abbreviation, "_", category, ".csv")
}

# --------------------
# Test 1: File Existence Check
# --------------------
test_all_files_exist <- function() {
  all_files_exist <- TRUE  # Flag to track if all files exist
  
  # Iterate through each state and category combination
  for (state in state_abbreviations) {
    for (category in categories) {
      filename <- generate_filename(state, category)
      
      # Check if the file exists, and give a warning if it doesn't
      if (!file.exists(filename)) {
        warning(paste("File does not exist:", filename))
        all_files_exist <- FALSE
      } 
    }
  }
  
  # Print a final message based on the existence of all files
  if (all_files_exist) {
    print("All expected raw FBI arrest files exist.")
  } else {
    warning("Some expected arrest files are missing.")
  }
}

# --------------------
# Test 2: File Size Check (Less than 2 KB)
# --------------------
test_file_size <- function() {
  for (state in state_abbreviations) {
    for (category in categories) {
      filename <- generate_filename(state, category)
      
      # Check if file exists to avoid error in file size check
      if (file.exists(filename)) {
        file_size <- file.info(filename)$size
        if (file_size >= 2048) {  # 2 KB = 2048 bytes
          warning(paste("File size exceeds 2 KB:", filename))
        }
      }
    }
  }
  print("File size check completed.")
}

# --------------------
# Execute the tests
# --------------------
test_all_files_exist()
test_file_size()

