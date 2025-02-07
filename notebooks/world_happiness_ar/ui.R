# Define UI for World Happinesss Exploration app ----
# Sidebar layout with input and output definitions ----

# ui <- page_navbar(
#   title = "My App",
#   bg = "#2D89C8",
#   inverse = TRUE,
#   nav_panel(title = "One", p("First page content.")),
#   nav_panel(title = "Two", p("Second page content.")),
#   nav_panel(title = "Three", p("Third page content.")),
#   nav_spacer(),
#   nav_menu(
#     title = "Links",
#     align = "right",
#     nav_item(tags$a("Posit", href = "https://posit.co")),
#     nav_item(tags$a("Shiny", href = "https://shiny.posit.co"))
#   )
# )
page_navbar(
  bg = "#1E2127",
  nav_panel("Home",icon = icon('house'), p(
    fluidRow(
      p(
        h1("Fish and sugar consumption as they relate to 
        feelings of happiness and prevalence of depressive & anxiety disorders"),
        # style=(
        #   "text-align:justify;color:white;background-color:navy;padding:15px;border-radius:10px"
        # )
      ),
      column(
        width=3
      ),
      column(
        br(),
        p(
          "It is widely accepted that consumption of fish and seafood 
                 have health benefits, and that increased sugar consumption has
                 health consequences. This app aims to investigate the 
                 relationship between consumption of those two pieces of a
                 country's diet, the", em(strong("Happiness Score")), "for each country*, and
                 the", em(strong("Sadness Score")), "for each country.",
          style=(
            "text-align:justify;color:black;background-color:lightblue;padding:15px;border-radius:10px"
          )
        ),
        br(),
        
        p(em("*Data collection proved difficult, with many countries being
           excluded from one or another dataset. As a result, not all countries 
           are represented.", 
             strong("Total countries represented: 150"))
          ,
          style=(
            "text-align:justify;color:black;background-color:papayawhip;padding:15px;border-radius:10px"
          )
        ),
        width=6),
      hr(),
      fluidRow(
        br(),
        br(),
        p("Some data was sourced from the",em("Gapminder"),"educational nonprofit",
          br(),
          a(href="https://www.gapminder.org/data/", "Gapminder",target="_blank"),style="text-align:center;color:black"),
        
        width=2,
        br(),
        p("Some data was sourced from the",em("Global Burden of Disease Collaborative Network"),
          br(),
          a(href="https://vizhub.healthdata.org/gbd-results/", "Global Burden of Disease Collaborative Network",target="_blank"),style="text-align:center;color:black"),
      ),
    ),
    
    "Project: Investigating fish and sugar consumption as they relate to feelings of happiness and prevalence of depressive & anxiety disorders"
  )),
  nav_panel('Explore', icon = icon('chart-line'), p(
    page_sidebar(
      # App title ----
      title = "Effects of Diet on Measures of Happiness",
      
      # Sidebar panel for inputs ----
      sidebar = sidebar(
        
        # Input: Action Buttons to toggle the sidebar content ----
        actionButton(
          'comparative',
          "Comparative"
        ),
        actionButton(
          'change_over_time',
          "Change Over Time"
        ),
        # Dynamic UI content that will change based on the button clicked
        uiOutput("dynamic_sidebar"),
        
        # Add vertical spacing between elements
        br(),br(),br(),br(),br(),br(),br(),br(),br(),br(),
        
        actionButton(
          'toggle_happy_sad',
          "Toggle Happy or Sad"
        ),
        # Custom footer
        tags$footer(
          glue(
            "*Sadness Score = (n new cases of depressive or anxiety disorders)",
            " / (country population measured mid-year)     |     ",
            "**Happiness Score = national average Cantril Life Ladder"
          ),
          style = ("background-color: #f8f9fa; color: #333; text-align: center;
               padding: 5px; font-size: 8px; font-family: Arial, sans-serif;
               position: fixed; left: 0; bottom: 0; width: 100%;")
        ),
        
        # Additional CSS to ensure the footer is above other content
        tags$style(HTML("
    body {
      padding-bottom: 20px; /* Adjust based on footer height */
    }
  "))
      ),
      
      # Main panel for displaying outputs ----
      navset_card_underline(
        
        title = "Visualizations",
        
        # Panel with scatter plot ----
        #nav_panel("Scatter", plotOutput("scatter")),
        
        # Panel with scatter and trendline plot ----
        nav_panel("Interactive Plot", plotlyOutput("line")),
        # Panel with scatter plot ----
        nav_panel("All Countries", plotlyOutput("scatter")),
        # Panel with table ----
        nav_panel("Table", dataTableOutput("table")),
        
      )
    )
  )
  ),
  nav_panel(
    "Calculations",
    icon=icon("calculator"),
    
    navset_card_underline(
      # Tab Title
      title = "What we learned",
      
      # Panel with simple summary
      nav_panel(
        "Summary",
        includeMarkdown("../../README.md") 
      ),
      nav_panel(
        "Technical Details",
        htmlOutput("calculations_html")
      ),
      nav_panel(
        "All Data Table",
        dataTableOutput("calc_table")
      )
    )
  )
)

