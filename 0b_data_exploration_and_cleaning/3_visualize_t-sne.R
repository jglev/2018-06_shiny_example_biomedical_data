## Visualize t-SNE output.

# Load libraries ----------------------------------------------------------

source(file.path('0a_helper_functions', 'check_packages.R'), local = TRUE)

check_packages('ggplot2')
check_packages('tidyverse')
check_packages('vegalite')

# Load dataset ------------------------------------------------------------

load(file.path('cache', 'dataset.Rdata'))

# Plot the output ---------------------------------------------------------

dataset %>% 
  dplyr::filter(source == 'cohort1') %>% 
  ggplot(aes(x = tsne_2d_v1, y = tsne_2d_v2)) + 
  geom_point(size = 0.25)

# ## TODO Enhancement: For ease of looking, split the dense 1D line into sections:
# tsne_1d_row_numbers <- dataset %>% 
#   dplyr::filter(source == 'cohort1') %>% 
#   select(tsne_1d_v1) %>% 
#   tibble::rowid_to_column('row_number') %>% 
#   na.omit() %>% 
#   pull(row_number)

dataset %>% 
  dplyr::filter(source == 'cohort1') %>%
  ggplot(aes(x = tsne_1d_v1, y = 0)) +
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


