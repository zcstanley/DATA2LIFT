# README for the `Scripts` Folder

## Overview

This folder contains a series of R scripts developed for the processing and analysis of youth arrest data in the United States. These scripts handle various tasks from downloading data to processing and final distribution of arrest data to Public Use Microdata Areas (PUMAs).

## Script Descriptions

### 1. `downloadArrestData.R`
   - **Purpose**: Fetches arrest data by age/sex and race for each state from the FBI's Crime Data API.
   - **Key Features**: Utilizes API calls to gather 2022 NIBRS+SRS data, focusing on demographic details.

### 2. `processArrestData.R`
   - **Purpose**: Processes and transforms the downloaded arrest data.
   - **Key Features**: Includes data cleaning, transformation, and preparation for integration with PUMA data.

### 3. `getArrestPUMS.R`
   - **Purpose**: Retrieves PUMS data and integrates it with the arrest data.
   - **Key Features**: Focuses on aligning demographic data from PUMS with arrest records.

### 4. `finalizeArrestData.R`
   - **Purpose**: Distributes the processed arrest data across PUMAs based on demographic proportions and saves the final dataset.
   - **Key Features**: Involves complex calculations to distribute data evenly and accurately across geographical areas.

### 5. `makeArrestMap.R`
   - **Purpose**: Generates preliminary maps visualizing youth arrests by PUMA.
   - **Key Features**: Spatial data processing and visualization.

## Usage

To use these scripts:
1. Ensure all required libraries (as mentioned in each script) are installed in R.
2. Run the scripts in the order listed above for a smooth workflow.
3. Adjust parameters and API keys as necessary.

## Dependencies

- R environment and the following R packages: `dplyr`, `httr`, `jsonlite`, `parallel`, `pbmcapply`,`readr`,`sf`, `tidycensus`, `tigris`,  `tidyverse`
- Access to the FBI's Crime Data API.


## Notes

- These scripts are designed to work together as part of a pipeline. Each script outputs data that serves as input for the next.
- Please refer to the main README for more details on the project scope, data sources, and limitations.
