# README for Parental Incarceration Data Processing and Analysis

## Overview

This repository contains scripts for processing and analyzing parental incarceration rates in the United States. The project aims to distribute children with an incarcerated parent to Public Use Microdata Areas (PUMAs) based on demographic proportions of age, sex, and race. The data are sourced from BJS reports. 

## Contents

- **`Scripts`**: Folder containing scripts for downloading and processing the data. 
- **`Tests`**: Folder containing scripts to test the performance of the data download and processing.
- **`RawData`**: Folder containing data downloaded from two BJS reports.
- **`ProcessedData`**: Folder containing data after it has undergone some amount of processing. 
- **`Plots`**: Folder containing preliminary maps.

## Data Sources

### Parents in Prison Report (2021)
The [*Parents in Prison and Their Minor Children: Survey of Prison Inmates, 2016*](https://bjs.ojp.gov/library/publications/parents-prison-and-their-minor-children-survey-prison-inmates-2016) report, produced by the Bureau of Justice Statistics (BJS), offers a comprehensive analysis of the prevalence of incarcerated parents and the impact on their minor children. Key aspects of the report include:
- **Survey Data**: The report is based on data from the Survey of Prison Inmates (SPI) conducted in 2016, providing insights into the demographics and family circumstances of incarcerated individuals.
- **Statistical Breakdown**: The data is broken down by various demographics, including race, ethnicity, and gender of the incarcerated parent, offering a nuanced view of how parental incarceration affects different communities.

### Prisoners in 2022 – Statistical Tables
The  [*Prisoners in 2022 - Statistical Tables*](https://bjs.ojp.gov/library/publications/prisoners-2022-statistical-tables) report, also from the Bureau of Justice Statistics, provides detailed statistical tables concerning the inmate population in state and federal prisons. Highlights of this report include:
- **Annual Overview**: The report offers an annual snapshot of the prisoner population, tracking changes in the number and characteristics of inmates.
- **Demographic Data**: It includes detailed breakdowns by race, sex, and jurisdiction offering a comprehensive overview of the U.S. prison population.

### Census PUMS Data
This project uses American Community Survey (ACS) Public Use Microdata Sample (PUMS) files, produced by the U.S. Census Bureau for demographic analysis. These files consist of untabulated records detailing individual people or housing units. We use 1-year files, which capture a snapshot of data for a single year. The ACS PUMS files include data at various geographic levels, the most detailed of which is Public Use Microdata Areas (PUMAs). These are designated areas with populations of about 100,000 or more, allowing for granular analysis of communities. Our analysis is at the PUMA level. 

### Accessing the Data

- Data tables from the BJS reports are downloaded directly from the report websites: [*Parents in Prison*](https://bjs.ojp.gov/library/publications/parents-prison-and-their-minor-children-survey-prison-inmates-2016) and  [*Prisoners in 2022*](https://bjs.ojp.gov/library/publications/prisoners-2022-statistical-tables). 
- The ACS PUMS data is accessed and manipulated using the R package `tidycensus`, which provides a user-friendly interface for interacting with the Census Bureau’s APIs and extracting the required data efficiently.

### Acknowledgements

- This project uses publicly available summary incarceration data compiled by the BJS. 
- This project uses publicly available ACS PUMS data, collected and produced by the U.S. Census Bureau.

## Usage

- To utilize the content of this folder, start with the `Scripts` to process the raw data. 
- Analyze and visualize the data using the files in the `ProcessedData` and `Plots` folders.
- The `Tests` folder contains scripts to validate the integrity of the processed data.

## Limitations

### Narrow Scope of the Estimate
- This analysis estimates only the number of children (aged 15-17) who have a parent who is currently incarcerated in state prison. Parents who are incarcerated in federal prison and those serving shorter sentences in local jails are not considered. The impact of parental incarceration is likely much larger, affecting youth who have ever had a parental figure or guardian who is incarcerated. 

### Race Data in NIBRS+SRS

- The race categories are not consistent across BJS data tables and may not accurately reflect the full racial diversity of incarcerated parents. Notably, certain BJS tables lack a "Multiracial" category, which is present in other BJS tables and PUMS data. Consequently, children of incarcerated parents of multiracial identity are likely inaccurately allocated. Furthermore, the data provides no practical information on the ethnicity of incarcerated parents, presenting another limitation in demographic representation.

### Mapping to PUMAs

- In the current approach, children with an incarcerated parent are allocated to Public Use Microdata Areas (PUMAs) using data on age, sex, and race. The BJS Data provides statistics on incarcerated parents categorized by sex and race. Our methodology is based on the assumption that race is independent sex. ate. This simplification overlooks any potential interactions between race and gender that may exist in the prison population, possibly leading to an inaccurate representation of the demographic makeup of incarcerated parents. We calculate the fraction of incarcerated parents for each sex and race grouping. These calculated fractions are then used to distribute incarcerated parents across PUMAs, in proportion to each PUMA's demographic composition. In instances where certain combinations of sex and race categories are not represented in any PUMA within a particular state, the corresponding incarcerated parents are evenly distributed across all PUMAs in that state. 
