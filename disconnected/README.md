# README for Disconnected Youth Data Processing and Analysis

## Overview

This folder contains scripts for counting and visualizing disconnected youth across the United States, specifically focusing on Public Use Microdata Areas (PUMAs). Disconnected youth are defined as individuals aged 16 to 24 who are neither attending school nor employed. This folder contains scripts, processed data, and visualizations that leverage the U.S. Census Bureau's Public Use Microdata Sample (PUMS) data from 2021.

## Folder Structure

- **`Scripts`**: Contains R scripts for downloading PUMS data and counting disconnected youth.
- **`ProcessedData`**: Includes datasets that have been processed and transformed from their original state. These datasets are used for further analysis and visualization.
- **`Plots`**: Contains preliminary maps and other visualizations of disconnected youth.
- **`Tests`**: Holds scripts for testing the integreity of the data processing.
- **`README.md`**: This file.

## Data Sources and PUMS Variables

The PUMS data variables used in this project include:
- `AGEP`: Age.
- `ESR`: Recoded employment status.
- `PUMA`: Public use microdata area code.
- `PWGTP`: Integer weight of person.
- `SCH`: School enrollment.
- `ST`: State code based on 2010 Census definitions.

Definitions of all PUMS variables used in 2021 are available in the [PUMS Data Dictionary 2021](https://www2.census.gov/programs-surveys/acs/tech_docs/pums/data_dict/PUMS_Data_Dictionary_2021.pdf).

## Usage

- To utilize the content of this folder, start with the `Scripts` to process the raw data. 
- Analyze and visualize the data using the files in the `ProcessedData` and `Plots` folders.
- The `Tests` folder contains scripts to validate the integrity of the processed data.

## Limitations

- Reliance on PUMS Data: While PUMS provides a rich dataset, it is a sample and not an exhaustive enumeration. This may lead to limitations in capturing the complete picture of disconnected youth.
- Geographic Limitations: The study focuses on PUMAs, which may not fully represent smaller or more localized variations in the distribution of disconnected youth.
