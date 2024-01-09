# README for Arrest Data Processing and Analysis

## Overview

This repository contains scripts for processing and analyzing arrest data in the United States. The project aims to distribute youth arrests to Public Use Microdata Areas (PUMAs) based on demographic proportions of age, sex, and race. The data is sourced from the FBI's Crime Data API, utilizing the 2022 NIBRS (National Incident-Based Reporting System) and SRS (Summary Reporting System) datasets.

## Contents


- **Scripts**: Folder containing scripts for downloading and processing the data. 
- **Tests**: Folder containing scripts to test the performance of the data download and processing.
- **RawData**: Folder containing data downloaded from the FBI's Crime Data API.
- **ProcessedData**: Folder containing data after it has undergone some amount of processing. 
- **Plots**: Folder containing preliminary maps.
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

- **UCR Data**: The UCR (Uniform Crime Reporting Program) provided summary arrest data until Jan. 1, 2021. Because of the 2020 pandemic, the 2019 data is the last relevant UCR dataset.
- **NIBRS Data**: Post-2021, the FBI transitioned to NIBRS, offering more detailed data. The 2022 dataset combines NIBRS and SRS data for comprehensive coverage.

### Accessing the Data

- The 2022 NIBRS+SRS data is accessed using the [FBI's Crime Data API](https://cde.ucr.cjis.gov/LATEST/webapp/#/pages/docApi).

## Limitations

### Missing Data

- Some agencies, like the NYPD, do not report arrest data, leading to significant missing data. This limitation should be considered when interpreting results. In 2022, the FBI estimated that they collected NIBRS data from agencies representing 76.9% of the US and SRS data from agencies representing 16.6% of the US. In total, NIBRS+SRS provided 93.5% coverage in 2022.

### Race Data in NIBRS+SRS

- The race categories in the NIBRS+SRS data are limited and may not accurately reflect the full racial diversity of arrestees.

### Mapping to PUMAs

- Currently, arrests are distributed to PUMAs based on age, sex, and the available race data. Future work could involve mapping arrests to PUMAs based on reporting agencies and FIPS codes, though this is a more complex task with its own set of challenges.

## Closing Thoughts

This project uses the 2022 NIBRS+SRS data, ignoring missing values, to distribute youth arrests to PUMAs using available age/sex/race data. While this approach provides a useful analysis framework, the limitations mentioned above should be carefully considered in any conclusions drawn from the data.

---

For further details on the scripts, their usage, and any specific requirements or dependencies, please refer to the individual script files.