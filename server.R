library("httr")
library("jsonlite")
library("knitr")
library("dplyr")
library("ggplot2")

make_request <- function(end_point){
  base_uri <- "https://webapi.nhtsa.gov"
  response <- GET(paste0(base_uri, end_point))
  body <- content(response, "text")
  parsed <- fromJSON(body)
  final <- parsed$Results
  final
}

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
  
  output$chosen_vehicle_table <- renderPlot({
    curr_ID <- curr_car()
    results <- make_request(paste0("/api/SafetyRatings/VehicleID/", curr_ID, "?format=json"))
    vehicle_description <- results["VehicleDescription"]
    #results <- select(results, OverallRating, OverallFrontCrashRating, OverallSideCrashRating, RolloverRating)
    results[results == "Not Rated"] <- 0
    
    tests <- colnames(results)
    test_results <- as.numeric(as.vector(results[1,]))
    modified <- data.frame(tests, results = test_results)
    #modified[1, 2] <- results["VehicleDescription"]
    car_plot <- ggplot(data = modified)+
      geom_col(mapping = aes(tests, results), stat = "identity", fill = "blue") +
      scale_y_continuous(limits = c(0,5)) +
      scale_x_discrete(limits = c("OverallRating", "OverallFrontCrashRating", "OverallSideCrashRating", "RolloverRating")) +
      labs(
        title = paste0("Test Results for ", vehicle_description),
        x = "Tests",
        y = "Rating (out of 5)"
      )
    car_plot
  })
  
  observe({
    makes_choice <- make_request(paste0("/api/SafetyRatings/modelyear/", input$year, "?format=json"))$Make
    updateSelectInput(session, 'makes', label = 'Choose a make', choices = makes_choice)
  })

  output$model_choice <- renderUI({
    models <- make_request(paste0("/api/SafetyRatings/modelyear/", input$year, "/make/", input$makes, "?format=json"))$Model
    selectInput('models', label = 'Choose a model', choices = models)
  })
  
  output$inspection_location <- renderTable({
    results <- make_request(paste0("/api/CSSIStation/zip/", input$zip, "?format=json"))
    if(!is.data.frame(results)){
      print("Input Valid Zip Code")
    }
    else {
      results$Contact <- paste(results$ContactFirstName, results$ContactLastName)
      results$Address <- paste0(results$AddressLine1, " ", results$City, ", ", results$State, " ", results$Zip)
      if(is.null(results$Email)){
        results <- select(results, Organization, Address, Contact, Phone1, OperationHours)
      }
      else{
        results <- select(results, Organization, Address, Contact, Email, Phone1, OperationHours)
      }
      return(results)
    }
  })
}

shinyServer(server)

