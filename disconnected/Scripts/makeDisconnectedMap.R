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

# -----------------------------------
# Define state postal abbreviations 
# -----------------------------------
states_list <- c("AL", "AK", "AZ", "AR", "CA", "CO", "CT", "DE", "FL", "GA", 
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
puma_shapes <- do.call(rbind, lapply(states_list, function(state) {
  tigris::pumas(state = state, year = 2019, cb = TRUE)
}))

# ---------------------------------------------
# Merge the PUMS data with the PUMA shapefiles
# ---------------------------------------------
merged_data <- left_join(puma_shapes, puma_data, 
                         by = c("STATEFP10" = "ST", "PUMACE10" = "PUMA"))

# ------------------------------------------
# Save or load processed data, as necessary
# ------------------------------------------
#save(merged_data, file = "disconnected/ProcessedData/disconnectedProcessedData.Rdata") 
#load("disconnected/ProcessedData/disconnectedProcessedData.Rdata")


# -------------------------------------
# Subset the data by geographic region
# -------------------------------------
us_contiguous <- merged_data[!merged_data$STATEFP %in% c("02", "15"), ]
alaska <- merged_data[merged_data$STATEFP == "02", ]
hawaii <- merged_data[merged_data$STATEFP == "15", ]

# ---------------------------------------------------
# Create a ggplot object with the cartogram polygons
# ---------------------------------------------------
plotDisconnected <- function(data=us_contiguous){
  p <- ggplot(data) +
    geom_sf(aes(fill = disconnected_youths)) +
    scale_fill_viridis_c(name = "Disconnected Youths") +
    theme_void() +
    theme(legend.position = "right")
  return(p)
}

# ---------------------------------------------------
# Create plots for contiguous US, Alaska, and Hawaii
# ---------------------------------------------------
p1 <- plotDisconnected(us_contiguous)
p2 <- plotDisconnected(alaska)
p3 <- plotDisconnected(hawaii)

# ----------------------------
# Save the plots as PDF files
# ----------------------------
ggsave(filename = "disconnected/Plots/disconnectedContiguousUS2021Map.pdf", plot = p1, width = 10, height = 6)
ggsave(filename = "disconnected/Plots/disconnectedAlaska2021Map.pdf", plot = p2, width = 10, height = 6)
ggsave(filename = "disconnected/Plots/disconnectedHawaii2021Map.pdf", plot = p3, width = 10, height = 6)