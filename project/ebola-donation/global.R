
# Load packages -----------------------------------------------------------

pkgTest <- function(x)
{
  if (!require(x,character.only = TRUE))
  {
    install.packages(x,dep=TRUE)
    if(!require(x,character.only = TRUE)) stop("Package not found")
  }
}

pkgTest("devtools")
if(!require("googleCharts")) {install_github('jcheng5/googleCharts'); library(googleCharts)}
pkgTest("shiny")
pkgTest("lubridate")
pkgTest("tidyr")
pkgTest("Hmisc")
pkgTest("reshape2")
pkgTest("ggplot2")
pkgTest("ggthemes")
if(!require("dplyr")) install_github('hadley/dplyr')


# Set graph colors (special for colorblind people) ------------------------

cbbPalette <- c("#000000", "#E69F00", "#56B4E9", "#009E73", "#F0E442", 
                "#0072B2", "#D55E00", "#CC79A7")

ebola_dat <- read.csv("data/ebola-donations-final.csv") # eventually I want to obtain this in the munge script
ebola_dat$Date = as.Date(ebola_dat$Date, "%Y-%m-%d")
source("munge/01.r")



