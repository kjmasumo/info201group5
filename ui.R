base_uri <- "https://one.nhtsa.gov/webapi"
end_point2 <-"/api/CivilPenalties?format=json"
response <- GET(paste0(base_uri, end_point2))
body <- content(response, "text")
datum <- fromJSON(body)
datum <- datum$Results
datum <- datum %>% 
  select(-AgreementDate, -PenaltyReceivedDate)
fee_range <- range(datum$Amount)

source("setup.R")

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
      'Complaints and Recalls Over Time',
      sidebarLayout(
        sidebarPanel(
          radioButtons('plot_choice', label = "Choose which plot to view", choices = c("Complaints", "Recalls"))
        ),
        mainPanel(
          plotOutput('chosen_year_table')
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
    tabPanel(
      "Analysis",
      h1("Data Analysis"),
      tags$em("How has the number of complaints changed over time?"),
      p("The way the API was set up posed a significant challenge for us to answer this question. The year was
        the parameter required when searching for a car, so questions pertaining to a variable over time
        required many loops to gather all the possible data. In addition to this, if too many GET requests
        were made while the shiny app was loading, it would freeze and never load. We settled on graphing
        the number of cars that were complained about, rather than the total number of complaints as an
        estimate for the total number of complaints. This graph showed that the number of complaints did
        increase from the years 1950 to 2007, but then began to decline. The number of cars sold over time 
        has also gone down over time, which accounts for some of the decline, but not all of it. It is possible
        that cars have also gotten safer over time, which leads to fewer complaints."),
      tags$em("How has the number of recalls changed over time?"),
      p("This graph led to similar issus as the complaints graph, and also showed a similar trend. While the
        number of cars sold in the US has declined over time, the decline doesn't account for all of the drop
        in the number of recalls, suggesting that cars might have gotten safer, leading to fewer recalls."),
      tags$em("How do those to relate to each other?"),
      p("The graphs of the recalls over time and the complaints over time are very similar which makes sense.
        If the number of complaints in a given year was very high, then it is more likely that the number of 
        recalls in that year were also high, given that there were a higher number of problems that customers
        had with their cars."),
      tags$em("Which companies recieved the highest number of Civil Penalties?"),
      p("G&K Automotive Conversion and NexL Sport tied for the highest number of Civil Penalites with 11.
        This is surprsing given that larger companies like Toyota and Ford recived significantly fewer
        pentalties than these companies. NexL Sport's penalties were mostly tied to a defect in a helmet they
        manufactured, which led to several penalites. G&K Automotive's penalties had to do with a False Certification
        of Compliance, which led to several penalties."),
      tags$em("What safety rating did my car get?"),
      p("In the Car Safety Ratings tab, you can select your model year, make, and model, and you can view
        the safety ratings that your car received.")
      
    ),
  # Stops errors from displaying.
  tags$style(type="text/css",
             ".shiny-output-error { visibility: hidden; }",
             ".shiny-output-error:before { visibility: hidden; }"
  )
)
)


shinyUI(ui)
