# World Happiness Index - R Shiny app by Andrew Richard
## Nashville Software School - DS8
here::i_am("notebooks/app/global.R")
library(here)
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
library(rmarkdown)


data <- tibble(read_csv(here('data/happy_sad_sugar_fish.csv'))) |> 
  arrange(country)

