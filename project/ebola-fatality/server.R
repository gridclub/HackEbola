shinyServer(function(input, output, session) {
  
  ## suidf is a reactive dataframe. Necessary for when summary/plot/map have common input (Multiple Variables). Not in this project
  ebola_df <- reactive({
    ebola_df <- ebola_dat %>%
      filter(Date == as.Date(input$date, origin = "1970-01-01"), !is.na(Location))
    ebola_df$Location <- capitalize(tolower(ebola_df$Location))
    ebola_df
  })
  
  ## create the plot of the data
  #   output$plot <- reactive({
  #     guinea_df <- guinea_df()
  #     if(is.null(input$city)){
  #       plot_df <- ebola_dat %>%
  #         filter(country == "Guinea", localite == "National", category == input$category) %>%
  #         group_by(month) %>%
  #         summarise(value = max(value))
  #       
  #       plot_df$month <- months(as.Date(paste0("2014-", plot_df$month, "-01")))
  #       
  #       colnames(plot_df) <- c("Month", input$category)
  #       
  #       return(list(
  #         data=googleDataTable(plot_df),
  #         options = list(
  #           vAxis = list(
  #             title = paste("Number of", input$category, "in Guinea each month")
  #           )
  #         )))
  #     }
  #         
  #     cities_df <- guinea_df %>%
  #       filter(sdr_name %in% input$city) %>%
  #       data.frame()
  #     
  #     plot_df <- spread(data=cities_df, key=sdr_name, value=value)[,-1]
  #     
  #     plot_df$month <- months(as.Date(paste0("2014-", plot_df$month, "-01")))
  #     colnames(plot_df)[1] <- c("Month")
  #     
  #     ## this outputs the google data to be used in the UI to create the dataframe
  #     list(
  #       data=googleDataTable(plot_df),
  #       options = list(
  #         vAxis = list(
  #           title = paste("Number of", input$category, "each month")
  #         )
  #       ))
  #   })
  #   
  #   
  #   observe({
  #         ## only run when 'back' is clicked
  #         input$back
  # 
  #         ## use isolate so that action is only run one time
  #         isolate({
  #             ## if unclicked, do not change months
  #             if(input$back == 0)
  #                 return()
  #             ## find currently set date
  #             old.date <- as.numeric(input$date)
  #             if(old.date == 8){
  #                 return(updateSelectInput(session, "date", selected = 6))
  #             }
  #             ## go to previous month, unless at first month, in which case stay there
  #             new.date <- ifelse(old.date - 1 < 3, 3, old.date - 1)
  #             updateSelectInput(session, "date", selected = new.date)
  # 
  #         })
  #     })
  # 
  #     ## update input$date when actionButton 'forward' is clicked
  #     observe({
  #         input$forward
  #         ## use isolate so that action is only run one time
  #         isolate({
  #             ## if unclicked, do not change months
  #             if(input$forward == 0)
  #                 return()
  #             ## find currently set date
  #             old.date <- as.numeric(input$date)
  #             ## go to next month, unless at last month, in which case stay there
  #             num_months <- 10
  #             if(old.date == 6){
  #                 return(updateSelectInput(session, "date", selected = 8))
  #             }
  #             new.date <- ifelse(old.date + 1 > num_months, num_months, old.date + 1)
  #             updateSelectInput(session, "date", selected = new.date)
  # 
  #         })
  #     })
  
  output$map <- reactive({
#     browser()
    ebola_df <- ebola_df()
    
    map_df <- ebola_df[,c("Location", "Fatality", "Cases")]
    
    colnames(map_df) <- c("City", "Fatality Rate", "Cases")
    
    list(data=googleDataTable(map_df),
         options = list(
           colorAxis = list(
#              values = "USD Donations",
             maxValue = max(ebola_dat$Fatality, na.rm=T),
             colors = c("red", "yellow", "green")),
           sizeAxis = list(
#              values = "Cases",
             maxValue = max(ebola_dat$Cases, na.rm=T),
             minValue = 0)
         ))
  })
  
})
