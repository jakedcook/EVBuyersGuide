# load libraries
library(shinythemes)
library(shiny)
library(leaflet)
library(shinydashboard)
library(dashboardthemes)
library(plotly)
library(maps)

# define UI
ui <- navbarPage(
  title = "EV Buyers Guide",
  theme = shinytheme("cyborg"),  # dark theme style
  
  # External links in the nav bar
  tabPanel("Home",
           tags$ul(class = "nav navbar-nav navbar-right",
                   tags$li(a(href = "https://www.youtube.com/@JDC6", icon("youtube"), "My Channel", target="_blank")),
                   tags$li(a(href = "https://www.linkedin.com/in/jake-d-cook/", icon("linkedin"), "My Profile", target="_blank")),
                   tags$li(a(href = "https://github.com/jakedcook/EVBuyersGuide", icon("github"), "Source Code", target="_blank"))
           ),# close links
           
           # About the Data
           tabPanel("About the Data",
                    tabsetPanel(
                      tabPanel("About", icon = icon("address-card"),
                               fluidRow(
                                 column(6,
                                        wellPanel(
                                          h3("Welcome", style = "color: white; font-weight: bold"),
                                          p("This dashboard was built to examine how regions and different charging grids can affect EV carbon dioxide emissions. The original hypothesis was that, from a carbon dioxide standpoint, 
                                          EVs actually underperform compared to the most efficient internal combustion/hybrid vehicles. To find the most carbon dioxide-efficient vehicle, head over to the State Data tab, 
                                            enter the state in which you live, and compare the vehicles! You might be surprised by what you find!"),
                                          
                                          p("The data is sourced from the United States Environmental Protection Agency (EPA), specifically from 2022. Two different CSV files were used and combined to form what is called 'completeStateData'. 
                                          Another CSV was used to create the electric vehicle and internal combustion/hybrid vehicle tables. 
                                            The data was rigorously cleaned to make it usable, callable, relatable, and understable."),
                                          p("Originally, this data was stored in a PostgreSQL database managed through pgAdmin4, and was accessed locally using a 'localhost' connection script in the global.R file. 
                                          To efficiently deploy this application to shinyapps.io, the database was replaced with CSV files to eliminate external dependencies. 
                                            However, a database solution is preferred for future redeployments, as it would simplify the process of updating the app with new data from the EPA for 2023 and 2024.")
                                        ) # close well panel
                                        ),# close column
                                 column(6,
                                        wellPanel(
                                          tags$img(src = "chargedEarth.jpg", width = "100%")
                                          )# close wellPanel
                                        ) # close column
                               )# close fluid row
                               ), # close about tab panel ,
                      tabPanel("Data", icon = icon("database"),
                               fluidRow(
                                 column(12,
                                        wellPanel(
                                          h3("Data Exploration and Cleaning Process"),
                                          p("Here we can see our starting point on the right with our three different datasets, and our final cleaned datasets on the left that were used to further our research."),
                                          h5("Clean Non-EV and EV Data"),
                                          p("The complete vehicle dataset provided an extensive amount of information for electric and internal combustion/hybrid vehicles. 
                                            During the cleaning process, we filtered to only include vehicles from model year 2022, as that was the most complete state energy data available. 
                                            Using the key provided with the dataset from the EPA, we began translating column names and eliminating columns that weren't relevant. 
                                            A column of 0 was initialized as a placeholder that dynamically fills when a state is selected."),
                                          h5("Clean State Energy/Emissions Data"),
                                          p("This dataset was the result of merging two different datasets from the EPA. 
                                            Since the carbon dioxide values were originally in millions of tons, we converted them into grams to match the vehicle data, which uses grams per mile. 
                                            Other columns not related to carbon emissions were retained to give users a sense of EV charging costs in their state, although that was not the focus of this research. 
                                            A metric titled EfficiencyScore was created to identify which states had the highest net kilowatt-hour generation with the lowest grams of carbon dioxide. 
                                            The worst-performing state, the District of Columbia, was set as the baseline or zero mark, and the scale increases from there. 
                                            This helps illustrate that even if a state has relatively low carbon emissions, it could still be inefficient if it produces very little net kilowatt-hour.")
                                        )# close well panel
                                        ),#close column
                                 column(6,
                                        wellPanel(
                                          h4("Cleaned Data"),
                                          h5("Non EV Data"),
                                          DT::dataTableOutput("clean_vehicle_data"),
                                          h5("State Energy/Emissions Data"),
                                          DT::dataTableOutput("clean_emission_data"),
                                          h5("EV Data"),
                                          DT::dataTableOutput("clean_ev_data")
                                        )),
                                 column(6,
                                        wellPanel(
                                          h4("Raw Data"),
                                          h5("Complete Vehicle Data"),
                                          DT::dataTableOutput("start_vehicle_data"),
                                          h5("State CO2 Emissions in Milions of Tons"),
                                          DT::dataTableOutput("start_emission_data"),
                                          h5("State Generation and Sales"),
                                          DT::dataTableOutput("start_generation_data")
                                        ))
                               ))
                    ) # close tabsetPanel,
           )# close about
  ), # close home
  
  
  # Emissions Map
  tabPanel("Emissions Map",
           tags$ul(class = "nav navbar-nav navbar-right",
                   tags$li(a(href = "https://www.youtube.com/@JDC6", icon("youtube"), "My Channel", target="_blank")),
                   tags$li(a(href = "https://www.linkedin.com/in/jake-d-cook/", icon("linkedin"), "My Profile", target="_blank")),
                   tags$li(a(href = "https://github.com/jakedcook/EVBuyersGuide", icon("github"), "Source Code", target="_blank"))
           ),# close links
           fluidRow(
             column(12, 
                    wellPanel(
                      h4("Grams of Carbon Dioxide Choropleth"),
                      plotOutput("co2_map")
                    )#close wellpanel
              ),# close column 
             column(6,
                    wellPanel(
                      h4("What You See"),
                      p("This section shows how states differ in the amount of carbon dioxide (in grams) emitted from electricity generation. 
                      States like Texas, California, Florida, Pennsylvania, and Ohio are among the top emitters. 
                      However, this view is based solely on total carbon dioxide emissions. In the next tab, titled 'Region Data', 
                        we take a closer look at the metrics that drive electricity generation and emissions."),
                      h4("Important to Note"),
                      p("It's important to consider how state size and population can impact total carbon emissions. 
                        However, as we’ll see, the structure of a state’s electrical grid plays the most significant role in determining grams of carbon dioxide emitted per kilowatt-hour.")
                    )), #close column 
             column(6,
                    wellPanel(
                      h4("Top Emitters by Millions of Tons of CO₂"),
                      plotlyOutput("tons_co2")
                    ))
                    )# close fluid row
  ), # close emissions map
  
  # Region Data
  tabPanel("Region Data",
           tags$ul(class = "nav navbar-nav navbar-right",
                   tags$li(a(href = "https://www.youtube.com/@JDC6", icon("youtube"), "My Channel", target="_blank")),
                   tags$li(a(href = "https://www.linkedin.com/in/jake-d-cook/", icon("linkedin"), "My Profile", target="_blank")),
                   tags$li(a(href = "https://github.com/jakedcook/EVBuyersGuide", icon("github"), "Source Code", target="_blank"))
           ),# close links
           tabsetPanel(
             tabPanel("North Data",
                      fluidRow(
                        column(12, 
                               wellPanel(
                                 h4("North Region Data", style = "color: #ffffff; font-weight: bold;"),
                                 selectInput("yaxis_var_north", "Select Variable to Plot:",
                                             choices = r_choices,
                                             selected = "efficiencyScore"),
                                 plotlyOutput("north_data_plot")
                                        )# close well panel
                               )# close column 
                      )# close fluid row
             ), # close north data 
             
             tabPanel("South Data",
                      fluidRow(
                        column(12,
                               wellPanel(
                                 h4("South Region Data", style = "color: #ffffff; font-weight: bold;"),
                                 selectInput("yaxis_var_south", "Select Variable to Plot",
                                             choices = r_choices,
                                             selected = "efficiencyScore"),
                                 plotlyOutput("south_data_plot")
                               )# close well panel
                        )# close column
                      )# close fluid row
             ), # close south data 
             
             tabPanel("Mid-West Data",
                      fluidRow(
                        column(12,
                               wellPanel(
                                 h4("Mid-West Region Data", style = "color: #ffffff; font-weight: bold;"),
                                 selectInput("yaxis_var_midWest", "Select Variable to Plot:",
                                             choices = r_choices,
                                             selected = "efficiencyScore"),
                                 plotlyOutput("midWest_data_plot")
                                        )#close well panel
                               )#close column
                      )# close fluid row
             ), # close mid-west data 
             
             tabPanel("West Data",
                      fluidRow(
                        column(12,
                               wellPanel(
                                 h4("West Region Data", style = "color: #ffffff; font-weight: bold;"),
                                 selectInput("yaxis_var_west", "Select Variable to Plot:",
                                             choices = r_choices,
                                             selected = "efficiencyScore"),
                                 plotlyOutput("west_data_plot")
                               )# close well panel
                               )# close column 
                      )# close fluid row
             ) # close west data
           ), # close tab panel
           fluidRow(
             column(6,
                    wellPanel(
                      h4("The Metrics"),
                      p("In this section, you can explore how states within each region perform across various energy-related metrics. 
                      Key metrics include an Efficiency Score, which reflects how much energy a state produces relative to the carbon dioxide it emits. 
                      You can also view data such as grams of CO₂ per kilowatt-hour, net kilowatt-hour generation, total grams of CO₂ emitted, 
                      CO₂ emissions in millions of tons for easier interpretation, average retail electricity price in cents per kilowatt-hour, 
                        total electricity sales in megawatt-hours (MWh), net summer capacity (MWh), and net generation (MWh)."),
                      p("What you’ll find is that the most significant factor influencing how efficiently an EV performs in terms of 
                        carbon emissions is how cleanly your state produces its electricity."),
                      h4("EV-Friendly States"),
                      p("The best states to own an electric vehicle are those with the lowest grams of carbon dioxide per kilowatt-hour. 
                      These states are typically powered by nuclear, hydro, wind, or natural gas. Most have already retired coal plants, 
                        are in the process of retiring them, or use coal only as a minor or legacy backup source.")
                    )),#close well and column 
             column(6,
                    wellPanel(
                      h4("Top 2 EV Friendly States Per Region"),
                      h6("North - New Hampshire & Connecticut"),
                      h6("South - South Carolina & Alabama"),
                      h6("Mid-West - South Dakota & Iowa"),
                      h6("West - Oregon & Washington"),
                      plotlyOutput("best_ev_states")
                    )) # close well and column 
           ) # close fluid row
  ), # close region data
  
  # State Data / Find Your EV
  tabPanel("State Data",
           tags$ul(class = "nav navbar-nav navbar-right",
                   tags$li(a(href = "https://www.youtube.com/@JDC6", icon("youtube"), "My Channel", target="_blank")),
                   tags$li(a(href = "https://www.linkedin.com/in/jake-d-cook/", icon("linkedin"), "My Profile", target="_blank")),
                   tags$li(a(href = "https://github.com/jakedcook/EVBuyersGuide", icon("github"), "Source Code", target="_blank"))
           ),# close links
           tabsetPanel(
             tabPanel("Find your EV",
                      fluidRow(
                        column(12,
                               wellPanel(
                                 h4("Are EVs Any Better in Your State?"),
                                 p("Use the dropdown to select your state and see how electric vehicles compare in terms of carbon dioxide emissions. 
                                 Each vehicle’s performance is adjusted based on your state’s electricity grid. 
                                   Look for lower 'Grams of CO₂ per Mile' to find the cleanest option in your region.")
                               ))# close column/well panel
                      ),#close fluid row
                      h4(selectInput("selected_state", "Chose Your State:",
                                     choices = stateNames)),
                      fluidRow(
                        column(6, 
                               wellPanel(
                                 h4("Electric Vehicles"),
                                 DT::dataTableOutput("ev_table")
                               )
                        ),
                        column(6,
                               wellPanel(
                                 h4("Internal Combustion/Hyrbid Vehicles"),
                                 DT::dataTableOutput("ice_table")
                               )
                        )
                      )
             ) # close EV tab panel
           ) # close all 
  ) # close state data tab 
) # close navbar 

  