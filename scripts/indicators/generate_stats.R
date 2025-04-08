# # reads parquet files and creates indicators
# (c) SMI 2025
# Rscript generate_indicators.R > indlog.txt 2>&1 &
# module load R

# salloc -p shared  --ntasks=1 --cpus-per-task=8 --mem=32G -t 120
# salloc -p test  --ntasks=1 --cpus-per-task=16 --mem=64G -t 120

# # reads parquet files and creates indicators
# Rscript generate_indicators.R > indlog.txt 2>&1 &
# module load R

# salloc -p shared  --ntasks=1 --cpus-per-task=8 --mem=32G -t 120
# salloc -p test  --ntasks=1 --cpus-per-task=16 --mem=512G -t 120

rm(list=ls())
pkgs <- c("RSQLite", "DBI", "arrow", "lubridate", "data.table", "progress", "progressr", "future.apply")
for (pkg in pkgs) if (!require(pkg, character.only = TRUE)) install.packages(pkg)
lapply(pkgs, library, character.only = TRUE)

MAX_FILES <- 50

# we use all cores
data.table::setDTthreads(min(8, as.integer(Sys.getenv("SLURM_CPUS_PER_TASK"))))
cat(sprintf("\nNumber of DT threads: %d\n", data.table::getDTthreads()))
options(datatable.verbose = FALSE)
options(datatable.showProgress = FALSE)

# Directories
PK_DIR="/n/netscratch/siacus_lab/Lab/output/" # FASRC
DB_DIR = '/n/home11/siacus/siacus_lab/Users/siacus'
TMP_DIR="/n/netscratch/siacus_lab/Lab/tmp_geo/" # FASRC

stats_db_path <- file.path(DB_DIR, "stats-mid.db")

dir.create(TMP_DIR)

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

con_stats <- dbConnect(SQLite(), dbname = stats_db_path)

dbExecute(con_stats, "
  CREATE TABLE IF NOT EXISTS status (
    dbname TEXT PRIMARY KEY,
    n_rows INTEGER NOT NULL,
    checked INTEGER
  )
")

dbDisconnect(con_stats)

Initialize <- FALSE

if(Initialize){
  # Connect to stats-mid.db and ensure the table exists
  con_stats <- dbConnect(SQLite(), dbname = stats_db_path)
  dbExecute(con_stats, "DROP TABLE IF EXISTS status")
  dbExecute(con_stats, "
  CREATE TABLE status (
    dbname TEXT PRIMARY KEY,
    nrows INTEGER NOT NULL,
    checked INTEGER
  )
  ")

  # Get all relevant .db files
  all_files <- list.files(DB_DIR, pattern = "^indicators.*\\.db$", full.names = FALSE)

  # Loop through files and count rows
  for (f in all_files) {
    indicators_db_path <- file.path(DB_DIR, f)
  
    con <- try(dbConnect(SQLite(), dbname = indicators_db_path), silent = TRUE)
    if (inherits(con, "try-error")) {
      cat(sprintf("⚠️ Failed to connect to %s\n", f))
      next
   }
  
    if (!"indicators" %in% dbListTables(con)) {
      dbDisconnect(con)
      next
   }

    # Get row count
    n_rows <- tryCatch(
      dbGetQuery(con, "SELECT COUNT(*) AS n FROM indicators")[["n"]],
      error = function(e) NA_integer_
    )
    dbDisconnect(con)
  
    if (!is.na(n_rows)) {
      dbExecute(con_stats, sprintf("
        INSERT OR REPLACE INTO status (dbname, nrows)
        VALUES ('%s', %d)
      ", f, n_rows ))
    
      cat(sprintf("✅ Recorded %d rows for %s\n", n_rows, f))
    }
  }
  dbDisconnect(con_stats)
  cat("\n✅ Status table initialized.\n")
}


# Connect to (or create) SQLite database
all_files <- list.files(DB_DIR, pattern = "^indicators.*\\.db$", full.names = FALSE)
nfiles <- length(all_files)

con_stats <- dbConnect(SQLite(), dbname = stats_db_path)


# Get row counts from stats table, grouped by dbname
existing_counts <- try(
  dbGetQuery(con_stats, "SELECT * FROM status"),
  silent = TRUE
)
dbDisconnect(con_stats)
cat("Existing counts:\n")

print(existing_counts)

plan(multicore, workers = as.integer(Sys.getenv("SLURM_CPUS_PER_TASK"))-1)
handlers(global = TRUE)

cat(sprintf("\nUsing future plan: %s with %d workers\n", class(plan())[1], nbrOfWorkers()))

# Ensure existing_counts is a data.table for efficient lookup within the function
if (!is.data.table(existing_counts)) {
  existing_counts <- as.data.table(existing_counts)
}
# Set key for faster joining/lookup (optional but good practice)
if (nrow(existing_counts) > 0 && "dbname" %in% names(existing_counts)) {
  setkey(existing_counts, dbname)
} else {
  # Handle empty or unexpected existing_counts
   cat("Warning: existing_counts is empty or does not contain 'dbname'. Comparison might not work as expected.\n")
   # Create an empty keyed data.table to prevent errors in the function
   existing_counts <- data.table(dbname = character(), nrows = integer())
   setkey(existing_counts, dbname)
}

# we now need to exclude those whose checked=1 from all_files

con_stats <- dbConnect(SQLite(), dbname = stats_db_path)
checked <- dbGetQuery(con_stats,"SELECT dbname from status where checked=1")$dbname
all_files <- all_files[!(all_files %in% checked)]

if(length(all_files)==0){
  q("no")
}

cat("\nRetaining indicators")
with_progress({
  p <- progressor(along = all_files)

  keep_flags <- future_lapply(all_files, function(f) {
    p(sprintf("Checking %s", f))
    con <- try(dbConnect(SQLite(), dbname = file.path(DB_DIR, f)), silent = TRUE)
    if (inherits(con, "try-error")) return(FALSE)
    if (!"indicators" %in% dbListTables(con)) {
      dbDisconnect(con)
      file.remove(file.path(DB_DIR, f))
      cat(sprintf("\nEmpty db %s, removing the file...", f))
      return(FALSE)
    }
    n_rows <- tryCatch(dbGetQuery(con, "SELECT COUNT(*) AS n FROM indicators")[["n"]], error = function(e) NA_integer_)
    dbDisconnect(con)
    if (is.na(n_rows)) return(FALSE)
    existing_n <- existing_counts[which(existing_counts[["dbname"]] == f), ][["nrows"]]
    return(length(existing_n) == 0 || n_rows != existing_n)
  })

  keep_files <- all_files[unlist(keep_flags)]
})

con_stats <- dbConnect(SQLite(), dbname = stats_db_path)
# Set checked = 0 (re-check) for dbnames in keep_files
# Insert missing dbnames (if they don't exist), with nrows = 0 and checked = 0
for (f in unique(keep_files)) {
  dbExecute(con_stats, sprintf(
    "INSERT INTO status (dbname, nrows, checked)
     VALUES (%s, 0, 0)
     ON CONFLICT(dbname) DO NOTHING",
    shQuote(f)
  ))
}

dbExecute(con_stats,sprintf("UPDATE status SET checked = 0 WHERE dbname IN (%s)",
    paste(shQuote(unique(keep_files)), collapse = ", ")))

for (f in existing_counts$dbname) {
  dbExecute(con_stats, sprintf(
    "INSERT INTO status (dbname, nrows, checked)
     VALUES (%s, %d, 1)
     ON CONFLICT(dbname) DO NOTHING",
    shQuote(f), existing_counts$nrows[match(f, existing_counts$dbname)]
  ))
}

# Set checked = 1 (no need to re-check) for dbnames NOT in keep_files
dbExecute(con_stats,sprintf("UPDATE status SET checked = 1 WHERE dbname NOT IN (%s)",
    paste(shQuote(unique(keep_files)), collapse = ", ")))
dbDisconnect(con_stats)

cat("\n")

plan(sequential)

# Filter all_files
all_files <- unique(keep_files)
nfiles <- length(all_files)

cat(sprintf("\nTotal files: %d.", nfiles))

if(nfiles > MAX_FILES){
  all_files <- all_files[1:MAX_FILES]
  nfiles <- length(all_files)
}

cat(sprintf("Number of files that will be processed now: %d\n", nfiles))

print(head(all_files))

naf <- length(all_files)
results <- vector("list", naf)

for(i in 1:naf){
  file_name <- all_files[i]
  cat(sprintf("\n[%.4d/%.4d] Reading %s...", i, naf, file_name))
  indicators_db_path <- file.path(DB_DIR, file_name)
  max_tries <- 5
  attempt <- 1
  success <- FALSE
  x <- NULL
  rm(x)
  while (!success && attempt <= max_tries) {
    tryCatch({
      con <- dbConnect(SQLite(), dbname = indicators_db_path)
      if ("indicators" %in% dbListTables(con)) {
        x <- setDT(dbGetQuery(con, "SELECT * FROM indicators"))
        success <- TRUE
      } else {
        attempt <- max_tries
      }
    }, error = function(e) {
      if (grepl("locked", conditionMessage(e))) Sys.sleep(1)
    })
    if (exists("con") && DBI::dbIsValid(con)) dbDisconnect(con)
    if (!success) {
      cat("[x]")
      attempt <- attempt + 1
    }
  }

  if (!success || is.null(x) || nrow(x) == 0) {
    return(list(file = file_name, status = "failed"))
  }

  # Transform
  x[, date := ceiling_date(as.IDate(date), unit = "month") - days(1)]
  x[, FIPS := substr(GEOID20, 1, 2)]
  x[, county := substr(GEOID20, 3, 5)]
  x[, StateCounty := paste0(FIPS, county)]
  x <- unique(x)

  if (nrow(x) == 0) {
    return(list(file = file_name, status = "empty"))
  }
  nrx <- nrow(x)
  cat(sprintf(" loaded %d rows", nrx))
  subset_x <- x[, c("StateCounty", "date", "FIPS", ..vars), with = FALSE]
  x <- NULL
  rm(x)
  subset_x[, (vars) := lapply(.SD, as.integer), .SDcols = vars]
  geo_summary <- melt(subset_x, id.vars = c("StateCounty", "date", "FIPS"),
                  measure.vars = vars, variable.name = "variable", value.name = "value")
  subset_x <- NULL
  rm(subset_x)
  geo_summary <- geo_summary[, .(
      value = sum(value, na.rm = TRUE),
      non_na = sum(!is.na(value)),
      na = sum(is.na(value)),
      total = .N,
      FIPS = FIPS[1]
    ), by = .(StateCounty, variable, date)]

  geo_summary[, `:=`(
      year = year(date[1]),
      month = month(date[1]),
      dbname = file_name,
      date = as.character(date) )]
  setcolorder(geo_summary, c("variable", "value", "total","non_na", "na", "FIPS", "StateCounty", "date","month", "year","dbname"))
  rda_file <- sub("\\.db$", ".rda", file_name)
  save_path <- file.path(TMP_DIR, rda_file)
  cat(sprintf(" saving %d rows...",nrow(geo_summary)))
  save(geo_summary, file = save_path)
  cat(" done!")
  results[[i]] <- list(file = file_name, status = "success", rows = nrx)
}

# Results summary
result_dt <- rbindlist(results, fill = TRUE)
print(result_dt)

good <- which(result_dt$status == "success")
if(length(good) > 0){
  good_rows <- existing_counts$nrows[match(result_dt$file[good],existing_counts$dbname)]
  good_dbs <- result_dt$file[good]
  cat("\nUpdating 'checked' status for:")
  print(good_dbs)
  con_stats <- dbConnect(SQLite(), dbname = stats_db_path)
  for(i in 1:length(good)){
    dbExecute(con_stats, 
      "UPDATE status SET checked = 1, nrows = ? WHERE dbname = ?", 
      params = list(good_rows[i], good_dbs[i])
    )
  }
  dbDisconnect(con_stats)
}
cat(sprintf("✅ %d files succeeded.\n", sum(result_dt$status == "success")))
cat(sprintf("⚠️ %d failed or empty.\n", sum(result_dt$status != "success")))

cat("✅ Finished stats generation.\n")
