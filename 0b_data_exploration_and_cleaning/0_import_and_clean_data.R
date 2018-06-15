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

## If I understand correctly, and resolved_age is to be used in place
## of noted_age, combine the two into a column:
dataset %<>% 
  dplyr::mutate(
    age = ifelse(!is.na(resolved_age), resolved_age, noted_age)
  )

## Examine the imported and cleaned dataset:
# dplyr::glimpse(dataset)
# View(dataset)

# Explore the dataset -----------------------------------------------------

dataset %>% 
  dplyr::group_by(source, sex, ethnicity, race) %>% 
  dplyr::summarize(
    age_mean = mean(age, na.rm = FALSE),
    age_sd = sd(age, na.rm = FALSE)
    # icd9_code
  )




