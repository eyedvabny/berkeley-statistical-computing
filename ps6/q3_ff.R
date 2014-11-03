## ---- Q3_ff ----
library(ff)
library(ffbase)

# Load in the saved ff dataset
system.time(
  ffload("AirlineDataAll")
)

# Remove the entries with 'bad' departure delays
system.time(
  filtered_dat <- subset(dat, DepDelay > -30 & DepDelay < 720)
)

# Calculate the number of departures for each airport
# Use batches of 1Gb for processing, so need to account
# for multiple splits fed into the function
get_dep_num <- function(orig_group){
  aggregate(TailNum ~ Origin,data=orig_group,length)
}
system.time(
  num_deps <- ffdfdply(x = filtered_dat, split = filtered_dat$Origin,
                       FUN = get_dep_num, BATCHBYTES = 1000000000)
)
names(num_deps)<- c("Origin","NumDeps")

# Merge the two ffdfs
system.time(
  merged_dat <- merge(filtered_dat,num_deps,by="Origin")
)

# Extract the longest delays
system.time(
 delays <- subset(merged_dat, NumDeps > 1000000 & DepDelay > 700)
)
delays <- delays[order(-DepDelay)[1:20],]
