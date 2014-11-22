shinyUI(fluidPage(
    ## this starts the googleCharts engine
    googleChartsInit(),
    ## create title
    titlePanel("Ebola cases in Guinea"),
    ## create sidebar
    sidebarLayout(
        sidebarPanel(
            ## in map, allow for timespan selection
            conditionalPanel(
                condition="input.tabs == 'Map'",
                selectInput("date", "Select Month",
                            choices = c("March" = 3,
                                        "April" = 4,
                                        "May" = 5,
                                        "June" = 6,
#                                         "July" = 7,
                                        "August" = 8,
                                        "September" = 9,
                                        "October" = 10)),
                actionButton("back", "Previous"), actionButton("forward", "Next"),
                tags$hr()
            ),

                selectInput("category", "Select Category",
                            choices = list("Cases",
                                           "Confirmed cases",
                                           "Deaths",
                                           "New cases",
                                           "Probable cases",
                                           "Suspected cases")),

            conditionalPanel(
                condition="input.tabs == 'Plot'",
                selectInput("city", "Select City", multiple = TRUE,
                            choices = names(table(guinea_dat$sdr_name[which(guinea_dat$sdr_name > 0)])))
                ),

            tags$hr(),

            ## author line
            h6("Created by:"),
            h6("Stephen A Lauer")

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

                             region = "GN",
                             displayMode = "markers",
#                              resolution = "provinces",

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
                ## plot tab with google chart options
                tabPanel("Time Series",
                         ## make chart title here (otherwise not centered)
                         h4(uiOutput("plot_title"), align="center"),
                         ## make line chart
                         googleLineChart("plot", width="100%", height="475px", options = list(

                             ## set fonts
                             fontName = "Source Sans Pro",
                             fontSize = 14,

                             ## set axis titles, ticks, fonts, and ranges
                             hAxis = list(
                                 #title = "",
                                 #format = "####-##-##",
                                 #                ticks = seq(1999, 2011, 2),
                                 #                viewWindow = xlim,
                                 textStyle = list(
                                     fontSize = 14),
                                 titleTextStyle = list(
                                     fontSize = 16,
                                     bold = TRUE,
                                     italic = FALSE)
                             ),
                             vAxis = list(
                                 title = "Number of cases per biweek",
                                 textStyle = list(
                                     fontSize = 14),
                                 titleTextStyle = list(
                                     fontSize = 16,
                                     bold = TRUE,
                                     italic = FALSE)
                             ),

                             ## set legend fonts
                             legend = list(
                                 textStyle = list(
                                     fontSize=14)),

                             ## set chart area padding
                             chartArea = list(
                                 top = 50, left = 75,
                                 height = "75%", width = "65%"
                             ),

                             
                             ## set colors
                             colors = cbbPalette,

                             ## set point size
                             pointSize = 3,

                             # set tooltip font size
                             tooltip = list(
                                 textStyle = list(
                                     fontSize = 14)
                             )
                         )),
                         value="Plot"),
                id="tabs")
        )
    )
))