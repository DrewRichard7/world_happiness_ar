# World Happiness Index - R Shiny app by Andrew Richard
## Nashville Software School - DS8

library(shiny)
library(tidyverse)
library(DT)
library(glue)
library(bslib)
library(plotly)
library(shinyjs)
library(ggrepel)
library(shinythemes)
library(htmltools)
library(markdown)
library(rmarkdown)


data <- tibble(read_csv('data/happy_sad_sugar_fish.csv')) |> 
  arrange(country)

