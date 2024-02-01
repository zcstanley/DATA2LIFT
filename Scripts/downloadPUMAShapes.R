# -----------------------------------------------------------------------------
# Census PUMA Shape Retrieval
# Author: Zofia C. Stanley
# Date: Jan 8, 2024
#
# Description:
# This script fetches and saves PUMA shapes by state in two formats: one for use
# in R plotting procedures, and one for use in Tableau dashboard creation. 
# -----------------------------------------------------------------------------

# --------------------
# Import required libraries
# --------------------
library(tidyverse)
library(tidycensus)
library(tigris)
library(pbmcapply)
library(sf)

# Define state abbreviations
state_abbreviations <- tolower(c(
  "AL", "AK", "AZ", "AR", "CA", "CO", "CT", "DE", "FL", "GA", 
  "HI", "ID", "IL", "IN", "IA", "KS", "KY", "LA", "ME", "MD", 
  "MA", "MI", "MN", "MS", "MO", "MT", "NE", "NV", "NH", "NJ", 
  "NM", "NY", "NC", "ND", "OH", "OK", "OR", "PA", "RI", "SC", 
  "SD", "TN", "TX", "UT", "VT", "VA", "WA", "WV", "WI", "WY", "DC"
))


# --------------------
# Retrieve shape files
# --------------------
pumaShapesNames <- do.call(rbind, lapply(state_abbreviations, function(state) {
  tigris::pumas(state = state, year = 2019, cb = FALSE)
}))

pumaShapesNames <- pumaShapesNames %>%
  rename(state_code = STATEFP10, PUMA = PUMACE10) 

fipsLookup <- fips_codes %>%
  select(state, state_code) %>%
  unique %>%
  mutate(state = tolower(state)) %>%
  filter(state %in% state_abbreviations)

pumaShapesNames <- merge(pumaShapesNames, fipsLookup) %>%
  select(-state_code, -FUNCSTAT10, -MTFCC10)

pumaShapes <- pumaShapesNames %>% select(state, PUMA, geometry)

# --------------------
# Store the finalized data
# --------------------
save(pumaShapes, file = "RawData/pumaShapes.Rdata") # Rdata file for R plotting
st_write(pumaShapesNames, "RawData/PUMA_Shapes.shp") # shapefile for Tableau