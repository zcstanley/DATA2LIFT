# README for DATA2LIFT Repo

## Overview

This repository is a part of  QSIDE’s *Data for Accountability, Transparency, and Advancement to Lower Incarceration for Transformation* (DATA2LIFT) initiative. As a part of the DATA2LIFT initiative, QSIDE set out to map indicator variables used to determine Opportunity Youth to a common spatial scale at the neighborhood cluster level. The goal is an interactive product that community based organizations (CBOs) can use to locate areas with large populations of opportunity youth. QSIDE is aware of five key variables for opportunity youth: 1) disconnected youth, 2) youth in foster care, 3) justice impacted youth, 4) parental incarceration, and 5) human trafficked youth. We have determined that the data on human trafficking remains too sparse to come to any good estimates of youth who have been trafficked. Thus we will focus on the remaining 4 factors. Briefly, disconnected youth are individuals between the ages of 16 and 24 who are not in school and are not employed. For youth in foster care, we consider children between the ages of 16 and 20 who are under the responsibility of state child welfare agencies and children under the responsibility of other public agencies who receive Title IV-E foster care payments. Justice impacted youth are individuals aged 16 to 24 who have been involved in the justice system at any level, ranging from a single arrest to juvenile incarceration. While there is no good data source tracking justice impacted youth at the individual level, there is comprehensive data on youth arrests. Thus, we choose to track youth arrests as a proxy for the number of justice impacted youth in a given geographic area. Note that our data source does not account for multiple arrests, so that a single individual may appear multiple times in the arrest data. Thus, the arrests are likely an overestimate of the number of individuals who were arrested in a given year. We compute a point-in-time estimate for the number of children who have a parent who is incarcerated in state prison. We do not consider parents who are incarcerated in federal prisons or serving shorter sentences or awaiting trial in local jails. 

In this work we use American Community Survey (ACS) Public Use Microdata Sample (PUMS) data produced by the U.S. Census Bureau. The ACS PUMS files include data at various geographic levels, the most detailed of which is Public Use Microdata Areas (PUMAs). These are designated areas with populations of about 100,000 or more, allowing for granular analysis of communities. For each PUMA, we report estimates of: 1) the number of disconnected youth (16-24), 2) the number of youth (16-20) in foster care, 3) the number of youth arrests (16-24), 4) the number of children (15-17) who have a parent incarcerated in a state prison. 

## Contents

- **`Scripts`**: Folder containing scripts for downloading data used in estimates of multiple indicator variables. 
- **`Tests`**: Folder containing scripts to test the performance of the data download and processing.
- **`RawData`**: Folder containing data downloaded from ACS PUMS.
- **`disconnected`**: Folder containing scripts and data used to estimate the number of disconnected youth by neighborhood cluster. 
- **`foster`**: Folder containing scripts and data used to estimate the number of foster youth by neighborhood cluster.
- **`incarceratedparent`**: Folder containing scripts and data used to estimate the number of youth with an incarcerated parent by neighborhood cluster.
- **`justiceimpacted`**: Folder containing scripts and data used to estimate the number of youth arrests by neighborhood cluster.

## Usage

- Download ACS PUMS data using the scripts in  the `Scripts` folder.
- Generate estimates of each indicator variable with the `disconnected`, `foster`, `incarceratedparent`, and `justiceimpacted` folders. 
- For descriptions of each indicator variable, instructions for generating estimates, data acknowledgements, and study limitations, please see the `README` files in the `disconnected`, `foster`, `incarceratedparent`, and `justiceimpacted` folders. 

