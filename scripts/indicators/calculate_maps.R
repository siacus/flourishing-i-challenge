# # reads parquet files and creates indicators
# (c) SMI 2025
# Rscript generate_indicators.R > indlog.txt 2>&1 &
# module load R
# downloads all shape files
# lftp -c "open https://www2.census.gov/geo/tiger/TIGER2024/TABBLOCK20/; mirror --include-glob=*.zip --parallel=4 ./"

rm(list=ls())
# Load necessary packages
if(!require(RSQLite)) install.packages("RSQLite")
if(!require(DBI)) install.packages("DBI")
if(!require(arrow)) install.packages("arrow")
if (!require(lubridate)) install.packages("lubridate")
if (!require(data.table)) install.packages("data.table")

# Directories
PK_DIR="/n/netscratch/siacus_lab/Lab/output/" # FASRC
DB_DIR = '/n/home11/siacus/siacus_lab/Users/siacus'


# Create shortened SQL-safe one-word labels (manually defined)
labels <- c(
  "happiness", "resilience", "selfesteem", "lifesat", "fearfuture", "vitality",
  "energy", "posfunct", "jobsat", "optimism", "innerpeace", "purpose",
  "depression", "anxiety", "suffering", "pain", "altruism", "loneliness",
  "relationships", "belonging", "gratitude", "trust", "trusted", "balance",
  "mastery", "discrim", "lovedgod", "believegod", "relcrit", "spiritpun",
  "relcomfort", "finworry", "afterlife", "volunteer", "charity", "forgive",
  "polvoice", "govapprove", "hope", "goodpromo", "delaygrat", "ptsd",
  "smokehealth", "drinkhealth", "healthlim", "empathy"
)

vars <- c("migmood","corruption", labels)

stats_mid_db_path <- file.path(DB_DIR, "stats-mid.db")


con_stat_mid <-dbConnect(SQLite(), dbname = stats_mid_db_path)
x <- dbGetQuery(con_stat_mid, "SELECT * FROM stats")
dbDisconnect(con_stat_mid)

setDT(x)
x[, key := sprintf("%s*%s*%s",variable,StateCounty,date)]
x <- x[, .(
  value        = sum(value, na.rm = TRUE),
  total        = sum(total, na.rm = TRUE),
  non_na       = sum(non_na, na.rm = TRUE),
  na           = sum(na, na.rm = TRUE),
  variable     = variable[1],
  FIPS         = FIPS[1],
  StateCounty  = StateCounty[1],
  date         = date[1],
  month        = month[1],
  year         = year[1]
), by = key][, key := NULL]

x[, salience := fifelse(total > 0, non_na / total, 0)]
x[variable == "corruption", salience := value / total]
x[, county := substr(StateCounty, 3, 5)]


flourishingStateYear <- x[, .(
  salience = mean(salience, na.rm = TRUE),
  stat = sum(value, na.rm = TRUE) / sum(total, na.rm = TRUE),
  ntweets = sum(total, na.rm = TRUE)
), by = .(FIPS, year, variable)]

setcolorder(flourishingStateYear, c("variable", "stat", "salience", "ntweets", "FIPS", "year"))

flourishingCountyYear <- x[, .(
  salience = mean(salience, na.rm = TRUE),
  stat = sum(value, na.rm = TRUE) / sum(total, na.rm = TRUE),
  FIPS = first(FIPS),
  county   = first(county),
  ntweets = sum(total, na.rm = TRUE)
), by = .(StateCounty, year, variable)]

setcolorder(flourishingCountyYear, c("variable", "stat", "salience", "ntweets","FIPS", "county", "StateCounty", "year"))

# we now aggregate by state

flourishingStateMonth <- x[, .(
  salience = mean(salience, na.rm = TRUE),
  stat = sum(value, na.rm = TRUE) / sum(total, na.rm = TRUE),
  ntweets = sum(total, na.rm = TRUE),
  month = first(month),
  year = first(year)
), by = .(FIPS, date, variable)]

setcolorder(flourishingStateMonth, c("variable", "stat", "salience", "ntweets", "FIPS", "date", "month", "year"))


flourishingCountyMonth <- x[, .(
  salience = mean(salience, na.rm = TRUE),
  stat = sum(value, na.rm = TRUE) / sum(total, na.rm = TRUE),
  FIPS = first(FIPS),
  county = first(county),
  ntweets = sum(total, na.rm = TRUE),
  month = first(month),
  year = first(year)
), by = .(StateCounty, date, variable)]


setcolorder(flourishingCountyMonth, c("variable", "stat", "salience", "ntweets","FIPS", "county", "StateCounty", "date", "month", "year"))

cat("\ndone! Saving data...")

fwrite(flourishingStateYear, "flourishingStateYear.csv")
write_parquet(flourishingStateYear, "flourishingStateYear.parquet")

fwrite(flourishingCountyYear, "flourishingCountyYear.csv")
write_parquet(flourishingCountyYear, "flourishingCountyYear.parquet")

fwrite(flourishingStateMonth, "flourishingStateMonth.csv")
write_parquet(flourishingStateMonth, "flourishingStateMonth.parquet")

fwrite(flourishingCountyMonth, "flourishingCountyMonth.csv")
write_parquet(flourishingCountyMonth, "flourishingCountyMonth.parquet")

cat("\nFinished maps files!\nThis is what we have in the files now:")

print(table(x$year))
