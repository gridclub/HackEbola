pkgTest <- function(x)
{
  if (!require(x,character.only = TRUE))
  {
    install.packages(x,dep=TRUE)
    if(!require(x,character.only = TRUE)) stop("Package not found")
  }
}
pkgTest("devtools")
if(!require("dplyr")) install_github('hadley/dplyr')
if(!require("googleCharts")) install_github('jcheng5/googleCharts')
pkgTest("shiny")
pkgTest("lubridate")
pkgTest("tidyr")

## Set graph colors (special for colorblind people)
cbbPalette <- c("#000000", "#E69F00", "#56B4E9", "#009E73", "#F0E442", 
                "#0072B2", "#D55E00", "#CC79A7")

## Load data and group cases by month
ebola_dat <- read.delim("sub-national-time-series-data.csv")
ebola_dat$date <- as.Date(ebola_dat$date, origin = "1900-01-01")
ebola_dat$month <- month(ebola_dat$date)

guinea_dat <- ebola_dat %>%
    filter(sdr_name != "") %>%
    group_by(category, month, sdr_name) %>%
    summarise(value = sum(value))

## make sure that classes of columns are correct
guinea_dat$category <- as.character(guinea_dat$category)
guinea_dat$sdr_name <- as.character(guinea_dat$sdr_name)
guinea_dat$value <- as.numeric(guinea_dat$value)
