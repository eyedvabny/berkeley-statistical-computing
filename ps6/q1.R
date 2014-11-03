## ---- Q1 ----
library(RSQLite)

# Start timing
system.time({

  # Create a new database for the airline data
  air_db <- dbConnect(SQLite(),"airline_db")

  # There are 29 columns in the data set
  air_classes <- c(rep("numeric",8),"character","numeric","character",
                   rep("numeric",5),rep("character",2),rep("numeric",4),
                   "character",rep("numeric",6))

  # Read in each year and write it to the db
  years <- 1987:2008
  for (year in years){
    fname <- sprintf("%d.csv.bz2",year)

    cat(paste("Reading in ",fname,"\n"))

    temp_df <- read.csv(bzfile(fname), colClasses=air_classes, stringsAsFactors=F)

    # Set the NA delay to 1000 to ease filtering
    temp_df$DepDelay[is.na(temp_df$DepDelay)] <- 1000

    cat(paste("Writing out ",fname,"\n"))

    # Add the data frame to the table
    dbWriteTable(conn=air_db, name="Airline", value=temp_df, row.names=F, append=T)
  }

  # Close the db connection
  dbDisconnect(air_db)

})
