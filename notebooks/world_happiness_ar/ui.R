#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#

# Define UI for World Happinesss Exploration app ----
# Sidebar layout with input and output definitions ----

page_sidebar(
  # theme = shinytheme("darkly"),
  # App title ----
  title = "World Happiness Exploration",
  
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
      style = "background-color: #f8f9fa; color: #333; text-align: center; padding: 5px; font-size: 8px; font-family: Arial, sans-serif; position: fixed; left: 0; bottom: 0; width: 100%;"
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

