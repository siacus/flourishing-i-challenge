# The Geography of Human Flourishing - Github Repository
Team of the [Spatial AI-Challenge 2024](https://i-guide.io/spatial-ai-challenge-2024/): Stefano Iacus, Devika Jain, Andrea Nasuto.

Other co-authors related to this project: Giuseppe Porro, Marcello Carammia, Andrea Vezzulli.

## Project Summary

[The Human Flourishing Program](https://hfh.fas.harvard.edu) is a research initiative whose goal is to study and promote human flourishing across a broad spectrum of life domains, integrating interdisciplinary research in social sciences, philosophy, psychology, and other fields. The [Global Flourishing Study](https://hfh.fas.harvard.edu/global-flourishing-study) (GFS), a five-year traditional longitudinal data collection on approximately 200,000 participants from 20+ geographically and culturally diverse countries and territories, measures global human flourishing in six areas: Happiness and life satisfaction; Mental and physical health; Meaning and purpose; Character and virtue; Close social relationships and Material and financial stability.

## Our Approach

The Geography of Human Flourishing research plan is to analyze Harvard’s collection of 10 billion geolocated tweets from 2010 to mid-2023 in view of the six areas identified by the GFS. The project applies [fine-tuned large language models (LLMs)](https://arxiv.org/abs/2411.00890) to extract 46 human flourishing dimensions across the six areas, generate high-resolution spatio-temporal indicators.  The project will apply large language models, to extract 46 human flourishing dimensions across the six areas of human flourishing, generate high-resolution spatio-temporal indicators and produce interactive tools to visualize and analyze the result. For the Spatial AI-Challenge 2024, the project analyzes a subset of 2.2 billion tweets geolocalized in the USA and generates  interactive visualization tools.

Given the scalability challenge, this project analyzes in parallel also the so-called *migration mood* and the perception of *corruption*. Well-being, migration mood and corruption are topics that are tradionally studied in couples (migration mood vs happiness; migration and corruption; corruption and well-being). This research project will study the interplay of these three large areas of research.

[Here](https://platform.i-guide.io/notebooks/e870ad3a-8c19-43e1-8323-fb8c39d12898) is the notebook submitted to the i-Guide platform that contains a copy of the [source notebook](flourishing.ipynb) stored in this github repository.

## Methodology

## How to build the setup to run inference on Anvil
```
### This will setup you to run inference on fasrc
### Do not use mamba, use conda/minicoda and give the exact same commands or gpu workflow won't work
### how I build the conda environment that I use to fine-tune and inference
module load anaconda
conda create -n jago python=3.10
conda activate jago
pip3 install accelerate peft bitsandbytes transformers trl
pip install huggingface-hub   # this is optional
pip install psutil
#####################################
### HOW TO BUILD llama-cpp-python ###
#####################################
#
### llama-ccp-python is used to run GGUF models in python
### a simple "pip install llama-cpp-python" will not
### install the GPU version
### 1. spin the gpu instance
salloc -p gpu_test --gres=gpu:1 --mem=40G -N 1 -t 2:00:00
### 2. load the modules as in the above
module load modtree/gpu   # default gcc and cuda version too old
module load cuda/11  # the version of cuda and gcc shold match on this cluster
module load gcc/11
module load anaconda
module list
### 3. activate the env to have it installed properly
conda activate jago
### 4. build it. Takes forever
CMAKE_ARGS="-DGGML_CUDA=on" pip install llama-cpp-python
### wait a few hours
```

## The Twitter Dataset

The Harvard Center for Geographic Analysis (CGA) maintains the Geotweet Archive, a global record of tweets spanning time, geography, and language. The Archive extends from 2010 to July 12, 2023 when Twitter stopped allowing free access to its API, transitioning API access to a paid model. The number of tweets in the collection totals approximately 10 billion multilingual global tweets (see map below), and it is stored on Harvard University’s High Performance Computing (HPC) cluster. For more information about the archive and how to acces it please click see our Dataverse page [Geotweets Archive v2.0](https://dataverse.harvard.edu/dataset.xhtml?persistentId=doi:10.7910/DVN/3NCMB6). 

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




