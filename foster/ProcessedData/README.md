# README for the `ProcessedData` Folder

## Overview

The `ProcessedData` folder contains datasets that have been processed and transformed from their original state. These datasets are used to analyze and understand foster youth patterns in the United States and their distribution across Public Use Microdata Areas (PUMAs).

## Key Files in the Folder

### 1. **`fosterDataByPUMA.csv`**
   - This CSV file includes estimated foster distribution data, structured with the following columns:
     - `state`: Two-letter state postal code.
     - `PUMA`: Public Use Microdata Area ID, unique within each state.
     - `count`: Estimated number of foster youth (aged 16-20) in the PUMA.
     - `foster_per_pop`: Estimated foster youth per 1,000 residents aged 16-20.
     - `foster_density`: Estimated foster youth per square kilometer.

### 2. **`fosterDataByPUMA.Rdata`**
   - A similar dataset to the CSV file, but in Rdata format and includes spatial data for PUMA shapes.

### 3. **`fosterMetadata.json`**
   - Provides metadata for the CSV file, offering additional context and information about the foster youth data.

### Additional Data Files

#### 4. **`scrapedFosterData.Rdata`**
   - Contains combined age, sex, and race proportions for each state. This file is produced during one of the analysis steps.

#### 5. **`pumsData.Rdata`**
   - Holds the count of age, sex, and race categories in each PUMA. The race data has been recoded to align with the AFCARS race categories, facilitating a more accurate analysis.
   
#### 6. **`pumsShapes.Rdata`**
   - Holds the shapes of each PUMA. 

## Usage

- These processed datasets are designed for analysis and visualization tasks.
- The `fosterDataByPUMA.csv` and `.Rdata` files are particularly useful for spatial analysis and mapping.
- The `scrapedFosterData.Rdata` and `pumsData.Rdata` are produced during the analysis pipeline and are then used to produce the `fosterDataByPUMA` files.

## Notes

- For a comprehensive understanding of the data's scope, sources, and limitations, users are advised to refer to the main README file of the project.
- For details on the processing steps and methodologies, refer to the scripts in the `Scripts` folder.
