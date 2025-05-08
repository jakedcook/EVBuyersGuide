# Load libraries
library(shiny)
library(shinydashboard)
library(leaflet)
library(tidyverse)
library(plotly)
library(jsonlite)
library(sf)
library(maps)
library(shinycssloaders)

# connection to our global r file for sql data retrieval 
source("global.R")

# function to generate bar plots for different regions
generate_plot <- function(region_data, region_name, y_var, y_label) {
  plot_ly(data = region_data, 
          x = ~State, 
          y = as.formula(paste("~", y_var)),  # Dynamically select the y-axis variable
          type = "bar", 
          color = ~State,  # Color each state differently
          colors = "Set3") %>%
    layout(title = paste(region_name, "-", y_label),
           xaxis = list(title = "State"),
           yaxis = list(title = y_label),
           showlegend = FALSE)
}

# function for top ev states graph
efficency_plot <- function(data){
  plot_ly(data = data, 
          x = ~gCo2pkWh,
          y = ~reorder(State, -gCo2pkWh),
          type = "bar",
          orientation = "h",
          marker = list(color = "limegreen")) %>%
    layout(
      title = "Best EV States by CO₂ Efficiency",
      xaxis = list(title = "Grams of CO₂ per kWh"),
      yaxis = list(title = ""),
      margin = list(l = 100)  # ensures long state names fit
    )
}

# function for top emitters 
top_emissions_plot <- function(data) {
  plot_ly(data = data,
          x = ~millionTonsOfCO2,
          y = ~reorder(State, millionTonsOfCO2),
          type = "bar",
          orientation = "h",
          marker = list(
            color = ~millionTonsOfCO2,
            colorscale = list(
              c(0, "#ffe5b4"),   # light orange
              c(1, "#cc5500")    # deep orange
            ),
            cmin = min(data$millionTonsOfCO2, na.rm = TRUE),
            cmax = max(data$millionTonsOfCO2, na.rm = TRUE),
            showscale = FALSE
            )) %>%
    layout(
      title = "",
      xaxis = list(title = "Million Tons of CO₂"),
      yaxis = list(title = ""),
      margin = list(l = 100)
    )
}

# for state names
best_states <- c("New Hampshire", "Connecticut", "South Carolina", 
                 "Alabama", "South Dakota", "Iowa", "Oregon", "Washington")

# server function
server <- function(input, output, session) {
  
  # Render the choropleth map
  output$co2_map <- renderPlot({
    
    
    # Generate the choropleth map
    states_sf %>%
      ggplot() +
      geom_sf(data = completeStateData, 
              aes(fill = gCo2), 
              color = "grey", size = 0.25) +  # Color for state borders and size of borders
      scale_fill_gradient(low = "lightyellow", high = "orange") +  # Applying a color scale 
      labs(fill = "Grams of CO2 Emitted") +
      geom_sf_text(data = get_urbn_labels(map = "states", sf = TRUE),
                   aes(label = state_abbv),
                   size = 3)
 
  })
  
  #render top emitters 
  output$tons_co2 <- renderPlotly({
    # get dataset for top emitters
    top_emitter_data <- state_co2 %>%
      arrange(desc(millionTonsOfCO2)) %>%
      head(8)
    
    plot<-top_emissions_plot(top_emitter_data)
  })
  
  
  
  # Render interactive plot for North Region Data
  output$north_data_plot <- renderPlotly({
    # Get the selected y-axis variable from the input
    y_var <- input$yaxis_var_north
    y_label <- readable_labels[[y_var]]
    plot <- generate_plot(northRegion, "North Region", y_var, y_label)
  })
  
  # Render interactive plot for South Region Data
  output$south_data_plot <- renderPlotly({
    y_var <- input$yaxis_var_south
    y_label <- readable_labels[[y_var]]
    generate_plot(southRegion, "South Region", y_var, y_label)  # Same function for South Region
  })
  
  # Render interactive plot for Mid-West Region Data
  output$midWest_data_plot <- renderPlotly({
    y_var <- input$yaxis_var_midWest
    y_label <- readable_labels[[y_var]]
    generate_plot(midWestRegion, "Mid-West Region", y_var, y_label)  # Same function for Mid-West Region
  })
  
  # Render interactive plot for West Region Data
  output$west_data_plot <- renderPlotly({
    y_var <- input$yaxis_var_west
    y_label <- readable_labels[[y_var]]
    generate_plot(westRegion, "West Region", y_var, y_label)  # Same function for West Region
  })
  
  # make best ev data for graphing 
  best_evState_data <- state_co2 %>%
    filter(State %in% best_states)
  
  # render plot for the best ev states 
  output$best_ev_states <- renderPlotly({
    efficency_plot(best_evState_data)
  })
  
  # for drop down state menu 
  observeEvent(input$selected_state, {
    req(input$selected_state)  # Make sure a state is selected
    
    # Get CO2 per kWh for selected state
    state_emission <- state_co2 %>%
      filter(State == input$selected_state) %>%
      pull(gCo2pkWh)
    
    # Perform the calculation and create new column gCo2pM
    updated_ev_data <- electric_vehicle_data %>%
      mutate(gCo2pM = state_emission / combMpKwh) %>%
      arrange(gCo2pM, desc(combMpKwh))
    
    # display the updated data
    output$ev_table <- DT::renderDataTable({
      updated_ev_data %>%
        mutate(
          combMpKwh = round(combMpKwh, 2),
          gCo2pM = round(gCo2pM, 2)
        ) %>%
        select(make, model, combMpKwh, gCo2pM) %>%
        arrange(gCo2pM, desc(combMpKwh)) %>%
        setNames(c("Make", "Model", "Combined MpkWh", "Grams of CO₂ per Mile"))
    })
  })

  # render a ice/hybrid table 
  output$ice_table <- DT::renderDataTable({
    vehicle_data %>%
      mutate(
        combinedMPG = round(combinedMPG, 2)
      ) %>%
      select(make, model, combinedMPG, gCo2pM) %>%
      arrange(gCo2pM, desc(combinedMPG)) %>%
      setNames(c("Make", "Model", "Combined MPG", "Grams of CO₂ per Mile")) %>%
      head(89)
    
  })
  
  # render the raw data frame for exploration 
  output$start_vehicle_data <- DT::renderDataTable({
    DT::datatable(raw_vehicle_data, options = list(scrollX = TRUE))
  })
  
  output$start_emission_data <- DT::renderDataTable({
    DT::datatable(raw_emissions_data, options = list(scrollX = TRUE))
  })
  
  output$start_generation_data <- DT::renderDataTable({
    DT::datatable(raw_electricity_generation2022, options = list(scrollX = TRUE))
  })
  
  output$clean_vehicle_data <- DT::renderDataTable({
    DT::datatable(vehicle_data, options = list(scrollX = TRUE))
  })
  
  output$clean_emission_data <- DT::renderDataTable({
    DT::datatable(state_co2, options = list(scrollX = TRUE))
  })
  
  output$clean_ev_data <- DT::renderDataTable({
    DT::datatable(electric_vehicle_data, options = list(scrollX = TRUE))
  })
  
}








