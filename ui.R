ui <- fluidPage(
  titlePanel("Car Safety Ratings"),
  sidebarLayout(
    sidebarPanel(
      selectInput(
        'year',
        label = "Choose a year",
        choices = years
      ),
      uiOutput('make_choice'),
      uiOutput('model_choice')
    ),
    mainPanel(
      tableOutput('chosen_vehicle_table')
    )
  )
)

shinyUI(ui)