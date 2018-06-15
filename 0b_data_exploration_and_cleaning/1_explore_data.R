# Explore the dataset, and generate ideas to communicate to stakeholders

# Explore the dataset -----------------------------------------------------

dataset %>% 
  dplyr::group_by(source, sex, ethnicity, race) %>% 
  dplyr::summarize(
    age_mean = mean(age, na.rm = FALSE),
    age_sd = sd(age, na.rm = FALSE)
    # icd9_code
  )