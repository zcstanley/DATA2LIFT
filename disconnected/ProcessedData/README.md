# README for the `ProcessedData` Folder

## Overview

The `ProcessedData` folder contains datasets that have been processed and transformed from their original state. These datasets are used to analyze and understand disconnected youth patterns in the United States and their distribution across Public Use Microdata Areas (PUMAs).

## Key Files in the Folder

### 1. **`disconnectedDataByPUMA.csv`**
   - This CSV file includes data on disconnected youth, structured with the following columns:
     - `state`: Two-letter state postal code.
     - `PUMA`: Public Use Microdata Area ID, unique within each state.
     - `count`: Estimated number of disconnected youth (aged 16-24) in the PUMA.
     - `disconnected_per_pop`: Estimated number of disconnected youth per 1,000 residents aged 16-24.
     - `disconnected_density`: Estimated number of disconnected youth per square kilometer.

### 2. **`disconnectedDataByPUMA.Rdata`**
   - A similar dataset to the CSV file, but in Rdata format and includes spatial data for PUMA shapes.

### 3. **`disconnectedMetadata.json`**
   - Provides metadata for the CSV file, offering additional context and information about the disconnected youth data.


## Usage

- These processed datasets are designed for analysis and visualization tasks.


## Notes

- For a comprehensive understanding of the data's scope, sources, and limitations, users are advised to refer to the main README file of the project.
- For details on the processing steps and methodologies, refer to the scripts in the `Scripts` folder.
