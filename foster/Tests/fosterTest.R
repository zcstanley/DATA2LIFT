# -----------------------------------------------------------------------------
# Informal Tests for Foster Code
# Author: Zofia Stanley
# Date: Dec 13, 2023
#
# Description:
# This script accomplishes the following tasks:
#   - Checks to see if the number of foster kids is preserved in data processing.
#   - Checks to see if there are NAs in the downloaded, unprocessed PUMS data.
#   - Provides starter code for investigating PUMS variable descriptions.
# -----------------------------------------------------------------------------

# --------------------------
# Import required libraries
# --------------------------
library(tidyverse)
library(tidycensus)
library(sf)

# ------------------------------------------------------------------------------------
# Check to see that the number of foster kids is the same before and after processing
# ------------------------------------------------------------------------------------
load("foster/ProcessedData/scrapedFosterData.Rdata")
load("foster/ProcessedData/fosterProcessedData.Rdata")

preprocessTotals <- scrapedFosterData %>%
  rename(total_pre = total_state) %>%
  select(state, total_pre) %>%
  unique()

postprocessTotals <- st_drop_geometry(fosterData) %>%
  group_by(state) %>%
  summarise(total_post = sum(count)) %>%
  ungroup()

totals <- merge(preprocessTotals, postprocessTotals) %>%
  mutate(diff = total_pre - total_post) 

if (any(abs(totals$diff) > 1)) {
  warning("Data processing does not preserve the total number of foster kids.")
  }


# ----------------------------------------------------------------------------------
# Check to see if there are any NAs in the raw (downloaded, unprocessed) PUMS data
# ----------------------------------------------------------------------------------
load("foster/RawData/fosterRawPUMSData.Rdata") 
nas <- sum(is.na(rawdata$PWGTP))

if (nas > 0) {
  warning(paste("There are", nas, "NA values in the raw PUMS data. Try re-downloading."))
  }

# ------------------------------------------------------------------------------------
# Not a test, per se, but verification of pums variables may start with the following:
# ------------------------------------------------------------------------------------
pums_vars <- pums_variables %>% 
  filter(year == 2021, survey == "acs1") 

print(pums_vars %>% filter(var_code == "RAC1P"))




