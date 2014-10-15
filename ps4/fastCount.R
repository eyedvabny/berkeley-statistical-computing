library(inline)
# this code is simply a placeholder to demonstrate that I can
# modify the input arguments as desired in C;
# in reality 'src' would contain substantive computations
src <- '
tablex[0] = 7;
'

dummyFun <- cfunction(signature(tablex = "integer", tabley = "integer",
                                xvar = "integer", yvar = "integer", useline = "integer",
                                n = "integer"), src, convention = ".C")

fastcount <- function(xvar,yvar) {
  nalineX <- is.na(xvar)
  nalineY <- is.na(yvar)
  xvar[nalineX | nalineY] <- 0
  yvar[nalineX | nalineY] <- 0
  useline <- !(nalineX | nalineY);
  tablex <- numeric(max(xvar)+1)
  tabley <- numeric(max(yvar)+1)
  stopifnot(length(xvar) == length(yvar))
  res <- dummyFun(
    tablex = as.integer(tablex), tabley = as.integer(tabley),
    as.integer(xvar), as.integer(yvar), as.integer(useline),
    as.integer(length(xvar)))
  xuse <- which(res$tablex > 0)
  xnames <- xuse - 1
  resb <- rbind(res$tablex[xuse], res$tabley[xuse])
  colnames(resb) <- xnames
  return(resb)
}
