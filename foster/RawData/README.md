# README for the `RawData` Folder

## Overview

The `RawData` folder contains PDF files sourced from the Adoption and Foster Care Analysis and Reporting System (AFCARS) for the Fiscal Year 2021. It also contains `.Rdata` files which hold data scraped from the AFCARS PDFs.

## Contents

### `pdf` Subfolder
- **Contents**: 
  - Contains a PDF file for each of the 50 states plus the District of Columbia (DC).
- **File Naming**: 
  - The files are named using two-letter lowercase postal codes for each state, e.g., `ak.pdf` for Alaska.
- **Data Source**: 
  - The PDF files are from The States AFCARS Report.

### Data Files
- **`scrapedAgeData.Rdata`**:
  - Description: Foster youth data broken down by age and state.
  - Source: Data scraped directly from the PDF files.
  
- **`scrapedRaceData.Rdata`**:
  - Description: Foster youth data broken down by race and state.
  - Source: Data scraped directly from the PDF files.
  
- **`scrapedSexData.Rdata`**:
  - Description: Foster youth data broken down by sex and state.
  - Source: Data scraped directly from the PDF files.
  
- **`scrapedTotalData.Rdata`**:
  - Description: Total count of foster youth by state.
  - Source: Data scraped directly from the PDF files.


## AFCARS Report Overview

- **Data Collection Requirement**: Under the final AFCARS rule, states are required to collect data on all children in foster care under the state child welfare agency’s responsibility, regardless of eligibility for Title IV-E funds. The data are reported to the Children’s Bureau. Funding for the AFCARS Report was provided by the Children’s Bureau, Administration on Children, Youth and Families, Administration for Children and Families, U.S. Department of Health and Human Services.
- **Reporting Period**: The data encompasses information for children in the foster care system and those whose adoptions were finalized during the federal fiscal year, extending from October 1 to September 30 of the following year. States submit their adoption and foster care data electronically to the Children’s Bureau at the close of two semi-annual reporting periods (October 1 - March 31 and April 1 - September 30).


### Reporting Population
- **Scope**: The dataset includes children under the responsibility of state child welfare agencies, including those on runaway status or with unknown locations, as well as children under the responsibility of other public agencies but receiving Title IV-E foster care payments.
- **Eligibility**: The dataset covers children whose removal episode is more than 24 hours and includes those under interagency agreements, such as with juvenile justice or tribal agencies.

## Usage

- The PDF files in this folder are used as the primary data source for analyzing foster care trends. They are processed through various scripts in the `Scripts` folder to extract and analyze relevant data.

