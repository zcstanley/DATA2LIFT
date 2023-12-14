# -----------------------------------------------------------------------------
# Make Maps of Distributed Foster Children by PUMA
# Author: Chad M. Topaz, Zofia Stanley
# Date: Dec 14, 2023
#
# Description:
# This script accomplishes the following tasks:
#   - 
# -----------------------------------------------------------------------------

# --------------------------
# Import required libraries
# --------------------------
library(tidyverse)
library(tidycensus)
library(sf)

# --------------------
# Load data
# --------------------
load("foster/ProcessedData/fosterProcessedData.Rdata")
load("foster/ProcessedData/pumsData.Rdata")
load("foster/ProcessedData/pumaShapes.Rdata")

# ----------------------------------
# Merge in population information
# ----------------------------------
pumaPopData <- pumsData %>%
  group_by(state, PUMA) %>%
  summarise(total_pop = sum(count)) 

fosterData <- merge(fosterData, pumaPopData) %>%
  mutate(foster_per_pop = count/(total_pop/1000)) %>%
  select(-total_pop)

# ----------------------------------
# Merge in geographical information
# ----------------------------------
fosterData <- merge(fosterData, pumaShapes) %>%
  st_as_sf() %>%
  mutate(puma_area = st_area(.) / 1e6,
         foster_density = count/puma_area) %>%
  select(-puma_area) %>%
  mutate(foster_density = as.numeric(foster_density))

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
  ggtitle("Children in Foster Care") +
  scale_fill_viridis_c(name = "Foster Youth", trans = "log10") +
  theme_void() +
  theme(legend.position = "right")

# Plot density of foster children
p2 <- fosterPlotData %>%
  ggplot() +
  geom_sf(aes(fill = foster_density), color = NA) +
  ggtitle("Children in Foster Care", subtitle = "per sq. km") +
  scale_fill_viridis_c(name = "Foster Density", trans = "log10") +
  theme_void() +
  theme(legend.position = "right")

# Plot foster youth per 1,000 youth (age 0-20)
p3 <- fosterPlotData %>%
  ggplot() +
  geom_sf(aes(fill = foster_per_pop), color = NA) +
  ggtitle("Children in Foster Care", subtitle = "per 1,000 residents under the age of 21") +
  scale_fill_viridis_c(name = "Foster Youth", trans = "log10") +
  theme_void() +
  theme(legend.position = "right")

# -----------------------------
# Save the plots as PDF files
# -----------------------------
ggsave(plot = p1, filename = "foster/Plots/fosterCountMap.pdf", width = 10, height = 6, units = "in", bg = "white")
ggsave(plot = p2, filename = "foster/Plots/fosterDensityMap.pdf", width = 10, height = 6, units = "in", bg = "white")
ggsave(plot = p3, filename = "foster/Plots/fosterPerPopMap.pdf", width = 10, height = 6, units = "in", bg = "white")