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

fluidPage(
  titlePanel("COVID-19 Visualization"),
  uiOutput("tab"),
  textOutput("date"),
  leafletOutput("mymap", width = "90%", height = 800),
  p(),
  
)
