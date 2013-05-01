#|------------------------------------------------------------------------------------------|
#|                                                                              PlusMonte.R |
#|                                                             Copyright © 2012, Dennis Lee |
#| Assert History                                                                           |
#|  0.9.6   Added missing package 'snow' and added a function monteTradeSummary().          |
#|  0.9.5   Added initNum to class Monte and function summary(). Created testPlusMonte to   |
#|             perform unit tests on functions monteShuffleIndexNum() and                   |
#|             monteSimulateReturnsZoo(), as well as some minor fixes.                      |
#|          Note: Object$call has a bug when the parameter contains a variable instead of   |
#|             value, there is no value for that parameter, e.g. fn(initNum=wealth).        |  
#|  0.9.4   Added an internal function monteCalcuReturnsZoo() that returns the computed     |
#|            returns for a numeric vector of profit/loss amount. Added TWO (2) matrices of |
#|            maxLocalDD and relLocalDD in the Monte class object.                          |
#|  0.9.3   Debug performance of external function MonteGrowReturns(), and s3 >> s2 >> s1,  |
#|            where s3 has the longest time taken for internal function monteCalcDrawdown() |
#|            despite adding a helper function monteMakeCluster(), which is OS-dependent.   |
#|  0.9.2   Expanded class function summary() to include maximum, median and minimum equity |
#|            and drawdown, with helper function monteCalcDrawdown(). Check arguments are   |
#|            valid.                                                                        |
#|  0.9.1   Completed previous TODOs to some extent. There are ONE (1) external function    |
#|            MonteGrowReturns() and TWO (2) class functions plot() and summary()           |
#|            implemented. Also, there are FOUR (4) internal functions (with multicore      |
#|            support): monteSimulateReturnsZoo(), monteShuffleIndexNum(), monteGrow(), and |
#|            monteIsMultiBln().                                                            |
#|          TODO: (1) The class function summary() should show more details, e.g. best and  |
#|            worst equity, local finished equities, best and worst returns, number of      |
#|            consecutive wins, etc.                                                        |
#|  0.9.0   This is a draft script of the class Monte. TODO: (1) This class should be       |
#|            similar to the class Markowitz, with AT LEAST TWO (2) class functions plot()  |
#|            and summary() functions; (2) create a numeric vector of maximum drawdowns as  |
#|            a class attribute, using the object$call property.                            |
#|------------------------------------------------------------------------------------------|
require(quantmod)
require(parallel)
require(snow)
require(PerformanceAnalytics)
source("C:/Users/denbrige/100 FxOption/103 FxOptionVerBack/080 Fx Git/R-source/PlusReg.R")
source("C:/Users/denbrige/100 FxOption/103 FxOptionVerBack/080 Fx Git/R-source/PlusFile.R")

#|------------------------------------------------------------------------------------------|
#|                            E X T E R N A L   F U N C T I O N S                           |
#|------------------------------------------------------------------------------------------|
#|------------------------------------------------------------------------------------------|
#|                          E X T E R N A L   A   F U N C T I O N S                         |
#|------------------------------------------------------------------------------------------|
MonteGrowReturns <- function(rawZoo, setNum, sizeNum=1, initNum=10000, replaceBln=TRUE, 
                             summary=TRUE, debug=FALSE)
{
  #---  Assert FIVE (5) arguments:                                                   
  #       rawZoo is a zoo object of returns
  #       setNum is an integer of number of sets to grow
  #       sizeNum is an integer of block size, where blocks of returns are kept together (default: 1)
  #       initNum is a double for initial starting capital in dollars (default: 10000)
  #       replaceBln is a boolean for sampling replacement (default: TRUE)
  
  rawNum <- length(rawZoo)
  #---  Check that arguments are valid
  if( as.numeric(setNum) <= 0 ) 
    stop("setNum MUST be greater than ZERO (0)")
  if( as.numeric(sizeNum) < 1 | as.numeric(sizeNum) > rawNum ) 
    stop("sizeNum MUST be between ONE(1) AND length(rawZoo)")
  
  #---  For setNum times, generate a shuffled index
  #       Create a matrix from the set of indexes, where EACH column is a different shuffled index
  if( debug ) s1.time <- Sys.time()
  if( monteIsMultiBln() )
    idx <- mcmapply(monteGrow, m=setNum, n=rawNum, sizeNum)
  else
    idx <- mcmapply(monteGrow, m=setNum, n=rawNum, sizeNum)
  idx <- matrix(idx, ncol=setNum)
  if( debug ) e1.time <- Sys.time()
  
  #---  For setNum times, create a new vector of returns using the shuffled index
  #       If replaceBln is TRUE, then the equity curve for different sets DO NOT converge
  #       If replaceBln is FALSE, then the equity curve for different sets converge
  mat <- matrix(data=rawZoo, nrow=rawNum)
  if( debug ) s2.time <- Sys.time()
  for(i in 1:setNum){
    if( replaceBln )
    {
      #---  The shuffled index contains repeats of sizeNum length
      #       We want to increment the repeats, such that when we reference the object 
      #       we obtain the block of returns, e.g.  1 1 1 1 1 becomes 1 2 3 4 5
      #       However, check that increments are NOT out of bounds (replace with last index)
      if( monteIsMultiBln() )
        temp_idx <- mcmapply( function(a, b) { a+(b-1) }, idx[,i], 1:sizeNum )
      else
        temp_idx <- mapply( function(a, b) { a+(b-1) }, idx[,i], 1:sizeNum )      
      temp_idx[temp_idx>rawNum] <- rawNum
      temp_ret_mat <- suppressWarnings( matrix(data = rawZoo[temp_idx]) )
    }
    else
    {
      #---  The shuffled index contains repeats of sizeNum length
      #       The shuffled index is used to order the rawZoo, such that the final object
      #       has the EXACT same values as rawZoo, but in a different order.
      #       This is sampling without replacement, hence the equity curve converges for different sets
      temp_mat <- as.matrix(cbind(rawZoo, idx[, i]))
      temp_mat <- temp_mat[order(temp_mat[,2]),]
      temp_ret_mat <- matrix(data = temp_mat[,1])
    }
    mat <- cbind(mat, temp_ret_mat)
  }
  if( debug ) e2.time <- Sys.time()
  #---  Create xts object of ALL sets of returns (exclude the first column of returns which is rawZoo)
  retXts <- xts(mat[,2:(setNum+1)], order.by=index(rawZoo))
  
  #---  Create xts object of ALL sets of equity based on retXts
  mat <- matrix(retXts+1, ncol=setNum)
  mat <- rbind( rep(initNum, setNum), mat )
  mat_equity <- apply(mat, 2, cumprod )
  eqyXts <- xts(mat_equity[2:nrow(mat_equity),], order.by=index(retXts) )

  if( debug ) s3.time <- Sys.time()
  if( summary ) dd.list <- monteCalcDrawdown( eqyXts )
  if( debug ) e3.time <- Sys.time()
  
  if( debug )
  {
    print("MonteGrowReturns(debug=TRUE)")
    cat("s1:", e1.time-s1.time, "s2:", e2.time-s2.time, "s3:", e3.time-s3.time, "\n")
  }
  
  #---  Return an object of class Monte, which includes retXts
  #
  if( summary )
    ret.Monte <- list("call" = match.call(),
                      "init" = initNum,
                      "returns" = retXts,
                      "equity" = eqyXts,
                      "maxLocalDD" = dd.list$maxLocalDD,
                      "relLocalDD" = dd.list$relLocalDD,
                      "maxDD" = dd.list$maxDD,
                      "relDD" = dd.list$relDD)
  else
    ret.Monte <- list("call" = match.call(),
                      "init" = initNum,
                      "returns" = retXts,
                      "equity" = eqyXts)
  
  class(ret.Monte) <- "Monte"
  ret.Monte
}

summary.Monte <- function(object, ...)
{
  call = object$call
    setNum = call$setNum
  if( !is.null(call$summary) )
    summary = call$summary
  else
    summary = TRUE

  cat("Call:\n")
  print(call)
    
  if( !summary )
    cat("No summary\n")
  else
  {
    initNum = object$init
    rets = object$returns
    eqty = object$equity
    ddNum = object$maxDD
    rdNum = object$relDD
    
    rawNum <- NROW(eqty)
    eqtyNum <- as.numeric(eqty[rawNum,])
    eqtyDbl <- eqtyNum/initNum - 1
    
    fD <- function(x){ 
      format(sprintf('%.2f',x), big.mark=',', width=9, justify='right')
    }  
    fP <- function(x){ 
      format(sprintf('%.1f%%',x), width=6, justify='right')
    }  
    cat("Initial equity balance    :")
    cat(fD(initNum),"\n")
    cat("Absolute maximum drawdown :")
    cat(fD(min(ddNum))," (", fP(100*min(rdNum)) ,
        ") [set = ", which(ddNum==min(ddNum))[1] ,"]\n", sep="")
    cat("Absolute median drawdown  :")
    cat(fD(median(ddNum))," (", fP(100*median(rdNum)) ,")\n", sep="")
    cat("Absolute minimum drawdown :")
    cat(fD(max(ddNum))," (", fP(100*max(rdNum)) ,
        ") [set = ", which(ddNum==max(ddNum))[1] ,"]\n", sep="")
    cat("Maximum equity balance    :")
    cat(fD(max(eqtyNum))," (", fP(100*max(eqtyDbl)) ,
        ") [set = ", which(eqtyNum==max(eqtyNum))[1] ,"]\n", sep="")
    cat("Median equity balance     :")
    cat(fD(median(eqtyNum))," (", fP(100*median(eqtyDbl)) ,")\n", sep="")
    cat("Minimum equity balance    :")
    cat(fD(min(eqtyNum))," (", fP(100*min(eqtyDbl)) ,
        ") [set = ", which(eqtyNum==min(eqtyNum))[1] ,"]\n", sep="")
  }
  
  invisible(object)
}

plot.Monte <- function(object, ...)
{
  call = object$call
  rets = object$returns
  chart.CumReturns(rets[,1:NCOL(rets)], wealth.index = TRUE, colorset=(1:call$setNum),
                   ylab = "Equity", main ="Return on Equity of Monte Carlo Simulations")
}

#|------------------------------------------------------------------------------------------|
#|                            I N T E R N A L   F U N C T I O N S                           |
#|------------------------------------------------------------------------------------------|
#|------------------------------------------------------------------------------------------|
#|                          I N T E R N A L   B   F U N C T I O N S                         |
#|------------------------------------------------------------------------------------------|
monteCalcReturnsZoo <- function(rawNum, initNum=10000)
{
  #---  Check that arguments are valid
  if( length(as.numeric(rawNum)) < 2 ) 
    stop("rawNum MUST be a numeric vector with AT LEAST TWO (2) rows")
  
  #---  Add the initNum to rawNum cumulatively
  #       Use function ROC() from tseries package to calculate returns
  cumNum <- cumsum(c(initNum, rawNum))
  retNum <- ROC(cumNum)
  retNum <- retNum[2:length(retNum)]

  #---  For length(retNum) times, Sys.Date() returns a date
  #       Increment date by +(n-1) where n is the row number, 
  #         e.g. row 1: +0, row 2: +1, row 3: +2
  #       Return a zoo object
  retDte <- rep( Sys.Date(), length(retNum) )
  if( monteIsMultiBln() )
    retDte <- mcmapply( function(x, n) { format(x + (n - 1), "%Y-%m-%d") }, retDte, 1:length(retDte) )
  else
    retDte <- mapply( function(x, n) { format(x + (n - 1), "%Y-%m-%d") }, retDte, 1:length(retDte) )
  
  retZoo <- zoo(matrix(retNum, ncol=1),
                as.Date(retDte, "%Y-%m-%d"))  
}
monteTradeSummary <- function(rawNum)
{
  #---  Check that arguments are valid
  if( length(as.numeric(rawNum)) < 1 ) 
    stop("rawNum MUST be a numeric vector with AT LEAST ONE (1) row")
  
  total.all   <- length(rawNum)
  total.win   <- length(rawNum[rawNum>0])
  total.lss   <- length(rawNum[rawNum<=0])
  avg.win     <- mean(rawNum[rawNum>0])
  avg.lss     <- mean(rawNum[rawNum<=0])
  pct.win     <- total.win/total.all
  pct.lss     <- total.lss/total.all
  
  list("total.all"=total.all,
       "total.win"=total.win,
       "total.lss"=total.lss,
       "avg.win"=avg.win,
       "avg.lss"=avg.lss,
       "pct.win"=pct.win,
       "pct.lss"=pct.lss)
}
monteMakeCluster <- function()
{
  ret.cl <- NULL
  if( RegIsLinuxBln() )
    ret.cl <- makeForkCluster(nnodes=detectCores())
  if( RegIsWindowsBln() )
  {
    sockChr <- c()
    for( i in 1:detectCores() )
    {
      sockChr <- c(sockChr, "localhost")
    }
    ret.cl <- makeCluster(sockChr, type="SOCK")
  }
  ret.cl
}

#|------------------------------------------------------------------------------------------|
#|                          I N T E R N A L   A   F U N C T I O N S                         |
#|------------------------------------------------------------------------------------------|
monteCalcDrawdown <- function( eqyXts )
{
  setNum <- NCOL(eqyXts)
  rawNum <- NROW(eqyXts)
  
  lmMtx <- matrix(NA, nrow=1, ncol=setNum)
  if( monteIsMultiBln() ) cl <- monteMakeCluster()
  for( i in 1:rawNum )
  {
    if( monteIsMultiBln() )
      maxTdNum <- parApply(cl, eqyXts[1:i,], 2, max)
    else
      maxTdNum <- apply(cl, eqyXts[1:i,], 2, max)
    lmMtx <- rbind(lmMtx, as.numeric(maxTdNum))
  }
  if( monteIsMultiBln() ) stopCluster(cl)
  lmMtx <- lmMtx[2:nrow(lmMtx),]
  ddMtx <- eqyXts - lmMtx
  rdMtx <- eqyXts / lmMtx - 1
  ddNum <- apply(ddMtx, 2, min)
  rdNum <- apply(rdMtx, 2, min)
  
  list(maxDD=ddNum, relDD=rdNum, maxLocalDD=ddMtx, relLocalDD=rdMtx)
}

monteSimulateReturnsZoo <- function(tradesNum, pAvgNum, lAvgNum, wPctNum, initNum=10000)
{
  #---  Assert FIVE (5) arguments:                                                   
  #       tradesNum is an integer for number of trades
  #       pAvgNum is a double for average profit in dollars
  #       lAvgNum is a double for average loss in dollars
  #       wPctNum is a double for the winning percentage
  #       initNum is a double for initial starting capital in dollars (default: 10000)

  #---  Check that arguments are valid
  if( as.numeric(tradesNum) < 3 ) 
    stop("tradesNum MUST be greater than OR equal to THREE (3)")
  if( as.numeric(pAvgNum) <= 0 ) 
    stop("pAvgNum MUST be greater than ZERO (0)")
  if( as.numeric(lAvgNum) >= 0 ) 
    stop("lAvgNum MUST be less than ZERO (0)")
  if( as.numeric(wPctNum) <= 0 | as.numeric(wPctNum) >= 1 ) 
    stop("wPctNum MUST be between ZERO (0) AND ONE (1)")
  if( as.numeric(initNum) <= 0 ) 
    stop("initNum MUST be greater than ZERO (0)")
  stopNum <- round(abs(tradesNum*lAvgNum*(1-wPctNum)))
  if( as.numeric(initNum) <= 1*stopNum ) 
    stop(paste0("initNum MUST BE greater than ONCE (1x) cumulative losses of -",
                   stopNum, "(",1*stopNum, ")"))
  
  #---  For tradesNum times, runif() returns a random number between 0 and 1
  #       If number is less than or equal to wPctNum, then it will be counted as a win
  #       If number is above wPctNum, then it will be counted as a loss
  simBln <- runif(tradesNum, min=0, max=1) <= wPctNum
  
  if( monteIsMultiBln() )
    simNum <- mcmapply(function(x) { if(x) pAvgNum else lAvgNum }, simBln)
  else
    simNum <- mapply(function(x) { if(x) pAvgNum else lAvgNum }, simBln)
  
  cumNum <- c(initNum, initNum + cumsum(simNum))
  retNum <- ROC(cumNum)
  retNum <- retNum[!is.na(retNum)]
  
  #---  For tradesNum times, Sys.Date() returns a date
  #       Increment date by +(n-1) where n is the row number, e.g. row 1: +0, row 2: +1, row 3: +2
  #       Return a zoo object (may need to create a data.frame)
  retDte <- rep( Sys.Date(), tradesNum )
  if( monteIsMultiBln() )
    retDte <- mcmapply( function(x, n) { format(x + (n - 1), "%Y-%m-%d") }, retDte, 1:length(retDte) )
  else
    retDte <- mapply( function(x, n) { format(x + (n - 1), "%Y-%m-%d") }, retDte, 1:length(retDte) )
  
  retZoo <- zoo(matrix(retNum, ncol=1),
                as.Date(retDte, "%Y-%m-%d"))  
  retZoo
}

monteShuffleIndexNum <- function(n, r)
{
#---  Assert TWO (2) arguments:                                                   
#       n:        an integer for the length of vector
#       r:        an integer for the size of block
#       retNum:   a numeric vector of shuffled index with length n and r blocks
  #---  Check that arguments are valid
  if( as.numeric(n) < 2 ) 
    stop("n MUST be an integer greater than ONE (1)")
  if( as.numeric(r) < 1 )  
    stop("r MUST be an integer between ONE (1) AND n")
  if( as.numeric(r) > as.numeric(n) ) 
    stop("r MUST be an integer between ONE (1) AND n")

  i <- trunc(n/r)
  j <- n %% r
  if( (i*r+j) != n ) stop("logical error")
  
  #---  For i times, runif() returns a random number between 1 and n
  #       Duplicate r times, each row in idxNum
  idxNum <- round(runif(i, min=1, max=n))
  idxNum <- idxNum[ rep(1:length(idxNum), rep(r, length(idxNum))) ]
  #---  For ONE (1) time, runif() returns a random number between 1 and n
  #       Duplicate r times, this row and append to idxNum
  modNum <- round(runif(1, min=1, max=n))
  modNum <- modNum[ rep(1, j) ]
  c(idxNum, modNum)
}

monteGrow <- function(m, n, r) {
  v <- matrix( monteShuffleIndexNum(n, r), ncol=1 )
  for( i in 2:m )
  {
    v <- c(v, monteShuffleIndexNum(n, r))
  }
  v
}

monteIsMultiBln <- function()
{
  return( detectCores() > 1 )
}

#|------------------------------------------------------------------------------------------|
#|                                E N D   O F   S C R I P T                                 |
#|------------------------------------------------------------------------------------------|
