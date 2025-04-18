# The Geography of Human Flourishing - Github Repository

Team of the [Spatial AI-Challenge 2024](https://i-guide.io/spatial-ai-challenge-2024/): Stefano Iacus, Devika Jain, Andrea Nasuto.

Other co-authors related to this project: Giuseppe Porro, Marcello Carammia, Andrea Vezzulli.

## Project Summary

[The Human Flourishing Program](https://hfh.fas.harvard.edu) is a research initiative dedicated to studying and promoting human flourishing across diverse domains of life. It integrates interdisciplinary research from the social sciences, philosophy, psychology, and related fields to advance understanding and practical applications. 
The [Global Flourishing Study](https://hfh.fas.harvard.edu/global-flourishing-study), is a five-year longitudinal study involving approximately 200,000 participants from over 20 geographically and culturally diverse countries and territories. It measures global human flourishing across six key dimensions:

- Happiness and life satisfaction
- Mental and physical health
- Meaning and purpose
- Character and virtue
- Close social relationships
- Material and financial stability

### Our Approach

The Geography of Human Flourishing research project aims to analyze Harvard’s archive of 10 billion geolocated tweets (spanning from 2010 to mid-2023) through the lens of the six dimensions of human flourishing defined by the Global Flourishing Study (GFS).

Using [fine-tuned large language models (LLMs)](https://arxiv.org/abs/2411.00890), the project extracts 46 indicators aligned with these six domains, generating high-resolution spatio-temporal datasets.  The initiative also develops interactive tools to visualize and analyze these patterns across space and time.

For the Spatial AI Challenge 2024, the project focuses on a U.S.-based subset of 2.2 billion geolocated tweets, building interactive dashboards and scalable workflows. To further push the boundaries of spatial AI, the project explores two additional themes—migration mood and perceived corruption—in parallel with well-being.

These three domains—well-being, migration mood, and corruption—are often studied in pairs (e.g., migration mood vs. happiness, migration and corruption, or corruption and well-being). This project advances the field by examining the dynamic interplay among all three, offering new insights into their complex interrelationships across both space and time.

[Here](https://platform.i-guide.io/notebooks/e870ad3a-8c19-43e1-8323-fb8c39d12898) is the notebook submitted to the i-Guide platform that contains a copy of the [source notebook](flourishing.ipynb) stored in this github repository.

You can play with a dashboard based on this data [here](https://askdataverse.shinyapps.io/FlourishingMap/) and the corresponding github repository is [here](https://github.com/siacus/flourishingmap).

## Our Dataset

The Harvard Center for Geographic Analysis (CGA) maintains the **GeoTweet Archive v2.0**, a global dataset of tweets spanning across time, geography, and language. This archive covers the period from 2010 to July 12, 2023, when Twitter transitioned its API access from free to a paid model. The archive contains approximately 10 billion multilingual tweets from around the world (see map below) and is hosted on Harvard University’s High Performance Computing (HPC) cluster. For more details about the archive and how to access it, please visit __[Geotweets Archive v2.0](https://dataverse.harvard.edu/dataset.xhtml?persistentId=doi:10.7910/DVN/3NCMB6)__.

![Geotweets.png](https://github.com/siacus/flourishing-i-challenge/blob/main/Geotweets_distribution.png)

## Repository Contents

1. ```scripts```: This directory contain [scripts](./scripts) for

* finetuning of LLMs
* classification of raw tweets
* construction of statistical indicators

These scripts should work on Anvil, Delta-AI and FASRC clusters. But read below before trying to run them. The [ReadMe](https://github.com/siacus/flourishing-i-challenge/blob/main/scripts/ReadMe.md) of the scripts folder contains simplified set of instructions for replicability and some notes that we find useful. Some tweaking are inevitable, like changing the account, allocation, SLURM partition names and folders. These scripts assume you have an account on an ACCESS Anvil or Harvard FARSC.

2. Instructions to run the notebook
* [requirements.txt](./requirements.txt): List of Python dependencies required to run the notebook.
*  [flourishing.ipynb](./flourishing.ipynb): Jupyter Notebook detailing the following information about the project: _Introduction, Dataset Description, Methodology, Results, Interpretation, Next Steps, Lessons Learned, Publications, Acknowledgements and Appendix_.
## Publications

1. Carpi, T., Hino, A., Iacus, S.M., Porro, G. (2022) The Impact of COVID-19 on Subjective Well-Being: Evidence from Twitter Data, Journal of Data Science 21(4), 761-780, __[DOI](https://jds-online.org/journal/JDS/article/1297/info)__.
2. Iacus, S. M., & Porro, G. (Eds.). (2023) Subjective well-being and social media. Routledge. ISBN: 9781032043166 __[LINK](https://www.routledge.com/Subjective-Well-Being-and-Social-Media/Iacus-Porro/p/book/9781032043166?srsltid=AfmBOopDDrHgFJs8bT0jeAnPVwZZfGRq9aUFL6z2fZmQxmMZEqIp9LU_)__.
3. Chai, Y., Kakkar, D., Palacios, J. et al. (2023) Twitter Sentiment Geographical Index Dataset, Sci Data 10, 684, __[DOI](https://www.nature.com/articles/s41597-023-02572-7)__.
4. Carammia, M., Iacus, S.M., Porro, G. (2024) Rethinking Scale: The Efficacy of Fine-Tuned Open-Source LLMs in Large-Scale Reproducible Social Science Research, ArXiv, __[DOI](https://arxiv.org/abs/2411.00890)__.

## License

This project is licensed under the MIT License.

## Acknowledgements

We extend our sincere thanks to the I-GUIDE team for the opportunity to participate in this challenge. We are especially grateful to Diana Sackton, Shaowen Wang, Anand Padmanabhan, Rajesh Kalyanam, Noah S. Oller Smith, and Nattapon Jaroenchai for their ongoing support and guidance throughout the project. We also acknowledge the Harvard FASRC team, with special thanks to Paul Edmon, for providing the additional computing resources that were essential to this work. We would like to thank Xiaokang Fu from the Harvard Center for Geographic Analysis (CGA) for his assistance in enriching U.S. tweets with Census geography. Finally, we would like to thank Parag Khanna from AlphaGeo for generously sharing the county-level climate and resilience index data for the United States.



