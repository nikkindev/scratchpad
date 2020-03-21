# install.packages("RCurl")
# install.packages("dplyr")
# install.packages("leaflet")
# install.packages("maps")
# install.packages("stringr")
# install.packages("shiny")
# install.packages('rsconnect')

rm(list = ls())

library(RCurl)
library(dplyr)
library(leaflet)
library(maps)
library(stringr)
library(shiny)
library(rsconnect)

mapdata <- world.cities %>% filter(capital == 1)

# Get cases, deaths and recovered data
cases_URL <- getURL("https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_19-covid-Confirmed.csv")
deaths_URL <- getURL("https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_19-covid-Deaths.csv")
rec_URL <- getURL("https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_19-covid-Recovered.csv")

cases <- read.csv(text = cases_URL, check.names = F, stringsAsFactors = F)
deaths <- read.csv(text = deaths_URL, check.names = F, stringsAsFactors = F)
recovered <- read.csv(text = rec_URL, check.names = F, stringsAsFactors = F)

# Renaming country column
colnames(cases)[2] <- "country"
colnames(deaths)[2] <- "country"
colnames(recovered)[2] <- "country"

# Sum over all cases
cases <- cases %>% 
  replace(is.na(.), 0) %>% 
  mutate(cases = rowSums(.[5:ncol(cases)])) %>% 
  select(-c(5:(ncol(cases)-1))) %>% 
  group_by(country) %>%
  summarise(cases = sum(cases))

# Sum over all deaths
deaths <- deaths %>% 
  replace(is.na(.), 0) %>% 
  mutate(deaths = rowSums(.[5:ncol(deaths)])) %>% 
  select(-c(5:(ncol(deaths)-1))) %>% 
  group_by(country) %>%
  summarise(deaths = sum(deaths))

# Sum over all recovered
recovered <- recovered %>% 
  replace(is.na(.), 0) %>% 
  mutate(recovered = rowSums(.[5:ncol(recovered)])) %>% 
  select(-c(5:(ncol(recovered)-1))) %>% 
  group_by(country) %>%
  summarise(recovered = sum(recovered))

# Combining into one df
data <- merge(merge(cases, deaths, by = "country"), recovered, by = "country")

# Matching countries in 'data' to countries in 'mapdata'
data$country <- data$country %>%
  str_replace_all(c("Serbia","Montenegro","Kosovo"), c("Serbia and Montenegro","Serbia and Montenegro","Serbia and Montenegro")) %>%
  str_replace(regex("^Taiwan*$"), "Taiwan") %>%
  str_replace("United Kingdom", "UK") %>%
  str_replace("US", "USA") %>%
  str_replace("Korea, South", "Korea South") %>%
  str_replace("Bahamas, The", "Bahamas") %>%
  str_replace("Gambia, The", "gambia") %>%
  str_replace("Czechia", "Czech Republic") %>%
  str_replace("North Macedonia", "Macedonia") %>%
  str_replace("gambia", "Gambia") %>%
  str_replace("Czechia", "Czech Republic") %>%
  str_replace("Cabo Verde", "Cape Verde") %>%
  str_replace("Saint Vincent and the Grenadines", "Saint Vincent and The Grenadines") %>%
  str_replace("Eswatini", "Swaziland") %>%
  str_replace("Cruise Ship", "0") %>%
  str_replace("Fiji", "0") %>%
  str_replace("Eswatini", "Swaziland")

# For country names that doesn't work with regex
data$country[data$country == "Congo (Brazzaville)"] <- "Congo"
data$country[data$country == "Congo (Kinshasa)"] <- "Congo"
data$country[data$country == "Taiwan*"] <- "Taiwan"
data$country[data$country == "Cote d'Ivoire"] <- "Ivory Coast"
data[!(data$country %in% mapdata$country.etc),]

# Grouping again for Congo renaming
data <- data %>% 
  group_by(country) %>%
  summarise(cases = sum(cases),
            deaths = sum(deaths),
            recovered = sum(recovered))

# Adding a label column
data$label <- paste(data$country," | ",
                    "Cases:",data$cases," | ",
                    "Deaths: ", data$deaths," | ",
                    "Recovered: ", data$recovered)

# Adding dummy row for matching NA values
mapdata[nrow(mapdata)+1,] <- rep(0,ncol(mapdata))

# Adding latitude and longitude columns
data$lat = mapdata[match(data$country,mapdata$country.etc, nomatch = nrow(mapdata)),"lat"]
data$long = mapdata[match(data$country,mapdata$country.etc, nomatch = nrow(mapdata)),"long"]

# Removing the dummy row
data <- data %>% filter(country != "0")

# Draw the map
m <- leaflet() %>% 
  addProviderTiles(providers$Stamen.TonerBackground) %>% 
  addCircles(data = data, 
             lat = ~lat, 
             lng = ~long,
             radius = ~cases,
             #radius = ~ifelse(cases > 10000, cases, 10000),
             color = "red",
             label = ~label,
  ) %>%
  setView(lat = 30, lng = 35, zoom = 1.5)


function(input, output, session) {
  
  output$mymap <- renderLeaflet({
    leaflet() %>% 
      addProviderTiles(providers$Stamen.TonerBackground) %>% 
      addCircles(data = data, 
                 lat = ~lat, 
                 lng = ~long,
                 radius = ~cases,
                 #radius = ~ifelse(cases > 10000, cases, 10000),
                 color = "red",
                 label = ~label,
      ) %>%
      setView(lat = 30, lng = 35, zoom = 1.5)
  })
  
  url <- a("Github code", href="https://github.com/nikkindev/scratchpad/tree/master/corona-visualization-r", target = "_blank")
  
  output$tab <- renderUI({
    url
  })
}
