## Explore the use of t-sne with these data for outlier / anomaly detection

## See https://www.analyticsvidhya.com/blog/2017/01/t-sne-implementation-r-python/
## and https://www.r-bloggers.com/playing-with-dimensions-from-clustering-pca-t-sne-to-carl-sagan/

# Load packages -----------------------------------------------------------

check_packages('ggplot2')
check_packages('Rtsne')

# Structure data ----------------------------------------------------------

## From the RBloggers example above, I can see that Rtsne expects data
## to be in wide format. 
## https://www.displayr.com/using-t-sne-to-visualize-data-before-prediction/
## indicates that tsne is fine with numerical data (perhaps normalized), while
## the RBloggers example indicates that it is fine with categorical data (in a
## wide matrix format).

## Trying to compute one big matrix froze my computer, so I'm
## cbinding individual model matricies instead:

model_matrix <- c(
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
      dataset_for_development %>% 
        ## Remove missing data, so that all returned columns are of
        ## equal length:
        na.omit() %>% 
        model.matrix(formula(paste0('~ 0 + ', x)), .) %>% 
        dplyr::as_tibble()
    }
  ) %>% as.matrix()
# model_matrix %>% str()

# Implement t-SNE ---------------------------------------------------------

## This follows https://www.r-bloggers.com/playing-with-dimensions-from-clustering-pca-t-sne-to-carl-sagan/
set.seed(3)
system.time(
  tsne_model <- Rtsne::Rtsne(
    # model_matrix,
      ## Take a sample for faster tsne development
      model_matrix[sample(1:nrow(model_matrix), 5000, replace = FALSE),c(1:14, 16:744)],
    theta = 0.8,
    pca = TRUE,
    check_duplicates = FALSE,  ## We've already deduplicated
    perplexity = 40,
    dims = 2,
    verbose = TRUE
    ## For max_iter, default is 1000, but a test with the full dataset
    ## and verbose = TRUE showed error convergence after 700.
    # max_iter = 700
  )
)
## Using just rows 1:1000 takes 42 seconds on my dev. laptop.

# str(tsne_model)

# Plot the output ---------------------------------------------------------

## Use if dims == 2 above
tsne_model$Y %>% 
  as_tibble() %>% 
  ggplot(aes(x = V1, y = V2)) + 
    geom_point(size = 0.25)

## Using variables 1:12 (i.e., excluding age and ICD9 codes)
## does give me more standard t-sne 2D visualization results.

## Use if dims == 1 above
# tsne_model$Y %>% 
#   as_tibble() %>% 
#   ggplot(aes(x = V1, y = 0)) + 
#   geom_point(size = 0.25)


