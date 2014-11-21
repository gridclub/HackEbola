ebola_dat <- read.delim("sub-national-time-series-data.csv")
ebola_dat$date <- as.Date(ebola_dat$date, origin = "1900-01-01")
ebola_dat$month <- month(ebola_dat$date)

dat <- tbl_df(ebola_dat) %>% select(country, date, category, value, date, sources, contains("sdr")) %>%
    filter(category=="Cases") %>% 
    group_by(country, date) %>%
    summarize(cum_cases=sum(value)) %>%
    mutate(inc_cases=cum_cases-lag(cum_cases))

qplot(date, cum_cases, geom="line", color=country, data=dat)
qplot(date, inc_cases, geom="smooth", color=country, data=dat, se=FALSE) + ylim(-10, 170) + theme_bw()
