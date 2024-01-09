# -----------------------------------------------------------------------------
# Make Maps of Distributed Youth Arrests by PUMA
# Author: Zofia Stanley
# Date: Dec 22, 2023
#
# Description:
# This script is designed for visualizing distributed youth arrest data across
# Public Use Microdata Areas (PUMAs). It combines spatial data with demographic
# and arrest data to create detailed maps, offering insights into the distribution
# and density of youth arrests (ages 16-24) in relation to population and geography.
#
# Key Operations:
# 1. Imports R libraries for data manipulation, census data handling, and spatial data.
# 2. Loads processed arrest data, PUMS data, and PUMA shapefiles.
# 3. Aggregates PUMS data to calculate total population per PUMA and merges this with
#    arrest data to calculate arrests per 1,000 population.
# 4. Enhances arrest data with geographical information from PUMA shapefiles, calculates
#    arrest density, and converts data for spatial analysis.
# 5. Prepares data for plotting, including geometry adjustments for visualization.
# 6. Generates three types of plots using ggplot2:
#    a. Absolute number of youth arrests per PUMA.
#    b. Density of youth arrests per square kilometer per PUMA.
#    c. Youth arrests per 1,000 population aged 16-24 per PUMA.
# 7. Saves the generated plots as PDF files.
#
# -----------------------------------------------------------------------------


# --------------------------
# Import required libraries
# --------------------------
library(tidyverse)
library(tidycensus)
library(dplyr)
library(sf)
library(tigris)

# --------------------
# Load data
# --------------------
load("justiceimpacted/ProcessedData/arrestDataByPUMA.Rdata")

# -------------------------
# Format data for plotting
# -------------------------
arrestPlotData <- arrestData %>%
  shift_geometry() %>% # move Alaska and Hawaii
  st_simplify(dTolerance = 1000)

# ------------
# Make plots
# ------------
# Plot absolute number of youth arrests
p1 <- arrestPlotData %>%
  ggplot() +
  geom_sf(aes(fill = count), color = NA) +
  ggtitle("Youth Arrests, ages 16-24") +
  scale_fill_viridis_c(name = "Arrests", trans = "log10") +
  theme_void() +
  theme(legend.position = "right")

# Plot density of youth arrests
p2 <- arrestPlotData %>%
  ggplot() +
  geom_sf(aes(fill = arrest_density), color = NA) +
  ggtitle("Youth Arrests, ages 16-24", subtitle = "per sq. km") +
  scale_fill_viridis_c(name = "Arrest Density", trans = "log10") +
  theme_void() +
  theme(legend.position = "right")

# Plot youth arrests per 1,000 youth (age 16-24)
p3 <- arrestPlotData %>%
  ggplot() +
  geom_sf(aes(fill = arrest_per_pop), color = NA) +
  ggtitle("Youth Arrests, ages 16-24", subtitle = "per 1,000 residents 16-24 years old") +
  scale_fill_viridis_c(name = "Arrests", trans = "log10") +
  theme_void() +
  theme(legend.position = "right")

# -----------------------------
# Save the plots as PDF files
# -----------------------------
ggsave(plot = p1, filename = "justiceimpacted/Plots/arrestCountMap.pdf", width = 10, height = 6, units = "in", bg = "white")
ggsave(plot = p2, filename = "justiceimpacted/Plots/arrestDensityMap.pdf", width = 10, height = 6, units = "in", bg = "white")
ggsave(plot = p3, filename = "justiceimpacted/Plots/arrestPerPopMap.pdf", width = 10, height = 6, units = "in", bg = "white")