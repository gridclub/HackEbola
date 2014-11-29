# Munging script for ebola donation visualization
# 11/28/2014
# Mark Hagemann

ebola01 = read.csv("data/sub-national-time-series-data.csv", sep = "\t")
# glimpse(ebola01)

# dim(ebola01)
# dim(unique(ebola01))

ebola02 = ebola01 %>%
  filter(!is.na(value)) %>%
  mutate(Date = as.Date(date, origin = "1900-01-01")) %>%
  select(Date, country, localite, category, value, sources, 
         sdr_id, sdr_name, sdr_level) %>%
  unique() %>%
  dcast(...~category, value.var = "value", fun.aggregate = mean) # use mean to prevent Infs, may want to change
# glimpse(ebola02)


# Donation data -----------------------------------------------------------

dons01 = read.csv("data/donations_utf8.csv", encoding = "UTF-8") # this was hard to obtain
glimpse(dons01)

dons02 = dons01 %>% 
  transmute(Date = as.Date(Decision.date, format = "%m/%d/%y"), 
            USD.given = as.numeric(gsub(",", "", as.character(USD.committed.contributed))),
            USD.pledged = as.numeric(gsub(",", "", as.character(USD.pledged))),
            donor = Donor,
            recipient = Recipient.Organization,
            destination = Destination.Country,
            appeal = Response.Plan.Appeal.title,
            description = Description) %>%
  group_by(destination) %>%
  arrange(Date) %>%
  mutate(USD.cumulative = cumsum(USD.given)) %>%
  ungroup()
# glimpse(dons02)
# setdiff(ebola02$country, dons02$destination)

startdate = min(c(ebola02$Date, dons02$Date), na.rm = T)
enddate = max(c(ebola02$Date, dons02$Date), na.rm = T)

naToZero = function(x) {x[is.na(x)] = 0; x}

# This not finished yet. How to handle weird "localite" values?
ebola_dat2 = ebola02 %>%
  merge(dons02, by.x = c("Date", "country"), by.y = c("Date", "destination"),
        all = T) #%>%
#   merge(data.frame(Date = seq.Date(startdate, enddate, by = 1)), all = T) %>%
#   mutate(USD.given = naToZero(USD.given), USD.pledged = naToZero(USD.pledged)) %>%
#   arrange(Date) #%>%
#   group_by(country) %>%
#   mutate(USD.cumulative = cumsum(USD.given)) %>%
#   ungroup()

# glimpse(ebola_dat)

ebola_byCountry = ebola02 %>% 
  melt(measure.vars = c("Cases", "Confirmed cases", "Deaths", "New cases", 
                        "Probable cases", "Suspected cases")) %>%
  group_by(country, Date, variable) %>%
  dplyr::summarize(value = sum(value, na.rm = T)) %>%
  ungroup() %>%
  mutate(class = "none", recipient = "none", donor = "none")
# glimpse(ebola_byCountry)  

classes = read.csv("data/donor_classes.csv", stringsAsFactors = F) # these are somewhat arbitrary classes I came up with

ebola_donations = dons02 %>%
  mutate(class = plyr::mapvalues(donor, from = classes$donor, to = classes$class)) %>%
  rename(country = destination) %>%
  select(-appeal, -description) %>%
  melt(id.vars = c("Date", "country", "recipient", "donor", "class")) %>%
  rbind(ebola_byCountry) %>%
  filter(country %in% c("Guinea", "Sierra Leone", "Liberia")) %>%
  mutate(country = droplevels(country))
  

# setdiff(classes$donor, dons02$donor)
# setdiff(dons02$donor, classes$donor)

