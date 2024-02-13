# -----------------------------------------------------------------------------
# Download National Prisoner Statistics Program Data
# Author: Zofia C. Stanley
# Date: Jan 18, 2024
#
# Description:
#   This R script downloads and unzips the data tables associated with the Prisoners in 2022 report.
#   This report provides data on persons in state and federal prisons. 
#
# Citation:
#   Bureau of Justice Statistics (2023). Prisoners in 2022 – Statistical Tables.
#   Retrieved from https://bjs.ojp.gov/library/publications/prisoners-2022-statistical-tables
#   Data Tables Downloaded from: https://bjs.ojp.gov/document/p22st.zip
# -----------------------------------------------------------------------------

# Load necessary libraries
library(httr)

# Specify the URL of the .zip file
url <- "https://bjs.ojp.gov/document/p22st.zip"

# Specify the destination of the downloaded .zip file
destfile <- "nps_data.zip"

# Specify the directory where the contents of the zip file will be extracted
extraction_dir <- "incarceratedparent/RawData/NPS"

# Use the GET function from httr to fetch the .zip file
response <- GET(url)

# Check if the request was successful
if (status_code(response) == 200) {
  # Write the content of the response to a file
  writeBin(content(response, "raw"), destfile)
  message("File downloaded successfully: ", destfile)
  
  # Create directory if it doesn't exist
  if (!dir.exists(extraction_dir)) {
    dir.create(extraction_dir)
  }
  
  # Unzip the file
  unzip(destfile, exdir = extraction_dir)
  file.remove(destfile)
  message("File unzipped successfully in: ", extraction_dir)
  
} else {
  message("Failed to download the file. Status code: ", status_code(response))
}