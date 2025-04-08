# The Geography of Human Flourishing - Project Notebook
Team of the [Spatial AI-Challenge 2024](https://i-guide.io/spatial-ai-challenge-2024/): Stefano Iacus, Devika Jain, Andrea Nasuto.

Other co-authors related to this project: Giuseppe Porro, Marcello Carammia, Andrea Vezzulli.

## Project Summary

[The Human Flourishing Program](https://hfh.fas.harvard.edu) is a research initiative whose goal is to study and promote human flourishing across a broad spectrum of life domains, integrating interdisciplinary research in social sciences, philosophy, psychology, and other fields. The [Global Flourishing Study](https://hfh.fas.harvard.edu/global-flourishing-study) (GFS), a five-year traditional longitudinal data collection on approximately 200,000 participants from 20+ geographically and culturally diverse countries and territories, measures global human flourishing in six areas: Happiness and life satisfaction; Mental and physical health; Meaning and purpose; Character and virtue; Close social relationships and Material and financial stability.

## Our Approach

The Geography of Human Flourishing research plan is to analyze Harvard’s collection of 10 billion geolocated tweets from 2010 to mid-2023 in view of the six areas identified by the GFS. The project applies [fine-tuned large language models (LLMs)](https://arxiv.org/abs/2411.00890) to extract 46 human flourishing dimensions across the six areas, generate high-resolution spatio-temporal indicators.  The project will apply large language models, to extract 46 human flourishing dimensions across the six areas of human flourishing, generate high-resolution spatio-temporal indicators and produce interactive tools to visualize and analyze the result. For the Spatial AI-Challenge 2024, the project analyzes a subset of 2.2 billion tweets geolocalized in the USA and generates  interactive visualization tools.

Given the scalability challenge, this project analyzes in parallel also the so-called *migration mood* and the perception of *corruption*. Well-being, migration mood and corruption are topics that are tradionally studied in couples (migration mood vs happiness; migration and corruption; corruption and well-being). This research project will study the interplay of these three large areas of research.

## Methodology



## The Twitter Dataset

The Harvard Center for Geographic Analysis (CGA) maintains the Geotweet Archive, a global record of tweets spanning time, geography, and language. The Archive extends from 2010 to July 12, 2023 when Twitter stopped allowing free access to its API, transitioning API access to a paid model. The number of tweets in the collection totals approximately 10 billion multilingual global tweets (see map below), and it is stored on Harvard University’s High Performance Computing (HPC) cluster. For more information about the archive and how to acces it please click see our Dataverse page [Geotweets Archive v2.0](https://dataverse.harvard.edu/dataset.xhtml?persistentId=doi:10.7910/DVN/3NCMB6). 

![alt text](https://github.com/siacus/flourishing-i-challenge/blob/main/map_tweets_language.png)


## Deliverables of The Project

This is a simple notebook that shows (partial) results of the LLM analysis of the 2.2 billion subset of USA tweets extracted from the global Harvard's [Geotweets Archive v2.0](https://dataverse.harvard.edu/dataset.xhtml?persistentId=doi:10.7910/DVN/3NCMB6). Each raw tweets from the archive was further enriched with 8,180,866 [Census Blocks Geography](https://www.census.gov/cgi-bin/geo/shapefiles/index.php). The analysis was run at Census ID level and aggreagated at County and State level by year. Our computations for entire the US and full time period of 13 years are ongoing. However, You can explore partial results (year >= 2012) for some of the 46 flourishing dimensions. We suggest to explore ```Happiness`` for the moment. See sample results for Happiness Index in the image below. On the main [data repository](https://huggingface.co/datasets/siacus/flourishing) on Huggingface (that will be constantly updated as data are avaiable) you can also find monthly aggregation by  county and state as well.
![alt text](https://github.com/siacus/flourishing-i-challenge/blob/main/Happiness_Index.png)

## How this Repository is Structured

The project involves three main steps:
* finetuning of LLMs
* classification of raw tweets
* construction of statistical indicators
and for each step we provide the [scripts](./scripts) in python and R used to perform each of them. Please check each individual subfolder.

## More about this Project

This repository contain partial results from [The Geography of Human Flourishing Project](https://i-guide.io/spatial-ai-challenge-2024/accepted-abstracts/) analysis for the years 2010-2023 and all scripts and models used.

This project is one of the 10 national projects awarded within the [Spatial AI-Challange 2024](https://i-guide.io/spatial-ai-challenge-2024/), an international initiative at the crossroads of geospatial science and artificial intelligence.

## Related Publications

* Iacus, S. M., & Porro, G. (Eds.). (2023). Subjective well-being and social media. Routledge. https://www.routledge.com/Subjective-Well-Being-and-Social-Media/Iacus-Porro/p/book/9781032043166
* Gao, Y., Iacus, S. M., & Porro, G. (2023). Social media data for urban well-being indices. Journal of Data Science, 21(1), 69–89. https://doi.org/10.6339/23-JDS1297
* Chai, Y., Kakkar, D., Palacios, J. et al. Twitter Sentiment Geographical Index Dataset. Sci Data 10, 684 (2023). https://doi.org/10.1038/s41597-023-02572-7

## Acknowledgements

We would like to thank the I-GUIDE team for the opportunity to participate in this challenge. Special thanks to the following members of the I-GUIDE team for their continuous support and guidance throughout the project: Diana Sackton, Shaowen Wang, Anand Padmanabhan, Rajesh Kalyanam, Noah S. Oller Smith, and Nattapon Jaroenchai.
We also like to acknowledge the Harvard FASRC team, especially Paul Edmon, for providing the additional computing resources essential to this work. Finally, we would like to thank Parag Khanna from AlphaGeo for generously sharing the county-level resilience indicator data for the United States.




