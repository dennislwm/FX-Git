#|------------------------------------------------------------------------------------------|
#|                                                                    Balch_04_quiz5_QSTK.R |
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
#| History                                                                                  |
#|  0.9.0   Coursera's "Computational Investing" course (Tucker Balch) Quiz 5 Week 5.       |
#|          Todo: Part A is partially complete and we have not started on Part B.           |
#|------------------------------------------------------------------------------------------|
source("C:/Users/denbrige/100 FxOption/103 FxOptionVerBack/080 Fx Git/R-source/PlusReg.R", echo=FALSE)
source("C:/Users/denbrige/100 FxOption/103 FxOptionVerBack/080 Fx Git/R-source/PlusFile.R", echo=FALSE)
library(quantmod)
library(PerformanceAnalytics)

#---  Prerequisite. We have to perform these TWO (2) steps prior to running this script.
#     (1) Download the data using the python script "Balch_01_tutorial01_QSTK.py" and save
#         it as a CSV file "Balch_02_tutorial01". Note: The python script saves the adjusted
#         closing price ONLY.
#     (2) Copy the CSV file into the folder "R-nonsource".
#|------------------------------------------------------------------------------------------|
#|                            E X T E R N A L   F U N C T I O N S                           |
#|------------------------------------------------------------------------------------------|
PyMarketSim <- function(initNum, orderStr, outStr, 
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
  orderDfr  <- PyFileReadDfr(orderStr, header=FALSE)
  symChr    <- unique(orderDfr$Symbol)
  startChr  <- as.character( min(orderDfr$Date), format="%Y-%m-%d" )
  finishChr <- as.character( max(orderDfr$Date), format="%Y-%m-%d" )
  
  #---  Read in "prices" of symbols
  priceXts  <- QstkReadXts(symChr, startChr, finishChr)
  
  #---  Scan trades to update "cash"
  #       (1) Sort "trades" by date
  #       (2) Check with "prices" and update into "fill"
  #       (3) Iterate over "fill" into "cash"
  orderDfr <- orderDfr[with(orderDfr, order(Date)), ]
  for( iRow in 1:nrow(orderDfr) )
  {
    jRow    <- which(index(priceXts)==orderDfr$Date[iRow])
    jPrice  <- priceXts[jRow, orderDfr$Symbol[iRow])
  }

  #---  Write the data
  PyFileWriteCsv(totalDfr)
}

#|------------------------------------------------------------------------------------------|
#|                            I N T E R N A L   F U N C T I O N S                           |
#|------------------------------------------------------------------------------------------|
PyFileReadDfr <- function(fileStr, workDirStr="C:/Users/denbrige/100 FxOption/103 FxOptionVerBack/080 Fx Git/R-nonsource", ...)
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
  names(rawDfr) <- c("Year", "Month", "Day", "Symbol", "Type", "Unit", "Date")
  rawDfr[, 6] <- suppressWarnings( as.numeric( rawDfr[, 6] ) )
  rawDfr[, 7] <- as.Date(paste(rawDfr[, 1],rawDfr[, 2],rawDfr[, 3],sep="/"), "%Y/%m/%d")
  
  retDfr <- data.frame(Date=rawDfr$Date, Symbol=rawDfr$Symbol, Type=rawDfr$Type, Unit=rawDfr$Unit)
  
  #---  Return a data frame
  return(retDfr)
}

PyFileWriteCsv <- function(datDfr, fileStr, 
                         workDirStr="C:/Users/denbrige/100 FxOption/103 FxOptionVerBack/080 Fx Git/R-nonsource")
{
  #---  Assert THREE (3) arguments:                                                   
  #       datDfr:       data frame to be written                                               
  #       fileStr:      name of the file (without the extension ".csv")
  #       workDirStr:   working directory                                             
  
  #---  Check that arguments are valid
  #       apply() function returns a list of arrays
  #       sapply() function returns a vector of numbers
  gLst <- apply(datDfr, 2, grep, pattern=",")
  if( length(gLst)>0 )
  {
    if( sum(sapply(gLst,sum))>0 )
      stop("ONE (1) OR MORE columns in datStr contain comma as values.")
  }
  if( missing(fileStr) )
    stop("fileStr CANNOT be EMPTY")
  else if( fileStr=="" )
    stop("fileStr CANNOT be EMPTY")
  
  #---  Split data into separate columns.
  sizeNum       <- ncol(datDfr)
  datDfr$Year   <- as.character(orderDfr$Date, format="%Y")
  datDfr$Month  <- as.character(orderDfr$Date, format="%m")
  datDfr$Day    <- as.character(orderDfr$Date, format="%d")
  
  outDfr <- data.frame(Year=datDfr$Year, Month=datDfr$Month, Day=datDfr$Day)
  outDfr <- cbind(outDfr, datDfr[, 2:sizeNum])
  
  #---  Set working directory                                                         
  setwd(workDirStr)
  #---  Write data
  #       Remove quotes from characters
  #       Remove row names 
  #       Remove col names
  write.table( outDfr, file=paste0( fileStr, ".csv" ), sep=",", quote=FALSE, row.names=FALSE, col.names=FALSE )
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