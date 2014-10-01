library(stringr)

## ---- GetSpeechStats ----
GetSpeechStats <- function(speech){

  # RegEx patterns to look for
  patterns <- c("\\s(I)\\s",
                "(?i)\\s(we)\\s",
                "America(n)*",
                "(?i)Democra(t|cy|tic)+",
                "(?i)Republic(an)*",
                "(?i)Free(dom)*",
                "\\s(war)",
                "(?i)\\sGod(?!\\sbless)",
                "(?i)\\sGod\\sBless",
                "(?i)(Jesus|Christ)",
                "(?i)econom"
              )

  # Sub-function for calling within sapply
  ProcSpeech <- function(pattern,speech){
    str_count(speech,perl(pattern))
  }

  # Call str_count for all patterns and on all speeches
  sapply(patterns,ProcSpeech,speech)
}

