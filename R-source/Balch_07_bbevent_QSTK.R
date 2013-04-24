#|------------------------------------------------------------------------------------------|
#|                                                                  Balch_07_bbevent_QsTK.R |
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
#|    In this homework you will investigate event studies based on technical indicators. I  |
#|  mentioned in class that I believe that technical indicators for a stock that move       |
#|  against the way the market is moving may have more validity than otherwise. So for this |
#|  exercise we will investigate that hypothesis. The project is to look for events with    |
#|  Bollinger Bands where the Bollinger value for an individual stock is significantly      |
#|  different than it currently is for the market.                                          |
#|                                                                                          |
#|    A.  Create an event study with the following parameters:                              |
#|                                                                                          |
#|      (i)     Bollinger value for the equity today < -2.0;                                |
#|      (ii)    Bollinger value for the equity yesterday >= -2.0;                           |
#|      (iii)   Bollinger value for SPY today >= 1.0.                                       |
#|      (iv)    Startdate: 1 Jan 2008                                                       |
#|      (v)     Enddate: 31 Dec 2009                                                        |
#|      (vi)    20 day lookback for Bollinger bands                                         |
#|      (vii)   Symbol list: SP5002012                                                      |
#|      (viii)  Adjusted close.                                                             |
#|                                                                                          |
#|        So we're looking for situations where the stock has punched through the LOWER     |
#|      band and the market is substantially in the other direction. That suggests that     |
#|      something special is happening with the stock.                                      |
#|                                                                                          |
#|        The Bollinger band event study has 278 events.                                    |
#|                                                                                          |
#|    B.  Revise your event analyzer to output a series of trades based on events. Instead  |
#|      of putting a ONE (1) in the event matrix, output to a file. Feed that output into   |
#|      your market simulator, and report the performance of your strategy in terms of      |
#|      total return, average daily return, STDDEV of daily return, and Sharpe Ratio for    |
#|      the time period. Additional parameters:                                             |
#|                                                                                          |
#|      (ix)    Starting cash: $100,000                                                     |
#|      (x)     When an event occurs, buy 100 shares of the equity on that day.             |
#|      (xi)    Sell automatically 5 trading days later.                                    |
#|                                                                                          |
#|      Output of the sample event in B.                                                    |
#|                                                                                          |
#|        Data Range :  2008-02-25 16:00:00  to  2009-12-30 16:00:00                        |
#|        Sharpe Ratio of Fund : 0.878184607953                                             |
#|        Sharpe Ratio of $SPX : -0.119678949254                                            |
#|        Total Return of Fund :  1.09201                                                   |
#|        Total Return of $SPX : 0.821125528503                                             |
#|        Standard Deviation of Fund :  0.00351096966115                                    |
#|        Standard Deviation of $SPX : 0.0224380004349                                      |
#|        Average Daily Return of Fund :  0.000194228352864                                 |
#|        Average Daily Return of $SPX : -0.000169161547432                                 |
#|                                                                                          |
#| Example                                                                                  |
#|    A.  > eventXts  <- tutorialXts()                                                      |
#|    B.  > orderXts  <- PyOrderWriteCsv(eventXts, "Balch_07_bbevent_orders")               |
#|        > valueXts  <- PyMarketSimXts(100000, "Balch_07_bbevent_orders")                  |
#|        > fundLst   <- PyAnalyzerLst(valueXts, "SPX")                                     |
#|                                                                                          |
#| History                                                                                  |
#|  0.9.0   Coursera's "Computational Investing" course (Tucker Balch) Quiz 8 Week 8.       |
#|------------------------------------------------------------------------------------------|
source("C:/Users/denbrige/100 FxOption/103 FxOptionVerBack/080 Fx Git/R-source/PlusReg.R", echo=FALSE)
source("C:/Users/denbrige/100 FxOption/103 FxOptionVerBack/080 Fx Git/R-source/PlusFile.R", echo=FALSE)
source("C:/Users/denbrige/100 FxOption/103 FxOptionVerBack/080 Fx Git/R-source/Balch_04_backtest_QSTK.R", echo=FALSE)
library(quantmod)
library(PerformanceAnalytics)
library(R.utils)

#|------------------------------------------------------------------------------------------|
#|                            E X T E R N A L   F U N C T I O N S                           |
#|------------------------------------------------------------------------------------------|
tutorialXts <- function()
{
  startChr  <- "2008-01-01"
  finishChr <- "2009-12-30"
  #---  Read symbols from file "sp5002012"
  #       (1) Use a smaller subset of symbols, with at least ONE (1) NA to validate the 
  #           function fill.na().
  symChr    <- QstkGetSymbolChr("sp5002012")
  #symChr    <- c('A', 'SNI')
  symChr    <- c(symChr, 'SPY')
  
  actualXts <- QstkReadXts(symChr, startChr, finishChr)
  actualXts <- fill.na(actualXts, method='ffill')
  actualXts <- fill.na(actualXts, method='bfill')
  actualXts <- fill.na(actualXts, method='ofill')
  
  width     <- 20
  retXts    <- rollapply(actualXts, width, FUN=function(x) { (x[length(x)]-mean(x))/sd(x) } )
  retXts    <- retXts[width:nrow(retXts)]
  retXts    <- fill.na(retXts, method='ffill')
  retXts    <- fill.na(retXts, method='bfill')
  retXts    <- fill.na(retXts, method='ofill')
  
  eventXts  <- findEvents(symChr, retXts) 
  eventXts
}
PyOrderWriteCsv <- function(eventXts, fileStr, tNum=5,
                            workDirStr="C:/Users/denbrige/100 FxOption/103 FxOptionVerBack/080 Fx Git/R-nonsource")
{
  #---  Assert FOUR (4) arguments:                                                   
  #       eventXts:     data frame (xts) with event matrix
  #       fileStr:      name of the file (without the extension ".csv")
  #       tNum:         a numeric for the number of trading days
  #       workDirStr:   working directory                                             
  
  #---  Check that arguments are valid
  if( missing(fileStr) )
    stop("fileStr CANNOT be EMPTY")
  else if( fileStr=="" )
    stop("fileStr CANNOT be EMPTY")
  if( tNum <= 0 )
    stop("tNum MUST be greater than ZERO (0)")
  
  #---  Create a sell data frame
  #       (1) Copy and shift the event data frame by tNum days, i.e.
  #           the LAST tNum rows has shifted to the FIRST tNum rows, while shifting rows down
  #       (2) For EACH symbol, sum(buy[1:tNum,sym]) into finalNum, i.e.
  #           buy orders with LESS than tNum days.
  #       (3) Assign finalNum into the LAST row and the FIRST tNum rows to ZERO (0)
  #           of the sell data frame
  #       (4) (Optional) Multiply sell data frame by -1
  #       (5) Rename the rows using the index(event)
  sellDfr   <- shiftDfr(as.data.frame(eventXts), tNum)
  finalNum  <- apply(sellDfr[1:tNum,], 2, sum)
  if( sum(finalNum) > 0 )
  {
    sellDfr[1:tNum, ] <- 0
    sellDfr[nrow(sellDfr), ] <- finalNum
  }
  sellDfr   <- -1 * sellDfr
  row.names(sellDfr) <- index(eventXts)
  
  #---  Combine event and sell into an order data frame (xts)
  #       (1) Check that the sum(order[sym]) for EACH symbol = 0
  #       (2) Write the order data frame using the function PyFileWriteCsv().
  orderDfr  <- dataFrame( colClasses=c(Date="character", 
                                       Symbol="character", 
                                       Order="character", 
                                       Unit="numeric"), nrow=0 )
  for( iRow in 1:nrow(eventXts) )
  {
    buyBln  <- sum(eventXts[iRow,]) != 0
    sellBln <- sum(sellDfr[iRow,]) != 0
    if( buyBln | sellBln )
    {
      for( jSym in 1:ncol(eventXts) )
      {
        dateChr     <- as.character(index(eventXts)[iRow])
        symChr      <- names(eventXts)[jSym]
        if( eventXts[iRow, jSym] != 0 )
        {
          #--- append buy order
          qtyNum    <- 100 * as.numeric(eventXts[iRow, jSym])
          newDfr    <- data.frame(Date=dateChr, Symbol=symChr, Order="Buy", Unit=qtyNum)
          orderDfr  <- rbind(orderDfr, newDfr)
        }
        if( sellDfr[iRow, jSym] != 0 )
        {
          #--- append sell order
          qtyNum    <- abs(100 * as.numeric(sellDfr[iRow, jSym]))
          newDfr    <- data.frame(Date=dateChr, Symbol=symChr, Order="Sell", Unit=qtyNum)
          orderDfr  <- rbind(orderDfr, newDfr)
        }
      }
    }
  }
  orderXts <- PyDfrToXts(orderDfr, formatChr="%Y-%m-%d")
  PyFileWriteCsv(orderXts, fileStr)
  orderXts
}
findEvents <- function(symChr, priceXts, mktChr="SPY")
{
  eventXts <- priceXts
  for( iCol in 1:ncol(eventXts) )
    eventXts[, iCol] <- FALSE
  eventXts
  
  for( iSym in 1:ncol(priceXts) )
  {
    for( jRow in 2:nrow(priceXts) )
    {
      today.sym <- as.numeric(priceXts[jRow, iSym])
      ysday.sym <- as.numeric(priceXts[jRow-1, iSym])
      today.mkt <- as.numeric(priceXts[jRow, mktChr])
      ysday.mkt <- as.numeric(priceXts[jRow-1, mktChr])
      daily.sym <- (today.sym/ysday.sym) - 1
      daily.mkt <- (today.mkt/ysday.mkt) - 1
      
      #if( daily.sym <= -0.03 & daily.mkt >= 0.02 )
      #if( today.sym < 9.0 & ysday.sym >= 9.0 )
      if( today.sym < -2.0 & ysday.sym >= -2.0 & today.mkt >= 1.0 )
        eventXts[jRow, iSym] <- TRUE
    }
  }
  # eventXts[, -which(names(eventXts)==mktChr)]
  eventXts
}

#|------------------------------------------------------------------------------------------|
#|                            I N T E R N A L   F U N C T I O N S                           |
#|------------------------------------------------------------------------------------------|
shiftDfr <- function(df,offset) df[((1:nrow(df))-1-offset)%%nrow(df)+1,]

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
PyDfrToXts <- function(datDfr, formatChr=NULL)
{
  if( is.null(formatChr) )
    retXts <- xts( datDfr[,-1], order.by=datDfr[,1] )
  else
    retXts <- xts( datDfr[,-1], order.by=as.Date(datDfr[,1], format=formatChr) )
  names( retXts ) <- names( datDfr )[-1]
  retXts
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
QstkGetSymbolChr <- function(fileChr, qstkDir="C:/Python27/Lib/site-packages/QSTK/QSData/Yahoo/Lists/")
{
  pathChr <- paste0(qstkDir,fileChr,".txt")
  if( !file.exists(pathChr) ) return( NULL )
  else
    retDfr <- read.csv(pathChr, header=FALSE, colClasses="character", sep=",")
  return( as.character(retDfr[,1]) )
}
QstkReadXts <- function(symChr, startDate, finishDate, priceChr="Adjusted", qstkDir="C:/Python27/Lib/site-packages/QSTK/QSData/Yahoo/")
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
    if(i == 1){st.merge <- paste(cv.names[i], "[,", "'", cv.names[i], ".", priceChr, "']", sep="")} else
    {st.merge <- paste(st.merge, paste(cv.names[i], "[,", "'", cv.names[i], ".", priceChr, "']", sep=""),
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