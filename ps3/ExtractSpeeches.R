## ---- Setup ----

# Load in the necessary libraries
library(XML)
library(stringr)
library(lubridate)
library(dplyr,warn.conflicts=FALSE)
library(ggplot2)

# Load in the necessary functions
source("ExtractSpeechContent.R")
source("CleanupSpeech.R")
source("GetSpeechStats.R")

# Access the SOU index page and extract the president, year, and speech URL
sou.url <- "http://www.presidency.ucsb.edu/sou.php"
sou.index <- htmlTreeParse(sou.url, useInternalNodes = TRUE)

# The first entry is the table header, so we can toss it out
speech.links <- xpathSApply(sou.index, "//td[@class='doclist']/a",
                            xmlGetAttr, 'href')[-1]
free(sou.index)

## ---- ExtractSpeeches ----

# Obtain the speech info from individual HTML pages
speech.data <- lapply(speech.links,ExtractSpeechContent)

# Need to extract columns from the resulting list of lists
speech.data <- matrix(unlist(speech.data), ncol=4, byrow = TRUE)
speech.data <- data.frame(name = speech.data[,1],
                          title = speech.data[,2],
                          date = mdy(speech.data[,3]),
                          speech = speech.data[,4],
                          stringsAsFactors = FALSE)

## ---- TagCount ----

# Get counts of laughter and applause tags
speech.data <- speech.data %>%
               mutate(
                 num.applause = str_count(speech, perl("(?i)\\[applause\\]")),
                 num.laughter = str_count(speech, perl("(?i)\\[laughter\\]"))
               )

## ---- CleanUp ----

# Clean-up the speech content
speech.data <- speech.data %>%
               mutate(speech = CleanupSpeech(speech))

## ---- SplitUp ----

# Split into sentences and words
speech.sentences <- str_split(speech.data$speech,perl("\n"))

speech.words <-  lapply(speech.sentences,
                        function(str_list){
                          unlist(str_split(str_list,perl("(\\s|\n)")))
                        })

#Tack the word counts onto speech data
speech.data <- speech.data %>%
               mutate(
                 num.sentences = sapply(speech.sentences,length),
                 num.words = sapply(speech.words,length)
               )

## ---- GetStats ----

speech.freq.counts <- data.frame(GetSpeechStats(speech.data$speech))
speech.data <- cbind(speech.data,speech.freq.counts)

## ---- PlotStats ----
ggplot(speech.data,aes(x=date,y=num.sentences)) +
  geom_line() +
  xlab("Speech Date") +
  ylab("Number of Sentences")

ggplot(speech.data,aes(x=date,y=num.words)) +
  geom_line() +
  xlab("Speech Date") +
  ylab("Number of Words")

ggplot(speech.data,aes(x=date)) +
  geom_line(aes(y=X.s.war.,color='red')) +
  geom_line(aes(y=X..i.Free.dom..,color='blue')) +
  scale_colour_discrete(name="",labels=c("War","Freedom")) +
  xlab("Speech Date") +
  ylab("Count of Appearance")
