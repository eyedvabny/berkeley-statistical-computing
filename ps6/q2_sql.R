## ---- Q2_SQL ----
library(RSQLite)
library(doParallel)
library(foreach)

# Connect to the DB
air_db <- dbConnect(SQLite(),"airline_db")

# Create a subset view
cmd1_1 <- "create view filteredAirline as select * from Airline"
cmd1_2 <- "where DepDelay > -30 and DepDelay < 720"
dbSendQuery(air_db,paste(cmd1_1,cmd1_2))

# Time the fetching of SFO & OAK information
cmd2_1 <- "select * from filteredAirline where"
cmd2_2 <- "Origin = 'SFO' or Origin = 'OAK'"
system.time(sfo_or_oak <- dbGetQuery(air_db,paste(cmd2_1,cmd2_2)))

# Time getting the mean & median delay by airport
cmd3_1 <- "select Origin, AVG(DepDelay) as avg_delay from filteredAirline"
cmd3_2 <- "group by Origin order by Origin"
system.time(avg_delay <- dbGetQuery(air_db,paste(cmd3_1,cmd3_2)))

# Create an index on the departure airports
system.time(dbSendQuery(air_db,"create index orig_idx on Airline(Origin)"))

# Rerun the previous queries to check for a speed-up
system.time(sfo_or_oak <- dbGetQuery(air_db,paste(cmd2_1,cmd2_2)))
system.time(avg_delay <- dbGetQuery(air_db,paste(cmd3_1,cmd3_2)))

# Compute the mean departure delay using parallel processing
# The EC2 instance has 4 cores, so we'll be running at max 4 threads
registerDoParallel(4)

# First let's get the unique departure cities (should be past post-indexing)
system.time(airports <- dbGetQuery(air_db,"select distinct Origin from filteredAirline"))

# Function to fetch the average delay for an airport
get_avg_delay <- function(airport){
  db <- dbConnect(SQLite(),"airline_db")
  q1 <- "select Origin, AVG(DepDelay) as avg_delay from filteredAirline"
  q2 <- sprintf("where Origin = '%s'",airport)
  result <- dbGetQuery(db,paste(q1,q2))
  dbDisconnect(db)
  return(result)
}

# Loop through the airports and fetch the avg delay
system.time(
  avg_delay_par <- foreach(airport = airports$Origin, .combine=rbind)
                    %dopar% get_avg_delay(airport)
)
