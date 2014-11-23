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

cleaner_donations <- cleaned_donations %>%
  group_by(Date, destination) %>%
  summarise(USD_given = sum(USD.given))

dates <- seq.Date(from = as.Date("2014-01-01"), to = as.Date("2014-11-20"), by = 1)
donations_interp <- data.frame(Date = rep(dates, each = 3),
                               country = rep(c("Guinea", "Sierra Leone", "Liberia"), 
                                             length(dates)))
donations_interp2 <- merge(x = donations_interp, y = cleaner_donations, 
                           by.x = c("Date", "country"), by.y = c("Date", "destination"), 
                           all.x = TRUE)  

donations_interp2$USD_given <- ifelse(is.na(donations_interp2$USD_given), 0, 
                                      donations_interp2$USD_given)

donations_interp3 <- donations_interp2 %>%
  group_by(country) %>%
  mutate(USD_interp = cumsum(USD_given))

ebola_dat <- merge(x=cases_interp, y=donations_interp3, all=TRUE)

ebola_dat$Date <- as.Date(ebola_dat$Date)
