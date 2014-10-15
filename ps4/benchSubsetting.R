##---- benchSubsetting ----
library(dplyr)
library(microbenchmark)

# The following function will benchmark list subsetting for numeric and string lists
# The input parameter is the length of the vector to be subset
benchSubsetting <- function(length){
  # Create a random vector of numbers
  test.nums <- runif(length)

  # Create a random vector of strings (of 10 characters)
  test.strs <- replicate(length,
                         paste(sample(letters, 10, replace = T),
                               collapse=''))

  # Create an accessing boolean vector (skewed probs favor smaller subsets)
  test.bool <- sample(c(T,F), length, replace=T, prob=c(0.3,0.7))

  # Create an interger index corresponding to the same items as above
  test.index <- which(test.bool)

  # Run the test
  test.timing <- microbenchmark(
    nums.ints = test.nums[test.index],
    nums.bools = test.nums[test.bool],
    strs.ints = test.strs[test.index],
    strs.bools = test.strs[test.bool]
  )

  # Summarize on the mean timing?
  test.timing %>%
    group_by(expr) %>%
    summarize(median.time = median(time)) %>%
    mutate(length = length)
}
