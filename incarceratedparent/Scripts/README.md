# README for the `Scripts` Folder

## Overview

This folder contains a series of R scripts developed for the estimation of children with a parent incarcerated in state prison in the United States. These scripts handle various tasks from downloading data to processing and distribution of children of prisoners to Public Use Microdata Areas (PUMAs).

## Contents

### Key Files

1. **`downloadSPIData.R`**: Fetches data tables from the BJS report [*Parents in Prison and Their Minor Children: Survey of Prison Inmates, 2016*](https://bjs.ojp.gov/library/publications/parents-prison-and-their-minor-children-survey-prison-inmates-2016).
2. **`downloadNPSData.R`**: Fetches data tables from the BJS report [*Prisoners in 2022 - Statistical Tables*](https://bjs.ojp.gov/library/publications/prisoners-2022-statistical-tables).
3. **`processSPIData.R`**: Formats the downloaded data tables for analysis.
4. **`processNPSData.R`**: Formats the downloaded data tables for analysis.
5. **`getParentPUMS.R`**: Retrieves PUMS data and processes it for integration with the parental incarceration data.
6. **`estimateChildrenPerPrisoner.R`**: Estimates the number of children per state prisoner by parent race and sex. 
6. **`estimatePrisonersByDemographics.R`**: Estimates the number of state prisoners by age, sex, and race in each state. 
6. **`finalizeIncarceratedParentData.R`**: Distributes the processed data across PUMAs based on demographic proportions and saves the final dataset.
7. **`makeIncarceratedParentMap.R`**: Generates preliminary maps visualizing parental incarceration by PUMA.

### Additional Files
- **`downloadNPSData.R`**: Fetches data tables from the [Annie E. Casey Foundation Data Center](https://datacenter.aecf.org/data/tables/9688-children-who-had-a-parent-who-was-ever-incarcerated#detailed/1/any/false/2043,1769,1696,1648,1603/any/18927,18928).
- **`processNSCHData.R`**: Compares two estimates of the number of children with an incarcerated parent. 

## Usage

- Ensure all required libraries (as mentioned in each script) are installed in R.
- Run the key scripts in the order listed above for a smooth workflow.
- Supplemental scripts are provided for additional analysis and are not needed for the primary estimate.

## Notes

- These scripts are designed to work together as part of a pipeline. Each script outputs data that serves as input for the next.
- Please refer to the main README for more details on the project scope, data sources, and limitations.
