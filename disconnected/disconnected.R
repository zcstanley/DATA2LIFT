library(tidycensus)
library(tidyverse)
library(pbmcapply)  # parallel version of lapply
library(sf)
library(cartogram)

# Set census api key
census_api_key("985901667535f61f5ea97bfbf8e4fdfcd8c743c4")

# Set your states
states_list <- c("AL", "AK", "AZ", "AR", "CA", "CO", "CT", "DE", "FL", "GA", 
                 "HI", "ID", "IL", "IN", "IA", "KS", "KY", "LA", "ME", "MD", 
                 "MA", "MI", "MN", "MS", "MO", "MT", "NE", "NV", "NH", "NJ", 
                 "NM", "NY", "NC", "ND", "OH", "OK", "OR", "PA", "RI", "SC", 
                 "SD", "TN", "TX", "UT", "VT", "VA", "WA", "WV", "WI", "WY", "DC")

# Function to get data for a specific state with retries on failure
getDataByState <- function(state, year, max_retries = 3) {
  # Define the required variables from ACS
  vars <- c("AGEP", "SCH", "ESR", "RAC1P", "HISP", "SEX", "ST", "PUMA")
  
  retries <- 1
  
  while (retries <= max_retries) {
    tryCatch({
      # Retrieve the data for the given year and state with specified variables
      data <- get_pums(variables = vars, year = year, state = state, survey = "acs1") %>%
        filter(AGEP >= 16 & AGEP <= 24, SCH == 1, ESR %in% c(3, 6))  # Filtering conditions
      return(data)
    }, error = function(e) {
      if (retries == max_retries) {
        warning(paste("Fetching data for state", state, "failed after", max_retries, "attempts. Returning empty data frame."))
        return(data.frame())  # Return an empty data frame
      }
      retries <- retries + 1
    })
  }
}

# Use pbmclapply to fetch data in parallel
rawdata_list <- pbmclapply(states_list, function(state) {
  getDataByState(state, 2021)
}, mc.cores = 23)

# Combine all the data into one data frame
# rawdata <- bind_rows(rawdata_list)
# save(rawdata, file = "rawdata.Rdata") 
load("disconnectedRawData.Rdata")

# Recode data for clarity
data <- rawdata %>% 
  mutate(
    race_ethnicity = case_when(
      HISP > 1 ~ "Hispanic",
      RAC1P == 1 ~ "White",
      RAC1P == 2 ~ "Black",
      RAC1P %in% c(3,4) ~ "Native American/Alaska Native",
      RAC1P == 6 ~ "Asian",
      RAC1P == 7 ~ "Native Hawaiian/Pacific Islander",
      RAC1P == 8 ~ "Multi-racial",
      TRUE ~ "None of the above"
    ),
    gender = if_else(SEX == 1, "Male", "Female")
  )

# Aggregate data by state-PUMA combination
puma_data <- rawdata %>%
  group_by(ST, PUMA) %>%
  summarise(disconnected_youths = sum(PWGTP), .groups = 'drop')

# Retrieve PUMA boundaries
puma_shapes <- do.call(rbind, lapply(states_list, function(state) {
  tigris::pumas(state = state, year = 2019, cb = TRUE)
}))

# Merge the data with the shapefile
merged_data <- left_join(puma_shapes, puma_data, 
                         by = c("STATEFP10" = "ST", "PUMACE10" = "PUMA"))


# Subset the data
us_contiguous <- merged_data[!merged_data$STATEFP %in% c("02", "15"), ]
alaska <- merged_data[merged_data$STATEFP == "02", ]
hawaii <- merged_data[merged_data$STATEFP == "15", ]

# Create a ggplot object with the cartogram polygons
p <- ggplot(us_contiguous) +
  geom_sf(aes(fill = disconnected_youths)) +
  scale_fill_viridis_c(name = "Disconnected Youths") +
  theme_void() +
  theme(legend.position = "right")

# Save the plot as a PDF file
ggsave(filename = "map.pdf", plot = p, width = 10, height = 6)