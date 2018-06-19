## Server logic for the Shiny web application.
## This app can be run locally from within RStudio using
## its "Run App" button.

## Load libraries ----------------------------------------------------------

library(DT)
library(shiny)

# Load data ---------------------------------------------------------------

# Following https://shiny.rstudio.com/gallery/plot-interaction-selecting-points.html
mtcars_subset <- mtcars %>% 
  tibble::as.tibble() %>% 
  dplyr::select(mpg, cyl, disp, hp, wt, am, gear)

## Define server logic -----------------------------------------------------

## Define server-side logic
shinyServer(function(input, output) {
  ## TODO: Get Vega working in Shiny.
  output$scatterplot <- renderPlot({
    mtcars_subset %>% ggplot(aes(wt, mpg)) + geom_point()
    # vegalite::vegalite(
    #   export = TRUE,  # For 
    #   renderer = 'svg'  # For png ('canvas') vs. svg ('svg') exporting
    # ) %>%
    #   cell_size(500, 300) %>%
    #   add_data(mtcars_subset) %>%
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
      brushedPoints(mtcars_subset, input$scatterplot_brush)
    } else if (!is.null(input$scatterplot_click)) {
      # message("Printing click")
      # message(input$scatterplot_click)
      near_points <- nearPoints(
        mtcars_subset,
        input$scatterplot_click, 
        addDist = TRUE
      )
      
      ## If a click is not near a point, show all points. Otherwise,
      ## show just the selected point(s).
      if (nrow(near_points) > 0) {
        near_points
      } else {
        mtcars_subset
      }
    } else {
      # mtcars_subset %>% dplyr::slice(0)  ## Return just the headings
      mtcars_subset
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
