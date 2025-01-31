#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#



# Define server logic 
function(input, output, session) {
  # Reactive value for filtered data
  plot_data <- reactive({
    req(input$country) # Ensure inputs are available
    data %>%
      filter(country == input$country)
  })
  
  # Reactive value to track the active button
  active_view <- reactiveVal("comparative")  # Default view
  
  # Update the active view when either button is clicked
  observeEvent(input$comparative, {
    active_view("comparative")
  })
  observeEvent(input$change_over_time, {
    active_view("change_over_time")
  })
  
  # Render the dynamic sidebar UI based on the active view
  output$dynamic_sidebar <- renderUI({
    if (active_view() == "comparative") {
      tagList(
        selectInput('country', "Select Country", unique(data$country)),
        radioButtons("x_var", "Choose X-axis Variable:",
                     choices = c("Fish Consumed" = "fish_kg_per_person_per_year",
                                 "Sugar Consumed" = "sugar_g_per_person_per_day"),
                     selected = "fish_kg_per_person_per_year") # Default to Fish
      )
    } else if (active_view() == "change_over_time") {
      tagList(
        selectInput('country', "Select Country", unique(data$country)),
        radioButtons("var_choice", "Choose your Variable(s):",
                     choices = c("Fish", "Sugar", "Both"))
      )
    }
  })
  
  
  output$line <- renderPlotly({
    req(plot_data())  # Ensure data is available
    
    if (active_view() == "comparative") {
      # Choose the selected X-axis variable
      x_var <- input$x_var
      
      # Scatter plot with a trendline
      p <- ggplot(data = plot_data(), aes_string(x = x_var, y = "happiness_score", color = "country")) +
        geom_point(alpha = 0.7) +  # Scatter points
        geom_smooth(method = "lm", se = FALSE, linetype = "dashed") +  # Trendline
        labs(title = glue("Happiness Score vs {ifelse(x_var == 'fish_kg_per_person_per_year', 'Fish Consumption', 'Sugar Consumption')}"),
             x = ifelse(x_var == "fish_kg_per_person_per_year", "Fish Consumed (kg/person/year)", "Sugar Consumed (g/person/day)"),
             y = "Happiness Score") +
        theme_minimal()
      
      ggplotly(p, tooltip = c("x", "y"))
      
    } else {
      # Handle "change_over_time" view
      country_data <- data %>% filter(country == input$country)
      
      if (input$var_choice == "Both") {
        # Dual y-axes plot for both variables
        plot_ly(data = country_data) %>%
          add_lines(x = ~year, y = ~fish_kg_per_person_per_year, name = "Fish Consumption", yaxis = "y1", line = list(color = "blue")) %>%
          add_lines(x = ~year, y = ~sugar_g_per_person_per_day, name = "Sugar Consumption", yaxis = "y2", line = list(color = "red")) %>%
          layout(title = paste("Change Over Time (Both Variables) for", input$country),
                 xaxis = list(title = "Year"),
                 yaxis = list(title = "Fish Consumption", titlefont = list(color = "blue"), tickfont = list(color = "blue")),
                 yaxis2 = list(title = "Sugar Consumption", overlaying = "y", side = "right", titlefont = list(color = "red"), tickfont = list(color = "red")))
      } else {
        # Single variable plot
        selected_var <- ifelse(input$var_choice == "Fish", "fish_kg_per_person_per_year", "sugar_g_per_person_per_day")
        var_title <- ifelse(input$var_choice == "Fish", "Fish Consumption", "Sugar Consumption")
        color <- ifelse(selected_var == "fish_kg_per_person_per_year", "blue", "red")
        
        plot_ly(data = country_data) %>%
          add_lines(x = ~year, y = ~get(selected_var), name = var_title, line = list(color = color)) %>%
          layout(title = glue("Change Over Time for {var_title} in {input$country}"),
                 xaxis = list(title = "Year"),
                 yaxis = list(title = var_title))
      }
    }
  })
  

  output$table <- renderDataTable({
    plot_data()
  })
}
