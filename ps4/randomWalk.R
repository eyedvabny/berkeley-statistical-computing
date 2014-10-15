## ---- randomWalk ----

# Compute a 2D random walk
# Input: number of steps, whether to return the full path
# Output: an (x,y) vector or list of such vector if full path

rw <- function(num.steps = 0, full.path = F){

  # Sanity check on the input
  if(!is.numeric(num.steps) | num.steps <= 0 ){
    stop("Invalid number of steps")
  }

  # Since this is a random walk, just generate the moves
  moves <- list(c(1,0),c(-1,0),c(0,1),c(0,-1))
  steps <- sample(moves,num.steps,replace=T)
  steps.matrix <- matrix(unlist(steps),ncol=2,byrow=T)

  # Sum up the moves and add them
  steps.matrix[,1] <- cumsum(steps.matrix[,1])
  steps.matrix[,2] <- cumsum(steps.matrix[,2])
  colnames(steps.matrix) <- c("x","y")

  walk <- list(origin = c(0,0), full.path = full.path)
  class(walk)<-"rw"
  walk$path <- steps.matrix

  return(walk)
}

# Print a well-formatted representation
print.rw <- function(walk, ...){
  if(walk$full.path){
    print(walk$path)
  }else{
    print(walk$path[length(walk$path)/2,])
  }
}

# Plot the walk on a 2D chart
plot.rw <- function(walk, ...){
  data <- data_frame(x=walk$path[,1],y=walk$path[,2])
  ggplot(data,aes(x=x,y=y))+
    geom_path()
}

# Return the ith step of the random walk
`[.rw` <- function(walk,i,...){
  if(!is.numeric(i) || i <= 0){
    return(walk$origin)
  }else{
    return(walk$path[i,])
  }
}

# Return the starting coordinate
start <- function(object, ...) UseMethod("start")
start.rw <- function(object){
  return(object$origin)
}

# Set the starting coordinate
`start<-` <- function(object, ...) UseMethod("start<-")
`start<-.rw` <- function(object,value){
  object$origin <- value
  return(object)
}
