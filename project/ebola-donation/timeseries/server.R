# server.R

library(ggplot2)
library(reshape2)
library(dplyr)
library(scales)
library(shiny)
library(foreign)
library(lubridate)
library(ggthemes)

load("data/cases.rdata")
load("data/dons.rdata")

### making static plots

# ggplot(cases, aes(x = Date, y = value)) + 
#   geom_line(aes(color = country)) +
#   geom_point(aes(color = country)) +
# #   scale_y_log10() +
#   facet_wrap(~variable)
# 
# ggplot(dons, aes(x = Date, y = USD.given)) +
#   geom_line(aes(color = destination)) +
#   geom_point(aes(color = destination))

# 
# countries = c("Guinea", "Sierra Leone")
# variables = c("Cases", "Deaths", "USD.cumulative")
# 
# plotdat = cases %>%
#   dcast(Date + country ~ variable) %>%
#   inner_join(dons, by = c("Date" = "Date", "country" = "destination")) %>%
#   melt(id.vars = c("Date", "country", "donor", "recipient", "appeal", "description")) %>%
#   filter(variable %in% variables, country %in% countries) %>%
#   tbl_df()
#   
# 
# ggplot(plotdat, aes(x = Date, y = value)) +
#   geom_line(aes(y = value, color = country)) +
#   geom_point(aes(color = country)) +
#   facet_wrap(~variable, scales = "free_y", ncol = 1)
# 
# load("../cache/cases.RData")
# load("../cache/dons.RData")
ebola_data = read.csv("data/ebola-donations-final.csv") %>%
  mutate(Date = as.Date(ymd(Date)))

# ggplot(ebola_data, aes(x = Date, y = val.approx))
  

shinyServer(function(input, output) {
  data_plot <- reactive({
    cases = cases
    dons = dons
    countries = input$countries
    variables = input$variables
    pdata = ebola_data %>%
      select(Date, country, val.approx, USD_given, USD_interp) %>%
      melt(id.vars = c("Date", "country")) %>%
      filter(variable %in% input$variables, country %in% input$countries)
    pdata
  })

  plot <- reactive({
    g = ggplot(data_plot(), aes(x = Date, y = value)) +
      geom_line(aes(y = value, color = country)) +
      facet_wrap(~variable, scales = "free_y", ncol = 1) + theme_economist()

    if(!input$log){
      return(g)
    } else{
      h <- g + scale_y_log10() 
      return(h)
    }
  })

  output$plot <- renderPlot({
    print(plot())
  })
})
