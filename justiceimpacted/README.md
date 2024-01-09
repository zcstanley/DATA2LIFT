# README for Youth Arrest Data Processing and Analysis

## Overview

This repository contains scripts for processing and analyzing arrest data in the United States. The project aims to distribute youth arrests to Public Use Microdata Areas (PUMAs) based on demographic proportions of age, sex, and race. The data is sourced from the FBI's Crime Data API, utilizing the 2022 NIBRS (National Incident-Based Reporting System) and SRS (Summary Reporting System) datasets.

## Contents

- **`Scripts`**: Folder containing scripts for downloading and processing the data. 
- **`Tests`**: Folder containing scripts to test the performance of the data download and processing.
- **`RawData`**: Folder containing data downloaded from the FBI's Crime Data API.
- **`ProcessedData`**: Folder containing data after it has undergone some amount of processing. 
- **`Plots`**: Folder containing preliminary maps.
- `README.md`: This file.

### Contents of the `Scripts` Folder

- `downloadArrestData.R`: Fetches arrest data by age/sex and age/race for each state.
- `processArrestData.R`: Processes and transforms the arrest data.
- `getArrestPUMS.R`: Retrieves PUMS data to integrate with arrest data.
- `finalizeArrestData.R`: Distributes arrest data to PUMAs and saves the final dataset.
- `makeArrestMap.R`: Makes maps of youth arrests by PUMA.

### Selected Contents of the `ProcessedData` Folder

- **`arrestDataByPUMA.csv`**: This CSV file contains detailed arrest data with the following columns:
  - `state`: Two-letter state postal code.
  - `PUMA`: Public Use Microdata Area ID (unique within each state).
  - `count`: Estimate of youth arrests (aged 16-24) in the PUMA.
  - `arrest_per_pop`: Estimate of youth arrests per 1,000 residents aged 16-24.
  - `arrest_density`: Estimate of youth arrests per square kilometer.

- **`arrestDataByPUMA.Rdata`**: Similar to the CSV file, but includes spatial data for PUMA shapes.

- **`arrestMetadata.json`**: Metadata file for the CSV, providing additional context and information about the data.


## Data Sources and Access

### NIBRS vs. SRS

- **UCR Data**: The UCR (Uniform Crime Reporting Program) provided summary arrest data until Jan. 1, 2021. This data is also known as SRS (Summary Reporting System). The last relevant dataset from UCR is from 2019, as the data from 2020 was heavily impacted by the pandemic.
- **NIBRS Data**: Since 2021, the FBI has transitioned to NIBRS, which offers more detailed data. However, in its initial year, there was low participation from agencies. In 2022 the FBI reintroduced the acceptance of SRS data alongside NIBRS for more comprehensive coverage. 


### Accessing the Data

- The 2022 NIBRS+SRS data is accessed using the [FBI's Crime Data API](https://cde.ucr.cjis.gov/LATEST/webapp/#/pages/docApi).

## Limitations

### Missing Data

- Some agencies, like the NYPD, do not report arrest data, leading to significant missing data. This limitation should be considered when interpreting results. In 2022, the FBI estimated that they collected NIBRS data from agencies representing 76.9% of the US and SRS data from agencies representing 16.6% of the US. In total, NIBRS+SRS provided 93.5% coverage in 2022.

### Race Data in NIBRS+SRS

- The race categories in the NIBRS+SRS data are limited and may not accurately reflect the full racial diversity of arrestees. Notably, the FBI's classification lacks a "Multiracial" category, which is present in PUMS data. Consequently, arrests involving individuals of multiracial identity are likely inaccurately allocated. Furthermore, the data provides no practical information on the ethnicity of arrestees, presenting another limitation in demographic representation.

### Mapping to PUMAs

- In the current approach, arrests are allocated to Public Use Microdata Areas (PUMAs) using data on age, sex, and race. The FBI's Crime Data API provides statistics on arrests categorized by age and sex, as well as by race. Our methodology is based on the assumption that race is independent of age and sex. Consequently, we calculate the fraction of arrests for each specific category combining age, sex, and race. These calculated fractions are then used to distribute arrests across PUMAs, in proportion to each PUMA's demographic composition. In instances where certain combinations of age, sex, and race categories are not represented in any PUMA within a particular state, the corresponding arrests are evenly distributed across all PUMAs in that state. Future work could involve mapping arrests to PUMAs based on reporting agencies and FIPS codes, though this is a more complex task with its own set of challenges.

## Closing Thoughts

This project uses the FBI's 2022 NIBRS+SRS data, ignoring missing values, to distribute youth arrests to PUMAs using available age/sex/race data. While this approach provides a useful analysis framework, the limitations mentioned above should be carefully considered in any conclusions drawn from the data.
