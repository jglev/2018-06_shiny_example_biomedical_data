# Explore the dataset, and generate ideas to communicate to stakeholders

# Load packages -----------------------------------------------------------

source('0a_helper_functions/check_packages.R')

check_packages('magrittr')
check_packages('tidyverse')

# Load dataset ------------------------------------------------------------

load(file.path('cache', 'cleaned_dataset.Rdata'))

dataset_for_development <- dataset %>% 
  ## Temporarily hard-coding a filter for development:
  filter(`source` == 'cohort1')

# Explore the dataset -----------------------------------------------------

# Rate of resolved cases --------------------------------------------------

dataset_for_development %>% 
  dplyr::group_by(resolved) %>% 
  dplyr::summarise(
    number = n()
  ) %>% 
  dplyr::mutate(
    percent = number / sum(number)
  )

# Amount of missing data --------------------------------------------------

dataset %>% 
  purrr::map_df(
    function(x) {
      is.na(x) %>% sum()
    }
  )

# Age -----------------------------------------------------

dataset_for_development %>% 
  # dplyr::group_by(sex, ethnicity, race) %>% 
  dplyr::summarize(
    noted_age_mean = mean(noted_age, na.rm = TRUE),
    noted_age_sd = sd(noted_age, na.rm = TRUE),
    noted_age_max = max(noted_age, na.rm = TRUE),
    noted_age_min = min(noted_age, na.rm = TRUE)
  )
## The above shows an impossible age min, which should be looked at.
## TODO: Ask whether pre-birth ages are actually valid.

## Even if pre-birth ages are valid, I am filtering data that are at
## impossible ages (assuming that parent issues pre-conception don't
## carry over to children in these data): Hence, anyone with an age
## lower than (to be conservative) 10 months, or 365 * (10/12):

dataset_for_development %>% 
  filter(noted_age >= (365 * (9/12)))

# Find non-standard-age participants --------------------------------------

## TODO: Explore this within finer-grained groups.

dataset_for_development %>% 
    dplyr::filter(
      noted_age > (mean(noted_age) + sd(noted_age)*3) |
        noted_age < (mean(noted_age) - sd(noted_age)*3)
    )

