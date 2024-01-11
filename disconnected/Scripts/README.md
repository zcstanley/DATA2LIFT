# README for the `Scripts` Folder

## Overview

This folder contains R scripts developed for the analysis and visualization of disconnected youth data, using Public Use Microdata Sample (PUMS) data. Disconnected youth are individuals between 16 and 24 years old who are not in school and not employed.

## Contents

1. **`getDisconnectedPUMS.R`**: This script processes PUMS data from the U.S. Census and counts disconnected youth.
2. **`makeDisconnectedMap.R`**: Generates preliminary maps visualizing disconnected youth by PUMA.

## Usage

- To use these scripts, ensure that all `PUMSRawData.Rdata` and `pumaShapes.Rdata` are located in **`RawData`**.
- Run `getDisconnectedPUMS.R` first to process the raw data.
- Follow with `makeDisconnectedMap.R` to generate the visualizations based on the processed data.

## Notes

- These scripts are designed to work together as part of a pipeline. Each script outputs data that serves as input for the next.
- Please refer to the main README for more details on the project scope, data sources, and limitations.