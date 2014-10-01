library(stringr)
library(magrittr)

## ---- CleanupSpeech ----

# Strip out the extraneous content and pretty-print the speech
CleanupSpeech <- function(speech){

  # 1st replace - remove all [] tags
  # 2nd replace - remove all periods after a single letter
  # 3rd replace - remove the periods after Mr. Mrs. or Ms.
  # 4th replace - insert new-line character after every sentence
  speech %>%
  str_replace_all(perl("\\[.*?\\]"),"") %>%
  str_replace_all(perl("(?<=\\s\\w)\\."),"") %>%
  str_replace_all(perl("(Mr|Ms|Mrs)\\."),"\\1") %>%
  str_replace_all(perl("(?<=\\.)\\s"),"\n")
}
