
shinyServer(function(input, output, session) {
  values <- reactiveValues(selectedFeature=NULL, highlight=c())
  
  #############################################
  
  ## draw leaflet map
  map <- createLeafletMap(session, "map")
  
  ## the functions within observe are called when any of the inputs are called
  
  ## Does nothing until called (done with action button)
  session$onFlushed(once=TRUE, function() {
#       browser()
      map$addGeoJSON(SLE_adm2) # draw map
  })
  
  observe({
    ## EVT = Mouse Click
    evt <- input$map_click
    if(is.null(evt))
      return()
    
    isolate({
      values$selectedFeature <- NULL
    })
  })
  
  observe({
    evt <- input$map_geojson_click
    if(is.null(evt))
      return()
    
    isolate({
      values$selectedFeature <- evt$properties
    })
  })
  ##  This function is what creates info box
  output$details <- renderText({
    
    ## Before a county is clicked, display a message
    if(is.null(values$selectedFeature)){
      return(as.character(tags$div(
        tags$div(
          h4("Click on a town or city"))
      )))
    }
    #     browser()
    town_name <- values$selectedFeature$NAME_2
    town_value <- prettyNum(values$selectedFeature["Cases"], big.mark = ",")
    
    ## If clicked county has no crude rate, display a message
    if(town_value == "NULL"){
      return(as.character(tags$div(
        tags$h5("The number of cases in ", town_name))))
    }
    ## For a single year when county is clicked, display a message
    as.character(tags$div(
      tags$h4("The number of cases in ", town_name),
      tags$h5(town_value)
    ))
  })
  
})