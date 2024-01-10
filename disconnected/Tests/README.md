# README for the `Tests` Folder

## Overview

The `Tests` folder contains test scripts specifically designed to assess and ensure the integrity of the PUMS data filtering process.

## Test Script Description

### `getDisconnectedPUMSTest.R`
   - **Purpose**: Performs a series of informal tests on `disconnectedDataByPUMA.Rdata`. The tests are designed to validate various aspects of the data, ensuring its integrity for further analysis.
   - **Tests included**:
     - Data types and structure validation
     - Negative or NaN values check
     - Data filtering and counting accuracy

## Usage

- To run the test script, ensure that the necessary data files (`disconnectedDataByPUMA.Rdata` and `RawData/PUMSRawData.Rdata`) are in the appropriate directories.
- Load the script in R or RStudio and execute it. The script will automatically run all the tests and provide feedback on their success or failure.
- Review the output of each test to confirm the integrity of the processed data or identify any issues that need to be addressed.

## Importance

- These tests are crucial for maintaining the quality and reliability of the analysis.
- Regular execution of these tests is recommended, especially after any data updates or changes to processing scripts.