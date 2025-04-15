# The Geography of Human Flourishing - Github Repository
Team of the [Spatial AI-Challenge 2024](https://i-guide.io/spatial-ai-challenge-2024/): Stefano Iacus, Devika Jain, Andrea Nasuto.

Other co-authors related to this project: Giuseppe Porro, Marcello Carammia, Andrea Vezzulli.

## Project Summary

[The Human Flourishing Program](https://hfh.fas.harvard.edu) is a research initiative dedicated to studying and promoting human flourishing across diverse domains of life. It integrates interdisciplinary research from the social sciences, philosophy, psychology, and related fields to advance understanding and practical applications. The [Global Flourishing Study](https://hfh.fas.harvard.edu/global-flourishing-study) (GFS), is a five-year longitudinal study involving approximately 200,000 participants from over 20 geographically and culturally diverse countries and territories. It measures global human flourishing across six key dimensions:

- Happiness and life satisfaction
- Mental and physical health
- Meaning and purpose
- Character and virtue
- Close social relationships
- Material and financial stability

## Our Approach

The Geography of Human Flourishing research project aims to analyze Harvard’s archive of 10 billion geolocated tweets (spanning from 2010 to mid-2023) through the lens of the six dimensions of human flourishing defined by the Global Flourishing Study (GFS).

Using [fine-tuned large language models (LLMs)](https://arxiv.org/abs/2411.00890) , the project extracts 46 indicators aligned with these six domains, generating high-resolution spatio-temporal datasets.  The initiative also develops interactive tools to visualize and analyze these patterns across space and time.

For the Spatial AI Challenge 2024, the project focuses on a U.S.-based subset of 2.2 billion geolocated tweets, building interactive dashboards and scalable workflows. To further push the boundaries of spatial AI, the project explores two additional themes—migration mood and perceived corruption—in parallel with well-being.

These three domains—well-being, migration mood, and corruption—are often studied in pairs (e.g., migration mood vs. happiness, migration and corruption, or corruption and well-being). This project advances the field by examining the dynamic interplay among all three, offering new insights into their complex interrelationships across both space and time.

[Here](https://platform.i-guide.io/notebooks/e870ad3a-8c19-43e1-8323-fb8c39d12898) is the notebook submitted to the i-Guide platform that contains a copy of the [source notebook](flourishing.ipynb) stored in this github repository.

You can play with a dashboard based on this data [here](https://askdataverse.shinyapps.io/FlourishingMap/) and the corresponding github repository is [here](https://github.com/siacus/flourishingmap).

## Methodology

There are three models running in parallel that classify the same tweet and produce numbers;
* human flourishing: e.g., happiness: low (-1), medium (0.5) and high (1), NA indicates that none of the 46 dimensions of human flourishing hase been found;
* migration mood: pro-migration (+1), anti-migration (-1), neutral (0), not about migration (NA);
* perception of corruption: about corruption (1) or not (0).

For each dimension, the calculation is done by aggregating and summing by regional area (census area, county, state), and period (month, year). The calculation is essentially summing up the values and normalizing by the total number of relevant/in topic tweets.

Therefore, all values vary in (-1,+1) with the exception of ```corruption``` which is alwayws a number in [0,1].

The [FlourishingMap Explorer](https://github.com/siacus/flourishingmap) further apply two transforms to improve contrast as most numbers are close to zero. The transformations are: ```log_indicator = log(2+indicator)``` and ```log_corruption = log(1+corruption)``` and then the statistics are normalized again to [-1,+1] (after centering for ```log(2)``` for all indicators but "corruption").


## The Twitter Dataset

The Harvard Center for Geographic Analysis (CGA) maintains the GeoTweet Archive, a global dataset of tweets spanning across time, geography, and language. This archive covers the period from 2010 to July 12, 2023, when Twitter transitioned its API access from free to a paid model. The archive contains approximately 10 billion multilingual tweets from around the world (see map below) and is hosted on Harvard University’s High Performance Computing (HPC) cluster.

For more details about the archive and how to access it, please visit __[Geotweets Archive v2.0](https://dataverse.harvard.edu/dataset.xhtml?persistentId=doi:10.7910/DVN/3NCMB6)__.

![alt text](https://github.com/siacus/flourishing-i-challenge/blob/main/map_tweets_language.png)

## Additional Datasets for Correlation Analysis

### County Level Climate and Resilience Index for USA (Source: AlphaGeo)

[AlphaGeo's Global Climate Risk and Resilience Index](https://docs.alphageo.ai/products/climate-risk-and-resilience-index/the-alphageo-advantage-climate-risk-and-resilience-index) is a unique two-in-one scoring suite of (1) Physical Risk and (2) Resilience-adjusted Risk. Together, these deliver risk and resilience assessments at scale. Explore the dataset [here](https://www.washingtonpost.com/climate-environment/interactive/2024/climate-risk-resilience-factors-us-cities/)
![alt text](https://github.com/siacus/flourishing-i-challenge/blob/main/climate_risk.png)


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

* Carpi, T., Hino, A.,  Iacus, S.M., Porro, G. (2022) The Impact of COVID-19 on Subjective Well-Being: Evidence from Twitter Data, Journal of Data Science 21(4), 761-780, DOI:[10.6339/22-JDS1066](https://doi.org/10.6339/22-JDS1066).
* Iacus, S. M., & Porro, G. (Eds.). (2023) Subjective well-being and social media. Routledge. ISBN: [9781032043166](https://www.routledge.com/Subjective-Well-Being-and-Social-Media/Iacus-Porro/p/book/9781032043166)
* Chai, Y., Kakkar, D., Palacios, J. et al. (2023) Twitter Sentiment Geographical Index Dataset, Sci Data 10, 684, DOI:[10.1038/s41597-023-02572-7](https://doi.org/10.1038/s41597-023-02572-7).
* Carammia, M., Iacus, S.M., Porro, G. (2024) Rethinking Scale: The Efficacy of Fine-Tuned Open-Source LLMs in Large-Scale Reproducible Social Science Research, ArXiv, DOI:[arXiv.2411.00890](https://doi.org/10.48550/arXiv.2411.00890).


## Acknowledgements

We would like to thank the I-GUIDE team for the opportunity to participate in this challenge. Special thanks to the following members of the I-GUIDE team for their continuous support and guidance throughout the project: Diana Sackton, Shaowen Wang, Anand Padmanabhan, Rajesh Kalyanam, Noah S. Oller Smith, and Nattapon Jaroenchai. We also like to acknowledge the Harvard FASRC team, especially Paul Edmon, for providing the additional computing resources essential to this work. Finally, we would like to thank Parag Khanna from AlphaGeo for generously sharing the county-level climate and resilience index data for the United States.




