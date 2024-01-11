# README for the `Scripts` Folder

## Overview

This folder contains a series of R scripts developed for the processing and analysis of youth arrest data in the United States. These scripts handle various tasks from downloading data to processing and final distribution of arrest data to Public Use Microdata Areas (PUMAs).

## Contents

1. **`downloadArrestData.R`**: Fetches arrest data by age/sex and race for each state from the FBI's Crime Data API.
2. **`processArrestData.R`**: Processes and transforms the downloaded arrest data.
3. **`getArrestPUMS.R`**: Retrieves PUMS data and processes it for integration with the arrest data.
4. **`finalizeArrestData.R`**: Distributes the processed arrest data across PUMAs based on demographic proportions and saves the final dataset.
5. **`makeArrestMap.R`**: Generates preliminary maps visualizing youth arrests by PUMA.

## Usage

- Ensure all required libraries (as mentioned in each script) are installed in R.
- Run the scripts in the order listed above for a smooth workflow.
- Adjust parameters and API keys as necessary.

## Notes

- These scripts are designed to work together as part of a pipeline. Each script outputs data that serves as input for the next.
- Please refer to the main README for more details on the project scope, data sources, and limitations.
