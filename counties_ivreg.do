import excel "C:\Users\Graham\Desktop\Thesis\Regression\regression.xlsx", sheet("Sheet1") firstrow
// gen povlite = poverty * lights
// ivregress 2sls tax_rate lights poverty povlite (density = geo_var agri_prod rivers), r

ivregress 2sls tax_rate lights (density = geo_var agri_prod rivers) [pweight=1/weight], cluster(county) first
ivregress 2sls tax_rate lights poverty (density = geo_var agri_prod rivers) [pweight=1/weight], cluster(county) first

import excel "C:\Users\Graham\Desktop\Thesis\Regression\Robustness\robustness-adjacent.xlsx", sheet("Sheet1") firstrow
reg tax_rate adjacent lights [pweight=1/weight], cluster(county)
ivregress 2sls tax_rate lights (adjacent = geo_var agri_prod rivers) [pweight=1/weight], cluster(county)

import excel "C:\Users\Graham\Desktop\Thesis\Regression\Robustness\robustness-gdp.xlsx", sheet("Sheet1") firstrow
gen loggdp = log(gdp)
ivregress 2sls tax_rate lights (density = geo_var agri_prod) [pweight=1/weight], cluster(county) first
ivregress 2sls tax_rate loggdp (density = geo_var agri_prod) [pweight=1/weight], cluster(county) first

import excel "C:\Users\Graham\Desktop\Thesis\Regression\Robustness\tax2.xlsx", sheet("Sheet1") firstrow
ivregress 2sls tax2 lights (density = geo_var agri_prod) [pweight=1/weight], cluster(county)

\\reg tax_rate density lights, r
\\reg density geo_var agri_prod lights rivers, r
\\ivregress 2sls tax_rate lights (density = geo_var agri_prod rivers), r