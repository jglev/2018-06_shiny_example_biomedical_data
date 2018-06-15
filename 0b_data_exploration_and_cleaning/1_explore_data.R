# Explore the dataset, and generate ideas to communicate to stakeholders

dataset_for_development <- dataset %>% 
  ## Temporarily hard-coding a filter for development:
  filter(`source` == 'cohort1')

# Rate of resolved cases --------------------------------------------------

dataset_for_development %>% 
  dplyr::group_by(resolved) %>% 
  dplyr::summarise(
    number = n()
  ) %>% 
  dplyr::mutate(
    percent = number / sum(number)
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


