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

end_point <- "/api/SafetyRatings?format=json"
years <- make_request(end_point)$ModelYear

ui <- fluidPage(
  navbarPage(
    "Car Safety Ratings",
    tabPanel(
      sidebarLayout(
        sidebarPanel(
          selectInput(
            "year",
            label = "Choose a year",
            choices = years
          ),
          uiOutput("make_choice"),
          uiOutput("model_choice")
        ),
        mainPanel(
          tableOutput("chosen_vehicle_table")
        )
      )
    ),
    "Child Seat Inspection Locations",
    tabPanel(
      sidebarLayout(
        sidebarPanel(
          textInput("zip", label = "Zip Code")
        ),
        mainPanel()
      )
    )
  )
)
shinyUI(ui)