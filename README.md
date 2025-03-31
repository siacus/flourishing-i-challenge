# The Geography of Human Flourishing - Project Notebook
This is a simple notebook that shows (partial) results of the LLM analysis of the 2.2 billion subset of USA tweets extracted from the global Harvard's [Geotweets Archive v2.0](https://dataverse.harvard.edu/dataset.xhtml?persistentId=doi:10.7910/DVN/3NCMB6). Each raw tweets from the archive was further enriched with Census Blocks Information downlaoded from Census.giv (https://www.census.gov/cgi-bin/geo/shapefiles/index.php) to enable this research.

Computation is not finished yet.
You can explore partial results (year >= 2012) for some of the 46 flourishing dimensions. We suggest to explore ```happiness`` for the moment. See sample results for Happiness Index in the sample image below. The analysis was run at Census ID level and aggreagated at County and State level by year. On the main [data repository](https://huggingface.co/datasets/siacus/flourishing) on Huggingface (that will be constantly updated as data are avaiable) you can also find monthly aggregation by  county and state as well.
![alt text](https://github.com/siacus/flourishing-i-challenge/blob/main/Happiness_Index.png)
