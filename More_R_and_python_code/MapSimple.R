
### Happiness

# Libraries (only run once)
if (!requireNamespace("tigris")) install.packages("tigris")
if (!requireNamespace("sf")) install.packages("sf")
if (!requireNamespace("arrow")) install.packages("arrow")
if (!requireNamespace("patchwork")) install.packages("patchwork")
if (!requireNamespace("ggplot2")) install.packages("ggplot2")
if (!requireNamespace("data.table")) install.packages("data.table")

library(tigris)
library(sf)
library(arrow)
library(patchwork)
library(ggplot2)
library(data.table)

# -----------------------------
# Load datasets from Hugging Face
# -----------------------------
state_data <- data.table(read_parquet("https://huggingface.co/datasets/siacus/flourishing/resolve/main/flourishingStateYear.parquet"))
county_data <- data.table(read_parquet("https://huggingface.co/datasets/siacus/flourishing/resolve/main/flourishingCountyYear.parquet"))

# -----------------------------
# Filter for happiness and a specific year
# -----------------------------
vars <- unique(state_data$variable)
vars

var <- "happiness"
yr <- 2012

state_plot_data <- state_data[variable == var & year == yr]
county_plot_data <- county_data[variable == var & year == yr]

# Ensure correct FIPS formatting
state_plot_data[, FIPS := sprintf("%02s", FIPS)]
county_plot_data[, FIPS_county := sprintf("%05s", FIPS_county)]

# -----------------------------
# Load and prep shapefiles
# -----------------------------
# States
states <- states(cb = TRUE, resolution = "20m", year = 2021) %>% st_as_sf()
states <- states[!states$STUSPS %in% c("AK", "HI", "PR"), ]
states$STATEFP <- sprintf("%02s", states$STATEFP)

# Counties
counties <- counties(cb = TRUE, resolution = "20m", year = 2021) %>% st_as_sf()
counties <- counties[!counties$STATEFP %in% c("02", "15", "72"), ]
counties$GEOID <- sprintf("%05s", counties$GEOID)

# -----------------------------
# Merge data with maps
# -----------------------------
map_state <- merge(states, state_plot_data, by.x = "STATEFP", by.y = "FIPS", all.x = TRUE)
map_county <- merge(counties, county_plot_data, by.x = "GEOID", by.y = "FIPS_county", all.x = TRUE)

# -----------------------------
# Create plots
# -----------------------------
p_state <- ggplot(map_state) +
  geom_sf(aes(fill = stat), color = "white") +
  scale_fill_viridis_c(option = "plasma", na.value = "grey90") +
  labs(
    title = paste("Happiness Stat by State -", yr),
    fill = "Stat"
  ) +
  theme_minimal()

p_county <- ggplot(map_county) +
  geom_sf(aes(fill = stat), color = NA) +
  scale_fill_viridis_c(option = "plasma", na.value = "grey90") +
  labs(
    title = paste("Happiness Stat by County -", yr),
    fill = "Stat"
  ) +
  theme_minimal()

# -----------------------------
# Combine and show
# -----------------------------
p_state + p_county

