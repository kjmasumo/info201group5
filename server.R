library("httr")
library("jsonlite")
library("knitr")
library("dplyr")

make_request <- function(end_point){
  base_uri <- "https://webapi.nhtsa.gov"
  response <- GET(paste0(base_uri, end_point))
  body <- content(response, "text")
  parsed <- fromJSON(body)
  final <- parsed$Results
  final
}


# end_point <- "/api/SafetyRatings?format=json"
# years <- make_request(end_point)$ModelYear

server <- function(input, output, session){
  
  curr_car <- reactive({
    model <- input$models
    if(!(" " %in% model)){
      model <- gsub(" ", "%20", input$models)
    }
    results <- make_request(paste0(
      "/api/SafetyRatings/modelyear/", 
      input$year, 
      "/make/",
      input$makes,
      "/model/",
      model,
      "?format=json"
      ))
    results$VehicleId[1]
  })
  
  output$chosen_vehicle_table <- renderTable({
    curr_ID <- curr_car()
    results <- make_request(paste0("/api/SafetyRatings/VehicleID/", curr_ID, "?format=json"))
    results
  })
  
  # observe({
  #   makes <- make_request(paste0("/api/SafetyRatings/modelyear/", input$year, "?format=json"))$Make
  #   #models <- make_request(paste0("/api/SafetyRatings/modelyear/", input$year, "/make/", input$makes, "?format=json"))$Model
  #   updateSelectInput(session, 'makes', label = 'Choose a make', choices = makes)
  #   #updateSelectInput(session, 'models', label = 'Choose a model', choices = "models")
  # })
  # 
  # observe({
  #   models <- make_request(paste0("/api/SafetyRatings/modelyear/", input$year, "/make/", input$makes, "?format=json"))$Model
  #   updateSelectInput(session, 'models', label = 'Choose a model', choices = "models")
  # })
  output$make_choice <- renderUI({
   makes <- make_request(paste0("/api/SafetyRatings/modelyear/", input$year, "?format=json"))$Make
   selectInput('makes', label = 'Choose a make', choices = makes)

  })

  output$model_choice <- renderUI({
    models <- make_request(paste0("/api/SafetyRatings/modelyear/", input$year, "/make/", input$makes, "?format=json"))$Model
    selectInput('models', label = 'Choose a model', choices = models)
  })
}

shinyServer(server)

