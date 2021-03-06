# Take advantage of more shinydashboard features by adding boxes

# Code common across app. Can also place in separate global.R -----------
# Load packages
library(shiny)
library(tidyverse)
library(shinydashboard)
# Load data. Anonymized upsides data for 10 countries for BAU, FMSY, and Opt policies
upsides_data <- read_csv("../data/upsides_data.csv")

# User interface. Can also place in separate ui.R -----------
ui <- function(request){
  dashboardPage(
    
    # Application title -----------
    dashboardHeader(title = "Fishery Projections Explorer"),
    
    # Initiate Sidebar layout  -----------
    dashboardSidebar(
      
      # Input for country filter  -----------
      selectInput(inputId = "country",
                  label = "Select country for figures",
                  choices = unique(upsides_data$Country) %>% sort()),
      
      # Input for policy filter  -----------
      checkboxGroupInput(inputId = "policy",
                         label = "Select policies for figures",
                         choices = unique(upsides_data$Policy),
                         selected = "Business As Usual"),
      
      # Bookmark button  -----------
      bookmarkButton()
    ),
    
    # Configure main panel  -----------
    dashboardBody(
      
      # Initialize fluid row  -----------
      fluidRow(
        
        # Display biomass figure  -----------
        # Put inside a box  -----------
        box(title = "Biomass Projections", 
            status = "primary",
            solidHeader = TRUE,
            width = 4,
            plotOutput("biomass_plot")),
        
        
        # Display catch figure  -----------
        # Put inside a box  -----------
        box(title = "Catch Projections", 
            status = "primary",
            solidHeader = TRUE,
            width = 4,
            plotOutput("catch_plot")),
        
        # Display profits figure  -----------
        # Put inside a box  -----------
        box(title = "Profits Projections", 
            status = "primary",
            solidHeader = TRUE,
            width = 4,
            plotOutput("profits_plot"))
        
      )
    )
  )
}
# Server. can also place in separate server.R -----------
server <- function(input, output, session) {
  
  # Reactive filtered dataset  -----------
  filtered_data <- reactive({
    
    # Require policy and country input - don't go further until it exists
    req(input$policy, input$country)
    
    upsides_data %>%
      filter(Country == input$country &
               Policy %in% input$policy)
    
  })
  
  # Render biomass plot using filtered data set  -----------
  output$biomass_plot <- renderPlot({
    
    filtered_data() %>%
      ggplot(aes(x = Year, y = Biomass, color = Policy)) +
      geom_line()
    
  })
  
  # Render catch plot using filtered data set  -----------
  output$catch_plot <- renderPlot({
    
    filtered_data() %>%
      ggplot(aes(x = Year, y = Catch, color = Policy)) +
      geom_line()
    
  })
  
  # Render profits plot using filtered data set  -----------
  output$profits_plot <- renderPlot({
    
    filtered_data() %>%
      ggplot(aes(x = Year, y = Profits, color = Policy)) +
      geom_line()
    
  })
  
}

shinyApp(ui, server, enableBookmarking = "url")