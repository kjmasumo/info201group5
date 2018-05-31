make_request <- function(end_point){
  base_uri <- "https://webapi.nhtsa.gov"
  response <- GET(paste0(base_uri, end_point))
  body <- content(response, "text")
  parsed <- fromJSON(body)
  final <- parsed$Results
  final
}

test1 <- make_request(paste0("/api/SafetyRatings/modelyear/", "2013", "?format=json"))
overall_data <- make_request("/api/SafetyRatings/VehicleId/7520?format=json")
ac_test <- select(test, OverallRating, ComplaintsCount, VehicleDescription)
View(ac_test)
View(test1)
get_year_info <- function(year){
  for (mk in make_request(paste0("/api/SafetyRatings/modelyear/", year, "?format=json"))$Make) {
    for (mdl in make_request(paste0("/api/SafetyRatings/modelyear/", year, "/make/", mk, "?format=json"))$Model) {
      for (id in make_request(paste0("/api/SafetyRatings/modelyear/", year, "/make/", mk, "/model/", gsub(" ", "%20", mdl), "?format=json"))$VehicleId){
        temp <- make_request(paste0("/api/SafetyRatings/VehicleId/", id, "?format=json"))
        temp2 <- select(temp, OverallRating, ComplaintsCount, VehicleDescription)
        test <- rbind(overall_data, temp2)
      }
    }
  }
}

update <- function(id){
  temp <- make_request(paste0("/api/SafetyRatings/VehicleID/", id, "?format=json"))
  overall_data <- rbind(overall_data, temp)
  overall_data
}

end_point <- "/api/SafetyRatings?format=jsn"
years <- make_request(end_point)$ModelYear

the_ui <- fluidPage(
  titlePanel("Overall Safety Rating vs. Number of complaints"),
  sidebarLayout(
    sidebarPanel(
      sliderInput(
        "year",
        "Year",
        min = min(years),
        max = max(years),
        value = 2010,
        step = 1
      ),
      uiOutput('make_choice'),
      uiOutput('model_choice'),
      actionButton("add", "Add Car")
    ),
    mainPanel(
      plotOutput("scatter", click = "plot_click"),
      fluidRow(
        column(
          12,
          h4("Click on the graph for more info"),
          verbatimTextOutput("click_info")
        )
      ),
      tableOutput("update_stuff")
    )
  )
)

temp1 <- make_request(paste0("/api/SafetyRatings/VehicleID/", "7731", "?format=json"))
test <- rbind(overall_data, temp1)
View(test)
View(overall_data)

the_server <- function(input, output){
  update_graph <- eventReactive(
    input$add,
    {
      test_data <- overall_data
      #temp <- make_request(paste0("/api/SafetyRatings/VehicleID/", id, "?format=json"))
      #use_this <- rbind(overall_data, temp)
      #use_this
      test_data
    }
  )
  output$update_stuff <- renderDataTable({
    overall_data
  })
  output$scatter <- renderPlot({
    ggplot(update_graph(), aes_string("OverallRating", "ComplaintsCount"))+ geom_point(stat = "identity")+
      labs(
        title = "Overall Saftey Rating vs Compalints",
        x = "Overall Rating",
        y = "Number of Complaints"
      )
  })
  output$click_info <- renderPrint({
    nearPoints(select(overall_data, VehicleDescription, OverallRating, ComplaintsCount), input$plot_click)
  })
  output$make_choice <- renderUI({
    makes <- make_request(paste0("/api/SafetyRatings/modelyear/", input$year, "?format=json"))$Make
    selectInput('makes', label = 'Choose a make', choices = makes)
  })
  
  output$model_choice <- renderUI({
    models <- make_request(paste0("/api/SafetyRatings/modelyear/", input$year, "/make/", input$makes, "?format=json"))$Model
    selectInput('models', label = 'Choose a model', choices = models)
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
}

shinyApp(the_ui, the_server)









