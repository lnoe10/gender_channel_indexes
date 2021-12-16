# Clearinghouse (Gender data focus) Indexes
This repository contains scripts and input/output files to update and generate the values found in the "Results" section of the [Gender data focus page](https://smartdatafinance.org/gender) of the Clearinghouse for Financing Development Data for all [IDA-eligible countries](https://ida.worldbank.org/en/about/borrowing-countries).

## List of indexes
### OECD Social Institutions and Gender Index
See R script for exact specifications. We use the overall index score  
Data source: [OECD](https://stats.oecd.org/Index.aspx?DataSetCode=SIGI2019)  
Additional calculations: Overall SIGI score is converted to rank equivalence. For example, lowest score becomes max number of countries with data. Then percent rank is calculated on rank. For example, lowest score becomes 0, highest score becomes 100.

### Open Data Watch Open Gender Data Index
See R script for exact specification. We use the overall index score  
Data Source: Open Data Watch (not public yet)  
Additional calculations: N/A

### Women, Business and the Law
See R script for exact specification. We use the overall index score  
Data Source: World Bank API or [Report website](https://wbl.worldbank.org/en/wbl-data)  
Additional calculations: N/A

### Statistical Performance Indicators
These values are acquired through the World Bank API and imported into Clearinghouse relational database elsewhere.

## Additional notes
For each of the data series above, we use the most recent data available.  
For each of the data series above, we compute the highest value of *all* countries, not just IDA-eligible and this value is marked as "Highest value for any country" on bar chart visualization. Future iterations may compute regional averages instead.  
Regional aggregates are computed dynamically by clearinghouse application, as described in Data Visualization specification files.
