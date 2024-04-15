# README for the `RawData` Folder

## Overview

The `RawData` folder contains ACS PUMS data files and PUMA shape files. 

## Contents

- **`PUMA_Shapes.shp`**: PUMA shapefile for use in Tableau dashboard.
- **`pumaShapes.Rdata`**: PUMA shapes for use in preliminary plotting routines in R. 
- **`pumsRawData.Rdata`**: PUMS dataset containing selected variables for all surveyed individuals. 

## Data Sources

### Census PUMS Data
This project uses American Community Survey (ACS) Public Use Microdata Sample (PUMS) files, produced by the U.S. Census Bureau for demographic analysis. These files consist of untabulated records detailing individual people or housing units. We use 1-year files, which capture a snapshot of data for a single year. The ACS PUMS files include data at various geographic levels, the most detailed of which is Public Use Microdata Areas (PUMAs). These are designated areas with populations of about 100,000 or more, allowing for granular analysis of communities. Our analysis is at the PUMA level. 

The PUMS data variables used in this project include:
- `AGEP`: Age.
- `ESR`: Recoded employment status.
- `HISP`: Hispanic origin.
- `PUMA`: Public use microdata area code.
- `PWGTP`: Integer weight of person.
- `RAC1P`: Race code.
- `SCH`: School enrollment.
- `SEX`: Sex.
- `ST`: State code based on 2010 Census definitions.

Definitions of all PUMS variables used in 2021 are available in the [PUMS Data Dictionary 2021](https://www2.census.gov/programs-surveys/acs/tech_docs/pums/data_dict/PUMS_Data_Dictionary_2021.pdf).

### Accessing the Data

- The ACS PUMS data is accessed and manipulated using the R package `tidycensus`, which provides a user-friendly interface for interacting with the Census Bureau’s APIs and extracting the required data efficiently.

### Acknowledgements

- This project uses publicly available ACS PUMS data, collected and produced by the U.S. Census Bureau.

