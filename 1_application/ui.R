## User Interface for the Shiny web application.
## This app can be run locally from within RStudio using
## its 'Run App' button.

## Load libraries ----------------------------------------------------------

library(shiny)


## Define UI ---------------------------------------------------------------

shinyUI(fluidPage(
  
  # Application title
  titlePanel('Cohort Overview'),
  
  # Sidebar with a slider input for number of bins 
  sidebarLayout(
    sidebarPanel(
      h3('Status Messages (TODO)'),
      textOutput('status_output'),
      h3('Data Sampler'),
      uiOutput('resample_slider'),
      actionButton(
        'resample_button',
        label = 'Resample',
        icon = NULL,
        width = NULL
      )
    ),
    
    mainPanel(
      fluidRow(
         plotOutput(
           'scatterplot',
           height = 300,
            # Equivalent to: click = clickOpts(id = 'plot_click')
            click = 'scatterplot_click',
            brush = brushOpts(
              id = 'scatterplot_brush'
            )
         )
      ),
      fluidRow(
        h4('Selection'),
        DT::dataTableOutput('plot_selection'),
        plotOutput(
          'selection_histogram', height = 300
        )
      )
    )
  )
))
