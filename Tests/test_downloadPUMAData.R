# -----------------------------------------------------------------------------
# PUMS Data Verification
# Author: Zofia C. Stanley
# Date: Apr 19, 2024
#
# Description:
# This script compares estimates derived from downloaded data to published
# PUMS verification tables. Verification table is downloaded from here:
# https://www.census.gov/programs-surveys/acs/microdata/documentation.2021.html
# -----------------------------------------------------------------------------

# -------------------------
# Load Required Libraries
# -------------------------
library(tidycensus)
library(tidyverse)
library(data.table)
library(srvyr)

# -----------------------------------
# Function to verify saved data
# -----------------------------------
verify_state_data <- function(state_abbreviation, verification_data, verbose=FALSE) {
  cat(sprintf("\nVerifying PUMS data for %s.\n", state_abbreviation))

  file_path <- sprintf("RawData/States/PUMS_%s.rds", state_abbreviation)
  dt_state <- readRDS(file_path)
  state_code <- as.character(levels(dt_state$ST))[1]
  survey_state <- to_survey(dt_state)
  
  # Calculate total count and standard error for gender
  gender_totals <- survey_state %>% 
    survey_count(SEX) 
  
  # Calculate totals for age range 15-19
  age_15_19 <- survey_state %>%
    filter(AGEP >= 15 & AGEP <= 19) %>%
    survey_count() 
  
  # Filter verification data for the current state and relevant characteristics
  state_verification <- verification_data %>%
    filter(ST == state_code & 
             CHARACTERISTIC %in% c("Total males (SEX=1)", "Total females (SEX=2)", "Age 15-19"))
  
  # Define a helper function to compare estimates
  compare_estimates <- function(estimated, verified, label, verbose=FALSE) {
    if (nrow(verified) > 0) {
      est <- estimated$n
      est_se <- estimated$n_se
      ver <- verified$PUMS_EST_17_TO_21
      ver_se <- verified$PUMS_SE_17_TO_21
      
      if (verbose || abs(est - ver) >= 0.5 || abs(est_se - ver_se) >= 0.5){
        cat(sprintf("\nVerification for %s:\n", label))
        cat(sprintf("Estimated: %f, SE: %f\n", est, est_se))
        cat(sprintf("Verified: %f, SE: %f\n", ver, ver_se))
        cat(sprintf("Difference: %f, SE Difference: %f\n", abs(est - ver), abs(est_se - ver_se)))
      }
    } else {
      cat(sprintf("\nNo verification data available for %s.\n", label))
    }
  }
  
  # Check gender totals
  for (sex_level in c("1", "2")) {
    estimated <- gender_totals[gender_totals$SEX == sex_level, ]
    verified <- state_verification[state_verification$CHARACTERISTIC == paste0("Total ", ifelse(sex_level == "1", "males", "females"), " (SEX=", sex_level, ")")
, ]
    compare_estimates(estimated, verified, paste("Gender", sex_level), verbose=verbose)
  }
  
  # Check age group totals
  estimated_age <- age_15_19
  verified_age <- state_verification[state_verification$CHARACTERISTIC == "Age 15-19", ]
  compare_estimates(estimated_age, verified_age, "Age 15-19", verbose=verbose)
}

# -----------------------------------
# Define State Postal Abbreviations 
# -----------------------------------
state_abbreviations <- c("AL", "AK", "AZ", "AR", "CA", "CO", "CT", "DE", "FL", "GA", 
                         "HI", "ID", "IL", "IN", "IA", "KS", "KY", "LA", "ME", "MD", 
                         "MA", "MI", "MN", "MS", "MO", "MT", "NE", "NV", "NH", "NJ", 
                         "NM", "NY", "NC", "ND", "OH", "OK", "OR", "PA", "RI", "SC", 
                         "SD", "TN", "TX", "UT", "VT", "VA", "WA", "WV", "WI", "WY", "DC")

# -----------------------------------
# Load PUMS Verification Data 
# -----------------------------------
verification <- read_csv("Tests/pums_estimates_17_21.csv")

# -----------------------------------
# Verify PUMS Data for All States
# -----------------------------------
for (state in state_abbreviations) {
  verify_state_data(state, verification)
}

