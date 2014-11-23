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

ebola_dat <- read.csv("~/Google Drive/HackEbola/project/ebola-donation/ebola-donations-final.csv")

ebola_dat$Date <- as.Date(ymd(ebola_dat$Date))
