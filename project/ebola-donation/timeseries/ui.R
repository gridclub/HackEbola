# ui.R
library(shiny)

shinyUI(fluidPage(
    titlePanel("Plotting Ebola"),

    sidebarLayout(
        sidebarPanel("Interactive plot components",

                     checkboxGroupInput("countries",
                                        label = h3("Countries to display"),
                                        choices = c("Guinea" = "Guinea",
                                            "Liberia" = "Liberia",
                                            "Sierra Leone" = "Sierra Leone"),
                                        selected = c("Liberia", "Guinea", "Sierra Leone")),
                     checkboxGroupInput("variables",
                                        label = h3("Variables to display"),
                                        choices = c("Cases" = "val.approx",
                                                    "Dollars Given" = "USD_given", 
                                                    "Cumulative Dollars Given" = "USD_interp"),
                                        selected = "USD_given"),
                     checkboxInput("log", "Plot y-axis on log scale")
                     ),

        mainPanel(p("USD donated and number of ebola cases"),

                  plotOutput("plot")
                  )
        )
))
