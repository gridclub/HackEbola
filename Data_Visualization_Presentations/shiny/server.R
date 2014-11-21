shinyServer(function(input, output, session) {
  
  ## suidf is a reactive dataframe. Necessary for when summary/plot/map have common input (Multiple Variables). Not in this project
  suidf <- reactive({
    suidf <- suidata
    suidf    
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
  
#   ## create the plot of the data
#   output$plot <- reactive({
#     moph <- input$moph
#     
#     if(moph == "all")
#       moph <- seq(0, 12)
#     
#     ## format counts into plot format 
#     plot_counts <- merge(counts, thai_prov_data, by="province", all.x=T) %>%
#       filter(disease == 26, date_sick_year >= input$start, MOPH_Admin_Code %in% moph) %>%
#       group_by(date_sick_biweek, date_sick_year) %>%
#       summarise(count = round(sum(count)))
#     
#     ## add date variable
#     plot_counts$date <- biweek_to_date(plot_counts$date_sick_biweek, 
#                                        plot_counts$date_sick_year)
#     
#     plot_forecasts <- merge(forecasts, thai_prov_data, by.x="pid", by.y="FIPS", all.x=T) %>%
#       filter(MOPH_Admin_Code %in% moph) %>%
#       group_by(biweek, year) %>%
#       summarise(predicted_count = round(sum(predicted_count)),
#                 ub = round(sum(ub)),
#                 lb = round(sum(lb)))
#     plot_forecasts$unseen <- plot_forecasts$lb
#     
#     plot_forecasts$date <- biweek_to_date(plot_forecasts$biweek, plot_forecasts$year)
#     
#     plot_df <- merge(plot_counts, plot_forecasts, by = "date", all=T)[,c("date", "count", "predicted_count", "ub", "lb", "unseen")]
#     
#     plot_df$date <- as.Date(plot_df$date)
#     
#     #   plot_df$unused <- ifelse(is.na(plot_df$predicted_count), NA, plot_df$count)
#     
#     plot_df$count <- ifelse(is.na(plot_df$predicted_count), plot_df$count, NA)
#     
#     plot_df <- select(plot_df, date, count, #unused, 
#                       predicted_count, ub, unseen, lb)
#     
#     colnames(plot_df) <- c("Date", "Observed Cases",# "Incomplete Recent Cases",
#                            "Forecasted Cases", "Prediction interval", "Unseen", 
#                            "CI Lower Bound")
#     
#     ## this outputs the google data to be used in the UI to create the dataframe
#     list(
#       data=googleDataTable(plot_df),
#       options = list(
#         vAxis = list(
#           viewWindow = list(max = max(plot_counts$count, plot_forecasts$predicted_count)*1.1)
#         )
#       ))
#   })
#   
  
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
        map_df <- guinea_dat %>%
                filter(category == input$category, month == input$date) %>%
                group_by(sdr_name) %>%
                summarise(Count = sum(value, na.rm=T))

            colnames(map_df)[1] <- "City"

            list(data=googleDataTable(map_df),
                 options = list(
                     colorAxis = list(
                         maxValue = max(guinea_dat$value[which(guinea_dat$category == input$category)], na.rm=T),
                         colors = c("green", "yellow", "red"))
                 ))
    })

})
