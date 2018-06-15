# Example Dynamic Communication of Biomedical Data

An example approach to dynamically communicating biomedical data.

## Objective

Create a web page that both summarizes the composition of and highlights the outliers (interesting cases) of a cohort.

## Desired Elements

- [ ] Dynamic web page that lays out the various components in a clean and easy to follow manner
- [ ] Have a header that includes the name of the cohort and placeholder for other descriptors or metadata
- [ ] Include at least 2 meaningful visuals using Vega (https://vega.github.io/vega/)
- [ ] Summary tables and other sections can be used to highlight certain points
- [ ] Have a section or callout to outliers
	- [ ] Include the reason why it is an outlier based on the method used
	- [ ] For example, a value is 3 times the stdev of the other points
- [ ] Web server component (any language) that serves up the data dynamically to power the page
	- [ ] Some elements may be computed on the server, some may be done in JavaScript
	- [ ] Async requests from the browser to the server are preferred
	- [ ] The web page should load in under a second
- [ ] *Bonus:* a separate page that compares the two cohorts

## Notes

- Data cleaning is not included in the main dashboard code.
- Values are not hard-coded.

## Todo / Ideas

- For anomaly detection: Perhaps incorporate t-SNE?
  - [Google Talks overview](https://medium.com/@Zelros/anomaly-detection-with-t-sne-211857b1cd00)
  - [Conceptual text overview, with implementation instructions for R and Python](https://www.analyticsvidhya.com/blog/2017/01/t-sne-implementation-r-python/)
- Break up ICD 10 codes by general category? (https://www.webpt.com/blog/post/understanding-icd-10-code-structure)
