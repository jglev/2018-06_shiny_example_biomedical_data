## Explore the use of t-sne with these data for outlier / anomaly detection

# Load libraries ----------------------------------------------------------

source(file.path('0a_helper_functions', 'check_packages.R'), local = TRUE)

check_packages('broom')
check_packages('ggplot2')
check_packages('tidyverse')
check_packages('Rtsne')
check_packages('vegalite')

# Load dataset ------------------------------------------------------------

load(file.path('cache', 'cleaned_dataset.Rdata'))

# Implement t-sne ---------------------------------------------------------

## See https://www.analyticsvidhya.com/blog/2017/01/t-sne-implementation-r-python/
## and https://www.r-bloggers.com/playing-with-dimensions-from-clustering-pca-t-sne-to-carl-sagan/
## For more re: t-sne interpretation, see https://distill.pub/2016/misread-tsne/

# Structure data ----------------------------------------------------------

## From the RBloggers example above, I can see that Rtsne expects data
## to be in wide format. 
## https://www.displayr.com/using-t-sne-to-visualize-data-before-prediction/
## indicates that tsne is fine with numerical data (perhaps normalized), while
## the RBloggers example indicates that it is fine with categorical data (in a
## wide matrix format).

create_model_matrix <- function(filtered_dataset) {
  ## Trying to compute one big matrix froze my computer, so I'm
  ## cbinding individual model matricies instead:
  c(
    "sex",
    "ethnicity",
    "race",
    "noted_age",
    ## I'm using resolved rather than resolved_age, since the latter
    ## includes so much missing data.
    "resolved",
    # "icd9_top",
    "icd9_general"# ,
    # "icd9_code"
  ) %>% 
    purrr::map_dfc(
      function(x) {
        filtered_dataset %>% 
          ## Remove missing data, so that all returned columns are of
          ## equal length:
          na.omit() %>% 
          ## Scale noted_age, following https://stats.stackexchange.com/a/218153,
          ## which notes that scaling allows t-sne to treat all variables more
          ## equally, rather than giving higher attention to larger-variance
          ## variables:
          dplyr::mutate(
            noted_age = scale(noted_age, center = TRUE, scale = TRUE)
          ) %>% 
          model.matrix(formula(paste0('~ 0 + ', x)), .) %>% 
          dplyr::as_tibble()
      }
    ) %>% as.matrix()
}

tsne_output <- dataset %>% 
  dplyr::group_by(`source`) %>% 
  dplyr::do(
    model_matrix = create_model_matrix(.)
  )
# tsne_output

# Implement t-SNE ---------------------------------------------------------

run_tSNE <- function(model_matrix, number_of_dimensions = 2) {
  ## This follows https://www.r-bloggers.com/playing-with-dimensions-from-clustering-pca-t-sne-to-carl-sagan/
  set.seed(3)
  tsne_model <- Rtsne::Rtsne(
    model_matrix,
      ## Take a sample for faster tsne development
      # model_matrix[sample(1:nrow(model_matrix), 500, replace = FALSE),],
    theta = 0.8,
    pca = TRUE,
    check_duplicates = FALSE,  ## We've already deduplicated
    perplexity = 40,
    dims = number_of_dimensions,
    verbose = TRUE,
    ## For max_iter, default is 1000, but a test with the full dataset
    ## and verbose = TRUE showed error convergence after 700.
    max_iter = 1000
  )
  tsne_model
  ## Using just rows 1:1000 takes 42 seconds on my dev. laptop.
}

## Run the actual t-SNEs, with 1D and 2D output, for each cohort
tsne_output %<>% 
  dplyr::mutate(
    tsne_1d = run_tSNE(model_matrix, number_of_dimensions = 1) %>% 
      list(),
    tsne_2d = run_tSNE(model_matrix, number_of_dimensions = 2) %>% 
      list()
  )

# Save the t-SNE output ---------------------------------------------------

save(tsne_output, file = file.path('cache', 'tsne_output.Rdata'))


# Plot the output ---------------------------------------------------------

## Use if dims == 2 above
tsne_model$Y %>% 
  as_tibble() %>% 
  ggplot(aes(x = V1, y = V2)) + 
    geom_point(size = 0.25)


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


