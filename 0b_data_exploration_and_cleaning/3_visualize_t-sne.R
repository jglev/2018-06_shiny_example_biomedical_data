## Visualize t-SNE output.

# Load libraries ----------------------------------------------------------

source(file.path('0a_helper_functions', 'check_packages.R'), local = TRUE)

check_packages('ggplot2')
check_packages('tidyverse')
check_packages('vegalite')

# Load dataset ------------------------------------------------------------

load(file.path('cache', 'tsne_output.Rdata'))

# Plot the output ---------------------------------------------------------

pull_tsne_points <- function(
  output_from_tsne = tsne_output,
  column = 'tsne_1d'
) {
  tsne_output %>% 
    dplyr::filter(source == 'cohort1') %>% 
    dplyr::pull(!!as.name(column)) %>% 
    magrittr::extract2(1) %>% 
    magrittr::extract2('Y')
}

oneD_tsne_plot_points <- tsne_output %>% pull_tsne_points('tsne_1d')
twoD_tsne_plot_points <- tsne_output %>% pull_tsne_points('tsne_2d')

twoD_tsne_plot_points %>% 
  as_tibble() %>% 
  ggplot(aes(x = V1, y = V2)) + 
  geom_point(size = 0.25)

oneD_tsne_plot_points %>%
  as_tibble() %>%
  ggplot(aes(x = V1, y = 0)) +
  geom_point(size = 0.25)

# Explore implementation in Vega ------------------------------------------

vega_spec <- vegalite::vegalite(
  export = TRUE,  # For 
  renderer = 'svg'  # For png ('canvas') vs. svg ('svg') exporting
) %>%
  cell_size(500, 300) %>%
  add_data(tsne_model$Y %>% as_data_frame() %>% slice(1:5)) %>%
  encode_x("V2", "quantitative") %>%
  encode_y("V1", "quantitative") %>%
  mark_point() %>% 
  to_spec() %>% 
  jsonlite::fromJSON()

## Add interactivity, following https://vega.github.io/vega-lite/docs/selection.html#type,
## as it seems not to yet be implemented in the R package
vega_spec$selection$pts$type <- 'interval'

## Produces a working vega spec, usable at https://vega.github.io/editor/#/edited
vega_spec %>% jsonlite::toJSON(auto_unbox = TRUE) %>% clipr::write_clip()


## Using variables 1:12 (i.e., excluding age and ICD9 codes)
## does give me more standard t-sne 2D visualization results.

## Use if dims == 1 above
# tsne_model$Y %>% 
#   as_tibble() %>% 
#   ggplot(aes(x = V1, y = 0)) + 
#   geom_point(size = 0.25)


