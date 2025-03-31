# The Geography of Human Flourishing - Project Notebook
Team: Stefano Iacus, Devika Jain, Andrea Nasuto

## Project Summary
The Human Flourishing Program is a research initiative whose goal is to study and promote human flourishing across a broad spectrum of life domains, integrating interdisciplinary research in social sciences, philosophy, psychology, and other fields. The Global Flourishing Study (GFS), a five-year traditional longitudinal data collection on approximately 200,000 participants from 20+ geographically and culturally diverse countries and territories, measures global human flourishing in six areas: Happiness and life satisfaction; Mental and physical health; Meaning and purpose; Character and virtue; Close social relationships and Material and financial stability. Our research plan is to analyze Harvard’s collection of 10 billion geolocated tweets from 2010 to mid-2023. The project will apply large language models, to extract 46 human flourishing dimensions across the six areas of human flourishing, generate high-resolution spatio-temporal indicators and produce interactive tools to visualize and analyze the result.

## Dataset Used:

The Harvard Center for Geographic Analysis (CGA) maintains the Geotweet Archive, a global record of tweets spanning time, geography, and language. The Archive extends from 2010 to July 12, 2023 when Twitter stopped allowing free access to its API, transitioning API access to a paid model. The number of tweets in the collection totals approximately 10 billion multilingual global tweets (see map below), and it is stored on Harvard University’s High Performance Computing (HPC) cluster. For more information about the archive and how to acces it please click see our Dataverse page [Geotweets Archive v2.0](https://dataverse.harvard.edu/dataset.xhtml?persistentId=doi:10.7910/DVN/3NCMB6). 

![alt text](https://github.com/siacus/flourishing-i-challenge/blob/main/map_tweets_language.png)

## Our Analysis

This is a simple notebook that shows (partial) results of the LLM analysis of the 2.2 billion subset of USA tweets extracted from the global Harvard's [Geotweets Archive v2.0](https://dataverse.harvard.edu/dataset.xhtml?persistentId=doi:10.7910/DVN/3NCMB6). Each raw tweets from the archive was further enriched with 8,180,866 [Census Blocks Geography](https://www.census.gov/cgi-bin/geo/shapefiles/index.php). The analysis was run at Census ID level and aggreagated at County and State level by year. Our computations for entire the US and full time period of 13 years are ongoing. However, You can explore partial results (year >= 2012) for some of the 46 flourishing dimensions. We suggest to explore ```Happiness`` for the moment. See sample results for Happiness Index in the image below. On the main [data repository](https://huggingface.co/datasets/siacus/flourishing) on Huggingface (that will be constantly updated as data are avaiable) you can also find monthly aggregation by  county and state as well.
![alt text](https://github.com/siacus/flourishing-i-challenge/blob/main/Happiness_Index.png)
