# -----------------------------------------------------------------------------
# Count the Number of Disconnected Youth and Make Maps
# Author: Chad M. Topaz, Zofia Stanley
# Date: Dec 9, 2023
#
# Description:
# This code determines the number of disconnected youth from PUMS data and
# saves maps of where disconnected youth live.
# -----------------------------------------------------------------------------

# -------------------------
# Load necessary libraries
# -------------------------
library(tidycensus)
library(tidyverse)
library(pbmcapply)  # parallel version of lapply
library(sf)
library(cartogram)
library(tigris)

# -----------------------------------
# Define state postal abbreviations 
# -----------------------------------
state_abbreviations <- c("AL", "AK", "AZ", "AR", "CA", "CO", "CT", "DE", "FL", "GA", 
                 "HI", "ID", "IL", "IN", "IA", "KS", "KY", "LA", "ME", "MD", 
                 "MA", "MI", "MN", "MS", "MO", "MT", "NE", "NV", "NH", "NJ", 
                 "NM", "NY", "NC", "ND", "OH", "OK", "OR", "PA", "RI", "SC", 
                 "SD", "TN", "TX", "UT", "VT", "VA", "WA", "WV", "WI", "WY", "DC")

# -------------------------------------------------------------------
# Load raw data if it exists, 
# else prompt user to download data using downloadDisconnectedData.R
# -------------------------------------------------------------------
tryCatch({
  load("disconnected/RawData/disconnectedRawData.Rdata")
  }, 
  error = function(e) {
    warning("The file disconnected/RawData/disconnectedRawData.Rdata does not exist. Please run Scripts/downloadDisconnectedData.R to create it.")
  })

load("RawData/PUMSRawData.Rdata") 
load("foster/ProcessedData/pumaShapes.Rdata")

# -----------------------------------------
# Aggregate data by state-PUMA combination
# -----------------------------------------
disconnectedData <- rawdata %>%
  group_by(ST, PUMA) %>%
  summarise(count = sum(PWGTP), .groups = 'drop') %>%
  rename(state_code = ST)

# ----------------------------------
# Merge in population information
# ----------------------------------
# Process and filter PUMS data for youth ages 16-24
pumaPopData <- rawPumsData %>% 
  select("PWGTP", "AGEP", "PUMA", "ST") %>%
  filter(AGEP >= 16 & AGEP <= 24) %>%
  rename(age = AGEP, state_code = ST, count = PWGTP) %>%
  select(state_code, PUMA, age, count) %>%
  group_by(state_code, PUMA) %>%
  summarise(total_pop = sum(count), .groups = 'drop') %>%
  ungroup

# Compute disconnected youth per 1,000 youth aged 16-24
disconnectedData <- merge(disconnectedData, pumaPopData) %>%
  mutate(disconnected_per_pop = count/(total_pop/1000)) %>%
  select(-total_pop) 

# ---------------------------------------------
# Get state abbreviations from state codes
# ---------------------------------------------
# Create a lookup table for state FIPS codes
fipsLookup <- fips_codes %>%
  select(state, state_code) %>%
  unique 

# Merge PUMS data with FIPS codes to integrate geographical data
disconnectedData <- merge(disconnectedData, fipsLookup) %>%
  select(-state_code) %>%
  mutate(state = tolower(state)) 

# ---------------------------------------------
# Merge the PUMS data with the PUMA shapefiles
# ---------------------------------------------
disconnectedData <- left_join(pumaShapes, disconnectedData, by = c("state", "PUMA")) %>%
  st_as_sf() %>%
  mutate(puma_area = st_area(.) / 1e6,
         disconnected_density = count/puma_area) %>%
  select(-puma_area) %>%
  mutate(disconnected_density = as.numeric(disconnected_density))

# ------------------------------------------
# Save or load processed data, as necessary
# ------------------------------------------
save(disconnectedData, file = "disconnected/ProcessedData/disconnectedDataByPUMA.Rdata") 
write.csv(disconnectedData %>% st_drop_geometry(), file = "disconnected/ProcessedData/disconnectedDataByPUMA.csv")
#load("disconnected/ProcessedData/disconnectedProcessedData.Rdata")


# -------------------------
# Format data for plotting
# -------------------------
disconnectedPlotData <- disconnectedData %>%
  shift_geometry() %>% # move Alaska and Hawaii
  st_simplify(dTolerance = 1000)

# ------------
# Make plots
# ------------
# Plot absolute number of disconnected youth
p1 <- disconnectedPlotData %>%
  ggplot() +
  geom_sf(aes(fill = count), color = NA) +
  ggtitle("Disconnected Youth, ages 16-24") +
  scale_fill_viridis_c(name = "Disconnected Youth", trans = "log10") +
  theme_void() +
  theme(legend.position = "right")

# Plot density of disconnected youth
p2 <- disconnectedPlotData %>%
  ggplot() +
  geom_sf(aes(fill = disconnected_density), color = NA) +
  ggtitle("Disconnected Youth, ages 16-24", subtitle = "per sq. km") +
  scale_fill_viridis_c(name = "Disconnected Density", trans = "log10") +
  theme_void() +
  theme(legend.position = "right")

# Plot disconnected youth per 1,000 youth (age 16-24)
p3 <- disconnectedPlotData %>%
  ggplot() +
  geom_sf(aes(fill = disconnected_per_pop), color = NA) +
  ggtitle("Disconnected Youth, ages 16-24", subtitle = "per 1,000 residents 16-24 years old") +
  scale_fill_viridis_c(name = "Disconnected Youth", trans = "log10") +
  theme_void() +
  theme(legend.position = "right")


# -----------------------------
# Save the plots as PDF files
# -----------------------------
ggsave(plot = p1, filename = "disconnected/Plots/disconnectedCountMap.pdf", width = 10, height = 6, units = "in", bg = "white")
ggsave(plot = p2, filename = "disconnected/Plots/disconnectedDensityMap.pdf", width = 10, height = 6, units = "in", bg = "white")
ggsave(plot = p3, filename = "disconnected/Plots/disconnectedPerPopMap.pdf", width = 10, height = 6, units = "in", bg = "white")