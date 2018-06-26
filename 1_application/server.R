## Server logic for the Shiny web application.
## This app can be run locally from within RStudio using
## its "Run App" button.

## Load libraries ----------------------------------------------------------

source(file.path('..', '0a_helper_functions', 'check_packages.R'), local = TRUE)

check_packages('alluvial')
check_packages('DT')
check_packages('ggplot2')
check_packages('magrittr')
check_packages('shiny')
check_packages('shinyjs')
check_packages('tidyverse')
check_packages('vegalite')

# Load data ---------------------------------------------------------------

## This will load an object called dataset
load(file.path('..', 'cache', 'cleaned_dataset.Rdata'))

## Define server logic -----------------------------------------------------

## Define server-side logic
shinyServer(function(input, output) {
  
  # Render general information about the dataset ----------------------------
  
  output$introduction_to_dataset <- renderText({
    paste0(
      'This interface allows exploring data on ',
      dataset %>% 
        select(source) %>% 
        distinct() %>% 
        nrow() %>% 
        scales::comma(),
      ' cohorts, comprising ',
      dataset %>% nrow() %>% scales::comma(),
      ' total cases across ',
      dataset %>% select(pat_id) %>% 
        distinct() %>% 
        nrow() %>% 
        scales::comma(),
      ' individual patients.'
    )
  })
  
  output$cohort_header <- renderText({
    req(input$cohort)
    
    paste0("Cohort: ", input$cohort)
  })
  
  # Render UI filter elements -----------------------------------------------
  
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
  
  # Filter data -------------------------------------------------------------
  
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
      dplyr::filter(!is.na(tsne_2d_v1) & !is.na(tsne_2d_v2)) %>% 
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
  debounce(1500)  ## Wait X ms until updating, allowing more time for input

  # Create t-SNE scatterplot ------------------------------------------------
  
  output$tsne_2d_scatterplot <- renderPlot({
    show("loading_content")  ## Show the loading notice
    
    req(input$cohort)
    
    vis <- dataset %>% 
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
    
    # vegalite::vegalite(
    #   export = TRUE,  # For
    #   renderer = 'svg'  # For png ('canvas') vs. svg ('svg') exporting
    # ) %>%
    #   cell_size(500, 300) %>%
    #   add_data(data_subset()) %>%
    #   encode_x('wt', 'quantitative') %>%
    #   encode_y('mpg', 'quantitative') %>%
    #   mark_point()
    
    hide("loading_content")  ## Hide the loading notice
    
    vis
  })
  
  # Select points from t-SNE scatterplot ------------------------------------
  
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
      if (nrow(near_points) > 1) {
        near_points
      } else {
        data_subset()
      }
    } else {
      # data_subset() %>% dplyr::slice(0)  ## Return just the headings
      data_subset()
    }
  })
  
  # Create output based on t-SNE point selection ----------------------------
  
  # Table of cases ----------------------------------------------------------
  
  output$plot_selection <- DT::renderDataTable({
    plot_selection() %>% 
      select(
        pat_id,
        sex,
        ethnicity,
        race,
        icd9_code,
        # icd9_general,
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
        `ICD-9 Code` = icd9_code
        # `ICD-9 General Category` = icd9_general
      )
  })
  
  # Age histogram -----------------------------------------------------------
  
  age_mean_and_sd <- reactive({
    plot_selection() %>% 
      dplyr::select(noted_age) %>% 
      dplyr::summarize(
        mean = mean(noted_age),
        sd = sd(noted_age)
      )
  })
  
  output$selection_age_histogram <- renderPlot({
    plot_selection() %>%
    ggplot(aes(x = noted_age)) +
    geom_histogram(bins = 50) +
    geom_vline(
      xintercept = age_mean_and_sd()$mean,
      color = 'slategray'
    ) +
    geom_vline(
      xintercept = age_mean_and_sd()$mean + 3*age_mean_and_sd()$sd,
      color = 'orchid'
    ) + 
    geom_vline(
      xintercept = age_mean_and_sd()$mean - 3*age_mean_and_sd()$sd,
      color = 'orchid'
    ) + 
    xlab('Age in Days') +
    ylab('Number of Cases')
    # renderVegalite({
      # vegalite::vegalite(
      #   export = TRUE,  # For
      #   renderer = 'canvas'  # For png ('canvas') vs. svg ('svg') exporting
      # ) %>%
      #   cell_size(800, 400) %>%
      #   add_data(data_subset()) %>%
      #   encode_x("noted_age", "quantitative") %>%
      #   axis_y(title = "Age in Days", grid = FALSE) %>%
      #   encode_y("*", "quantitative", aggregate = "count") %>%
      #   bin_x(maxbins = 50) %>%
      #   mark_bar()
    })
  
  # ICD-9 bar chart ---------------------------------------------------------
  
  output$selection_icd9_top_chart <- renderPlot({
    plot_selection() %>%
      ggplot(aes(x = icd9_top)) +
      geom_bar() +
      xlab('ICD-9 First Digit/Letter') +
      ylab('Number of Cases') + 
      coord_flip()
    # renderVegalite({
      # vegalite::vegalite(
      #   export = TRUE,  # For
      #   renderer = 'canvas'  # For png ('canvas') vs. svg ('svg') exporting
      # ) %>%
      #   cell_size(800, 400) %>%
      #   add_data(data_subset()) %>%
      #   encode_x("race", "quantitative") %>%
      #   axis_y(title = "Race", grid = TRUE) %>%
      #   axis_y(title = "Age in Days", grid = FALSE) %>%
      #   encode_y("*", "quantitative", aggregate = "count") %>%
      #   mark_bar()
  })
  
  # Multi-tiered flowing (Sankey / Alluvial) visualization ------------------

  output$sankey_diagram <- renderPlot({
    dataset_alluvial <- plot_selection() %>% 
      dplyr::select(sex, race, resolved) %>% 
      dplyr::group_by(sex, race, resolved) %>% 
      dplyr::summarize(n = n()) %>% 
      # dplyr::mutate(frequency = n / sum(n)) %>% 
      ungroup() %>% 
      dplyr::mutate(
        sex = as.character(sex) %>% tidyr::replace_na('(Not recorded)'),
        race = as.character(race) %>% tidyr::replace_na('(Not recorded)'),
        # ethnicity = as.character(ethnicity) %>% tidyr::replace_na('(Not recorded)'),
        # resolved = as.character(resolved) %>% tidyr::replace_na('(Unknown)'),
        color = if_else(resolved == TRUE, 'green', 'red'),
        # color = 'cadetblue2'  ## The closest I could find to CHOP's logo's color : )
        resolved = if_else(resolved == TRUE, 'Yes', 'No')
      )
    
    if (dataset_alluvial %>% nrow() > 0) {
      if (dataset_alluvial %>% nrow() == 1) {
        ## Add a dummy row to the dataset, to avoid an
        ## "incorrect number of dimensions" error, if there is only
        ## one row in the dataset selection.
        dataset_alluvial %<>% 
          dplyr::bind_rows(tibble(
            sex = c(''),
            race = c(''),
            n = c(0),
            color = c('black')
          ))
      }
      
      alluvial(
        dataset_alluvial %>% 
        select(sex, race),
        freq = dataset_alluvial$n,
        col = dataset_alluvial$color,
        cex = 1.0
      )
    } else {
      NULL
    }
  })
  
  # Define cohort comparison charts -----------------------------------------

  create_faceted_bar_plot <- function(categorical_variable) {
    dataset %>% 
      ggplot(aes_string(x = 'source', fill = categorical_variable)) +
      geom_bar(position = 'fill') +
      scale_y_continuous(labels = scales::percent)
  }
  
  output$cohort_comparison_charts <- renderUI({
    list(
      h4('Sex'),
      renderPlot(create_faceted_bar_plot('sex')),
      h4('Race'),
      renderPlot(create_faceted_bar_plot('race')),
      h4('Ethnicity'),
      renderPlot(create_faceted_bar_plot('ethnicity')),
      h4('ICD-9 Diagnosis First Digit / Letter'),
      renderPlot(create_faceted_bar_plot('icd9_top')),
      h4('Was the Case Resolved?'),
      renderPlot(create_faceted_bar_plot('resolved'))
    )
  })
  
})
