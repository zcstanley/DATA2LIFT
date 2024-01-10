# README for Foster Youth Data Processing and Analysis

## Overview

This repository contains scripts for processing and analyzing foster youth data in the United States. The project aims to distribute foster youth to Public Use Microdata Areas (PUMAs) based on demographic proportions of age, sex, and race. The data is sourced from the States Adoption and Foster Care Analysis and Reporting System (AFCARS) Reports.

## Contents

- **`Scripts`**: Folder containing scripts for downloading and processing the data. 
- **`Tests`**: Folder containing scripts to test the performance of the data download and processing.
- **`RawData`**: Folder containing data downloaded from the States AFCARS Reports.
- **`ProcessedData`**: Folder containing data after it has undergone some amount of processing. 
- **`Plots`**: Folder containing preliminary maps.
- `README.md`: This file.


## Data Sources and Access

- **AFCARS Reports**: The data originates from AFCARS, which requires states to submit detailed information about children in foster care and those whose adoptions were finalized each fiscal year.
- **Age Range**: In general opportunity youth are between 16 and 24 years of age. Since all states stop foster care by age 21, we look specifically at foster youth between the ages of 16 and 20.
- **State Variation in Foster Care**: There is variability among states in terms of the age at which foster care support ends – about half of the states provide support up to 18 years, while others extend to ages 19 and 20. This variation poses challenges in comparing data across states. 

### Accessing the Data

- The 2022 AFCARS report data is published on the [Children's Bureau website](https://www.acf.hhs.gov/cb/research-data-technology/statistics-research/afcars).

## Limitations

### Race Data in the AFCARS Report

- The race categories in the AFCARS data are limited and may not accurately reflect the full racial diversity of arrestees. Notably, AFCARS does not report race data for youth of Hispanic ethnicity. 

### Mapping to PUMAs

- In the current approach, foster youth are allocated to Public Use Microdata Areas (PUMAs) using data on age, sex, and race. The AFCARS report provides statistics on arrests categorized separately by age, sex, and race. Our methodology is based on the assumption that age, sex, and race are all independent. Consequently, we calculate the fraction of foster youth for each specific category combining age, sex, and race. These calculated fractions are then used to distribute foster youth across PUMAs, in proportion to each PUMA's demographic composition. In instances where certain combinations of age, sex, and race categories are not represented in any PUMA within a particular state, the corresponding foster youth are evenly distributed across all PUMAs in that state. Future work could involve mapping foster youth to PUMAs based on reporting agencies and FIPS codes, though this is a more complex task with its own set of challenges.

## Closing Thoughts

This project uses the AFCARS report data to distribute foster youth to PUMAs using available age/sex/race data. While this approach provides a useful analysis framework, the limitations mentioned above should be carefully considered in any conclusions drawn from the data.
