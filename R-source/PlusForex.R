#|------------------------------------------------------------------------------------------|
#|                                                                              PlusForex.R |
#|                                                             Copyright © 2012, Dennis Lee |
#| Assert Background                                                                        |
#|    The data for this R script comes from a windows app named MetaTrader 4 and a web site |
#|  called MQL5.com. There are NINE (9) files from MetaTrader 4 ( click on menu File->      |
#|  Save As ): (1) EURUSD1.csv, (2) EURUSD5.csv, (3) EURUSD15.csv, (4) EURUSD30.csv,        |
#|  (5) EURUSD60.csv; (6) EURUSD240.csv; (7) EURUSD1440.csv; (8) EURUSD10080.csv, and       |
#|  (9) EURUSD43200.csv. There are SEVEN (7) columns in each CSV file: (1) Date; (2) Time;  |
#|  (3) Open; (4) High;  (5) Low; (6) Close; and (7) Volume, with NO header. These files    |
#|  are easily read into R using the read.csv() function. However, for MQL5, there are NO   |
#|  CSV files, hence we have to scrape the data from the web page using the XML package.    |
#|  The data is then saved into a CSV file.                                                 |
#|                                                                                          |
#| Assert Function                                                                          |
#|                                                                                          |
#|    (1) Display the Autocorrelation Function plots of a currency for different periods.   |
#|                                                                                          |
#|        ForexAcfPlot <- function( symbolChr ) {                                           |
#|        #---  Assert ONE (1) argument:                                                    |
#|        #       symbolChr:       Currency symbol, e.g. EURUSD.                            |
#|        }                                                                                 |
#|                                                                                          |
#|    (2) Display a box plot with a median ranking by group.                                |
#|                                                                                          |
#|        ForexBoxplotFtr <- function( inDfr, FUN, ... ) {                                  |
#|        #---  Assert THREE (3) arguments:                                                 |
#|        #       inDfr:      data frame with AT LEAST TWO (2) columns: (1) "name", and     |
#|        #                   (2) "value"                                                   |
#|        #       FUN:        function to apply and sort the values by (default: MEDIAN)    |
#|        #       ...:        arguments to pass to function boxplot(), e.g. main="My plot"  |
#|        #                   Note: set las and mar arguments using the par() function      |
#|        }                                                                                 |
#|                                                                                          |
#| Assert History                                                                           |
#|  1.0.2   Use function setSymbolLookup() to specify Oanda as the source, and create a     |
#|            plot of EURUSD using candleChart(). Added TWO (2) new indicator functions     |
#|            forexIndSharpeRsi() and forexIndSharpeMacd().                                 |
#|  1.0.1   Added ONE (1) internal function forexAtcUserReadDfr().                          |
#|  1.0.0   Contains R functions to manipulate data from the MQL5.com web site.             |
#|          There are TWO (2) external functions: ForexAcfPlot() and ForexBoxplotFtr(), and |
#|          there are THREE (3) internal fns: forexAtcReadDfr(), freqDfr() and freqVtr().   |
#|------------------------------------------------------------------------------------------|
require(DMwR)
require(tseries)
require(R.utils)
require(XML)
source("C:/Users/denbrige/100 FxOption/103 FxOptionVerBack/080 Fx Git/R-source/PlusReg.R")
source("C:/Users/denbrige/100 FxOption/103 FxOptionVerBack/080 Fx Git/R-source/PlusFile.R")

#|------------------------------------------------------------------------------------------|
#|                            E X T E R N A L   F U N C T I O N S                           |
#|------------------------------------------------------------------------------------------|
#|------------------------------------------------------------------------------------------|
#|                          E X T E R N A L   A   F U N C T I O N S                         |
#|------------------------------------------------------------------------------------------|
ForexAcfPlot <- function(symbolChr)
{
  #---  Assert ONE (1) argument:                                                    
  #       symbolChr:       Currency symbol, e.g. EURUSD.                            

  periodChr <- c("1", "5", "15", "30", "60", "240", "1440", "10080", "43200")
  for( perChr in periodChr )
  {
    #---  Construct name and symbol
    nameChr <- paste(symbolChr, perChr, sep="")
    
    #---  Init loading data
    posDfr <- BasReadDfr(nameChr, header=FALSE)
    
    names(posDfr) <- c("Date", "Time", "Open", "High", "Low", "Close", "Volume")
    
    #--- Coerce character into numeric or date
    posDfr$Open     <- suppressWarnings( as.numeric( posDfr$Open ) )
    posDfr$High     <- suppressWarnings( as.numeric( posDfr$High ) )
    posDfr$Low      <- suppressWarnings( as.numeric( posDfr$Low ) )
    posDfr$Close    <- suppressWarnings( as.numeric( posDfr$Close ) )
    posDfr$Volume   <- suppressWarnings( as.numeric( posDfr$Volume ) )
    #posDfr$Date     <- as.(paste(posDfr$Date, " ", posDfr$Time, sep=""), "%Y.%m.%d %H:%M")
    
    #--- Coerce data frame into zoo and exclude ALL columns except date and close
    posDataZoo <- as.zoo(data.frame(Close=as.numeric(posDfr$Close)))
    index(posDataZoo) = as.chron(paste(posDfr$Date, " ", posDfr$Time, ":00", sep=""), format("%Y.%m.%d %H:%M:%S"))
    
    #--- Calculate cc returns as difference in log prices
    retDataZoo <- diff(log(posDataZoo))
    
    #--- Coerce zoo into matrix as some core functions do NOT work with zoo
    retDataMat = coredata(retDataZoo)
    
    #--- Compute time series diagnostics
    #       Autocorrelations
    #acf( retDataMat[,"Close"], main="" )
    print( acf( retDataMat[, "Close"], ylim=c(-0.2,0.2), xlim=c(2,20), main="" )[1:20, 1] )
    text(7.5, 0.19, nameChr)
    print( nameChr )
  }
}

#|------------------------------------------------------------------------------------------|
#|                          E X T E R N A L   B   F U N C T I O N S                         |
#|------------------------------------------------------------------------------------------|
ForexBoxplotFtr <- function(inDfr, FUN=median, ...)
{
  #---  Assert THREE (3) arguments:                                                    
  #       inDfr:      data frame with AT LEAST TWO (2) columns: (1) "name", and (2) "value"
  #       FUN:        function to apply and sort the values
  #       ...:        arguments to pass to function boxplot(), e.g. main="My plot"
  #                   Note: set las and mar arguments using the par() function
  valueNum <- inDfr$value
  nameFtr <- reorder(inDfr$name, inDfr$value, FUN, na.rm=TRUE)
  orderVtr <- levels(nameFtr["scores"])
  tableDfr <- freqDfr(inDfr$name)
  countVtr <- freqVtr(tableDfr, orderVtr)
  
  boxplot(valueNum ~ nameFtr, xaxt="n", medcol=rgb(0,0,0,alpha=0), ...)
  calcNum <- tapply(inDfr$value, nameFtr, FUN)
  points(calcNum, col="red", pch=18)  
  axis(1, at=seq_along(orderVtr), cex.axis=0.8, 
       labels=eval(substitute(paste(st," (",n,")",sep=""), list(st=orderVtr, n=countVtr) )))  
  return(nameFtr)
}

#|------------------------------------------------------------------------------------------|
#|                            I N T E R N A L   F U N C T I O N S                           |
#|------------------------------------------------------------------------------------------|
#|------------------------------------------------------------------------------------------|
#|                          I N T E R N A L   C   F U N C T I O N S                         |
#|------------------------------------------------------------------------------------------|
forexIndSharpeRsi <- function(quotes, k=26, pAdf=0.05)
{
  #---  ADF null hypothesis is that the data is non-stationary
  #       Therefore, p-value>0.05 is non-stationary
  sdNum <- as.numeric( suppressWarnings(rollapply(quotes, k, sd, na.pad=TRUE)) )
  sdNum <- sdNum[!is.na(sdNum)]
  fNum <- NROW(quotes) - length(sdNum)
  sdNum <- c(rep(NA,fNum), sdNum)
  #---  For some reason, xts always return a time series that is
  #       up to the last row - 1, therefore we use a zoo object 
  rollSd <- zoo( matrix(sdNum, ncol=1), 
                 order.by=time(quotes) )
  if( pAdf > 0 )
  {
    pVal <- suppressWarnings(adf.test(!is.na(sdNum))$p.value)
    if( pVal > pAdf )
      stop("k MUST be greater in for the data to be stationary.")
    
  }
  rollMacd <- MACD(rollSd)
  rollMacd$hist <- rollMacd[,1] - rollMacd[,2]
  rollRsi <- RSI(rollMacd$hist)
  if( is.xts(quotes) )
    rollRsi
  else
    as.numeric(rollRsi)
}

forexIndSharpeMacd <- function(quotes, k=26, pAdf=0.05)
{
  #---  ADF null hypothesis is that the data is non-stationary
  #       Therefore, p-value>0.05 is non-stationary
  sdNum <- as.numeric( suppressWarnings(rollapply(quotes, k, sd, na.pad=TRUE)) )
  sdNum <- sdNum[!is.na(sdNum)]
  fNum <- NROW(quotes) - length(sdNum)
  sdNum <- c(rep(NA,fNum), sdNum)
  rollSd <- zoo( matrix(sdNum, ncol=1), 
                 order.by=time(quotes) )
  if( pAdf > 0 )
  {
    pVal <- suppressWarnings(adf.test(!is.na(sdNum))$p.value)
    if( pVal > pAdf )
      stop("k MUST be greater in for the data to be stationary.")
    
  }
  rollMacd <- MACD(rollSd)
  if( is.xts(quotes) )
    rollMacd
  else
    as.numeric(rollMacd)
}

#|------------------------------------------------------------------------------------------|
#|                          I N T E R N A L   B   F U N C T I O N S                         |
#|------------------------------------------------------------------------------------------|
forexAtcReadDfr <- function( begNum=1, endNum=99 )
{                                                         
  retDfr <- dataFrame( colClasses=c( rank="character",    login="character", 
                                     user="character",    country="character",
                                     deals="character",   trades="character",
                                     pf="character",      balance="character", 
                                     profit="character",  equity="character"), 
                       nrow=0 )
  #---  Initialize page rank
  #       Page rank is a cumulative rank starting from page 1
  pr <- 0
  for( p in begNum:endNum )
  {
    urlStr <- paste0("http://championship.mql5.com/2012/en/users/index/page", p)
    atc.Htm <- htmlParse(urlStr)
    atc.Htt <- readHTMLTable(atc.Htm)
    
    if( length(atc.Htt) < 3 ) break
    atcDfr <- atc.Htt[[3]]
    
    if( is.null(atcDfr) ) break
    
    rNum <- length( levels( atcDfr[ ,1] ) )
    for( r in 1:rNum )
    {
      retDfr[pr+r, 1] <- as.character( atcDfr[, 1][r] )
      retDfr[pr+r, 2] <- as.character( atcDfr[, 2][r] )
      retDfr[pr+r, 3] <- as.character( atcDfr[, 3][r] )
      retDfr[pr+r, 4] <- as.character( atcDfr[, 4][r] )
      retDfr[pr+r, 5] <- as.character( atcDfr[, 5][r] )
      retDfr[pr+r, 6] <- as.character( atcDfr[, 6][r] )
      retDfr[pr+r, 7] <- as.character( atcDfr[, 7][r] )
      retDfr[pr+r, 8] <- as.character( atcDfr[, 8][r] )
      retDfr[pr+r, 9] <- as.character( atcDfr[, 9][r] )
      retDfr[pr+r, 10] <- as.character( atcDfr[, 10][r] )
    }
    pr <- pr + rNum
  }
  if( nrow(retDfr) == 0 ) return(NULL)
  retDfr
}

freqDfr <- function(inVtr)
{
  nameDfr <- inVtr
  
  #--- Count of freq by name
  table(nameDfr)
  #--- Create a data frame of freq by name
  #       Remove row.names
  tableDfr <- data.frame(name=names(tapply(nameDfr, nameDfr, length)), freq=tapply(nameDfr, nameDfr, length))
  rownames(tableDfr) <- NULL
  
  #--- Create a subset
  return(tableDfr)
}

freqVtr <- function(inDfr, orderVtr) 
{
  #---  Assert 'directory' is a character vector of length 1 indicating the location of the
  #       CSV files.
  #     'threshold' is a numeric vector of length 1 indicating the number of completely
  #       observed observations (on all variables) required to compute the correlation 
  #       between nitrate and sulfate; the default is 0.
  #     Return a numeric vector of correlations.
  
  #---  Assert create an empty numeric vector
  outVtr <- numeric(0)
  
  for(ord in orderVtr)
  {
    #---  Append numeric vector
    outVtr <- c(outVtr, inDfr[inDfr$name==ord,2])
  }
  
  #---  Assert return value is a numeric vector
  return(outVtr)
}

#|------------------------------------------------------------------------------------------|
#|                          I N T E R N A L   C   F U N C T I O N S                         |
#|------------------------------------------------------------------------------------------|
forexAtcUserReadDfr <- function( userChr )
{
  if( missing(userChr) )
    stop("userChr CANNOT be EMPTY")
  userNum <- length(userChr)
  
  retDfr <- dataFrame( colClasses=c( user="character",
                                     gprofit="character",     gloss="character", 
                                     nprofit="character",     pfactor="character",
                                     epayoff="character",     absdraw="character",
                                     maxdraw="character",     reldraw="character", 
                                     trades="character",      shorts="character",
                                     longs="character",       winners="character",
                                     losers="character",      maxwin="character",
                                     maxloss="character",     avewin="character",
                                     aveloss="character",     seqwinners="character",
                                     seqlosers="character",   seqwin="character",
                                     seqloss="character",     ghpr="character",
                                     ahpr="character",        sharpe="character",
                                     zscore="character",      regcorr="character",
                                     regse="character",       mfepftcorr="character",
                                     maepftcorr="character",  mfemaecorr="character"), 
                       nrow=userNum )
  
  #---  Initialize page rank
  #       Page rank is a cumulative rank starting from page 1
  for( r in 1:userNum )
  {
    urlStr <- paste0("http://championship.mql5.com/2012/en/users/", userChr[r])
    usr.Htm <- htmlParse(urlStr)
    #---  Remove error in names by setting header=F
    #       Alternatively, only parse the table you want
    usrDfr <- readHTMLTable(usr.Htm, which=9)
    
    if( is.null(usrDfr) ) break
    
    #---  Note the columns do NOT have the same length, due to NAs.
    desChr <- as.character( reorder(usrDfr[, 1], 1:33) )
    valChr <- as.character( reorder(usrDfr[, 2], 1:33) )
    
    #---  Clean up values
    #       Remove $, % and white space
    #       Remove brackets and any value inside
    valChr <- gsub("\\$", "", valChr)
    valChr <- gsub("%", "", valChr)
    valChr <- gsub(" ", "", valChr)
    val.reg <- regexpr("\\(.*\\)", valChr)
    for( i in 1:length(valChr) )
    {
      if( !is.na(val.reg[i]) & val.reg[i]>0 )
        valChr[i] <- substring(valChr[i], 1, val.reg[i]-1)
    }

    if( length(desChr)!=33 | length(valChr)!=33 ) break

    retDfr[r, 1] <- userChr[r]
    retDfr[r, 2] <- valChr[2]
    retDfr[r, 3] <- valChr[3]
    retDfr[r, 4] <- valChr[4]
    retDfr[r, 5] <- valChr[5]
    retDfr[r, 6] <- valChr[6]
    retDfr[r, 7] <- valChr[7]
    retDfr[r, 8] <- valChr[8]
    retDfr[r, 9] <- valChr[9]
    retDfr[r, 10] <- valChr[10]
    retDfr[r, 11] <- valChr[11]
    retDfr[r, 12] <- valChr[12]
    retDfr[r, 13] <- valChr[13]
    retDfr[r, 14] <- valChr[14]
    retDfr[r, 15] <- valChr[15]
    retDfr[r, 16] <- valChr[16]
    retDfr[r, 17] <- valChr[17]
    retDfr[r, 18] <- valChr[18]
    retDfr[r, 19] <- valChr[19]
    retDfr[r, 20] <- valChr[20]
    retDfr[r, 21] <- valChr[21]
    retDfr[r, 22] <- valChr[22]
    retDfr[r, 23] <- valChr[23]
    retDfr[r, 24] <- valChr[24]
    retDfr[r, 25] <- valChr[25]
    retDfr[r, 26] <- valChr[26]
    retDfr[r, 27] <- valChr[27]
    retDfr[r, 28] <- valChr[28]
    
    retDfr[r, 29] <- valChr[30]
    retDfr[r, 30] <- valChr[32]
    retDfr[r, 31] <- valChr[33]
  }
  retDfr
}

#|------------------------------------------------------------------------------------------|
#|                                E N D   O F   S C R I P T                                 |
#|------------------------------------------------------------------------------------------|

if( TRUE )
{
#---  Get daily close prices of forex from Oanda
#       Each symbol is contained in an xts object
  setSymbolLookup(EURUSD=list(name='EUR/USD', src='oanda'))
  suppressWarnings(getSymbols(c('EURUSD')))
  
#---  Plot a candlestick
#       No volume
#       Add a separate indicator window with SharpeRSI
  candleChart(EURUSD, subset='last 6 months', theme='white', TA=NULL)
  indSharpeRsi.FUN <- newTA(FUN=forexIndSharpeRsi, legend='Sharpe Rsi')
  indSharpeMacd.FUN <- newTA(FUN=forexIndSharpeMacd, legend='Sharpe Macd')
  indSharpeMacd.FUN()
  indSharpeRsi.FUN()
}
