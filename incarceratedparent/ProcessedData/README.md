# README for the `ProcessedData` Folder

## Overview

The `ProcessedData` folder contains datasets that have been processed and transformed from their original state. These datasets are used to analyze and understand parental incarceration patterns in the United States and their distribution across Public Use Microdata Areas (PUMAs).

## Contents

### Key Files

- **`incarceratedParentDataByPUMA.csv`**: This CSV file includes detailed data on the number of children with an incarcerated parent, structured with the following columns:
     - `state`: Two-letter state postal code.
     - `PUMA`: Public Use Microdata Area ID, unique within each state.
     - `count`: Estimated number of children (aged 15-17) with a parent incarcerated in state prison by PUMA.
     - `incarcerated_parent_per_pop`: Estimated children with an incarcerated parent per 1,000 residents aged 15-17.
     - `incarcerated_parent_density`: Estimated children with an incarcerated parent per square kilometer.
- **`incarceratedParentDataByPUMA.Rdata`**: A similar dataset to the CSV file, but in Rdata format and includes spatial data for PUMA shapes.
- **`incarceratedParentMetadata.json`**: Provides metadata for the CSV file.

### Additional Files

- **`olderChildrenPerPrisoner.Rdata`**: Contains estimates of the number of children per state prisoner by sex and race of the parent. This file is produced during one of the analysis steps.
- **`prisonersByStateAgeSexRace.Rdata`**: Contains estimates of the number state prisoners by age, sex and race in each state. This file is produced during one of the analysis steps.
- **`pumsData.Rdata`**: Holds the count of age, sex, and race categories in each PUMA. The race data has been recoded to align with the BJS race categories, facilitating a more accurate analysis.

## Usage

- These processed datasets are designed for analysis and visualization tasks.
- The `incarceratedParentDataByPUMA.csv` and `.Rdata` files are particularly useful for spatial analysis and mapping.
- The `olderChildrenPerPrisoner.Rdata`, `prisonersByStateAgeSexRace.Rdata`, and `pumsData.Rdata` are produced during the analysis pipeline and are then used to produce the `incarceratedParentDataByPUMA` files.

## Notes

- For a comprehensive understanding of the data's scope, sources, and limitations, users are advised to refer to the main README file of the project.
- For details on the processing steps and methodologies, refer to the scripts in the `Scripts` folder.
