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
    data |>
      filter(country == input$country)
  })
  
  # Reactive value to track the active button ----
  active_view <- reactiveVal("comparative")  # Default view
  
  # Reactive value to store the state of the data
  happy_sad_y_val <- reactiveVal(data$happiness_score)
  
  # Reactive value to store the y-axis label
  y_axis_label <- reactiveVal("Happiness Score")
  
  # Update the active view when either button is clicked ----
  
  # view for comparing variables one country at a time
  observeEvent(input$comparative, {
    active_view("comparative")
  })
  
  # view for viewing the change in one variable over time
  observeEvent(input$change_over_time, {
    active_view("change_over_time") 
  })
  
  # button toggles the y-ax variable between happy and sad variables
  observeEvent(input$toggle_happy_sad, {
    if (identical(happy_sad_y_val(), data$happiness_score)) {
      happy_sad_y_val(data$pct_new_per_pop_disorders)
      y_axis_label(
        "Sadness Score"
      )
    } else {
      happy_sad_y_val(data$happiness_score)
      y_axis_label("Happiness Score")
    }
  })
  
  
  # Render the dynamic sidebar UI based on the active view ----
  output$dynamic_sidebar <- renderUI({
    if (active_view() == "comparative") {
      tagList(
        selectInput('country', "Select Country", unique(data$country)),
        radioButtons(
          "x_var", "Choose X-axis Variable:",
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
      x_var <- input$x_var
      
      # Create a clean data frame with explicit columns ----
      plot_df <- plot_data() %>%
        mutate(
          x_value = as.numeric(.data[[x_var]]),
          # Use the row indices directly since plot_data is already filtered
          y_value = happy_sad_y_val()[which(data$country == input$country)],
          hover_text = paste("Year:", year, "\nCountry:", country)
        )
      
      # Fit the linear model ----
      fit <- lm(y_value ~ x_value, data = plot_df)
      predicted_values <- predict(fit)
      
      # Create the plot ----
      p <- plot_ly() %>%
        # Add scatter points
        add_trace(
          data = plot_df,
          x = ~x_value,
          y = ~y_value,
          type = "scatter",
          mode = "markers",
          marker = list(
            color = "#007fff",
            size = 8,
            opacity = 0.7
          ),
          text = ~hover_text,
          name = "Data points"
        ) %>%
        # Add trend line ----
      add_trace(
        data = plot_df,
        x = ~x_value,
        y = predicted_values,
        type = "scatter",
        mode = "lines",
        line = list(
          color = '#ff1d58',
          dash = "dash",
          width = 2
        ),
        name = "Trend line"
      ) %>%
        # Update layout ----
      layout(
        title = list(
          text = paste("Happiness Score vs", 
                       ifelse(x_var == "fish_kg_per_person_per_year", 
                              "Fish Consumption", 
                              "Sugar Consumption"))
        ),
        xaxis = list(
          title = list(
            text = ifelse(x_var == "fish_kg_per_person_per_year", 
                          "Fish Consumed (kg/person/year)", 
                          "Sugar Consumed (g/person/day)")
          )
        ),
        yaxis = list(
          title = list(
            text = y_axis_label()
          )
        ),
        showlegend = FALSE,
        hovermode = "closest"
      )
      
      return(p)
    } 
    # Handle "change_over_time" view ----
    else if (active_view() == "change_over_time") {
      country_data <- data |>  filter(country == input$country)
      
      if (input$var_choice == "Both") {
        # Dual y-axes plot for both variables
        plot_ly(data = country_data) %>%
          add_lines(
            x = ~year,
            y = ~fish_kg_per_person_per_year,
            name = "Fish Consumption",
            yaxis = "y1",
            line = list(color = "#007fff"),
            hovertemplate = paste(
              "Country: %{text}<br>",
              "Year: %{x}<br>",
              "Fish Consumption: %{y:.1f} kg/person/year<br>",
              "<extra></extra>"
            ),
            text = ~country
          ) |>
          add_lines(
            x = ~year,
            y = ~sugar_g_per_person_per_day,
            name = "Sugar Consumption",
            yaxis = "y2",
            line = list(color = "#ff1d58"),
            hovertemplate = paste(
              "Country: %{text}<br>",
              "Year: %{x}<br>",
              "Sugar: %{y:.1f} g/person/day<br>",
              "<extra></extra>"
            ),
            text = ~country
          ) |>
          layout(
            title = paste(
              "Change Over Time (Both Variables) for", input$country
            ),
            xaxis = list(title = "Year"),
            yaxis = list(
              title = "Fish Consumption",
              titlefont = list(color = "#007fff"),
              tickfont = list(color = "#007fff")
            ),
            yaxis2 = list(
              title = "Sugar Consumption",
              overlaying = "y",
              side = "right",
              titlefont = list(color = "#ff1d58"),
              tickfont = list(color = "#ff1d58"))
          )
      } else {
        # Single variable plot ----
        selected_var <- ifelse(
          input$var_choice == "Fish",
          "fish_kg_per_person_per_year",
          "sugar_g_per_person_per_day"
        )
        var_title <- ifelse(
          input$var_choice == "Fish",
          "Fish Consumption",
          "Sugar Consumption"
        )
        color <- ifelse(
          selected_var == "fish_kg_per_person_per_year",
          "#007fff",
          "#ff1d58"
        )
        
        plot_ly(data = country_data) |>
          add_lines(
            x = ~year,
            y = ~get(selected_var),
            name = var_title,
            line = list(color = color),
            hovertemplate = paste(
              "Country: %{text}<br>",
              "Year: %{x}<br>",
              "%{y:.1f}",
              ifelse(input$var_choice == "Fish",
                     " kg/person/year",
                     " g/person/day"),
              "<br><extra></extra>"
            ),
            text = ~country
          )  |>
          layout(
            title = glue(
              "Change Over Time for {var_title} in {input$country}"
            ),
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
      
      
      # Modify highlight column to use country names instead of TRUE/FALSE ----
      plot_data_2_mod <- plot_data_2() %>%
        mutate(
          highlight = ifelse(highlight, country, "Other Countries"),
          alpha_val = ifelse(highlight == "Other Countries", 0.3, 1),
          size_val = ifelse(highlight == "Other Countries", 1, 1.01)  # More distinct size difference
        )
      
      
      # Color mapping with selected country
      color_values <- c("Other Countries" = "#007FFF")
      color_values[input$country] <- "#ff1d58"
      
      # # Scatter plot with a trendline
      p <- ggplot(
        data = plot_data_2_mod,
        aes(x = .data[[x_var]],
            y = happy_sad_y_val(),
            text = paste("Year:", year, "\nCountry:", country)
        )
      ) +
        geom_point(
          aes(color=highlight,
              alpha = alpha_val,
              size = size_val
          )
        ) +  # Scatter points
        geom_smooth(
          aes(
            group = 1
          ),
          method = "lm",
          formula = y ~ x,
          se = FALSE,
          linetype = "dashed",
          color = '#007fff'
        ) +  # Trendline
        labs(
          title = glue(
            "Happiness Score vs {ifelse(x_var == 'fish_kg_per_person_per_year',
            'Fish Consumption (kg/person/year)',
            'Sugar Consumption (g/person/day)')} for the World"
          ),
          x = ifelse(
            x_var == "fish_kg_per_person_per_year",
            "Fish Consumed (kg/person/year)",
            "Sugar Consumed (g/person/day)"),
          y = y_axis_label()
        ) +
        scale_color_manual(values = color_values) +  # Custom color scale
        scale_alpha_identity() +  # Use predefined alpha values from data
        theme_classic()
      
      ggplotly(p, tooltip = c("x", "y", "text"))
      
      
    } else if (active_view() == "change_over_time"){
      
      # Modify highlight column to use country names instead of TRUE/FALSE ----
      plot_data_2_mod <- plot_data_2() |>
        mutate(
          highlight = ifelse(highlight, country, "Other Countries"),
          # Lower opacity for other countries ----
          alpha_val = ifelse(highlight == "Other Countries", 0.4, 1))  
      
      if (input$var_choice == "Both") {
        # Dual y-axes scatter plot for both variables -----
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
                    ),
                    hovertemplate = paste(
                      "Country: %{text}<br>",
                      "Year: %{x}<br>",
                      "Fish Consumption: %{y:.1f} kg/person/year<br>",
                      "<extra></extra>"
                    ),
                    text = ~country
          ) |>
          add_trace(x = ~year,
                    y = ~sugar_g_per_person_per_day,
                    name = "Sugar Consumption (g/person/day)",
                    yaxis = "y2",
                    type = 'scatter',
                    mode = 'markers',  
                    marker = list(
                      color = "#ff1d58",
                      size = 8,
                      opacity = ~alpha_val
                    ),
                    hovertemplate = paste(
                      "Country: %{text}<br>",
                      "Year: %{x}<br>",
                      "Sugar: %{y:.1f} g/person/day<br>",
                      "<extra></extra>"
                    ),
                    text = ~country
          ) |>
          layout(
            title = paste(
              "Change Over Time (Both Variables) for", input$country
            ),
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
        # Single variable scatter plot ----
        selected_var <- ifelse(
          input$var_choice == "Fish",
          "fish_kg_per_person_per_year",
          "sugar_g_per_person_per_day"
        )
        var_title <- ifelse(
          input$var_choice == "Fish",
          "Fish Consumption (kg/person/year)",
          "Sugar Consumption (g/person/day)"
        )
        color <- ifelse(
          selected_var == "fish_kg_per_person_per_year",
          "#007fff",
          "#ff1d58"
        )
        
        plot_ly(data = plot_data_2_mod) |>
          add_trace(x = ~year,
                    y = ~get(selected_var),
                    name = var_title,
                    type = 'scatter',
                    mode = 'markers',  
                    marker = list(
                      color = color,
                      size = 8,
                      opacity = ~alpha_val
                    ),
                    hovertemplate = paste(
                      "Country: %{text}<br>",
                      "Year: %{x}<br>",
                      "%{y:.1f}",
                      ifelse(input$var_choice == "Fish",
                             " kg/person/year",
                             " g/person/day"),
                      "<br><extra></extra>"
                    ),
                    text = ~country
          ) |>
          layout(
            title = glue("Change Over Time for {var_title} for All Countries"),
            xaxis = list(title = "Year"),
            yaxis = list(title = var_title))
      }
    }
  })
}