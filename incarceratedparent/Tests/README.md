# README for the `Tests` Folder

## Overview

This folder contains a collection of test scripts designed to ensure the integrity and correctness of the datasets and processing scripts used in the parental incarceration data analysis project. These tests are essential for verifying the reliability of our data processing and analytical methods.

## Contents

- **`downloadNPSDataTest.R`**: Verifies that all expected data files from the BJS report [*Prisoners in 2022 - Statistical Tables*](https://bjs.ojp.gov/library/publications/prisoners-2022-statistical-tables) are successfully downloaded.
- **`downloadSPIDataTest.R`**: Verifies that all expected data files from the BJS report [*Parents in Prison and Their Minor Children: Survey of Prison Inmates, 2016*](https://bjs.ojp.gov/library/publications/parents-prison-and-their-minor-children-survey-prison-inmates-2016) are successfully downloaded.
- **`downloadNSCHDataTest.R`**: Verifies that all expected data files from the [AECF Data Center](https://datacenter.aecf.org/data/tables/9688-children-who-had-a-parent-who-was-ever-incarcerated#detailed/1/any/false/2043,1769,1696,1648,1603/any/18927,18928)
 are successfully downloaded.
- **`test_finalizeIncarceratedParentData.R`**: Verifies the assignment of prisoners to neighborhood clusters.
- **`test_estimateChildrenPerPrisoner.R`**: Assesses the estimation of the number of children with a parent incarcerated in state prison.
- **`test_estimatePrisonersByDemographics.R`**: Assesses the estimation of the number of state prisoners by demographics.
- **`test_getParentPUMS.R`**: Assesses the integrity of the PUMS data integration process.
- **`test_processNPSData.R`**: Assesses the processing of data tables to a long format. 
- **`test_processSPIData.R`**: Assesses the processing of data tables to a long format. 

## Usage

- To run these tests, ensure that all required data files are in the appropriate directories as specified in each test script.
- Execute each test script in R to perform the specified checks.
- Review the output of each test to confirm data integrity or to identify areas needing correction.

## Notes

- These tests are crucial for maintaining the quality and reliability of the analysis.
- Regular execution of these tests is recommended, especially after any data updates or changes to processing scripts.