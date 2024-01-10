# README for the `Scripts` Folder

## Overview

This folder contains a series of R scripts developed for the processing and analysis of foster youth data in the United States. These scripts handle various tasks from downloading data to processing and final distribution of arrest data to Public Use Microdata Areas (PUMAs).

## Script Descriptions

### 1. `downloadFosterData.R`
   - **Purpose**: Fetches foster youth data for each state from the States AFCARS Report.
   - **Key Features**: Downloads a pdf file for each state containing demographic details on the foster youth population in that state.

### 2. `scrapeFosterData.R`
   - **Purpose**: Processes and transforms the downloaded foster youth data.
   - **Key Features**: Includes pdf scraping, data cleaning, and preparation for integration with PUMA data.

### 3. `getFosterPUMS.R`
   - **Purpose**: Retrieves PUMS data and integrates it with the foster data.
   - **Key Features**: Focuses on aligning demographic data from PUMS with race categories used in the AFCARS Report.

### 4. `finalizeFosterData.R`
   - **Purpose**: Distributes the processed foster youth data across PUMAs based on demographic proportions and saves the final dataset.
   - **Key Features**: Involves complex calculations to distribute data evenly and accurately across geographical areas.

### 5. `makeFosterMap.R`
   - **Purpose**: Generates preliminary maps visualizing foster youth by PUMA.
   - **Key Features**: Spatial data processing and visualization.

## Usage

To use these scripts:
1. Ensure all required libraries (as mentioned in each script) are installed in R.
2. Run the scripts in the order listed above for a smooth workflow.
3. Adjust parameters and API keys as necessary.

## Dependencies

- R environment and the following R packages: `dplyr`, `httr`, `jsonlite`, `parallel`, `pbmcapply`,`readr`,`sf`, `tidycensus`, `tigris`,  `tidyverse`
- Access to the U.S. Census PUMS data, either online or stored locally.
- Access to the States AFCARS Report, either online or stored locally.


## Notes

- These scripts are designed to work together as part of a pipeline. Each script outputs data that serves as input for the next.
- Please refer to the main README for more details on the project scope, data sources, and limitations.
