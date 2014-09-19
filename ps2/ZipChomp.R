#!/usr/bin/env RScript

# An RScript to subset and filter a bz-ipped CSV
# Inputs: CSV name, column index for strat, column index for filter, filter key
# Outputs: bz-ipped files for each element of the subsetting column
# 
# CC Eugene Yedvabny, 2014

# Capture the provided arguments
args <- commandArgs(TRUE)

# Sanity check that we have enough arguments
if(length(args) < 4){
    stop("Please provide the bz2 file name, stratifying column, subsetting column and desired subsetting key")
}

# Assign the variables
input.name <- args[1]
strat.col <- as.numeric(args[2])
sort.col <- as.numeric(args[3])
sort.value <- args[4]

# Checking that file exists
# Unfortunately no checks for correct bz type
if (!file.exists(input.name)){
    stop("Specified file doesn't exist")
}

# Open the input file for reading
input.handle <- bzfile(args[1], "r")

# Count the number of fields
input.header <- readLines(input.handle, n=1)
input.cols <- strsplit(input.header,",")[[1]]
if(strat.col < 0 || strat.col > length(input.cols) || sort.col < 0 || sort.col > length(input.cols)){
    close(input.handle)
    stop("Please use column indices within bounds of the input file")
}

# Create a list of output file handles
# it will be keyed by unique values of strat.col
output.files <- list()

# Read the rest of the file line by line appending to right section
input.length <- 0
while(length(input.line <- readLines(input.handle,1))) {

    input.fields <- strsplit(input.line,",")[[1]]

    # Only stratify rows which match the sorting value
    if(input.fields[sort.col] == sort.value){

        # Open the output file if one is not open yet
        # Otherwise create a new file handle
        output.key <- input.fields[strat.col]
        output.file <- output.files[[output.key]]
        if(is.null(output.file)) {
            output.file.name <- paste(output.key,".csv.bz2",sep="")
            output.file <- bzfile(output.file.name,'w')
            output.files[[output.key]] <- output.file
        }

        # Write the filtered line into the now-open file
        write(input.line,output.file)
    }

    input.length <- input.length + 1
}

# Indicate that we're done processing
write(sprintf("Done: processed %d lines (excluding the header)",input.length),stdout())

# Close all the files
closeAllConnections()
