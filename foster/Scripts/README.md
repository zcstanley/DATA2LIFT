# README for the `Scripts` Folder

## Overview

This folder contains a series of R scripts developed for the processing and analysis of foster youth data in the United States. These scripts handle various tasks from downloading data to processing and final distribution of foster youth data to Public Use Microdata Areas (PUMAs).

## Contents

1. **`downloadFosterData.R`**: Fetches foster youth data for each state from the States AFCARS Report.
2. **`scrapeFosterData.R`**: Processes and transforms the downloaded foster youth data.
3. **`getFosterPUMS.R`**: Retrieves PUMS data and integrates it with the foster data.
4. **`finalizeFosterData.R`**: Distributes the processed foster youth data across PUMAs based on demographic proportions and saves the final dataset.
5. **`makeFosterMap.R`**: Generates preliminary maps visualizing foster youth by PUMA.

## Usage

- Ensure all required libraries (as mentioned in each script) are installed in R.
- Run the scripts in the order listed above for a smooth workflow.
- Adjust parameters and API keys as necessary.

## Notes

- These scripts are designed to work together as part of a pipeline. Each script outputs data that serves as input for the next.
- Please refer to the main README for more details on the project scope, data sources, and limitations.
