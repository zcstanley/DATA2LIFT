# -----------------------------------------------------------------------------
# Foster Care Data Extraction and Analysis
# Author: Chad M. Topaz
# Date: Sep 19, 2023
#
# Description:
# This code performs the following tasks:
#   1. Extracts foster care data (total, age, sex, and race) from PDFs for each state.
#   2. Processes the extracted text to get foster count by age, sex, and race.
#   3. Combines processed data for each state into comprehensive datasets.
#   4. Computes proportions for age, sex, and race within each state.
#   5. Joins all individual datasets into a master dataset.
#
# Assumption:
# The code assumes that amongst foster children, age, sex, and race are independent 
# factors. Thus, we can determine proportions for combinations of these factors by 
# multiplying the proportion of each factor together.
# -----------------------------------------------------------------------------

# -------------------------
# Load necessary libraries
# -------------------------
library(pdftools)
library(tidyverse)
library(pbmcapply)
library(magick)
library(tesseract)
library(tidycensus)

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

# -----------------------------------------------------
# Extract all data: total, age, sex, and race from PDF
# -----------------------------------------------------
extractData <- function(state) {
  
  # Set filename for the PDF to be processed
  filename <- paste0("foster/pdf/", state, ".pdf")
  
  # Convert the first page of the PDF to an image
  bitmap <- pdf_convert(filename, pages = 1, dpi = 300)
  img <- image_read(bitmap[1])
  
  # Extract totals data from the image
  totals_geometry <- geometry_area(width = 2613, height = 121, x_off = 169, y_off = 1660)
  totals_cropped <- image_crop(img, geometry = totals_geometry)
  extracted_totals <- tesseract::ocr(totals_cropped)
  
  # Extract age data from the image
  age_geometry <- geometry_area(width = 1229, height = 1346, x_off = 174, y_off = 1982)
  age_cropped <- image_crop(img, geometry = age_geometry)
  extracted_age <- tesseract::ocr(age_cropped)
  
  # Extract sex data from the image
  sex_geometry <- geometry_area(width = 1339, height = 184, x_off = 1433, y_off = 1775)
  sex_cropped <- image_crop(img, geometry = sex_geometry)
  extracted_sex <- tesseract::ocr(sex_cropped)
  
  # Convert the second page of the PDF for race data
  bitmap_race <- pdf_convert(filename, pages = 2, dpi = 300)
  img_race <- image_read(bitmap_race[1])
  
  # Extract race data from the image
  race_geometry <- geometry_area(width = 1298, height = 560, x_off = 180, y_off = 255)
  race_cropped <- image_crop(img_race, geometry = race_geometry)
  extracted_race <- tesseract::ocr(race_cropped)
  
  # Return all the extracted data
  return(list(
    totals = extracted_totals,
    age = extracted_age,
    sex = extracted_sex,
    race = extracted_race
  ))
}

# -------------------------------------------------------------
# Process the extracted text to convert it to the desired data
# -------------------------------------------------------------
processData <- function(extracted, state) {
  
  # Processing totals to obtain foster count
  count <- strsplit(trimws(extracted$totals), "\n")[[1]] %>%
    str_split("N *= *") %>%
    unlist %>%
    tail(1) %>%
    str_replace_all(",", "") %>%
    as.numeric
  
  totaldata <- data.frame(count = count, state = state)
  
  # Process age data to get count by age
  extract_age_count <- function(line) {
    matches <- regmatches(line, regexec("^(.*)\\s(\\d+%|T%|A%)\\s([0-9,]+)$", line))
    number_without_commas <- gsub(",", "", matches[[1]][4])
    as.numeric(number_without_commas)
  }
  
  counts_age <- strsplit(trimws(extracted$age), "\n")[[1]][-1] %>%
    map_dfr(~ tibble(age_count = extract_age_count(.)))
  agedata <- data.frame(age = 0:20, count = counts_age$age_count, state = state)
  
  # Process sex data to get count by sex
  extract_sex_count <- function(line) {
    matches <- regmatches(line, regexec("^(.*)\\s(\\d+%|T%|A%)\\s([0-9,]+)$", line))
    number_without_commas <- gsub(",", "", matches[[1]][4])
    as.numeric(number_without_commas)
  }
  
  counts_sex <- strsplit(trimws(extracted$sex), "\n")[[1]][-1] %>%
    map_dfr(~ tibble(sex_count = extract_sex_count(.)))
  sexdata <- data.frame(sex = c("male", "female"), count = counts_sex$sex_count, state = state)
  
  # Process race data to get count by race
  extract_race_count <- function(line) {
    matches <- regmatches(line, regexec("^(.*)\\s(\\d+%|T%|A%)\\s([0-9,]+)$", line))
    number_without_commas <- gsub(",", "", matches[[1]][4])
    as.numeric(number_without_commas)
  }
  
  counts_race <- strsplit(trimws(extracted$race), "\n")[[1]][-1] %>%
    map_dfr(~ tibble(race_count = extract_race_count(.)))
  racedata <- data.frame(
    race = c("Indigenous", "Asian", "Black", "Pacific", "Hispanic", "white", NA, "Multi"), 
    count = counts_race$race_count, 
    state = state
  ) %>%
    drop_na
  
  # Return the processed data
  return(list(
    totaldata = totaldata,
    agedata = agedata,
    sexdata = sexdata,
    racedata = racedata
  ))
}

# --------------------------------------
# Fetch and process data for each state
# --------------------------------------
results <- pbmclapply(state_abbreviations, function(state) {
  extracted <- extractData(state)
  processData(extracted, state)
}, mc.cores = parallel::detectCores() - 1)

# Remove temporary image files created during processing
file.remove(list.files(pattern = "\\.png$"))

# Combining processed data for each state into single data frames
totaldata <- bind_rows(lapply(results, `[[`, "totaldata"))
agedata <- bind_rows(lapply(results, `[[`, "agedata"))
sexdata <- bind_rows(lapply(results, `[[`, "sexdata"))
racedata <- bind_rows(lapply(results, `[[`, "racedata"))

# -------------------------
# Create master data frame
# -------------------------

# Remove rows with NA values from the data
agedata <- agedata %>% drop_na
sexdata <- sexdata %>% drop_na
racedata <- racedata %>% drop_na

# Compute proportions for age, sex, and race within each state
agedata <- agedata %>%
  group_by(state) %>%
  mutate(age_prop = count / sum(count)) %>%
  ungroup()

sexdata <- sexdata %>%
  group_by(state) %>%
  mutate(sex_prop = count / sum(count)) %>%
  ungroup()

racedata <- racedata %>%
  group_by(state) %>%
  mutate(race_prop = count / sum(count)) %>%
  ungroup()

# Join all individual datasets into a master dataset
scrapedFosterData <- agedata %>%
  inner_join(sexdata, by = "state") %>%
  inner_join(racedata, by = "state") %>%
  inner_join(totaldata, by = "state") %>%
  rename(total_state = count.y.y) %>%
  mutate(prop = age_prop * sex_prop * race_prop) %>%
  select(state, age, sex, race, prop, total_state)

# Save the final dataset to a file
save(scrapedFosterData, file = "foster/scrapedFosterData.Rdata")