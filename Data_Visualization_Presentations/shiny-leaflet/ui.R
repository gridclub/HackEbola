
shinyUI(fluidPage(
  
  ## blank title, but put in a special title for window tab
  titlePanel("", windowTitle = "Sierra Leone Ebola cases and travel restrictions"),
  ## Add a little CSS to make the map background pure white
  tags$head(tags$style("
                                      #showcase-code-position-toggle, #showcase-sxs-code { display: none; }
                                      .floater { background-color: white; padding: 8px; opacity: 1; border-radius: 6px; box-shadow: 0 0 15px rgba(0,0,0,0.2); }
                                      ")),
  ## Map Creation
  leafletMap("map", width=1200, height=800, 
             options=list(center = c(8, -11), zoom=8)), 
  
  ## Info Box 
  absolutePanel(left=50, bottom=50, width=300, class="floater",
                htmlOutput("details")),
  
  # Legend
  
  absolutePanel(
    right = 50, top = 50, draggable=FALSE, style = "", 
    class = "floater",
    #                      strong("Crude Suicide Rate"),
    tags$table(
      mapply(function(from, to, color) {
        tags$tr(
          tags$td(tags$div(
            style = sprintf("width: 16px; height: 16px; background-color: %s;", color)
          )),
          tags$td(prettyNum(round(from), big.mark = ","), "to", 
                  prettyNum(round(to), big.mark = ","), align = "right")
        )
      }, 
      colorRanges$from, colorRanges$to, map_colors[-length(map_colors)],
      SIMPLIFY=FALSE),
      tags$td(tags$div(
        style = sprintf("width: 16px; height: 16px; background-color: %s;", "#999999")
      )),
      tags$td("Data not available", align = "right")
    )
    
  )
  
))