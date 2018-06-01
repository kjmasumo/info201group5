# years <- make_request("/api/Complaints/vehicle?format=json")
# vector_years <- as.character(as.vector(years[,1]))
# vector_years <- vector_years[2:66]
# complaint_count <- c()
# recall_count <- c()
# for(year in vector_years){
#   complaint_count <- c(get_request_count(paste0("/api/Complaints/vehicle/modelyear/", year, "?format=json")), complaint_count)
#   recall_count <- c(get_request_count(paste0("/api/Recalls/vehicle/modelyear/", year, "?format=json")), recall_count)
# }
# write.csv(makers_complained, file = "data/makers_complained.csv")
# write.csv(makers_recalled, file = "data/makers_recalled.csv")
library(httr)
library(dplyr)
library(knitr)
library(jsonlite)
library(ggplot2)
library(shiny)
library(rsconnect)
makers_complained <- read.csv("data/makers_complained.csv", stringsAsFactors = F)
makers_recalled <- read.csv("data/makers_recalled.csv", stringsAsFactors = F)

source("setup.R")

server <- function(input, output, session){
  
  output$chosen_year_table <- renderPlot({
    if(input$plot_choice == "Complaints"){
      result_plot <- ggplot(data = makers_complained)+
        geom_point(mapping = aes(x = vector_years, y = count_reversed)) +
        geom_smooth(mapping = aes(x = vector_years, y = count_reversed)) +
        theme(axis.text.x = element_text(size = 11, angle = 90, hjust = 0))+
        labs(
          x = "Year",
          y = "Cars Complained About",
          title = "Total Cars Complained About Over Time"
        )
    }else{
      result_plot <- ggplot(data = makers_recalled)+
        geom_point(mapping = aes(x = vector_years, y = count_reversed)) +
        geom_smooth(mapping = aes(x = vector_years, y = count_reversed)) +
        theme(axis.text.x = element_text(size = 11, angle = 90, hjust = 0))+
        labs(
          x = "Year",
          y = "Cars with Recalls",
          title = "Total Cars that had a Part Recalled Over Time"
        )
    }
    result_plot
  })
  
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
      scale_x_discrete(limits = c("OverallRating","FrontCrashDriversideRating", "FrontCrashPassengerSideRating", "OverallFrontCrashRating", "OverallSideCrashRating", "SideCrashDriversideRating", "SideCrashPassengerSideRating", "RolloverRating")) +
      theme(axis.text.x = element_text(size = 13, angle = 50, hjust = 1)) +
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
    if(input$zip != ""){
      results <- make_request(paste0("/api/CSSIStation/zip/", input$zip, "?format=json"))
      if(is.data.frame(results)){
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
    }
  })
  output$help <- renderText("Input valid zip code to display inspection locations")

  output$CPbar <- renderPlot({
    ggplot(data = datum) +
      geom_bar(mapping = aes(x= Company)) +
      theme(axis.text.x = element_text(size = 11, angle = 90, hjust = 0.5))
  })
  
  output$CPtable <- renderDataTable(datum)
}
shinyServer(server)

