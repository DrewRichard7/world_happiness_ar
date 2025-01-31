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
    uiOutput("dynamic_sidebar")
    
  ),
  
  # Main panel for displaying outputs ----
  navset_card_underline(
    
    title = "Visualizations",
    
    # Panel with scatter plot ----
    #nav_panel("Scatter", plotOutput("scatter")),
    
    # Panel with line plot (depending on plotly or ggplot, comment out correct one) ----
    # nav_panel("Plot", plotOutput("line")),
    nav_panel("Interactive Plot", plotlyOutput("line")),
    # Panel with table ----
    nav_panel("Table", dataTableOutput("table"))
  )
)

