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
  navbarPage('Cohort Explorer',  # Application title
    tabPanel('Guidance',
      p(textOutput('introduction_to_dataset')),
      h1('Guidance for Use'),
      p(
        'This page has two tabs for data analysis.',
        'The', tags$b('Explore'), 'tab is for understanding each cohort',
        tags$b('individually.'), 'The', tags$b('Cohort Comparison'), 'tab is',
        'for understanding the', tags$b('relationship between cohorts.')
      ),
      p(
        'Note that across these tabs, each data point is an',
        tags$b('individual case,', tags$i('not'), 'an individual patient.')
      ),
      h2('The Explore tab'),
      h3('t-SNE'),
      p(
        'The top of the tab uses a visualization method called t-SNE',
        '(t-distributed stochastic neighbor embedding). t-SNE can be used for',
        tags$a(
          href = 'https://medium.com/@Zelros/anomaly-detection-with-t-sne-211857b1cd00',
          'anomaly detection,'
        ),
        'because it displays "closeness" between cases.'
      ),
      p(
        't-SNE takes multiple variables -- in this case, sex, ethnicity,',
        'race, age at beginning of a case, whether the case was resolved,',
        'and diagnosis general category (i.e., the ICD-9 code',
        'pre-decimal digits) -- and, in this case, allows graphing similarity',
        'across all of those variables using only a two-axis plot.'
      ),
      p(
        tags$b(
          'You can filter cases by category using the sidebar on the left',
          'side of the Explore tab, and then can select specific groups of',
          'cases from those that are filtered / highlighted by clicking and',
          'dragging across the t-SNE plot. The information displayed below the',
          't-SNE plot will update to reflect both filtering from the sidebar',
          'and clicking and dragging on the t-SNE plot.'
        )
      ),
      p(
        tags$b(
          'You can filter cases by category using the sidebar on the left',
          'side of the Explore tab, and then can select specific groups of',
          'cases from those that are filtered / highlighted by clicking and',
          'dragging across the t-SNE plot. The information displayed below the',
          't-SNE plot will update to reflect both filtering from the sidebar',
          'and clicking and dragging on the t-SNE plot.'
        )
      ),
      h4('Update timing'),
      p(
        'The t-SNE diagram takes approximately 5 seconds to update on a',
        'commodity laptop. Please be patient as it updates -- the computations',
        'are quick, but the actual plotting takes several seconds.'
      ),
      h3('Age'),
      p(
        'A histogram below the t-SNE plot displays the age distribution',
        'of the selected cases. The mean of the distribution is shown in',
        'gray, while three standard deviations from that mean are fenced in',
        'pink, showing the number of age-based outliers from the selected',
        'cases.'
      ),
      h3('ICD-9 Diagnosis'),
      p(
        'A bar chart below displays the distribution of ICD-9 general',
        'categories -- here, the first digit or letter of the ICD-9 diagnosis',
        '-- across the selected cases.'
      ),
      h3('Resolved (Green) vs. Unresolved (Red) Cases, by Sex and Race'),
      p(
        'Finally, a Sankey diagram (also called an Alluvial diagram)',
        'shows the distribution of sex and race within the selected cases,',
        'with resolved cases marked in green and non-resolved cases marked',
        'in red.'
      ),
      h2('The Cohort Comparison tab'),
      p(
        'The Cohort Comparison tab presents a series of stacked bar charts,',
        'one for each of the categorical variables present in the dataset.',
        'You can scroll down through the tab to compare cohorts on each of',
        'these categorical variables.'
      )
    ),
    tabPanel('Explore',
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
              id = 'loading_content',
              class = 'loading-content',
              h2(class = 'animated infinite pulse', 'Loading data...')
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
    tabPanel('Cohort Comparison',
      h1('Cohort Comparison, by Categorical Variables'),
      uiOutput('cohort_comparison_charts')
    )
  )
))
