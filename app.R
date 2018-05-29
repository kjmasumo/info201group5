make_request <- function(end_point){
  base_uri <- "https://webapi.nhtsa.gov"
  response <- GET(paste0(base_uri, end_point))
  body <- content(response, "text")
  parsed <- fromJSON(body)
  final <- parsed$Results
  final
}
test1 <- make_request(paste0("/api/SafetyRatings/modelyear/", "2013", "?format=json"))
test <- make_request("/api/SafetyRatings/VehicleId/7520?format=json")
View(test)
View(test1)
get_year_info <- function(year){
  for (i in make_request(paste0("/api/SafetyRatings/modelyear/", year, "?format=json"))$Make) {
    for (j in make_request(paste0("/api/SafetyRatings/modelyear/", year, "/make/", i, "?format=json"))$Model) {
      for (h in make_request(paste0("/api/SafetyRatings/modelyear/", year, "/make/", i, "/model/", gsub(" ", "%20", j), "?format=json"))$VehicleId){
        temp <- make_request(paste0("/api/SafetyRatings/VehicleId/", h, "?format=json"))
        #test <- rbind(test, temp)
      }
    }
  }
}

new_thing <- get_year_info("2013")
new_thing


base_uri <- "https://webapi.nhtsa.gov"
end_point <- "/api/SafetyRatings/VehicleId/8230?format=json"
response <- GET(paste0(base_uri, end_point))
body <- content(response, "text")
parsed <- fromJSON(body)
final <- parsed$Results
View(final)

the_ui <- fluidPage(
  titlePanel("Overall Safety Rating vs. Number of complaints"),
  sidebarLayout(
    sidebarPanel(
      sliderInput(
        "year",
        "Year",
        value = 2013,
        min = 2000,
        max = 2019
      )
    ),
    mainPanel(
      plotOutput("scatter", click = "plot_click"),
      fluidRow(
        column(
          12,
          h4("Click on the graph for more info"),
          verbatimTextOutput("click_info")
        )
      )
    )
  )
)

the_server <- function(input, output){
  #output$scatter <- renderPlot({
  #  ggplot(get_year_input(input$year), aes_string("OverallRating", "ComplaintsCount"))+ geom_point(stat = "identity")+
  #    labs(
  #      title = "Overall Saftey Rating vs Compalints",
  #      x = "Overall Rating",
  #      y = "Number of Complaints"
  #    )
  #})
  output$scatter <- renderPlot({
    ggplot(final, aes_string("OverallRating", "ComplaintsCount"))+ geom_point(stat = "identity")+
      labs(
        title = "Overall Saftey Rating vs Compalints",
        x = "Overall Rating",
        y = "Number of Complaints"
      )
  })
  output$click_info <- renderPrint({
    nearPoints(select(final, VehicleDescription, OverallRating, ComplaintsCount), input$plot_click)
  })
}

shinyApp(the_ui, the_server)























