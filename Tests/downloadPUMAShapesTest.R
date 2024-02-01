# -----------------------------------------------------------------------------
# Informal Tests for PUMA Shape Download Code
# Author: Zofia C. Stanley
# Date: Feb 1, 2024
#
# Description:
# This script accomplishes the following tasks:
#   - Checks to see if the geometries are the same in both shape files. 
# -----------------------------------------------------------------------------

# --------------------------
# Import required libraries
# --------------------------

library(sf)
library(dplyr)

# -----------------------------------------------------------------------------
# Check to see if the geometries are the same in the two PUMA shape files
# -----------------------------------------------------------------------------
load("RawData/pumaShapes.Rdata")
shapefile <- st_read("RawData/PUMA_Shapes.shp")

compare_shapefiles <- function(shapefile, pumaShapes) {
  comparison_geom <- st_equals(shapefile$geometry, pumaShapes$geometry)
  comparison_attr <- identical(shapefile %>% st_drop_geometry() %>% select(state, PUMA), pumaShapes %>% st_drop_geometry())
  
  # Results
  if (all(comparison_geom)) {
    print("PASS: The geometries in corresponding rows are equal.")
  } else {
    print("FAIL: The geometries in corresponding rows are not equal.")
  }
  
  if (comparison_attr) {
    print("PASS: The non-geometric attributes in both data frames are exactly the same.")
  } else {
    print("FAIL: The non-geometric attributes in both data frames are not the same.")
  }
  }

# --------------------------
# Run tests
# --------------------------
compare_shapefiles(shapefile, pumaShapes)
