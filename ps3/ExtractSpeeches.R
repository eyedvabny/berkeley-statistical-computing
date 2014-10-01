# Load in the necessary libraries
library(stringr)
library(lubridate)
library(XML)
library(dplyr)

# Load in the necessary functions
source("ExtractSpeechContent.R")
source("CleanupSpeech.R")

# Access the SOU index page and extract the president, year, and speech URL
sou.url <- "http://www.presidency.ucsb.edu/sou.php"
sou.index <- htmlTreeParse(sou.url, useInternalNodes = TRUE)

# The first entry is the table header, so we can toss it out
speech.links <- xpathSApply(sou.index, "//td[@class='doclist']/a",
                            xmlGetAttr, 'href')[-1]
free(sou.index)

# Obtain the speech info from individual HTML pages
speech.data <- lapply(speech.links,ExtractSpeechContent)

# Need to extract columns from the resulting list of lists
speech.data <- matrix(unlist(speech.data), ncol=4, byrow = TRUE)
speech.data <- data.frame(name = speech.data[,1],
                          title = speech.data[,2],
                          date = speech.data[,3],
                          speech = speech.data[,4],
                          stringsAsFactors = FALSE)

# Get counts of laughter and applause tags
speech.data <- speech.data %>%
               mutate(
                 num.applause = str_count(speech, perl("(?i)\\[applause\\]")),
                 num.laughter = str_count(speech, perl("(?i)\\[laughter\\]"))
               )

# Clean-up the speech content
speech.data <- speech.data %>%
               mutate(speech = CleanupSpeech(speech))

# Split into sentences and words and count
speech.sentences <- str_split(speech.data$speech,perl("\n"))
speech.words <-  str_split(speech.data$speech,perl("\\s"))
