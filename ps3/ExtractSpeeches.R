library(XML)
index.url <- "http://www.presidency.ucsb.edu/sou.php"
index.html <- htmlTreeParse(speech.list.url)
test <- getNodeSet(index.html,'//a')
