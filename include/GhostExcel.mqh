//|-----------------------------------------------------------------------------------------|
//|                                                                          GhostExcel.mqh |
//|                                                            Copyright © 2012, Dennis Lee |
//| Assert History                                                                          |
//| 1.00    Originated from PlusGhost 1.50.                                                 |
//| 1.01    Adjusted trade history profit in ExcelManager(), OrderClose() and OrderProfit().|
//|             Split OrderSelect() into OrderTradeSelect() and OrderHistorySelect().       |
//|             Added OrderExpiration(), AccountNumber(), Expiration and CloseTime.         |
//| 1.02    Replaced bool GhostTradeHistory with GhostStatistics.                           | 
//|         Removed PlusEasy.mqh dependency for Pts.                                        |
//|         Additional Debug functions.                                                     |
//| 1.03    Fixed calculation of profit in ExcelManager().                                  |
//|-----------------------------------------------------------------------------------------|

//|-----------------------------------------------------------------------------------------|
//|                     F X 1 . N E T   E X C E L L I N K   A D D O N                       |
//|-----------------------------------------------------------------------------------------|
#import "excellink.dll"
int     ExcelStart(string,int);
string  ExcelVersion();
int     ExcelPutString(int,int,int,string);
int     ExcelPutValue(int,int,int,double);
int     ExcelFormatCellColor(int,int,int,int,int);
int     ExcelFormatCellFontSize(int,int,int,int);
int     ExcelFormatCellFont(int,int,int,int);
double  ExcelGetValue(int,int,int);
string  ExcelGetString(int,int,int);
int     ExcelSaveFile(string);
int     ExcelSheetRename(int, string);
int     ExcelPutCalc(int,int,int,string);
string  ExcelGetCalc(int,int,int,string);
int     ExcelEnd();
int     ExcelClose();
int     ExcelFreeString();
string  ExcelCell(int,int);
int     ExcelUnixTime();
int     ExcelAutoFit(bool);
#import

//|-----------------------------------------------------------------------------------------|
//|                           I N T E R N A L   V A R I A B L E S                           |
//|-----------------------------------------------------------------------------------------|
//---- Assert internal variables for ExcelLink
string   ExcelFileName;
string   ExcelVer   = "1.03";
int      ExcelSelectRow;
int      ExcelSelectMode;
int      ExcelNextTicket;
//---- Excel sheet positions
int      AdSheet    = 1;
int      StSheet    = 1;
int      OpSheet    = 2;
int      PoSheet    = 3;
int      ThSheet    = 3;
//---- Excel first row for each sheet
int      AdFirstRow = 2;
int      StFirstRow = 6;
int      OpFirstRow = 2;
int      PoFirstRow = 2;
int      ThFirstRow = 2;
//---- Excel column positions for Account Details
int      AdAccountNo    = 1;
int      AdCurrency     = 2;
int      AdBalance      = 3;
int      AdEquity       = 4;
int      AdMargin       = 5;
int      AdProfit       = 6;
//---- Excel column positions for Statistics Trades
int      StTotalTrades      = 1;
int      StTotalLots        = 2;
int      StTotalProfit      = 3;
int      StTotalProfitPip   = 4;
int      StTotalDrawdown    = 5;
int      StTotalDrawdownPip = 6;
int      StTotalMargin      = 7;
int      StMaxLots          = 8;
int      StMaxProfit        = 9;
int      StMaxProfitPip     = 10;
int      StMaxDrawdown      = 11;
int      StMaxDrawdownPip   = 12;
int      StMaxMargin        = 13;
//---- Excel column positions for Open Positions
int      OpTicket       = 1;
int      OpOpenTime     = 2;
int      OpType         = 3;
int      OpLots         = 4;
int      OpOpenPrice    = 5;
int      OpStopLoss     = 6;
int      OpTakeProfit   = 7;
int      OpCurPrice     = 8;
int      OpSwap         = 9;
int      OpProfit       = 10;
int      OpExpiration   = 11;
int      OpCloseTime    = 12;
int      OpMagicNo      = 13;
int      OpAccountNo    = 14;
int      OpSymbol       = 15;
int      OpComment      = 16;
int      OpExpertName   = 17;
//---- Excel column positions for Pending Orders
int      PoTicket       = 1;
int      PoOpenTime     = 2;
int      PoType         = 3;
int      PoLots         = 4;
int      PoOpenPrice    = 5;
int      PoStopLoss     = 6;
int      PoTakeProfit   = 7;
int      PoClosePrice   = 8;
int      PoSwap         = 9;
int      PoProfit       = 10;
int      PoExpiration   = 11;
int      PoCloseTime    = 12;
int      PoMagicNo      = 13;
int      PoAccountNo    = 14;
int      PoSymbol       = 15;
int      PoComment      = 16;
int      PoExpertName   = 17;
//---- Excel column positions for Trade History
int      ThTicket       = 1;
int      ThOpenTime     = 2;
int      ThType         = 3;
int      ThLots         = 4;
int      ThOpenPrice    = 5;
int      ThStopLoss     = 6;
int      ThTakeProfit   = 7;
int      ThClosePrice   = 8;
int      ThSwap         = 9;
int      ThProfit       = 10;
int      ThExpiration   = 11;
int      ThCloseTime    = 12;
int      ThMagicNo      = 13;
int      ThAccountNo    = 14;
int      ThSymbol       = 15;
int      ThComment      = 16;
int      ThExpertName   = 17;

//|-----------------------------------------------------------------------------------------|
//|                             I N I T I A L I Z A T I O N                                 |
//|-----------------------------------------------------------------------------------------|
bool ExcelCreate(int acctNo, string symbol, int period, string eaName)
{
    int handle;
    bool init;
    
//--- Assert Check if file exists, e.g. "Acc440660-EURUSD-Growthbot.xls"
    ExcelFileName=StringConcatenate("AccNo",acctNo,"-",symbol,"-",period,"-",eaName,".xls");
    
    handle=ExcelStart(ExcelFileName,1);
    if(handle<0) return(false);
    
//--- Assert File is opened for the FIRST time.
    if("AccountNo"!=ExcelGetString(AdSheet,AdFirstRow-1,AdAccountNo)) init=true;
    
    if(init)
    {
    //--- Assert rename worksheets to AccountDetails,OpenPositions,PendingOrders,TradeHistory
        ExcelSheetRename(AdSheet,"AccountDetails");
        ExcelSheetRename(OpSheet,"OpenPositions");
        ExcelSheetRename(ThSheet,"TradeHistory");
        
    //--- Assert add headers to AccountDetails: BrokerName, AccountNo, Currency, Balance, Equity, Margin, PL
        ExcelPutString(AdSheet, AdFirstRow-1, AdAccountNo,  "AccountNo");
        ExcelPutString(AdSheet, AdFirstRow-1, AdCurrency,   "Currency");
        ExcelPutString(AdSheet, AdFirstRow-1, AdBalance,    "Balance");
        ExcelPutString(AdSheet, AdFirstRow-1, AdEquity,     "Equity");
        ExcelPutString(AdSheet, AdFirstRow-1, AdMargin,     "Margin");
        ExcelPutString(AdSheet, AdFirstRow-1, AdProfit,     "Profit");

    //--- Assert add headers to Statistics:
        ExcelPutString(StSheet, StFirstRow-1, StTotalTrades,        "TotalTrades");
        ExcelPutString(StSheet, StFirstRow-1, StTotalLots,          "TotalLots");
        ExcelPutString(StSheet, StFirstRow-1, StTotalProfit,        "TotalProfit");
        ExcelPutString(StSheet, StFirstRow-1, StTotalProfitPip,     "TotalProfitPip");
        ExcelPutString(StSheet, StFirstRow-1, StTotalDrawdown,      "TotalDrawdown");
        ExcelPutString(StSheet, StFirstRow-1, StTotalDrawdownPip,   "TotalDrawdownPip");
        ExcelPutString(StSheet, StFirstRow-1, StTotalMargin,        "TotalMargin");
        ExcelPutString(StSheet, StFirstRow-1, StMaxLots,            "MaxLots");
        ExcelPutString(StSheet, StFirstRow-1, StMaxProfit,          "MaxProfit");
        ExcelPutString(StSheet, StFirstRow-1, StMaxProfitPip,       "MaxProfitPip");
        ExcelPutString(StSheet, StFirstRow-1, StMaxDrawdown,        "MaxDrawdown");
        ExcelPutString(StSheet, StFirstRow-1, StMaxDrawdownPip,     "MaxDrawdownPip");
        ExcelPutString(StSheet, StFirstRow-1, StMaxMargin,          "MaxMargin");
    
    //--- Assert add headers to Opened Positions: Ticket, OpenTime, Type, Lots, OpenPrice, StopLoss, TakeProfit, Comment, AccountNo, ExpertName, Symbol, MagicNo
        ExcelPutString(OpSheet, OpFirstRow-1,  OpTicket,       "Ticket");
        ExcelPutString(OpSheet, OpFirstRow-1,  OpOpenTime,     "OpenTime");
        ExcelPutString(OpSheet, OpFirstRow-1,  OpType,         "Type");
        ExcelPutString(OpSheet, OpFirstRow-1,  OpLots,         "Lots");
        ExcelPutString(OpSheet, OpFirstRow-1,  OpOpenPrice,    "OpenPrice");
        ExcelPutString(OpSheet, OpFirstRow-1,  OpStopLoss,     "StopLoss");
        ExcelPutString(OpSheet, OpFirstRow-1,  OpTakeProfit,   "TakeProfit");
        ExcelPutString(OpSheet, OpFirstRow-1,  OpCurPrice,     "CurPrice");
        ExcelPutString(OpSheet, OpFirstRow-1,  OpSwap,         "Swap");
        ExcelPutString(OpSheet, OpFirstRow-1,  OpProfit,       "Profit");
        ExcelPutString(OpSheet, OpFirstRow-1,  OpExpiration,   "Expiration");
        ExcelPutString(OpSheet, OpFirstRow-1,  OpCloseTime,    "CloseTime");
        ExcelPutString(OpSheet, OpFirstRow-1,  OpMagicNo,      "MagicNo");
        ExcelPutString(OpSheet, OpFirstRow-1,  OpAccountNo,    "AccountNo");
        ExcelPutString(OpSheet, OpFirstRow-1,  OpSymbol,       "Symbol");
        ExcelPutString(OpSheet, OpFirstRow-1,  OpComment,      "Comment");
        ExcelPutString(OpSheet, OpFirstRow-1,  OpExpertName,   "ExpertName");
    
    //--- Assert add headers to Trade History: Ticket, OpenTime, Type, Lots, OpenPrice, StopLoss, TakeProfit, Comment, AccountNo, ExpertName, Symbol, MagicNo
        ExcelPutString(ThSheet, ThFirstRow-1,  ThTicket,       "Ticket");
        ExcelPutString(ThSheet, ThFirstRow-1,  ThOpenTime,     "OpenTime");
        ExcelPutString(ThSheet, ThFirstRow-1,  ThType,         "Type");
        ExcelPutString(ThSheet, ThFirstRow-1,  ThLots,         "Lots");
        ExcelPutString(ThSheet, ThFirstRow-1,  ThOpenPrice,    "OpenPrice");
        ExcelPutString(ThSheet, ThFirstRow-1,  ThStopLoss,     "StopLoss");
        ExcelPutString(ThSheet, ThFirstRow-1,  ThTakeProfit,   "TakeProfit");
        ExcelPutString(ThSheet, ThFirstRow-1,  ThClosePrice,   "ClosePrice");
        ExcelPutString(ThSheet, ThFirstRow-1,  ThSwap,         "Swap");
        ExcelPutString(ThSheet, ThFirstRow-1,  ThProfit,       "Profit");
        ExcelPutString(ThSheet, ThFirstRow-1,  ThExpiration,   "Expiration");
        ExcelPutString(ThSheet, ThFirstRow-1,  ThCloseTime,    "CloseTime");
        ExcelPutString(ThSheet, ThFirstRow-1,  ThMagicNo,      "MagicNo");
        ExcelPutString(ThSheet, ThFirstRow-1,  ThAccountNo,    "AccountNo");
        ExcelPutString(ThSheet, ThFirstRow-1,  ThSymbol,       "Symbol");
        ExcelPutString(ThSheet, ThFirstRow-1,  ThComment,      "Comment");
        ExcelPutString(ThSheet, ThFirstRow-1,  ThExpertName,   "ExpertName");
        
    //--- Assert Populate AccountDetails: AccountNo, Currency, Balance, Equity, Margin, PL
        ExcelPutValue(AdSheet,  AdFirstRow,  AdAccountNo,    AccountNumber());
        ExcelPutString(AdSheet, AdFirstRow,  AdCurrency,     AccountCurrency());
        ExcelPutValue(AdSheet,  AdFirstRow,  AdBalance,      AccountBalance());
    }

    return(true);
}

//|-----------------------------------------------------------------------------------------|
//|                               M A I N   P R O C E D U R E                               |
//|-----------------------------------------------------------------------------------------|
void ExcelManager()
{
    int r, histRow, type;
    double lots, closePrice;
    double calcProfit, openPrice;
    double openSL, openTP, pts;
    string sym;

//--- Assert for each Open Position, check if SL or TP reached.
//--- First row is header
    r=OpFirstRow;
    while (ExcelGetValue(OpSheet,r,OpTicket)>0)
    {
        type = ExcelGetValue(OpSheet,r,OpType);
        lots = ExcelGetValue(OpSheet,r,OpLots);
        openPrice=ExcelGetValue(OpSheet,r,OpOpenPrice);
        openSL=ExcelGetValue(OpSheet,r,OpStopLoss);
        openTP=ExcelGetValue(OpSheet,r,OpTakeProfit);
        sym  = ExcelGetString(OpSheet,r,OpSymbol);
        pts  = MarketInfo( sym, MODE_POINT );
    //--- Assert get real-time info.
        if(type==OP_BUY)
        {
            closePrice = MarketInfo( sym, MODE_BID ); 
            if( (openSL!=0.0 && closePrice<=openSL) ||
                (openTP!=0.0 && closePrice>=openTP) )
            {
            //--- Assert calculate profit/loss
                calcProfit=(closePrice-openPrice)*lots*TurtleBigValue(sym)/pts;
                break;
            }
                    
        }
        else if(type==OP_SELL)
        {
            closePrice = MarketInfo( sym, MODE_ASK ); 
            if( (openSL!=0.0 && closePrice>=openSL) ||
                (openTP!=0.0 && closePrice<=openTP) )
            {
            //--- Assert calculate profit/loss
                calcProfit=(openPrice-closePrice)*lots*TurtleBigValue(sym)/pts;
                break;
            }
        }

    //---- Increment row
        r ++;
    }

//--- Assert adjustment to account details using BigValue.
    if(calcProfit!=0.0) 
    {
        ExcelPutValue(AdSheet,AdFirstRow,AdBalance,  ExcelGetValue(AdSheet,AdFirstRow,AdBalance)+calcProfit);

        //--- Assert copy row to Trade History
        histRow=ExcelCopyRow(OpSheet,OpTicket,OpFirstRow,r,ThSheet,ThTicket,ThFirstRow);
        if(histRow>0)
        {
        //--- Adjust trade history values.
           ExcelPutValue(ThSheet,histRow,ThClosePrice,  closePrice);
           ExcelPutValue(ThSheet,histRow,ThProfit,      calcProfit);
           ExcelPutValue(ThSheet,histRow,ThCloseTime,   TimeCurrent());
        }
        
        if(r>=OpFirstRow) { ExcelDeleteRow(OpSheet,OpTicket,OpFirstRow,r); GhostCurOpenPositions --; }

    //--- Debug
        GhostDebugPrint( 1,"ExcelManager",
         GhostDebugInt("r",r)+
         GhostDebugDbl("openPrice",openPrice,5)+
         GhostDebugDbl("closePrice",closePrice,5)+
         GhostDebugDbl("openSL",openSL,5)+
         GhostDebugDbl("openTP",openTP,5)+
         GhostDebugDbl("calcProfit",calcProfit,5) );
    }
}

//|-----------------------------------------------------------------------------------------|
//|                             T E R M I N A L   B U F F E R S                             |
//|-----------------------------------------------------------------------------------------|
void ExcelLoadBuffers()
{
    int lastErr, digits, r;
    double calcProfit;
    double calcProfitPip;
    double closePrice;
    double lots;
    double mgn;
    double openPrice;
    double pts;

//--- Assert statistics gathering
    int totalTrades;
    double totalLots;
    double totalProfitPip;
    double totalMargin;
    
    
    GhostCurOpenPositions=0; GhostCurPendingOrders=0; GhostSummProfit=0.0;

//--- Assert Load OpenPositions
//--- First row is header
    r=OpFirstRow;
    while (ExcelGetValue(OpSheet,r,OpTicket)>0)
    {
		digits = MarketInfo( ExcelGetString(OpSheet,r,OpSymbol), MODE_DIGITS );
		pts = MarketInfo( ExcelGetString(OpSheet,r,OpSymbol), MODE_POINT );

      GhostOpenPositions[GhostCurOpenPositions][TwTicket]     = DoubleToStr( ExcelGetValue(OpSheet,r,OpTicket), 0 );
		GhostOpenPositions[GhostCurOpenPositions][TwOpenTime]   = TimeToStr( ExcelGetValue(OpSheet,r,OpOpenTime) );
		GhostOpenPositions[GhostCurOpenPositions][TwType]       = OrderTypeToStr( ExcelGetValue(OpSheet,r,OpType) );
		GhostOpenPositions[GhostCurOpenPositions][TwLots]       = DoubleToStr( ExcelGetValue(OpSheet,r,OpLots), 1 );
		GhostOpenPositions[GhostCurOpenPositions][TwOpenPrice]  = DoubleToStr( ExcelGetValue(OpSheet,r,OpOpenPrice), digits );
		GhostOpenPositions[GhostCurOpenPositions][TwStopLoss]   = DoubleToStr( ExcelGetValue(OpSheet,r,OpStopLoss), digits );
		GhostOpenPositions[GhostCurOpenPositions][TwTakeProfit] = DoubleToStr( ExcelGetValue(OpSheet,r,OpTakeProfit), digits );
        
    //--- Assert get close price and calculate margin and profit
      lots = ExcelGetValue(OpSheet,r,OpLots); 
      mgn = MarketInfo(ExcelGetString(OpSheet,r,OpSymbol),MODE_MARGINREQUIRED)*lots;
      openPrice = ExcelGetValue(OpSheet,r,OpOpenPrice);
      calcProfit = 0.0; calcProfitPip = 0.0;
      if ( ExcelGetValue(OpSheet,r,OpType) == OP_BUY )
      {   
         closePrice = MarketInfo( ExcelGetString(OpSheet,r,OpSymbol), MODE_BID ); 
      //--- Assert calculate profits      
         calcProfit     = (closePrice-openPrice)*lots*TurtleBigValue(Symbol())/pts;
         calcProfitPip  = (closePrice-openPrice)/GhostPts;
      }
		else if ( ExcelGetValue(OpSheet,r,OpType) == OP_SELL )
		{ 
         closePrice = MarketInfo( ExcelGetString(OpSheet,r,OpSymbol), MODE_ASK ); 
      //--- Assert calculate profits      
         calcProfit     = (openPrice-closePrice)*lots*TurtleBigValue(Symbol())/pts;
         calcProfitPip  = (openPrice-closePrice)/GhostPts;
      }
      GhostOpenPositions[GhostCurOpenPositions][TwCurPrice]   = DoubleToStr( closePrice, digits ); 
		GhostOpenPositions[GhostCurOpenPositions][TwSwap]       = DoubleToStr( ExcelGetValue(OpSheet,r,OpSwap), 2 );
		GhostOpenPositions[GhostCurOpenPositions][TwProfit]     = DoubleToStr( calcProfit, 2 );
		GhostOpenPositions[GhostCurOpenPositions][TwComment]    = ExcelGetString(OpSheet,r,OpComment);
        
    //--- Assert record statistics for SINGLE trade
      if(GhostStatistics)
      {
         if(lots>0)            { if(lots           >
            ExcelGetValue(StSheet,StFirstRow,   StMaxLots)) 
            ExcelPutValue(StSheet,StFirstRow,   StMaxLots,          lots); 
         }
         if(calcProfit>0)      { if(calcProfit     >
            ExcelGetValue(StSheet,StFirstRow,   StMaxProfit))
            ExcelPutValue(StSheet,StFirstRow,   StMaxProfit,        calcProfit);
         }
         if(calcProfitPip>0)   { if(calcProfitPip  >
            ExcelGetValue(StSheet,StFirstRow,   StMaxProfitPip))
            ExcelPutValue(StSheet,StFirstRow,   StMaxProfitPip,     calcProfitPip);
         }
         if(calcProfit<0)      { if(calcProfit     <
            ExcelGetValue(StSheet,StFirstRow,   StMaxDrawdown))
            ExcelPutValue(StSheet,StFirstRow,   StMaxDrawdown,      calcProfit);
         }
         if(calcProfitPip<0)   { if(calcProfitPip  <
            ExcelGetValue(StSheet,StFirstRow,   StMaxDrawdownPip))
            ExcelPutValue(StSheet,StFirstRow,   StMaxDrawdownPip,   calcProfitPip);
         }
         if(mgn>0)             { if(mgn            >
            ExcelGetValue(StSheet,StFirstRow,   StMaxMargin))
            ExcelPutValue(StSheet,StFirstRow,   StMaxMargin,        mgn);
         }
      }

    //---- Increment row
      totalLots         += lots;
      totalMargin       += mgn;
      GhostSummProfit   += calcProfit;
      totalProfitPip    += calcProfitPip;
      GhostCurOpenPositions ++;
      r ++;
      if ( GhostCurOpenPositions >= GhostRows ) { break; }
    }

//--- Assert record AGGREGATE statistics
    if(GhostStatistics)
    {
      if(GhostCurOpenPositions>0) { if(GhostCurOpenPositions  >
        ExcelGetValue(StSheet,StFirstRow,   StTotalTrades)) 
        ExcelPutValue(StSheet,StFirstRow,   StTotalTrades,      GhostCurOpenPositions); 
      }
      if(totalLots>0)             { if(totalLots              >
        ExcelGetValue(StSheet,StFirstRow,   StTotalLots)) 
        ExcelPutValue(StSheet,StFirstRow,   StTotalLots,        totalLots); 
      }
      if(GhostSummProfit>0)       { if(GhostSummProfit        >
        ExcelGetValue(StSheet,StFirstRow,   StTotalProfit))
        ExcelPutValue(StSheet,StFirstRow,   StTotalProfit,      GhostSummProfit);
      }
      if(totalProfitPip>0)        { if(totalProfitPip         >
        ExcelGetValue(StSheet,StFirstRow,   StTotalProfitPip))
        ExcelPutValue(StSheet,StFirstRow,   StTotalProfitPip,   totalProfitPip);
      }
      if(GhostSummProfit<0)       { if(GhostSummProfit        <
        ExcelGetValue(StSheet,StFirstRow,   StTotalDrawdown))
        ExcelPutValue(StSheet,StFirstRow,   StTotalDrawdown,    GhostSummProfit);
      }
      if(totalProfitPip<0)        { if(totalProfitPip         <
        ExcelGetValue(StSheet,StFirstRow,   StTotalDrawdownPip))
        ExcelPutValue(StSheet,StFirstRow,   StTotalDrawdownPip, totalProfitPip);
      }
      if(totalMargin>0)           { if(totalMargin            >
        ExcelGetValue(StSheet,StFirstRow,   StTotalMargin))
        ExcelPutValue(StSheet,StFirstRow,   StTotalMargin,      totalMargin);
      }
    }
    
//--- Assert Load PendingOrders
//--- First row is header
    r=PoFirstRow;
    while (ExcelGetValue(PoSheet,r,PoTicket)>0)
    {
		digits = MarketInfo( ExcelGetString(PoSheet,r,PoSymbol), MODE_DIGITS );

		GhostPendingOrders[GhostCurPendingOrders][TwTicket]     = DoubleToStr( ExcelGetValue(PoSheet,r,PoTicket), 0 );
		GhostPendingOrders[GhostCurPendingOrders][TwOpenTime]   = TimeToStr( ExcelGetValue(PoSheet,r,PoOpenTime) );
		GhostPendingOrders[GhostCurPendingOrders][TwType]       = OrderTypeToStr( ExcelGetValue(PoSheet,r,PoType) );
		GhostPendingOrders[GhostCurPendingOrders][TwLots]       = DoubleToStr( ExcelGetValue(PoSheet,r,PoLots), 1 );
		GhostPendingOrders[GhostCurPendingOrders][TwOpenPrice]  = DoubleToStr( ExcelGetValue(PoSheet,r,PoOpenPrice), digits );
		GhostPendingOrders[GhostCurPendingOrders][TwStopLoss]   = DoubleToStr( ExcelGetValue(PoSheet,r,PoStopLoss), digits );
		GhostPendingOrders[GhostCurPendingOrders][TwTakeProfit] = DoubleToStr( ExcelGetValue(PoSheet,r,PoTakeProfit), digits );

		if ( ExcelGetValue(PoSheet,r,PoType) == OP_SELLSTOP || ExcelGetValue(PoSheet,r,PoType) == OP_SELLLIMIT )
		{ GhostPendingOrders[GhostCurPendingOrders][TwCurPrice] = DoubleToStr( MarketInfo( ExcelGetString(PoSheet,r,PoSymbol), MODE_BID ), digits ); }
		else
		{ GhostPendingOrders[GhostCurPendingOrders][TwCurPrice] = DoubleToStr( MarketInfo( ExcelGetString(PoSheet,r,PoSymbol), MODE_ASK ), digits ); }

		GhostPendingOrders[GhostCurPendingOrders][TwSwap]       = DoubleToStr( ExcelGetValue(PoSheet,r,PoSwap), 2 );
		GhostPendingOrders[GhostCurPendingOrders][TwProfit]     = DoubleToStr( 0, 2 );
		GhostPendingOrders[GhostCurPendingOrders][TwComment]    = ExcelGetString(PoSheet,r,PoComment);

    //---- Increment row
      GhostCurPendingOrders ++;
      r ++;
      if ( GhostCurOpenPositions + GhostCurPendingOrders >= GhostRows ) { break; }
    }

//--- Assert record ACCOUNT details
   ExcelPutValue(AdSheet,AdFirstRow,   AdEquity,      GhostSummProfit+ExcelAccountBalance());
   ExcelPutValue(AdSheet,AdFirstRow,   AdMargin,      totalMargin);
   ExcelPutValue(AdSheet,AdFirstRow,   AdProfit,      GhostSummProfit);

   GhostReorderBuffers();
}

//|-----------------------------------------------------------------------------------------|
//|                                 O P E N   O R D E R S                                   |
//|-----------------------------------------------------------------------------------------|
int ExcelOrderSend(string sym, int type, double lots, double price, int slip, double SL, double TP, string cmt="", int mgc=0, datetime exp=0, color arrow=CLR_NONE)
{
    int r;
    double  openPrice;
    double  openSL;
    double  openTP;
    int     openRow;
    int     openTicket;
    int     openTime;

//--- Assert Create new ticket.
    openTicket=ExcelCreateTicket();
    if(openTicket<=0) 
    {
    //--- Debug    
        if(GhostDebug>=1)   Print(GhostDebug,":ExcelOrderSend(",sym,",",type,",",lots,",",price,",",slip,",",SL,",",TP,",",cmt,",",mgc,",",exp,",",arrow,"): return=-1");
        return(-1);
    }
//--- if new open position then create new row in Open Positions.
    if(type==OP_BUY || type==OP_SELL)
    {
    //--- Assert Create new row.
        openRow=ExcelCreateRow(OpSheet,OpTicket,OpFirstRow);
        if(openRow<=0) return(-1);
        
    //--- Assert get real-time info.
        if(type==OP_BUY)
        {
            openPrice = MarketInfo( sym, MODE_ASK ); 
            if(SL!=0.0) openSL=NormalizeDouble(openPrice-SL*GhostPts,Digits);
            if(TP!=0.0) openTP=NormalizeDouble(openPrice+TP*GhostPts,Digits);
        }
        else
        {
            openPrice = MarketInfo( sym, MODE_BID ); 
            if(SL!=0.0) openSL=NormalizeDouble(openPrice+SL*GhostPts,Digits);
            if(TP!=0.0) openTP=NormalizeDouble(openPrice-TP*GhostPts,Digits);
        }
        openTime=TimeCurrent(); //server

        ExcelPutValue(OpSheet,openRow,OpTicket,     openTicket);
        ExcelPutValue(OpSheet,openRow,OpOpenTime,   openTime);
        ExcelPutValue(OpSheet,openRow,OpType,       type);
        ExcelPutValue(OpSheet,openRow,OpLots,       lots);
        ExcelPutValue(OpSheet,openRow,OpOpenPrice,  openPrice);
        ExcelPutValue(OpSheet,openRow,OpStopLoss,   openSL);
        ExcelPutValue(OpSheet,openRow,OpTakeProfit, openTP);
        //ExcelPutValue(OpSheet,openRow,OpCurPrice,    0.0);
        //ExcelPutValue(OpSheet,openRow,OpSwap,        0.0);
        //ExcelPutValue(OpSheet,openRow,OpProfit,      0.0);
        ExcelPutValue(OpSheet,openRow,OpMagicNo,    mgc);
        ExcelPutValue(OpSheet,openRow,OpAccountNo,  ExcelGetValue(AdSheet,AdFirstRow,AdAccountNo));
        ExcelPutString(OpSheet,openRow,OpSymbol,    sym);
        ExcelPutString(OpSheet,openRow,OpComment,   cmt);
        ExcelPutString(OpSheet,openRow,OpExpertName,GhostExpertName);
        
    //--- Debug    
        if(GhostDebug>=1)   Print(GhostDebug,":ExcelOrderSend(",sym,",",type,",",lots,",",price,",",slip,",",SL,",",TP,",",cmt,",",mgc,",",exp,",",arrow,"): return=",openTicket);
        return(openTicket);
    }
}

bool ExcelOrderModify(int ticket, double price, double SL, double TP, datetime exp, color arrow=CLR_NONE)
{
    int r;
    int type;
    double curPrice;
    double modifyPrice;
    double modifySL;
    double modifyTP;
    string sym;
    
//--- Assert ticket no exists in Open Positions.
    r=ExcelFindTicket(OpSheet,OpTicket,OpFirstRow,ticket);
    if(r>0)
    {
        type=ExcelGetValue(OpSheet,r,OpType);
        sym=ExcelGetString(OpSheet,r,OpSymbol);
        if ( type <= OP_SELL ) 
        {
        //--- Assert get open position info.
        /*
            if(type==OP_BUY)
            {
               curPrice = MarketInfo( sym, MODE_ASK ); 
               if(SL!=0.0) modifySL=NormalizeDouble(curPrice-SL*GhostPts,Digits);
               if(TP!=0.0) modifyTP=NormalizeDouble(curPrice+TP*GhostPts,Digits);
            }
            else if(type==OP_SELL)
            {
               curPrice = MarketInfo( sym, MODE_BID ); 
               if(SL!=0.0) modifySL=NormalizeDouble(curPrice+SL*GhostPts,Digits);
               if(TP!=0.0) modifyTP=NormalizeDouble(curPrice-TP*GhostPts,Digits);
            }
        */
            ExcelPutValue(OpSheet,r,OpStopLoss,     SL);
            ExcelPutValue(OpSheet,r,OpTakeProfit,   TP);
        //--- Debug    
            if(GhostDebug>=1)   Print(GhostDebug,":ExcelOrderModify(",ticket,",",price,",",SL,",",TP,",",exp,",",arrow,"): return=true");
            return(true);
        }
    }

//--- Assert ticket no exists in Pending Orders.
/*
    r=ExcelFindTicket(PoSheet,PoTicket,PoFirstRow,ticket);
    if(r>0)
    {
    //--- Assert get pending order info.
        if(OP_BUY==ExcelGetValue(PoSheet,r,PoType))
        {
            if(price==0.0) 
            {   modifyPrice=ExcelGetValue(PoSheet,r,PoOpenPrice); }
            else
            {   modifyPrice=price; }
            if(SL!=0.0) modifySL=NormalizeDouble(modifyPrice-SL*GhostPts,Digits);
            if(TP!=0.0) modifyTP=NormalizeDouble(modifyPrice+TP*GhostPts,Digits);
        }
        else if(OP_SELL==ExcelGetValue(PoSheet,r,PoType))
        {
            if(price==0.0)
            {   modifyPrice=ExcelGetValue(PoSheet,r,PoOpenPrice); }
            else
            {   modifyPrice=price; }
            if(SL!=0.0) modifySL=NormalizeDouble(modifyPrice+SL*GhostPts,Digits);
            if(TP!=0.0) modifyTP=NormalizeDouble(modifyPrice-TP*GhostPts,Digits);
        }
        ExcelPutValue(PoSheet,r,PoOpenPrice,    modifyPrice);
        ExcelPutValue(PoSheet,r,PoStopLoss,     modifySL);
        ExcelPutValue(PoSheet,r,PoTakeProfit,   modifyTP);
    //--- Debug    
        if(GhostDebug>=1)   Print(GhostDebug,":ExcelOrderModify(",ticket,",",price,",",SL,",",TP,",",exp,",",arrow,"): return=true");
        return(true);
    }
*/

//--- Assert ticket not found.
//--- Debug    
   GhostDebugPrint( 1,"ExcelOrderModify",
      GhostDebugInt("ticket",ticket)+
      GhostDebugDbl("price",price,5)+
      GhostDebugDbl("SL",SL,5)+
      GhostDebugDbl("TP",TP,5)+
      GhostDebugBln("return",false) );
    return(false);
}

int ExcelCreateRow(int sheet, int keyCol, int firstRow)
{
    bool empty=true;
    int r;
//--- Assert get last row.
//--- First row is header.
    r=firstRow;
    while(ExcelGetValue(sheet,r,keyCol)>0)
    {
        empty=false;
        r ++;
    }
//--- Debug
    GhostDebugPrint( 1,"ExcelCreateRow",
      GhostDebugInt("sheet",sheet)+
      GhostDebugInt("keyCol",keyCol)+
      GhostDebugInt("firstRow",firstRow)+
      GhostDebugInt("return",r) );

    if(empty) return(firstRow);
    else return(r);
}

int ExcelCreateTicket()
{
    int r,maxTicket;

//--- Assert get last ticket no.
//--- First row is header.
    if(ExcelNextTicket<=0)
    {
      r=OpFirstRow;
      while(ExcelGetValue(OpSheet,r,OpTicket)>0)
      {
        if(maxTicket<ExcelGetValue(OpSheet,r,OpTicket))
        {
            maxTicket=ExcelGetValue(OpSheet,r,OpTicket);
        }
        r ++;
      }
      r=ThFirstRow;
      while(ExcelGetValue(ThSheet,r,ThTicket)>0)
      {
        if(maxTicket<ExcelGetValue(ThSheet,r,ThTicket))
        {
            maxTicket=ExcelGetValue(ThSheet,r,ThTicket);
        }
        r ++;
      }
      maxTicket ++;
      ExcelNextTicket = maxTicket;
    }
    else
    {
      ExcelNextTicket ++;
    }
    
//--- Debug
    GhostDebugPrint( 1,"ExcelCreateTicket",
      GhostDebugInt("return",ExcelNextTicket) );
    return(ExcelNextTicket);
}

//|-----------------------------------------------------------------------------------------|
//|                                O R D E R S   S T A T U S                                |
//|-----------------------------------------------------------------------------------------|
int ExcelFindTicket(int sheet, int keyCol, int firstRow, int ticket)
{
    int r, rowFound=0;

//--- Assert ticket no exists.    
//--- First row is header
    r=firstRow;
    while (ExcelGetValue(sheet,r,keyCol)>0)
    {
        if(ticket==ExcelGetValue(sheet,r,keyCol))
        {
            rowFound=r;
            break;
        }
        r ++;
    }
    //--- Debug    
    if(0==rowFound) 
    {
      GhostDebugPrint( 2,"ExcelFindTicket",
         GhostDebugInt("sheet",sheet)+
         GhostDebugInt("keyCol",keyCol)+
         GhostDebugInt("firstRow",firstRow)+
         GhostDebugInt("ticket",ticket)+
         GhostDebugInt("return",-1),
         false );
        return(-1);
    }
    GhostDebugPrint( 2,"ExcelFindTicket",
      GhostDebugInt("sheet",sheet)+
      GhostDebugInt("keyCol",keyCol)+
      GhostDebugInt("firstRow",firstRow)+
      GhostDebugInt("ticket",ticket)+
      GhostDebugInt("return",rowFound),
      false );
    return(rowFound);
}

int ExcelOrdersTotal()
{
    int r;
    
    r=ExcelCreateRow(OpSheet,OpTicket,OpFirstRow);
    if(r==OpFirstRow) return(0);
    else return(r-OpFirstRow);
}

int ExcelOrdersHistoryTotal()
{
    int r;
    
    r=ExcelCreateRow(ThSheet,ThTicket,ThFirstRow);
    if(r==ThFirstRow) return(0);
    else return(r-ThFirstRow);
}

bool ExcelOrderSelect(int index, int select, int pool=MODE_TRADES)
{
    bool ret;
    int r;
    
    ExcelSelectMode=pool;
    
//--- Assert SELECT_BY_TICKET index is order ticket.
    if(select==SELECT_BY_TICKET)
    {
    //--- Find order by ticket
        ExcelSelectRow=ExcelFindTicket(OpSheet,OpTicket,OpFirstRow,index);
    //--- Assert ExcelSelectRow>0
        if(ExcelSelectRow>0) ret=true;

    //--- Debug    
         GhostDebugPrint( 2,"ExcelOrderSelect",
            GhostDebugInt("index",index)+
            GhostDebugInt("select",select)+
            GhostDebugInt("pool",pool)+
            GhostDebugInt("row",ExcelSelectRow)+
            GhostDebugBln("return",ret),
            true );
        return(ret);
    }
//--- Assert SELECT_BY_POS where index=0 is FirstRow.
    else
    {
        if(pool==MODE_TRADES)       { return( ExcelOrderTradesSelect(index) ); }
        else if(pool==MODE_HISTORY) { return( ExcelOrderHistorySelect(index) ); }
    }
}

bool ExcelOrderTradesSelect(int index)
{
    bool ret;
    
//--- Find total orders 
    ExcelSelectRow=index+OpFirstRow;
//--- Assert OrdersTotal>0
    if(ExcelOrdersTotal()>0)
    {
    //--- Assert index is within range
        if(index>=0 && index<ExcelOrdersTotal()) ret=true;
    }    
            
//--- Debug    
    GhostDebugPrint( 2,"ExcelOrderTradesSelect",
        GhostDebugInt("index",index)+
        GhostDebugInt("total",ExcelOrdersTotal())+
        GhostDebugBln("return",ret),
        true );
    return(ret);
}

bool ExcelOrderHistorySelect(int index)
{
    bool ret;

//--- Find total history
    ExcelSelectRow=index+ThFirstRow;
//--- Assert OrdersHistoryTotal>0
    if(ExcelOrdersHistoryTotal()>0)
    {
    //--- Assert index is within range
       if(index>=0 && index<ExcelOrdersHistoryTotal()) ret=true;
    }

//--- Debug    
    GhostDebugPrint( 2,"ExcelOrderHistorySelect",
        GhostDebugInt("index",index)+
        GhostDebugInt("historyTotal",ExcelOrdersHistoryTotal())+
        GhostDebugBln("return",ret),
        true );
    return(ret);
}

double ExcelOrderClosePrice()
{
    switch(ExcelSelectMode)
    {
        case MODE_HISTORY: return(ExcelGetValue(ThSheet,ExcelSelectRow,ThClosePrice));
        case MODE_TRADES:
        default:           return(ExcelGetValue(PoSheet,ExcelSelectRow,PoClosePrice));
    }
    return(0.0);
}
datetime ExcelOrderCloseTime()
{
    switch(ExcelSelectMode)
    {
        case MODE_HISTORY: return(ExcelGetValue(ThSheet,ExcelSelectRow,ThCloseTime));
        case MODE_TRADES:
        default:           return(ExcelGetValue(PoSheet,ExcelSelectRow,PoCloseTime));
    }
    return(0);
}
string ExcelOrderComment()
{
    switch(ExcelSelectMode)
    {
        case MODE_HISTORY: return(ExcelGetString(ThSheet,ExcelSelectRow,ThComment));
        case MODE_TRADES:
        default:           return(ExcelGetString(OpSheet,ExcelSelectRow,OpComment));
    }
    return("");
}
datetime ExcelOrderExpiration()
{
    switch(ExcelSelectMode)
    {
        case MODE_HISTORY: return(ExcelGetValue(ThSheet,ExcelSelectRow,ThExpiration));
        case MODE_TRADES:
        default:           return(ExcelGetValue(PoSheet,ExcelSelectRow,PoExpiration));
    }
    return(0);
}
double ExcelOrderLots()
{
    switch(ExcelSelectMode)
    {
        case MODE_HISTORY: return(ExcelGetValue(ThSheet,ExcelSelectRow,ThLots));
        case MODE_TRADES:
        default:           return(ExcelGetValue(OpSheet,ExcelSelectRow,OpLots));
    }
    return(0.0);
}
int ExcelOrderMagicNumber()
{
    switch(ExcelSelectMode)
    {
        case MODE_HISTORY: return(ExcelGetValue(ThSheet,ExcelSelectRow,ThMagicNo));
        case MODE_TRADES:
        default:           return(ExcelGetValue(OpSheet,ExcelSelectRow,OpMagicNo));
    }
    return(0);
}

double ExcelOrderOpenPrice()
{
    switch(ExcelSelectMode)
    {
        case MODE_HISTORY: return(ExcelGetValue(ThSheet,ExcelSelectRow,ThOpenPrice));
        case MODE_TRADES:
        default:           return(ExcelGetValue(OpSheet,ExcelSelectRow,OpOpenPrice));
    }
    return(0.0);
}
datetime ExcelOrderOpenTime()
{
    switch(ExcelSelectMode)
    {
        case MODE_HISTORY: return(ExcelGetValue(ThSheet,ExcelSelectRow,ThOpenTime));
        case MODE_TRADES:
        default:           return(ExcelGetValue(OpSheet,ExcelSelectRow,OpOpenTime));
    }
    return(0);
}
double ExcelOrderProfit()
{
    double calcProfit;
    double closePrice;
    double lots;
    double openPrice;
    double pts;
    string sym;
    
    switch(ExcelSelectMode)
    {
        case MODE_HISTORY: return(ExcelGetValue(ThSheet,ExcelSelectRow,ThProfit));
        case MODE_TRADES:
        default:           
        //--- Exclude ALL pending orders
            if ( ExcelGetValue(OpSheet,ExcelSelectRow,OpType) > OP_SELL )   { return(0.0); }

        //--- Assert get lots, open and close prices
            lots        = ExcelGetValue(OpSheet,ExcelSelectRow,   OpLots);
            openPrice   = ExcelGetValue(OpSheet,ExcelSelectRow,   OpOpenPrice);
            sym         = ExcelGetString(OpSheet,ExcelSelectRow,  OpSymbol);
            pts = MarketInfo( sym, MODE_POINT );
            if ( ExcelGetValue(OpSheet,ExcelSelectRow,OpType) == OP_BUY )
            { 
               closePrice = MarketInfo( sym, MODE_BID ); 
      
            //--- Assert calculate profits      
               calcProfit = (closePrice-openPrice)*lots*TurtleBigValue(sym)/pts;
            }
            else if (ExcelGetValue(OpSheet,ExcelSelectRow,OpType) == OP_SELL )
            { 
               closePrice = MarketInfo( sym, MODE_ASK ); 

            //--- Assert calculate profits      
               calcProfit = (openPrice-closePrice)*lots*TurtleBigValue(sym)/pts;
            }
            return(calcProfit);
    }
    return(0.0);
}
double ExcelOrderStopLoss()
{
    switch(ExcelSelectMode)
    {
        case MODE_HISTORY: return(ExcelGetValue(ThSheet,ExcelSelectRow,ThStopLoss));
        case MODE_TRADES:
        default:           return(ExcelGetValue(OpSheet,ExcelSelectRow,OpStopLoss));
    }
    return(0.0);
}
string ExcelOrderSymbol()
{
    switch(ExcelSelectMode)
    {
        case MODE_HISTORY: return(ExcelGetString(ThSheet,ExcelSelectRow,ThSymbol));
        case MODE_TRADES:
        default:           return(ExcelGetString(OpSheet,ExcelSelectRow,OpSymbol));
    }
    return("");
}
double ExcelOrderTakeProfit()
{
    switch(ExcelSelectMode)
    {
        case MODE_HISTORY: return(ExcelGetValue(ThSheet,ExcelSelectRow,ThTakeProfit));
        case MODE_TRADES:
        default:           return(ExcelGetValue(OpSheet,ExcelSelectRow,OpTakeProfit));
    }
    return(0.0);
}
int ExcelOrderTicket()
{
    switch(ExcelSelectMode)
    {
        case MODE_HISTORY: return(ExcelGetValue(ThSheet,ExcelSelectRow,ThTicket));
        case MODE_TRADES:
        default:           return(ExcelGetValue(OpSheet,ExcelSelectRow,OpTicket));
    }
    return(0);
}
int ExcelOrderType()
{
    switch(ExcelSelectMode)
    {
        case MODE_HISTORY: return(ExcelGetValue(ThSheet,ExcelSelectRow,ThType));
        case MODE_TRADES:
        default:           return(ExcelGetValue(OpSheet,ExcelSelectRow,OpType));
    }
    return(0);
}

double ExcelAccountBalance()
{
    return(ExcelGetValue(AdSheet,AdFirstRow,AdBalance));
}
double ExcelAccountEquity()
{
    return(ExcelGetValue(AdSheet,AdFirstRow,AdEquity));
}
double ExcelAccountMargin()
{
    return(ExcelGetValue(AdSheet,AdFirstRow,AdMargin));
}
double ExcelAccountFreeMargin()
{
    return(0.0);
}
int ExcelAccountNumber()
{
    return(ExcelGetValue(AdSheet,AdFirstRow,AdAccountNo));
}
double ExcelAccountProfit()
{
    return(ExcelGetValue(AdSheet,AdFirstRow,AdProfit));
}

//|-----------------------------------------------------------------------------------------|
//|                                  C L O S E  O R D E R S                                 |
//|-----------------------------------------------------------------------------------------|
bool ExcelOrderClose(int ticket, double lots, double price, int slippage, color arrow=CLR_NONE)
{
    int r, histRow;
    double calcLots, closePrice, orderLots;
    double calcProfit, openPrice, pts;

//--- Assert ticket no exists in Open Positions ONLY.
    r=ExcelFindTicket(OpSheet,OpTicket,OpFirstRow,ticket);
    if(r<=0) 
    {
    //--- Debug    
        GhostDebugPrint( 1,"ExcelOrderClose",
         GhostDebugInt("ticket",ticket)+
         GhostDebugDbl("lots",lots,2)+
         GhostDebugDbl("price",price,5)+
         GhostDebugInt("slippage",slippage)+
         GhostDebugBln("return",false) );
        return(false);        
    }
//--- Exclude ALL pending orders
   if ( ExcelGetValue(OpSheet,r,OpType) > OP_SELL ) 
   { 
        return(false);        
   }
    
//--- Assert check if partial close or full close.
    orderLots=ExcelGetValue(OpSheet,r,OpLots);
    if(lots>=orderLots)
    { calcLots = ExcelGetValue(OpSheet,r,OpLots); }
    else
    { calcLots = lots; }

//--- Assert get close price and calculate profits
    openPrice = ExcelGetValue(OpSheet,r,OpOpenPrice);
    pts = MarketInfo( ExcelGetString(OpSheet,r,OpSymbol), MODE_POINT );
    if ( ExcelGetValue(OpSheet,r,OpType) == OP_BUY )
    { 
      closePrice = MarketInfo( ExcelGetString(OpSheet,r,OpSymbol), MODE_BID ); 
      
   //--- Assert calculate profits      
      calcProfit = (closePrice-openPrice)*calcLots*TurtleBigValue(Symbol())/pts;
    }
    else if (ExcelGetValue(OpSheet,r,OpType) == OP_SELL )
    { 
      closePrice = MarketInfo( ExcelGetString(OpSheet,r,OpSymbol), MODE_ASK ); 

   //--- Assert calculate profits      
      calcProfit = (openPrice-closePrice)*calcLots*TurtleBigValue(Symbol())/pts;
    }
    
//--- Assert adjustment to account details using BigValue.
    ExcelPutValue(AdSheet,AdFirstRow,AdBalance, ExcelGetValue(AdSheet,AdFirstRow,AdBalance)+calcProfit);

//--- Assert partial close to update Lots in row; otherwise delete entire row.
    if(calcLots<orderLots)
    { 
      ExcelPutValue(OpSheet,r,OpLots,orderLots-calcLots); 

    //--- Assert copy row to Trade History
      histRow=ExcelCopyRow(OpSheet,OpTicket,OpFirstRow,r,ThSheet,ThTicket,ThFirstRow);
      if(histRow>0)  
      {
      //--- Adjust trade history values.
         ExcelPutValue(ThSheet,histRow,ThLots,        calcLots);
         ExcelPutValue(ThSheet,histRow,ThClosePrice,  closePrice);
         ExcelPutValue(ThSheet,histRow,ThProfit,      calcProfit);
         ExcelPutValue(ThSheet,histRow,ThCloseTime,   TimeCurrent());
      }
    }
    else
    { 
    //--- Assert copy row to Trade History
      histRow=ExcelCopyRow(OpSheet,OpTicket,OpFirstRow,r,ThSheet,ThTicket,ThFirstRow);
      if(histRow>0)
      {
      //--- Adjust trade history values.
         ExcelPutValue(ThSheet,histRow,ThClosePrice,  closePrice);
         ExcelPutValue(ThSheet,histRow,ThProfit,      calcProfit);
         ExcelPutValue(ThSheet,histRow,ThCloseTime,   TimeCurrent());
      }

      if(r>=OpFirstRow) { ExcelDeleteRow(OpSheet,OpTicket,OpFirstRow,r); GhostCurOpenPositions --; }
    }
    
//--- Debug    
    GhostDebugPrint( 1,"ExcelOrderClose",
      GhostDebugInt("ticket",ticket)+
      GhostDebugDbl("lots",lots,2)+
      GhostDebugDbl("price",price,5)+
      GhostDebugInt("slippage",slippage)+
      GhostDebugBln("return",true) );
    return(true);
}

bool ExcelOrderDelete(int ticket, color arrow=CLR_NONE)
{
    int r;

//--- Assert ticket no exists in Pending Orders.
    r=ExcelFindTicket(PoSheet,PoTicket,PoFirstRow,ticket);
    if(r<=0) 
    {
    //--- Debug    
        if(GhostDebug>=1)   Print(GhostDebug,":ExcelOrderDelete(",ticket,",",arrow,"): return=false");
        return(false);        
    }
//--- Exclude ALL opened positions
   if ( ExcelGetValue(PoSheet,r,PoType) <= OP_SELL ) 
   { 
    //--- Debug    
        if(GhostDebug>=1)   Print(GhostDebug,":ExcelOrderDelete(",ticket,",",arrow,"): return=false");
        return(false);        
   }

//--- Assert delete pending order; DO NOT transfer to trade history as CANCELLED
   if(r>=PoFirstRow) ExcelDeleteRow(PoSheet,PoTicket,PoFirstRow,r); 
    
//--- Debug    
    if(GhostDebug>=1)   Print(GhostDebug,":ExcelOrderDelete(",ticket,",",arrow,"): return=true");
    return(true);
}

//|-----------------------------------------------------------------------------------------|
//|                             E X C E L   F U N C T I O N S                               |
//|-----------------------------------------------------------------------------------------|
int ExcelCopyRow(int sheet, int keyCol, int firstRow, int copyRow, int destSheet, int destKeyCol, int destFirstRow, int destCopyRow = 0)
{
   int r;
   
//--- Assert destination row is not zero
   if(destCopyRow==0)   destCopyRow=ExcelCreateRow(destSheet,destKeyCol,destFirstRow);
   if(destCopyRow==0)   return(-1);
   
//--- Copy ALL fields from source to destination
   ExcelPutValue(destSheet,destCopyRow,1,    ExcelGetValue(sheet,copyRow,1));
   ExcelPutValue(destSheet,destCopyRow,2,    ExcelGetValue(sheet,copyRow,2));
   ExcelPutValue(destSheet,destCopyRow,3,    ExcelGetValue(sheet,copyRow,3));
   ExcelPutValue(destSheet,destCopyRow,4,    ExcelGetValue(sheet,copyRow,4));
   ExcelPutValue(destSheet,destCopyRow,5,    ExcelGetValue(sheet,copyRow,5));
   ExcelPutValue(destSheet,destCopyRow,6,    ExcelGetValue(sheet,copyRow,6));
   ExcelPutValue(destSheet,destCopyRow,7,    ExcelGetValue(sheet,copyRow,7));
   ExcelPutValue(destSheet,destCopyRow,8,    ExcelGetValue(sheet,copyRow,8));
   ExcelPutValue(destSheet,destCopyRow,9,    ExcelGetValue(sheet,copyRow,9));
   ExcelPutValue(destSheet,destCopyRow,10,   ExcelGetValue(sheet,copyRow,10));
   ExcelPutValue(destSheet,destCopyRow,11,   ExcelGetValue(sheet,copyRow,11));
   ExcelPutValue(destSheet,destCopyRow,12,   ExcelGetValue(sheet,copyRow,12));
   ExcelPutValue(destSheet,destCopyRow,13,   ExcelGetValue(sheet,copyRow,13));
   ExcelPutValue(destSheet,destCopyRow,14,   ExcelGetValue(sheet,copyRow,14));
   ExcelPutString(destSheet,destCopyRow,15,  ExcelGetString(sheet,copyRow,15));
   ExcelPutString(destSheet,destCopyRow,16,  ExcelGetString(sheet,copyRow,16));
   ExcelPutString(destSheet,destCopyRow,17,  ExcelGetString(sheet,copyRow,17));

//--- Debug
   if(GhostDebug>=2)   Print(GhostDebug,":ExcelCopyRow(): destSheet=",destSheet,";destCopyRow=",destCopyRow,";sheet=",sheet,";copyRow=",copyRow);
   
   return(destCopyRow);
}

void ExcelDeleteRow(int sheet, int keyCol, int firstRow, int deleteRow)
{
    int r, lastRow;
    
//--- Move all rows, after rowFound, up by one.
    lastRow=ExcelCreateRow(sheet,keyCol,firstRow);
    lastRow --;

    for(r=lastRow;r>deleteRow;r--)
    {
        ExcelPutValue(sheet,r-1,1,      ExcelGetValue(sheet,r,1));
        ExcelPutValue(sheet,r-1,2,      ExcelGetValue(sheet,r,2));
        ExcelPutValue(sheet,r-1,3,      ExcelGetValue(sheet,r,3));
        ExcelPutValue(sheet,r-1,4,      ExcelGetValue(sheet,r,4));
        ExcelPutValue(sheet,r-1,5,      ExcelGetValue(sheet,r,5));
        ExcelPutValue(sheet,r-1,6,      ExcelGetValue(sheet,r,6));
        ExcelPutValue(sheet,r-1,7,      ExcelGetValue(sheet,r,7));
        ExcelPutValue(sheet,r-1,8,      ExcelGetValue(sheet,r,8));
        ExcelPutValue(sheet,r-1,9,      ExcelGetValue(sheet,r,9));
        ExcelPutValue(sheet,r-1,10,     ExcelGetValue(sheet,r,10));
        ExcelPutValue(sheet,r-1,11,     ExcelGetValue(sheet,r,11));
        ExcelPutValue(sheet,r-1,12,     ExcelGetValue(sheet,r,12));
        ExcelPutValue(sheet,r-1,13,     ExcelGetValue(sheet,r,13));
        ExcelPutValue(sheet,r-1,14,     ExcelGetValue(sheet,r,14));
        ExcelPutString(sheet,r-1,15,    ExcelGetString(sheet,r,15));
        ExcelPutString(sheet,r-1,16,    ExcelGetString(sheet,r,16));
        ExcelPutString(sheet,r-1,17,    ExcelGetString(sheet,r,17));
    }
//--- Debug
    if(GhostDebug>=2)   Print(GhostDebug,":ExcelDeleteRow(): lastRow=",lastRow,";deleteRow=",deleteRow);
    
//--- Clear last row, after all rows have been moved up by one.
    ExcelPutValue(sheet,lastRow,1,    0);
    ExcelPutValue(sheet,lastRow,2,    0);
    ExcelPutValue(sheet,lastRow,3,    0);
    ExcelPutValue(sheet,lastRow,4,    0);
    ExcelPutValue(sheet,lastRow,5,    0);
    ExcelPutValue(sheet,lastRow,6,    0);
    ExcelPutValue(sheet,lastRow,7,    0);
    ExcelPutValue(sheet,lastRow,8,    0);
    ExcelPutValue(sheet,lastRow,9,    0);
    ExcelPutValue(sheet,lastRow,10,   0);
    ExcelPutValue(sheet,lastRow,11,   0);
    ExcelPutValue(sheet,lastRow,12,   0);
    ExcelPutValue(sheet,lastRow,13,   0);
    ExcelPutValue(sheet,lastRow,14,   0);
    ExcelPutString(sheet,lastRow,15,  "");
    ExcelPutString(sheet,lastRow,16,  "");
    ExcelPutString(sheet,lastRow,17,  "");
}

