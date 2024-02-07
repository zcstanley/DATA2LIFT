# README for the `RawData` Folder

## Overview

The `RawData` folder contains data sourced from two major programs: the Survey of Prison Inmates (SPI) and the National Prisoner Statistics (NPS) program. Each subfolder contains the unzipped contents of the respective data files and a readme file from the Bureau of Justice Statistics (BJS). Relevant data tables are reformatted for analysis and stored in `.Rdata` files.  

## Contents

### Downloaded data subfolders
- **`SPI` Subfolder**:
  - Contains data from the Survey of Prison Inmates (SPI).
  - Files store data for tables, figures, and other resources from the BJS report [*Parents in Prison and Their Minor Children: Survey of Prison Inmates, 2016*](https://bjs.ojp.gov/library/publications/parents-prison-and-their-minor-children-survey-prison-inmates-2016) by Maruschak and Bronson (2021).
- **`NPS` Subfolder**:
  - Contains data from the National Prisoner Statistics (NPS) program.
  - Files store data for tables, figures, and other resources from the BJS report [*Prisoners in 2022 - Statistical Tables*](https://bjs.ojp.gov/library/publications/prisoners-2022-statistical-tables) by Carson and Kluckow (2023).

### Reformatted data files
- **`childAgeData.Rdata`**: Contains data on percent of children with an incarcerated parent by age of child. 
- **`childrenByParentSexData.Rdata`**: Contains data on children with an incarcerated parent by sex of parent. 
- **`incarceratedParentPercentData.Rdata`**: Contains data on percent of state prisoners who are a parent. 
- **`numPrisoners2016Data.Rdata`**: Contains data on the number of state prisoners in 2016. 
- **`prisonersByAgeSexRace.Rdata`**: Contains data on the number of state prisoners in 2022 by age, sex, and race. 
- **`prisonersByStateRace.Rdata`**: Contains data on the number of state prisoners in 2022 by race in each state. 
- **`prisonersByStateSex.Rdata`**: Contains data on the number of state prisoners in 2022 by sex in each state. 
- **`nsch_data.xlsx`**: Contains data downloaded from the [Annie E. Casey Foundation Data Center](https://datacenter.aecf.org/data/tables/9688-children-who-had-a-parent-who-was-ever-incarcerated#detailed/1/any/false/2043,1769,1696,1648,1603/any/18927,18928). 

## Usage

- The data files within the `SPI` and `NPS` subfolders are used as primary sources for research, analysis, and reporting on the children of incarcerated parents. They are processed through various scripts in the `Scripts` folder to extract and analyze relevant data.
- Users are referred to the individual readme files in each subfolder for a thorough understanding of the available data.

## Notes

- The data in the `NPS` subfolder is sourced from the Bureau of Justice Statistics' National Prisoner Statistics program, as detailed in the publication ["Prisoners in 2022 – Statistical Tables"](https://bjs.ojp.gov/library/publications/prisoners-2022-statistical-tables).
- The `SPI` subfolder contains data from the Survey of Prison Inmates, referenced in the Bureau of Justice Statistics' publication ["Parents in Prison and Their Minor Children: Survey of Prison Inmates, 2016"](https://bjs.ojp.gov/library/publications/parents-prison-and-their-minor-children-survey-prison-inmates-2016).
