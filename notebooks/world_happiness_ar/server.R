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
  # Reactive value for filtered data ----
  plot_data <- reactive({
    req(input$country) # Ensure inputs are available
    data |> 
      filter(country == input$country)
  })
  
  # Reactive value to track the active button ----
  active_view <- reactiveVal("comparative")  # Default view
  
  # Update the active view when either button is clicked ----
  observeEvent(input$comparative, {
    active_view("comparative")
  })
  observeEvent(input$change_over_time, {
    active_view("change_over_time")
  })
  observeEvent(input$happy_sad, {
    active_view("happy_sad")
  })
  
  
  # Render the dynamic sidebar UI based on the active view ----
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
  
  # Render country specific plots ----
  output$line <- renderPlotly({
    req(plot_data())  # Ensure data is available
    
    if (active_view() == "comparative") {
      # Choose the selected X-axis variable
      x_var <- input$x_var
      
      # # Scatter plot with a trendline
      p <- ggplot(
        data = plot_data(),
        aes(x = .data[[x_var]], y = happiness_score)
      ) +
        geom_point(
          alpha = 0.7,
          color = "#007fff"
        ) +  # Scatter points
        geom_smooth(
          method = "lm",
          se = FALSE,
          linetype = "dashed",
          color = '#ff1d58'
        ) +  # Trendline
        labs(title = glue("Happiness Score vs {ifelse(x_var == 'fish_kg_per_person_per_year', 'Fish Consumption', 'Sugar Consumption')}"),
             x = ifelse(x_var == "fish_kg_per_person_per_year", "Fish Consumed (kg/person/year)", "Sugar Consumed (g/person/day)"),
             y = "Happiness Score") +
        theme_classic()
      
      ggplotly(p, tooltip = c("x", "y"))
      
      
    } else if (active_view() == "change_over_time"){
      # Handle "change_over_time" view
      country_data <- data |>  filter(country == input$country)
      
      if (input$var_choice == "Both") {
        # Dual y-axes plot for both variables
        plot_ly(data = country_data) %>%
          add_lines(
            x = ~year,
            y = ~fish_kg_per_person_per_year,
            name = "Fish Consumption",
            yaxis = "y1",
            line = list(color = "#007fff")) |> 
          add_lines(
            x = ~year,
            y = ~sugar_g_per_person_per_day,
            name = "Sugar Consumption",
            yaxis = "y2",
            line = list(color = "#ff1d58")) |> 
          layout(title = paste("Change Over Time (Both Variables) for", input$country),
                 xaxis = list(title = "Year"),
                 yaxis = list(title = "Fish Consumption", titlefont = list(color = "#007fff"), tickfont = list(color = "#007fff")),
                 yaxis2 = list(title = "Sugar Consumption", overlaying = "y", side = "right", titlefont = list(color = "#ff1d58"), tickfont = list(color = "#ff1d58")))
      } else {
        # Single variable plot
        selected_var <- ifelse(input$var_choice == "Fish", "fish_kg_per_person_per_year", "sugar_g_per_person_per_day")
        var_title <- ifelse(input$var_choice == "Fish", "Fish Consumption", "Sugar Consumption")
        color <- ifelse(selected_var == "fish_kg_per_person_per_year", "#007fff", "#ff1d58")
        
        plot_ly(data = country_data) |> 
          add_lines(
            x = ~year,
            y = ~get(selected_var),
            name = var_title,
            line = list(color = color))  |> 
          layout(title = glue("Change Over Time for {var_title} in {input$country}"),
                 xaxis = list(title = "Year"),
                 yaxis = list(title = var_title))
      }
    } else if (active_view() == "happy_sad"){
      
      
      
    } 
  })
  
  # Render selected country table ----
  output$table <- renderDataTable({
    plot_data()
  })
  
  
  # Reactive value for filtered data ----
  plot_data_2 <- reactive({
    req(input$country) # Ensure inputs are available
    data |> 
      mutate(highlight = country %in% input$country)
  })
  
  # Render all countries tabset ----
  output$scatter <- renderPlotly({
    req(plot_data_2())  # Ensure data is available
    
    if (active_view() == "comparative") {
      # Choose the selected X-axis variable
      x_var <- input$x_var
      
      # Modify highlight column to use country names instead of TRUE/FALSE
      plot_data_2_mod <- plot_data_2() |> 
        mutate(highlight = ifelse(highlight, country, "Other Countries"),
               alpha_val = ifelse(highlight == "Other Countries", 0.4, 1),
               size_val = ifelse(highlight == "Other Countries", 0.5, .75))  # Lower opacity for other countries
      
      # Create color values with the actual country name
      color_values <- c("Other Countries" = "#007fff")
      color_values[input$country] <- "#ff1d58"  # Dynamically add the selected country's color
      
      
      # # Scatter plot with a trendline
      p <- ggplot(data = plot_data_2_mod, aes(x = .data[[x_var]], y = happiness_score)) +
        geom_point(aes(color=highlight, alpha = alpha_val, size = size_val)) +  # Scatter points
        geom_smooth(method = "lm", formula = y~x, se = FALSE, linetype = "dashed", color = '#007fff') +  # Trendline
        labs(title = glue("Happiness Score vs {ifelse(x_var == 'fish_kg_per_person_per_year', 'Fish Consumption (kg/person/year)', 'Sugar Consumption (g/person/day)')} for the World"),
             x = ifelse(x_var == "fish_kg_per_person_per_year", "Fish Consumed (kg/person/year)", "Sugar Consumed (g/person/day)"),
             y = "Happiness Score") +
        scale_color_manual(values = color_values) +  # Custom color scale
        scale_alpha_identity() +  # Use predefined alpha values from data
        theme_classic()
      
      ggplotly(p, tooltip = c("x", "y"))
      
    } else if (active_view() == "change_over_time"){
      
      # Modify highlight column to use country names instead of TRUE/FALSE
      plot_data_2_mod <- plot_data_2() |> 
        mutate(highlight = ifelse(highlight, country, "Other Countries"),
               alpha_val = ifelse(highlight == "Other Countries", 0.4, 1))  # Lower opacity for other countries
      
      if (input$var_choice == "Both") {
        # Dual y-axes scatter plot for both variables
        plot_ly(data = plot_data_2_mod) |> 
          add_trace(x = ~year, 
                    y = ~fish_kg_per_person_per_year, 
                    name = "Fish Consumption (kg/person/year)", 
                    yaxis = "y1", 
                    type = 'scatter',
                    mode = 'markers',  # Add this line
                    marker = list(
                      color = "#007fff",
                      size = 8,
                      opacity = ~alpha_val
                    )) |> 
          add_trace(x = ~year, 
                    y = ~sugar_g_per_person_per_day, 
                    name = "Sugar Consumption (g/person/day)", 
                    yaxis = "y2", 
                    type = 'scatter',
                    mode = 'markers',  # Add this line
                    marker = list(
                      color = "#ff1d58",
                      size = 8,
                      opacity = ~alpha_val
                    )) |> 
          layout(title = paste("Change Over Time (Both Variables) for", input$country),
                 xaxis = list(title = "Year"),
                 yaxis = list(title = "Fish Consumption (kg/person/year)", 
                              titlefont = list(color = "#007fff"), 
                              tickfont = list(color = "#007fff")),
                 yaxis2 = list(title = "Sugar Consumption (g/person/day)", 
                               overlaying = "y", 
                               side = "right", 
                               titlefont = list(color = "#ff1d58"), 
                               tickfont = list(color = "#ff1d58")))
      } else {
        # Single variable scatter plot
        selected_var <- ifelse(input$var_choice == "Fish", "fish_kg_per_person_per_year", "sugar_g_per_person_per_day")
        var_title <- ifelse(input$var_choice == "Fish", "Fish Consumption (kg/person/year)", "Sugar Consumption (g/person/day)")
        color <- ifelse(selected_var == "fish_kg_per_person_per_year", "#007fff", "#ff1d58")
        
        plot_ly(data = plot_data_2_mod) |> 
          add_trace(x = ~year, 
                    y = ~get(selected_var), 
                    name = var_title, 
                    type = 'scatter',
                    mode = 'markers',  # Add this line
                    marker = list(
                      color = color,
                      size = 8,
                      opacity = ~alpha_val
                    )) |> 
          layout(title = glue("Change Over Time for {var_title} for All Countries"),
                 xaxis = list(title = "Year"),
                 yaxis = list(title = var_title))
      }
    }
  })
}