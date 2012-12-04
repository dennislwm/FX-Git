require(quantmod)
require(PerformanceAnalytics)

monteSimulateReturnsZoo <- function(n, p, l, w, c=10000)
{
  #n is the number of returns
  #p is the average profit
  #l is the average loss
  #w is the winning percentage
  #c is the starting capital (default: 10000)
  
  #runif() will return a number between 0 and 1
  # if number is less than or equal to w, then it will be counted as a win
  # if number is above w, then it will be counted as a loss
  simBln <- runif(n, min=0, max=1) <= w
  
  simNum <- sapply(simBln, function(x) { if(x) p else l })
  
  cumNum <- c(c, c + cumsum(simNum))
  retNum <- ROC(cumNum)
  retNum <- retNum[!is.na(retNum)]
  
  retDte <- c()
  for( i in 1:n ) { retDte <- c( retDte, format(Sys.Date()+i, "%Y-%m-%d") ) }
  retDfr <- data.frame( returns=retNum, date=retDte )
  retDfr[, 2] <- as.Date(retDfr[, 2], "%Y-%m-%d")
  
  retZoo <- zoo(matrix(retDfr[,1], ncol=1),
                retDfr[, 2])  
}

#Function that grabs a random number and then repeats that number r times
monteRandom.index <- function(x, r){
  #x is an xts object of asset returns
  #r is for how many consecutive returns make up a 'block'
  vec <- c()
  total_length <- length(x)
  n <- total_length/r
  for(i in 1:n){
    vec <- append(vec,c(rep(sample(1:(n*100),1), r)))
  }
  diff <- as.integer(total_length - length(vec))
  vec <- append(vec, c(rep(sample(1:(n*100),1), len = diff)))
  return(vec)
}

monteShuffleReturnsXts <- function(x, n, r){
  #x is an xts object of asset returns
  #n is the number of samples to run
  #r is for how many consecutive returns make up a 'block' and is passed to ran_gen
  
  mat <- matrix(data = x, nrow = length(x))
  for(i in 1:n){
    temp_random <- monteRandom.index(x = x, r = r)
    temp_mat <- as.matrix(cbind(x, temp_random))
    temp_mat <- temp_mat[order(temp_mat[,2]),]
    temp_ret_mat <- matrix(data = temp_mat[,1])
    mat <- cbind(mat, temp_ret_mat)
  }
  final_xts <- xts(mat, order.by=index(x))
  return(final_xts)
}

plot.Monte <- function(object, ...)
  # plot.assets  	logical. If true then plot asset sd and er
{
    call = object$call  
    a <- monteSimulateReturnsZoo(3000, 27.78, -67.81, 0.75)
    yy <- monteShuffleReturnsXts(a, 100, 5)
    chart.CumReturns(yy[,1:NCOL(yy)], wealth.index = TRUE, 
                     ylab = "Equity", 
                     main ="Return on Equity of Monte Carlo Simulations")
}
