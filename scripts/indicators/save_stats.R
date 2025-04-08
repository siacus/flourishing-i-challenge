
# (c) SMI 2025
# salloc -p test  --ntasks=1 --cpus-per-task=16 --mem=512G -t 120

rm(list=ls())
pkgs <- c("RSQLite", "DBI", "data.table", "progress")
for (pkg in pkgs) if (!require(pkg, character.only = TRUE)) install.packages(pkg)
lapply(pkgs, library, character.only = TRUE)


# we use all cores
data.table::setDTthreads(min(8, as.integer(Sys.getenv("SLURM_CPUS_PER_TASK"))))
cat(sprintf("\nNumber of DT threads: %d\n", data.table::getDTthreads()))
options(datatable.verbose = FALSE)
options(datatable.showProgress = FALSE)

# Directories
PK_DIR="/n/netscratch/siacus_lab/Lab/output/" # FASRC
DB_DIR = '/n/home11/siacus/siacus_lab/Users/siacus'
TMP_DIR="/n/netscratch/siacus_lab/Lab/tmp_geo/" # FASRC

dir.create(TMP_DIR)
stats_db_path <- file.path(DB_DIR, "stats-mid.db")

processed_files <- list.files(TMP_DIR, pattern = "^indicators.*\\.rda$", full.names = FALSE)
skipped_files <- NULL
npf <- length(processed_files)

if(npf==0){
  cat("\nNothing to save, exiting.\n")
  q("no")
}
# ==== Sequential Write Phase ====
cat("📝 Writing stats to SQLite sequentially...\n")

for (i in 1:npf){
  f <- processed_files[i]
  cat(sprintf("\n[%.4d/%.4d] Loading %s", i, npf, f))  
  if (file.exists(file.path(TMP_DIR, f))) {
    load(file.path(TMP_DIR, f)) # loads geo_summary
    nrg <- nrow(geo_summary)
    cat(sprintf(" %d rows loaded,", nrg))
    dbname <- geo_summary$dbname[1]
    con_stats <- dbConnect(SQLite(), dbname = stats_db_path)
    if (dbExistsTable(con_stats, "stats")) {
        cat(" deleting existing stats (if any) from db...")
        dbExecute(con_stats, sprintf("DELETE FROM stats WHERE dbname = '%s'", dbname))
    }
    cat(" saving to db...")
    out <- try(dbWriteTable(con_stats, "stats", geo_summary, append = TRUE), TRUE, TRUE)
    cat(" updating status in db...")
    if(class(out)!="try-error"){
        dbExecute(con_stats, sprintf( "INSERT INTO status (dbname, nrows) VALUES ('%s', %d) ON CONFLICT(dbname) DO UPDATE SET nrows = excluded.nrows", dbname, nrg))
        cat(sprintf(" good job! Removing %s.",f))
        file.remove(file.path(TMP_DIR, f))
    } else {
      cat(sprintf("⚠️ Failed to write %s", f))
      skipped_files <- c(skipped_files, f)
    }   
    dbDisconnect(con_stats)
  }
}

processed_files <- processed_files[!processed_files %in% skipped_files]
cat(sprintf("\n✅ Processed %d files:", length(processed_files)))
print(processed_files)
cat(sprintf("\n⚠️ Skipped %d files due to error:", length(skipped_files)))
print(skipped_files)




