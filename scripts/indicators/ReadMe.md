# Building the indicators
As the generated preliminary classifications are as large as the original raw Twitter data, we created a series of function to divide and conquer the workload on a cluster.

We used to create temporary SQLite databases. Still file can grow very fast. Moreover, SQLite does not allow for concurrent access or vectorized writing, so scripts mail fail from time to time. Be patient.

The steps are the following;
* [update_db.R](./update_db.R): add new parquet files to the list of files to analyze;
* [reset_db.R](./reset_db.R): fixes hanging files in the processing state;
* [generate_indicators.R](./generate_indicators.R): creates the indicatorsXXX.db files starting form the parquet files. Statistics are calculated at census area level;
* [generate_stats.R}(./generate_stats.R): produces intermediate statistics as RDA files; aggregates data per county and state;
* [save_stats.R](./save_stats.R): save intermediate stats to db;
* [calculate_maps.R](./calculate_maps.R): the final indicators are produced by County and State, yearly and monthly.

