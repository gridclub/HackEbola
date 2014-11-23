
shinyServer(function(input, output, session) {
  values <- reactiveValues(selectedFeature=NULL, highlight=c())
  
  ## draw leaflet map
  map <- createLeafletMap(session, "map")
  
  ## Does nothing until the session is loaded
  session$onFlushed(once=TRUE, function() {
    map$addGeoJSON(west_africa_adm2) # draw map
  })
  
  ## Grab properties from clicked province
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
    ## Before a district is clicked, display a message
    if(is.null(values$selectedFeature)){
      return(as.character(tags$div(
        tags$div(
          h4("Click on a district"))
      )))
    }
    detail_index <- ifelse(values$selectedFeature$ISO == "LBR", "NAME_1", "NAME_2")
    #     browser()
    district_name <- values$selectedFeature[detail_index]
    district_value <- prettyNum(values$selectedFeature["Cases"], big.mark = ",")
    
    ## If clicked district has no crude rate, display a message
    if(district_value == "NULL"){
      return(as.character(tags$div(
        tags$h5("The number of cases in ", district_name))))
    }
    ## For a single year when county is clicked, display a message
    as.character(tags$div(
      tags$h4("The number of cases in ", district_name),
      tags$h5(district_value)
    ))
  })
  
})