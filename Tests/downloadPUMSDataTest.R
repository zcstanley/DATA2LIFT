# -----------------------------------------------------------------------------
# Informal Tests for PUMS Download Code
# Author: Zofia Stanley
# Date: Jan 10, 2024
#
# Description:
# This script accomplishes the following tasks:
#   - Checks to see if there are NAs in the downloaded, unprocessed PUMS data.
#   - Provides starter code for investigating PUMS variable descriptions.
# -----------------------------------------------------------------------------

# --------------------------
# Import required libraries
# --------------------------
library(tidyverse)
library(tidycensus)
library(sf)

# ----------------------------------------------------------------------------------
# Check to see if there are any NAs in the raw (downloaded, unprocessed) PUMS data
# ----------------------------------------------------------------------------------
load("RawData/PUMSRawData.Rdata") 
nas <- sum(is.na(rawPumsData$PWGTP))

if (nas > 0) {
  warning(paste("There are", nas, "NA values in the raw PUMS data. Try re-downloading."))
}

##
# To do: Check to see that race recoding works properly (check class of columns)
##

# ------------------------------------------------------------------------------------
# Not a test, per se, but verification of pums variables may start with the following:
# ------------------------------------------------------------------------------------
pums_vars <- pums_variables %>% 
  filter(year == 2021, survey == "acs1") 

print(pums_vars %>% filter(var_code == "RAC1P"))
