pkgTest <- function(x)
{
  if (!require(x,character.only = TRUE))
  {
    install.packages(x,dep=TRUE)
    if(!require(x,character.only = TRUE)) stop("Package not found")
  }
}
pkgTest("devtools")
if(!require("dplyr")) install_github('hadley/dplyr')
pkgTest("shiny")
install_github('leaflet-shiny', 'jcheng5')
if(!require("leaflet")) install_github('jcheng5/leaflet-shiny')
pkgTest("RJSONIO")
pkgTest("tidyr")
pkgTest("Hmisc")
pkgTest("stringr")

SLE_adm2 <- fromJSON("SLE_adm/SLE_adm2.geojson")
GIN_adm2 <- fromJSON("GIN_adm/GIN_adm2.geojson")
LBR_adm1 <- fromJSON("LBR_adm/LBR_adm1.geojson")

west_africa_adm2 <- list(type = c(SLE_adm2[[1]], GIN_adm2[[1]], LBR_adm1[[1]]),
                         features = c(SLE_adm2[[2]], GIN_adm2[[2]], LBR_adm1[[2]]))

travel_restrict <- read.delim("travel-restrict.csv")
travel_restrict$date_from <- ifelse(travel_restrict$date_from == "n/a", 0, 1)

ebola_dat <- read.delim("sub-national-time-series-data.csv")

paint_brush <- colorRampPalette(colors=c("white", "red3"))
map_colors <- c(paint_brush(n=5), "#999999")


tr_df <- travel_restrict %>%
    filter(restrictionscale == "Domestic") %>%
    group_by(location) %>%
    summarise(restricted = max(date_from, na.rm=T))

map_dat <- ebola_dat %>%
    filter(category == "Cases", sdr_name != "") %>%
    group_by(sdr_name) %>%
    summarise(value = sum(value, na.rm = T))

map_dat$sdr_name <- ifelse(map_dat$sdr_name == "Grand Bassa", "GrandBassa", 
                           as.character(map_dat$sdr_name))

map_dat$sdr_name <- ifelse(map_dat$sdr_name == "Rivercess", "RiverCess", map_dat$sdr_name)
# map_dat$sdr_name <- gsub("Grand ", "Grand", map_dat$sdr_name)
map_dat$sdr_name <- ifelse(map_dat$sdr_name == "Western Area Rural", "WesternRural", 
                           as.character(map_dat$sdr_name))
map_dat$sdr_name <- ifelse(map_dat$sdr_name == "Western Area Urban", "WesternUrban", 
                           as.character(map_dat$sdr_name))
map_dat$sdr_name <- gsub(" ", "", map_dat$sdr_name)

#####################################MAP CREATION##############

cuts <- quantile(map_dat$value, probs = seq(0, 1, length.out = length(map_colors)))

## assign colors to each entry in the data frame
color <- as.integer(cut2(map_dat$value, cuts = cuts))
map_dat <- cbind.data.frame(map_dat, color)
map_dat$color <- ifelse(is.na(map_dat$color), length(map_colors), 
                        map_dat$color)
map_dat$opacity <- 0.7

map_dat <- merge(x = map_dat, y = tr_df, by.x = "sdr_name", by.y = "location", all = TRUE)


## for each county in the map, attach the Crude Rate and colors associated
for(i in 1:length(west_africa_adm2$features)){
  map_prop_index_index <- ifelse(west_africa_adm2$features[[i]]$properties$ISO == "LBR", "NAME_1", "NAME_2")
  west_africa_adm2$features[[i]]$properties[map_prop_index_index] <- 
    str_replace(iconv(west_africa_adm2$features[[i]]$properties[[map_prop_index_index]], to = "ASCII//TRANSLIT"), "[^[:alnum:]]", "")
  map_prop_index <- match(west_africa_adm2$features[[i]]$properties[[map_prop_index_index]],
                          map_dat$sdr_name)
  ## Each feature is a county
  west_africa_adm2$features[[i]]$properties["Cases"] <- 
    ifelse(is.null(map_dat[map_prop_index, "value"]), NA, map_dat[map_prop_index, "value"])
  ## Style properties
  west_africa_adm2$features[[i]]$properties$style <- list(
    fill=TRUE, 
    ## Fill color has to be equal to the map_dat color and is matched by county
    fillColor = map_colors[ifelse(is.null(map_dat$color[map_prop_index]), 6, 
                                  map_dat$color[map_prop_index])], 
    fillOpacity=0.7, 
    ## "#000000" = Black, "#999999"=Grey, 
    weight=ifelse(map_dat$restricted[map_prop_index] == 1, 2, 1), stroke=TRUE, 
    color=ifelse(map_dat$restricted[map_prop_index] == 1, "#000000", "white"), 
    opacity=ifelse(map_dat$restricted[map_prop_index] == 1, 1, 0)
  )
}

colorRanges <- data.frame(
  from = head(cuts, length(cuts)-1),
  to = tail(cuts, length(cuts)-1)
)