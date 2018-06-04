# Exercise 3: mapping with ggplot2

# Install and load `ggplot2` and `dplyr`
library("ggplot2")
library("dplyr")

# Also install and load the `maps` package, which contains geometry for a number
# of pre-defined maps.
install.packages("maps")
library("maps")

# Use `map_data()` to load the `county` map of the US, storing it in a variable
# `counties_map`
counties_map <- map_data("county")

# Inspect this data frame to understand what data yu're working with
View(head(counties_map, 10))

# Consider: what column contains state names? What column contains county names?
# What format are those county names in?

# Draw a plot of the `counties.map` data set using polygon geometry.
# Map the the `x` aesthetic to longitude, `y` to latitude, and `group` to "group"
# You can add the `coord_quick_map()` coordinate system to make it look nice
ggplot(data = counties_map) +
  geom_polygon(aes(x = long, y = lat, group = group)) +
  coord_quickmap()


### Data Wrangling

# Read in the provided election data file (.csv)
## BE SURE TO SET YOUR WORKING DIRECTORY!
election <- read.csv("data/2016_US_County_Level_Presidential_Results.csv", stringsAsFactors = FALSE)

# Inspect the `election` data frame to understand the data you're working with
colnames(election)
View(election)

## Consider: what column contains state names? What column contains county names?
## What format are those county names in?

## The format for the states and and counties are different, so you need some way
## to match the election data to the map data in order to produce the map.
## The `election` data does have FIPS codes (https://en.wikipedia.org/wiki/FIPS_county_code)
## which you can use for this. And a data frame that links FIPS to the state and
## county names is available from the `maps` library!

# Use `data()` to load the `"county.fips"` data frame from the `maps` library
data("county.fips")

# Inspect the `county.fips` data frame to see what you got
View(county.fips)

# Use a `join` operation to add `fips` column from `county.fips` to your
# `counties_map` data frame.
# Note that you may need to use `paste0()` and `mutate() to make a column of
# "state,county" values to join by!
# Also note: don't worry about Alaska for this exercise.
counties_map <- counties_map %>%
  mutate(polyname = paste0(region, ",", subregion)) %>%
  left_join(county.fips, by = "polyname")

# Now you can join the `counties_map` data (with fips!) to the `election` data
# Hint: use `by = c("fips" = "combined_fips")` to specify the column to join by
county_elections <- left_join(counties_map, election, by = c("fips" = "combined_fips"))

# One more change: add a column to store whether the Democrat or the Republication
# party had the higher number of votes ("won" the county)
# Hint: start by adding a column of logical values (TRUE/FALSE) of whether a party
#       won, and then join that with a simple data frame that matches to Strings
county_elections <- mutate(county_elections, winner = votes_dem > votes_gop)
dem_won <- data.frame(winner = c(T, F), party = c("Democrat", "Republican"))
county_elections <- left_join(county_elections, dem_won, by = "winner")


### Data Visualization

# Finally, you can create the election results map!
# Draw a map of the full elections data set, using polygon geometry as above.
# Be sure and `fill` each geometry based on which party won the county
# Specify a `manual` fill scale to make Democratic counties "blue" and Republican
# counties "red"
ggplot(data = county_elections) +
  geom_polygon(aes(x = long, y = lat, group = group, fill = party)) +
  scale_fill_manual(values = c("blue", "red")) +
  coord_quickmap()

# For fun: how else can you fill in this map? What other insights can you produce?
