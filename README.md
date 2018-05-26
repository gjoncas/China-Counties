# Chinese Inter-County Competition and Pro-Business Policy

Materials for my MA thesis at Fudan University (复旦大学)

The idea is, counties want to attract investment, but firms don't care if they locate in one county or another nearby.
<br>So counties have to compete with one another for firm investment: the more counties, the fiercer competition is.
<br>Some experts (e.g. Cheung, <a href="https://www.degruyter.com/view/j/me.2014.1.issue-1/me-2014-0008/me-2014-0008.xml?format=INT">2014</a>) think inter-county competition is <i>the</i> main reason for China's economic success.

We can measure pro-business policy by the effective tax rate — how much of the federal tax rate is actually enforced.
<br>A problem is, there may be some factor affecting both county density and the tax rate, causing spurious correlation.
<br>For example, an area richer to begin with will have more counties and also more development (which will affect taxes).
<br>To overcome endogeneity, we need a variable correlated with county density, but not economic development.

This study uses geography as an instrumental variable for county density, controlling for development.
<br>I'll use the software ArcGIS to analyze geographic data for land elevation & agricultural productivity.
<br>Then I'll use regression analysis with Python to determine how these influence pro-business policy.


## Updates
18.04.12: Added slides for thesis proposal
<br>18.05.26: Updated précis, added new slides
