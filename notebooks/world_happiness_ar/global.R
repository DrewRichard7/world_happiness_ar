# World Happiness Index - R Shiny app by Andrew Richard
## Nashville Software School - DS8

library(shiny)
library(tidyverse)
library(DT)
library(glue)
library(bslib)
library(plotly)
library(shinyjs)

# DELETE WHEN COMPLETE: 
# ----
# setwd("~/Documents/projects/nss/nss_projects/world_happiness_ar/notebooks/world_happiness_ar")

data <- read_csv('../../data/happy_sad_sugar_fish.csv')
