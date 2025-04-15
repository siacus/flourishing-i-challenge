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

### Our Approach

The Geography of Human Flourishing research project aims to analyze Harvard’s archive of 10 billion geolocated tweets (spanning from 2010 to mid-2023) through the lens of the six dimensions of human flourishing defined by the Global Flourishing Study (GFS).

Using [fine-tuned large language models (LLMs)](https://arxiv.org/abs/2411.00890) , the project extracts 46 indicators aligned with these six domains, generating high-resolution spatio-temporal datasets.  The initiative also develops interactive tools to visualize and analyze these patterns across space and time.

For the Spatial AI Challenge 2024, the project focuses on a U.S.-based subset of 2.2 billion geolocated tweets, building interactive dashboards and scalable workflows. To further push the boundaries of spatial AI, the project explores two additional themes—migration mood and perceived corruption—in parallel with well-being.

These three domains—well-being, migration mood, and corruption—are often studied in pairs (e.g., migration mood vs. happiness, migration and corruption, or corruption and well-being). This project advances the field by examining the dynamic interplay among all three, offering new insights into their complex interrelationships across both space and time.

[Here](https://platform.i-guide.io/notebooks/e870ad3a-8c19-43e1-8323-fb8c39d12898) is the notebook submitted to the i-Guide platform that contains a copy of the [source notebook](flourishing.ipynb) stored in this github repository.

You can play with a dashboard based on this data [here](https://askdataverse.shinyapps.io/FlourishingMap/) and the corresponding github repository is [here](https://github.com/siacus/flourishingmap).

## Repository Contents

1. ```Scipts```: These directory contain scripts for

* finetuning of LLMs
* classification of raw tweets
* construction of statistical indicators

These scripts should work on Anvil, Delta-AI and FASRC clusters. But read below before trying to run them. The [ReadMe](https://github.com/siacus/flourishing-i-challenge/blob/main/scripts/ReadMe.md) of the scripts folder contains simplified set of instructions for replicability and some notes that we find useful. Some tweaking are inevitable, like changing the account, allocation, SLURM partition names and folders. These scripts assume you have an account on an ACCESS Anvil or Harvard FARSC.

2. ```requirements.txt```: List of Python dependencies required to run the notebook.
3. ```flourishing.ipynb```: Jupyter Notebook detailing the following information about the project:

* Introduction
* Dataset Description
* Methodology
* Results
* Interpretation
* Next Steps
* Lessons Learned
* Publications
* Acknowledgements
* Appendix




## License

This project is licensed under the MIT License.



