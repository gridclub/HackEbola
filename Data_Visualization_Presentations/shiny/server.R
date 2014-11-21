shinyServer(function(input, output, session) {
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
            new.date <- ifelse(old.date - 1 < 1, 1, old.date - 1)
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
            num_months <- 11
            if(old.date == 6){
                return(updateSelectInput(session, "date", selected = 8))
            }
            new.date <- ifelse(old.date + 1 > num_months, num_months, old.date + 1)
            updateSelectInput(session, "date", selected = new.date)

        })
    })

    output$map <- reactive({
        #         browser()
        if(length(which(guinea_dat$category == input$category &&
                            guinea_dat$month == as.numeric (input$date))) != 0){

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
        }

        map_df <- data

        list(data=googleDataTable(map_df),
             options = list(
                 colorAxis = list(
                     maxValue = max(guinea_dat$value[which(guinea_dat$category == input$category)], na.rm=T),
                     colors = c("green", "yellow", "red"))
             ))
    })

})
