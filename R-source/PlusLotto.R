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
#|        Lotto <- function(lottoStr, ticketNum, startNum) {                                |
#|        #---  Assert THREE (3) arguments:                                                 |
#|        #       lottoStr:    MUST specify EITHER "powerball", "ozlotto", "satlotto",      |
#|        #                   "wedlotto", OR "toto"                                         |
#|        #       ticketNum:   integer value to specify number of tickets (default: 12)     |
#|        #       startNum:    the start row that is used in forecast (default: 1)          |
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
#|        LottoArimaSummary <- function(startNum) {                                         |
#|        #---  Assert ONE (1) arguments:                                                   |
#|        #       startNum:     the start row that is used in forecast (default: 1)         |
#|        }                                                                                 |  
#|                                                                                          |
#|    (4) Display a table of confidence intervals for each number, based on ARIMA(q)        |
#|                                                                                          |
#|        LottoArimaConf <- function(lottoStr, startNum) {                                  |
#|        #---  Assert TWO (2) arguments:                                                   |
#|        #       lottoStr:     MUST specify EITHER "powerball", "ozlotto", "satlotto",     |
#|        #                     "wedlotto", OR "toto"                                       |
#|        #       startNum:     the start row that is used in forecast (default: 1)         |
#|        }                                                                                 |
#|                                                                                          |
#|    (5) Display the latest results for Powerball, Ozlotto, Gold, Toto and 4D.             |
#|                                                                                          |
#|        LottoResult <- function(..., resNum) {                                            |
#|        #---  Assert TWO (2) arguments:                                                   |
#|        #       ...:          optionally specify ANY of "powerball", "ozlotto",           |
#|        #                     "satlotto", "wedlotto", "toto", AND/OR "4d" (default: ALL)  |
#|        #       resNum:       the latest N results (default: 1)                           |
#|        }                                                                                 |
#|                                                                                          |
#|    (6) Forecast a set of Powerball, OzLotto, Gold, Toto or 4D system numbers, based on   |
#|        ARIMA(q).                                                                         |
#|                                                                                          |
#|        LottoSystem <- function(systemNum, lottoStr, ticketNum, startNum) {               |
#|        #---  Assert FOUR (4) arguments:                                                  |
#|        #       systemNum:   MUST be an integer between SEVEN (7) and TWELVE (12)         |
#|        #       lottoStr:    MUST specify EITHER "powerball", "ozlotto", "satlotto",      |
#|        #                    "wedlotto", OR "toto"                                        |
#|        #       ticketNum:   integer value to specify number of tickets (default: 12)     |
#|        #       startNum:    the start row that is used in forecast (default: 1)          |
#|        }                                                                                 |
#|                                                                                          |
#|    (7) Forecast a standard set of numbers for ALL/ANY lotto games, based on ARIMA(q).    |
#|                                                                                          |
#|        LottoStandard <- function(..., ticketNum, startNum) {                             |
#|        #---  Assert THREE (3) arguments:                                                 |
#|        #       ...:          optionally specify ANY of "powerball", "ozlotto",           |
#|        #                     "satlotto", "wedlotto", "toto", AND/OR "4d" (default: ALL)  |
#|        #       ticketNum:   integer value to specify number of tickets (default: 12)     |
#|        #       startNum:    the start row that is used in forecast (default: 1)          |
#|        }                                                                                 |
#|                                                                                          |
#|    (8) Display the next available draw dates for ALL/ANY lotto games.                    |
#|                                                                                          |
#|        LottoDraw <- function(..., startNum) {                                            |
#|        #---  Assert TWO (2) arguments:                                                   |
#|        #       ...:          optionally specify ANY of "powerball", "ozlotto",           |
#|        #                     "satlotto", "wedlotto", "toto", AND/OR "4d" (default: ALL)  |
#|        #       startNum:    the start row that is used in forecast (default: 1)          |
#|        }                                                                                 |
#|                                                                                          |
#| Assert History                                                                           |
#|  1.0.9   Added 80% confidence interval to functions LottoArimaSummary() and              |
#|          LottoArimaConf().                                                               |
#|  1.0.8   Minor fix to function lottoArimaNum() so that computed power CANNOT be LESS     |
#|          THAN ONE (1).                                                                   |
#|  1.0.7   Major changes to the inputs to the auto.arima() function. First, we use the     |
#|          diff(log(data)) instead of the diff(data) as input, as this reduces the AIC     |
#|          to about ONE-THIRD (1/3). Second, we use a zoo object instead of a matrix as    |
#|          input to ensure that the time series is in the correct order when using the     |
#|          forecast() function. Third, we added a new parameter, c80Bln, in FOUR (4)       |
#|          external functions Lotto(), LottoSystem(), LottoArimaSummary(), and             |
#|          LottoArimaConf() and internal function lottoArimaConfZooDfr(), to select either |
#|          EIGHTY (80%) percent or NINETY-FIVE (95%) percent confidence interval           |
#|          (default: 95%). We maintain compatibility by adding new internal functions      |
#|          lottoPowerSplitZoo(), lottoOzSplitZoo(), lotto4DSplitZoo(), and                 |
#|          lottoRandSplitZoo(). Added test_that() for function lottoArimaConfZooDfr().     |
#|  1.0.6   Incorporated Roulette (r) into several external functions, and added TWO (2)    |
#|          internal functions lottoRandUpdateNum() and lottoRandSplitMtx().                |
#|  1.0.5   Updated function LottoUpdateNum() to return the number of results updated.      |
#|          Changed internal functions lottoUpdateBln() and lottoArimaConfDfr().            |
#|          Created a test script testPlusLotto.R to perform unit tests on functions.       |
#|  1.0.4   Added ONE (1) internal function lottoUpdateBln().                               |
#|  1.0.3   Replaced TWO (2) functions: lottoReadDfr() and lottoWriteCsv() with functions   |
#|          fileReadDfr() and fileWriteCsv(), respectively, from package PlusFile.R.        |
#|  1.0.2   Added THREE (3) external functions: LottoSystem(), LottoStandard(), and         |
#|          LottoDraw(). Using the Gap analysis from Win4D, I have added EIGHT (8)          |
#|          functions: LottoSeqConf(), Lotto4DSeq(), lottoTotoSeqSplitMtx(),                |
#|          lotto4DSeqSplitMtx(), lottoTotoSeqDfr(), lotto4DSeqDfr(), lottoSeqAlongNum(),   |
#|          and lotto4DSystemChr().                                                         |
#|  1.0.1   Incorporated 4D results into the FIVE (5) external functions, including the new |
#|          function LottoResult(). Fixed the missing Supplementary Number in the toto      |
#|          results file. Completed FOUR (4) internal 4D functions: lotto4DResultChr(),     |
#|          lotto4DDrawDte(), lotto4DUpdateNum() and lotto4DSplitMtx().                     |
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
library(gtools)
library(zoo)
source("C:/Users/denbrige/100 FxOption/103 FxOptionVerBack/080 Fx Git/R-source/PlusReg.R")
source("C:/Users/denbrige/100 FxOption/103 FxOptionVerBack/080 Fx Git/R-source/PlusFile.R")

#|------------------------------------------------------------------------------------------|
#|                            E X T E R N A L   F U N C T I O N S                           |
#|------------------------------------------------------------------------------------------|
#|------------------------------------------------------------------------------------------|
#|                          E X T E R N A L   A   F U N C T I O N S                         |
#|------------------------------------------------------------------------------------------|
Lotto <- function(lottoStr, ticketNum=12, startNum=1, c80Bln=FALSE)
{
  #---  Assert TWO (2) arguments:                                                   
  #       lottoStr:     MUST specify EITHER "powerball", "ozlotto", "satlotto", "wedlotto",
  #                     "toto", "4d"
  #       ticketNum:    integer value to specify number of tickets                 
  
  #---  Check that arguments are valid
  typeStr <- c("powerball", "ozlotto", "satlotto", "wedlotto", "toto", "4d", "r")
  if( length(which(typeStr==lottoStr)) == 0 )
    stop("lottoStr MUST be either: powerball, ozlotto, satlotto, wedlotto, toto, OR 4d")
  if( as.numeric(ticketNum) < 1 ) 
    stop("ticketNum MUST be greater than OR equal to ONE (1)")
  
  #---  Draw mechanism
  #       (1) Power draws Number 1-5 from same pool, then powerball from another pool
  #       (2) Gold (sat and wed) draws Number 1-6 from same pool
  #       (3) Toto draws Number 1-6 and Additional Number from same pool
  #       (3) Oz draws Number 1-7 from same pool
  #       (4) 4d draws Digit 1-4 EACH from DIFFERENT pools (i.e duplicates allowed)
  if(lottoStr == "powerball")
    dupCol <- 1:5
  if(lottoStr == "satlotto")
    dupCol <- 1:6
  if(lottoStr == "wedlotto")
    dupCol <- 1:6
  if(lottoStr == "toto")
    dupCol <- 1:7
  if(lottoStr == "ozlotto")
    dupCol <- 1:7
  if(lottoStr == "4d")
    dupCol <- 1:1
  if(lottoStr == "r")
    dupCol <- 1:1
  
  #---  Call the ARIMA function to get a confidence data frame
  confDfr <- LottoArimaConf(lottoStr, startNum, c80Bln=c80Bln)
  
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
        if( nrow(tmpMtx) > 1 )
          dupNum <- apply(tmpMtx[ ,dupCol], 1, anyDuplicated)
        else
          dupNum <- anyDuplicated( tmpMtx[1, dupCol] )
        if( sum(dupNum) == 0 ) outMtx <- tmpMtx
      }
      else
        outMtx <- tmpMtx
    }
  }
  if( lottoStr == "4d" )
    paste0(outMtx[,1], outMtx[,2], outMtx[,3], outMtx[,4])
  else if( lottoStr == "r" )
    outMtx[,1]
  else
    outMtx
}  

LottoSystem <- function(systemNum, lottoStr, ticketNum=12, startNum=1, c80Bln=FALSE)
{
  #---  Assert THREE (3) arguments:
  #       systemNum:    MUST be an integer between SEVEN (7) and TWELVE (12)
  #       lottoStr:     MUST specify EITHER "powerball", "ozlotto", "satlotto", "wedlotto",
  #                     OR "toto"
  #       ticketNum:    integer value to specify number of tickets                 
  
  #---  Check that arguments are valid
  typeStr <- c("powerball", "ozlotto", "satlotto", "wedlotto", "toto")
  if( length(which(typeStr==lottoStr)) == 0 )
    stop("lottoStr MUST be either: powerball, ozlotto, satlotto, wedlotto, OR toto")
  if( as.numeric(ticketNum) < 1 ) 
    stop("ticketNum MUST be greater than OR equal to ONE (1)")
  
  #---  Draw mechanism
  #       (1) Power draws Number 1-5 from same pool, then powerball from another pool
  #       (2) Gold (sat and wed) AND Toto draw Number 1-6 from same pool
  #       (3) Oz draws Number 1-7 from same pool
  #       (4) 4d draws Digit 1-4 EACH from DIFFERENT pools (i.e duplicates allowed)
  if( lottoStr == "ozlotto" | lottoStr == "toto")
    numCol <- 1:7
  else
    numCol <- 1:6
  sysNum <- systemNum - max(numCol)
  if( sysNum < 1 | sysNum > 6 ) 
  {
    if( lottoStr == "ozlotto" | lottoStr == "toto" )
      stop("systemNum MUST be between EIGHT (8) and TWELVE (12)")
    else
      stop("systemNum MUST be between SEVEN (7) and TWELVE (12)")
  }
  
  outMtx <- matrix(nrow = ticketNum, ncol = systemNum)
  perMtx <- permutations(max(numCol), max(numCol))
  lotMtx <- Lotto( lottoStr, ticketNum, startNum, c80Bln=c80Bln )
  for( t in 1:nrow(lotMtx) )
  {
    #---  System mechanism
    #       Get a standard ticket from the Arima model
    #       If there is no intersection, then randomly draw n number
    #       Append n number to the end of ticket for System
    #       Discard the standard ticket and repeat again
    stdMtx <- Lotto( lottoStr, 1, startNum, c80Bln=c80Bln )
    while( length(intersect( stdMtx[1,], lotMtx[t,] )) > 0 )
    {
      stdMtx <- Lotto( lottoStr, 1, startNum, c80Bln=c80Bln )
    }
    idxNum <- round(runif(1, min=1, max=nrow(perMtx)))
    perNum <- perMtx[idxNum, ]
    for( i in 1:sysNum )
    {
      p <- max(numCol)+i
      outMtx[t, p] <- stdMtx[perNum[i]]
    }
    outMtx[t, 1:max(numCol)] <- lotMtx[t, ]
  }
  outMtx
}  

LottoUpdateNum <- function(silent=TRUE)
{
  sNum <- 0
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
    
    sNum <- sNum + updNum
    if( updNum == 0 ) 
      msgStr = paste("The ", lottoStr, " file is the latest.", sep="")
    else
    {
      #---  Sat and Wed lotto are the same lotto
      if( lottoStr == "satlotto" | lottoStr == "wedlotto" ) updNum <- updNum / 2
      msgStr = paste("Updated ", updNum, " result(s) for ", lottoStr, " file.", sep="")
    }
    print(msgStr)
  }
  sNum
}

LottoArimaSummary <- function(startNum=1, c80Bln=FALSE)
{
  #---  Assert ONE (1) arguments:                                                   
  #       startNum:     the start row that is used in forecast (default: 1)                 
  
  #---  Check that arguments are valid
  typeStr <- c("powerball", "ozlotto", "satlotto", "wedlotto", "toto", "4d")
  if( as.numeric(startNum) < 1 | as.numeric(startNum) > 10 ) 
    stop("startNum MUST be between ONE (1) and TEN (10)")
  
  #---  Compute power of odds
  pwrNum <- c( 45*factorial(45)/factorial(40)/lottoArimaNum("powerball", startNum, c80Bln),
               factorial(45)/factorial(38)/lottoArimaNum("ozlotto", startNum, c80Bln),
               factorial(45)/factorial(39)/lottoArimaNum("satlotto", startNum, c80Bln),
               factorial(45)/factorial(39)/lottoArimaNum("wedlotto", startNum, c80Bln),
               factorial(45)/factorial(38)/lottoArimaNum("toto", startNum, c80Bln),
               10000/lottoArimaNum("4d", startNum, c80Bln) )
  
  data.frame(lotto=typeStr, power=round(pwrNum,1))
}

LottoArimaConf <- function(lottoStr, startNum=1, c80Bln=FALSE)
{
  #---  Assert TWO (2) arguments:                                                   
  #       lottoStr:     MUST specify EITHER "powerball", "ozlotto", "satlotto", "wedlotto", "toto" OR "4d"
  #       startNum:     the start row that is used in forecast (default: 1)                 
  
  #---  Check that arguments are valid
  typeStr <- c("powerball", "ozlotto", "satlotto", "wedlotto", "toto", "4d", "r")
  if( length(which(typeStr==lottoStr)) == 0 )
    stop("lottoStr MUST be either: powerball, ozlotto, satlotto, wedlotto, toto OR 4d")
  if( as.numeric(startNum) < 1 | as.numeric(startNum) > 10 ) 
    stop("startNum MUST be between ONE (1) and TEN (10)")
  
  #---  Init loading data
  #       (1) Power, Gold (sat and wed), and Toto uses SIX (6) numbers
  #       (2) Toto7 and Oz uses SEVEN (7) numbers
  rawDfr <- fileReadDfr(lottoStr)
  rawDfr <- rawDfr[startNum:nrow(rawDfr), ]
  if(lottoStr == "powerball")
    rawZoo <- lottoPowerSplitZoo( rawDfr )
  if(lottoStr == "satlotto")
    rawZoo <- lottoPowerSplitZoo( rawDfr )
  if(lottoStr == "wedlotto")
    rawZoo <- lottoPowerSplitZoo( rawDfr )
  if(lottoStr == "toto")
    rawZoo <- lottoOzSplitZoo( rawDfr )
  if(lottoStr == "ozlotto")
    rawZoo <- lottoOzSplitZoo( rawDfr )
  if(lottoStr == "4d")
    rawZoo <- lotto4DSplitZoo( rawDfr )
  if(lottoStr == "r")
    rawZoo <- lottoRandSplitZoo( rawDfr )
  
  #---  Compute min, max and sum confidence intervals
  if(lottoStr == "4d" | lottoStr == "r")
    ret.list <- lottoArimaConfZooDfr(rawZoo, 0, c80Bln=c80Bln)
  else
    ret.list <- lottoArimaConfZooDfr(rawZoo, 1, c80Bln=c80Bln)
  
  #---  Return an object of class Lotto, which includes confDfr
  #
  ret.Lotto <- list("call" = match.call(),
                    "conf_95" = ret.list$conf_95_Dfr,
                    "conf_80" = ret.list$conf_80_Dfr
                    )
  
  class(ret.Lotto) <- "Lotto"
  ret.Lotto
}

#|------------------------------------------------------------------------------------------|
#|                          E X T E R N A L   B   F U N C T I O N S                         |
#|------------------------------------------------------------------------------------------|
LottoResult <- function( ..., resNum=1 )
{
  #---  Assert TWO (2) arguments:                                                   
  #       resNum:       the number of results to display (default: 1)                 
  #       ...:          optionally specify ANY of "powerball", "ozlotto", "satlotto", 
  #                     "wedlotto", "toto", AND/OR "4d" (default: ALL)
  
  #---  Check that arguments are valid
  userStr <- c(...)
  typeStr <- c("powerball", "ozlotto", "satlotto", "wedlotto", "toto", "4d", "r")
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
    if(lottoStr == "r")
    {
      resCol <- 1:3
      nameStr <- c(nameStr, "Number")
    }
    if(lottoStr == "4d")
    {
      resCol <- 1:15
      re2Col <- 16:25
      nameStr <- c(nameStr, "First Prize", "2nd", "3rd", "Starter", "Sta", "Sta", "Sta", "Sta",
                   "Sta", "Sta", "Sta", "Sta", "Sta")
      nam2Str <- c("Consolation", "Con", "Con", "Con", "Con", "Con", "Con", "Con", "Con", "Con")
      
      rawDfr <- fileReadDfr( lottoStr )
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
      rawDfr <- fileReadDfr( lottoStr )
      if( !is.null(rawDfr) )
      {
        resNum <- min(resNum, nrow(rawDfr))
        rawDfr <- rawDfr[, resCol]
        names( rawDfr ) <- nameStr
        print( toupper(lottoStr), row.names=FALSE )
        print( rawDfr[1:resNum,], row.names=FALSE )
      }
    }
  }
}

LottoDraw <- function( ..., startNum=1)
{
  #---  Assert ONE (1) arguments:                                                   
  #       ...:          optionally specify ANY of "powerball", "ozlotto", "satlotto", 
  #                     "wedlotto", "toto", AND/OR "4d" (default: ALL)
  #       startNum:     the start row that is used in forecast (default: 1)                 
  
  #---  Check that arguments are valid
  userStr <- c(...)
  typeStr <- c("powerball", "ozlotto", "satlotto", "wedlotto", "toto", "4d")
  for( lottoStr in userStr )
  {
    if( length(which(typeStr==lottoStr)) == 0 )
      stop("lottoStr MUST be ANY: powerball, ozlotto, satlotto, wedlotto, toto, AND/OR 4d")
  }
  if( as.numeric(startNum) < 1 | as.numeric(startNum) > 10 ) 
    stop("startNum MUST be between ONE (1) and TEN (10)")
  
  if( length(userStr) > 0 ) typeStr <- userStr
  dayChr <- c("Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat")
  
  #---  Display next draw date
  for( lottoStr in typeStr )
  {
    nameStr <- c("Draw Date", "")
    drawChr <- lottoDrawDateChr(lottoStr, startNum)
    drawNum <- as.POSIXlt(as.Date(drawChr, "%Y/%m/%d"))$wday
    rawDfr <- data.frame( drawChr, dayChr[drawNum+1] )
    names( rawDfr ) <- nameStr
    
    print( toupper(lottoStr), row.names=FALSE )
    print( rawDfr, row.names=FALSE )
  }
}

LottoStandard <- function( ..., ticketNum=12, startNum=1 )
{
  #---  Assert THREE (3) arguments:                                                   
  #       ...:          optionally specify ANY of "powerball", "ozlotto", "satlotto", 
  #                     "wedlotto", "toto", AND/OR "4d" (default: ALL)
  #       ticketNum:    integer value to specify number of tickets                 
  #       startNum:     the start row that is used in forecast (default: 1)                 
  
  #---  Check that arguments are valid
  if( as.numeric(ticketNum) < 1 ) 
    stop("ticketNum MUST be greater than OR equal to ONE (1)")
  if( as.numeric(startNum) < 1 | as.numeric(startNum) > 10 ) 
    stop("startNum MUST be between ONE (1) and TEN (10)")
  userStr <- c(...)
  typeStr <- c("powerball", "ozlotto", "satlotto", "wedlotto", "toto", "4d")
  for( lottoStr in userStr )
  {
    if( length(which(typeStr==lottoStr)) == 0 )
      stop("lottoStr MUST be ANY: powerball, ozlotto, satlotto, wedlotto, toto, AND/OR 4d")
  }
  
  #---  Display next draw date
  for( lottoStr in typeStr )
  {
    print( toupper(lottoStr), row.names=FALSE )
    print( Lotto(lottoStr, ticketNum, startNum), row.names=FALSE )
  }
}

#|------------------------------------------------------------------------------------------|
#|                          E X T E R N A L   C   F U N C T I O N S                         |
#|------------------------------------------------------------------------------------------|
Lotto4DSeq <- function( numChr, seqDfr )
{
  topChr <- character(0)
  for( i in 1:length(numChr) )
  {
    #---  Call the Search Time function for EACH number
    tNum <- lottoSeqAlongNum( "4d", numChr[i] )[1:6]
    if( !is.na(tNum[1]) & !is.na(tNum[2]) & !is.na(tNum[3]) &
      !is.na(tNum[4]) & !is.na(tNum[5]) & !is.na(tNum[6]) )
    { 
      sumNum <- tNum[1]+tNum[2]+tNum[3]+tNum[4]+tNum[5]+tNum[6]
      if( tNum[1] >= seqDfr[1,1] & tNum[1] <= seqDfr[1,2] &
        tNum[2] >= seqDfr[2,1] & tNum[2] <= seqDfr[2,2] &
        tNum[3] >= seqDfr[3,1] & tNum[3] <= seqDfr[3,2] &
        tNum[4] >= seqDfr[4,1] & tNum[4] <= seqDfr[4,2] &
        tNum[5] >= seqDfr[5,1] & tNum[5] <= seqDfr[5,2] &
        tNum[6] >= seqDfr[6,1] & tNum[6] <= seqDfr[6,2] &
        sumNum >= seqDfr[7,1] & sumNum <= seqDfr[7,2] )
      {
        topChr <- rbind(topChr, numChr[i] )
      }     
    }
  }
  topChr
}

LottoSeqConf <- function( lottoStr, startNum=1 )
{
  #---  Check that arguments are valid
  typeStr <- c("powerball", "ozlotto", "satlotto", "wedlotto", "toto", "4d")
  if( length(which(typeStr==lottoStr)) == 0 )
    stop("lottoStr MUST be either: powerball, ozlotto, satlotto, wedlotto, toto OR 4d")
  
  rawDfr <- fileReadDfr( lottoStr )
  rawDfr <- rawDfr[startNum:nrow(rawDfr), ]
  
  #---  Generate a matrix of time differences
  if( lottoStr == "toto" )
    rawMtx <- lottoTotoSeqSplitMtx( rawDfr )
  if( lottoStr == "4d" )
    rawMtx <- lotto4DSeqSplitMtx( rawDfr )
  
  #---  Call the ARIMA function to get a confidence data frame
  confDfr <- lottoArimaConfDfr( rawMtx, 1 )
  confDfr
}

#|------------------------------------------------------------------------------------------|
#|                            I N T E R N A L   F U N C T I O N S                           |
#|------------------------------------------------------------------------------------------|
#|------------------------------------------------------------------------------------------|
#|                          I N T E R N A L   A   F U N C T I O N S                         |
#|------------------------------------------------------------------------------------------|
lottoArimaConfDfr <- function( rawMtx, lNum, uNum=NULL )
{
  #---  Assert THREE (3) arguments:                                                   
  #       rawMtx:       a numeric matrix with at least (3 rows x 1 col) to be forecasted
  #       lNum:         a numeric vector containing lower bounds                 
  #       uNum:         a numeric vector containing upper bounds (default: NULL)                 
  
  #---  Check that arguments are valid
  if( is.null(rawMtx) )
    stop("rawMtx MUST be a numeric matrix with at least (3 rows x 1 col) to be forecasted")
  if( RegIsEmptyBln(rawMtx) )
    stop("rawMtx MUST be a numeric matrix with at least (3 rows x 1 col) to be forecasted")
  if( is.null(ncol(rawMtx)) )
    stop("rawMtx MUST be a numeric matrix with at least (3 rows x 1 col) to be forecasted")
  if( ncol(rawMtx)==0 )
    stop("rawMtx MUST be a numeric matrix with at least (3 rows x 1 col) to be forecasted")
  if( nrow(rawMtx)<3 )
    stop("rawMtx MUST be a numeric matrix with at least (3 rows x 1 col) to be forecasted")
  if( is.null(lNum) )
    stop("lNum MUST be a numeric vector containing lower bounds")
  if( RegIsEmptyBln(lNum) )
    stop("lNum MUST be a numeric vector containing lower bounds")
  if( length(lNum)>1 & length(lNum)!=ncol(rawMtx) )
    stop("lNum MUST be a numeric vector of length EQUAL to number of columns in the matrix")
  if( !is.null(uNum) )
    if( RegIsEmptyBln(uNum) )
      stop("uNum MUST be a numeric vector containing upper bounds")
  if( length(uNum)>1 & length(uNum)!=ncol(rawMtx) )
    stop("uNum MUST be a numeric vector of length EQUAL to number of columns in the matrix")
  if( ncol(rawMtx)>1 )
    rawMtx <- rawMtx[complete.cases(rawMtx), ]
  else
    rawMtx <- na.omit(rawMtx)
  if( nrow(rawMtx)<3 )
    stop("rawMtx contains LESS THAN THREE (3) complete rows to be forecasted")
  
  #---  Initialize variables
  colNum <- ncol(rawMtx)
  #---  Compute min, max and sum
  if( length(lNum)==1 )
    minNum <- rep.int(lNum, colNum)
  mnsNum <- sum(minNum)
  if( is.null(uNum) )
    maxNum <- apply(rawMtx, 2, max)
  else
    maxNum <- rep.int(uNum, colNum)
  if( !RegIsEmptyBln(which(maxNum<minNum)) )
    stop("lNum MUST BE LESS THAN uNum")
  
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
  foreDfr[colNum+1, 1] <- max(foreDfr[colNum+1, 1], mnsNum)
  foreDfr
}
lottoArimaConfZooDfr <- function( rawZoo, lNum, uNum=NULL, c80Bln=FALSE )
{
  #---  Assert THREE (3) arguments:                                                   
  #       rawZoo:       a zoo object with AT LEAST (3 rows x 2 cols) to be forecasted
  #       lNum:         a numeric vector containing lower bounds                 
  #       uNum:         a numeric vector containing upper bounds (default: NULL)                 
  
  #---  Check that arguments are valid
  if( is.null(rawZoo) )
    stop("rawZoo MUST be a zoo object with at least (3 rows x 2 cols) to be forecasted")
  if( RegIsEmptyBln(rawZoo) )
    stop("rawZoo MUST be a zoo object with at least (3 rows x 2 cols) to be forecasted")
  if( is.null(NCOL(rawZoo)) )
    stop("rawZoo MUST be a zoo object with at least (3 rows x 2 cols) to be forecasted")
  if( NCOL(rawZoo)<2 )
    stop("rawZoo MUST be a zoo object with at least (3 rows x 2 cols) to be forecasted")
  if( NROW(rawZoo)<3 )
    stop("rawZoo MUST be a zoo object with at least (3 rows x 2 cols) to be forecasted")
  if( is.null(lNum) )
    stop("lNum MUST be a numeric vector containing lower bounds")
  if( RegIsEmptyBln(lNum) )
    stop("lNum MUST be a numeric vector containing lower bounds")
  if( length(lNum)>1 & length(lNum)!=NCOL(rawZoo) )
    stop("lNum MUST be a numeric vector of length EQUAL to number of columns in the matrix")
  if( !is.null(uNum) )
    if( RegIsEmptyBln(uNum) )
      stop("uNum MUST be a numeric vector containing upper bounds")
  if( length(uNum)>1 & length(uNum)!=NCOL(rawZoo) )
    stop("uNum MUST be a numeric vector of length EQUAL to number of columns in the matrix")
  if( NCOL(rawZoo)>1 )
    rawZoo <- rawZoo[complete.cases(rawZoo), ]
  else
    rawZoo <- na.omit(rawZoo)
  if( NROW(rawZoo)<3 )
    stop("rawZoo contains LESS THAN THREE (3) complete rows to be forecasted")
  if( !RegIsDateBln(index(rawZoo)) )
    stop("rawZoo MUST be a time series, i.e. index(rawZoo) MUST be a date")
    
  #---  Initialize variables
  colNum <- NCOL(rawZoo)
  #---  Compute min, max and sum
  if( length(lNum)==1 )
    minNum <- rep.int(lNum, colNum)
  mnsNum <- sum(minNum)
  if( is.null(uNum) )
    maxNum <- apply(rawZoo, 2, max)
  else
    maxNum <- rep.int(uNum, colNum)
  if( !RegIsEmptyBln(which(maxNum<minNum)) )
    stop("lNum MUST BE LESS THAN uNum")
  
  rawZoo <- cbind(rawZoo, apply(rawZoo, 1, sum))
  
  #--- fit MA on individual numbers and forecast for ONE (1) look ahead
  #       compute the confidence for EACH number
  upper_95_Num <- numeric(0)
  lower_95_Num <- numeric(0)
  upper_80_Num <- numeric(0)
  lower_80_Num <- numeric(0)
  for (i in 1:(colNum+1))
  {
    #---  Compute difNum, which is a vector of differences between the rows
    #       E.g. difNum[1] = row[1] - row[2]
    #       If lNum=0, shift by 1 because log(0) is Infinity
    if( lNum==0 )
      difNum <- diff(log(rawZoo[ ,i]+1))
    else
      difNum <- diff(log(rawZoo[ ,i]))
    
    #---  Fit MA on diff and forecast for ONE (1) look ahead
    dif.arima <- suppressWarnings(auto.arima(difNum))
    dif.forecast <- suppressWarnings(forecast(dif.arima, h=1))
    
    #---  Rearrange the formula for difNum, and compute the new row and confidence, 
    #       based on the diff forecast
    #       row[0] = difNum[0] + row[1]
    #       For 95% confidence interval, use max(forecast$upper) and min(forecast$lower)
    #       For 80% confidence interval, use min(forecast$upper) and max(forecast$lower)
    fore_95_UpperNum <- max(dif.forecast$upper)
    fore_95_LowerNum <- min(dif.forecast$lower)
    fore_80_UpperNum <- min(dif.forecast$upper)
    fore_80_LowerNum <- max(dif.forecast$lower)
    #       If lNum=0, shift back by -1 because log(0) is Infinity
    if( lNum==0 )
    {
      upper_95_Num <- c(upper_95_Num, exp( log(rawZoo[NROW(rawZoo), i]+1) + fore_95_UpperNum )-1 )
      lower_95_Num <- c(lower_95_Num, exp( log(rawZoo[NROW(rawZoo), i]+1) + fore_95_LowerNum )-1 )
      upper_80_Num <- c(upper_80_Num, exp( log(rawZoo[NROW(rawZoo), i]+1) + fore_80_UpperNum )-1 )
      lower_80_Num <- c(lower_80_Num, exp( log(rawZoo[NROW(rawZoo), i]+1) + fore_80_LowerNum )-1 )
    }
    else
    {
      upper_95_Num <- c(upper_95_Num, exp( log(rawZoo[NROW(rawZoo), i]) + fore_95_UpperNum ) )
      lower_95_Num <- c(lower_95_Num, exp( log(rawZoo[NROW(rawZoo), i]) + fore_95_LowerNum ) )
      upper_80_Num <- c(upper_80_Num, exp( log(rawZoo[NROW(rawZoo), i]) + fore_80_UpperNum ) )
      lower_80_Num <- c(lower_80_Num, exp( log(rawZoo[NROW(rawZoo), i]) + fore_80_LowerNum ) )
    }
  }
  
  fore_95_Dfr <- data.frame(lower=lower_95_Num, upper=upper_95_Num)
  fore_80_Dfr <- data.frame(lower=lower_80_Num, upper=upper_80_Num)
  fore_95_Dfr$lower <- round(fore_95_Dfr$lower)
  fore_95_Dfr$upper <- trunc(fore_95_Dfr$upper)
  fore_80_Dfr$lower <- round(fore_80_Dfr$lower)
  fore_80_Dfr$upper <- trunc(fore_80_Dfr$upper)
  for (i in 1:colNum)
  {
    fore_95_Dfr[i, 1] <- max(fore_95_Dfr[i, 1], minNum[i])
    fore_95_Dfr[i, 2] <- min(fore_95_Dfr[i, 2], maxNum[i])
    fore_80_Dfr[i, 1] <- max(fore_80_Dfr[i, 1], minNum[i])
    fore_80_Dfr[i, 2] <- min(fore_80_Dfr[i, 2], maxNum[i])
  }
  fore_95_Dfr[colNum+1, 1] <- max(fore_95_Dfr[colNum+1, 1], mnsNum)
  fore_80_Dfr[colNum+1, 1] <- max(fore_80_Dfr[colNum+1, 1], mnsNum)
  
  list(conf_95_Dfr=fore_95_Dfr, conf_80_Dfr=fore_80_Dfr)
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
lotto4DSplitZoo <- function( rawDfr )
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
  rawZoo <- zoo(matrix(cbind( as.numeric( substring(topChr, 1, 1) ),
                              as.numeric( substring(topChr, 2, 2) ),
                              as.numeric( substring(topChr, 3, 3) ),
                              as.numeric( substring(topChr, 4, 4) ) ),
                       ncol=4),
                rawDfr[, 2])
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
lottoPowerSplitZoo <- function( rawDfr )
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
  rawZoo <- zoo(matrix(cbind(rawDfr[, 3],rawDfr[, 4],rawDfr[, 5],rawDfr[, 6],rawDfr[, 7],rawDfr[, 8]),
                       ncol=6),
                rawDfr[, 2])
}
lottoRandSplitMtx <- function( rawDfr )
{
  #--- Coerce character into numeric or date
  rawDfr[, 1] <- suppressWarnings( as.numeric( rawDfr[, 1] ) )    # Draw number
  rawDfr[, 2] <- as.Date(rawDfr[, 2], "%Y/%m/%d")                 # Draw date
  rawDfr[, 3] <- suppressWarnings( as.numeric( rawDfr[, 3] ) )    # Number 1-2
  rawDfr[, 4] <- suppressWarnings( as.numeric( rawDfr[, 4] ) )    
  
  rawDfr <- rawDfr[1:nrow(rawDfr), ]
  rawMtx <- cbind(rawDfr[,3], rawDfr[,4])
}
lottoRandSplitZoo <- function( rawDfr )
{
  #--- Coerce character into numeric or date
  rawDfr[, 1] <- suppressWarnings( as.numeric( rawDfr[, 1] ) )    # Draw number
  rawDfr[, 2] <- as.Date(rawDfr[, 2], "%Y/%m/%d")                 # Draw date
  rawDfr[, 3] <- suppressWarnings( as.numeric( rawDfr[, 3] ) )    # Number 1-2
  rawDfr[, 4] <- suppressWarnings( as.numeric( rawDfr[, 4] ) )    
  
  rawDfr <- rawDfr[1:nrow(rawDfr), ]
  rawMtx <- zoo(matrix(cbind(rawDfr[,3], rawDfr[,4]),
                       ncol=2),
                rawDfr[, 2])
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
lottoOzSplitZoo <- function( rawDfr )
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
  rawZoo <- zoo(matrix(cbind(rawDfr[, 3],rawDfr[, 4],rawDfr[, 5],rawDfr[, 6],rawDfr[, 7],rawDfr[, 8],rawDfr[, 9]),
                       ncol=7),
                rawDfr[, 2])
}

lottoArimaNum <- function(lottoStr, startNum=1, c80Bln=FALSE)
{
  #---  Assert TWO (2) arguments:                                                   
  #       lottoStr:     MUST specify EITHER "powerball", "ozlotto", "satlotto", "wedlotto", "toto", OR "4d"
  #       startNum:     the start row that is used in forecast (default: 1)                 
  
  #---  Check that arguments are valid
  typeStr <- c("powerball", "ozlotto", "satlotto", "wedlotto", "toto", "4d")
  if( length(which(typeStr==lottoStr)) == 0 )
    stop("lottoStr MUST be either: powerball, ozlotto, satlotto, wedlotto, toto OR 4d")
  if( as.numeric(startNum) < 1 | as.numeric(startNum) > 10 ) 
    stop("startNum MUST be between ONE (1) and TEN (10)")
  
  #---  Call the ARIMA function to get a confidence data frame
  confDfr <- LottoArimaConf(lottoStr, startNum, c80Bln=c80Bln)
  confDfr$range <- confDfr$upper - confDfr$lower + 1
  
  #---  Calculate the power by multipying the individual ranges
  #       Powerball has five ranges then one range
  #       Sort the first five ranges by smalles to largest
  sRow <- nrow(confDfr)
  pNum <- 1
  if( lottoStr == "powerball" )
  {
    sortDfr <- confDfr[1:(sRow-2),]
    sortDfr <- sortDfr[with(sortDfr, order(range)),]
    for( i in 1:nrow(sortDfr) )
    {
      rNum <- sortDfr[i, 3] - (i - 1)
      if( rNum < 0 ) rNum <- 1
      pNum <- pNum * rNum
    }
    pNum <- pNum * confDfr[(sRow-1), 3]
  }
  else if( lottoStr == "4d" )
  {
    pNum <- prod(confDfr[1:sRow-1,3])
  }
  else
  {
    sortDfr <- confDfr[1:(sRow-1),]
    sortDfr <- sortDfr[with(sortDfr, order(range)),]
    for( i in 1:nrow(sortDfr) )
    {
      rNum <- sortDfr[i, 3] - (i - 1)
      if( rNum < 0 ) rNum <- 1
      pNum <- pNum * rNum
    }
  }
  pNum
}

#|------------------------------------------------------------------------------------------|
#|                          I N T E R N A L   B   F U N C T I O N S                         |
#|------------------------------------------------------------------------------------------|
lottoUpdateBln <- function( timeStamp.POSIXct, now.POSIXct=as.POSIXct(Sys.time()) )
{
  #---  Assert determine latest draw date
  last.POSIXct <- lottoDrawLastDte(now.POSIXct)
  
  #---  Assert calculate time difference
  time.difftime <- difftime(now.POSIXct, timeStamp.POSIXct, units="hours")
  last.difftime <- difftime(now.POSIXct, last.POSIXct, units="hours")
  
  #---  Assert timestamp is larger than last
  if( abs(as.double(time.difftime)) > abs(as.double(last.difftime)) )
  {
    updNum <- LottoUpdateNum()
    if( updNum > 0 ) return(TRUE)
  }
  return(FALSE)
}

lottoDrawLastDte <- function( now.POSIXct=as.POSIXct(Sys.time()) )
{
  eventBln <- FALSE
  
  #---  Assert compute the date and time of last draw
  #       Decompose today's date
  #       Compare with today's date and time of 18:00
  yNum <- as.POSIXlt(now.POSIXct)$year+1900
  mNum <- as.POSIXlt(now.POSIXct)$mon+1
  dNum <- as.POSIXlt(now.POSIXct)$mday
  wNum <- as.POSIXlt(now.POSIXct)$wday + 1
  date.POSIXct <- ISOdatetime(yNum,mNum,dNum,0,0,0)
  std.POSIXct <- ISOdatetime(yNum,mNum,dNum,18,0,0)
  std.difftime <- difftime(now.POSIXct, std.POSIXct, units="hours")
  if( now.POSIXct > std.POSIXct )
    eventBln <- TRUE
  
  #---  Assert determine day of week of last draw
  dayStr <- c("Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat")
  if( eventBln )
  {
    if( dayStr[wNum] == "Sun" |
      dayStr[wNum] == "Mon" |
      dayStr[wNum] == "Wed" |
      dayStr[wNum] == "Thu" |
      dayStr[wNum] == "Sat" ) 
      last.POSIXct <- as.POSIXct(date.POSIXct)
    else 
      last.POSIXct <- as.POSIXct(date.POSIXct - 1)
  }
  else
  {
    if( dayStr[wNum] == "Mon" |
      dayStr[wNum] == "Tue" |
      dayStr[wNum] == "Thu" |
      dayStr[wNum] == "Fri" |
      dayStr[wNum] == "Sun" ) 
      last.POSIXct <- as.POSIXct(date.POSIXct - 1)
    else 
      last.POSIXct <- as.POSIXct(date.POSIXct - 2)
  }
  #---  Assert compute the date and time of last draw
  #       Decompose today's date
  #       Compare with today's date and time of 18:00
  yNum <- as.POSIXlt(last.POSIXct)$year+1900
  mNum <- as.POSIXlt(last.POSIXct)$mon+1
  dNum <- as.POSIXlt(last.POSIXct)$mday
  ISOdatetime(yNum,mNum,dNum,18,0,0)
}

#|------------------------------------------------------------------------------------------|
#|                          I N T E R N A L   C   F U N C T I O N S                         |
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
  fourDfr <- fileReadDfr("4d")
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
    fileWriteCsv(formDfr, "4d")
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
  
  fileDfr <- fileReadDfr(lottoStr)
  if( !is.null(fileDfr) )
    nxtDrawNum <- max( suppressWarnings( as.numeric( fileDfr[, 1] ) ) ) + 1
  
  if( maxDrawNum < nxtDrawNum ) return(0)
  else
  {
    formDfr <- as.data.frame(lapply(newDfr, function(x) if (is(x, "Date")) format(x, "%Y/%m/%d") else x))
    fileWriteCsv(formDfr, lottoStr)
    retNum <- maxDrawNum - nxtDrawNum + 1
  }
  retNum
}

lottoTotoUpdateNum <- function( startDrawNum=2480, endDrawNum=9999, silent=TRUE )
{
  totoDfr <- fileReadDfr("toto")
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
    fileWriteCsv(formDfr, "toto")
  }
  retNum
}

lottoRandUpdateNum <- function( randNum, startDrawNum=1, endDrawNum=9999, silent=TRUE )
{
  randDfr <- fileReadDfr("r")
  if( is.null(randDfr) )
  {
    randDfr <- dataFrame( colClasses=c(Draw_number="character", Draw_date="character", 
                                       Number_1="character", Number_2="character"),
                          nrow=0 )
  }
  
  startDrawDte <- Sys.Date()
  if( nrow(randDfr)>0 )
  {
    #--- Coerce character into numeric or date
    nextDrawNum <- max( suppressWarnings( as.numeric( randDfr[, 1] ) ) ) + 1
    if( nextDrawNum > startDrawNum ) startDrawNum <- nextDrawNum
    startDrawDte <- max( suppressWarnings( as.Date( randDfr[, 2], "%Y/%m/%d") ) ) + 1
  }
  if( startDrawNum > endDrawNum ) return(0)
  
  retNum <- 0
  
  d <- startDrawNum
  rNum <- as.numeric(randNum)
  rNum <- c(rNum, rNum)
  rDte <- startDrawDte
  
  rDfr <- data.frame(d, format(rDte, "%Y/%m/%d"), rNum[1], rNum[2])
  names(rDfr) <- names(randDfr)
  randDfr <- rbind(rDfr, randDfr)
  retNum <- retNum + 1
  if( !silent ) print( paste("Imported random draw ", d, sep="") )
  
  if( retNum > 0 ) 
  {
    formDfr <- as.data.frame(lapply(randDfr, function(x) if (is(x, "Date")) format(x, "%Y/%m/%d") else x))
    fileWriteCsv(formDfr, "r")
  }
  nrow(formDfr)
}

lottoDrawDateChr <- function( lottoStr, startNum=1 )
{
  #---  Assert TWO (2) arguments:                                                   
  #       lottoStr:     MUST specify EITHER "powerball", "ozlotto", "satlotto", "wedlotto", "toto" OR "4d"
  #       startNum:     the start row that is used in forecast (default: 1)                 
  
  #---  Check that arguments are valid
  typeStr <- c("powerball", "ozlotto", "satlotto", "wedlotto", "toto", "4d")
  if( length(which(typeStr==lottoStr)) == 0 )
    stop("lottoStr MUST be either: powerball, ozlotto, satlotto, wedlotto, toto OR 4d")
  if( as.numeric(startNum) < 1 | as.numeric(startNum) > 10 ) 
    stop("startNum MUST be between ONE (1) and TEN (10)")
  
  #---  Draw date mechanism
  #       (1) Powerball draws ONE (1) time per week on Thursdays
  #       (1) Ozlotto draws ONE (1) time per week on Tuesdays
  #       (1) Gold Sat draws ONE (1) time per week on Saturdays
  #       (1) Gold Wed draws ONE (1) time per week on Wednesdays
  #       (2) Toto draws TWO (2) times per week on Mondays and Thursdays
  #       (2) 4D draws THREE (3) times per week on Wednesdays, Saturdays and Sundays
  rawDfr <- fileReadDfr(lottoStr)
  rawDfr <- rawDfr[startNum:nrow(rawDfr), ]
  
  #---  Coerce character into numeric or date
  #       Weekday [0-6] represents [Sun,Mon,..,Sat] 
  rawDfr[, 2] <- as.Date(rawDfr[, 2], "%Y/%m/%d")                 # Draw date
  latDte <- rawDfr[1, 2]
  latNum <- as.POSIXlt(latDte)$wday
  
  if(lottoStr == "powerball")
    latDte <- latDte + 7
  if(lottoStr == "ozlotto")
    latDte <- latDte + 7
  if(lottoStr == "satlotto")
    latDte <- latDte + 7
  if(lottoStr == "wedlotto")
    latDte <- latDte + 7
  if(lottoStr == "toto")
  {
    if( latNum == 1 ) latDte <- latDte + 3
    else latDte <- latDte + 4
  }
  if(lottoStr == "4d")
  {
    if( latNum == 6 ) latDte <- latDte + 1
    else latDte <- latDte + 3
  }
  format(latDte, "%Y/%m/%d")  
}  

#|------------------------------------------------------------------------------------------|
#|                          I N T E R N A L   D   F U N C T I O N S                         |
#|------------------------------------------------------------------------------------------|
lottoTotoSeqSplitMtx <- function( rawDfr )
{
  #--- Coerce character into numeric or date
  rawDfr[, 1] <- suppressWarnings( as.numeric( rawDfr[, 1] ) )    # Draw number
  rawDfr[, 2] <- as.Date(rawDfr[, 2], "%Y/%m/%d")                 # Draw date
  
  rawDfr <- rawDfr[1:nrow(rawDfr), ]
  topChr <- character(0)
  for( i in 1:nrow(rawDfr) )
  {
    topChr <- rbind( topChr, rawDfr[i,9], rawDfr[i,8], rawDfr[i,7],
                     rawDfr[i,6], rawDfr[i,5], rawDfr[i,4], rawDfr[i,3] )
  }
  
  seqMtx <- matrix( nrow=nrow(topChr), ncol=6 )
  for( i in 1:nrow(topChr) )
  {
    seqMtx[i, ] <- lottoSeqAlongNum( "toto", topChr[i] )[2:7] 
  }
  seqMtx
}

lottoTotoSeqDfr <- function( numChr, allBln=TRUE )
{
  
  #---  Check that arguments are valid
  if( as.numeric(numChr) < 1 | as.numeric(numChr) > 45 ) 
    stop("numChr MUST be between ONE (1) and FORTY-FIVE (45)")
  
  rawDfr <- fileReadDfr("toto")
  if( !allBln )
  {
    return( subset( rawDfr,
                    rawDfr$Number_1 == numChr |
                      rawDfr$Number_2 == numChr |
                      rawDfr$Number_3 == numChr |
                      rawDfr$Number_4 == numChr |
                      rawDfr$Number_5 == numChr |
                      rawDfr$Number_6 == numChr ) )
  }
  return( subset( rawDfr,
                  rawDfr$Number_1 == numChr |
                    rawDfr$Number_2 == numChr |
                    rawDfr$Number_3 == numChr |
                    rawDfr$Number_4 == numChr |
                    rawDfr$Number_5 == numChr |
                    rawDfr$Number_6 == numChr |
                    rawDfr$Number_7 == numChr ) )
}

lotto4DSeqSplitMtx <- function( rawDfr )
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
  
  tmeMtx <- matrix( nrow=nrow(topChr), ncol=6 )
  for( i in 1:nrow(topChr) )
  {
    tmeMtx[i, ] <- lottoSeqAlongNum( "4d", topChr[i] )[2:7] 
  }
  tmeMtx
}

lotto4DSeqDfr <- function( numChr, allBln=TRUE )
{
  rawDfr <- fileReadDfr("4d")
  perChr <- lotto4DSystemChr(numChr)
  if( !allBln )
  {
    return( subset( rawDfr,
                    rawDfr$Number_1 %in% perChr |
                      rawDfr$Number_2 %in% perChr |
                      rawDfr$Number_3 %in% perChr ) )
  }
  subset( rawDfr, 
          rawDfr$Number_1 %in% perChr |
            rawDfr$Number_2 %in% perChr |
            rawDfr$Number_3 %in% perChr |
            rawDfr$Number_4 %in% perChr |
            rawDfr$Number_5 %in% perChr |
            rawDfr$Number_6 %in% perChr |
            rawDfr$Number_7 %in% perChr |
            rawDfr$Number_8 %in% perChr |
            rawDfr$Number_9 %in% perChr |
            rawDfr$Number_10 %in% perChr |
            rawDfr$Number_11 %in% perChr |
            rawDfr$Number_12 %in% perChr |
            rawDfr$Number_13 %in% perChr |
            rawDfr$Number_14 %in% perChr |
            rawDfr$Number_15 %in% perChr |
            rawDfr$Number_16 %in% perChr |
            rawDfr$Number_17 %in% perChr |
            rawDfr$Number_18 %in% perChr |
            rawDfr$Number_19 %in% perChr |
            rawDfr$Number_20 %in% perChr |
            rawDfr$Number_21 %in% perChr |
            rawDfr$Number_22 %in% perChr |
            rawDfr$Number_23 %in% perChr )
}

lottoSeqAlongNum <- function( lottoStr, numChr, allBln=TRUE )
{
  #---  Check that arguments are valid
  typeStr <- c("powerball", "ozlotto", "satlotto", "wedlotto", "toto", "4d")
  if( length(which(typeStr==lottoStr)) == 0 )
    stop("lottoStr MUST be either: powerball, ozlotto, satlotto, wedlotto, toto, OR 4d")
  
  #if(lottoStr == "powerball")
  #if(lottoStr == "satlotto")
  #if(lottoStr == "wedlotto")
  if(lottoStr == "toto")
    subDfr <- lottoTotoSeqDfr( numChr, allBln )
  #if(lottoStr == "ozlotto")
  if(lottoStr == "4d")
    subDfr <- lotto4DSeqDfr( numChr, allBln )
  
  #---  Add today as reference
  dteChr <- c(lottoDrawDateChr(lottoStr), subDfr$Draw_date)
  
  #---  Compute time differences in days
  as.numeric(-diff(as.Date(dteChr, "%Y/%m/%d")))
}

lotto4DSystemChr <- function( numChr )
{
  dChr <- character(0)
  perChr <- character(0)
  
  if( nchar(numChr) != 4 )
    stop("numChr MUST be a FOUR(4)-digit number as a character")
  for( pos in 1:4 )
  {
    dChr <- rbind(dChr, substring(numChr,pos,pos))
    if(is.na(suppressWarnings( as.numeric(dChr[pos]) )))
      stop("numChr MUST be a FOUR(4)-digit number as a character")
  }
  
  #---  Generate a matrix of ALL permutations for 4x4 orders
  #       Create a set of numbers for ALL permutations
  #       Remove duplicates
  perMtx <- permutations(4,4)
  for( i in 1:nrow(perMtx) )
  {
    nChr <- paste0( dChr[ perMtx[i,1] ], 
                    dChr[ perMtx[i,2] ], 
                    dChr[ perMtx[i,3] ], 
                    dChr[ perMtx[i,4] ] )
    perChr <- rbind(perChr, nChr[1])
  }
  perChr <- unique(perChr)
  perChr
}

#|------------------------------------------------------------------------------------------|
#|                                E N D   O F   S C R I P T                                 |
#|------------------------------------------------------------------------------------------|
