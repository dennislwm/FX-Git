#|------------------------------------------------------------------------------------------|
#|                                                                          PlusMarketDfr.R |
#|                                                             Copyright © 2012, Dennis Lee |
#| Assert History                                                                           |
#|  1.0.1   Added constants for trading and ONE function MarketDfrNormalizeDouble.FUN().    |
#|  1.0.0   This script allows R functions to access the MarketInfo data from MT4.          |
#|            THREE (3) external functions MarketDfrCreate(), MarketDfrInfo.FUN() and       |
#|            MarketDfrRefreshRates.FUN().                                                  |
#|------------------------------------------------------------------------------------------|
require(R.utils)
source("C:/Users/denbrige/100 FxOption/103 FxOptionVerBack/080 Fx Git/R-source/PlusFile.R")

#|------------------------------------------------------------------------------------------|
#|                            I N T E R N A L   V A R I A B L E S                           |
#|------------------------------------------------------------------------------------------|
#---  Assert internal variables for Dfr
MarketDfrName           = "PlusMarketDfr"
MarketDfrVer            = "1.0.1"
#---  Dfr CSV file names (one table per CSV file)
MiTableStr              = "MarketInfo"
#---- Dfr column names for MarketInfo
MiLowStr                = "Low"
MiHighStr               = "High"
MiTimeStr               = "Time"
MiBidStr                = "Bid"
MiAskStr                = "Ask"
MiPointStr              = "Point"
MiDigitsStr             = "Digits"
MiSpreadStr             = "Spread"
MiStopLevelStr          = "StopLevel"
MiLotSizeStr            = "LotSize"
MiTickValueStr          = "TickValue"
MiTickSizeStr           = "TickSize"
MiSwapLongStr           = "SwapLong"
MiSwapShortStr          = "SwapShort"
MiStartingStr           = "Starting"
MiExpirationStr         = "Expiration"
MiTradeAllowedStr       = "TradeAllowed"
MiMinLotStr             = "MinLot"
MiLotStepStr            = "LotStep"
MiMaxLotStr             = "MaxLot"
MiSwapTypeStr           = "SwapType"
MiProfitCalcModeStr     = "ProfitCalcMode"
MiMarginCalcModeStr     = "MarginCalcMode"
MiMarginInitStr         = "MarginInit"
MiMarginMaintenanceStr  = "MarginMaintenance"
MiMarginHedgedStr       = "MarginHedged"
MiMarginRequiredStr     = "MarginRequired"
MiFreezeLevelStr        = "MarginFreezeLevel"
MiSymbolStr             = "Symbol"
#---- Constant variables
#        See documentation http://docs.mql4.com/constants/marketinfo
MODE_LOW                = 1   # double
MODE_HIGH               = 2   # double
MODE_TIME               = 5   # datetime
MODE_BID                = 9   # double
MODE_ASK                = 10  # double, e.g. 0.9333
MODE_POINT              = 11  # int
MODE_DIGITS             = 12  # int, e.g. 5
MODE_SPREAD             = 13  # int, e.g. 22
MODE_STOPLEVEL          = 14  # int, e.g. 30
MODE_LOTSIZE            = 15  # int, e.g. 100000
MODE_TICKVALUE          = 16  # double, e.g. 1.0209
MODE_TICKSIZE           = 17  # int
MODE_SWAPLONG           = 18  # double, e.g. 1.27
MODE_SWAPSHORT          = 19  # double, e.g. -2.78
MODE_STARTING           = 20  # int
MODE_EXPIRATION         = 21  # int
MODE_TRADEALLOWED       = 22  # int, e.g. 1
MODE_MINLOT             = 23  # double, e.g. 0.01
MODE_LOTSTEP            = 24  # double, e.g. 0.01
MODE_MAXLOT             = 25  # double, e.g. 20
MODE_SWAPTYPE           = 26  # int
MODE_PROFITCALCMODE     = 27  # int
MODE_MARGINCALCMODE     = 28  # int
MODE_MARGININIT         = 29  # int
MODE_MARGINMAINTENANCE  = 30  # int
MODE_MARGINHEDGED       = 31  # int
MODE_MARGINREQUIRED     = 32  # double, e.g. 952.59
MODE_FREEZELEVEL        = 33  # int
MODE_SYMBOL             = 34  # string, this doesn't exists in MT4
#        See doc http://docs.mql4.com/constants/trading
OP_BUY                  = 0
OP_SELL                 = 1
OP_BUYLIMIT             = 2
OP_SELLLIMIT            = 3
OP_BUYSTOP              = 4
OP_SELLSTOP             = 5

#|------------------------------------------------------------------------------------------|
#|                            E X T E R N A L   F U N C T I O N S                           |
#|------------------------------------------------------------------------------------------|
#|------------------------------------------------------------------------------------------|
#|                          E X T E R N A L   A   F U N C T I O N S                         |
#|------------------------------------------------------------------------------------------|
MarketDfrCreate <- function( symStr, acctNoInt )
{
  InitBln  <- FALSE;
  isOkBln  <- FALSE;
  
  #---  Assert check if CSV file exists, e.g. "Acc440660-MarketInfo.csv"
  MarketNameStr <- paste0("AccNo",acctNoInt,"-",MiTableStr)
  
  #---  Assert CSV file is opened for the first time.
  if( !fileExists(MarketNameStr) ) InitBln <- TRUE
  
  if( InitBln )
  {
    isOkBln <- TRUE;
    #---  Assert create table MarketInfo
    marketInfoDfr <- dataFrame( colClasses=c(Low="character",              High="character",             
                                             Dummy_03="character",         Dummy_04="character",
                                             Time="character",             Dummy_06="character",
                                             Dummy_07="character",         Dummy_08="character",
                                             Bid="character",              Ask="character",
                                             Point="character",            Digits="character",
                                             Spread="character",           StopLevel="character",
                                             LotSize="character",          TickValue="character",
                                             TickSize="character",         SwapLong="character",
                                             SwapShort="character",        Starting="character",
                                             Expiration="character",       TradeAllowed="character",
                                             MinLot="character",           LotStep="character",
                                             MaxLot="character",           SwapType="character",
                                             ProfitCalcMode="character",   MarginCalcMode="character",
                                             MarginInit="character",       MarginMaintenance="character",
                                             MarginHedged="character",     MarginRequired="character",
                                             MarginFreezeLevel="character",Symbol="character"), 
                                    nrow=0 )
    fileWriteCsv(marketInfoDfr, MarketNameStr)
    #---  Assert OK table created successfully
    isOkBln <- fileExists(MarketNameStr)
    
    if( !isOkBln ) return(FALSE);
  }
  #---  Assert Populate MarketInfo
  #       Check if row for symbol exists
  marketInfoDfr <- fileReadDfr(MarketNameStr)
  symDfr <- marketInfoDfr[ marketInfoDfr$Symbol==symStr, ]
  if( nrow(symDfr)==0 )
  {
    r <- nrow(marketInfoDfr)+1
    marketInfoDfr[r,] <- NA
    marketInfoDfr[r, MODE_SYMBOL] <- symStr
  }
  fileWriteCsv(marketInfoDfr, MarketNameStr)

  return(TRUE)
}

MarketDfrInfo.FUN <- function( acctNoInt )
{
#---  MarketInfo.FUN() returns a function that has a default MarketNameStr
#       e.g. "Acc440660-MarketInfo"
  function( symStr, modeInt, MarketNameStr=paste0("AccNo",acctNoInt,"-",MiTableStr) )
  {
    if( !fileExists(MarketNameStr) ) return(NULL)
    
    #---  Read data frame, e.g. "Acc440660-MarketInfo.csv"
    marketInfoDfr <- fileReadDfr(MarketNameStr)
    
    #---  Assert check if info for symbol exists
    #       Remove duplicate entries
    if( length(which(marketInfoDfr$Symbol==symStr))==0 )       
      return(NULL)
    else
    {
      symDfr <- marketInfoDfr[ marketInfoDfr$Symbol==symStr, ]
      if( nrow(symDfr)>1 )   symDfr <- symDfr[1:1,]
    }
    
    #---  Coerce data into numeric and date
    #       Return appropriate column
    return( as.numeric(symDfr[1, modeInt]) )
  }
}

MarketDfrRefreshRates.FUN <- function( acctNoInt )
{
#---  MarketDfrRefreshRates.FUN() returns a function that has a default MarketNameStr
#       e.g. "Acc440660-MarketInfo"
  function( symStr, infoNum, MarketNameStr=paste0("AccNo",acctNoInt,"-",MiTableStr) )
  {
    if( !fileExists(MarketNameStr) ) return(NULL)
    
    #---  Read data frame, e.g. "Acc440660-MarketInfo.csv"
    marketInfoDfr <- fileReadDfr(MarketNameStr)
    
    #---  Assert check if info for symbol exists
    #       Update the existing entry
    if( length(which(marketInfoDfr$Symbol==symStr))==0 )
    {
      MarketDfrCreate( symStr, acctNoInt ) 
      marketInfoDfr <- fileReadDfr(MarketNameStr)
    }
      
    r <- which(marketInfoDfr$Symbol==symStr)
    marketInfoDfr[r, 1:MODE_FREEZELEVEL] <- infoNum
    fileWriteCsv(marketInfoDfr, MarketNameStr)
  }
}

#|------------------------------------------------------------------------------------------|
#|                            I N T E R N A L   F U N C T I O N S                           |
#|------------------------------------------------------------------------------------------|
MarketDfrNormalizeDouble.FUN <- function( digits )
{
#---  MarketDfrNormalizeDouble.FUN() returns a function that has a default digits
  function( value, d=digits )
  {
    round(value, d)
  }   
}

#|------------------------------------------------------------------------------------------|
#|                          I N T E R N A L   A   F U N C T I O N S                         |
#|------------------------------------------------------------------------------------------|

#|------------------------------------------------------------------------------------------|
#|                                E N D   O F   S C R I P T                                 |
#|------------------------------------------------------------------------------------------|
