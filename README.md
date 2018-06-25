# Example Dynamic Communication of Biomedical Data

An example approach to dynamically communicating biomedical data.

## Objective

Create a web page that both summarizes the composition of and highlights the outliers (interesting cases) of a cohort.

## Desired Elements

- [X] Dynamic web page that lays out the various components in a clean and easy to follow manner
- [X] Have a header that includes the name of the cohort and placeholder for other descriptors or metadata
- [X] Include at least 2 meaningful visuals using Vega (https://vega.github.io/vega/)  
  The code in this repository includes examples of using an R API to vegalite to render visualizations using Vega. However, tests as I was developing this codebase revealed that Vega takes substantially longer to render than ggplot2 (5+ seconds). Given that speed was a desired element of this challenge, and that I have implemented visualizations in Vega here (but have left the code commented out), I think it reasonable to decide to use ggplot2 to render visualizations, while still checking this box.
- [X] Summary tables and other sections can be used to highlight certain points
- [X] Have a section or callout to outliers  
    (The t-SNE output is intended as this. Age-SD-based-outlier detection is also now implemented.)
	- [ ] Include the reason why it is an outlier based on the method used
	- [ ] For example, a value is 3 times the stdev of the other points
- [X] Web server component (any language) that serves up the data dynamically to power the page
	- [X] Some elements may be computed on the server, some may be done in JavaScript
	- [ ] Async requests from the browser to the server are preferred
	- [ ] The web page should load in under a second  
	  The page itself loads in ~1 second; however, GGplot2 takes approximately 3 seconds to render the main t-SNE plot. Precomputing this did not help.
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

## Issues / Places for Further Development

- To check: Are these data public / ok to make public?
- data_subset() is an event that launches both on load and then one second after load, causing load time to be longer. This could be optimized.
- As mentioned above, currently, `ggplot2` is used in place of `vega`, as the latter took substantially longer to render on my development laptop.
- The emphasis on visual inspection of the t-SNE scatterplot means that this interface is not particularly (or perhaps at all) accessible to clinicians and researchers who have limited vision. Researching and developing approaches to convey the t-SNE output (and scatterplot output more generally) to users through a screen reader could be a fruitful future step. This could also be accomplished, e.g., but running the t-SNE output through a clustering algorithm such as k-means, and then summarizing the output of that.

## Style guide



