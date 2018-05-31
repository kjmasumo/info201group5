source("setup.R")
end_point <- "/api/SafetyRatings?format=json"
years <- make_request(end_point)$ModelYear


ui <- fluidPage(
  navbarPage("NHTSA data", 
    tabPanel("Car Safety Ratings",
      sidebarLayout(
        sidebarPanel(
          selectInput(
            'year',
            label = "Choose a year",
            choices = years
          ),
          uiOutput('make_choice'),
          uiOutput('model_choice')
        ),
        mainPanel(
          tableOutput('chosen_vehicle_table')
        )
      )
    ), 
    tabPanel("Civil Penalties", 
      mainPanel(
        tabsetPanel( type = "tabs",
          tabPanel("Company Penalties", plotOutput("CPbar")), 
          tabPanel("Civil Penalty", dataTableOutput("CPtable")),
          tabPanel("Summary", 
                   p(
                     "The company with the most civil penalties is ", MPphrase, "with", 
                     MPdatum$Count," penalties."
                     )
               )
        )
      )
    )
  )
)

shinyUI(ui)