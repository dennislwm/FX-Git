//|-----------------------------------------------------------------------------------------|
//|                                                                         GhostSqLite.mqh |
//|                                                            Copyright © 2012, Dennis Lee |
//| Assert History                                                                          |
//| 1.00    Originated from PlusGhost 1.50.                                                 |
//| 1.01    Fixed OrderSend() return incorrect Id. Fixed OrdersTotal() and                  |
//|             OrdersHistoryTotal() return incorrect total. Added print debug info and     |
//|             some minor fixes in SqLiteCreate() and SqLiteLoadBuffers().                 |
//| 1.02    Populate Statistics table in SqLiteCreate() and fixed type of StMaxLots and     |
//|             SqLiteAccountNumber().                                                      |
//|-----------------------------------------------------------------------------------------|

//|-----------------------------------------------------------------------------------------|
//|                        S H M U M A   S Q L I T E   A D D O N                            |
//|-----------------------------------------------------------------------------------------|
#include    <sqlite.mqh>

//|-----------------------------------------------------------------------------------------|
//|                           I N T E R N A L   V A R I A B L E S                           |
//|-----------------------------------------------------------------------------------------|
//---- Assert internal variables for SQLite
string   SqLiteName        = "";
string   SqLiteVer         = "1.02";
int      SqLiteSelectIndex;
int      SqLiteSelectMode;
bool     SqLiteSelectAsc;
int      SqLiteSelectHandle;
int      SqLiteSelectTotal;
//---- SqLite table names
string   AdTable    = "AccountDetails";
string   StTable    = "Statistics";
string   OpTable    = "OpenedPositions";
string   PoTable    = "OpenedPositions";
string   ThTable    = "TradeHistory";
//---- SqLite column names for AccountDetails
string   AdAccountNoStr       = "AccountNo";
string   AdCurrencyStr        = "Currency";
string   AdBalanceStr         = "Balance";
string   AdEquityStr          = "Equity";
string   AdMarginStr          = "Margin";
string   AdProfitStr          = "Profit";
//---- SqLite column names for Statistics
string   StTotalTradesStr     = "TotalTrades";
string   StTotalLotsStr       = "TotalLots";
string   StTotalProfitStr     = "TotalProfit";
string   StTotalProfitPipStr  = "TotalProfitPip";
string   StTotalDrawdownStr   = "TotalDrawdown";
string   StTotalDrawdownPipStr= "TotalDrawdownPip";
string   StTotalMarginStr     = "TotalMargin";
string   StMaxLotsStr         = "MaxLots";
string   StMaxProfitStr       = "MaxProfit";
string   StMaxProfitPipStr    = "MaxProfitPip";
string   StMaxDrawdownStr     = "MaxDrawdown";
string   StMaxDrawdownPipStr  = "MaxDrawdownPip";
string   StMaxMarginStr       = "MaxMargin";
//---- SqLite column names for Opened Positions
string   OpTicketStr          = "Ticket";
string   OpOpenTimeStr        = "OpenTime";
string   OpTypeStr            = "Type";
string   OpLotsStr            = "Lots";
string   OpOpenPriceStr       = "OpenPrice";
string   OpStopLossStr        = "StopLoss";
string   OpTakeProfitStr      = "TakeProfit";
string   OpCurPriceStr        = "CurPrice";
string   OpSwapStr            = "Swap";
string   OpProfitStr          = "Profit";
string   OpExpirationStr      = "Expiration";
string   OpCloseTimeStr       = "CloseTime";
string   OpMagicNoStr         = "MagicNo";
string   OpAccountNoStr       = "AccountNo";
string   OpSymbolStr          = "Symbol";
string   OpCommentStr         = "Comment";
string   OpExpertNameStr      = "ExpertName";
//---- SqLite column names for Pending Orders (uses same table as Opened Positions)
string   PoTicketStr          = "Ticket";
string   PoOpenTimeStr        = "OpenTime";
string   PoTypeStr            = "Type";
string   PoLotsStr            = "Lots";
string   PoOpenPriceStr       = "OpenPrice";
string   PoStopLossStr        = "StopLoss";
string   PoTakeProfitStr      = "TakeProfit";
string   PoClosePriceStr      = "CurPrice";
string   PoSwapStr            = "Swap";
string   PoProfitStr          = "Profit";
string   PoExpirationStr      = "Expiration";
string   PoCloseTimeStr       = "CloseTime";
string   PoMagicNoStr         = "MagicNo";
string   PoAccountNoStr       = "AccountNo";
string   PoSymbolStr          = "Symbol";
string   PoCommentStr         = "Comment";
string   PoExpertNameStr      = "ExpertName";
//---- SqLite column names for TradeHistory
string   ThTicketStr          = "Ticket";
string   ThOpenTimeStr        = "OpenTime";
string   ThTypeStr            = "Type";
string   ThLotsStr            = "Lots";
string   ThOpenPriceStr       = "OpenPrice";
string   ThStopLossStr        = "StopLoss";
string   ThTakeProfitStr      = "TakeProfit";
string   ThClosePriceStr      = "ClosePrice";
string   ThSwapStr            = "Swap";
string   ThProfitStr          = "Profit";
string   ThExpirationStr      = "Expiration";
string   ThCloseTimeStr       = "CloseTime";
string   ThMagicNoStr         = "MagicNo";
string   ThAccountNoStr       = "AccountNo";
string   ThSymbolStr          = "Symbol";
string   ThCommentStr         = "Comment";
string   ThExpertNameStr      = "ExpertName";

//|-----------------------------------------------------------------------------------------|
//|                             I N I T I A L I Z A T I O N                                 |
//|-----------------------------------------------------------------------------------------|
bool SqLiteCreate(int acctNo, string symbol, int period, string eaName)
{
   bool  Init   = false;
   bool  isOk;
   int   r;
    
//--- Assert Check if db exists, e.g. "Acc440660-Growthbot"
   SqLiteName=StringConcatenate("AccNo",acctNo,"-",symbol,"-",period,"-",eaName,".db");
    
//--- Assert Database is opened for the FIRST time.
   if( !IsTableExists(SqLiteName,AdTable) ) Init = true;
   
   if(Init)
   {
   //--- Assert create table AccountDetails: BrokerName, AccountNo, Currency, Balance, Equity
      isOk=true;
         isOk=isOk && DbCreateTable(SqLiteName,       AdTable);
         isOk=isOk && DbAlterTableInteger(SqLiteName, AdTable, AdAccountNoStr);
         isOk=isOk && DbAlterTableText(SqLiteName,    AdTable, AdCurrencyStr);
         isOk=isOk && DbAlterTableReal(SqLiteName,    AdTable, AdBalanceStr);
         isOk=isOk && DbAlterTableReal(SqLiteName,    AdTable, AdEquityStr);
         isOk=isOk && DbAlterTableReal(SqLiteName,    AdTable, AdMarginStr);
         isOk=isOk && DbAlterTableReal(SqLiteName,    AdTable, AdProfitStr);
      if(!isOk) 
         Print("0:SqLiteCreate(",NormalizeDouble(acctNo,0),",",symbol,",",period,",",eaName,"): Assert failed create table AccountDetails.");
   //--- Assert OK table created successfully
      if( !IsTableExists(SqLiteName,AdTable) ) return(false);

   //--- Assert create table Statistics:
      isOk=true;
         isOk=isOk && DbCreateTable(SqLiteName,       StTable);
         isOk=isOk && DbAlterTableInteger(SqLiteName, StTable, StTotalTradesStr);
         isOk=isOk && DbAlterTableReal(SqLiteName,    StTable, StTotalLotsStr);
         isOk=isOk && DbAlterTableReal(SqLiteName,    StTable, StTotalProfitStr);
         isOk=isOk && DbAlterTableReal(SqLiteName,    StTable, StTotalProfitPipStr);
         isOk=isOk && DbAlterTableReal(SqLiteName,    StTable, StTotalDrawdownStr);
         isOk=isOk && DbAlterTableReal(SqLiteName,    StTable, StTotalDrawdownPipStr);
         isOk=isOk && DbAlterTableReal(SqLiteName,    StTable, StTotalMarginStr);
         isOk=isOk && DbAlterTableReal(SqLiteName,    StTable, StMaxLotsStr);
         isOk=isOk && DbAlterTableReal(SqLiteName,    StTable, StMaxProfitStr);
         isOk=isOk && DbAlterTableReal(SqLiteName,    StTable, StMaxProfitPipStr);
         isOk=isOk && DbAlterTableReal(SqLiteName,    StTable, StMaxDrawdownStr);
         isOk=isOk && DbAlterTableReal(SqLiteName,    StTable, StMaxDrawdownPipStr);
         isOk=isOk && DbAlterTableReal(SqLiteName,    StTable, StMaxMarginStr);
      if(!isOk) 
         Print("0:SqLiteCreate(",NormalizeDouble(acctNo,0),",",symbol,",",period,",",eaName,"): Assert failed create table Statistics.");
   //--- Assert OK table created successfully
      if( !IsTableExists(SqLiteName,StTable) ) return(false);

   //--- Assert create table Opened Positions:
      isOk=true;
         isOk=isOk && DbCreateTable(SqLiteName,       OpTable);
         isOk=isOk && DbAlterTableInteger(SqLiteName, OpTable, OpTicketStr);
         isOk=isOk && DbAlterTableDT(SqLiteName,      OpTable, OpOpenTimeStr);
         isOk=isOk && DbAlterTableInteger(SqLiteName, OpTable, OpTypeStr);
         isOk=isOk && DbAlterTableReal(SqLiteName,    OpTable, OpLotsStr);
         isOk=isOk && DbAlterTableReal(SqLiteName,    OpTable, OpOpenPriceStr);
         isOk=isOk && DbAlterTableReal(SqLiteName,    OpTable, OpStopLossStr);
         isOk=isOk && DbAlterTableReal(SqLiteName,    OpTable, OpTakeProfitStr);
         isOk=isOk && DbAlterTableReal(SqLiteName,    OpTable, OpCurPriceStr);
         isOk=isOk && DbAlterTableReal(SqLiteName,    OpTable, OpSwapStr);
         isOk=isOk && DbAlterTableReal(SqLiteName,    OpTable, OpProfitStr);
         isOk=isOk && DbAlterTableDT(SqLiteName,      OpTable, OpExpirationStr);
         isOk=isOk && DbAlterTableDT(SqLiteName,      OpTable, OpCloseTimeStr);
         isOk=isOk && DbAlterTableText(SqLiteName,    OpTable, OpMagicNoStr);
         isOk=isOk && DbAlterTableText(SqLiteName,    OpTable, OpAccountNoStr);
         isOk=isOk && DbAlterTableText(SqLiteName,    OpTable, OpSymbolStr);
         isOk=isOk && DbAlterTableText(SqLiteName,    OpTable, OpCommentStr);
         isOk=isOk && DbAlterTableText(SqLiteName,    OpTable, OpExpertNameStr);
      if(!isOk) 
         Print("0:SqLiteCreate(",NormalizeDouble(acctNo,0),",",symbol,",",period,",",eaName,"): Assert failed create table OpenedPositions.");
   //--- Assert OK table created successfully
      if( !IsTableExists(SqLiteName,OpTable) ) return(false);

   //--- Assert create table Trade History:
      isOk=true;
         isOk=isOk && DbCreateTable(SqLiteName,       ThTable);
         isOk=isOk && DbAlterTableInteger(SqLiteName, ThTable, ThTicketStr);
         isOk=isOk && DbAlterTableDT(SqLiteName,      ThTable, ThOpenTimeStr);
         isOk=isOk && DbAlterTableInteger(SqLiteName, ThTable, ThTypeStr);
         isOk=isOk && DbAlterTableReal(SqLiteName,    ThTable, ThLotsStr);
         isOk=isOk && DbAlterTableReal(SqLiteName,    ThTable, ThOpenPriceStr);
         isOk=isOk && DbAlterTableReal(SqLiteName,    ThTable, ThStopLossStr);
         isOk=isOk && DbAlterTableReal(SqLiteName,    ThTable, ThTakeProfitStr);
         isOk=isOk && DbAlterTableReal(SqLiteName,    ThTable, ThClosePriceStr);
         isOk=isOk && DbAlterTableReal(SqLiteName,    ThTable, ThSwapStr);
         isOk=isOk && DbAlterTableReal(SqLiteName,    ThTable, ThProfitStr);
         isOk=isOk && DbAlterTableDT(SqLiteName,      ThTable, ThExpirationStr);
         isOk=isOk && DbAlterTableDT(SqLiteName,      ThTable, ThCloseTimeStr);
         isOk=isOk && DbAlterTableText(SqLiteName,    ThTable, ThMagicNoStr);
         isOk=isOk && DbAlterTableText(SqLiteName,    ThTable, ThAccountNoStr);
         isOk=isOk && DbAlterTableText(SqLiteName,    ThTable, ThSymbolStr);
         isOk=isOk && DbAlterTableText(SqLiteName,    ThTable, ThCommentStr);
         isOk=isOk && DbAlterTableText(SqLiteName,    ThTable, ThExpertNameStr);
      if(!isOk) 
         Print("0:SqLiteCreate(",NormalizeDouble(acctNo,0),",",symbol,",",period,",",eaName,"): Assert failed create table TradeHistory.");
   //--- Assert OK table created successfully
      if( !IsTableExists(SqLiteName,ThTable) ) return(false);

   //--- Assert Populate AccountDetails: AccountNo, Currency, Balance
      r=SqLiteCreateRow(AdTable);
      if(r<=0) return(false);
      isOk=true;
         isOk=isOk && SqLitePutInteger(AdTable,r,     AdAccountNoStr,   AccountNumber());
         isOk=isOk && SqLitePutText(AdTable,r,        AdCurrencyStr,    AccountCurrency());
         isOk=isOk && SqLitePutReal(AdTable,r,        AdBalanceStr,     AccountBalance());
         isOk=isOk && SqLitePutReal(AdTable,r,        AdEquityStr,      AccountEquity());
      if(!isOk)
      {
         Print("0:SqLiteCreate(",NormalizeDouble(acctNo,0),",",symbol,",",period,",",eaName,"): Assert failed populate AccountDetails.");
         return(false);
      }

   //--- Assert Populate Statistics: 
      r=SqLiteCreateRow(StTable);
      if(r<=0) 
      {
         Print("0:SqLiteCreate(",NormalizeDouble(acctNo,0),",",symbol,",",period,",",eaName,"): Assert failed populate Statistics.");
         return(false);
      }
      
      if(GhostDebug>=1) Print(GhostDebug,":SqLiteCreate(",NormalizeDouble(acctNo,0),",",symbol,",",period,",",eaName,"): r=",r,";SqLiteName=",SqLiteName," created successfully.");
   }
   return(true);    
}

//|-----------------------------------------------------------------------------------------|
//|                               M A I N   P R O C E D U R E                               |
//|-----------------------------------------------------------------------------------------|
void SqLiteManager()
{
   int handle;
   int lastCol;
   int id;
   string exp;
   double bal;
   double calcProfit;
   double closePrice;
   double openPrice;
   double openSL;
   double openTP;
   int    type;
   string sym;
    
   exp="SELECT * FROM "+OpTable;
    
//--- Assert query will lock database
   lastCol=DbLockQuery(SqLiteName, handle, exp);
   {
      if(lastCol>0) while( DbNextRow(handle) )
      {
         type        = SqLiteGetInteger(handle, OpType);
         sym         = SqLiteGetText(handle,    OpSymbol);
      //--- Assert get real-time info
         openPrice   = SqLiteGetReal(handle,    OpOpenPrice);
         openSL      = SqLiteGetReal(handle,    OpStopLoss);
         openTP      = SqLiteGetReal(handle,    OpTakeProfit);
         if(type==OP_BUY)
         {
            closePrice = MarketInfo( sym, MODE_BID );
            if(   (openSL!=0.0 && closePrice<=openSL) ||
                  (openTP!=0.0 && closePrice>=openTP) )
            {
            //--- Assert calculate profit/loss
               calcProfit=(closePrice-openPrice)*TurtleBigValue(sym)/Pts;
               
               id=SqLiteGetId(handle);
               break;
            }
         }
         else if(type==OP_SELL)
         {
            closePrice = MarketInfo( sym, MODE_ASK );
            if(   (openSL!=0.0 && closePrice>=openSL) ||
                  (openTP!=0.0 && closePrice<=openTP) )
            {
            //--- Assert calculate profit/loss
               calcProfit=(openPrice-closePrice)*TurtleBigValue(sym)/Pts;

               id=SqLiteGetId(handle);
               break;
            }
         }
      }
   }
//--- Assert unlock database
   DbFreeQuery(handle);
 
//--- Assert adjustment to account details using BigValue
   if(calcProfit!=0.0)
   {
      bal=SqLiteAccountBalance();
      SqLitePutReal(AdTable,1,AdBalanceStr,  bal+calcProfit);
   
      if(id>0) SqLiteDeleteRow(OpTable,id);

   //--- Debug    
      if(GhostDebug>=1)   Print(GhostDebug,":SqLiteManager(): id=",id,";openPrice=",NormalizeDouble(openPrice,5),";closePrice=",NormalizeDouble(closePrice,5),";openSL=",NormalizeDouble(openSL,5),";openTP=",NormalizeDouble(openTP,5),";calcProfit=",calcProfit);
   }
}

//|-----------------------------------------------------------------------------------------|
//|                             T E R M I N A L   B U F F E R S                             |
//|-----------------------------------------------------------------------------------------|
void SqLiteLoadBuffers()
{
   int handle;
   int lastCol;
   int id;
   string exp;
   int lastErr, digits, r;
   double calcProfit;
   double calcProfitPip;
   double closePrice;
   double lots;
   double mgn;
   double openPrice;
   double pts;
   int    type;
   string sym;

//--- Assert statistics gathering
   double maxLots; 
   double maxProfit; 
   double maxProfitPip;
   double maxDrawdown;
   double maxDrawdownPip;
   double maxMargin;
   int    totalTrades;
   double totalLots;
   double totalProfitPip;
   double totalMargin;
   bool   bTotalTrades;
   bool   bTotalLots;
   bool   bTotalProfit;
   bool   bTotalProfitPip;
   bool   bTotalDrawdown;
   bool   bTotalDrawdownPip;
   bool   bTotalMargin;
   bool   bMaxLots; 
   bool   bMaxProfit; 
   bool   bMaxProfitPip;
   bool   bMaxDrawdown;
   bool   bMaxDrawdownPip;
   bool   bMaxMargin;
    
   GhostCurOpenPositions=0; GhostCurPendingOrders=0; GhostSummProfit=0.0;
    
//--- Assert load opened positions (exclude pending orders)
   exp="SELECT * FROM "+OpTable+" WHERE "+OpTypeStr+"<="+OP_SELL;
    
//--- Assert query will lock database
   lastCol=DbLockQuery(SqLiteName, handle, exp);
   {
      if(lastCol>0) while( DbNextRow(handle) )
      {
         type     = SqLiteGetInteger(handle,    OpType);
         sym      = SqLiteGetText(handle,    OpSymbol);
         lots     = SqLiteGetReal(handle,    OpLots);
         openPrice= SqLiteGetReal(handle,    OpOpenPrice);
         digits = MarketInfo( sym, MODE_DIGITS );
         pts = MarketInfo( sym, MODE_POINT );

         GhostOpenPositions[GhostCurOpenPositions][TwTicket]     = DoubleToStr( SqLiteGetInteger(handle,    OpTicket), 0 );
         GhostOpenPositions[GhostCurOpenPositions][TwOpenTime]   = TimeToStr( SqLiteGetDT(handle,           OpOpenTime) );
         GhostOpenPositions[GhostCurOpenPositions][TwType]       = OrderTypeToStr( type );
         GhostOpenPositions[GhostCurOpenPositions][TwLots]       = DoubleToStr( lots, 1 );
         GhostOpenPositions[GhostCurOpenPositions][TwOpenPrice]  = DoubleToStr( openPrice, digits );
         GhostOpenPositions[GhostCurOpenPositions][TwStopLoss]   = DoubleToStr( SqLiteGetReal(handle,       OpStopLoss), digits );
         GhostOpenPositions[GhostCurOpenPositions][TwTakeProfit] = DoubleToStr( SqLiteGetReal(handle,       OpTakeProfit), digits );
      //--- Assert get close price and calculate margin and profit
         mgn = MarketInfo( sym, MODE_MARGINREQUIRED ) * lots;
         calcProfit = 0.0; calcProfitPip = 0.0;
         if( type == OP_BUY )
         {
            closePrice = MarketInfo( sym, MODE_BID );
         //--- Assert calculate profits
            calcProfit     = (closePrice-openPrice)*lots*TurtleBigValue(Symbol())/pts;
            calcProfitPip  = (closePrice-openPrice)/Pts;
         }
         else if( type == OP_SELL )
         {
            closePrice = MarketInfo( sym, MODE_ASK );
         //--- Assert calculate profits
            calcProfit     = (openPrice-closePrice)*lots*TurtleBigValue(Symbol())/pts;
            calcProfitPip  = (openPrice-closePrice)/Pts;
         }
         GhostOpenPositions[GhostCurOpenPositions][TwCurPrice]   = DoubleToStr( closePrice, digits ); 
         GhostOpenPositions[GhostCurOpenPositions][TwSwap]       = DoubleToStr( SqLiteGetReal(handle,       OpSwap), 2 );
         GhostOpenPositions[GhostCurOpenPositions][TwProfit]     = DoubleToStr( calcProfit, 2 );
         GhostOpenPositions[GhostCurOpenPositions][TwComment]    = SqLiteGetText(handle,                    OpComment);

      //--- Assert record statistics for SINGLE trade
         if( lots>0 &&           lots > maxLots )                 maxLots = lots;
         if( calcProfit>0 &&     calcProfit > maxProfit )         maxProfit = calcProfit;
         if( calcProfitPip>0 &&  calcProfitPip > maxProfitPip )   maxProfitPip = calcProfitPip;
         if( calcProfit<0 &&     calcProfit < maxDrawdown )       maxDrawdown = calcProfit;
         if( calcProfitPip<0 &&  calcProfitPip < maxDrawdownPip ) maxDrawdownPip = calcProfitPip;
         if( mgn>0 &&            mgn > maxMargin )                maxMargin = mgn;
         
      //--- Increment row
         totalLots         += lots;
         totalMargin       += mgn;
         GhostSummProfit   += calcProfit;
         totalProfitPip    += calcProfitPip;
         GhostCurOpenPositions ++;
         if ( GhostCurOpenPositions >= GhostRows ) { break; }
      }
   }
//--- Assert unlock database
   DbFreeQuery(handle);
   
//--- Assert retrieve record of statistics details
   exp="SELECT * FROM "+StTable+" WHERE id=1";
    
//--- Assert query will lock database
   lastCol=DbLockQuery(SqLiteName, handle, exp);
   {
      if(lastCol>0) DbNextRow(handle);
      bTotalTrades =       GhostCurOpenPositions > SqLiteGetInteger(handle,                  StTotalTrades);
      bTotalLots =         totalLots > SqLiteGetReal(handle,                                 StTotalLots);
      bTotalProfit =       GhostSummProfit>0.0 && GhostSummProfit > SqLiteGetReal(handle,    StTotalProfit);
      bTotalProfitPip =    totalProfitPip>0.0 && totalProfitPip > SqLiteGetReal(handle,      StTotalProfitPip);
      bTotalDrawdown =     GhostSummProfit<0.0 && GhostSummProfit > SqLiteGetReal(handle,    StTotalDrawdown);
      bTotalDrawdownPip =  totalProfitPip<0.0 && totalProfitPip > SqLiteGetReal(handle,      StTotalDrawdownPip);
      bTotalMargin =       totalMargin > SqLiteGetReal(handle,                               StTotalMargin);
      bMaxLots =        maxLots > SqLiteGetReal(handle,        StMaxLots);
      bMaxProfit =      maxProfit > SqLiteGetReal(handle,      StMaxProfit);
      bMaxProfitPip =   maxProfitPip > SqLiteGetReal(handle,   StMaxProfitPip);
      bMaxDrawdown =    maxDrawdown > SqLiteGetReal(handle,    StMaxDrawdown);
      bMaxDrawdownPip = maxDrawdownPip > SqLiteGetReal(handle, StMaxDrawdownPip);
      bMaxMargin =      maxMargin > SqLiteGetReal(handle,      StMaxMargin);
   }
//--- Assert unlock database
   DbFreeQuery(handle);
   
//--- Assert record AGGREGATE statistics
   if( bTotalTrades ) SqLitePutInteger(StTable,1,StTotalTradesStr,          GhostCurOpenPositions);
   if( bTotalLots ) SqLitePutReal(StTable,1,StTotalLotsStr,                 totalLots);
   if( bTotalProfit ) SqLitePutReal(StTable,1,StTotalProfitStr,             GhostSummProfit);
   if( bTotalProfitPip ) SqLitePutReal(StTable,1,StTotalProfitPipStr,       totalProfitPip);
   if( bTotalDrawdown ) SqLitePutReal(StTable,1,StTotalDrawdownStr,         GhostSummProfit);
   if( bTotalDrawdownPip ) SqLitePutReal(StTable,1,StTotalDrawdownPipStr,   totalProfitPip);
   if( bTotalMargin ) SqLitePutReal(StTable,1,StTotalMarginStr,             totalMargin);
//--- Assert record statistics for SINGLE trade
   if( bMaxLots ) SqLitePutReal(StTable,1,StMaxLotsStr,                 maxLots);
   if( bMaxProfit ) SqLitePutReal(StTable,1,StMaxProfitStr,             maxProfit);
   if( bMaxProfitPip ) SqLitePutReal(StTable,1,StMaxProfitPipStr,       maxProfitPip);
   if( bMaxDrawdown ) SqLitePutReal(StTable,1,StMaxDrawdownStr,         maxDrawdown);
   if( bMaxDrawdownPip ) SqLitePutReal(StTable,1,StMaxDrawdownPipStr,   maxDrawdownPip);
   if( bMaxMargin ) SqLitePutReal(StTable,1,StMaxMarginStr,             maxMargin);

//--- Assert load pending orders (exclude opened positions)
   exp="SELECT * FROM "+PoTable+" WHERE "+PoTypeStr+">"+OP_SELL;
    
//--- Assert query will lock database
   lastCol=DbLockQuery(SqLiteName, handle, exp);
   {
      if(lastCol>0) while( DbNextRow(handle) )
      {
         type     = SqLiteGetInteger(handle, PoType);
         sym      = SqLiteGetText(handle,    PoSymbol);
         lots     = SqLiteGetReal(handle,    PoLots);
         openPrice= SqLiteGetReal(handle,    PoOpenPrice);
         digits = MarketInfo( sym, MODE_DIGITS );

         GhostPendingOrders[GhostCurPendingOrders][TwTicket]      = DoubleToStr( SqLiteGetInteger(handle,   PoTicket), 0 );
         GhostPendingOrders[GhostCurPendingOrders][TwOpenTime]    = TimeToStr( SqLiteGetDT(handle,          PoOpenTime) );
         GhostPendingOrders[GhostCurPendingOrders][TwType]        = OrderTypeToStr( type );
         GhostPendingOrders[GhostCurPendingOrders][TwLots]        = DoubleToStr( lots, 1 );
         GhostPendingOrders[GhostCurPendingOrders][TwOpenPrice]   = DoubleToStr( openPrice, digits );
         GhostPendingOrders[GhostCurPendingOrders][TwStopLoss]    = DoubleToStr( SqLiteGetReal(handle,      PoStopLoss), digits );
         GhostPendingOrders[GhostCurPendingOrders][TwTakeProfit]  = DoubleToStr( SqLiteGetReal(handle,      PoTakeProfit), digits );
         if( type == OP_SELLSTOP || type == OP_SELLLIMIT )
            GhostPendingOrders[GhostCurPendingOrders][TwCurPrice] = DoubleToStr( MarketInfo( sym, MODE_BID ), digits );
         else
            GhostPendingOrders[GhostCurPendingOrders][TwCurPrice] = DoubleToStr( MarketInfo( sym, MODE_ASK ), digits ); 
         GhostPendingOrders[GhostCurPendingOrders][TwSwap]        = DoubleToStr( SqLiteGetReal(handle,      PoSwap), 2 );
         GhostPendingOrders[GhostCurPendingOrders][TwProfit]      = DoubleToStr( 0, 2 );
         GhostPendingOrders[GhostCurPendingOrders][TwComment]     = SqLiteGetText(handle,                   PoComment);
         
      //--- Increment row
         GhostCurPendingOrders ++;
         if( GhostCurOpenPositions + GhostCurPendingOrders >= GhostRows ) { break; }
      }
   }
//--- Assert unlock database
   DbFreeQuery(handle);

//--- Assert record ACCOUNT details
   SqLitePutReal(AdTable,1,AdEquityStr,   GhostSummProfit+SqLiteAccountBalance());
   SqLitePutReal(AdTable,1,AdMarginStr,   totalMargin);
   SqLitePutReal(AdTable,1,AdProfitStr,   GhostSummProfit);
   
   GhostReorderBuffers();
}

//|-----------------------------------------------------------------------------------------|
//|                             D E I N I T I A L I Z A T I O N                             |
//|-----------------------------------------------------------------------------------------|
void SqLiteDeInit()
{
}

//|-----------------------------------------------------------------------------------------|
//|                                 O P E N   O R D E R S                                   |
//|-----------------------------------------------------------------------------------------|
int SqLiteOrderSend(string sym, int type, double lots, double price, int slip, double SL, double TP, string cmt="", int mgc=0, datetime exp=0, color arrow=CLR_NONE)
{
   int handle;
   int lastCol;
   int id;
   bool isOk;
   double openPrice;
   double openSL;
   double openTP;
   int    openTime;

//--- Assert Create new ticket in OpenedPositions
   if(type==OP_BUY || type==OP_SELL)
   {
      id=SqLiteCreateRow(OpTable);
      if(id<=0) return(-1);
   
   //--- Assert get real-time info.
      if(type==OP_BUY)
      {
         openPrice = MarketInfo( sym, MODE_ASK ); 
         if(SL!=0.0) openSL=NormalizeDouble(openPrice-SL*Pts,Digits);
         if(TP!=0.0) openTP=NormalizeDouble(openPrice+TP*Pts,Digits);
      }
      else
      {
         openPrice = MarketInfo( sym, MODE_BID ); 
         if(SL!=0.0) openSL=NormalizeDouble(openPrice+SL*Pts,Digits);
         if(TP!=0.0) openTP=NormalizeDouble(openPrice-TP*Pts,Digits);
      }
      openTime=TimeCurrent(); //server
      
      isOk=true;
         isOk=isOk && SqLitePutInteger(OpTable,id,OpTicketStr,    id);
         isOk=isOk && SqLitePutDT(OpTable,id,OpOpenTimeStr,       openTime);
         isOk=isOk && SqLitePutInteger(OpTable,id,OpTypeStr,      type);
         isOk=isOk && SqLitePutReal(OpTable,id,OpLotsStr,         lots);
         isOk=isOk && SqLitePutReal(OpTable,id,OpOpenPriceStr,    openPrice);
         isOk=isOk && SqLitePutReal(OpTable,id,OpStopLossStr,     openSL);
         isOk=isOk && SqLitePutReal(OpTable,id,OpTakeProfitStr,   openTP);
         //isOk=isOk && SqLitePutReal(OpTable,id,OpCurPriceStr,     0.0);
         //isOk=isOk && SqLitePutReal(OpTable,id,OpSwapStr,         0.0);
         //isOk=isOk && SqLitePutReal(OpTable,id,OpProfitStr,       0.0);
         //isOk=isOk && SqLitePutDT(OpTable,id,OpExpirationStr,     0);
         //isOk=isOk && SqLitePutDT(OpTable,id,OpCloseTimeStr,      closeTime);
         isOk=isOk && SqLitePutInteger(OpTable,id,OpMagicNoStr,   mgc);
         isOk=isOk && SqLitePutInteger(OpTable,id,OpAccountNoStr, SqLiteAccountNumber());
         isOk=isOk && SqLitePutText(OpTable,id,OpSymbolStr,       sym);
         isOk=isOk && SqLitePutText(OpTable,id,OpCommentStr,      cmt);
         isOk=isOk && SqLitePutText(OpTable,id,OpExpertNameStr,   GhostExpertName);
      if(!isOk) 
         Print("0:SqLiteOrderSend(",sym,",",type,",",lots,",",price,",",slip,",",SL,",",TP,",",cmt,",",mgc,",",exp,",",arrow,"): Assert failed to open order return=",id);
      else
         Print("0:SqLiteOrderSend(",sym,",",type,",",lots,",",price,",",slip,",",SL,",",TP,",",cmt,",",mgc,",",exp,",",arrow,"): OK opened order return=",id);
      return(id);
   }
}

bool SqLiteOrderModify(int ticket, double price, double SL, double TP, datetime exp, color arrow=CLR_NONE)
{
   int handle;
   int lastCol;
   int id;
   bool isOk;
   string expr;
   int type;
   double curPrice;
   double modifySL;
   double modifyTP;
   string sym;
   
//--- Assert ticket no exists in Open Positions.
   id=SqLiteFindTicket(ticket);
   if(id>0)
   {
      expr="SELECT * FROM "+OpTable+" WHERE id="+id;
    
   //--- Assert query will lock database
      lastCol=DbLockQuery(SqLiteName, handle, expr);
      {
         if(lastCol>0) DbNextRow(handle);
         type     = SqLiteGetInteger(handle,    OpType);
         sym      = SqLiteGetText(handle,       OpSymbol);
      }
   //--- Assert unlock database
      DbFreeQuery(handle);
      
      if( type <= OP_SELL )
      {
         isOk=true;
            isOk=isOk && SqLitePutReal(OpTable,id,OpStopLossStr,     SL);
            isOk=isOk && SqLitePutReal(OpTable,id,OpTakeProfitStr,   TP);
            isOk=isOk && SqLitePutDT(OpTable,id,OpExpirationStr,     exp);
         if(!isOk) 
            Print("0:SqLiteOrderModify(",ticket,",",price,",",SL,",",TP,",",exp,",",arrow,"): Assert failed to modify order ticket=",ticket);
         else
            Print("0:SqLiteOrderModify(",ticket,",",price,",",SL,",",TP,",",exp,",",arrow,"): return=true; isOk=true; id=",id);
         return(true);
      }
   }

//--- Assert ticket not found.
//--- Debug    
   if(GhostDebug>=1)   Print(GhostDebug,":SqLiteOrderModify(",ticket,",",price,",",SL,",",TP,",",exp,",",arrow,"): return=false");
   return(false);
}
//|-----------------------------------------------------------------------------------------|
//|                                O R D E R S   S T A T U S                                |
//|-----------------------------------------------------------------------------------------|
int SqLiteFindTicket(int ticket)
{
   int handle;
   int lastCol;
   int id;
   string exp;
    
   exp="SELECT id FROM "+OpTable+" WHERE "+OpTicketStr+"="+ticket;
    
//--- Assert query will lock database
   lastCol=DbLockQuery(SqLiteName, handle, exp);
   {
      if(lastCol>0) DbNextRow(handle);
      id=SqLiteGetId(handle);
   }
//--- Assert unlock database
   DbFreeQuery(handle);
    
//--- Debug    
   if(id<=0) 
   {
      if(GhostDebug>=3)   Print(GhostDebug,":SqLiteFindTicket(",ticket,"): return=-1");
      return(-1);
   }

   if(GhostDebug>=3)   Print(GhostDebug,":SqLiteFindTicket(",ticket,"): return=",id);
   return(id);
}

int SqLiteOrdersTotal()
{
   int handle;
   int lastCol;
   int count;
   string exp;
    
   exp="SELECT COUNT(id) FROM "+OpTable;
//--- Assert query will lock database
   lastCol=DbLockQuery(SqLiteName, handle, exp);
   {
      if(lastCol>0) DbNextRow(handle);
      count=SqLiteGetInteger(handle,0);
   }
//--- Assert unlock database
   DbFreeQuery(handle);
    
   return(count);
}

int SqLiteOrdersHistoryTotal()
{
   int handle;
   int lastCol;
   int count;
   string exp;
    
   exp="SELECT COUNT(id) FROM "+ThTable;
//--- Assert query will lock database
   lastCol=DbLockQuery(SqLiteName, handle, exp);
   {
      if(lastCol>0) DbNextRow(handle);
      count=SqLiteGetInteger(handle,0);
   }
//--- Assert unlock database
   DbFreeQuery(handle);
    
   return(count);
}

bool SqLiteInitSelect(bool asc, int select, int pool=MODE_TRADES)
{
//--- Assert init called before OrderSelect().
   if(select==SELECT_BY_POS)
   {
      if(pool==MODE_TRADES)         { return(SqLiteInitTradesSelect(asc)); }
      else if(pool==MODE_HISTORY)   { return(SqLiteInitHistorySelect(asc)); }
   }
   
//--- Assert unlock database using SqLiteFreeSelect(); called after OrderSelect().
}

bool SqLiteInitTradesSelect(bool asc)
{
   int lastCol;
   string exp;
   string ord;

   SqLiteSelectTotal=SqLiteOrdersTotal();
   
//--- Assert order by ascending or descending
   if(asc) 
      SqLiteSelectIndex=-1;
   else
   {
      SqLiteSelectIndex=SqLiteSelectTotal;
      ord=" ORDER BY id DESC"; 
   }
   SqLiteSelectAsc=asc;

//--- Find total orders
   exp="SELECT * FROM "+OpTable+ord;
    
//--- Assert query will lock database
   lastCol=DbLockQuery(SqLiteName, SqLiteSelectHandle, exp);
//--- Debug    
   if(GhostDebug>=2) if(SqLiteSelectTotal>0) Print(SqLiteSelectHandle,":SqLiteInitTradesSelect(",asc,"): exp=",exp,"; SqLiteSelectIndex=",SqLiteSelectIndex,"; SqLiteSelectTotal=",SqLiteSelectTotal);
   return(lastCol>0);
}

bool SqLiteInitHistorySelect(bool asc)
{
   int lastCol;
   string exp;
   string ord;

   SqLiteSelectTotal=SqLiteOrdersHistoryTotal();
   
//--- Assert order by ascending or descending
   if(asc) 
      SqLiteSelectIndex=-1;
   else
   {
      SqLiteSelectIndex=SqLiteSelectTotal;
      ord=" ORDER BY id DESC"; 
   }
   SqLiteSelectAsc=asc;

//--- Find total orders
   exp="SELECT * FROM "+ThTable+ord;
    
//--- Assert query will lock database
   lastCol=DbLockQuery(SqLiteName, SqLiteSelectHandle, exp);
//--- Debug    
   if(GhostDebug>=2) if(SqLiteSelectTotal>0) Print(SqLiteSelectHandle,":SqLiteInitHistorySelect(",asc,"): exp=",exp,"; SqLiteSelectIndex=",SqLiteSelectIndex,"; SqLiteSelectTotal=",SqLiteSelectTotal);
   return(lastCol>0);
}

bool SqLiteOrderSelect(int index, int select, int pool=MODE_TRADES)
{
   bool init;
   bool ret;
   int lastCol;
   int id;
   string exp;
   
   SqLiteSelectMode=pool;
   
//--- Assert SELECT_BY_TICKET index is order ticket.
   if(select==SELECT_BY_TICKET)
   {
   //--- Find order by ticket
      exp="SELECT id FROM "+OpTable+" WHERE "+OpTicketStr+"="+index;
    
      //--- Assert query will lock database
      lastCol=DbLockQuery(SqLiteName, SqLiteSelectHandle, exp);
      {
         if(lastCol>0) DbNextRow(SqLiteSelectHandle);
         id=SqLiteGetId(SqLiteSelectHandle);
      }
   //--- Assert unlock database using SqLiteFreeSelect(); called after OrderSelect().
    
   //--- Debug    
      if(id<=0) 
      {
         if(GhostDebug>=2)   Print(GhostDebug,":SqLiteOrderSelect(",index,",",select,",",pool,"): id=-1");
         return(false);
      }
      else
      {
         if(GhostDebug>=2)   Print(GhostDebug,":SqLiteOrderSelect(",index,",",select,",",pool,"): id=",id);
         return(true);
      }
   }
//--- Assert SELECT_BY_POS where index=0 is first row.
   else if(select==SELECT_BY_POS)
   {
   //--- Assert init using SqLiteInitSelect(); called before OrderSelect().
      if(pool==MODE_TRADES)         { return(SqLiteOrderTradesSelect(index)); }
      else if(pool==MODE_HISTORY)   { return(SqLiteOrderHistorySelect(index)); }
      
   //--- Assert unlock database using SqLiteFreeSelect(); called after OrderSelect().
   }
}

bool SqLiteOrderTradesSelect(int index)
{
   string dbg;
   bool ret;
   
//--- Debug    
   dbg=SqLiteSelectHandle+":SqLiteOrderTradesSelect("+index+")";
   
//--- Assert increment if ascending 
   if(SqLiteSelectAsc) 
   {
      
   //--- Debug    
      dbg=dbg+": Asc";

      if(index>SqLiteSelectIndex && index<SqLiteSelectTotal) 
      {
      //--- Debug    
         dbg=dbg+"; "+index+">"+SqLiteSelectIndex+" && "+index+"<"+SqLiteSelectTotal;
         
         while( SqLiteSelectIndex < index - 1 ) 
         { 
            if( !DbNextRow(SqLiteSelectHandle) ) return(false);
            SqLiteSelectIndex ++;
         }
         SqLiteSelectIndex = index;
         ret=DbNextRow(SqLiteSelectHandle);

      //--- Debug    
         dbg=dbg+"; SqLiteSelectIndex="+index+"; id="+SqLiteGetId(SqLiteSelectHandle)+"; ret="+ret;
         if(GhostDebug>=2) if(SqLiteSelectTotal>0) Print(dbg);

         return(ret);
      }
   }
//--- Assert decrement if descending
   else
   {
      
   //--- Debug    
      dbg=dbg+": Dsc";
      if(index<SqLiteSelectIndex && index>=0)
      {
      //--- Debug    
         dbg=dbg+"; "+index+"<"+SqLiteSelectIndex+" && "+index+">=0";
         
         while( SqLiteSelectIndex > index + 1 ) 
         { 
            if( !DbNextRow(SqLiteSelectHandle) ) return(false);
            SqLiteSelectIndex --;
         }
         SqLiteSelectIndex = index;
         ret=DbNextRow(SqLiteSelectHandle);
      
      //--- Debug    
         dbg=dbg+"; SqLiteSelectIndex="+index+"; id="+SqLiteGetId(SqLiteSelectHandle)+"; ret="+ret;
         if(GhostDebug>=2) if(SqLiteSelectTotal>0) Print(dbg);
         
         return(ret);
      }
   }
   return(false);
}

bool SqLiteOrderHistorySelect(int index)
{
   return(SqLiteOrderTradesSelect(index));
}

void SqLiteFreeSelect()
{
//--- Debug    
   if(GhostDebug>=2) if(SqLiteSelectTotal>0) Print(SqLiteSelectHandle,":SqLiteFreeSelect(): SqLiteSelectIndex=",SqLiteSelectIndex);
   
//--- Assert clear global select variables
   SqLiteSelectIndex=-1;
   SqLiteSelectTotal=0;
   
//--- Assert unlock database using SqLiteFreeSelect(); called after OrderSelect().
   sqlite_free_query(SqLiteSelectHandle);
}

double SqLiteOrderClosePrice()
{
   switch(SqLiteSelectMode)
   {
      case MODE_HISTORY:   return( SqLiteGetReal(SqLiteSelectHandle,ThClosePrice) );
      case MODE_TRADES:
      default:             return( SqLiteGetReal(SqLiteSelectHandle,PoClosePrice) );
   }
   return(0.0);
}
datetime SqLiteOrderCloseTime()
{
   switch(SqLiteSelectMode)
   {
      case MODE_HISTORY:   return( SqLiteGetDT(SqLiteSelectHandle,ThCloseTime) );
      case MODE_TRADES:
      default:             return( SqLiteGetDT(SqLiteSelectHandle,PoClosePrice) );
   }
   return(0);
}
string SqLiteOrderComment()
{
   switch(SqLiteSelectMode)
   {
      case MODE_HISTORY:   return( SqLiteGetText(SqLiteSelectHandle,ThComment) );
      case MODE_TRADES:
      default:             return( SqLiteGetText(SqLiteSelectHandle,OpComment) );
   }
   return("");
}
datetime SqLiteOrderExpiration()
{
   switch(SqLiteSelectMode)
   {
      case MODE_HISTORY:   return( SqLiteGetDT(SqLiteSelectHandle,ThExpiration) );
      case MODE_TRADES:
      default:             return( SqLiteGetDT(SqLiteSelectHandle,PoExpiration) );
   }
   return(0);
}
double SqLiteOrderLots()
{
   switch(SqLiteSelectMode)
   {
      case MODE_HISTORY:   return( SqLiteGetReal(SqLiteSelectHandle,ThLots) );
      case MODE_TRADES:
      default:             return( SqLiteGetReal(SqLiteSelectHandle,OpLots) );
   }
   return(0.0);
}
int SqLiteOrderMagicNumber()
{
   switch(SqLiteSelectMode)
   {
      case MODE_HISTORY:   return( SqLiteGetInteger(SqLiteSelectHandle,ThMagicNo) );
      case MODE_TRADES:
      default:             return( SqLiteGetInteger(SqLiteSelectHandle,OpMagicNo) );
   }
   return(0);
}
double SqLiteOrderOpenPrice()
{
   switch(SqLiteSelectMode)
   {
      case MODE_HISTORY:   return( SqLiteGetReal(SqLiteSelectHandle,ThOpenPrice) );
      case MODE_TRADES:
      default:             return( SqLiteGetReal(SqLiteSelectHandle,OpOpenPrice) );
   }
   return(0.0);
}
datetime SqLiteOrderOpenTime()
{
   switch(SqLiteSelectMode)
   {
      case MODE_HISTORY:   return( SqLiteGetDT(SqLiteSelectHandle,ThOpenTime) );
      case MODE_TRADES:
      default:             return( SqLiteGetDT(SqLiteSelectHandle,OpOpenTime) );
   }
   return(0);
}
double SqLiteOrderProfit()
{
   double calcProfit;
   double closePrice;
   double lots;
   double openPrice;
   double pts;
   string sym;
   
   switch(SqLiteSelectMode)
   {
      case MODE_HISTORY:   return( SqLiteGetReal(SqLiteSelectHandle,ThProfit) );
      case MODE_TRADES:
      default:
      //--- Exclude ALL pending orders
         if ( SqLiteOrderType() > OP_SELL )  { return(0.0); }
         
      //--- Assert get lots, open and close prices
         lots        = SqLiteOrderLots();
         openPrice   = SqLiteOrderOpenPrice();
         sym         = SqLiteOrderSymbol();
         pts = MarketInfo( sym, MODE_POINT );
         if( SqLiteOrderType() == OP_BUY )
         {
            closePrice = MarketInfo( sym, MODE_BID );
            
         //--- Assert calculate profits
            calcProfit = (closePrice-openPrice)*lots*TurtleBigValue(sym)/pts;
         }
         else if( SqLiteOrderType() == OP_SELL )
         {
            closePrice = MarketInfo( sym, MODE_ASK );
            
         //--- Assert calculate profits
            calcProfit = (openPrice-closePrice)*lots*TurtleBigValue(sym)/pts;
         }
         return(calcProfit);
   }
   return(0.0);
}
double SqLiteOrderStopLoss()
{
   switch(SqLiteSelectMode)
   {
      case MODE_HISTORY:   return( SqLiteGetReal(SqLiteSelectHandle,ThStopLoss) );
      case MODE_TRADES:
      default:             return( SqLiteGetReal(SqLiteSelectHandle,OpStopLoss) );
   }
   return(0.0);
}
string SqLiteOrderSymbol()
{
   switch(SqLiteSelectMode)
   {
      case MODE_HISTORY:   return( SqLiteGetText(SqLiteSelectHandle,ThSymbol) );
      case MODE_TRADES:
      default:             return( SqLiteGetText(SqLiteSelectHandle,OpSymbol) );
   }
   return("");
}
double SqLiteOrderTakeProfit()
{
   switch(SqLiteSelectMode)
   {
      case MODE_HISTORY:   return( SqLiteGetReal(SqLiteSelectHandle,ThTakeProfit) );
      case MODE_TRADES:
      default:             return( SqLiteGetReal(SqLiteSelectHandle,OpTakeProfit) );
   }
   return(0.0);
}
int SqLiteOrderTicket()
{
   switch(SqLiteSelectMode)
   {
      case MODE_HISTORY:   return( SqLiteGetInteger(SqLiteSelectHandle,ThTicket) );
      case MODE_TRADES:
      default:             return( SqLiteGetInteger(SqLiteSelectHandle,OpTicket) );
   }
   return(0);
}
int SqLiteOrderType()
{
   switch(SqLiteSelectMode)
   {
      case MODE_HISTORY:   return( SqLiteGetInteger(SqLiteSelectHandle,ThType) );
      case MODE_TRADES:
      default:             return( SqLiteGetInteger(SqLiteSelectHandle,OpType) );
   }
   return(0);
}

double SqLiteAccountBalance()
{
    int handle;
    int lastCol;
    string exp;
    double val;
    
    exp="SELECT * FROM "+AdTable+" WHERE id=1";
    
//--- Assert query will lock database
    lastCol=DbLockQuery(SqLiteName, handle, exp);
    {
       if(lastCol>0) DbNextRow(handle);
       val=SqLiteGetReal(handle,AdBalance);
    }
//--- Assert unlock database
    DbFreeQuery(handle);

    return(val);
}
double SqLiteAccountEquity()
{
    int handle;
    int lastCol;
    string exp;
    double val;
    
    exp="SELECT * FROM "+AdTable+" WHERE id=1";
    
//--- Assert query will lock database
    lastCol=DbLockQuery(SqLiteName, handle, exp);
    {
       if(lastCol>0) DbNextRow(handle);
       val=SqLiteGetReal(handle,AdEquity);
    }
//--- Assert unlock database
    DbFreeQuery(handle);

    return(val);
}
double SqLiteAccountMargin()
{
    int handle;
    int lastCol;
    string exp;
    double val;
    
    exp="SELECT * FROM "+AdTable+" WHERE id=1";
    
//--- Assert query will lock database
    lastCol=DbLockQuery(SqLiteName, handle, exp);
    {
       if(lastCol>0) DbNextRow(handle);
       val=SqLiteGetReal(handle,AdMargin);
    }
//--- Assert unlock database
    DbFreeQuery(handle);

    return(val);
}
double SqLiteAccountFreeMargin()
{
    return(0.0);
}
int SqLiteAccountNumber()
{
    int handle;
    int lastCol;
    string exp;
    int val;
    
    exp="SELECT * FROM "+AdTable+" WHERE id=1";
    
//--- Assert query will lock database
    lastCol=DbLockQuery(SqLiteName, handle, exp);
    {
       if(lastCol>0) DbNextRow(handle);
       val=SqLiteGetInteger(handle,AdAccountNo);
    }
//--- Assert unlock database
    DbFreeQuery(handle);

    return(val);
}
double SqLiteAccountProfit()
{
    int handle;
    int lastCol;
    string exp;
    double val;
    
    exp="SELECT * FROM "+AdTable+" WHERE id=1";
    
//--- Assert query will lock database
    lastCol=DbLockQuery(SqLiteName, handle, exp);
    {
       if(lastCol>0) DbNextRow(handle);
       val=SqLiteGetReal(handle,AdProfit);
    }
//--- Assert unlock database
    DbFreeQuery(handle);

    return(val);
}

//|-----------------------------------------------------------------------------------------|
//|                                 C L O S E  O R D E R S                                  |
//|-----------------------------------------------------------------------------------------|
bool SqLiteOrderClose(int ticket, double lots, double price, int slippage, color arrow=CLR_NONE)
{
   int handle;
   int lastCol;
   int id;
   bool isOk;
   string expr;
   int type;
   double bal, calcLots, closePrice, orderLots;
   double calcProfit, openPrice, pts;
   string sym;
   
//--- Assert ticket no exists in Open Positions.
   id=SqLiteFindTicket(ticket);
   if(id>0)
   {
      expr="SELECT * FROM "+OpTable+" WHERE id="+id;
    
   //--- Assert query will lock database
      lastCol=DbLockQuery(SqLiteName, handle, expr);
      {
         if(lastCol>0) DbNextRow(handle);
         type     = SqLiteGetInteger(handle,    OpType);
         sym      = SqLiteGetText(handle,       OpSymbol);
         orderLots= SqLiteGetReal(handle,       OpLots);
         openPrice= SqLiteGetReal(handle,       OpOpenPrice);
      }
   //--- Assert unlock database
      DbFreeQuery(handle);
      
      if( type <= OP_SELL )
      {
      //--- Assert check if partial close or full close.
         if( lots >= orderLots )
            calcLots = orderLots;
         else
            calcLots = lots;
      //--- Assert get close price and calculate profits
         pts = MarketInfo( sym, MODE_POINT );
         if( type == OP_BUY )
         {
            closePrice = MarketInfo( sym, MODE_BID );
         //--- Assert calculate profits      
            calcProfit = (closePrice-openPrice)*calcLots*TurtleBigValue(Symbol())/pts;
         }
         else if( type == OP_SELL )
         {
            closePrice = MarketInfo( sym, MODE_ASK );
         //--- Assert calculate profits      
            calcProfit = (openPrice-closePrice)*calcLots*TurtleBigValue(Symbol())/pts;
         }
      //--- Assert adjustment to account details using BigValue.
         isOk=true;
            bal=SqLiteAccountBalance();
            isOk=isOk && SqLitePutReal(AdTable,1,AdBalanceStr,    bal+calcProfit);
      //--- Assert partial close to update Lots in row; otherwise delete entire row.
         if( calcLots < orderLots )
         {
            isOk=isOk && SqLitePutReal(OpTable,id,OpLotsStr,      orderLots-calcLots);
         }
         else
         {
            isOk=isOk && SqLiteDeleteRow(OpTable,id);
         }
         if(!isOk) 
            Print("0:SqLiteOrderClose(",ticket,",",lots,",",price,",",slippage,",",arrow,"): Assert failed to close order ticket=",ticket);
         else
            Print("0:SqLiteOrderClose(",ticket,",",lots,",",price,",",slippage,",",arrow,"): Ok closed trade calcProfit=",calcProfit);
         return(true);
      }
   }

//--- Assert ticket not found.
//--- Debug    
   if(GhostDebug>=1)   Print(GhostDebug,":SqLiteOrderClose(",ticket,",",lots,",",price,",",slippage,",",arrow,"): return=false");
   return(false);
}

//|-----------------------------------------------------------------------------------------|
//|                              S Q L I T E   F U N C T I O N S                            |
//|-----------------------------------------------------------------------------------------|
bool IsTableExists(string db, string table)
{
    int err=sqlite_table_exists(db,table);
    if(err<0)
    {
        Print("0:Check for table "+table+" existence. Error Code: "+err);
        return(false);
    }
    return(err>0);
}

bool DbCreateTable(string db, string table)
{
    string exp="CREATE TABLE "+table+" (id INTEGER PRIMARY KEY ASC)";
    return(DbExec(db,exp));
}

bool DbAlterTableText(string db, string table, string field)
{
    string exp="ALTER TABLE "+table+" ADD COLUMN "+field+" TEXT NOT NULL DEFAULT ''";
    return(DbExec(db,exp));
}

bool DbAlterTableInteger(string db, string table, string field)
{
    string exp="ALTER TABLE "+table+" ADD COLUMN "+field+" INTEGER NOT NULL DEFAULT '0'";
    return(DbExec(db,exp));
}

bool DbAlterTableReal(string db, string table, string field)
{
    string exp="ALTER TABLE "+table+" ADD COLUMN "+field+" REAL NOT NULL DEFAULT '0.0'";
    return(DbExec(db,exp));
}

bool DbAlterTableDT(string db, string table, string field)
{
//--- DT can be stored as TEXT, REAL or INTEGER
    string exp="ALTER TABLE "+table+" ADD COLUMN "+field+" INTEGER NOT NULL DEFAULT '0'";
    return(DbExec(db,exp));
}

int DbLockQuery(string db, int& handle, string query)
{
    int lastCol[1];
    handle = sqlite_query (db, query, lastCol);
    
//--- Assert return last column index, i.e. 0,1,2...n in table    
    return(lastCol[0]);
}

bool DbNextRow(int handle)
{
   if(sqlite_next_row(handle) == 1) return(true);
   else return(false);
}

int SqLiteCreateRow(string table)
{
   int handle;
   int lastCol;
   int lastRow;
    
   string exp="INSERT INTO "+table+" (id) VALUES (NULL)";
   DbExec(SqLiteName,exp);
    
   exp="SELECT MAX(id) FROM "+table;
    
//--- Assert query will lock database
   lastCol=DbLockQuery(SqLiteName, handle, exp);
   {
      if(lastCol>0) DbNextRow(handle);
      lastRow=SqLiteGetId(handle);
   }
//--- Assert unlock database
   DbFreeQuery(handle);
    
   return(lastRow);
}

int SqLiteGetId(int handle)
{
   return(StrToInteger(sqlite_get_col(handle,0)));
}

string SqLiteGetText(int handle, int col)
{
   return(sqlite_get_col(handle,col));
}

int SqLiteGetInteger(int handle, int col)
{
   return(StrToInteger(sqlite_get_col(handle,col)));
}

double SqLiteGetReal(int handle, int col)
{
   return(StrToDouble(sqlite_get_col(handle,col)));
}

datetime SqLiteGetDT(int handle, int col)
{
   return(StrToInteger(sqlite_get_col(handle,col)));
}

void DbFreeQuery(int handle)
{
//--- Assert OK to unlock, otherwise error database is locked
   sqlite_free_query(handle);
}

bool SqLitePutText(string table, int id, string key, string value)
{
   string exp="UPDATE "+table+" SET "+key+"='"+value+"' WHERE id="+id;
   return(DbExec(SqLiteName,exp));
}

bool SqLitePutInteger(string table, int id, string key, int value)
{
   string exp="UPDATE "+table+" SET "+key+"="+value+" WHERE id="+id;
   return(DbExec(SqLiteName,exp));
}

bool SqLitePutReal(string table, int id, string key, double value)
{
   string exp="UPDATE "+table+" SET "+key+"="+value+" WHERE id="+id;
   return(DbExec(SqLiteName,exp));
}

bool SqLitePutDT(string table, int id, string key, int value)
{
   string exp="UPDATE "+table+" SET "+key+"="+value+" WHERE id="+id;
   return(DbExec(SqLiteName,exp));
}

bool SqLiteDeleteRow(string table, int id)
{
   string exp="DELETE FROM "+table+" WHERE id="+id;
   return(DbExec(SqLiteName,exp));
}

bool DbBegin(string db)
{
   string exp="BEGIN TRANSACTION;";
   return(DbExec(db,exp));
}

bool DbCommit(string db)
{
   string exp="COMMIT TRANSACTION;";
   return(DbExec(db,exp));
}

bool DbRollback(string db)
{
   string exp="ROLLBACK TRANSACTION;";
   return(DbExec(db,exp));
}

bool DbExec(string db, string exp)
{
    int err=sqlite_exec(db,exp);
    if (err!=0)
    {
        Print("0:Check expression '"+exp+"'. Error Code: "+err);
        return(false);
    }
    else return(true);
}
