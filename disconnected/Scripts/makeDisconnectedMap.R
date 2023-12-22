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

# -----------------------------------------
# Aggregate data by state-PUMA combination
# -----------------------------------------
puma_data <- rawdata %>%
  group_by(ST, PUMA) %>%
  summarise(disconnected_youths = sum(PWGTP), .groups = 'drop')

# -------------------------
# Retrieve PUMA boundaries
# -------------------------
pumaShapes <- do.call(rbind, pbmclapply(state_abbreviations, function(state) {
  tigris::pumas(state = state, year = 2021, cb = FALSE)
}, mc.cores = parallel::detectCores() - 1))

pumaShapes <- pumaShapes %>%
  rename(ST = STATEFP10, PUMA = PUMACE10) %>%
  select(ST, PUMA, geometry)

# ---------------------------------------------
# Merge the PUMS data with the PUMA shapefiles
# ---------------------------------------------
disconnectedData <- left_join(pumaShapes, puma_data, by = c("ST", "PUMA")) %>%
  st_as_sf() %>%
  mutate(puma_area = st_area(.) / 1e6,
         disconnected_density = disconnected_youths/puma_area) %>%
  select(-puma_area) %>%
  mutate(disconnected_density = as.numeric(disconnected_density))


# ------------------------------------------
# Save or load processed data, as necessary
# ------------------------------------------
#save(disconnectedData, file = "disconnected/ProcessedData/disconnectedProcessedData.Rdata") 
#load("disconnected/ProcessedData/disconnectedProcessedData.Rdata")


# -------------------------
# Format data for plotting
# -------------------------
disconnectedPlotData <- disconnectedData %>%
  shift_geometry(geoid_column="ST") %>% # move Alaska and Hawaii
  st_simplify(dTolerance = 1000)

# ------------
# Make plots
# ------------
# Plot absolute number of foster children
p1 <- disconnectedPlotData %>%
  ggplot() +
  geom_sf(aes(fill = disconnected_youths), color = NA) +
  ggtitle("Disconnected Youth") +
  scale_fill_viridis_c(name = "Disconnected Youth", trans = "log10") +
  theme_void() +
  theme(legend.position = "right")

# Plot density of foster children
p2 <- disconnectedPlotData %>%
  ggplot() +
  geom_sf(aes(fill = disconnected_density), color = NA) +
  ggtitle("Disconnected Youth", subtitle = "per sq. km") +
  scale_fill_viridis_c(name = "Disconnected Density", trans = "log10") +
  theme_void() +
  theme(legend.position = "right")


# -----------------------------
# Save the plots as PDF files
# -----------------------------
ggsave(plot = p1, filename = "disconnected/Plots/disconnectedCountMap.pdf", width = 10, height = 6, units = "in", bg = "white")
ggsave(plot = p2, filename = "disconnected/Plots/disconnectedDensityMap.pdf", width = 10, height = 6, units = "in", bg = "white")