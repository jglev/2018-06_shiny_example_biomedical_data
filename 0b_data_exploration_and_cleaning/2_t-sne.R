## Explore the use of t-sne with these data for outlier / anomaly detection

# Load libraries ----------------------------------------------------------

source(file.path('0a_helper_functions', 'check_packages.R'), local = TRUE)

check_packages('ggplot2')
check_packages('magrittr')
check_packages('tidyverse')
check_packages('Rtsne')
check_packages('vegalite')

# Load dataset ------------------------------------------------------------

load(file.path('cache', 'cleaned_dataset.Rdata'))
# load(file.path('cache', 'tsne_output.Rdata'))

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

column_names_for_model_matrix <- c(
  "source",
  "sex",
  "ethnicity",
  "race",
  "noted_age",
  ## I'm using resolved rather than resolved_age, since the latter
  ## includes so much missing data.
  "resolved",
  "icd9_general"
)

create_model_matrix <- function(
  filtered_dataset,
  vector_of_column_names
) {
  ## Trying to compute one big matrix froze my computer, so I'm
  ## cbinding individual model matricies instead:
  vector_of_column_names %>% 
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
  dplyr::select_at(column_names_for_model_matrix) %>% 
  dplyr::group_by(`source`) %>% 
  dplyr::do(
    model_matrix = create_model_matrix(., column_names_for_model_matrix)
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

# Join dataset to t-SNE output --------------------------------------------

## Since each row of original data has just one cohort and thus was
## used in just one model, we will join the t-SNE output back to the
## dataset for later ease of use.

pull_tsne_points <- function(
  output_from_tsne = tsne_output,
  column = 'tsne_1d',
  cohort_values_to_keep = NULL
) {
  tsne_output %>% 
    purrr::when(
      !is.null(cohort_values_to_keep) ~ (.) %>% 
        dplyr::filter(source %in% cohort_values_to_keep),
      ~ (.)
    ) %>% 
    dplyr::pull(!!as.name(column)) %>% 
    magrittr::extract2(1) %>% 
    magrittr::extract2('Y')
}

oneD_tsne_plot_points <- tsne_output %>% 
  pull_tsne_points(
    column = 'tsne_1d',
    cohort_values_to_keep = 'cohort1'
  ) %>% 
  as.tibble() %>% 
  dplyr::rename(
    tsne_1d_v1 = V1
  )
twoD_tsne_plot_points <- tsne_output %>% 
  pull_tsne_points(
    column = 'tsne_2d',
    cohort_values_to_keep = 'cohort1'
  ) %>% 
  as.tibble() %>% 
  dplyr::rename(
    tsne_2d_v1 = V1,
    tsne_2d_v2 = V2
  )

row_numbers_to_join_tsne_data_to <- dataset %>% 
  tibble::rowid_to_column('row_number') %>% 
  dplyr::select_at(c('row_number', column_names_for_model_matrix)) %>% 
  na.omit() %>% 
  dplyr::filter(source == 'cohort1') %>%
  dplyr::pull(row_number)

## Create blank columns, which we will fill in below:
dataset %<>% 
  dplyr::mutate(
    tsne_1d_v1 = NA,
    tsne_2d_v1 = NA,
    tsne_2d_v2 = NA
  )

dataset[row_numbers_to_join_tsne_data_to,c(
  'tsne_1d_v1',
  'tsne_2d_v1',
  'tsne_2d_v2'
)] <- dplyr::bind_cols(
  oneD_tsne_plot_points,
  twoD_tsne_plot_points
)

# Save the t-SNE output ---------------------------------------------------

save(tsne_output, file = file.path('cache', 'tsne_output.Rdata'))
