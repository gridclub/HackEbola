require(dplyr)
require(sp)
require(maptools)
require(rgeos)
require(Hmisc)
require(shiny)
require(leaflet)
require(RJSONIO)
require(rCharts)
require(tidyr)
require(lubridate)

SLE_adm2 <- fromJSON("SLE_adm/SLE_adm2.geojson")

travel_restrict <- read.delim("travel-restrict.csv")
travel_restrict$date_from <- ifelse(travel_restrict$date_from == "n/a", 0, 1)

ebola_dat <- read.delim("sub-national-time-series-data.csv")

paint_brush <- colorRampPalette(colors=c("white", "red3"))
map_colors <- c(paint_brush(n=5), "#999999")


tr_df <- travel_restrict %>%
    filter(country == "Sierra Leone", location != "Sierra Leone", 
           restrictionscale == "Domestic") %>%
    group_by(adm2) %>%
    summarise(restricted = max(date_from, na.rm=T))

map_dat <- ebola_dat %>%
    filter(country == "Sierra Leone", sdr_level == "ADM2", category == "Cases") %>%
    group_by(sdr_name) %>%
    summarise(value = sum(value, na.rm = T))

#####################################MAP CREATION##############

cuts <- quantile(map_dat$value, probs = seq(0.2, 0.8, 0.2))

## assign colors to each entry in the data frame
color <- as.integer(cut2(map_dat$value, cuts = cuts))
map_dat <- cbind.data.frame(map_dat, color)
map_dat$color <- ifelse(is.na(map_dat$color), length(map_colors), 
                        map_dat$color)
map_dat$opacity <- 0.7

map_dat <- merge(x = map_dat, y = tr_df, by.x = "sdr_name", by.y = "adm2", all = TRUE)

map_dat$sdr_name <- ifelse(map_dat$sdr_name == "Western Area Rural", "Western Rural", 
                           as.character(map_dat$sdr_name))

map_dat$sdr_name <- ifelse(map_dat$sdr_name == "Western Area Urban", "Western Urban", 
                           as.character(map_dat$sdr_name))

## for each county in the map, attach the Crude Rate and colors associated
for(i in 1:length(SLE_adm2$features)){
  map_prop_index <- match(SLE_adm2$features[[i]]$properties$NAME_2, map_dat$sdr_name)
  ## Each feature is a county
  SLE_adm2$features[[i]]$properties["Cases"] <- 
    map_dat[map_prop_index, "value"]
  ## Style properties
  SLE_adm2$features[[i]]$properties$style <- list(
    fill=TRUE, 
    ## Fill color has to be equal to the map_dat color and is matched by county
    fillColor = map_colors[map_dat$color[map_prop_index]], 
    fillOpacity=map_dat$opacity[map_prop_index], 
    ## "#000000" = Black, "#999999"=Grey, 
    weight=ifelse(map_dat$restricted[map_prop_index] == 1, 2, 1), stroke=TRUE, 
    color=ifelse(map_dat$restricted[map_prop_index] == 1, "#000000", "white"), 
    opacity=ifelse(map_dat$restricted[map_prop_index] == 1, 1, 0.5)
  )
}

colorRanges <- data.frame(
  from = head(cuts, length(cuts)-1),
  to = tail(cuts, length(cuts)-1)
)