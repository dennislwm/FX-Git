#|------------------------------------------------------------------------------------------|
#|                                                                 Balch_04_backtest_QSTK.R |
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
#|    In this Homework THREE (3) you will create a basic market simulator that accepts      |
#|  trading orders and keeps track of a portfolio's value and saves it to a file. You will  |
#|  also create another program that assesses the performance of that portfolio.            |
#|                                                                                          |
#|    A.  Create a market simulation tool, marketsim.py that takes a command line like this |
#|                                                                                          |
#|        > python marketsim.py 1000000 orders.csv values.csv                               |
#|                                                                                          |
#|      where the number represents starting cash, and "orders.csv" is a file of orders     |
#|      organized like this: (i) Year; (ii) Month; (iii) Day; (iv) Symbol; (v) BUY OR SELL; |
#|      (vi) Number of Shares. For example:                                                 |
#|                                                                                          |
#|        2008, 12, 3, AAPL, BUY, 130                                                       |
#|        2008, 12, 8, AAPL, SELL, 130                                                      |
#|        2008, 12, 5, IBM, BUY, 50                                                         |
#|                                                                                          |
#|      Your simulator should calculate the total value of the portfolio for EACH day using |
#|      adjusted closing prices (cash plus value of equities) and print the result to the   |
#|      file "values.csv". The contents of the values.csv file should look something like   |
#|      this:                                                                               |
#|                                                                                          |
#|        2008, 12, 3, 1000000                                                              |
#|        2008, 12, 4, 1000010                                                              |
#|        2008, 12, 5, 1000250                                                              |
#|                                                                                          |
#|    B.  Create a portfolio analysis tool, analyze.py, that takes a command line like this | 
#|                                                                                          |
#|        > python analyze.py values.csv $SPX                                               |
#|                                                                                          |
#|      The tool should read in the daily values (cumulative portfolio value) from          |
#|      "values.csv" and plot them. It should use the symbol on the command line as a       |
#|      benchmark for comparison (in this case $SPX). Using this information, analyze.py    |
#|      should:                                                                             |
#|      (a) Plot the price history over the trading period.                                 |
#|      (b) Your program should also output: (i) Standard deviation of daily returns of the |
#|          total portfolio; (ii) Average daily return of the total portfolio; (iii) Sharpe |
#|          ratio (Always assume you have TWO HUNDRED AND FIFTY TWO (252) trading days in   |
#|          a year, and risk free rate = 0) of the total portfolio; and (iv) Cumulative     |
#|          return of the total portfolio.                                                  |
#|                                                                                          |
#| Example                                                                                  |
#|    A.  > valueXts  <- PyMarketSimXts(1000000, "Balch_04_backtest_orders")                |
#|        > fundLst   <- PyAnalyzerLst(valueXts, "SPX")                                     |
#|                                                                                          |
#|    B.  > valu2Xts  <- PyMarketSimXts(1000000, "Balch_04_backtest_order2")                |
#|        > fun2Lst   <- PyAnalyzerLst(valu2Xts, "SPX")                                     |
#|                                                                                          |
#| History                                                                                  |
#|  0.9.4   Fixed THREE (3) bugs: (i) Used function fill.na() to ensure NO NAs in prices    |
#|          for functions PyAnalyzerLst() and PyMarketSimXts(); (ii) Converted factor into  |
#|          character for function PyBillOrderXts(); and (iii) Changed order for names()    |
#|          function to be applied in function PyOrderReadDfr(). Added function fill.na().  |
#|  0.9.3   Completed Part B, that is created a function PyAnalyzerLst(). Changed name of   |
#|          function PyFileReadDfr() to PyOrderReadDfr().                                   | 
#|  0.9.2   Added the function PyCalcValueXts() that has THREE (3) parameters: (i) symChr - |
#|          a character vector of symbols; (ii) orderDfr - a data frame for "trades"; (iii) |
#|          priceXts - a data frame (xts) for prices of symbols. It returns a "values" data |
#|          frame (xts). Added an internal function PyDfrToXts() that converts a data frame |
#|          with a date column (as the FIRST column) to an xts object. Modified output from |
#|          a data frame to an xts object for functions PyBillOrderXts(), PyMarketSimXts(). |
#|          Modified input from a data frame to an xts object for function PyFileWriteCsv().|
#|  0.9.1   Added the function PyBillOrderDfr() that has THREE (3) parameters: (i) initNum  |
#|          - initial cash; (ii) orderDfr - a data frame for "trades"; (iii) priceXts - a   |
#|          data frame (xts) for (adjusted close) prices of symbols. It returns a "cash"    |
#|          data frame.                                                                     |
#|  0.9.0   Coursera's "Computational Investing" course (Tucker Balch) Quiz 5 Week 5.       |
#|          Todo: Part A is partially complete and we have not started on Part B.           |
#|------------------------------------------------------------------------------------------|
source("C:/Users/denbrige/100 FxOption/103 FxOptionVerBack/080 Fx Git/R-source/PlusReg.R", echo=FALSE)
source("C:/Users/denbrige/100 FxOption/103 FxOptionVerBack/080 Fx Git/R-source/PlusFile.R", echo=FALSE)
library(quantmod)
library(PerformanceAnalytics)
library(R.utils)

#|------------------------------------------------------------------------------------------|
#|                            E X T E R N A L   F U N C T I O N S                           |
#|------------------------------------------------------------------------------------------|
PyAnalyzerLst <- function(valueXts, benchChr)
{
  #---  Assert TWO (2) arguments:                                                   
  #       valueXts:     a data frame (xts) of "values"
  #       benchChr:     symbol for benchmark
  
  #---  Check that arguments are valid
  if( missing(valueXts) )
    stop("valueXts CANNOT be EMPTY")
  if( missing(benchChr) )
    stop("benchChr CANNOT be EMPTY")
  else if( benchChr=="" )
    stop("benchChr CANNOT be EMPTY")
  
  #---  Read in data, then analyze it
  symChr    <- benchChr
  startChr  <- as.character( min(index(valueXts)), format="%Y-%m-%d" )
  finishChr <- as.character( max(index(valueXts)), format="%Y-%m-%d" )
  
  #---  Read in "prices" of symbols
  priceXts  <- QstkReadXts(symChr, startChr, finishChr)
  priceXts  <- fill.na(priceXts, method='ffill')
  priceXts  <- fill.na(priceXts, method='bfill')
  priceXts  <- fill.na(priceXts, method='ofill')
  
  #---  Calculate ratios
  value.mean.daily  <- mean(dailyReturn(valueXts[,1]))
  value.sd.daily    <- sqrt(var(dailyReturn(valueXts[,1])))
  value.sharpe.pa   <- sqrt(252)*value.mean.daily/value.sd.daily
  value.tsr         <- as.numeric(valueXts[nrow(valueXts),1])/as.numeric(valueXts[1,1])
  
  price.mean.daily  <- mean(dailyReturn(priceXts[,1]))
  price.sd.daily    <- sqrt(var(dailyReturn(priceXts[,1])))
  price.sharpe.pa   <- sqrt(252)*price.mean.daily/price.sd.daily
  price.tsr         <- as.numeric(priceXts[nrow(priceXts),1])/as.numeric(priceXts[1,1])
  
  #---  Return a list
  #
  retLst <- list("fund.sharpe"  = as.numeric(value.sharpe.pa),
                 "fund.tsr"     = as.numeric(value.tsr),
                 "fund.sd"      = as.numeric(value.sd.daily),
                 "fund.mean"    = as.numeric(value.mean.daily),
                 "bench.sharpe" = as.numeric(price.sharpe.pa),
                 "bench.tsr"    = as.numeric(price.tsr),
                 "bench.sd"     = as.numeric(price.sd.daily),
                 "bench.mean"   = as.numeric(price.mean.daily) 
                 )
  retLst
}  

PyMarketSimXts <- function(initNum, orderStr, outStr=NULL, 
                        workDirStr="C:/Users/denbrige/100 FxOption/103 FxOptionVerBack/080 Fx Git/R-nonsource")
{
  #---  Assert THREE (3) arguments:                                                   
  #       initNum:      a numeric value for initial portfolio value
  #       orderStr:     name of the order file (without the extension ".csv")
  #       outStr:       name of the output file (without the extension ".csv")
  #       workDirStr:   working directory                                             
  
  #---  Check that arguments are valid
  if( missing(orderStr) )
    stop("orderStr CANNOT be EMPTY")
  else if( orderStr=="" )
    stop("orderStr CANNOT be EMPTY")
  
  #---  Read in data, then scan it
  #       (1) Build list of symbols
  #       (2) Build date boundaries (min and max) per list, NOT per symbol
  orderDfr  <- PyOrderReadDfr(orderStr, workDirStr=workDirStr, header=FALSE)
  symChr    <- as.character(sort(unique(orderDfr$Symbol)))
  startChr  <- as.character( min(orderDfr$Date), format="%Y-%m-%d" )
  finishChr <- as.character( max(orderDfr$Date), format="%Y-%m-%d" )
  
  #---  Read in "prices" of symbols
  priceXts  <- QstkReadXts(symChr, startChr, finishChr)
  priceXts  <- fill.na(priceXts, method='ffill')
  priceXts  <- fill.na(priceXts, method='bfill')
  priceXts  <- fill.na(priceXts, method='ofill')
  
  #---  Scan "trades" to update "cash"
  #       (1) Sort "trades" by date, and iterate over "trades"
  #       (2) Check with "prices" and update into "cash"
  orderDfr  <- orderDfr[with(orderDfr, order(Date)), ]
  cashXts   <- PyBillOrderXts(initNum, orderDfr, priceXts)
  
  #---  Scan "trades" to update "values"
  #       (1) Check with "prices" and update into "values"
  valueXts  <- PyCalcValueXts(symChr, orderDfr, priceXts)
  
  #---  Sum "cash" and "values" to create "total"
  totalNum  <- apply( cbind(cashXts$Cash, valueXts$Value), 1, sum )
  totalDfr  <- data.frame(Date=index(valueXts), Total=totalNum)
  totalXts  <- PyDfrToXts(totalDfr)
  
  #---  Write the data
  if( is.null(outStr) )
  {
    return(totalXts)
  } else
  {
    PyFileWriteCsv(totalXts, outStr, workDirStr=workDirStr)
  }
}

#|------------------------------------------------------------------------------------------|
#|                            I N T E R N A L   F U N C T I O N S                           |
#|------------------------------------------------------------------------------------------|
PyCalcValueXts <- function(symChr, orderDfr, priceXts)
{
  sRow      <- nrow(priceXts)
  part1Str  <- "dataFrame( colClasses=c(Date='character'," 
  for( i in seq_along(symChr) )
  {
    if( i == 1 )
    {
      part2Str <- paste0(symChr[i],"='numeric',")
    } else {
      part2Str <- paste0(part2Str, symChr[i],"='numeric',")
    }
  }
  part3Str  <- paste0("Value='numeric'), nrow=",sRow,")")
  valueDfr  <- eval(parse(text=paste0(part1Str, part2Str, part3Str)))
  valueDfr$Date   <- as.character(index(priceXts), format("%Y-%m-%d"))
  for( iRow in 1:nrow(orderDfr) )
  {
    jRow    <- which(index(priceXts)==orderDfr$Date[iRow])
    jSym    <- as.character(orderDfr$Symbol[iRow])
    jPrice  <- as.numeric( priceXts[jRow, orderDfr$Symbol[iRow]] )
    if( "buy"==tolower(orderDfr$Type[iRow]) )   jType=1
    if( "sell"==tolower(orderDfr$Type[iRow]) )  jType=-1
    jUnit   <- orderDfr$Unit[iRow] * jType
    valueDfr[jRow, jSym]  <- valueDfr[jRow, jSym] + jUnit 
    if( jRow < sRow )
    {
      valueDfr[(jRow+1):sRow, jSym] <- valueDfr[jRow, jSym]
    }
  }
  valueXts  <- PyDfrToXts(valueDfr, "%Y-%m-%d")
  
  for( i in seq_along(symChr) )
  {
    if( i == 1 )
    {
      evalStr <- paste0( "apply(cbind(priceXts[,",i,"], valueXts[,",i,"]),1,prod)" )
    } else {
      evalStr <- paste0( evalStr, "+apply(cbind(priceXts[,",i,"], valueXts[,",i,"]),1,prod)" )
    }
  }
  valueXts$Value <- eval(parse(text=evalStr))
  valueXts  
}

PyBillOrderXts <- function(initNum, orderDfr, priceXts)
{
  sRow      <- nrow(priceXts)
  cashDfr   <- dataFrame( colClasses=c(Date="character", 
                                       Billed="numeric", 
                                       CashBf="numeric", 
                                       Cash="numeric"), nrow=sRow )
  cashDfr$Date    <- as.character(index(priceXts), format("%Y-%m-%d"))
  cashDfr$Billed  <- 0  
  cashDfr$CashBf  <- initNum
  cashDfr$Cash    <- initNum
  for( iRow in 1:nrow(orderDfr) )
  {
    jRow    <- which(index(priceXts)==orderDfr$Date[iRow])
    jPrice  <- as.numeric( priceXts[jRow, as.character(orderDfr$Symbol[iRow])] )
    jUnit   <- orderDfr$Unit[iRow]
    if( "buy"==tolower(orderDfr$Type[iRow]) )   jType=-1
    if( "sell"==tolower(orderDfr$Type[iRow]) )  jType=1
    jBilled <- jPrice * jUnit * jType
    cashDfr[jRow, "Billed"] <- cashDfr[jRow, "Billed"] + jBilled 
    cashDfr[jRow, "Cash"]   <- cashDfr[jRow, "CashBf"] + cashDfr[jRow, "Billed"]
    if( jRow < sRow )
    {
      cashDfr[(jRow+1):sRow, "CashBf"]  <- cashDfr[jRow, "Cash"]
      cashDfr[(jRow+1):sRow, "Cash"]    <- cashDfr[jRow, "Cash"]
    }
  }
  cashXts  <- PyDfrToXts(cashDfr, "%Y-%m-%d")
  cashXts
}

PyDfrToXts <- function(datDfr, formatChr=NULL)
{
  if( is.null(formatChr) )
    retXts <- xts( datDfr[,-1], order.by=datDfr[,1] )
  else
    retXts <- xts( datDfr[,-1], order.by=as.Date(datDfr[,1], format=formatChr) )
  names( retXts ) <- names( datDfr )[-1]
  retXts
}

PyOrderReadDfr <- function(fileStr, 
                          workDirStr="C:/Users/denbrige/100 FxOption/103 FxOptionVerBack/080 Fx Git/R-nonsource", ...)
{
  #---  Assert TWO (2) arguments:
  #       fileStr:      name of the file (without the extension ".csv")
  #       workDirStr:   working directory                                             
  
  #---  Check that arguments are valid
  if( missing(fileStr) )
    stop("fileStr CANNOT be EMPTY")
  else if( fileStr=="" )
    stop("fileStr CANNOT be EMPTY")
  
  #---  Read in data using standard function                                                         
  rawDfr <- fileReadDfr(fileStr, ...)
  
  #---  Coerce data into numeric or date.
  #     [6] Number of units
  #     [1] Year, e.g. 2013
  #     [2] Month, e.g. 2
  #     [3] Day, e.g. 15
  rawDfr[, 6] <- suppressWarnings( as.numeric( rawDfr[, 6] ) )
  rawDfr[, 7] <- as.Date(paste(rawDfr[, 1],rawDfr[, 2],rawDfr[, 3],sep="/"), "%Y/%m/%d")
  names(rawDfr) <- c("Year", "Month", "Day", "Symbol", "Type", "Unit", "Date")
  
  retDfr <- data.frame(Date=rawDfr$Date, Symbol=rawDfr$Symbol, Type=rawDfr$Type, Unit=rawDfr$Unit)
  
  #---  Return a data frame
  return(retDfr)
}

PyFileWriteCsv <- function(datXts, fileStr, 
                           workDirStr="C:/Users/denbrige/100 FxOption/103 FxOptionVerBack/080 Fx Git/R-nonsource")
{
  #---  Assert THREE (3) arguments:                                                   
  #       datXts:       data frame (xts) to be written                                               
  #       fileStr:      name of the file (without the extension ".csv")
  #       workDirStr:   working directory                                             
  
  #---  Check that arguments are valid
  #       apply() function returns a list of arrays
  #       sapply() function returns a vector of numbers
  gLst <- apply(datXts, 2, grep, pattern=",")
  if( length(gLst)>0 )
  {
    if( sum(sapply(gLst,sum))>0 )
      stop("ONE (1) OR MORE columns in datXts contain comma as values.")
  }
  if( missing(fileStr) )
    stop("fileStr CANNOT be EMPTY")
  else if( fileStr=="" )
    stop("fileStr CANNOT be EMPTY")
  
  #---  Split data into separate columns.
  sizeNum       <- ncol(datXts)
  datXts$Year   <- as.character(index(datXts), format="%Y")
  datXts$Month  <- as.character(index(datXts), format="%m")
  datXts$Day    <- as.character(index(datXts), format="%d")
  
  outDfr <- data.frame(Year=datXts$Year, Month=datXts$Month, Day=datXts$Day)
  for( i in 1:sizeNum )
  {
    nameChr     <- names(datXts) 
    outDfr[, nameChr[i]] <- datXts[, nameChr[i]]
  }
  
  #---  Set working directory                                                         
  setwd(workDirStr)
  #---  Write data
  #       Remove quotes from characters
  #       Remove row names 
  #       Remove col names
  write.table( outDfr, file=paste0( fileStr, ".csv" ), sep=",", quote=FALSE, row.names=FALSE, col.names=FALSE )
  outDfr
}
fill.na <- function(priceXts, method="ffill")
{
  if( method=="ffill" )
  {
    fil.num <- as.numeric(priceXts[1, ])
    row.seq <- 2:nrow(priceXts)
  } else if( method =="bfill" ) 
  {
    fil.num <- as.numeric(priceXts[nrow(priceXts), ])
    row.seq <- (nrow(priceXts)-1):1
  } else if( method =="ofill" ) {
    fil.num <- rep(1.0, nrow(priceXts))
  } else
    stop("method MUST be EITHER 'ffill', 'bfill', OR 'ofill'")
  
  if( method=="ofill")
  {
    for( jCol in 1:ncol(priceXts) )
    {
      naBln <- sum(is.na(priceXts[, jCol])) == nrow(priceXts)
      if( naBln ) priceXts[, jCol] <- fil.num
    }
  } else {
    for( iRow in row.seq )
    {
      naBln <- sum(is.na(priceXts[iRow,])) > 0
      if( naBln )
      {
        for( jCol in 1:ncol(priceXts) )
        {
          val   <- as.numeric(priceXts[iRow, jCol])
          fil   <- fil.num[jCol]
          if( is.na(val) & !is.na(fil) )
            priceXts[iRow, jCol] <- fil
        }
      }
      fil.num <- as.numeric(priceXts[iRow,])
    }
  }
  priceXts
}

QstkReadXts <- function(symChr, startDate, finishDate, qstkDir="C:/Python27/Lib/site-packages/QSTK/QSData/Yahoo/")
{
  plt.first.date <- as.Date(startDate, format="%Y-%m-%d")
  plt.last.date <- as.Date(finishDate, format="%Y-%m-%d")
  cv.date.range <- paste(plt.first.date, "::", plt.last.date, sep="")
  
  # Specify character vector for stock names.
  cv.names <- symChr
  
  # Assign source and date format details for all symbols in cv.names.
  for(i in index(cv.names))
  {
    eval(parse(text=paste("setSymbolLookup(",
                          cv.names[i],
                          "=list(src='csv',format='%Y-%m-%d'))")
    )
    )
  }
  # Load symbols.
  for(symbol in cv.names)
  {
    getSymbols(symbol, dir=qstkDir)
  }
  
  cv.names <- sort(cv.names)
  # Merge the adjusted close prices for all the symbols in the portfolio. This loop accomodates any
  # number of symbols and any symbol names. The loop creates a string for the merge command with all
  # its arguments filled in. This string is then passed to the "eval(parse())" combination for
  # execution.
  for(i in index(cv.names))
  {
    if(i == 1){st.merge <- paste(cv.names[i], "[,", "'", cv.names[i], ".Adjusted']", sep="")} else
    {st.merge <- paste(st.merge, paste(cv.names[i], "[,", "'", cv.names[i], ".Adjusted']", sep=""),
                       sep=",")}
    
  }
  xts.port <- eval(parse(text=paste("merge(", st.merge, ")", sep="")))
  # Truncate the data to the specified range.
  xts.port <- xts.port[cv.date.range,]
  names(xts.port) <- cv.names
  xts.port
}

#|------------------------------------------------------------------------------------------|
#|                                E N D   O F   S C R I P T                                 |
#|------------------------------------------------------------------------------------------|