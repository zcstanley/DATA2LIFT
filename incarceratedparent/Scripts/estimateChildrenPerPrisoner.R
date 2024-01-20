load("incarceratedparent/RawData/incarceratedParentPercentData.Rdata")
load("incarceratedparent/RawData/childrenByParentSexData.Rdata")
load("incarceratedparent/RawData/childAgeData.Rdata")
load("incarceratedparent/RawData/numPrisoners2016Data.Rdata")


# Compute the number of children aged 15-17 who have a parent incarcerated in a 
# state prison by sex of the parent

# Filter out federal jurisdiction and children aged 15-17 from childAge
childAgeState <- childAge %>% 
  filter(jurisdiction == "state", child_age == "15-17") %>%
  rename(percent_by_age = percent)

# Filter out federal jurisdiction from childrenByParentSex
childrenByParentSexState <- childrenByParentSex %>% 
  filter(jurisdiction == "state") %>%
  rename(percent_parent = percent)

# Calculate number of children aged 15-17
mergedData <- merge(childrenByParentSexState, childAgeState, by = c("jurisdiction", "sex")) %>% 
  mutate(
    count_children = as.numeric(gsub(",", "", count_children)), # Remove commas from count_children
    percent_by_age = as.numeric(percent_by_age) / 100, # Convert percent to proportion
    children_15_17 = count_children * percent_by_age # Calculate number of children 15-17
  )

# Select relevant columns
result <- mergedData[, c("jurisdiction", "sex", "children_15_17")]

