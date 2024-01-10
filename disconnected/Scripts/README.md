# README for the `Scripts` Folder

## Overview

The `Scripts` folder contains R scripts developed for the analysis and visualization of disconnected youth data, using Public Use Microdata Sample (PUMS) data. Disconnected youth are individuals between 16 and 24 years old who are not in school and not employed.

## Script Descriptions

### 1. `getDisconnectedPUMS.R`
   - **Purpose**: This script processed PUMS data from the U.S. Census and counts disconnected youth.
   - **Key Functions**:
     - Loads saved raw PUMS data.
     - Applies filters to identify disconnected youth.
     - Integrates population and geographical data for further analysis.

### 2. `makeDisconnectedMap.R`
   - **Purpose**: Dedicated to creating spatial visualizations (maps) of disconnected youth across different PUMAs. This script takes the processed data and generates maps that depict various aspects such as the count, density, and proportion of disconnected youth.
   - **Key Features**:
     - Creates maps showing absolute numbers, densities, and relative proportions of disconnected youth.

## Usage

- To use these scripts, ensure that all `PUMSRawData.Rdata` and `pumaShapes.Rdata` are located in **`RawData`**.
- Run `getDisconnectedPUMS.R` first to process the raw data.
- Follow with `makeDisconnectedMap.R` to generate the visualizations based on the processed data.

## Dependencies

- R environment with packages including `tidyverse`, `tidycensus`, `sf`, and others as required by the specific tasks within each script.
- Access to the U.S. Census PUMS data, either online or stored locally.
