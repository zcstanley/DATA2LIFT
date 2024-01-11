# README for the `RawData` Folder

## Overview

The `RawData` folder contains initial datasets downloaded from the FBI's Crime Data API. These datasets offer comprehensive arrest data across the United States, broken down by various demographic categories.

## Contents

- **`ArrestData` Subfolder**: This subfolder stores CSV files with arrest data for each of the 50 U.S. states plus the District of Columbia (DC).

### Contents of the `ArrestData` Subfolder

- **State-Specific Data Files**: For each state (including DC), there are three CSV files, each corresponding to a different category of data:
  - `fbi_arrest_[StateAbbreviation]_female.csv`: Data on female arrests, broken down by age.
  - `fbi_arrest_[StateAbbreviation]_male.csv`: Data on male arrests, broken down by age.
  - `fbi_arrest_[StateAbbreviation]_race.csv`: Data on arrests broken down by race.

  For example, for Alaska, there are the following files:
  - `fbi_arrest_AK_female.csv`
  - `fbi_arrest_AK_male.csv`
  - `fbi_arrest_AK_race.csv`

## Usage

- These raw data files can be downloaded with the `downloadArrestData.R` script located in the `Scripts` folder. Additional scripts are used for subsequent processing and analysis of these datasets.

## Notes

- The dataset is as reported to the FBI and has limitations, such as incomplete reporting from certain regions or agencies.
- For a comprehensive understanding of the data's scope, sources, and limitations, users are advised to refer to the main README file of the project.
