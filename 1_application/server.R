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
  output$plot1 <- renderPlot({
    mtcars_subset %>% ggplot(aes(wt, mpg)) + geom_point()
  })
  
  output$click_selection <- renderPrint({
    # Because it's a ggplot2, we don't need to supply xvar or yvar; if this
    # were a base graphics plot, we'd need those.
    nearPoints(mtcars_subset, input$plot1_click, addDist = TRUE)
  })
  
  output$plot_selection <- DT::renderDataTable({
    # Because it's a ggplot2, we don't need to supply xvar or yvar; if this
    # were a base graphics plot, we'd need those.
    if (!is.null(input$plot1_brush)) {
      message("Printing brush")
      message(input$plot1_brush)
      brushedPoints(mtcars_subset, input$plot1_brush)
    } else if (!is.null(input$plot1_click)) {
      message("Printing click")
      message(input$plot1_click)
      nearPoints(mtcars_subset, input$plot1_click, addDist = TRUE)
    } else {
      mtcars_subset %>% dplyr::slice(0)  ## Return just the headings
    }
  })
  
  output$brush_selection <- renderPrint({
    
  })
  
  
})
