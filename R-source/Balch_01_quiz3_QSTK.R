#|------------------------------------------------------------------------------------------|
#|                                                                    Balch_01_quiz3_QSTK.R |
#|                                                             Copyright © 2012, Dennis Lee |
#| Background                                                                               |
#|    The data for this R script comes from QTSK. We use the adjusted close prices. As the  |
#|  R script may NOT be able to access the data, we should use Python to download the data  |
#|  and export it to a CSV file.                                                            |
#|                                                                                          |
#| Motivation                                                                               |
#|  (1) Coursera's "Computational Investing" (CI) course taught students to use a Python    |
#|      framework for ALL their homeworks. However, it appears that these homeworks could   |
#|      be performed using R, which is NOT supported by the lecturer Tucker Balch.          |
#|  (2) The package "PlusBullet" can be used to perform portfolio analysis, and ANY ideas   |
#|      taken from the course can be used to extend the functionality of this package.      |
#|                                                                                          |
#| Homework                                                                                 |
#|    A. Write a function simulate() that can assess the performance of a FOUR(4)-stock     |
#|  portfolio. Inputs to the function include: (i) start date; (ii) end date; (iii) symbols |
#|  e.g. (GOOG, AAPL, GLD, XOM); and (iv) allocations to the securities at the beginning of |
#|  the simulation, e.g. (0.2, 0.3, 0.4, 0.1). The function should return a list of FOUR (4)|
#|  objects: (i) standard deviation of daily returns of the total portfolio; (ii) average   |
#|  daily return of the total portfolio; (iii) Sharpe ratio - ALWAYS assume that you have   |
#|  TWO HUNDRED AND FIFTY TWO (252) trading days in a year and risk free rate is ZERO (2) - |
#|  of the total portfolio; and (iv) cumulative return of the total portfolio.              |
#|    Here is a suggested outline for your simulation() code:                               |
#|    (1) Read in adjusted closing prices for the FOUR (4) securities.                      |
#|    (2) Normalize the prices according to the FIRST day. The FIRST row for EACH stock     |
#|        should have a value of ONE (1.0) at this point.                                   |
#|    (3) Multiply EACH column by the allocation to the corresponding security.             |
#|    (4) Sum EACH row for EACH day. That is your cumulative daily portfolio value.         |
#|    (5) Compute statistics from the total portfolio value.                                |
#|    Here are some notes and assumptions:                                                  |
#|    (a) Allocate some amount of value to EACH equity on the FIRST day. You then "hold"    |
#|        those investments for the ENTIRE period. Assume 252 trading days/year.            | 
#|    (b) Use adjusted close data provided with QSTK. If you use other data your results    |
#|        may turn out different from ours. Yahoo's online data changes every day. We could |
#|        NOT build a consistent "correct" answer based on "live" Yahoo data.               |
#|    (c) Report statistics for the ENTIRE portfolio. When we compute statistics on the     |
#|        portfolio value, we INCLUDE the FIRST day. We assume you are using the data       |
#|        provided with QSTK.                                                               | 
#|                                                                                          |
#|    B. Make sure your simulate() function gives correct output. Check it against the      |
#|  examples below:                                                                         |
#|    (a) Start Date: January 1, 2011                                                       |
#|        End Date: December 31, 2011                                                       |
#|        Symbols: ['AAPL', 'GLD', 'GOOG', 'XOM']                                           |
#|        Optimal Allocations: [0.4, 0.4, 0.0, 0.2]                                         |
#|        Sharpe Ratio: 1.02828403099                                                       |
#|        Volatility (stdev of daily returns):  0.0101467067654                             |
#|        Average Daily Return:  0.000657261102001                                          |
#|        Cumulative Return:  1.16487261965                                                 |
#|    (b) Start Date: January 1, 2010                                                       |
#|        End Date: December 31, 2010                                                       |
#|        Symbols: ['AXP', 'HPQ', 'IBM', 'HNZ']                                             |
#|        Optimal Allocations:  [0.0, 0.0, 0.0, 1.0]                                        |
#|        Sharpe Ratio: 1.29889334008                                                       |
#|        Volatility (stdev of daily returns): 0.00924299255937                             |
#|        Average Daily Return: 0.000756285585593                                           |
#|        Cumulative Return: 1.1960583568                                                   |
#|                                                                                          |
#|    C. Use your function to create a portfolio optimizer. Create a "for" loop (or nested  |
#|  "for" loop) that enables you to test EVERY "legal" set of allocations to the FOUR (4)   |
#|  securities. Keep track of the "best" portfolio, and print it out at the end.            |
#|    "Legal" set of allocation means: (a) the allocations sum to ONE (1); and (b) the      |
#|  allocations are in TEN (10%) percent increments. Example legal allocations are          |
#|  (1.0, 0.0, 0.0, 0.0) and (0.1, 0.1, 0.1, 0.7).                                          |
#|    "Best" portfolio means: highest Sharpe ratio.                                         |
#|                                                                                          |
#|    D. Create a chart that illustrates the value of your portfolio over the period AND    |
#|  compare it to SPY.                                                                      |
#|                                                                                          |
#| History                                                                                  |
#|  1.0.0   Coursera's "Computational Investing" course (Tucker Balch) Quiz 3 Week 3.       |
#|------------------------------------------------------------------------------------------|
source("C:/Users/denbrige/100 FxOption/103 FxOptionVerBack/080 Fx Git/R-source/PlusReg.R", echo=FALSE)
source("C:/Users/denbrige/100 FxOption/103 FxOptionVerBack/080 Fx Git/R-source/PlusFile.R", echo=FALSE)

#---  Prerequisite. We have to perform these TWO (2) steps prior to running this script.
#     (1) Download the data using the python script "Balch_01_tutorial01_QSTK.py" and save
#         it as a CSV file "Balch_01_tutorial01". Note: The python script saves the adjusted
#         closing price ONLY.
#     (2) Copy the CSV file into the folder "R-nonsource".

#---  Part A. We will to write the function simulate() in R using a different signature - 
#       than the python script - that can assess the performance of a FOUR(4)-stock
#       portfolio. Inputs to the function include: (a) file name; (b) allocations to the 
#       securities at the beginning of the simulation, e.g. (0.2, 0.3, 0.4, 0.1); and (c)
#       risk free rate.
#     (1) Read in adjusted closing prices for the FOUR (4) securities.                      
#     (2) Normalize the prices according to the FIRST day. The FIRST row for EACH stock     
#       should have a value of ONE (1.0) at this point.                                   
#     (3) Multiply EACH column by the allocation to the corresponding security.             
#     (4) Sum EACH row for EACH day. That is your cumulative daily portfolio value.         
#     (5) Compute statistics from the total portfolio value. The function should return a 
#       list of FOUR (4) objects: (i) standard deviation of daily returns of the total 
#       portfolio; (ii) average daily return of the total portfolio; (iii) Sharpe ratio - 
#       ALWAYS assume that you have TWO HUNDRED AND FIFTY TWO (252) trading days in a year 
#       and risk free rate is ZERO (0) - of the total portfolio; and (iv) cumulative return 
#       of the total portfolio.

simulateLst <- function(fileStr, allocNum, rfNum = 0)
{
  #---  Assert THREE (3) arguments:                                                   
  #       fileStr:    name of the file (without the extension ".csv")
  #       allocNum:   a numeric vector of allocations to the securities                                             
  #       rfNum:      a numeric for risk free rate (default: 0)
  
  #---  Check that arguments are valid
  if( missing(fileStr) )
    stop("fileStr CANNOT be EMPTY")
  else if( fileStr=="" )
    stop("fileStr CANNOT be EMPTY")
  
  #     (1) Read in adjusted closing prices for the FOUR (4) securities.                      
  qstkDfr <- fileReadDfr(fileStr)
  
  #---  Check that arguments are valid
  if( is.na(sum(allocNum)) )
    stop("allocNum MUST sum to ONE (1)")
  else if( sum(allocNum) != 1 )
    stop("allocNum MUST sum to ONE (1)")
  if( length(allocNum) != ncol(qstkDfr)-1 )
    stop("length(allocNum) MUST equal the number of securities in fileStr")
  
  #--- Coerce character into numeric or date
  qstkDfr[, 1]  <- as.Date(qstkDfr[, 1], "%Y-%m-%d %H:%M:%S")
  qstkDfr[, 2]  <- suppressWarnings( as.numeric( qstkDfr[, 2] ) )
  qstkDfr[, 3]  <- suppressWarnings( as.numeric( qstkDfr[, 3] ) )
  qstkDfr[, 4]  <- suppressWarnings( as.numeric( qstkDfr[, 4] ) )
  qstkDfr[, 5]  <- suppressWarnings( as.numeric( qstkDfr[, 5] ) )
  
  #     (2) Normalize the prices according to the FIRST day. The FIRST row for EACH stock     
  #       should have a value of ONE (1.0) at this point.                                   
  qstkDfr[, 2]  <- qstkDfr[ ,2] / qstkDfr[1, 2]
  qstkDfr[, 3]  <- qstkDfr[ ,3] / qstkDfr[1, 3]
  qstkDfr[, 4]  <- qstkDfr[ ,4] / qstkDfr[1, 4]
  qstkDfr[, 5]  <- qstkDfr[ ,5] / qstkDfr[1, 5]
  
  #     (3) Multiply EACH column by the allocation to the corresponding security.             
  qstkDfr[, 2]  <- allocNum[1] * qstkDfr[, 2]
  qstkDfr[, 3]  <- allocNum[2] * qstkDfr[, 3]
  qstkDfr[, 4]  <- allocNum[3] * qstkDfr[, 4]
  qstkDfr[, 5]  <- allocNum[4] * qstkDfr[, 5]
  
  #     (4) Sum EACH row for EACH day. That is your cumulative daily portfolio value.         
  qstkDfr$Portfolio <- qstkDfr[, 2] + qstkDfr[, 3] + qstkDfr[, 4] + qstkDfr[, 5]
  qstkDfr$Daily <- 0.0
  for( r in 2:nrow(qstkDfr) )
  {
    qstkDfr[r, 7] <- (qstkDfr[r, 6] / qstkDfr[r-1, 6]) - 1
  }
  
  #     (5) Compute statistics from the total portfolio value. The function should return a 
  #       list of FOUR (4) objects: (i) standard deviation of daily returns of the total 
  #       portfolio; (ii) average daily return of the total portfolio; (iii) Sharpe ratio - 
  #       ALWAYS assume that you have TWO HUNDRED AND FIFTY TWO (252) trading days in a year 
  #       and risk free rate is ZERO (0) - of the total portfolio; and (iv) cumulative return 
  #       of the total portfolio.
  sdNum     <- sd(qstkDfr$Daily)
  meanNum   <- mean(qstkDfr$Daily)
  sharpeNum <- sqrt(252)*(meanNum-rfNum)/sdNum 
  retLst    <- list("qstk"    = qstkDfr,
                    "alloc"   = allocNum,
                    "sd"      = sdNum,
                    "meanRet" = meanNum,
                    "sharpe"  = sharpeNum,
                    "cumRet"  = qstkDfr$Portfolio[nrow(qstkDfr)]
                    )
  retLst
}

#|    C. Use your function to create a portfolio optimizer. Create a "for" loop (or nested  |
#|  "for" loop) that enables you to test EVERY "legal" set of allocations to the FOUR (4)   |
#|  securities. Keep track of the "best" portfolio, and print it out at the end.            |
#|    "Legal" set of allocation means: (a) the allocations sum to ONE (1); and (b) the      |
#|  allocations are in TEN (10%) percent increments. Example legal allocations are          |
#|  (1.0, 0.0, 0.0, 0.0) and (0.1, 0.1, 0.1, 0.7).                                          |
#|    "Best" portfolio means: highest Sharpe ratio.                                         |
optimizerLst <- function(fileStr, rfNum = 0)
{
  sharpe.best <- 0
  alloc.best  <- 0
  for( a in round(seq(0.0, 1.0, by=0.1), digits=1) )
  {
#    a <- round(a, digits=1)
    for( b in round(seq(0.0, 1-a, by=0.1), digits=1) )
    {
#      b <- round(b, digits=1)
      for( c in round(seq(0.0, 1-(a+b), by=0.1), digits=1) )
      {
#        c <- round(c, digits=1)
        d <- 1-(a+b+c)
        d <- round(d, digits=1)
        print(paste(a,b,c,d,sep=","))
        if( sum(a,b,c,d) - 1 > 0.005 )
          stop("sum(a,b,c,d) is NOT equal to ONE (1)")
        simLst <- simulateLst(fileStr, c(a,b,c,d), rfNum)
        if( simLst$sharpe > sharpe.best )
        {
          sharpe.best <- simLst$sharpe
          alloc.best  <- simLst$alloc
        }
      }
    }
  }
  retLst    <- list("alloc"   = alloc.best,
                    "sharpe"  = sharpe.best
  )
  retLst
}