# (c) SMI 2025
# salloc -p test  --ntasks=1 --cpus-per-task=32 --mem=64G -t 120

rm(list=ls())

# Load necessary packages
if(!require(RSQLite)) install.packages("RSQLite")
if(!require(DBI)) install.packages("DBI")
if (!require(progress)) install.packages("progress")
if (!require(data.table)) install.packages("data.table")
if (!require(progressr)) install.packages("progressr")
if (!require(future.apply)) install.packages("future.apply")



ResetFailed <- FALSE # Optional switch to reset failed files to waiting
CleanUp <- FALSE # deduplicates indicators

PK_DIR <- "/n/netscratch/siacus_lab/Lab/output/"
DB_DIR <- "/n/home11/siacus/siacus_lab/Users/siacus"
db_path <- file.path(DB_DIR, "parquet_files.db")

dbcon <- dbConnect(SQLite(), dbname = db_path)
print(dbGetQuery(dbcon, "SELECT status, COUNT(*) AS count FROM file_status GROUP BY status"))
dbDisconnect(dbcon)


# Deduplicate file_status table if duplicates exist
con <- dbConnect(SQLite(), dbname = db_path)
dup_check <- dbGetQuery(con, "SELECT COUNT(*) - COUNT(DISTINCT filename) AS dup_count FROM file_status")$dup_count
if (!is.na(dup_check) && dup_check > 0) {
  cat("\nDeduplicating 'file_status' table by filename...")
  dbExecute(con, "CREATE TEMP TABLE temp_file_status AS SELECT * FROM file_status WHERE rowid IN (SELECT MIN(rowid) FROM file_status GROUP BY filename)")
  dbExecute(con, "DELETE FROM file_status")
  dbExecute(con, "INSERT INTO file_status SELECT * FROM temp_file_status")
  dbExecute(con, "DROP TABLE temp_file_status")
  cat(" Deduplication of 'file_status' completed.")
} else {
  cat(" No duplicates found in 'file_status' table.")
}
dbDisconnect(con)

dbcon <- dbConnect(SQLite(), dbname = db_path)
print(dbGetQuery(dbcon, "SELECT status, COUNT(*) AS count FROM file_status GROUP BY status"))
dbDisconnect(dbcon)

data.table::setDTthreads(0)
cat(sprintf("\nNumber of cores: %d\n", data.table::getDTthreads()))

# Cleanup duplicates in indicators*.db
all_db_files <- list.files(DB_DIR, pattern = "^indicators(\\d+)?\\.db$", full.names = TRUE)
ndbs <- length(all_db_files)

if(CleanUp){
  for (i in 1:ndbs) {
    db_file <- all_db_files[i]
    cat(sprintf("\nWorking on DB file: %s...",db_file))
    con <- dbConnect(SQLite(), dbname = db_file)
    if ("indicators" %in% dbListTables(con)) {
      n <- dbGetQuery(con, "SELECT COUNT(*) AS n FROM indicators")$n
      if (n == 0) {
        dbDisconnect(con)
        cat(sprintf(" Deleting empty DB file: %s.", db_file))
        file.remove(db_file)
        next
      }         
      cat(" Checking duplicates...")
      cols <- dbListFields(con, "indicators")
      cols_sql <- paste(cols, collapse = ", ")
      
      # Simplified efficient deduplication using rowid
      dup_check_query <- sprintf("
        SELECT COUNT(*) - COUNT(DISTINCT %s) AS dup_count FROM indicators
      ", cols_sql)

      dup_count <- dbGetQuery(con, dup_check_query)$dup_count
      
      if (!is.na(dup_count) && dup_count > 0) {
        cat(sprintf(" Found %d duplicates. Deduplicating...", dup_count))
        
        dbExecute(con, "BEGIN TRANSACTION;")
        dbExecute(con, sprintf("
          CREATE TABLE indicators_dedup AS SELECT DISTINCT %s FROM indicators;
        ", cols_sql))
        dbExecute(con, "DROP TABLE indicators;")
        dbExecute(con, "ALTER TABLE indicators_dedup RENAME TO indicators;")
        dbExecute(con, "COMMIT;")
        dbDisconnect(con)
        cat(" Done deduplication.")
      } else {
        cat(" No duplicates found.")
      }
    }
  }
}

plan(multicore)  # Linux only
handlers(global = TRUE)
handlers("txtprogressbar")  # or "progress" for fancier output

with_progress({
  p <- progressor(along = all_db_files)

  all_files_done <- future_lapply(all_db_files, function(db_file) {
    p(sprintf("Processing %s", basename(db_file)))
    
    con <- dbConnect(SQLite(), dbname = db_file)
    
    if (!("indicators" %in% dbListTables(con))) {
      dbDisconnect(con)
      return(NULL)
    }

    n <- dbGetQuery(con, "SELECT COUNT(*) AS n FROM indicators")$n

    if (n == 0) {
      dbDisconnect(con)
      cat(sprintf(" Deleting empty DB file: %s.\n", db_file))
      file.remove(db_file)
      return(NULL)
    }

    result <- tryCatch({
      setDT(dbGetQuery(con, "SELECT DISTINCT filename FROM indicators"))
    }, error = function(e) {
      message(sprintf("Error in %s: %s", db_file, e$message))
      NULL
    })

    dbDisconnect(con)
    unique(result)
  })
})

dt <- rbindlist(all_files_done, use.names = TRUE, fill = TRUE)
done_files <- unique(dt$filenames)

con <- dbConnect(SQLite(), dbname = db_path)
files_proc <- dbGetQuery(con, "SELECT DISTINCT filename FROM file_status WHERE status = 'processing'")$filename
dbDisconnect(con)

# Files still marked as processing but not completed
stuck_files <- setdiff(files_proc, done_files)
message("Found ", length(stuck_files), " stuck files in 'processing' status.")

if (length(stuck_files) > 0) {
  batch_size <- 1000
  pb <- progress_bar$new(
    format = "Resetting [:bar] :current/:total (:percent) ETA: :eta",
    total = ceiling(length(stuck_files) / batch_size), clear = FALSE, width = 60
  )

  for (i in seq(1, length(stuck_files), by = batch_size)) {
    batch <- stuck_files[i:min(i + batch_size - 1, length(stuck_files))]
    quoted_files <- paste0("'", gsub("'", "''", batch), "'")
    in_clause <- paste(quoted_files, collapse = ", ")
    query <- sprintf("UPDATE file_status SET status = 'waiting' WHERE status = 'processing' AND filename IN (%s)", in_clause)

    con <- NULL
    repeat {
      tryCatch({
        con <- dbConnect(SQLite(), dbname = db_path)
        break
      }, error = function(e) {
        if (grepl("locked", e$message)) {
          message("DB is locked. Retrying in 2 seconds...")
          Sys.sleep(2)
        } else stop(e)
      })
    }

    tryCatch({
      dbExecute(con, query)
    }, error = function(e) {
      warning(sprintf("Failed batch update for files %d–%d: %s", i, i + batch_size - 1, e$message))
    })

    dbDisconnect(con)
    pb$tick()
  }

  message("Reset status to 'waiting' for all stuck files.")
} else {
  message("No stuck files to reset.")
}


dbcon <- dbConnect(SQLite(), dbname = db_path)
print(dbGetQuery(dbcon, "SELECT status, COUNT(*) AS count FROM file_status GROUP BY status"))
dbDisconnect(dbcon)


if (ResetFailed) {
  con <- dbConnect(SQLite(), dbname = db_path)
  dbExecute(con, "UPDATE file_status SET status = 'waiting' WHERE status = 'failed'")
  dbDisconnect(con)
  message("Reset status from 'failed' to 'waiting' for all failed files.")
}

dbcon <- dbConnect(SQLite(), dbname = db_path)
print(dbGetQuery(dbcon, "SELECT status, COUNT(*) AS count FROM file_status GROUP BY status"))
dbDisconnect(dbcon)

