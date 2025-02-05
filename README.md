# world_happiness_ar
Exploration of the World Happiness Index in R Shiny

## **Project Title:** 
Investigating fish and sugar consumption as they relate to feelings of happiness and prevalence of depressive & anxiety disorders
## **Executive Summary**
It is widely accepted that consumption of fish and seafood have health benefits, and that increased sugar consumption has health consequences. This app aims to investigate the relationship between consumption of those two pieces of a country's diet, the *Happiness Score* for each country*, and the *Sadness Score* for each country. 
Data was sourced from the Gapminder dataset, as well as the Global Burden of Disease database via VizHub. 
*data was not found for all countries across all years for the happiness score, fish consumption, and sugar consumption. Total countries represented:* **150**

## **Motivation**
I know from personal experience that diet can affect your mood. I know how excess sugar intake makes me feel, and want to see the trends represented across the world. Fish and seafood are newer in my own diet, but I want to expand my consumption of fish, and this study may also give extra reason for that. 

## **Data Question**
How do the consumption of sugar and consumption of fish & other seafood products impact mental health? Are there regional or continental variances or trends? Is there a clear global trend? 

## **Minimum Viable Product (MVP)**
* country selector to view data by country
* view showing data for all countries
* regression information & statistical tests run to make inferences
* table showing selected data

## **Schedule (through 2/15/2025)**

1. Get the Data (**finish date**)
2. Clean & Explore the Data (**finish date**)
3. Create Presentation and Shiny App (**finish date**)
4. Internal Demos (2/11/2025)
5. Midcourse Project Presentations (2/15/2025)

## **Data Sources**
[1] Based on free material from [GAPMINDER.ORG](http://GAPMINDER.ORG), CC-BY LICENSE
	- **Main Data Page** :https://www.gapminder.org/data/ 
		*happiness score data* : http://gapm.io/dhapiscore_whr
		*fish & seafood consumption data* : 
		*sugar consumption data* : 
[2] IHME-GBD
Global Burden of Disease Collaborative Network.
Global Burden of Disease Study 2021 (GBD 2021) Results.
Seattle, United States: Institute for Health Metrics and Evaluation (IHME), 2022.
Available from https://vizhub.healthdata.org/gbd-results/.
	*Depressive & Anxiety disorders data* : 

## **Known Issues and Challenges**

- not all countries are represented in all datasets, even from the same source. Some countries also are created or dissolved in the time range specified. 
- many countries are referenced by different names, so sorting and matching may prove difficult. 
- Plotly is a new library for me in R, so learning the nuances that are different from python may be a challenge
- the data question is fairly vague, and although interesting, may not have a useful answer. 
