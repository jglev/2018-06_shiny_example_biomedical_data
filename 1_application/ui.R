## User Interface for the Shiny web application.
## This app can be run locally from within RStudio using
## its 'Run App' button.

## Load libraries ----------------------------------------------------------

source(file.path('..', '0a_helper_functions', 'check_packages.R'), local = TRUE)

check_packages('shiny')

## Define UI ---------------------------------------------------------------

shinyUI(fluidPage(
  
  # Application title
  titlePanel('Cohort Overview'),
  
  # Sidebar with a slider input for number of bins 
  sidebarLayout(
    sidebarPanel(
      h2('Cohort'),
      uiOutput('cohort_filter'),
      h2('Highlight Datapoints'),
      uiOutput('filter_parameters')
      # actionButton(
      #   'resample_button',
      #   label = 'Resample',
      #   icon = NULL,
      #   width = NULL
      # )
    ),
    
    mainPanel(
      fluidRow(
         plotOutput(
           'tsne_2d_scatterplot',
           height = 300,
            # Equivalent to: click = clickOpts(id = 'plot_click')
            click = 'tsne_2d_scatterplot_click',
            brush = brushOpts(
              id = 'tsne_2d_scatterplot_brush'
            )
         )
      ),
      fluidRow(
        h3('Selection'),
        DT::dataTableOutput('plot_selection'),
        h4('Age at Beginning of Case'),
        plotOutput(
          'selection_histogram', height = 300
        )
      )
    )
  )
))
