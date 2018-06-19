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
       textOutput('status_output')
    ),
    
    mainPanel(
      fluidRow(
         plotOutput(
           'plot1', height = 300,
            # Equivalent to: click = clickOpts(id = 'plot_click')
            click = 'plot1_click',
            brush = brushOpts(
              id = 'plot1_brush'
            )
         )
      ),
      fluidRow(
        h4('Clicked selection'),
        DT::dataTableOutput('plot_selection')
      )
    )
  )
))
