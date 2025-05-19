## Project: Investigate the FBI Gun Dataset


[![](https://img.shields.io/badge/linkedin-@Shilin_Li-orange.svg?colorA=abcdef&logo=data:image/jpeg;base64,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)](https://www.linkedin.com/in/shilin-li-40474777/)


### Introduction


The data comes from the FBI's National Instant Criminal Background Check System. The NICS is used by to determine whether a prospective buyer is eligible to buy firearms or explosives. Gun shops call into this system to ensure that each customer does not have a criminal record or isn’t otherwise ineligible to make a purchase. The data has been supplemented with state level data from [census.gov](https://www.census.gov).

![alt text](https://images.pexels.com/photos/1260563/pexels-photo-1260563.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=650&w=940)


(Image is from a copyright-free website: https://www.pexels.com/royalty-free-images/.)


- The [NICS data](https://d17h27t6h515a5.cloudfront.net/topher/2017/November/5a0a4db8_gun-data/gun-data.xlsx) is found in one sheet of an .xlsx file. It contains the number of firearm checks by month, state, and type.
- The [U.S. census data]( https://d17h27t6h515a5.cloudfront.net/topher/2017/November/5a0a554c_u.s.-census-data/u.s.-census-data.csv) is found in a .csv file. It contains several variables at the state level. Most variables just have one data point per state (2016), but a few have data for more than one year.


| Table of Contents |
| :--- |
| <a href='#Prerequisites'> Prerequisites </a> 🔍📜 | 
| <a href='#Design'> Design </a>  📐 |
| <a href='#Conclusions'> Conclusions </a>  📌 |
| <a href='#License'> License </a> 🔖 |


<a id='Prerequisites'></a>

### Prerequisites


![](https://img.shields.io/badge/platform-ios-green.svg?colorA=abcdef)


- Python 3.6.3
- Jupyter Notebook
- Anaconda-Navigator


<a id='Design'></a>

### Design


![](https://img.shields.io/badge/language-Python-orange.svg)


**_Step One_** - Choose Data Set


Click this [link](https://docs.google.com/document/d/e/2PACX-1vTlVmknRRnfy_4eTrjw5hYGaiQim5ctr9naaRd4V9du2B5bxpd8FEH3KtDgp8qVekw7Cj1GLk1IXdZi/pub?embedded=True) to download the corresponding data.

**_Step Two_** - Get Organized


This project eventually contain:


- The report communicating any findings;
- Any Python code used during the analysis;
- The data set;


**_Step Three_** - Analyze


Brainstorm some questions that could be answered using the data set, then start answering those questions, we would mainly focus on looking at the relationships between multiple variables. 


<a id='Conclusions'></a>

### Conclusions


In current study, a good amount of profound analysis has been carried out. Prior to each step, deailed instructions was given and interpretions was also provided afterwards. The dataset included 2 tables, but they have to be loaded by different measures. The data was ranging from 1998 to 2017, which consisted of detailed information of registered gun. Based on such substantial data, the analysis would be more reliable as opposed to small scale analysis.
The limitations of current study were obvious as well, data was seperated into two tables which could affect the process of analysis. On the other hand, the population estimation were only recorded for 2010 and 2016, which limit some analysis to a small range, same for many other parameters, such as "Foreign born persons, percent", "Veterans, 2011-2015", etc.


<a id='License'></a>

## License 


[![MIT Licence](https://badges.frapsoft.com/os/mit/mit.svg?v=103)](https://github.com/Shilin0806/Investigate_the_FBI_Gun_Dataset/blob/master/LICENSE)
