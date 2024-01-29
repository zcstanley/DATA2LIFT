# -----------------------------------------------------------------------------
# Make Maps of Disconnected Youth
# Author: Chad M. Topaz, Zofia C. Stanley
# Date: Jan 9, 2023
#
# Description:
# This code creates maps of where disconnected youth live.
#
# Key Operations:
# 1. Prepares data for plotting, including geometry adjustments for visualization.
# 2. Generates three types of plots using ggplot2:
#    a. Absolute number of disconnected youth per PUMA.
#    b. Density of disconnected youth per square kilometer per PUMA.
#    c. Disconnected youth per 1,000 population aged 16-24 per PUMA.
# 3. Saves the generated plots as PDF files.
#
# -----------------------------------------------------------------------------


# -------------------------
# Load necessary libraries
# -------------------------
library(tidyverse)
library(sf)
library(tigris)


# ------------------------------------------
# Load processed disconnected youth data
# ------------------------------------------
load("disconnected/ProcessedData/disconnectedDataByPUMA.Rdata")

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
  ggtitle("Disconnected Youth, 16-24 Years Old") +
  scale_fill_viridis_c(name = "Disconnected Youth", trans = "log10") +
  theme_void() +
  theme(legend.position = "right")

# Plot density of disconnected youth
p2 <- disconnectedPlotData %>%
  ggplot() +
  geom_sf(aes(fill = disconnected_density), color = NA) +
  ggtitle("Disconnected Youth, 16-24 Years Old", subtitle = "per sq. km") +
  scale_fill_viridis_c(name = "Disconnected Density", trans = "log10") +
  theme_void() +
  theme(legend.position = "right")

# Plot disconnected youth per 1,000 youth (age 16-24)
p3 <- disconnectedPlotData %>%
  ggplot() +
  geom_sf(aes(fill = disconnected_per_pop), color = NA) +
  ggtitle("Disconnected Youth, 16-24 Years Old", subtitle = "per 1,000 Residents 16-24 Years Old") +
  scale_fill_viridis_c(name = "Disconnected Youth", trans = "log10") +
  theme_void() +
  theme(legend.position = "right")


# -----------------------------
# Save the plots as PDF files
# -----------------------------
ggsave(plot = p1, filename = "disconnected/Plots/disconnectedCountMap.pdf", width = 10, height = 6, units = "in", bg = "white")
ggsave(plot = p2, filename = "disconnected/Plots/disconnectedDensityMap.pdf", width = 10, height = 6, units = "in", bg = "white")
ggsave(plot = p3, filename = "disconnected/Plots/disconnectedPerPopMap.pdf", width = 10, height = 6, units = "in", bg = "white")