## User Interface for the Shiny web application.
## This app can be run locally from within RStudio using
## its 'Run App' button.

## Load libraries ----------------------------------------------------------

source(file.path('..', '0a_helper_functions', 'check_packages.R'), local = TRUE)

check_packages('shiny')
check_packages('shinyjs')

## Define UI ---------------------------------------------------------------

shinyUI(fluidPage(
  useShinyjs(),  ## See, e.g., https://ox-it.github.io/OxfordIDN_Shiny-App-Templates/advanced-shiny-features/loading-data/
  
  # Sidebar with a slider input for number of bins 
  navbarPage("Cohort Explorer",  # Application title
    tabPanel("Instructions",
      h1("Instructions for Use"),
      p("These are instructions for use."),
      h2("t-SNE"),
      p("The top of the tab uses a visualization method called t-SNE.")
    ),
    tabPanel("Explore",
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
          h1(textOutput('cohort_header')),
          fluidRow(
            div(
              id = "loading_content",
              class = "loading-content",
              h2(class = "animated infinite pulse", "Loading data...")
            ),
            plotOutput(
              'tsne_2d_scatterplot',
              height = 800,
              # Equivalent to: click = clickOpts(id = 'plot_click')
              click = 'tsne_2d_scatterplot_click',
              brush = brushOpts(
                id = 'tsne_2d_scatterplot_brush'
              )
            )
          ),
          fluidRow(
            h2('Selection'),
            DT::dataTableOutput('plot_selection'),
            h3('Age at Beginning of Case'),
            p('(Mean of selected points marked with gray line, 3*SD marked with pink line)'),
            plotOutput(
              'selection_age_histogram',
              height = 500
            ),
            # vegaliteOutput(
            #   'selection_age_histogram'
            # ),
            h3('ICD-9 Diagnosis Top Level (First Digit / Letter)'),
            plotOutput(
              'selection_icd9_top_chart',
              height = 500
            ),
            # vegaliteOutput(
            #   'selection_race_chart'
            # )
            h3('Resolved (Green) vs. Unresolved (Red) Cases, by Sex and Race'),
            plotOutput(
              'sankey_diagram',
              height = 1500
            )
          )
        )
      )
    ),
    tabPanel("Cohort Comparison",
      h1('Cohort Comparison, by Categorical Variables'),
      uiOutput('cohort_comparison_charts')
    )
  )
))
