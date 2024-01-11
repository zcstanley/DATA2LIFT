# README for the `ProcessedData` Folder

## Overview

The `ProcessedData` folder contains datasets that have been processed and transformed from their original state. These datasets are used to analyze and understand youth arrest patterns in the United States and their distribution across Public Use Microdata Areas (PUMAs).

## Contents

### Key Files

- **`arrestDataByPUMA.csv`**: This CSV file includes detailed arrest data, structured with the following columns:
     - `state`: Two-letter state postal code.
     - `PUMA`: Public Use Microdata Area ID, unique within each state.
     - `count`: Estimated number of youth arrests (aged 16-24) in the PUMA.
     - `arrest_per_pop`: Estimated youth arrests per 1,000 residents aged 16-24.
     - `arrest_density`: Estimated youth arrests per square kilometer.
- **`arrestDataByPUMA.Rdata`**: A similar dataset to the CSV file, but in Rdata format and includes spatial data for PUMA shapes.
- **`arrestMetadata.json`**: Provides metadata for the CSV file, offering additional context and information about the arrest data.

### Additional Files

- **`processedArrestData.Rdata`**: Contains combined age, sex, and race proportions for each state. This file is produced during one of the analysis steps.
- **`pumsData.Rdata`**: Holds the count of age, sex, and race categories in each PUMA. The race data has been recoded to align with the FBI's race categories, facilitating a more accurate analysis.

## Usage

- These processed datasets are designed for analysis and visualization tasks.
- The `arrestDataByPUMA.csv` and `.Rdata` files are particularly useful for spatial analysis and mapping.
- The `processedArrestData.Rdata` and `pumsData.Rdata` are produced during the analysis pipeline and are then used to produce the `arrestDataByPUMA` files.

## Notes

- For a comprehensive understanding of the data's scope, sources, and limitations, users are advised to refer to the main README file of the project.
- For details on the processing steps and methodologies, refer to the scripts in the `Scripts` folder.
