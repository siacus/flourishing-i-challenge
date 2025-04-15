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
The selected 46 dimensions of the global human flourishing framework and the way to extract them from tweets are listed below:

1. **Happiness** – the text expresses some level of happiness  
2. **Resilience** – a text expressing capability of withstanding or recovering from difficulties  
3. **Self-esteem** – the text expresses level of confidence in one's worth or abilities  
4. **Life Satisfaction** – the text expresses satisfaction with one's life as a whole  
5. **Fear of future** – the text expresses worry about one's condition in the next years  
6. **Vitality** – the text expresses feelings of strength and activity  
7. **Having energy** – the text expresses that one feels full of energy  
8. **Positive functioning** – the text expresses that one feels capable to do many things  
9. **Expressing job satisfaction** – the text expresses satisfaction with one's present job, all things considered  
10. **Expressing optimism** – the text expresses optimism about one's condition in the medium-run future  
11. **Peace with thoughts and feelings** – the text expresses a general feeling of peace with one's thoughts and feelings  
12. **Purpose in life** – the text expresses understanding of one's purpose in life. In other terms, it expresses the feeling that the things one is doing in his/her life are worthwhile  
13. **Depression** – the text expresses that one is bothered by the following problems: Little interest or pleasure in doing things; Feeling down, depressed or hopeless  
14. **Anxiety** – the text expresses that one is bothered by the following problems: Feeling nervous, anxious or on edge; Not being able to stop or control worrying  
15. **Suffering** – the text expresses the experience of any type of physical or mental suffering  
16. **Feeling pain** – the text expresses the experience of bodily pain currently or in the recent past  
17. **Expressing altruism** – the text expresses willingness to do things that bring advantages to others, even if it results in disadvantage for him/herself  
18. **Loneliness** – the text expresses feelings of loneliness  
19. **Quality of relationship** – the text expresses satisfaction about one's relationships  
20. **Belonging to society** – the text expresses a sense of belonging in one's community  
21. **Expressing gratitude** – the text expresses one's feelings of gratitude for many reasons  
22. **Expressing trust** – the text expresses feeling of trust towards people in one's community  
23. **Feeling trusted** – the text expresses that people in one's community trust one another  
24. **Balance in the various aspects of own life** – the text indicates that the various aspects of one's life are, in general, well balanced  
25. **Mastery (ability, capability)** – the text expresses one's feeling of being very capable in most things one does in life  
26. **Perceiving discrimination** – the text expresses the feeling of being discriminated against because of one's belonging to any group  
27. **Feeling loved by God** – the text expresses one's feeling of being loved or cared for by God, the main god worshipped, or the spiritual force that guides one's life  
28. **Belief in God** – the text expresses belief in one God, or more than one god, or an impersonal spiritual force  
29. **Religious criticism** – the text expresses that people in one's religious community are critical of one's person or one's lifestyle  
30. **Spiritual punishment** – the text expresses the feeling of God, a god, or a spiritual force as a punishing entity  
31. **Feeling religious comfort** – the text expresses finding strength or comfort in one's religion or spirituality  
32. **Financial/material worry** – the text expresses one's worry about being able to meet normal monthly living expenses  
33. **Life after death belief** – the text expresses one's belief in life after death  
34. **Volunteering** – the text expresses one's habit of volunteering one's time to an organization  
35. **Charitable giving/helping** – the text expresses one's habit of donating money to a charity  
36. **Seeking for forgiveness** – the text expresses propensity to forgive those who have hurt us  
37. **Feeling having a political voice** – the text expresses the feeling of having a say about what the government does  
38. **Expressing government approval** – the text expresses approval of the job performance of the national government of one's country  
39. **Having hope** – the text expresses feelings of hope about the future, despite challenges  
40. **Promoting good** – the text shows the propensity of acting to promote good in all circumstances, even in difficult and challenging situations  
41. **Expressing delayed gratification** – the text expresses ability to give up some happiness now for greater happiness later 
42. **PTSD (Post-traumatic stress disorder)** – the text expresses the tendency to be frequently bothered by the big threats to life one has witnessed or personally experienced during one's life  
43. **Describing smoking related health issues** – the text expresses the habit of smoking many cigarettes every day  
44. **Describing drinking related health issues** – the text expresses the habit of frequently drinking full drinks of any kind of alcoholic beverage  
45. **Describing health limitations** – the text indicates any health problems that prevent one from doing any of the things people that age normally can do  
46. **Expressing empathy** – the text expresses ability to share other people's feelings or experiences by imagining what it would be like to be in their own situation  


For the Spatial AI Challenge 2024, the project focuses on a U.S.-based subset of 2.2 billion geolocated tweets, building interactive dashboards and scalable workflows. To further push the boundaries of spatial AI, the project explores two additional themes—migration mood and perceived corruption—in parallel with well-being.

These three domains—well-being, migration mood, and corruption—are often studied in pairs (e.g., migration mood vs. happiness, migration and corruption, or corruption and well-being). This project advances the field by examining the dynamic interplay among all three, offering new insights into their complex interrelationships across both space and time.

[Here](https://platform.i-guide.io/notebooks/e870ad3a-8c19-43e1-8323-fb8c39d12898) is the notebook submitted to the i-Guide platform that contains a copy of the [source notebook](flourishing.ipynb) stored in this github repository.

You can play with a dashboard based on this data [here](https://askdataverse.shinyapps.io/FlourishingMap/) and the corresponding github repository is [here](https://github.com/siacus/flourishingmap).

## Repository Contents

1. ```scripts```: This directory contain [scripts](./scripts) for

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



