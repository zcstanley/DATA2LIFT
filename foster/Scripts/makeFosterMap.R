# -----------------------------------------------------------------------------
# Make Maps of Distributed Foster Children by PUMA
# Author: Chad M. Topaz, Zofia Stanley
# Date: Jan 10, 2023
#
# Description:
# This script is designed for visualizing distributed foster youth data across
# Public Use Microdata Areas (PUMAs). It creates detailed maps, offering insights 
# into the distribution and density of foster youth (ages 16-20) in relation to 
# population and geography.
#
# Key Operations:
# 1. Prepares data for plotting, including geometry adjustments for visualization.
# 2. Generates three types of plots using ggplot2:
#    a. Absolute number of foster youth aged 16-20 per PUMA.
#    b. Density of foster youth per square kilometer per PUMA.
#    c. Foster youth per 1,000 population aged 16-20 per PUMA.
# 3. Saves the generated plots as PDF files.
# -----------------------------------------------------------------------------

# --------------------------
# Import required libraries
# --------------------------
library(tidyverse)
library(tidycensus)
library(sf)
library(tigris)

# --------------------
# Load data
# --------------------
load("foster/ProcessedData/fosterDataByPUMA.Rdata")

# -------------------------
# Format data for plotting
# -------------------------
fosterPlotData <- fosterData %>%
  shift_geometry() %>% # move Alaska and Hawaii
  st_simplify(dTolerance = 1000)

# ------------
# Make plots
# ------------
# Plot absolute number of foster children
p1 <- fosterPlotData %>%
  ggplot() +
  geom_sf(aes(fill = count), color = NA) +
  ggtitle("Children in Foster Care, aged 16-20") +
  scale_fill_viridis_c(name = "Foster Youth", trans = "log10") +
  theme_void() +
  theme(legend.position = "right")

# Plot density of foster children
p2 <- fosterPlotData %>%
  ggplot() +
  geom_sf(aes(fill = foster_density), color = NA) +
  ggtitle("Children in Foster Care, aged 16-20", subtitle = "per sq. km") +
  scale_fill_viridis_c(name = "Foster Density", trans = "log10") +
  theme_void() +
  theme(legend.position = "right")

p3 <- fosterPlotData %>%
  ggplot() +
  geom_sf(aes(fill = foster_per_pop), color = NA) +
  ggtitle("Children in Foster Care, aged 16-20", subtitle = "per 1,000 residents aged 16-20") +
  scale_fill_viridis_c(name = "Foster Youth", trans = "log10") +
  theme_void() +
  theme(legend.position = "right")

# -----------------------------
# Save the plots as PDF files
# -----------------------------
ggsave(plot = p1, filename = "foster/Plots/fosterCountMap.pdf", width = 10, height = 6, units = "in", bg = "white")
ggsave(plot = p2, filename = "foster/Plots/fosterDensityMap.pdf", width = 10, height = 6, units = "in", bg = "white")
ggsave(plot = p3, filename = "foster/Plots/fosterPerPopMap.pdf", width = 10, height = 6, units = "in", bg = "white")