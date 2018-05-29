make_request <- function(end_point){
  base_uri <- "https://webapi.nhtsa.gov"
  response <- GET(paste0(base_uri, end_point))
  body <- content(response, "text")
  parsed <- fromJSON(body)
  final <- parsed$Results
  final
}

end_point <- "/api/SafetyRatings?format=jsn"
years <- make_request(end_point)$ModelYear

ui <- fluidPage(
  titlePanel("Car Safety Ratings"),
  sidebarLayout(
    sidebarPanel(
      selectInput(
        'year',
        label = "Choose a year",
        choices = years
      ),
      #selectInput('makes', choices = NULL, label = ""),
      #selectInput('models', choices = NULL, label = "")
      uiOutput('make_choice'),
      uiOutput('model_choice')
    ),
    mainPanel(
      tableOutput('chosen_vehicle_table')
    )
  )
)

shinyUI(ui)
