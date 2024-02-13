# -----------------------------------------------------------------------------
# Download Survey of Prison Inmates Data
# Author: Zofia C. Stanley
# Date: Jan 18, 2024
#
# Description:
# This R script downloads and unzips the data tables associated with the 2016 Survey of Prison Inmates.
# The data reflects demographic information about prisoners who have at least one minor child.
#
# Citation:
# Bureau of Justice Statistics (2021). Parents in Prison and Their Minor Children: Survey of Prison Inmates, 2016.
# Retrieved from https://bjs.ojp.gov/library/publications/parents-prison-and-their-minor-children-survey-prison-inmates-2016
# Data Tables Downloaded from: https://bjs.ojp.gov/redirect-legacy/content/pub/sheets/pptmcspi16st.zip
#
# -----------------------------------------------------------------------------

# Load necessary libraries
library(httr)

# Specify the URL of the .zip file
url <- "https://bjs.ojp.gov/redirect-legacy/content/pub/sheets/pptmcspi16st.zip"

# Specify the destination of the downloaded .zip file
destfile <- "spi_data.zip"

# Specify the directory where the contents of the zip file will be extracted
extraction_dir <- "incarceratedparent/RawData/SPI"

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