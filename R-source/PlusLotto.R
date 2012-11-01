#|------------------------------------------------------------------------------------------|
#|                                                                              PlusLotto.R |
#|                                                             Copyright © 2012, Dennis Lee |
#| Assert Background                                                                        |
#|    The data for this R script comes from Tatts.com (Australia) and SingaporePools.com.sg |
#|  (Singapore). There are FOUR (4) files in CSV format from Tatts.com: (1) powerball.csv,  |
#|  (2) ozlotto.csv, (3) satlotto.csv, and (4) wedlotto.csv. These files are easily read    |
#|  into R using the read.csv() function. However, for SingaporePools.com.sg, there are NO  |
#|  CSV files, hence we have to scrape the results from the web page using the XML package. |  
#|  The data is saved into TWO (2) CSV files: (1) toto.csv, and 4d.csv.                     |
#|                                                                                          |
#| Assert Function                                                                          |
#|                                                                                          |
#|    (1) Forecast a set of Powerball, OzLotto, Gold, Toto or 4D numbers, based on          |
#|        ARIMA(q).                                                                         |
#|                                                                                          |
#|        Lotto <- function(lottoStr, ticketNum) {                                          |
#|        #---  Assert TWO (2) arguments:                                                   |
#|        #        lottoStr:    MUST specify EITHER "powerball", "ozlotto", "satlotto",     |
#|        #                     "wedlotto", OR "toto"                                       |
#|        #        ticketNum:   integer value to specify number of tickets (default: 12)    |
#|        }                                                                                 |
#|                                                                                          |
#|    (2) Update the result files for Powerball, OzLotto, Gold, Toto AND 4D.                |
#|                                                                                          |
#|        LottoUpdate <- function(silent=FALSE) {                                           |
#|        #---  Assert ONE (1) arguments:                                                   |
#|        #       silent:       Do not display print messages (default: FALSE)              |
#|        }                                                                                 |
#|                                                                                          |
#|    (3) Display a table summary of lotto power, based on ARIMA conf.                      |
#|                                                                                          |
#|        LottoArimaSummary <- function(startNum=1) {                                       |
#|        #---  Assert ONE (1) arguments:                                                   |
#|        #       startNum:     the start row that is used in forecast (default: 1)         |
#|        }                                                                                 |  
#|                                                                                          |
#|    (4) Display a table of confidence intervals for each number, based on ARIMA(q)        |
#|                                                                                          |
#|        LottoArimaConf <- function(lottoStr, startNum=1) {                                |
#|        #---  Assert TWO (2) arguments:                                                   |
#|        #       lottoStr:     MUST specify EITHER "powerball", "ozlotto", "satlotto",     |
#|        #                     "wedlotto", OR "toto"                                       |
#|        #       startNum:     the start row that is used in forecast (default: 1)         |
#|        }                                                                                 |
#|                                                                                          |
#|    (5) Display the latest results for Powerball, Ozlotto, Gold, Toto and 4D.             |
#|                                                                                          |
#|        LottoResult <- function(resNum=1, ...) {                                          |
#|        #---  Assert TWO (2) arguments:                                                   |
#|        #       resNum:       the latest N results (default: 1)                           |
#|        #       lottoStr:     optionally specify ANY of "powerball", "ozlotto",           |
#|        #                     "satlotto", "wedlotto", "toto", AND/OR "4d" (default: ALL)  |
#|        }                                                                                 |
#|                                                                                          |
#| Assert History                                                                           |
#|  1.0.1   Incorporated 4D results into the FIVE (5) external functions, including the new |
#|          function LottoResult(). Fixed the missing Supplementary Number in the toto      |
#|          results file. Completed FOUR (4) internal 4D functions: lotto4DResultChr(),     |
#|          lotto4DDrawDte(), lotto4DUpdateNum() and lotto4DSplitMtx().                     |
#|                                                                                          |
#|  1.0.0   This library contains external R functions to update, summarize, analyze, and   |
#|          forecast lotto results. The FOUR (4) external functions are LottoUpdate(),      |
#|          LottoArimaSummary(), LottoArimaConf(), and Lotto(). There are also several      |
#|          internal R functions: lottoTotoResultNum(), lottoTotoDrawDte(),                 |
#|          lottoTotoUpdateNum(), lottoTattsUpdateNum(), lottoArimaNum(),                   |
#|          lottoPowerSplitMtx(), lottoOzSplitMtx(), lottoWriteCsv(), and lottoReadDfr().   |
#|          Planned: Incorporate 4D results into the FOUR (4) external functions. There are |
#|          TWO (2) uncompleted 4D functions: lotto4DResultNum(), and lotto4DUpdateNum().   |
#|          Planned: Add ONE (1) external function LottoResult() to display latest results. |
#|          However, the toto results file is missing the Supplementary Number.             |
#|------------------------------------------------------------------------------------------|
library(forecast)
library(XML)
library(R.utils)

#|------------------------------------------------------------------------------------------|
#|                            E X T E R N A L   F U N C T I O N S                           |
#|------------------------------------------------------------------------------------------|
Lotto <- function(lottoStr, ticketNum=12, startNum=1)
{
  #---  Assert TWO (2) arguments:                                                   
  #       lottoStr:     MUST specify EITHER "powerball", "ozlotto", "satlotto", "wedlotto",
  #                     "toto", OR "4d"
  #       ticketNum:    integer value to specify number of tickets                 
  
  #---  Check that arguments are valid
  typeStr <- c("powerball", "ozlotto", "satlotto", "wedlotto", "toto", "4d")
  if( length(which(typeStr==lottoStr)) == 0 )
    stop("lottoStr MUST be either: powerball, ozlotto, satlotto, wedlotto, toto OR 4d")
  if( as.numeric(ticketNum) < 1 ) 
    stop("ticketNum MUST be greater than OR equal to ONE (1)")

  #---  Draw mechanism
  #       (1) Power draws Number 1-5 from same pool, then powerball from another pool
  #       (2) Gold (sat and wed) AND Toto draw Number 1-6 from same pool
  #       (3) Oz draws Number 1-7 from same pool
  #       (4) 4d draws Digit 1-4 EACH from DIFFERENT pools (i.e duplicates allowed)
  if(lottoStr == "powerball")
    dupCol <- 1:5
  if(lottoStr == "satlotto")
    dupCol <- 1:6
  if(lottoStr == "wedlotto")
    dupCol <- 1:6
  if(lottoStr == "toto")
    dupCol <- 1:6
  if(lottoStr == "ozlotto")
    dupCol <- 1:7
  if(lottoStr == "4d")
    dupCol <- 1:1
  
  #---  Call the ARIMA function to get a confidence data frame
  confDfr <- LottoArimaConf(lottoStr, startNum)
  
  sRow <- nrow(confDfr)
  
  #---  There are TWO (2) criteria for EACH ticket
  #       (1) the individual numbers must be within the upper and lower bound
  #       (2) the sum of numbers must be within the upper and lower bound
  #       (3) there must not be duplicated numbers within EACH row
  outMtx <- matrix(nrow = 0, ncol = sRow-1)
  while( length(outMtx) <= 0 )
  {
    tmpMtx <- matrix(nrow=ticketNum, ncol=sRow-1)
    #---  Check for condition (1)
    for(n in 1:ncol(tmpMtx))
    {
      tmpMtx[, n] <- round(runif(ticketNum, min=confDfr[n,1], max=confDfr[n,2]))
    }
    
    #---  Check for condition (2)
    sumNum <- apply(tmpMtx, 1, sum)
    if( length(sumNum[sumNum >= confDfr[sRow,1]]) == ticketNum && 
        length(sumNum[sumNum <= confDfr[sRow,2]]) == ticketNum )
    {
      #---  Check for condition (3)
      if( length(dupCol) > 1 )
      {
        dupNum <- apply(tmpMtx[ ,dupCol], 1, anyDuplicated)
        if( sum(dupNum) == 0 ) outMtx <- tmpMtx
      }
      else
        outMtx <- tmpMtx
    }
  }
  if( lottoStr == "4d" )
    paste0(outMtx[,1], outMtx[,2], outMtx[,3], outMtx[,4])
  else
    outMtx
}  

LottoUpdate <- function(silent=TRUE)
{
  #---  Assert ONE (1) arguments:                                                   
  #       silent:     Do not display print messages (default: FALSE)

  #---  Update the result files
  typeStr <- c("powerball", "ozlotto", "satlotto", "wedlotto", "toto", "4d")
  for( lottoStr in typeStr )
  {
    if( lottoStr == "toto" )
      updNum <- lottoTotoUpdateNum(silent=silent)
    else if( lottoStr == "4d" )
      updNum <- lotto4DUpdateNum(silent=silent)
    else 
      updNum <- lottoTattsUpdateNum(lottoStr)
    if( updNum == 0 ) 
      msgStr = paste("The ", lottoStr, " file is the latest.", sep="")
    else
      msgStr = paste("Updated ", updNum, " result(s) for ", lottoStr, " file.", sep="")
    print(msgStr)
  }
}

LottoArimaSummary <- function(startNum=1)
{
  #---  Assert ONE (1) arguments:                                                   
  #       startNum:     the start row that is used in forecast (default: 1)                 
  
  #---  Check that arguments are valid
  typeStr <- c("powerball", "ozlotto", "satlotto", "wedlotto", "toto", "4d")
  if( as.numeric(startNum) < 1 & as.numeric(startNum) > 10 ) 
    stop("startNum MUST be between ONE (1) and TEN (10)")

  #---  Compute power of odds
  pwrNum <- c( 45*factorial(45)/factorial(40)/lottoArimaNum("powerball", startNum),
               factorial(45)/factorial(38)/lottoArimaNum("ozlotto", startNum),
               factorial(45)/factorial(39)/lottoArimaNum("satlotto", startNum),
               factorial(45)/factorial(39)/lottoArimaNum("wedlotto", startNum),
               factorial(45)/factorial(39)/lottoArimaNum("toto", startNum),
               10000/lottoArimaNum("4d", startNum) )
               
  data.frame(lotto=typeStr, power=round(pwrNum,1))
}

LottoArimaConf <- function(lottoStr, startNum=1)
{
  #---  Assert TWO (2) arguments:                                                   
  #       lottoStr:     MUST specify EITHER "powerball", "ozlotto", "satlotto", "wedlotto", "toto", OR "4d"
  #       startNum:     the start row that is used in forecast (default: 1)                 
  
  #---  Check that arguments are valid
  typeStr <- c("powerball", "ozlotto", "satlotto", "wedlotto", "toto", "4d")
  if( length(which(typeStr==lottoStr)) == 0 )
    stop("lottoStr MUST be either: powerball, ozlotto, satlotto, wedlotto, toto OR 4d")
  if( as.numeric(startNum) < 1 & as.numeric(startNum) > 10 ) 
    stop("startNum MUST be between ONE (1) and TEN (10)")
  
  #---  Init loading data
  #       (1) Power, Gold (sat and wed), and Toto uses SIX (6) numbers
  #       (2) Oz uses SEVEN (7) numbers
  rawDfr <- lottoReadDfr(lottoStr)
  rawDfr <- rawDfr[startNum:nrow(rawDfr), ]
  if(lottoStr == "powerball")
    rawMtx <- lottoPowerSplitMtx( rawDfr )
  if(lottoStr == "satlotto")
    rawMtx <- lottoPowerSplitMtx( rawDfr )
  if(lottoStr == "wedlotto")
    rawMtx <- lottoPowerSplitMtx( rawDfr )
  if(lottoStr == "toto")
    rawMtx <- lottoPowerSplitMtx( rawDfr )
  if(lottoStr == "ozlotto")
    rawMtx <- lottoOzSplitMtx( rawDfr )
  if(lottoStr == "4d")
    rawMtx <- lotto4DSplitMtx( rawDfr )

  rawMtx <- rawMtx[complete.cases(rawMtx), ]
  colNum <- ncol(rawMtx)
  #---  Compute min, max and sum
  if(lottoStr == "4d")
    minNum <- rep.int(0, colNum)
  else
    minNum <- rep.int(1, colNum)
  maxNum <- apply(rawMtx, 2, max)
  rawMtx <- cbind(rawMtx, apply(rawMtx, 1, sum))
  
  #--- fit MA on individual numbers and forecast for ONE (1) look ahead
  #       compute the confidence for EACH number
  upperNum <- numeric(0)
  lowerNum <- numeric(0)
  for (i in 1:ncol(rawMtx))
  {
    #---  Compute difNum, which is a vector of differences between the rows
    #       E.g. difNum[1] = row[1] - row[2]
    difNum <- -diff(rawMtx[ ,i])
    
    #---  Fit MA on diff and forecast for ONE (1) look ahead
    dif.arima <- suppressWarnings(auto.arima(difNum, max.p=0))
    dif.forecast <- forecast(dif.arima, h=1)
    
    #---  Rearrange the formula for difNum, and compute the new row and confidence, 
    #       based on the diff forecast
    #       row[0] = difNum[0] + row[1]
    upperNum <- c(upperNum, max(forecast(dif.arima, h=1)$upper) + rawMtx[1, i])
    lowerNum <- c(lowerNum, min(forecast(dif.arima, h=1)$lower) + rawMtx[1, i])
  }
  
  foreDfr <- data.frame(lower=lowerNum, upper=upperNum)
  foreDfr$lower <- round(foreDfr$lower)
  foreDfr$upper <- trunc(foreDfr$upper)
  for (i in 1:colNum)
  {
    foreDfr[i, 1] <- max(foreDfr[i, 1], minNum[i])
    foreDfr[i, 2] <- min(foreDfr[i, 2], maxNum[i])
  }
  foreDfr
}

LottoResult <- function( resNum=1, ...)
{
  #---  Assert TWO (2) arguments:                                                   
  #       resNum:       the number of results to display (default: 1)                 
  #       ...:          optionally specify ANY of "powerball", "ozlotto", "satlotto", 
  #                     "wedlotto", "toto", AND/OR "4d" (default: ALL)
  
  #---  Check that arguments are valid
  userStr <- c(...)
  typeStr <- c("powerball", "ozlotto", "satlotto", "wedlotto", "toto", "4d")
  for( lottoStr in userStr )
  {
    if( length(which(typeStr==lottoStr)) == 0 )
      stop("lottoStr MUST be ANY: powerball, ozlotto, satlotto, wedlotto, toto, AND/OR 4d")
  }
  if( as.numeric(resNum) < 1 ) 
    stop("resNum MUST be greater than OR equal to ONE (1)")
  
  #---  Update the result files
  if( length(userStr) > 0 ) typeStr <- userStr
  
  #---  Result format is a data frame
  for( lottoStr in typeStr )
  {
    nameStr <- c("Draw No", "Draw Date")
    if(lottoStr == "powerball")
    {
      resCol <- 1:8
      nameStr <- c(nameStr, "Number", "Num", "Num", "Num", "Num", "Powerball")
    }
    if(lottoStr == "satlotto")
    {
      resCol <- 1:10
      nameStr <- c(nameStr, "Number", "Num", "Num", "Num", "Num", "Num", "Supplement", "Supp")
    }
    if(lottoStr == "wedlotto")
    {
      resCol <- 1:10
      nameStr <- c(nameStr, "Number", "Num", "Num", "Num", "Num", "Num", "Supplement", "Supp")
    }
    if(lottoStr == "toto")
    {
      resCol <- 1:9
      nameStr <- c(nameStr, "Number", "Num", "Num", "Num", "Num", "Num", "Additional")
    }
    if(lottoStr == "ozlotto")
    {
      resCol <- 1:11
      nameStr <- c(nameStr, "Number", "Num", "Num", "Num", "Num", "Num", "Num", "Supplement", "Supp")
    }
    if(lottoStr == "4d")
    {
      resCol <- 1:15
      re2Col <- 16:25
      nameStr <- c(nameStr, "First Prize", "2nd", "3rd", "Starter", "Sta", "Sta", "Sta", "Sta",
                   "Sta", "Sta", "Sta", "Sta", "Sta")
      nam2Str <- c("Consolation", "Con", "Con", "Con", "Con", "Con", "Con", "Con", "Con", "Con")
      
      rawDfr <- lottoReadDfr( lottoStr )
      ra2Dfr <- rawDfr[, re2Col]
      rawDfr <- rawDfr[, resCol]
      names( rawDfr ) <- nameStr
      names( ra2Dfr ) <- nam2Str
      print( toupper(lottoStr), row.names=FALSE )
      print( rawDfr[1:resNum,], row.names=FALSE )
      print( ra2Dfr[1:resNum,], row.names=FALSE )
    }
    else
    {
      rawDfr <- lottoReadDfr( lottoStr )
      rawDfr <- rawDfr[, resCol]
      names( rawDfr ) <- nameStr
      print( toupper(lottoStr), row.names=FALSE )
      print( rawDfr[1:resNum,], row.names=FALSE )
    }
  }
}

#|------------------------------------------------------------------------------------------|
#|                            I N T E R N A L   F U N C T I O N S                           |
#|------------------------------------------------------------------------------------------|
lotto4DResultChr <- function( drawNum )
{
  retNum <- numeric(0)
  urlStr <- paste("http://www.singaporepools.com.sg/Lottery?page=wc10_four_d_past&drawNo=",
                  drawNum, sep="")
  toto.HTML <- htmlParse(urlStr)
  toto.HTMLTable <- readHTMLTable(toto.HTML)

  if( length(toto.HTMLTable) < 8 ) return( retNum )
  winDfr <- toto.HTMLTable[[6]]
  topChr <- levels( reorder(winDfr[ ,2], 1:3) )
  winDfr <- toto.HTMLTable[[7]]
  starter1Chr <- levels(winDfr[ ,1])[1:5] 
  starter2Chr <- levels(winDfr[ ,2])[1:5] 
  winDfr <- toto.HTMLTable[[8]]
  consol1Chr <- levels(winDfr[ ,1])[1:5] 
  consol2Chr <- levels(winDfr[ ,2])[1:5] 
  if( !is.na(topChr[1]) & !is.na(topChr[2]) & !is.na(topChr[3]) & !is.na(starter1Chr[1]) &
    !is.na(starter1Chr[2]) & !is.na(starter1Chr[3]) & !is.na(starter1Chr[4]) & 
    !is.na(starter1Chr[5]) & !is.na(starter2Chr[1]) & !is.na(starter2Chr[2]) & 
    !is.na(starter2Chr[3]) & !is.na(starter2Chr[4]) & !is.na(starter2Chr[5]) &
    !is.na(consol1Chr[1]) & !is.na(consol1Chr[2]) & !is.na(consol1Chr[3]) &
    !is.na(consol1Chr[4]) & !is.na(consol1Chr[5]) & !is.na(consol2Chr[1]) &
    !is.na(consol2Chr[2]) & !is.na(consol2Chr[3]) & !is.na(consol2Chr[4]) &
    !is.na(consol2Chr[5]) )
  {
    retNum <- c( topChr, starter1Chr, starter2Chr, consol1Chr, consol2Chr )
  }
  retNum
}

lotto4DDrawDte <- function( drawNum )
{
  retDte <- NULL
  urlStr <- paste("http://www.singaporepools.com.sg/Lottery?page=wc10_four_d_past&drawNo=",
                  drawNum, sep="")
  toto.HTML <- htmlParse(urlStr)
  toto.HTMLTable <- readHTMLTable(toto.HTML)
  
  if( length(toto.HTMLTable) < 5 ) return( retDte )
  dateDfr <- toto.HTMLTable[[5]]
  #---  Sometimes the date appear in 14th element
  regChr <- "[0-9]{2} (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) [0-9]{2}"
  dateChr <- levels(dateDfr[ ,1])[15]
  if( length(grep(regChr, dateChr))==0 )
    dateChr <- levels(dateDfr[ ,1])[14]
  r <- regexpr(regChr, dateChr)
  retDte <- as.Date(regmatches(dateChr, r), "%d %b %y")
  
  retDte
}

lottoTotoResultNum <- function( drawNum )
{
  retNum <- numeric(0)
  urlStr <- paste("http://www.singaporepools.com.sg/Lottery?page=wc10_toto_past&drawNo=",
                  drawNum, sep="")
  toto.HTML <- htmlParse(urlStr)
  toto.HTMLTable <- readHTMLTable(toto.HTML)

  if( length(toto.HTMLTable) < 10 ) return( retNum )
  winDfr <- toto.HTMLTable[[8]]
  num.1 <- as.numeric( levels(winDfr[ ,1])[1] ) 
  num.2 <- as.numeric( levels(winDfr[ ,2])[1] )
  num.3 <- as.numeric( levels(winDfr[ ,3])[1] ) 
  num.4 <- as.numeric( levels(winDfr[ ,4])[1] ) 
  num.5 <- as.numeric( levels(winDfr[ ,5])[1] ) 
  num.6 <- as.numeric( levels(winDfr[ ,6])[1] ) 
  winDfr <- toto.HTMLTable[[10]]
  num.7 <- as.numeric( levels(winDfr[ ,1])[1] )
  if( !is.na(num.1) & !is.na(num.2) & !is.na(num.3) &
      !is.na(num.4) & !is.na(num.5) & !is.na(num.6) & 
      !is.na(num.7) )
  {
    retNum <- c( num.1, num.2, num.3, num.4, num.5, num.6, num.7 )
  }
  retNum
}

lottoTotoDrawDte <- function( drawNum )
{
  retDte <- NULL
  urlStr <- paste("http://www.singaporepools.com.sg/Lottery?page=wc10_toto_past&drawNo=",
                  drawNum, sep="")
  toto.HTML <- htmlParse(urlStr)
  toto.HTMLTable <- readHTMLTable(toto.HTML)
  
  if( length(toto.HTMLTable) < 6 ) return( retDte )
  dateDfr <- toto.HTMLTable[[6]]
  dateChr <- levels(dateDfr[ ,1])[1]
  
  endPos <- nchar(dateChr)
  begPos <- endPos - 7
  retDte <- as.Date(substring(dateChr,begPos,endPos), "%d/%m/%y")
  #retDte <- substring(dateChr,begPos,endPos)
  
  retDte
}

lotto4DUpdateNum <- function( startDrawNum=2771, endDrawNum=9999, silent=TRUE )
{
  fourDfr <- lottoReadDfr("4d")
  if( is.null(fourDfr) )
  {
    fourDfr <- dataFrame( colClasses=c(Draw_number="character", Draw_date="character", 
                                       Number_1="character", Number_2="character",
                                       Number_3="character", Number_4="character",
                                       Number_5="character", Number_6="character", 
                                       Number_7="character", Number_8="character", 
                                       Number_9="character", Number_10="character", 
                                       Number_11="character", Number_12="character", 
                                       Number_13="character", Number_14="character", 
                                       Number_15="character", Number_16="character", 
                                       Number_17="character", Number_18="character", 
                                       Number_19="character", Number_20="character", 
                                       Number_21="character", Number_22="character", 
                                       Number_23="character"), nrow=0 )
  }
  
  if( nrow(fourDfr)>0 )
  {
    #--- Coerce character into numeric or date
    nextDrawNum <- max( suppressWarnings( as.numeric( fourDfr[, 1] ) ) ) + 1
    if( nextDrawNum > startDrawNum ) startDrawNum <- nextDrawNum
  }
  if( startDrawNum > endDrawNum ) return(0)
  
  retNum <- 0
  for( d in startDrawNum:endDrawNum )
  {
    rChr <- lotto4DResultChr(d)
    rDte <- lotto4DDrawDte(d)
    if( length(rChr) == 23 )
    {
      rDfr <- data.frame(d, format(rDte, "%Y/%m/%d"), rChr[1], rChr[2], rChr[3], rChr[4], 
                         rChr[5], rChr[6], rChr[7], rChr[8], rChr[9], rChr[10], rChr[11], 
                         rChr[12], rChr[13], rChr[14], rChr[15], rChr[16], rChr[17], 
                         rChr[18], rChr[19], rChr[20], rChr[21], rChr[22], rChr[23])
      names(rDfr) <- names(fourDfr)
      fourDfr <- rbind(rDfr, fourDfr)
      retNum <- retNum + 1
      if( !silent ) print( paste("Imported 4D draw ", d, sep="") )
    }
    else break
  }
  
  if( retNum > 0 ) 
  {
    formDfr <- as.data.frame(lapply(fourDfr, function(x) if (is(x, "Date")) format(x, "%Y/%m/%d") else x))
    lottoWriteCsv(formDfr, "4d")
  }
  retNum
}

lottoTattsUpdateNum <- function( lottoStr )
{
  #---  Assert TWO (2) arguments:                                                   
  #       lottoStr:     MUST specify EITHER "powerball", "ozlotto", "satlotto", or "wedlotto"
  #       startNum:     the start row that is used in forecast (default: 1)                 
  
  #---  Check that arguments are valid
  typeStr <- c("powerball", "ozlotto", "satlotto", "wedlotto")
  if( length(which(typeStr==lottoStr)) == 0 )
    stop("lottoStr MUST be either: powerball, ozlotto, satlotto, OR wedlotto")

  #---  Download from URL
  if(lottoStr == "powerball")
    urlStr <- "http://www.goldencasket.com/results/results_download_powerball.asp"
  if(lottoStr == "satlotto")
    urlStr <- "http://www.goldencasket.com/results/results_download_gold_lotto.asp?type=sat"
  if(lottoStr == "wedlotto")
    urlStr <- "http://www.goldencasket.com/results/results_download_gold_lotto.asp?type=wed"
  if(lottoStr == "ozlotto")
    urlStr <- "http://www.goldencasket.com/results/results_download_ozlotto.asp"

  #---  There are TWO (2) conditions before updating the file
  #       (1) Download file MUST NOT be empty
  #       (2) Download max draw must be greater than OR equal to next file draw
  newDfr <- read.csv(urlStr)
  if( nrow(newDfr) == 0 ) return(0)
  
  #--- Coerce character into numeric or date
  maxDrawNum <- max( suppressWarnings( as.numeric( newDfr[, 1] ) ) )
  nxtDrawNum <- 1
  
  fileDfr <- lottoReadDfr(lottoStr)
  if( !is.null(fileDfr) )
    nxtDrawNum <- max( suppressWarnings( as.numeric( fileDfr[, 1] ) ) ) + 1
  
  if( maxDrawNum < nxtDrawNum ) return(0)
  else
  {
    formDfr <- as.data.frame(lapply(newDfr, function(x) if (is(x, "Date")) format(x, "%Y/%m/%d") else x))
    lottoWriteCsv(formDfr, lottoStr)
    retNum <- maxDrawNum - nxtDrawNum + 1
  }
  retNum
}

lottoTotoUpdateNum <- function( startDrawNum=2480, endDrawNum=9999, silent=TRUE )
{
  totoDfr <- lottoReadDfr("toto")
  if( is.null(totoDfr) )
  {
    totoDfr <- dataFrame( colClasses=c(Draw_number="character", Draw_date="character", 
                                       Number_1="character", Number_2="character",
                                       Number_3="character", Number_4="character",
                                       Number_5="character", Number_6="character",
                                       Number_7="character"), nrow=0 )
  }
  
  if( nrow(totoDfr)>0 )
  {
    #--- Coerce character into numeric or date
    nextDrawNum <- max( suppressWarnings( as.numeric( totoDfr[, 1] ) ) ) + 1
    if( nextDrawNum > startDrawNum ) startDrawNum <- nextDrawNum
  }
  if( startDrawNum > endDrawNum ) return(0)
  
  retNum <- 0
  for( d in startDrawNum:endDrawNum )
  {
    rNum <- lottoTotoResultNum(d)
    rDte <- lottoTotoDrawDte(d)
    if( length(rNum) == 7 )
    {
      rDfr <- data.frame(d, format(rDte, "%Y/%m/%d"), rNum[1], rNum[2], rNum[3], rNum[4], rNum[5], rNum[6], rNum[7])
      names(rDfr) <- names(totoDfr)
      totoDfr <- rbind(rDfr, totoDfr)
      retNum <- retNum + 1
      if( !silent ) print( paste("Imported toto draw ", d, sep="") )
    }
    else break
  }

  if( retNum > 0 ) 
  {
    formDfr <- as.data.frame(lapply(totoDfr, function(x) if (is(x, "Date")) format(x, "%Y/%m/%d") else x))
    lottoWriteCsv(formDfr, "toto")
  }
  retNum
}

lottoArimaNum <- function(lottoStr, startNum=1)
{
  #---  Assert TWO (2) arguments:                                                   
  #       lottoStr:     MUST specify EITHER "powerball", "ozlotto", "satlotto", "wedlotto", "toto", OR "4d"
  #       startNum:     the start row that is used in forecast (default: 1)                 
  
  #---  Check that arguments are valid
  typeStr <- c("powerball", "ozlotto", "satlotto", "wedlotto", "toto", "4d")
  if( length(which(typeStr==lottoStr)) == 0 )
    stop("lottoStr MUST be either: powerball, ozlotto, satlotto, wedlotto, toto OR 4d")
  if( as.numeric(startNum) < 1 & as.numeric(startNum) > 10 ) 
    stop("startNum MUST be between ONE (1) and TEN (10)")
  
  #---  Call the ARIMA function to get a confidence data frame
  confDfr <- LottoArimaConf(lottoStr, startNum)
  confDfr$range <- confDfr$upper - confDfr$lower + 1
  
  sRow <- nrow(confDfr)
  prod(confDfr[1:sRow-1,3])
}

lotto4DSplitMtx <- function( rawDfr )
{
  #--- Coerce character into numeric or date
  rawDfr[, 1] <- suppressWarnings( as.numeric( rawDfr[, 1] ) )    # Draw number
  rawDfr[, 2] <- as.Date(rawDfr[, 2], "%Y/%m/%d")                 # Draw date
  
  rawDfr <- rawDfr[1:nrow(rawDfr), ]
  topChr <- character(0)
  for( i in 1:nrow(rawDfr) )
  {
    topChr <- rbind(topChr, rawDfr[i,5], rawDfr[i,4], rawDfr[i,3])
  }
  rawMtx <- cbind( as.numeric( substring(topChr, 1, 1) ),
                   as.numeric( substring(topChr, 2, 2) ),
                   as.numeric( substring(topChr, 3, 3) ),
                   as.numeric( substring(topChr, 4, 4) ) )
}

lottoPowerSplitMtx <- function( rawDfr )
{
  #--- Coerce character into numeric or date
  rawDfr[, 1] <- suppressWarnings( as.numeric( rawDfr[, 1] ) )    # Draw number
  rawDfr[, 2] <- as.Date(rawDfr[, 2], "%Y/%m/%d")                 # Draw date
  rawDfr[, 3] <- suppressWarnings( as.numeric( rawDfr[, 3] ) )    # Number 1-5 and Powerball
  rawDfr[, 4] <- suppressWarnings( as.numeric( rawDfr[, 4] ) )    
  rawDfr[, 5] <- suppressWarnings( as.numeric( rawDfr[, 5] ) )    
  rawDfr[, 6] <- suppressWarnings( as.numeric( rawDfr[, 6] ) )    
  rawDfr[, 7] <- suppressWarnings( as.numeric( rawDfr[, 7] ) )    
  rawDfr[, 8] <- suppressWarnings( as.numeric( rawDfr[, 8] ) )    
  
  rawDfr <- rawDfr[1:nrow(rawDfr), ]
  rawMtx <- cbind(rawDfr[, 3],rawDfr[, 4],rawDfr[, 5],rawDfr[, 6],rawDfr[, 7],rawDfr[, 8])
}

lottoOzSplitMtx <- function( rawDfr )
{
  #--- Coerce character into numeric or date
  rawDfr[, 1] <- suppressWarnings( as.numeric( rawDfr[, 1] ) )    # Draw number
  rawDfr[, 2] <- as.Date(rawDfr[, 2], "%Y/%m/%d")                 # Draw date
  rawDfr[, 3] <- suppressWarnings( as.numeric( rawDfr[, 3] ) )    # Number 1-7
  rawDfr[, 4] <- suppressWarnings( as.numeric( rawDfr[, 4] ) )    
  rawDfr[, 5] <- suppressWarnings( as.numeric( rawDfr[, 5] ) )    
  rawDfr[, 6] <- suppressWarnings( as.numeric( rawDfr[, 6] ) )    
  rawDfr[, 7] <- suppressWarnings( as.numeric( rawDfr[, 7] ) )    
  rawDfr[, 8] <- suppressWarnings( as.numeric( rawDfr[, 8] ) )    
  rawDfr[, 9] <- suppressWarnings( as.numeric( rawDfr[, 9] ) )    
  
  rawDfr <- rawDfr[1:nrow(rawDfr), ]
  rawMtx <- cbind(rawDfr[, 3],rawDfr[, 4],rawDfr[, 5],rawDfr[, 6],rawDfr[, 7],rawDfr[, 8],rawDfr[, 9])
}

lottoWriteCsv <- function(datDfr, fileStr, 
                         workDirStr="C:/Users/denbrige/100 FxOption/103 FxOptionVerBack/080 Fx Git/R-nonsource")
{
  #---  Assert THREE (3) arguments:                                                   
  #       datDfr:       data frame to be written                                               
  #       fileStr:      name of the file (without the suffix "_part_xx" and extension ".csv"
  #       workDirStr:   working directory                                             
  
  #---  Set working directory                                                         
  setwd(workDirStr)
  #---  Write data
  #       Remove quotes from characters
  write.table( datDfr, file=paste( fileStr, ".csv", sep="" ), sep=",", quote=FALSE )
}

lottoReadDfr <- function(fileStr, partNum=1, 
                         workDirStr="C:/Users/denbrige/100 FxOption/103 FxOptionVerBack/080 Fx Git/R-nonsource")
{
  #---  Assert THREE (3) arguments:                                                   
  #       fileStr:      name of the file (without the suffix "_part_xx" and extension ".csv"
  #       partNum:      number of parts                                               
  #       workDirStr:   working directory                                             
  #       retDfr:       NULL or a data frame (with partial OR full data)
  
  #---  Check that partNum is valid (between 1 to 999)                                 
  if( as.numeric(partNum) < 1 || as.numeric(partNum) > 999 ) 
    stop("partNum MUST be between 1 AND 999")
  #---  Set working directory                                                         
  setwd(workDirStr)
  #---  Read data from split parts
  #       Append suffix to the fileStr
  #       Read each part and merge them together
  
  if( as.numeric(partNum) > 1 )
  {
    if( !file.exists( paste( fileStr, "_part001.csv", sep="" ) ) ) return( NULL )
    retDfr <- read.csv( paste( fileStr, "_part001.csv", sep="" ), colClasses = "character" )
    
    for( id in 2:partNum )
    {
      #---  rbind() function will bind two data frames with the same header together
      partStr <- paste( fileStr, "_part", sprintf("%03d", as.numeric(id)), ".csv", sep="" )
      if( !file.exists( partStr ) ) break
      tmpDfr <- read.csv( partStr, colClasses = "character")
      retDfr <- rbind( retDfr, tmpDfr )
    }
  }
  else
  {
    if( !file.exists( paste( fileStr, ".csv", sep="" ) ) ) return( NULL )
    retDfr <- read.csv( paste( fileStr, ".csv", sep="" ), colClasses = "character" )
  }
  
  #---  Return a data frame
  return(retDfr)
}

#|------------------------------------------------------------------------------------------|
#|                                E N D   O F   S C R I P T                                 |
#|------------------------------------------------------------------------------------------|
