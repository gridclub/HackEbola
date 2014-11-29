shinyUI(fluidPage(
    ## this starts the googleCharts engine
    googleChartsInit(),
    ## create title
    titlePanel("Donations and Ebola cases in West Africa"),
    ## create sidebar
    sidebarLayout(
        sidebarPanel(
            ## in map, allow for timespan selection
            conditionalPanel(
                condition="input.tabs == 'Map'",
                sliderInput("date", "Days since May 1", min = 16151, max = 16394, value = 16151,
                            animate=animationOptions(interval=100, loop=F, playButton = NULL,
                                                     pauseButton = NULL)),
                #                 actionButton("back", "Previous"), actionButton("forward", "Next"),
                tags$hr()
            ),

            conditionalPanel(
                condition="input.tabs == 'Plot'",
                checkboxGroupInput("countries", "Countries to display", 
                                   choices = levels(ebola_donations$country),
                                   selected = c("Liberia", "Guinea", "Sierra Leone")),
                #                 checkboxGroupInput("ebolaVars", "Ebola variables to display", 
                #                                    choices = c(levels(ebola_byCountry$ebola_var)),
                #                                    selected = "Cases"),
                #                 checkboxGroupInput("aidVars", "Humanitarian aid variables to display", 
                #                             choices = levels(ebola_donations$variable),
                #                             selected = "USD.given"),
                checkboxGroupInput("variables", "variables to display", 
                                   choices = levels(ebola_donations$variable),
                                   selected = c("Cases", "USD.given")),
                checkboxGroupInput("donorClasses", "Donor categories", 
                            choices = levels(ebola_donations$class),
                            selected = levels(ebola_donations$class)),
                checkboxInput("log", "Plot y-axis on log scale"),
                tags$hr()
                ),

            ## author line
            h6("Created by:"),
            h6("Mark Hagemann & Stephen A Lauer")

        ),

        ## create main panel
        mainPanel(
            ## create tabs
            tabsetPanel(
                ## plot map
                tabPanel("Map", ## make chart title here (otherwise not centered)
                         h4(uiOutput("map_title"), align="center"),
                         ## make line chart
                         googleGeoChart("map", width="100%", height="475px", options = list(

                             data = list("map"),

                             region = "011",
                             displayMode = "markers",
                            #     resolution = "provinces",

                             ## set fonts
                             fontName = "Source Sans Pro",
                             fontSize = 14,

                             ## set legend fonts
                             legend = list(
                                 textStyle = list(
                                     fontSize=14)),

                             ## set chart area padding
                             chartArea = list(
                                 top = 50, left = 75,
                                 height = "75%", width = "70%"
                             ),

                             # set colors
                             colorAxis = list(
                                 minValue = 0),


                             # set tooltip font size
                             tooltip = list(
                                 textStyle = list(
                                     fontSize = 14)
                             )
                         )), id="Map"),
                ## plot tab, merged from Mark's plots (based on cmrivers)
                tabPanel("Time Series",
                         ## make chart title here (otherwise not centered)
                         h4(uiOutput("plot_title"), align="center"),
                         ## make line chart
                         plotOutput("tsplot"),
                         value = "Plot"),
                id="tabs")
        )
    )
))