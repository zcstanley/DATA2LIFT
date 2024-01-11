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

## Data Sources

### FBI Arrests Data

This project utilizes two distinct FBI data sources, which have been aggregated by the FBI to provide an overview of arrest data for each state in the United States. The two reporting formats used by local law enforcement agencies are:

- **SRS Data**: The UCR (Uniform Crime Reporting Program) provided summary arrest data until Jan. 1, 2021. This data is also known as SRS (Summary Reporting System). The last relevant dataset from UCR is from 2019, as the data from 2020 was heavily impacted by the pandemic.
- **NIBRS Data**: Since 2021, the FBI has transitioned to NIBRS, which offers more detailed data. However, in its initial year, there was low participation from agencies. In 2022 the FBI reintroduced the acceptance of SRS data alongside NIBRS for more comprehensive coverage. 

### Census PUMS Data
This project uses American Community Survey (ACS) Public Use Microdata Sample (PUMS) files, produced by the U.S. Census Bureau for demographic analysis. These files consist of untabulated records detailing individual people or housing units. We use 1-year files, which capture a snapshot of data for a single year. The ACS PUMS files include data at various geographic levels, the most detailed of which is Public Use Microdata Areas (PUMAs). These are designated areas with populations of about 100,000 or more, allowing for granular analysis of communities. Our analysis is at the PUMA level. 


### Accessing the Data

- The 2022 NIBRS+SRS data is accessed using the [FBI's Crime Data API](https://cde.ucr.cjis.gov/LATEST/webapp/#/pages/docApi). The same data are available to view on the [FBI's Crime Data Explorer](https://cde.ucr.cjis.gov/LATEST/webapp/#/pages/explorer/crime/arrest).
- The ACS PUMS data is accessed and manipulated using the R package `tidycensus`, which provides a user-friendly interface for interacting with the Census Bureau’s APIs and extracting the required data efficiently.

### Acknowledgements

- This project uses publicly available state-level summary arrest data compiled by the FBI. The data were collected by local law enforcement agencies and voluntarily submitted to the FBI.
- This project uses publicly available ACS PUMS data, collected and produced by the U.S. Census Bureau.

## Usage

- To utilize the content of this folder, start with the `Scripts` to process the raw data. 
- Analyze and visualize the data using the files in the `ProcessedData` and `Plots` folders.
- The `Tests` folder contains scripts to validate the integrity of the processed data.

## Limitations

### Missing Arrest Data

- Some agencies, for example the NYPD, do not report arrest data, leading to significant missing data. This limitation should be considered when interpreting results. In 2022, the FBI estimated that they collected NIBRS data from agencies representing 76.9% of the US and SRS data from agencies representing 16.6% of the US. In total, NIBRS+SRS provided 93.5% coverage in 2022.

### Race Data in NIBRS+SRS

- The race categories in the NIBRS+SRS data are limited and may not accurately reflect the full racial diversity of arrestees. Notably, the FBI's classification lacks a "Multiracial" category, which is present in PUMS data. Consequently, arrests involving individuals of multiracial identity are likely inaccurately allocated. Furthermore, the data provides no practical information on the ethnicity of arrestees, presenting another limitation in demographic representation.

### Mapping Arrests to PUMAs

- In the current approach, arrests are allocated to Public Use Microdata Areas (PUMAs) using data on age, sex, and race. The FBI's Crime Data provides statistics on arrests categorized by age and sex, as well as by race. Our methodology is based on the assumption that race is independent of age and sex. Consequently, we calculate the fraction of arrests for each specific category combining age, sex, and race. These calculated fractions are then used to distribute arrests across PUMAs, in proportion to each PUMA's demographic composition. In instances where certain combinations of age, sex, and race categories are not represented in any PUMA within a particular state, the corresponding arrests are evenly distributed across all PUMAs in that state. Future work could involve mapping arrests to PUMAs based on reporting agencies and FIPS codes, though this is a more complex task with its own set of challenges.
