## ---- newMaxLikelihood ----

load('ps4prob6.Rda') # should have A, n, K

ll <- function(Theta, A) {
  sum.ind <- which(A==1, arr.ind=T)
  logLik <- sum(log(Theta[sum.ind])) - sum(Theta)
  return(logLik)
}

oneUpdate <- function(A, n, K, theta.old, thresh = 0.1) {

  Theta.old <- theta.old %*% t(theta.old)
  L.old <- ll(Theta.old, A)

  # Allocate q
  q <- as.numeric(NA)
  length(q) <- n*n*K
  dim(q) <- c(n,n,K)

  #
  # Unfortunately didn't have enough time to resolve this :-(
  #

  for (i in 1:n) {
    for (j in 1:n) {
      for (z in 1:K) {
        if (theta.old[i, z]*theta.old[j, z] == 0){
          q[i, j, z] <- 0
        } else {
          q[i, j, z] <- theta.old[i, z]*theta.old[j, z] / Theta.old[i, j]
        }
      }
    }
  }

  for (z in 1:K) {
    theta.old[,z] <- rowSums(A*q[,,z])/sqrt(sum(A*q[,,z]))
  }

  #
  #
  #

  L.new <- ll(theta.old %*% t(theta.old), A)

  converge.check <- abs(L.new - L.old) < thresh

  return(list(theta = theta.old/rowSums(theta.old), loglik = L.new, converged = converge.check))
}

# initialize the parameters at random starting values
temp <- runif(n*K)
dim(temp) <- c(n,K)
theta.init <- temp/rowSums(temp)

# do single update
out <- oneUpdate(A, n, K, theta.init)
