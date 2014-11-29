shinyServer(function(input, output, session) {
#   browser()
  ## ebola_df is a reactive dataframe. Necessary for when summary/plot/map have common input (Multiple Variables). Not in this project
  ebola_df <- reactive({
#     browser()
    ebola_df <- ebola_dat %>%
      filter(Date == as.Date(input$date, origin = "1970-01-01"), !is.na(location))
    ebola_df$location <- capitalize(tolower(ebola_df$location))
    ebola_df
  })
  
  ## create the plot of the data
  
  data_plot <- reactive({   
#     browser()
    countries = input$countries
    variables = input$variables #c(input$ebolaVars, input$aidVars)
    classes = input$donorClasses
    edata = ebola_donations %>%
      filter(variable %in% variables, country %in% countries,
             class %in% c("none", classes)) %>%
      na.omit()
    edata
  })
  
  tsplot <- reactive({
#     browser()
    g = ggplot(data_plot(), aes(x = Date, y = value)) + 
#       geom_area(aes(fill = country), position = "stack") +
      geom_line(aes(color = country)) +
#       geom_point(aes(shape = class)) +
      facet_wrap(~variable, scales = "free_y", ncol = 1) + theme_economist()
    
    if(!input$log){
      return(g)
    } else{
      h <- g + scale_y_log10() 
      return(h)
    }
  })
  
  
  output$map <- reactive({
#     browser()
    ebola_df <- ebola_df()
    
    map_df <- ebola_df[,c("location", "USD_interp", "val.approx")]
    
    colnames(map_df) <- c("City", "USD Donated (log10)", "Cases")
    map_df[,2] = log10(map_df[,2] + 1)
    
    list(data=googleDataTable(map_df),
         options = list(
           colorAxis = list(
#              values = "USD Donations",
             maxValue = log10(max(ebola_dat$USD_interp, na.rm=T)),
             colors = c("red", "yellow", "green")),
           sizeAxis = list(
#              values = "Cases",
             maxValue = max(ebola_dat$val.approx, na.rm=T),
             minValue = 0)
         ))
  })

  output$tsplot <- renderPlot({
    print(tsplot())
  })
  
})
