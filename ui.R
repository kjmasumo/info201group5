library("httr")
library("jsonlite")
library("knitr")
library("dplyr")
library("shiny")

make_request <- function(end_point){
  base_uri <- "https://one.nhtsa.gov/webapi"
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

end_point <- "/api/SafetyRatings?format=jsn"
years <- make_request(end_point)$ModelYear


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
        )
      )
    ),
    tabPanel(
      "Child Seat Inspection Locations",
      sidebarLayout(
        sidebarPanel(
          textInput("zip", label = "Zip Code", value = NULL)
        ),
        mainPanel(
          tableOutput("inspection_location")
        )
      )
    )
  )
)

shinyUI(ui)
