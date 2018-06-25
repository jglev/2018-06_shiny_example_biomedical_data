# Example Dynamic Communication of Biomedical Data

An example approach to dynamically communicating biomedical data.

## Objective

Create a web page that both summarizes the composition of and highlights the outliers (interesting cases) of a cohort.

## Desired Elements

- [X] Dynamic web page that lays out the various components in a clean and easy to follow manner
- [X] Have a header that includes the name of the cohort and placeholder for other descriptors or metadata
- [O] Include at least 2 meaningful visuals using Vega (https://vega.github.io/vega/)
- [X] Summary tables and other sections can be used to highlight certain points
- [ ] Have a section or callout to outliers  
    (The t-SNE output is intended as this. Age-SD-based-outlier detection could also be implemented in the Age scatterplot, but that could be a further step in a project like this.)
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
  - After substantial research, I've come to the conclusion that Vega does not yet have a robust (or any) API for selections. Selections (e.g., brushing / click-and-drag selection of scatterplot points) is possible in Vega, but publishing that back to R, e.g., does not seem feasible yet.
  	- See:
  		- https://github.com/vega/vega-lite/issues/1830, "APIs to interact with Selection's Data and Signals," which is open.
  		- The view API (https://vega.github.io/vega/docs/api/view/) seems promising for this purpose, but not yet well-documented enough to use, and almost wholly undocumented in the secondary landscape of StackExchange, etc.
  			- I do have a StackOverflow Question open about this topic: https://stackoverflow.com/questions/50902820/are-selections-in-vega-visualizations-accessible-from-outside-vega
	- GGPlot2, by contrast, *does* now have brush-selection abilities: https://shiny.rstudio.com/gallery/plot-interaction-selecting-points.html
	- Thus, t-sne output will be in ggplot2 for now, while I can still satisfy the overall goal of having at least two Vega visualizations that are dynamically driven from user selection of t-sne scatterplot points.
- Break up ICD 10 codes by general category? (https://www.webpt.com/blog/post/understanding-icd-10-code-structure)
