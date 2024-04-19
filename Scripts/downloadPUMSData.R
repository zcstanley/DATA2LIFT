# -----------------------------------------------------------------------------
# PUMS Data Retrieval
# Author: Chad M. Topaz, Zofia C. Stanley
# Date: Apr 19, 2024
#
# Description:
# This script downloads Public Use Microdata Sample (PUMS) data from the U.S. Census
# for specified variables and years, processes the data, and saves it for future use.
# -----------------------------------------------------------------------------

# -------------------------
# Load Required Libraries
# -------------------------
library(tidycensus)
library(tidyverse)
library(data.table)

# -----------------------------------
# Set Census API Key
# -----------------------------------
census_api_key("d48d2c6fa999265383738be2b1f48aed4900866a")

# -----------------------------------
# Define State Postal Abbreviations 
# -----------------------------------
state_abbreviations <- c("AL", "AK", "AZ", "AR", "CA", "CO", "CT", "DE", "FL", "GA", 
                 "HI", "ID", "IL", "IN", "IA", "KS", "KY", "LA", "ME", "MD", 
                 "MA", "MI", "MN", "MS", "MO", "MT", "NE", "NV", "NH", "NJ", 
                 "NM", "NY", "NC", "ND", "OH", "OK", "OR", "PA", "RI", "SC", 
                 "SD", "TN", "TX", "UT", "VT", "VA", "WA", "WV", "WI", "WY", "DC")

# ----------------------------------------
# Function to Retrieve Data by State
# ----------------------------------------
getDataByState <- function(state, year, max_retries = 3) {
  vars <- c("AGEP", "SCH", "ESR", "RAC1P", "HISP", "SEX", "ST", "PUMA")
  retries <- 1
  
  while (retries <= max_retries) {
    # Try to download the data
    dt <- tryCatch({
      get_pums(variables = vars, year = year, state = state, survey = "acs5", rep_weights = "person")
    }, error = function(e) {
      message("Error downloading data for state ", state, ": ", e$message)
      NULL  # Return NULL to indicate failure
    })
    
    # Check if download was successful
    if (is.null(dt)) {
      retries <- retries + 1
      next
    }
    
    # Check for NA values and attempt re-download if necessary
    if (any(sapply(dt, function(x) any(is.na(x))))) {
      message("NA values found in downloaded data for state ", state, ". Attempting re-download.")
      retries <- retries + 1
      next
    }
    
    # Optimize data types for storage
    setDT(dt)
    dt <- dt[, !names(dt) %in% c("SERIALNO", "SPORDER", "WGTP"), with = FALSE]
    dt[, (c("ST", "SCH", "SEX", "ESR", "HISP", "RAC1P")) := lapply(.SD, as.factor), .SDcols = c("ST", "SCH", "SEX", "ESR", "HISP", "RAC1P")]
    dt[, PUMA := as.integer(PUMA)]
    dt[, (names(dt)[sapply(dt, is.numeric)]) := lapply(.SD, as.integer), .SDcols = names(dt)[sapply(dt, is.numeric)]]
    
    return(dt)
  }
  
  # If all retries fail
  warning(paste("All attempts to fetch and validate data for state", state, "have failed. Returning empty data table."))
  return(data.table())
}

# ----------------------------------------
# Function to Aggregate Data
# ----------------------------------------
aggregate_data_dt <- function(dt) {
  if (!is.data.table(dt)) {
    setDT(dt)
  }
  
  if (!is.null(dt$ST) && nrow(dt) > 0) {
    cat("Processing State Code:", dt$ST[1], "\n")
  } else {
    cat("State Code not available in the dataset.\n")
  }
  
  # This aggregation groups responses by key demographic attributes (AGEP, PUMA, ST, SCH, SEX, ESR, HISP, RAC1P),
  # summing the associated person weights for each group. This method reduces memory usage by eliminating
  # the need to store individual responses separately, which is not required for our analysis. The result includes
  # a count of responses per group, helping to ensure the statistical robustness of our aggregated data.
  result <- dt[, c(lapply(.SD, sum), Num_Responses = .N), 
               by = .(AGEP, PUMA, ST, SCH, SEX, ESR, HISP, RAC1P), 
               .SDcols = patterns("^PWGTP")]
  return(result)
}

# ----------------------------------------
# Fetch data (use pbmclapply to fetch data in parallel)
# ----------------------------------------
rawdata_list <- lapply(state_abbreviations, function(state) {
  getDataByState(state, 2021)
})

# -------------------------------------------------
# Combine and Save All Data
# -------------------------------------------------
results_list <- lapply(rawdata_list, aggregate_data_dt)
combined_dt <- rbindlist(results_list, use.names = TRUE)
saveRDS(combined_dt, "RawData/PUMSDataWithReplicateWeights.rds")

# ----------------------------------------
# Save Each State's Data Separately
# ----------------------------------------
for (i in seq_along(results_list)) {
  filename <- sprintf("RawData/States/PUMS_%s.rds", state_abbreviations[i])
  saveRDS(results_list[[i]], filename)
  print(paste("Saved:", filename))
}
