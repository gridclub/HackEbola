shinyServer(function(input, output, session) {
  
  ## suidf is a reactive dataframe. Necessary for when summary/plot/map have common input (Multiple Variables). Not in this project
  guinea_df <- reactive({
    guinea_df <- guinea_dat %>%
      filter(category == input$category)
    guinea_df
  })
  
#   ## Create summary table
#   output$summary <- renderDataTable({
#     ## Make reactive dataframe into regular dataframe
#     suidf <- suidf()
#     
#     ## if a user chooses Single Year, display only data from that year (dpylr)
#     if(input$timespan == "sing.yr"){
#       df <- filter(suidf, Year==input$year)
#     }
#     
#     ## if a user chooses Multiple Years, display data from all years in range
#     if(input$timespan == "mult.yrs"){
#       range <- seq(min(input$range), max(input$range), 1)
#       df <- c()
#       for(i in 1:length(range)){
#         bbb <- subset(suidf, Year==range[i])
#         df <- rbind.data.frame(df, bbb)
#       }
#     }
#     
#     ## make counties a vector based on input variable
#     if(!is.null(input$county))
#       counties <- input$county
#     ## if none selected, put all counties in vector
#     if(is.null(input$county))
#       counties <- names(table(suidata[,1]))[c(1:7, 9:12,14)]
#     
#     ## if the user checks the meanUS box or the meanMA box, add those to counties vector
#     if(input$meanUS){
#       if(input$meanMA){
#         counties <- c("US", "MA", counties) ## US and MA  
#       } else{
#         counties <- c("US", counties) ## US only
#       }
#     } else{
#       if(input$meanMA){
#         counties <- c("MA", counties) ## US only ## MA only
#       }
#     }
#     
#     ## create a dataframe consisting only of counties in vector
#     df2 <- c()
#     for(i in 1:length(counties)){
#       bbb <- subset(df, County==counties[i])
#       df2 <- rbind.data.frame(df2, bbb)
#     }
#     
#     ## make column names more pretty (i.e. no periods)
#     colnames(df2)[7:10] <- c("Crude Rate (per 100,000)", 
#                              "Crude Rate Lower Bound", 
#                              "Crude Rate Upper Bound", 
#                              "Crude Rate Standard Error")
#     
#     return(df2)
#   }, options=list(searching = FALSE, orderClasses = TRUE)) # there are a bunch of options to edit the appearance of datatables, these make them pretty
#   
#   
  
  ## create the plot of the data
  output$plot <- reactive({
    guinea_df <- guinea_df()
    if(is.null(input$city)){
      plot_df <- ebola_dat %>%
        filter(country == "Guinea", localite == "National", category == input$category) %>%
        group_by(month) %>%
        summarise(value = sum(value))
      
      plot_df$month <- months(as.Date(paste0("2014-", plot_df$month, "-01")))
      
      colnames(plot_df) <- c("Month", input$category)
      
      return(list(
        data=googleDataTable(plot_df),
        options = list(
          vAxis = list(
            title = paste("Number of", input$category, "in Guinea each month")
          )
        )))
    }
        
    cities_df <- guinea_df %>%
      filter(sdr_name %in% input$city)
    
    plot_df <- spread(cities_df, sdr_name, value)[,-1]
    
    plot_df$month <- months(as.Date(paste0("2014-", plot_df$month, "-01")))
    colnames(plot_df)[1] <- c("Month")
    
    ## this outputs the google data to be used in the UI to create the dataframe
    list(
      data=googleDataTable(plot_df),
      options = list(
        vAxis = list(
          title = paste("Number of", input$category, "each month")
        )
      ))
  })
  
  
  observe({
        ## only run when 'back' is clicked
        input$back

        ## use isolate so that action is only run one time
        isolate({
            ## if unclicked, do not change months
            if(input$back == 0)
                return()
            ## find currently set date
            old.date <- as.numeric(input$date)
            if(old.date == 8){
                return(updateSelectInput(session, "date", selected = 6))
            }
            ## go to previous month, unless at first month, in which case stay there
            new.date <- ifelse(old.date - 1 < 3, 3, old.date - 1)
            updateSelectInput(session, "date", selected = new.date)

        })
    })

    ## update input$date when actionButton 'forward' is clicked
    observe({
        input$forward
        ## use isolate so that action is only run one time
        isolate({
            ## if unclicked, do not change months
            if(input$forward == 0)
                return()
            ## find currently set date
            old.date <- as.numeric(input$date)
            ## go to next month, unless at last month, in which case stay there
            num_months <- 10
            if(old.date == 6){
                return(updateSelectInput(session, "date", selected = 8))
            }
            new.date <- ifelse(old.date + 1 > num_months, num_months, old.date + 1)
            updateSelectInput(session, "date", selected = new.date)

        })
    })

    output$map <- reactive({
      guinea_df <- guinea_df()
        map_df <- guinea_df %>%
                filter(month == input$date) %>%
                group_by(sdr_name) %>%
                summarise(Count = sum(value, na.rm=T))

            colnames(map_df)[1] <- "City"

            list(data=googleDataTable(map_df),
                 options = list(
                     colorAxis = list(
                         maxValue = max(guinea_df$value[which(guinea_df$category == input$category)], na.rm=T),
                         colors = c("green", "yellow", "red"))
                 ))
    })

})
