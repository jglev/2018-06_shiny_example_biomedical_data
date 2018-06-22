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

data(mtcars)
dataset <- mtcars

## Define server logic -----------------------------------------------------

## Define server-side logic
shinyServer(function(input, output) {
  
  resample_slider_min <- dplyr::case_when(
    nrow(dataset) > 1000 ~ 1000,
    nrow(dataset) > 100 ~ 100,
    TRUE ~ 1
  )
  resample_slider_max <- nrow(dataset)
  resample_slider_step <- dplyr::case_when(
    nrow(dataset) > 1000 ~ 100,
    nrow(dataset) > 20 ~ 10,
    TRUE ~ 1
  )
  resample_slider_value <- min(
    mean(c(resample_slider_min, resample_slider_max)),
    1000
  )
  
  output$resample_slider <- renderUI({
    sliderInput(
      'sample_size',
      label = "Sample Size",
      min = resample_slider_min,
      max = resample_slider_max,
      ## Tests with tsne show that runs are *much* faster at n ~ 1000
      ## (at the cost of accuracy, but users probably aren't going to
      ## want to wait for tens of minutes for a run to complete). Thus,
      ## we'll set an initial value at max 1000.
      value = resample_slider_value,
      step = resample_slider_step,
      round = TRUE,
      animate = FALSE,
      dragRange = TRUE
    )
  })
  
  resample_data <- function(sample_size = resample_slider_value) {
    dataset %>% 
      tibble::as.tibble() %>% 
      dplyr::select(mpg, cyl, disp, hp, wt, am, gear) %>% 
      dplyr::sample_n(
        as.integer(sample_size)
      )
  }
  
  ## Resample each time the action button is pressed
  data_subset <- eventReactive(input$resample_button, {
    req(input$sample_size)
    resample_data(input$sample_size)
  })
  
  ## TODO: Get Vega working in Shiny.
  output$scatterplot <- renderPlot({
    data_subset() %>% ggplot(aes(wt, mpg)) + geom_point()
    # vegalite::vegalite(
    #   export = TRUE,  # For
    #   renderer = 'svg'  # For png ('canvas') vs. svg ('svg') exporting
    # ) %>%
    #   cell_size(500, 300) %>%
    #   add_data(data_subset()) %>%
    #   encode_x("wt", "quantitative") %>%
    #   encode_y("mpg", "quantitative") %>%
    #   mark_point()
  })
  
  plot_selection <- reactive({
    # Because it's a ggplot2, we don't need to supply xvar or yvar; if this
    # were a base graphics plot, we'd need those.
    if (!is.null(input$scatterplot_brush)) {
      # message("Printing brush")
      # message(input$scatterplot_brush)
      brushedPoints(data_subset(), input$scatterplot_brush)
    } else if (!is.null(input$scatterplot_click)) {
      # message("Printing click")
      # message(input$scatterplot_click)
      near_points <- nearPoints(
        data_subset(),
        input$scatterplot_click, 
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
    plot_selection()
  })
  
  output$selection_histogram <- renderPlot({
    plot_selection() %>% 
      ggplot(aes(x = wt)) +
      geom_histogram(bins = 50)
  })
  
  ## TODO: Implement multi-tiered flowing visualization
  
})
