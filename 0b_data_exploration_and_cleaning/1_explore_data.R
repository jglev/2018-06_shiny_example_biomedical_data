# Explore the dataset, and generate ideas to communicate to stakeholders

# Load dataset ------------------------------------------------------------

load(file.path('cache', 'cleaned_dataset.Rdata'))

# Explore the dataset -----------------------------------------------------

dataset %>% 
  dplyr::group_by(source, sex, ethnicity, race) %>% 
  dplyr::summarize(
    age_mean = mean(noted_age, na.rm = FALSE),
    age_sd = sd(noted_age, na.rm = FALSE)
    # icd9_code
  )
