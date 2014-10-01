library(XML)
library(stringr)
library(magrittr)

## ---- ExtractSpeechContent ----

# Loads in the page from the specified URL
# Extracts the president's name, speech year, and text
# Additionally counts the number of applause and laughter tags
ExtractSpeechContent <- function(speech.url){
  speech.page <- htmlTreeParse(speech.url, useInternalNodes = TRUE)

  # The meta title contains president's name, speech title, and date
  metastring <- speech.page %>% xpathSApply("//meta[@name='title']",
                                            xmlGetAttr, 'content')

  # Using look-ahead and look-behind to extract components
  speech.name <- metastring %>% str_extract(perl("^.*(?=:)"))
  speech.title <- metastring %>% str_extract(perl("(?<=:\\s).*(?=\\s-)"))
  speech.year <- metastring %>% str_extract(perl("(?<=-\\s).*$"))

  # Get the raw text of the speech
  speech.body <- speech.page %>% xpathSApply("//span[@class='displaytext']",
                                             xmlValue)

  # Return the raw data
  c(speech.name,speech.title,speech.year,speech.body)
}
