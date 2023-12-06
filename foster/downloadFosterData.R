# -----------------------------------------------------------------------------
# Foster Care Data URL Retrieval and PDF Download
# Author: Chad M. Topaz
# Date: Sep 19, 2023
#
# Description:
# This code downloads the relevant foster care PDF files locally
# for each state.
# -----------------------------------------------------------------------------

# -------------------------
# Load necessary libraries
# -------------------------
library(pdftools)
library(tidyverse)
library(pbmcapply)

# -----------------------------------
# Define state postal abbreviations 
# -----------------------------------
state_abbreviations <- tolower(c(
  "AL", "AK", "AZ", "AR", "CA", "CO", "CT", "DE", "FL", "GA", 
  "HI", "ID", "IL", "IN", "IA", "KS", "KY", "LA", "ME", "MD", 
  "MA", "MI", "MN", "MS", "MO", "MT", "NE", "NV", "NH", "NJ", 
  "NM", "NY", "NC", "ND", "OH", "OK", "OR", "PA", "RI", "SC", 
  "SD", "TN", "TX", "UT", "VT", "VA", "WA", "WV", "WI", "WY", "DC"
))

# -------------------------------------------
# Determine appropriate URLs for each state
# -------------------------------------------
getGoodURL <- function(state_abbrev) {
  base_url <- paste0("https://www.acf.hhs.gov/sites/default/files/documents/cb/afcars-tar-", state_abbrev, "-2021")
  
  for (suffix in c(".pdf", "_1.pdf", "_0.pdf")) {
    try_url <- paste0(base_url, suffix)
    
    success <- tryCatch(
      {
        pdf_data(url(try_url))
        TRUE
      },
      error = function(e) FALSE
    )
    
    if (success) {
      return(try_url)
    }
  }
  
  return(NA)
}

# ---------------------------
# Download the PDFs locally
# ---------------------------
download_file <- function(i) {
  filename <- paste0("foster/pdf/", state_abbreviations[i], ".pdf")
  download.file(successful_urls[i], filename, mode = "wb")
  return(NULL)
}

# -------------------------------------------------
# Fetch valid URLs and initiate the PDF downloads
# -------------------------------------------------
successful_urls <- pbmclapply(state_abbreviations, getGoodURL, mc.cores = parallel::detectCores() - 1) %>% unlist
trash <- pbmclapply(1:length(state_abbreviations), download_file, mc.cores = parallel::detectCores() - 1)