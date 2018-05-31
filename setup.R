library(httr)
library(dplyr)
library(knitr)
library(jsonlite)
library(ggplot2)

make_request <- function(end_point){
  base_uri <- "https://webapi.nhtsa.gov"
  response <- GET(paste0(base_uri, end_point))
  body <- content(response, "text")
  parsed <- fromJSON(body)
  final <- parsed$Results
  final
}

get_request_count <- function(end_point){
  base_uri <- "https://webapi.nhtsa.gov"
  response <- GET(paste0(base_uri, end_point))
  body <- content(response, "text")
  parsed <- fromJSON(body)
  final <- parsed$Count
  final
}

end_point2 <-"/api/CivilPenalties?format=json"

datum <- make_request(end_point2)
datum <- datum %>% 
  select(-AgreementDate, -PenaltyReceivedDate)


MPdatum <- datum %>% 
  group_by(Company) %>% 
  summarize(Count = n()) %>% 
  filter(Count == max(Count))

p <- length(MPdatum$Company)
MPphrase <- if(p>1){
  paste(MPdatum$Company[1],
        paste("and", MPdatum$Company[2:p] ))
} else{
    MPdatum$Company
  }
