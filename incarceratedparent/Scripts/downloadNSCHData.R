# -----------------------------------------------------------------------------
# Download National Survey of Children’s Health (NSCH) Data
# Author: Zofia C. Stanley
# Date: Jan 23, 2024
#
# Description:
# This R script downloads a data table regarding children who have 
# experienced an incarcerated parent. The data is provided by the Annie E. Casey 
# Foundation's KIDS COUNT Data Center.
#
# Citation:
# Annie E. Casey Foundation. (2024). Children Who Had a Parent Who Was Ever Incarcerated.
# KIDS COUNT Data Center. Retrieved January 23, 2024, from 
# https://datacenter.aecf.org/data/tables/9688-children-who-had-a-parent-who-was-ever-incarcerated
# -----------------------------------------------------------------------------

# Load necessary libraries
library(httr)

# Define the base and relative URLs
base_url <- "https://datacenter.aecf.org"
relative_path <- "/rawdata.axd?ind=9688&loc=1"
full_url <- paste0(base_url, relative_path)

# Specify the path and filename for the downloaded data
data_dir <- "incarceratedparent/RawData"
file_name <- "nsch_data.xlsx"
dest_file_path <- file.path(data_dir, file_name)

# Ensure the directory exists
if (!dir.exists(data_dir)) {
  dir.create(data_dir, recursive = TRUE)
}

# Fetch the data from the URL
response <- GET(full_url)

# Check if the request was successful (HTTP status code 200)
if (status_code(response) == 200) {
  # Save the content of the response to the specified file
  writeBin(content(response, "raw"), dest_file_path)
  message("File downloaded successfully: ", dest_file_path)
} else {
  # Provide detailed error information
  message("Failed to download the file. HTTP status code: ", status_code(response))
}