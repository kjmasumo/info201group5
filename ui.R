<<<<<<< HEAD
library("httr")
library("jsonlite")
library("knitr")
library("dplyr")
library("shiny")

make_request <- function(end_point){
  base_uri <- "https://webapi.nhtsa.gov"
  response <- GET(paste0(base_uri, end_point))
  body <- content(response, "text")
  parsed <- fromJSON(body)
  final <- parsed$Results
  final
}
base_uri <- "https://one.nhtsa.gov/webapi"
end_point2 <-"/api/CivilPenalties?format=json"
response <- GET(paste0(base_uri, end_point2))
body <- content(response, "text")
datum <- fromJSON(body)
datum <- datum$Results
datum <- datum %>% 
  select(-AgreementDate, -PenaltyReceivedDate)
fee_range <- range(datum$Amount)

=======
source("setup.R")
>>>>>>> samuelm
end_point <- "/api/SafetyRatings?format=json"
years <- make_request(end_point)$ModelYear

year_range <- make_request("/api/Complaints/vehicle?format=json")
year_range <- year_range[-1, ]
lowest <- as.numeric(year_range[65])
highest <- as.numeric(year_range[1])

ui <- fluidPage(
  navbarPage(
    "NHTSA data",
    tabPanel(
      "Car Safety Ratings",
      sidebarLayout(
        sidebarPanel(
          selectInput(
            "year",
            label = "Choose a year",
            choices = years
          ),
          selectInput(
            'makes',
            label = 'Choose a make',
            choices = "ACURA"
          ),
          #uiOutput("make_choice"),
          uiOutput("model_choice")
        ),
        mainPanel(
          plotOutput("chosen_vehicle_table")
        )
      )
    ),
    tabPanel(
      'Complaints Over Time',
      sidebarLayout(
        sidebarPanel(
          sliderInput('year_range', label = "Year Range", min = lowest, max = highest, value = c(2000, 2001), sep = "")
        ),
        mainPanel(
          plotOutput('chosen_year_table')
        )
      )
<<<<<<< HEAD
    ),
    tabPanel(
      "Civil Penalties",
      sidebarLayout(
        sliderInput("fee",
          label = "Fee Amount (in dollars)", min = fee_range[1], max = fee_range[2],
          value = fee_range
        ),
        selectInput("company", label = "Company", choices = unique(datum$Company))
      ),
      mainPanel(
        tabsetPanel(
          type = "tabs",
          tabPanel("Civil Penalty", dataTableOutput("CPtable")),
          tabPanel("Fees by Year Plot", plotOutput("CPplot")),
          tabPanel("Company Penalties", plotOutput("CPbar"))
=======
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
>>>>>>> samuelm
        )
      )
    ),
    tabPanel(
      "Child Seat Inspection Locations",
      sidebarLayout(
        sidebarPanel(
          textInput("zip", label = "Zip Code", value = 90210),
          textOutput("help")
        ),
        mainPanel(
          tableOutput("inspection_location")
        )
      )
    ),
  # Stops errors from displaying.
  tags$style(type="text/css",
             ".shiny-output-error { visibility: hidden; }",
             ".shiny-output-error:before { visibility: hidden; }"
  )
)
)


shinyUI(ui)
