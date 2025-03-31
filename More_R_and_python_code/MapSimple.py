import geopandas as gpd
import pandas as pd
import matplotlib.pyplot as plt
from datasets import load_dataset

# -----------------------------
# Load data from Hugging Face
# -----------------------------
state_ds = load_dataset("siacus/flourishing", data_files="flourishingStateYear.parquet")
county_ds = load_dataset("siacus/flourishing", data_files="flourishingCountyYear.parquet")

state_df = state_ds["train"].to_pandas()
county_df = county_ds["train"].to_pandas()

# -----------------------------
# Filter for happiness and specific year
# -----------------------------
var = "happiness"
yr = 2012

state_plot = state_df[(state_df["variable"] == var) & (state_df["year"] == yr)].copy()
county_plot = county_df[(county_df["variable"] == var) & (county_df["year"] == yr)].copy()

state_plot["FIPS"] = state_plot["FIPS"].apply(lambda x: f"{int(x):02d}")
county_plot["FIPS_county"] = county_plot["FIPS_county"].apply(lambda x: f"{int(x):05d}")

# -----------------------------
# Load shapefiles
# -----------------------------
# US State and County boundaries
states = gpd.read_file("https://www2.census.gov/geo/tiger/GENZ2021/shp/cb_2021_us_state_20m.zip")
counties = gpd.read_file("https://www2.census.gov/geo/tiger/GENZ2021/shp/cb_2021_us_county_20m.zip")

# Remove AK, HI, PR
states = states[~states["STUSPS"].isin(["AK", "HI", "PR"])]
counties = counties[~counties["STATEFP"].isin(["02", "15", "72"])]

# -----------------------------
# Merge with flourishing data
# -----------------------------
states["FIPS"] = states["STATEFP"]
state_map = states.merge(state_plot, on="FIPS", how="left")

counties["FIPS_county"] = counties["STATEFP"] + counties["COUNTYFP"]
county_map = counties.merge(county_plot, on="FIPS_county", how="left")

# -----------------------------
# Plot maps side by side
# -----------------------------
fig, axes = plt.subplots(1, 2, figsize=(18, 8))

# State-level map
state_map.plot(
    column="stat",
    cmap="plasma",
    linewidth=0.1,
    ax=axes[0],
    edgecolor="white",
    missing_kwds={"color": "lightgrey"}
)
axes[0].set_title(f"Happiness Stat by State - {yr}")
axes[0].axis("off")

# County-level map
county_map.plot(
    column="stat",
    cmap="plasma",
    linewidth=0,
    ax=axes[1],
    edgecolor="white",
    missing_kwds={"color": "lightgrey"}
)
axes[1].set_title(f"Happiness Stat by County - {yr}")
axes[1].axis("off")

plt.tight_layout()
plt.show()
