# README for the `Tests` Folder

## Overview

This folder contains a collection of test scripts designed to ensure the integrity and correctness of the datasets and processing scripts used in the foster youth data analysis project. These tests are essential for verifying the reliability of our data processing and analytical methods.

## Contents

- **`downloadFosterDataTest.R`**: Verifies that all expected arrest data files from the States AFCARS Report are successfully downloaded.
- **`scrapeFosterDataTest.R`**: Checks the processed foster youth data for consistency and accuracy.
- **`getFosterPUMSTest.R`**: Assesses the integrity of the PUMS data integration process.
- **`finalizeFosterDataTest.R`**: Ensures that the final distributed foster youth data aligns with the processed data and maintains data integrity.

## Usage

- To run these tests, ensure that all required data files are in the appropriate directories as specified in each test script.
- Execute each test script in R to perform the specified checks.
- Review the output of each test to confirm data integrity or to identify areas needing correction.

## Notes

- These tests are crucial for maintaining the quality and reliability of the analysis.
- Regular execution of these tests is recommended, especially after any data updates or changes to processing scripts.