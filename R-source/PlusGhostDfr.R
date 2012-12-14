#|------------------------------------------------------------------------------------------|
#|                                                                           PlusGhostDfr.R |
#|                                                             Copyright © 2012, Dennis Lee |
#| Assert History                                                                           |
#|  0.9.0   Originated from GhostSqLite 1.22. Source files are loaded in this sequence:     |
#|            (1) PlusReg; (2) PlusFile; (3) PlusMarketDfr; (4) PlusGhostDfr (this file.    |
#|          TODO: There are lots of functions to implement. Aside from the functions that   |
#|            originated from GhostSqLite 1.22, we have to design a file PlusDateTimeDfr    |
#|            that contains R functions equivalent to MT4 date and time functions here:     |
#|            http://docs.mql4.com/dateandtime/timecurrent                                  |
#|------------------------------------------------------------------------------------------|
source("C:/Users/denbrige/100 FxOption/103 FxOptionVerBack/080 Fx Git/R-source/PlusMarketDfr.R")

#|------------------------------------------------------------------------------------------|
#|                            I N T E R N A L   V A R I A B L E S                           |
#|------------------------------------------------------------------------------------------|
#---  Assert internal variables for Dfr
DfrName              = "PlusGhostDfr"
DfrVer               = "0.9.0"
#---  Dfr CSV file names (one table per CSV file)
AdTableStr           = "AccountDetails"
StTableStr           = "Statistics"
OpTableStr           = "OpenedPositions"
PoTableStr           = "OpenedPositions"
ThTableStr           = "TradeHistory"
#---- Dfr column names for AccountDetails
AdAccountNoStr       = "AccountNo"
AdCurrencyStr        = "Currency"
AdBalanceStr         = "Balance"
AdEquityStr          = "Equity"
AdMarginStr          = "Margin"
AdProfitStr          = "Profit"
#---- SqLite column names for Statistics
StTotalTradesStr     = "TotalTrades"
StTotalLotsStr       = "TotalLots"
StTotalProfitStr     = "TotalProfit"
StTotalProfitPipStr  = "TotalProfitPip"
StTotalDrawdownStr   = "TotalDrawdown"
StTotalDrawdownPipStr= "TotalDrawdownPip"
StTotalMarginStr     = "TotalMargin"
StMaxLotsStr         = "MaxLots"
StMaxProfitStr       = "MaxProfit"
StMaxProfitPipStr    = "MaxProfitPip"
StMaxDrawdownStr     = "MaxDrawdown"
StMaxDrawdownPipStr  = "MaxDrawdownPip"
StMaxMarginStr       = "MaxMargin"
#---- SqLite column names for Opened Positions
OpTicketStr          = "Ticket"
OpOpenTimeStr        = "OpenTime"
OpTypeStr            = "Type"
OpLotsStr            = "Lots"
OpOpenPriceStr       = "OpenPrice"
OpStopLossStr        = "StopLoss"
OpTakeProfitStr      = "TakeProfit"
OpCurPriceStr        = "CurPrice"
OpSwapStr            = "Swap"
OpProfitStr          = "Profit"
OpExpirationStr      = "Expiration"
OpCloseTimeStr       = "CloseTime"
OpMagicNoStr         = "MagicNo"
OpAccountNoStr       = "AccountNo"
OpSymbolStr          = "Symbol"
OpCommentStr         = "Comment"
OpExpertNameStr      = "ExpertName"
#---- SqLite column names for Pending Orders (uses same table as Opened Positions)
PoTicketStr          = "Ticket"
PoOpenTimeStr        = "OpenTime"
PoTypeStr            = "Type"
PoLotsStr            = "Lots"
PoOpenPriceStr       = "OpenPrice"
PoStopLossStr        = "StopLoss"
PoTakeProfitStr      = "TakeProfit"
PoClosePriceStr      = "CurPrice"
PoSwapStr            = "Swap"
PoProfitStr          = "Profit"
PoExpirationStr      = "Expiration"
PoCloseTimeStr       = "CloseTime"
PoMagicNoStr         = "MagicNo"
PoAccountNoStr       = "AccountNo"
PoSymbolStr          = "Symbol"
PoCommentStr         = "Comment"
PoExpertNameStr      = "ExpertName"
#---- SqLite column names for TradeHistory
ThTicketStr          = "Ticket"
ThOpenTimeStr        = "OpenTime"
ThTypeStr            = "Type"
ThLotsStr            = "Lots"
ThOpenPriceStr       = "OpenPrice"
ThStopLossStr        = "StopLoss"
ThTakeProfitStr      = "TakeProfit"
ThClosePriceStr      = "ClosePrice"
ThSwapStr            = "Swap"
ThProfitStr          = "Profit"
ThExpirationStr      = "Expiration"
ThCloseTimeStr       = "CloseTime"
ThMagicNoStr         = "MagicNo"
ThAccountNoStr       = "AccountNo"
ThSymbolStr          = "Symbol"
ThCommentStr         = "Comment"
ThExpertNameStr      = "ExpertName"
ThEquityStr          = "Equity"

#|------------------------------------------------------------------------------------------|
#|                            E X T E R N A L   F U N C T I O N S                           |
#|------------------------------------------------------------------------------------------|
#|------------------------------------------------------------------------------------------|
#|                          E X T E R N A L   A   F U N C T I O N S                         |
#|------------------------------------------------------------------------------------------|
DfrCreate <- function( acctNoInt, symbolStr, periodInt, eaNameStr,
                       acctCcyStr="SGD", acctBalDbl=1000)
{
  InitBln  <- FALSE;
  isOkBln  <- FALSE;
  
  #---  Assert check if CSV file exists, e.g. "Acc440660-Growthbot.csv"
  #        There are FOUR (4) CSV files: 
  SqLiteNameStr <- paste0("AccNo",acctNoInt,
                          "-",symbolStr,
                          "-",periodInt,
                          "-",eaNameStr)
  
  #---  Assert CSV file is opened for the first time.
  if( !fileExists(paste0(SqLiteNameStr,"-",AdTableStr)) ) InitBln <- TRUE
  
  if( InitBln )
  {
    isOkBln <- TRUE;
    #---  Assert create table AccountDetails
    accountDetailsDfr <- dataFrame( colClasses=c(AccountNo="character",  Currency="character",
                                                 Balance="character",    Equity="character",
                                                 Margin="character",     Profit="character"), 
                                    nrow=0 )
    fileWriteCsv(accountDetailsDfr, paste0(SqLiteNameStr,"-",AdTableStr))
    #---  Assert OK table created successfully
    isOkBln <- isOkBln & fileExists(paste0(SqLiteNameStr,"-",AdTableStr))
    
    #---  Assert create table Statistics
    statisticsDfr <- dataFrame( colClasses=c(TotalTrades="character",    TotalLots="character", 
                                             TotalProfit="character",    TotalProfitPip="character",
                                             TotalDrawdown="character",  TotalDrawdownPip="character",
                                             TotalMargin="character",    MaxLots="character",
                                             MaxProfit="character",      MaxProfitPip="character",
                                             MaxDrawdown="character",    MaxDrawdownPip="character",
                                             MaxMargin="character"), 
                                nrow=0 )
    fileWriteCsv(statisticsDfr, paste0(SqLiteNameStr,"-",StTableStr))
    #---  Assert OK table created successfully
    isOkBln <- isOkBln & fileExists(paste0(SqLiteNameStr,"-",StTableStr))
    
    #---  Assert create table Opened Positions
    openedPositionsDfr <- dataFrame( colClasses=c(Ticket="character",       OpenTime="character", 
                                                  Type="character",         Lots="character",
                                                  OpenPrice="character",    StopLoss="character",
                                                  TakeProfit="character",   CurPrice="character",
                                                  Swap="character",         Profit="character",
                                                  Expiration="character",   CloseTime="character",
                                                  MagicNo="character",      AccountNo="character",
                                                  Symbol="character",       Comment="character",
                                                  ExpertName="character"), 
                                     nrow=0 )
    fileWriteCsv(openedPositionsDfr, paste0(SqLiteNameStr,"-",OpTableStr))
    #---  Assert OK table created successfully
    isOkBln <- isOkBln & fileExists(paste0(SqLiteNameStr,"-",OpTableStr))
    
    #---  Assert create table TradeHistory
    tradeHistoryDfr <- dataFrame( colClasses=c(Ticket="character",       OpenTime="character", 
                                               Type="character",         Lots="character",
                                               OpenPrice="character",    StopLoss="character",
                                               TakeProfit="character",   ClosePrice="character",
                                               Swap="character",         Profit="character",
                                               Expiration="character",   CloseTime="character",
                                               MagicNo="character",      AccountNo="character",
                                               Symbol="character",       Comment="character",
                                               ExpertName="character",   Equity="character"), 
                                  nrow=0 )
    fileWriteCsv(tradeHistoryDfr, paste0(SqLiteNameStr,"-",ThTableStr))
    #---  Assert OK table created successfully
    isOkBln <- isOkBln & fileExists(paste0(SqLiteNameStr,"-",ThTableStr))
    
    if( !isOkBln ) return(FALSE);
    
    #---  Assert Populate AccountDetails: AccountNo, Currency, Balance, Equity
    accountDetailsDfr[1, 1] <- acctNoInt
    accountDetailsDfr[1, 2] <- acctCcyStr
    accountDetailsDfr[1, 3] <- acctBalDbl
    accountDetailsDfr[1, 4] <- acctBalDbl
    fileWriteCsv(accountDetailsDfr, paste0(SqLiteNameStr,"-",AdTableStr))
    
    #---  Assert Populate Statistics
    statisticsDfr[1, ] <- NA
    fileWriteCsv(statisticsDfr, paste0(SqLiteNameStr,"-",StTableStr))
  }
  return(TRUE)
}
#|------------------------------------------------------------------------------------------|
#|                                  O P E N   O R D E R S                                   |
#|------------------------------------------------------------------------------------------|
DfrOrderSend <- function( pts )
{
  function( sym, type, lots, price, slip, SL, TP, cmt="", mgc=0, exp=0, arrow=NULL, GhostPts=pts)
  {
    openPrice   <- 0.0
    openSL      <- 0.0
    openTP      <- 0.0
    openTime    <- 0
    curPrice    <- 0.0
   
  #---  Assert Create new ticket in OpenedPositions
    if(type==OP_BUY || type==OP_SELL)
    {
    #--- Assert get real-time info.
      if(type==OP_BUY)
      {
        openPrice <- MarketInfo( sym, MODE_ASK )
        if(SL!=0.0) openSL<-NormalizeDouble(openPrice-SL*GhostPts)
        if(TP!=0.0) openTP<-NormalizeDouble(openPrice+TP*GhostPts)
      }
      else
      {
        openPrice <- MarketInfo( sym, MODE_BID )
        if(SL!=0.0) openSL<-NormalizeDouble(openPrice+SL*GhostPts)
        if(TP!=0.0) openTP<-NormalizeDouble(openPrice-TP*GhostPts)
      }
      openTime<-TimeCurrent()
      
      return( DfrOrderOpen( sym, openTime, type, lots, openPrice, openSL, openTP, cmt, mgc, exp, arrow ) )
    }
    else if(type>OP_SELL)
    {
      #--- Assert get real-time info.
      openPrice <- price
      openSL    <- SL
      openTP    <- TP
      if(type==OP_BUYLIMIT)
      {
        curPrice <- MarketInfo( sym, MODE_ASK )
        if( openPrice > curPrice ) return(-1)
      }
      else if(type==OP_SELLLIMIT)
      {
        curPrice <- MarketInfo( sym, MODE_BID )
        if( openPrice < curPrice ) return(-1)
      }
      else if(type==OP_BUYSTOP)
      {
        curPrice <- MarketInfo( sym, MODE_ASK ) 
        if( openPrice < curPrice ) return(-1)
      }
      else if(type==OP_SELLSTOP)
      {
        curPrice = MarketInfo( sym, MODE_BID )
        if( openPrice > curPrice ) return(-1)
      }
      openTime<-TimeCurrent()
      
      return( DfrOrderOpen( sym, openTime, type, lots, openPrice, openSL, openTP, cmt, mgc, exp, arrow ) )
    }
  }
}

#|------------------------------------------------------------------------------------------|
#|                            I N T E R N A L   F U N C T I O N S                           |
#|------------------------------------------------------------------------------------------|

#|------------------------------------------------------------------------------------------|
#|                          I N T E R N A L   A   F U N C T I O N S                         |
#|------------------------------------------------------------------------------------------|

#|------------------------------------------------------------------------------------------|
#|                                E N D   O F   S C R I P T                                 |
#|------------------------------------------------------------------------------------------|
