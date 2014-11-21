require(dplyr)
require(googleCharts)
require(shiny)
require(lubridate)

ebola_dat <- read.delim("~/Google Drive/slauer_git/HackEbola/HackEbola/sub-national-time-series-data.csv")
ebola_dat$date <- as.Date(ebola_dat$date, origin = "1900-01-01")
ebola_dat$month <- month(ebola_dat$date)

guinea_dat <- ebola_dat %>%
    filter(country == "Guinea", sdr_name != "") %>%
    group_by(category, month, sdr_name) %>%
    summarise(value = sum(value))

guinea_dat$category <- as.character(guinea_dat$category)
guinea_dat$sdr_name <- as.character(guinea_dat$sdr_name)
guinea_dat$value <- as.numeric(guinea_dat$value)
