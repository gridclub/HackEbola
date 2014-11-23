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

cases_interp <- read.csv("~/Google Drive/HackEbola/project/ebola-donation/cases_interp.csv")[,-1]
cleaned_donations <- read.csv("~/Google Drive/HackEbola/project/ebola-donation/cleaned_donations.csv")[,-1]

cases_interp$Date <- ymd(cases_interp$Date)
cleaned_donations$Date <- ymd(cleaned_donations$Date)
cases_interp$country <- as.character(cases_interp$country)
cleaned_donations$destination <- as.character(cleaned_donations$destination)

ebola_dat <- merge(x=cases_interp, y=cleaned_donations, 
                   by.x = c("Date", "country"), by.y = c("Date", "destination"),
                   all.x = TRUE, all.y=FALSE)

ebola_dat$USD.given <- ifelse(is.na(ebola_dat$USD.given), 0, ebola_dat$USD.given)

ebola_dat2  <- ebola_dat %>% 
  group_by(country) %>%
  mutate(USD_interp = cumsum(USD.given))
