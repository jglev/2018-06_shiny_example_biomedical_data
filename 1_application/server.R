## Server logic for the Shiny web application.
## This app can be run locally from within RStudio using
## its "Run App" button.

## Load libraries ----------------------------------------------------------

library(shiny)

# Load data ---------------------------------------------------------------

# Following https://shiny.rstudio.com/gallery/plot-interaction-selecting-points.html
mtcars_subset <- mtcars[, c("mpg", "cyl", "disp", "hp", "wt", "am", "gear")]

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
  
  output$click_selection <- renderPrint({
    # Because it's a ggplot2, we don't need to supply xvar or yvar; if this
    # were a base graphics plot, we'd need those.
    nearPoints(mtcars_subset, input$plot1_click, addDist = TRUE)
  })
  
  output$brush_selection <- renderPrint({
    brushedPoints(mtcars_subset, input$plot1_brush)
  })
  
  
})
