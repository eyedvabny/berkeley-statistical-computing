##---- Q3_SQL ----
library(RSQLite)

# Connect to the db
air_db <- dbConnect(SQLite(),"airline_db")

# Get the count information for each origin airport
cmd1 <- "select Origin, count(1) as DepCount from filteredAirline group by Origin"
system.time(
  orig_counts <- dbGetQuery(air_db,cmd1)
)

# Write the new table into the db
dbWriteTable(air_db,name = "DeptCounts",value = orig_counts)

# Join the tables and select observations with longest delay
cmd2_1 <- "select FA.Origin,DepDelay,DepCount from"
cmd2_2 <- "filteredAirline as FA join DeptCounts as DC"
cmd2_3 <- "on FA.Origin = DC.Origin"
cmd2_4 <- "where DepCount > 1000000 and DepDelay > 700"
system.time(
  delays <- dbGetQuery(air_db,paste(cmd2_1,cmd2_2,cmd2_3))
)

# Sort the delays and drop
delays <- delays[order(-DepDelay)[1:20],]
