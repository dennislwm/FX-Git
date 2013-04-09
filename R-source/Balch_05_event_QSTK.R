#|------------------------------------------------------------------------------------------|
#|                                                                    Balch_05_event_QSTK.R |
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
#|    In this homework you will take the output of your Event Study work to build a more    |
#|  complete back testing platform. Specifically, you should choose an event from the ones  |
#|  you have experimented with in this class, assess it and tune it using the Event         |
#|  Profiler, then back test it with the simulator you created.                             |
#|                                                                                          |
#|    A.  Revise your event analyzer to output a series of trades based on events. Instead  |
#|      of putting a ONE (1) in the event matrix, output to a file.                         |
#|        Feed that output into your market simulator, and report the performance of your   |
#|      strategy in terms of total return, average daily return, STDDEV of daily return,    |
#|      and Sharpe Ratio for the time period.                                               |
#|                                                                                          |
#| Example                                                                                  |
#|    A.  > eventXts  <- tutorialXts()                                                      |
#|        > orderXts  <- PyOrderWriteCsv(eventXts, "Balch_05_event_orders")                 |
#|                                                                                          |
#| History                                                                                  |
#|  0.9.2   Fixed missing code (write to csv) in function PyOrderWriteCsv().                |
#|  0.9.1   Added TWO (2) external functions tutorialXts() and PyOrderWriteCsv(), and       |
#|          FOUR (4) internal functions shiftDfr(), QstkGetSymbolChr(), PyFileWriteCsv()    |
#|          and PyDfrToXts(). The latter TWO (2) functions were copied from the R script    |
#|          "Balch_04_backtest_QSTK.R". Also, we added a parameter priceChr (default:       |
#|          "Adjusted") to the function QstkReadXts() to specify the price column to be     |
#|          used, and we added a new method "ofill" in function fill.na(). Todo: Write code |
#|          for eventProfiler() function.                                                   | 
#|  0.9.0   Coursera's "Computational Investing" course (Tucker Balch) Quiz 6 Week 6.       |
#|          Todo: Function eventProfiler() and Homework 4.                                  |
#|------------------------------------------------------------------------------------------|
source("C:/Users/denbrige/100 FxOption/103 FxOptionVerBack/080 Fx Git/R-source/PlusReg.R", echo=FALSE)
source("C:/Users/denbrige/100 FxOption/103 FxOptionVerBack/080 Fx Git/R-source/PlusFile.R", echo=FALSE)
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
  
  actualXts <- QstkReadXts(symChr, startChr, finishChr, priceChr='Close')
  actualXts <- fill.na(actualXts, method='ffill')
  actualXts <- fill.na(actualXts, method='bfill')
  actualXts <- fill.na(actualXts, method='ofill')
  
  eventXts  <- findEvents(symChr, actualXts) 
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
      if( today.sym < 9.0 & ysday.sym >= 9.0 )
        eventXts[jRow, iSym] <- TRUE
    }
  }
  # eventXts[, -which(names(eventXts)==mktChr)]
  eventXts
}

eventProfiler <- function(event, data, lookBack=20, lookForward=20, fileStr="study", 
                          marketNeutralBln=TRUE, errorBarBln=TRUE, marketSymChr="SPY")
{
  #---  df_close = d_data['close'].copy()
  #       (1) df_close is a data frame with rows as "adjusted" close, and cols as "symbols",
  #           e.g. df_close.columns: "[... YHOO, YUM, ZION, ZMH, SPY]"
  #       (2) df_close.values: "[... 12.73, 59.42, 107.5]"
  
  #---  df_rets = df_close.copy()
  #     tsu.returnize0(df_rets.values)
  #       (1) df_rets.values (before): "[... 12.73, 59.42, 107.5]"
  #       (2) df_rets.values (after):  "[... 0.00394322, -0.00701872, -0.00037195]"
  
  #---  if b_market_neutral == TRUE:
  #       df_rets = df_rets - df_rets['SPY']
  #         (1) df_rets.values (before): "[... 0.00394322, -0.00701872, -0.00037195]"
  #         (2) df_rets.values (after):  "[... 0.00431517, -0.00664676,  0]"
  #       del df_rets['SPY']
  #         (3) df_rets.columns (before): "[... YHOO, YUM, ZION, ZMH, SPY]"
  #         (4) df_rets.columns (after):  "[... YHOO, YUM, ZION, ZMH]"
  #       del df_events['SPY']
  #         (5) df_events.columns (before): "[... YHOO, YUM, ZION, ZMH, SPY]"
  #         (6) df_events.columns (after):  "[... YHOO, YUM, ZION, ZMH]"
  #         (7) df_events.values:           "[... nan,  nan,  nan]"
  
  #---  df_close = df_close.reindex(columns=df_events.columns)
  #       (1) this equivalent code is > del df_close['SPY']

  #---  df_events.values[0:lookBack, :] = np.NaN
  #     df_events.values[-lookForward:, :] = np.NaN
  #       (1) df_events.values[0:20, :] = "[... nan,  nan,  nan]"
  #       (2) df_events.values[-20:, :] = "[... nan,  nan,  nan]"
  
  #---  i_no_events = int(np.nansum(df_events.values))
  #     na_event_rets = "False"
  #       (1) Return the sum of array elements over a given axis treating 
  #           Not a Numbers (NaNs) as ZERO (0)
  #       (2) i_no_events = 451
  #       (3) type(na_event_rets) = 'str'
  
  #---  for i, s_sym in enumerate(df_events.columns):
  #             (1) iCol in 0:500, sym in 'A':'ZMH'
  #       for j, dt_date in enumerate(df_events.index):
  #             (2) jRow in 0:503, dt_date in '2008-01-02 16:00:00':'2009-12-30 16:00:00'
  #         if df_events[s_sym][dt_date] == 1:
  #         na_ret = df_rets[s_sym][j - i_lookback:j + 1 + i_lookforward]
  #             (3) na_ret = "[... 0.014150, -0.020885, -0.068655] Name: ZION"
  #             (4) na_ret.shape = (41,)
  #         if type(na_event_rets) == type(""):
  #             (5) type("") = 'str'
  #             (6) type(na_event_rets) = 'numpy.ndarray'
  #           na_event_rets = na_ret
  #         else:
  #           na_event_rets = np.vstack((na_event_rets, na_ret))
  #             (7) Take a sequence of arrays and stack them vertically to make a single array
  #             (8) na_event_rets.shape = (451, 41)
  
  #---  na_event_rets = np.cumprod(na_event_rets + 1, axis=1)
  #       (1) 
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