# README for Foster Youth Data Processing and Analysis

## Overview

This repository contains scripts for processing and analyzing foster youth data in the United States. The project aims to distribute foster youth to Public Use Microdata Areas (PUMAs) based on demographic proportions of age, sex, and race. The foster data is sourced from the States Adoption and Foster Care Analysis and Reporting System (AFCARS) Reports.

## Contents

- **`Scripts`**: Folder containing scripts for downloading and processing the data. 
- **`Tests`**: Folder containing scripts to test the performance of the data download and processing.
- **`RawData`**: Folder containing data downloaded from the States AFCARS Reports.
- **`ProcessedData`**: Folder containing data after it has undergone some amount of processing. 
- **`Plots`**: Folder containing preliminary maps.
- `README.md`: This file.

## Data Sources

### AFCARS Reports
The data originates from AFCARS, which requires states to submit detailed information about children in foster care each fiscal year. In general opportunity youth are between 16 and 24 years of age. Since all states stop foster care by age 21, we look specifically at foster youth between the ages of 16 and 20.

### Census PUMS Data
This project uses American Community Survey (ACS) Public Use Microdata Sample (PUMS) files, produced by the U.S. Census Bureau for demographic analysis. These files consist of untabulated records detailing individual people or housing units. We use 1-year files, which capture a snapshot of data for a single year. The ACS PUMS files include data at various geographic levels, the most detailed of which is Public Use Microdata Areas (PUMAs). These are designated areas with populations of about 100,000 or more, allowing for granular analysis of communities. Our analysis is at the PUMA level. 

### Accessing the Data

- The 2022 AFCARS report data is published on the [Children's Bureau website](https://www.acf.hhs.gov/cb/research-data-technology/statistics-research/afcars).
- The ACS PUMS data is accessed and manipulated using the R package `tidycensus`, which provides a user-friendly interface for interacting with the Census Bureau’s APIs and extracting the required data efficiently.

### Acknowledgements
- This project uses publicly available data on foster youth published in the States AFCARS Report. Funding for the AFCARS Report was provided by the Children’s Bureau, Administration on Children, Youth and Families, Administration for Children and Families, U.S. Department of Health and Human Services.
- This project uses publicly available ACS PUMS data, collected and produced by the U.S. Census Bureau.

## Limitations

### State Variation in Foster Care

- There is variability among states in terms of the age at which foster care support ends – about half of the states provide support up to 18 years, while others extend to ages 19 and 20. This variation poses challenges in comparing data across states. 

### Race Data in the AFCARS Report

- The race categories in the AFCARS data are limited and may not accurately reflect the full racial diversity of youth in foster care. Notably, AFCARS does not report race data for youth of Hispanic ethnicity. 

### Mapping to PUMAs

- In the current approach, foster youth are allocated to Public Use Microdata Areas (PUMAs) using data on age, sex, and race. The AFCARS report provides statistics on youth in foster care categorized separately by age, sex, and race. Our methodology is based on the assumption that age, sex, and race are all independent. Consequently, we calculate the fraction of foster youth for each specific category combining age, sex, and race. These calculated fractions are then used to distribute foster youth across PUMAs, in proportion to each PUMA's demographic composition. In instances where certain combinations of age, sex, and race categories are not represented in any PUMA within a particular state, the corresponding foster youth are evenly distributed across all PUMAs in that state. Future work could involve mapping foster youth to PUMAs based on reporting agencies and FIPS codes, though this is a more complex task with its own set of challenges.
