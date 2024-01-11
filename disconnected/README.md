# README for Disconnected Youth Data Processing and Analysis

## Overview

This folder contains scripts for counting and visualizing disconnected youth across the United States, specifically focusing on Public Use Microdata Areas (PUMAs). Disconnected youth are defined as individuals aged 16 to 24 who are neither attending school nor employed. This folder contains scripts, processed data, and visualizations that leverage the U.S. Census Bureau's Public Use Microdata Sample (PUMS) data from 2021.

## Contents

- **`Scripts`**: Contains R scripts for downloading PUMS data and counting disconnected youth.
- **`ProcessedData`**: Includes datasets that have been processed and transformed from their original state. These datasets are used for further analysis and visualization.
- **`Plots`**: Contains preliminary maps and other visualizations of disconnected youth.
- **`Tests`**: Holds scripts for testing the integreity of the data processing.
- `README.md`: This file.

## Data Sources

### Census PUMS Data
This project uses American Community Survey (ACS) Public Use Microdata Sample (PUMS) files, produced by the U.S. Census Bureau for demographic analysis. These files consist of untabulated records detailing individual people or housing units. We use 1-year files, which capture a snapshot of data for a single year. The ACS PUMS files include data at various geographic levels, the most detailed of which is Public Use Microdata Areas (PUMAs). These are designated areas with populations of about 100,000 or more, allowing for granular analysis of communities. Our analysis is at the PUMA level. 

The PUMS data variables used in this project include:
- `AGEP`: Age.
- `ESR`: Recoded employment status.
- `PUMA`: Public use microdata area code.
- `PWGTP`: Integer weight of person.
- `SCH`: School enrollment.
- `ST`: State code based on 2010 Census definitions.

Definitions of all PUMS variables used in 2021 are available in the [PUMS Data Dictionary 2021](https://www2.census.gov/programs-surveys/acs/tech_docs/pums/data_dict/PUMS_Data_Dictionary_2021.pdf).

### Accessing the Data

- The ACS PUMS data is accessed and manipulated using the R package `tidycensus`, which provides a user-friendly interface for interacting with the Census Bureau’s APIs and extracting the required data efficiently.

### Acknowledgements

- This project uses publicly available ACS PUMS data, collected and produced by the U.S. Census Bureau.

## Usage

- To utilize the content of this folder, start with the `Scripts` to process the raw data. 
- Analyze and visualize the data using the files in the `ProcessedData` and `Plots` folders.
- The `Tests` folder contains scripts to validate the integrity of the processed data.

## Limitations

- **Reliance on PUMS Data**: While PUMS provides a rich dataset, it is a sample and not an exhaustive enumeration. This may lead to limitations in capturing the complete picture of disconnected youth.
- **Geographic Limitations**: The study focuses on PUMAs, which may not fully represent smaller or more localized variations in the distribution of disconnected youth.
