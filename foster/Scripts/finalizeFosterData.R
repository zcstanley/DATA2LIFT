# -----------------------------------------------------------------------------
# Distribute Foster Children to PUMAs Based on Age, Sex, and Race Proportions
# Author: Chad M. Topaz
# Date: Sep 19, 2023
#
# Description:
# This script accomplishes the following tasks:
#   - Load datasets: scraped foster data, PUMS data, and PUMA shapefiles.
#   - Convert proportions to counts for foster data.
#   - Calculate the proportion of each PUMA by age, sex, and race.
#   - Distribute foster children among PUMAs according to demographic proportions.
# -----------------------------------------------------------------------------

# --------------------
# Import required libraries
# --------------------
library(tidyverse)
library(tidycensus)
library(sf)

# --------------------
# Load data
# --------------------
load("foster/ProcessedData/scrapedFosterData.Rdata")
load("foster/ProcessedData/pumsData.Rdata")
load("foster/ProcessedData/pumaShapes.Rdata")

# --------------------
# Distribute foster kids to PUMAS
# --------------------

# Convert props to counts in foster data
scrapedFosterData <- scrapedFosterData %>%
  mutate(count = prop * total_state) %>%
  select(-prop, -total_state)

# Calculate the proportion of each PUMA for a given combination of age/sex/race
# e.g. of all the 1 y/o Black girls in a given state, what fraction are in a given PUMA?
pumsData <- pumsData %>%
  group_by(state, age, sex, race) %>%
  mutate(puma_prop = count / sum(count)) %>%
  ungroup() %>%
  select(-count)

# Create a new dataframe by joining the two dataframes on the common columns (state, age, sex, race)
joined_data <- inner_join(scrapedFosterData, pumsData) %>%
  mutate(foster = count * puma_prop) %>%
  select(-count, -puma_prop)

# Handle missing combinations
# Identify the total number of PUMAs for each state
puma_count_per_state <- pumsData %>%
  group_by(state) %>%
  mutate(total_pumas = n_distinct(PUMA)) %>%
  ungroup() %>%
  select(state, PUMA, total_pumas) %>%
  unique()

# Identify missing combinations and distribute children
missing_distributed <- anti_join(scrapedFosterData, pumsData, by = c("state", "age", "sex", "race")) %>%
  left_join(puma_count_per_state, by = "state") %>%
  mutate(distributed_count = count / total_pumas) %>%
  select(-total_pumas, -count) %>%
  rename(foster = distributed_count)

# Combine the datasets
combined_data <- bind_rows(joined_data, missing_distributed) 

# Total up foster kids in each PUMA
fosterData <- combined_data %>%
  group_by(state, PUMA) %>%
  summarise(count = sum(foster))

# Merge in geographical information
fosterData <- merge(fosterData, pumaShapes) %>%
  st_as_sf() %>%
  mutate(puma_area = st_area(.) / 1e6,
         foster_density = count/puma_area) %>%
  select(-puma_area) %>%
  mutate(foster_density = as.numeric(foster_density))

# Save
save(fosterData, file = "foster/ProcessedData/fosterProcessedData.Rdata")

# Now let's make nice new data for a visualization

fosterPlotData <- fosterData %>%
  filter(! state %in% c("ak","hi")) %>%
  st_simplify(dTolerance = 1000)

p1 <- fosterPlotData %>%
  ggplot() +
  geom_sf(aes(fill = count), color = NA) +
  scale_fill_viridis_c(name = "Foster Youth", trans = "log10") +
  theme_void() +
  theme(legend.position = "right")

# Save the plot as a PDF file
ggsave(plot = p1, filename = "foster/Plots/fosterCountMap.png", width = 10, height = 6, units = "in", bg = "white")

p2 <- fosterPlotData %>%
  ggplot() +
  geom_sf(aes(fill = foster_density), color = NA) +
  scale_fill_viridis_c(name = "Foster Density\n(per sq. km)", trans = "log10") +
  theme_void() +
  theme(legend.position = "right")

# Save the plot as a PDF file
ggsave(plot = p2, filename = "foster/Plots/fosterDensityMap.png", width = 10, height = 6, units = "in", bg = "white")