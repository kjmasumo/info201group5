library(httr)
library(dplyr)
library(knitr)
library(jsonlite)

make_request <- function(end_point){
  base_uri <- "https://one.nhtsa.gov/webapi"
  response <- GET(paste0(base_uri, end_point))
  body <- content(response, "text")
  parsed <- fromJSON(body)
  final <- parsed$Results
  final
}

end_point2 <-"/api/CivilPenalties?format=json"

datum <- make_request(end_point2)