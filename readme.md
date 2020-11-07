# Map of Who Is Wearing Masks in the U.S

Mask-Wearing Survey Data was published by the New York Times: https://github.com/nytimes/covid-19-data/tree/master/mask-use.
Estimates from The New York Times are based on roughly 250,000 interviews conducted by Dynata from July 2 to July 14, 2020.

The New York Times article link: https://www.nytimes.com/interactive/2020/07/17/upshot/coronavirus-face-mask-map.html.

## compute the chance of someone you met in a random encounter wears mask

The chance of someone you met in a random encounter wears mask is calculated by assuming that survey respondents 
- who answered 'Always' were wearing masks all of the time, 
- those who answered 'Frequently' were wearing masks 80 percent of the time, 
- those who answered 'Sometimes' were wearing masks 50 percent of the time, 
- those who answered 'Rarely' were wearing masks 20 percent of the time and 
- those who answered 'Never' were wearing masks none of the time.

pWear = 1(ALWAYS=1) + 0.8*1(FREQUENTLY=1) + 0.5*1(SOMETIMES=1) + 0.2*1(RARELY=1) + 0*1(NEVER=1)

R Code __nyt_maskSurvey.R__ generates the map with color-coded $pWear$ values.