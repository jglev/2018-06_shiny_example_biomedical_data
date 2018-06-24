## Server logic for the Shiny web application.
## This app can be run locally from within RStudio using
## its "Run App" button.

## Load libraries ----------------------------------------------------------

source(file.path('..', '0a_helper_functions', 'check_packages.R'), local = TRUE)

check_packages('DT')
check_packages('ggplot2')
check_packages('shiny')
check_packages('vegalite')

# Load data ---------------------------------------------------------------

## This will load an object called dataset
load(file.path('..', 'cache', 'cleaned_dataset.Rdata'))

## Define server logic -----------------------------------------------------

## Define server-side logic
shinyServer(function(input, output) {
  
  # resample_slider_min <- dplyr::case_when(
  #   nrow(dataset) > 1000 ~ 1000,
  #   nrow(dataset) > 100 ~ 100,
  #   TRUE ~ 1
  # )
  # resample_slider_max <- nrow(dataset)
  # resample_slider_step <- dplyr::case_when(
  #   nrow(dataset) > 1000 ~ 100,
  #   nrow(dataset) > 20 ~ 10,
  #   TRUE ~ 1
  # )
  # resample_slider_value <- min(
  #   mean(c(resample_slider_min, resample_slider_max)),
  #   1000
  # )
  # 
  # output$resample_slider <- renderUI({
  #   sliderInput(
  #     'sample_size',
  #     label = 'Sample Size',
  #     min = resample_slider_min,
  #     max = resample_slider_max,
  #     ## Tests with tsne show that runs are *much* faster at n ~ 1000
  #     ## (at the cost of accuracy, but users probably aren't going to
  #     ## want to wait for tens of minutes for a run to complete). Thus,
  #     ## we'll set an initial value at max 1000.
  #     value = resample_slider_value,
  #     step = resample_slider_step,
  #     round = TRUE,
  #     animate = FALSE,
  #     dragRange = TRUE
  #   )
  # })
  # 
  # resample_data <- function(sample_size = resample_slider_value) {
  #   dataset %>% 
  #     tibble::as.tibble() %>% 
  #     dplyr::select(mpg, cyl, disp, hp, wt, am, gear) %>% 
  #     dplyr::sample_n(
  #       as.integer(sample_size)
  #     )
  # }
  # 
  # ## Resample each time the action button is pressed
  # data_subset <- eventReactive(input$resample_button, {
  #   req(input$sample_size)
  #   resample_data(input$sample_size)
  # })
  
  get_levels <- function(column_name) {
    dataset %>% pull(!!as.name(column_name)) %>% levels()
  }
  
  cohorts <- get_levels('source')
  sexes <- get_levels('sex')
  races <- get_levels('race')
  ethnicities <- get_levels('ethnicity')
  icd9_generals <- get_levels('icd9_general')
  
  output$cohort_filter <- renderUI({
    selectInput(
      'cohort',
      label = 'Cohort',
      choices = cohorts,
      selected = cohorts[1],
      multiple = FALSE
    )
  })
  
  output$filter_parameters <- renderUI({
    list(
      selectInput(
        'sex',
        label = 'Sex',
        choices = sexes,
        multiple = TRUE
      ),
      selectInput(
        'race',
        label = 'Race',
        choices = races,
        multiple = TRUE
      ),
      selectInput(
        'ethnicity',
        label = 'Ethnicity',
        choices = ethnicities,
        multiple = TRUE
      ),
      selectInput(
        'icd9_general',
        label = 'ICD-9 General Category',
        choices = icd9_generals,
        multiple = TRUE
      ),
      selectInput(
        'resolved',
        label = 'Resolved',
        choices = list('Yes' = TRUE, 'No' = FALSE),
        multiple = TRUE
      ),
      sliderInput(
        'noted_age',
        label = 'Age at Initial Incident Note',
        min = dataset %>% pull(noted_age) %>% min(),
        max = dataset %>% pull(noted_age) %>% max(),
        value = c(
          dataset %>% pull(noted_age) %>% min(),
          dataset %>% pull(noted_age) %>% max()
        ),
        dragRange = TRUE
      )
    )
  })
  
  filter_from_input <- function(lhs, input_name, column_to_filter) {
    lhs %>% 
      purrr::when(
        length(input[[input_name]]) > 0 ~ (.) %>% 
          dplyr::filter(
            !!as.name(column_to_filter) %in% input[[input_name]]
          ),
        ~ (.)
      )
  }
  
  ## Get dataset matching rows:
  data_subset <- reactive({
    dataset %>% 
      tibble::rowid_to_column('row_number') %>% 
      filter_from_input('cohort', 'source') %>% 
      filter_from_input('sex', 'sex') %>% 
      filter_from_input('race', 'race') %>% 
      filter_from_input('ethnicity', 'ethnicity') %>% 
      filter_from_input('icd9_general', 'icd9_general') %>% 
      filter_from_input('resolved', 'resolved') %>% 
      purrr::when(
        length(input$noted_age) == 2 ~ (.) %>% 
          dplyr::filter(
            noted_age >= input$noted_age[1] &
              noted_age <= input$noted_age[2]
          ),
        ~ (.)
      )
  }) %>% 
  debounce(1000)  ## Wait X ms until updating, allowing more time for input

  # Create t-SNE scatterplot ------------------------------------------------
  
  output$tsne_2d_scatterplot <- renderPlot({
    req(input$cohort)
    
    dataset %>% 
      dplyr::filter(source == input$cohort) %>% 
      ggplot(aes(x = tsne_2d_v1, y = tsne_2d_v2)) + 
      geom_point(size = 0.25, alpha = 0.01) +
      geom_point(
        data = data_subset(),
        aes(x = tsne_2d_v1, y = tsne_2d_v2),
        color = '#D01C65',
        alpha = 1.0,
        size = 0.25
      ) +
      xlab('Factor 1') + 
      ylab('Factor 2')
    
    # data_subset() %>% ggplot(aes(wt, mpg)) + geom_point()
    
    # vegalite::vegalite(
    #   export = TRUE,  # For
    #   renderer = 'svg'  # For png ('canvas') vs. svg ('svg') exporting
    # ) %>%
    #   cell_size(500, 300) %>%
    #   add_data(data_subset()) %>%
    #   encode_x('wt', 'quantitative') %>%
    #   encode_y('mpg', 'quantitative') %>%
    #   mark_point()
  })
  
  plot_selection <- reactive({
    # Because it's a ggplot2, we don't need to supply xvar or yvar; if this
    # were a base graphics plot, we'd need those.
    if (!is.null(input$tsne_2d_scatterplot_brush)) {
      # message('Printing brush')
      # message(input$tsne_2d_scatterplot_brush)
      brushedPoints(data_subset(), input$tsne_2d_scatterplot_brush)
    } else if (!is.null(input$tsne_2d_scatterplot_click)) {
      # message('Printing click')
      # message(input$tsne_2d_scatterplot_click)
      near_points <- nearPoints(
        data_subset(),
        input$tsne_2d_scatterplot_click, 
        addDist = TRUE
      )
      
      ## If a click is not near a point, show all points. Otherwise,
      ## show just the selected point(s).
      if (nrow(near_points) > 0) {
        near_points
      } else {
        data_subset()
      }
    } else {
      # data_subset() %>% dplyr::slice(0)  ## Return just the headings
      data_subset()
    }
  })
  
  output$plot_selection <- DT::renderDataTable({
    plot_selection() %>% 
      select(
        pat_id,
        sex,
        ethnicity,
        race,
        icd9_code,
        icd9_general,
        noted_age,
        resolved_age,
        resolved
      ) %>% 
      dplyr::rename(
        `Patient ID` = pat_id,
        `Sex` = sex,
        `Ethnicity` = ethnicity,
        `Race` = race,
        `Age at Beginning of Issue` = noted_age,
        `Age at Resolution of Issue` = resolved_age,
        `Was Case Resolved?` = resolved,
        `ICD-9 Code` = icd9_code,
        `ICD-9 General Category` = icd9_general
      )
  })
  
  output$selection_histogram <- renderPlot({
    plot_selection() %>% 
      ggplot(aes(x = noted_age)) +
      geom_histogram(bins = 50) + 
      xlab('Age in Days') + 
      ylab('Number of Cases')
  })
  
  ## TODO: Implement multi-tiered flowing visualization
  
})
