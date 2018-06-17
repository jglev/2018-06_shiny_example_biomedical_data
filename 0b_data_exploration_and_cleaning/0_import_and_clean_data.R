# Import and Clean the Dataset

# Load packages -----------------------------------------------------------

source('0a_helper_functions/check_packages.R')

check_packages('magrittr')
check_packages('tidyverse')


# Import the data ---------------------------------------------------------

## We have two cohorts, each in a discrete directory, and each with two
## CSV files to be joined.

dataset <- list.dirs(
  path = 'data',
  full.names = TRUE,
  recursive = TRUE
) %>% 
  magrittr::extract(-1) %>%  ## Remove the 'data' directory itself
  purrr::map_dfr(function(x) {
    ## Extract the cohort name from the filepath:
    cohort_name <- x %>% 
      stringr::str_split('/', simplify = TRUE) %>% 
      magrittr::extract(2)
    
    ## Read the patient data, and join it to the problems data,
    ## recording source:
    readr::read_csv(file.path(x, 'patients.csv')) %>% 
      dplyr::mutate(source = cohort_name) %>% 
      left_join(
        readr::read_csv(file.path(x, 'problems.csv')),
        by = 'pat_id'
      )
  })

# Clean the imported data -------------------------------------------------

## Correct variable types:
dataset %<>% 
  dplyr::mutate(
    sex = as.factor(sex),
    ethnicity = as.factor(ethnicity),
    source = as.factor(source),
    icd9_code = as.factor(icd9_code)
  )

## Remove duplicate rows:
dataset %<>% 
  dplyr::distinct()

## Record whether issue was resolved:
## This can be directly inferred from whether resolved_age is not NA,
## but it may be more conceptually straightforward for code review
## and analysis to make it into its own column, especially when
## making data wide from long later.
dataset %<>% 
  dplyr::mutate(
    resolved = ifelse(!is.na(resolved_age), TRUE, FALSE)
  )

## Split ICD 9 codes into more granular categories:
dataset %<>% 
  dplyr::mutate(
    icd9_top = as.factor(substring(icd9_code, 1, 1)),
    icd9_general = as.factor(substring(icd9_code, 1, 3))
  )

## Examine the imported and cleaned dataset:
# dplyr::glimpse(dataset)
# View(dataset)
