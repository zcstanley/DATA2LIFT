# -----------------------------------------------------------------------------
# Make Maps of Distributed Children with an Incarcerated Parent by PUMA
# Author: Zofia C. Stanley
# Date: Jan 23, 2024
#
# Description:
# This script is designed for visualizing distributed children with incarcerated parent across
# Public Use Microdata Areas (PUMAs). It creates detailed maps, offering insights 
# into the distribution and density of children with incarcerated parent (ages 15-17) in relation to 
# population and geography.
#
# Key Operations:
# 1. Prepares data for plotting, including geometry adjustments for visualization.
# 2. Generates three types of plots using ggplot2:
#    a. Absolute number of children with incarcerated parent per PUMA.
#    b. Density of children with incarcerated parent per square kilometer per PUMA.
#    c. Children with incarcerated parent per 1,000 population aged 15-17 per PUMA.
# 3. Saves the generated plots as PDF files.
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
load("incarceratedparent/ProcessedData/incarceratedParentDataByPUMA.Rdata")

# -------------------------
# Format data for plotting
# -------------------------
incarceratedParentPlotData <- incarceratedParentData %>%
  shift_geometry() %>% # move Alaska and Hawaii
  st_simplify(dTolerance = 1000)

# ------------
# Make plots
# ------------
# Plot absolute number of children with an incarcerated parent
p1 <- incarceratedParentPlotData %>%
  ggplot() +
  geom_sf(aes(fill = count), color = NA) +
  ggtitle("Children with an Incarcerated Parent in State Prison, ages 15-17") +
  scale_fill_viridis_c(name = "Youth", trans = "log10") +
  theme_void() +
  theme(legend.position = "right")

# Plot density of children with an incarcerated parent
p2 <- incarceratedParentPlotData %>%
  ggplot() +
  geom_sf(aes(fill = incarcerated_parent_density), color = NA) +
  ggtitle("Children with an Incarcerated Parent in State Prison, ages 15-17", subtitle = "per sq. km") +
  scale_fill_viridis_c(name = "Density", trans = "log10") +
  theme_void() +
  theme(legend.position = "right")

# Plot children with an incarcerated parent per 1,000 youth (age 15-17)
p3 <- incarceratedParentPlotData %>%
  ggplot() +
  geom_sf(aes(fill = incarcerated_parent_per_pop), color = NA) +
  ggtitle("Children with an Incarcerated Parent in State Prison, ages 15-17", subtitle = "per 1,000 residents 15-17 years old") +
  scale_fill_viridis_c(name = "Youth", trans = "log10") +
  theme_void() +
  theme(legend.position = "right")

# -----------------------------
# Save the plots as PDF files
# -----------------------------
ggsave(plot = p1, filename = "incarceratedparent/Plots/incarceratedParentCountMap.pdf", width = 10, height = 6, units = "in", bg = "white")
ggsave(plot = p2, filename = "incarceratedparent/Plots/incarceratedParentDensityMap.pdf", width = 10, height = 6, units = "in", bg = "white")
ggsave(plot = p3, filename = "incarceratedparent/Plots/incarceratedParentPerPopMap.pdf", width = 10, height = 6, units = "in", bg = "white")