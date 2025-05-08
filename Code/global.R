# set up global sever connection 
library(tidyverse)
library(sf)
library(urbnmapr)
library(urbnthemes)



# Load Data
state_co2 <- read.csv("data/completeStateData2022.csv", stringsAsFactors = FALSE)
vehicle_data <- read.csv("data/vehicleData2022.csv", stringsAsFactors = FALSE)
electric_vehicle_data <- read.csv("data/electricVehicleData2022.csv", stringsAsFactors = FALSE)

#rename for join
#names(state_co2)[names(state_co2) == 'states' ] <- 'State'

# states for map
set_urbn_defaults(style = "map")
states_sf <- get_urbn_map(map = "states", sf = TRUE)
completeStateData <- left_join(get_urbn_map(map = "states", sf = TRUE),
                               state_co2,
                               by = c("state_name" = "State"))

# get the raw data that we will show in the data tab
raw_vehicle_data <- read.csv("data/vehicles.csv")
raw_emissions_data <- read.csv("data/1970-2022StateCO2Emissions.csv")
raw_electricity_generation2022 <- read.csv("data/stateGeneration2022.csv")

# filter data for regions 
# Filter region-specific data for West, Midwest, South, and North regions

# West Region Data
westRegion <- state_co2 %>%
  filter(State %in% c("Arizona", "Colorado", "Idaho", "Montana", "Nevada", 
                      "New Mexico", "Utah", "Wyoming", "Alaska", "California", 
                      "Hawaii", "Oregon", "Washington"))

# Midwest Region Data
midWestRegion <- state_co2 %>%
  filter(State %in% c("Illinois", "Indiana", "Michigan", "Ohio", "Wisconsin", 
                      "Iowa", "Kansas", "Minnesota", "Missouri", "Nebraska", 
                      "North Dakota", "South Dakota"))

# South Region Data
southRegion <- state_co2 %>%
  filter(State %in% c("Delaware", "Florida", "Georgia", "Maryland", "North Carolina", 
                      "South Carolina", "Virginia", "West Virginia", "Alabama", 
                      "Kentucky", "Mississippi", "Tennessee", "Arkansas", "Louisiana", 
                      "Oklahoma", "Texas", "District of Columbia"))

# North Region Data
northRegion <- state_co2 %>%
  filter(State %in% c("Connecticut", "Maine", "Massachusetts", "New Hampshire", 
                      "Rhode Island", "Vermont", "New Jersey", "New York", "Pennsylvania"))

# render labels for region data graphs
readable_labels <- c(
  EfficiencyScore = "Efficiency Score",
  gCo2pkWh = "Grams of CO₂ per kWh",
  netKWhGeneration = "Net kWh Generation",
  gCo2 = "Total Grams of CO₂",
  millionTonsOfCO2 = "Million Tons of CO₂",
  AverageRetailPrice.cents.kWh. = "Avg. Retail Price (¢/kWh)",
  TotalRetailSales.MWh. = "Total Retail Sales (MWh)",
  NetSummerCapacity.MW. = "Net Summer Capacity (MWh)",
  NetGeneration.MWh. = "Net Generation (MWh)"
)

# single set of choices to call
r_choices <- setNames(names(readable_labels), readable_labels)

# create state name variable 
stateNames <- state.name
