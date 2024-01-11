# README for the `Tests` Folder

## Overview

This folder contains a collection of test scripts designed to ensure the integrity and correctness of the datasets and processing scripts used in the youth arrest data analysis project. These tests are essential for verifying the reliability of our data processing and analytical methods.

## Contents

- **`downloadArrestDataTest.R`**: Verifies that all expected arrest data files from the FBI's Crime Data API are successfully downloaded.
- **`processArrestDataTest.R`**: Checks the processed arrest data for consistency and accuracy.
- **`getArrestPUMSTest.R`**: Assesses the integrity of the PUMS data integration process.
- **`finalizeArrestDataTest.R`**: Verifies that the final distributed arrest data aligns with the processed data and maintains data integrity.


## Usage

- To run these tests, ensure that all required data files are in the appropriate directories as specified in each test script.
- Execute each test script in R to perform the specified checks.
- Review the output of each test to confirm data integrity or to identify areas needing correction.

## Notes

- These tests are crucial for maintaining the quality and reliability of the analysis.
- Regular execution of these tests is recommended, especially after any data updates or changes to processing scripts.