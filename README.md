# Chinese Inter-County Competition & Pro-Business Policy

Materials for my MA thesis at Fudan University (复旦大学)

The idea is, counties want to attract investment, but firms don't care if they locate in one county or another nearby.
<br>So counties have to compete with one another for firm investment: the more counties, the fiercer competition is.
<br>Some experts (e.g. Cheung, <a href="https://www.degruyter.com/view/j/me.2014.1.issue-1/me-2014-0008/me-2014-0008.xml?format=INT">2014</a>) think inter-county competition is <i>the</i> main reason for China's economic success.

We can measure pro-business policy by the effective tax rate — how much of the federal tax rate is actually enforced.
<br>A problem is, there may be some factor affecting both county density and the tax rate, causing spurious correlation.
<br>For example, an area richer to begin with will have more counties and also more development (which will affect taxes).
<br>To overcome endogeneity, we need a variable correlated with county density, but not economic development.

This study uses geography as an instrumental variable for county density, controlling for development.
<br>I use the software ArcGIS to analyze geographic data for land elevation & agricultural productivity.
<br>Then I use regression analysis with Stata to determine how these influence pro-business policy.

## assembleData.R
<ul>
<li>Works with geographic data extracted using ArcGIS, contained in Excel files (available on request)</li>
<li>Cleans counties with missing values, salvages values by using data for neighbouring counties</li>
<li>Uses run length encoder to repeat geographic data for firms in each county </li>
<li>After running, the data are assembled into a regression that can be run in R or Stata</li>
</ul>

## density.R
<ul>
<li>Uses county adjacency & centroid data extracted with ArcGIS (available on request)</li>
<li>To reduce search space, uses neighbours within a given 'depth' (e.g. neighbours of neighbours is depth 2)</li>
<li>Density for a given county is its number of neighbours whose centroid is within 100km of that county's centroid</li>
</ul>

## robustness.R
<ul>
<li>Reassembles data using only adjacent neighbours (sharing a border), rather than within 100km</li>
<li>Experiments with different specifications for tax enforcements from the firm-level data</li>
<li>Reassembles data for a subset of counties for which GDP data is available</li>
</ul>
