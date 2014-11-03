## ---- Q2_ff ----
library(ff)
library(ffbase)

# Load in the saved ff dataset
system.time(
  ffload("AirlineDataAll")
)

# Remove the entries with 'bad' departure delays
system.time(
  filtered_dat <- subset(dat,DepDelay > -30 & DepDelay < 720)
)

# Get the entries from SFO and OAK
system.time(
  sfo_or_oak <- subset(filtered_dat, Origin == "SFO" | Origin == "OAK")
)

# Calculate the average delay for each airport
# Use batches of 1Gb for processing, so need to account
# for multiple splits fed into the function
get_dep_mean <- function(orig_group){
  aggregate(DepDelay ~ Origin,data=orig_group,mean)
}

system.time(
  avg_delay <- ffdfdply(x = filtered_dat, split = filtered_dat$Origin,
                        FUN = get_dep_mean, BATCHBYTES = 1000000000)
)
