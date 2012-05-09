//|-----------------------------------------------------------------------------------------|
//|                                                                           PlusGhost.mqh |
//|                                                            Copyright © 2012, Dennis Lee |
//| Assert History                                                                          |
//| 1.00    Show trades in a separate window "GhostTerminal".                               |
//| 1.10    GhostMode has the following status:                                             |
//|             0   - Broker trades (Real)                                                  |
//|             1   - Paper trades using ExcelLink                                          |
//|             2   - Paper trades using SQL (To be implemented)                            |
//| 1.20    Implemented GhostOrderSend, GhostOrderModify and GhostOrderClose.               |
//| 1.21    Implemented ExcelManager(), enhanced ordering functions, added                  |
//|             debugging statements, and fixed ExcelDeleteRow().                           |
//| 1.22    Implemented GhostOrderSelect(), ExcelOrderSelect, and associated order select   |
//|             functions, and fixed ExcelOrderModify().                                    |
//| 1.23    Fixed ExcelOrderSelect() and GhostOrderTicket().                                |
//| 1.24    Implemented ExcelOrderProfit().                                                 |
//| 1.25    Fixed calculation of profit.                                                    |
//| 1.30    Record statistics of opened trades when in paper trading mode.                  |
//| 1.40    Keep a paper trail of all trades (can be set to false).                         |
//| 1.50    Added MODE_HISTORY in ExcelOrderSelect().                                       |
//|            Added GhostOrderDelete(), GhostOrderPrint(), GhostOrderClosePrice(),         |
//|            GhostOrderCloseTime(),GhostAccountBalance(), GhostAccountEquity(),           |
//|            GhostAccountFreeMargin(),GhostAccountMargin() and related Excel functions.   |
//|            Fixed Excel headers - accidentally replaced with Trade History.              |
//|            Fixed GhostCurOpenPositions - decrease by one for EACH closed order.         |
//| 1.60    Split file into GhostExcel, GhostMySql, and GhostSqLite.                        |
//| 1.61    Display versions of SqLite and Excel, and fixed summary display for SqLite.     |
//| 1.62    Removed PlusEasy.mqh dependency for Pts. Allow user to change ExpertName.       |
//| 1.63    Replaced bool GhostTradeHistory with GhostStatistics (history is now compulsory |
//|            but statistics is an option - to do statistics with 0-Broker).               |
//|         Additional Debug functions.                                                     |
//| 1.64    Minor fixes in debug functions and Pts.                                         |
//| 1.70    Split file into GhostBroker and allow record statistics of opened trades when   |
//|            in live trading mode.                                                        |
//| 1.71    Fixed memory leak in OrderSelect() for SELECT_BY_TICKET mode and added          |
//|            OrderDelete for SqLite.                                                      |
//|-----------------------------------------------------------------------------------------|
#property   copyright "Copyright © 2012, Dennis Lee"

//|-----------------------------------------------------------------------------------------|
//|                 P L U S L I N E X   E X T E R N A L   V A R I A B L E S                 |
//|-----------------------------------------------------------------------------------------|
extern   string GhostTerminal           = "GhostTerminal";
extern   string g1                      = "Mode: 0-Broker; 1-Excel; 2-SqLite";
extern   int    GhostMode               = 0;
extern   bool   GhostStatistics         = false;
extern   string g2                      = "ExpertName: Unique filename";
extern   string GhostExpertName         = "EA";
extern   int    GhostRows               = 10;
extern   int	GhostPipLimit			= 10;
extern   bool   GhostBigText            = false;
extern   color  GhostMainColor          = White;
extern   color  GhostBuyColor           = Green;
extern   color  GhostBuyOPColor         = Lime;
extern   color  GhostBuySLColor         = Lime;
extern   color  GhostBuyTPColor         = Lime;
extern   color  GhostSellColor          = Crimson;
extern   color  GhostSellOPColor        = Red;
extern   color  GhostSellSLColor        = Red;
extern   color  GhostSellTPColor        = Red;
extern   string g3                      = "Debug: 0-Crit; 1-Core; 2-Detail";
extern   int    GhostDebug              = 1;
extern   int    GhostCount              = 1000;

//|-----------------------------------------------------------------------------------------|
//|                           I N T E R N A L   V A R I A B L E S                           |
//|-----------------------------------------------------------------------------------------|
string   GhostName="PlusGhost";
string   GhostVer="1.71";
int      gCount=0;

//---- Assert internal variables for GhostTerminal
string   GhostFontType="Arial";
int      GhostFontSize=8;
int      GhostWin=-1;
string   GhostOpenPositions[1][11];
string   GhostPendingOrders[1][11];
int      GhostCurOpenPositions=0;
int      GhostCurPendingOrders=0;
double   GhostSummProfit=0.0;
double   GhostPts;

//---- Terminal window column positions
int      TwTicket       = 0;
int      TwOpenTime     = 1;
int      TwType         = 2;
int      TwLots         = 3;
int      TwOpenPrice    = 4;
int      TwStopLoss     = 5;
int      TwTakeProfit   = 6;
int      TwCurPrice     = 7;
int      TwSwap         = 8;
int      TwProfit       = 9;
int      TwComment      = 10;

#include    <GhostExcel.mqh>
#include    <GhostSqLite.mqh>
#include    <GhostBroker.mqh>

//|-----------------------------------------------------------------------------------------|
//|                             I N I T I A L I Z A T I O N                                 |
//|-----------------------------------------------------------------------------------------|
void GhostInit()
{
   string eaName;
//---- Automatically adjust to Full-Pip or Sub-Pip Accounts
   if (Digits==4||Digits==2)
   {
      GhostPts=Point;
   }
   if (Digits==5||Digits==3)
   {
      GhostPts=Point*10;
   }
//---- Automatically adjust one decimal place left for Gold
   if (Symbol()=="XAUUSD") 
   {
      GhostPts*=10;
   }

   if(GhostExpertName=="") eaName="EA";
   else eaName=GhostExpertName;
  
   GhostTerminalInit();

//-- Assert Excel or SQL files are created.
   switch(GhostMode)
   {
      case 1:  if(!ExcelCreate(AccountNumber(),Symbol(),Period(),eaName)) { GhostMode=0; }
               break;
      case 2:  if(!SqLiteCreate(AccountNumber(),Symbol(),Period(),eaName)) { GhostMode=0; }
               break;
      default: if(!BrokerCreate(AccountNumber(),Symbol(),Period(),eaName)) { GhostStatistics=false; }
               break;
   }
}

//|-----------------------------------------------------------------------------------------|
//|                               M A I N   P R O C E D U R E                               |
//|-----------------------------------------------------------------------------------------|
void GhostRefresh()
{
//-- Assert terminal buffers are loaded.
    switch(GhostMode)
    {
        case 1:     ExcelManager();
                    ExcelLoadBuffers();     
                    break;
        case 2:     SqLiteManager();
                    SqLiteLoadBuffers();
                    break;
        default:    BrokerLoadBuffers();    
                    break;
    }

//-- Assert GhostTerminal exists.
    if(GhostWin<0) return(-1);
    
//--- Assert refresh terminal window.
    GhostTerminalRefresh(GhostPts);
}

//|-----------------------------------------------------------------------------------------|
//|                             D E I N I T I A L I Z A T I O N                             |
//|-----------------------------------------------------------------------------------------|
void GhostDeInit()
{
    GhostTerminalDeInit();
    
//-- Assert Excel or SQL files are saved.
    switch(GhostMode)
    {
        case 1: //--- Assert save file.
                    ExcelSaveFile(ExcelFileName);
                    ExcelEnd();
                    break;
        case 2: //--- Assert close database.
                    SqLiteDeInit();
                    break;
        default://--- Assert close dependency.
                    BrokerDeInit();
                    break;
    }
}

//|-----------------------------------------------------------------------------------------|
//|                                 O P E N   O R D E R S                                   |
//|-----------------------------------------------------------------------------------------|
int GhostOrderSend(string symbol, int type, double lots, double price, int slippage,
                    double stoploss, double takeprofit, string comment="", int magic=0,
                    datetime expiration=0, color arrow_color=CLR_NONE)
{
    int ret;
    
    switch(GhostMode)
    {
        case 1:     ret=ExcelOrderSend(symbol,type,lots,price,slippage,stoploss,takeprofit,comment,magic,expiration,arrow_color);
                    ExcelSaveFile(ExcelFileName);
                    return(ret);
        case 2:     ret=SqLiteOrderSend(symbol,type,lots,price,slippage,stoploss,takeprofit,comment,magic,expiration,arrow_color);
                    return(ret);
        default:    return(OrderSend(symbol,type,lots,price,slippage,stoploss,takeprofit,comment,magic,expiration,arrow_color));
    }
    return(0);
}

bool GhostOrderModify(int ticket, double price, double stoploss, double takeprofit, 
                        datetime expiration=0, color arrow_color=CLR_NONE)
{
    int ret;
    
    switch(GhostMode)
    {
        case 1:     ret=ExcelOrderModify(ticket,price,stoploss,takeprofit,expiration,arrow_color);
                    ExcelSaveFile(ExcelFileName);
                    return(ret);
        case 2:     ret=SqLiteOrderModify(ticket,price,stoploss,takeprofit,expiration,arrow_color);
                    return(ret);
        default:    return(OrderModify(ticket,price,stoploss,takeprofit,expiration,arrow_color));
    }
    return(false);
}

//|-----------------------------------------------------------------------------------------|
//|                                O R D E R S   S T A T U S                                |
//|-----------------------------------------------------------------------------------------|
int GhostOrdersTotal()
{
    int ret;
    
    switch(GhostMode)
    {
        case 1:     ret=ExcelOrdersTotal();
                    return(ret);
        case 2:     ret=SqLiteOrdersTotal();
                    return(ret);
        default:    return(OrdersTotal());
    }
    return(0);
}

int GhostOrdersHistoryTotal()
{
    int ret;
    
    switch(GhostMode)
    {
        case 1:     ret=ExcelOrdersHistoryTotal();
                    return(ret);
        case 2:     ret=SqLiteOrdersHistoryTotal();
                    return(ret);
        default:    return(OrdersHistoryTotal());
    }
    return(0);
}

double GhostOrderClosePrice()
{
    double ret;
    
    switch(GhostMode)
    {
        case 1:     ret=ExcelOrderClosePrice();
                    return(ret);
        case 2:     ret=SqLiteOrderClosePrice();
                    return(ret);
        default:    return(OrderClosePrice());
    }
    return(0.0);
}

datetime GhostOrderCloseTime()
{
    datetime ret;
    
    switch(GhostMode)
    {
        case 1:     ret=ExcelOrderCloseTime();
                    return(ret);
        case 2:     ret=SqLiteOrderCloseTime();
                    return(ret);
        default:    return(OrderCloseTime());
    }
    return(0);
}

string GhostOrderComment()
{
    string ret;
    
    switch(GhostMode)
    {
        case 1:     ret=ExcelOrderComment();
                    return(ret);
        case 2:     ret=SqLiteOrderComment();
                    return(ret);
        default:    return(OrderComment());
    }
    return("");
}

double GhostOrderCommission()
{
    double ret;
    
    switch(GhostMode)
    {
        case 1:     ret=0.0;            //ExcelOrderCommission() to be implemented
                    return(ret);
        case 2:     ret=0.0;
                    return(ret);
        default:    return(OrderCommission());
    }
    return(0.0);
}

datetime GhostOrderExpiration()
{
    datetime ret;
    
    switch(GhostMode)
    {
        case 1:     ret=0.0;            //ExcelOrderExpiration() to be implemented
                    return(ret);
        case 2:     ret=SqLiteOrderExpiration();
                    return(ret);
        default:    return(OrderExpiration());
    }
    return(0);
}

double GhostOrderLots()
{
    double ret;
    
    switch(GhostMode)
    {
        case 1:     ret=ExcelOrderLots();
                    return(ret);
        case 2:     ret=SqLiteOrderLots();
                    return(ret);
        default:    return(OrderLots());
    }
    return(0.0);
}

double GhostOrderOpenPrice()
{
    double ret;
    
    switch(GhostMode)
    {
        case 1:     ret=ExcelOrderOpenPrice();
                    return(ret);
        case 2:     ret=SqLiteOrderOpenPrice();
                    return(ret);
        default:    return(OrderOpenPrice());
    }
    return(0.0);
}

datetime GhostOrderOpenTime()
{
    datetime ret;
    
    switch(GhostMode)
    {
        case 1:     ret=ExcelOrderOpenTime();
                    return(ret);
        case 2:     ret=SqLiteOrderOpenTime();
                    return(ret);
        default:    return(OrderOpenTime());
    }
    return(0);
}

void GhostOrderPrint()
{
    double ret;
    
    switch(GhostMode)
    {
        case 1:     return(ret);
        case 2:     return(ret);
        default:    OrderPrint();
    }
    return(0.0);
}

double GhostOrderProfit()
{
    double ret;
    
    switch(GhostMode)
    {
        case 1:     ret=ExcelOrderProfit();
                    return(ret);
        case 2:     ret=SqLiteOrderProfit();
                    return(ret);
        default:    return(OrderProfit());
    }
    return(0.0);
}

bool GhostInitSelect(bool asc, int index, int select, int pool)
{
    bool ret;
    
    switch(GhostMode)
    {
        case 1:     return(true);
        case 2:     ret=SqLiteInitSelect(asc,index,select,pool);
                    return(ret);
        default:    return(true);
    }
    return(false);
}

bool GhostOrderSelect(int index,int select, int pool=MODE_TRADES)
{
    bool ret;
    
    switch(GhostMode)
    {
        case 1:     ret=ExcelOrderSelect(index,select,pool);
                    return(ret);
        case 2:     ret=SqLiteOrderSelect(index,select,pool);
                    return(ret);
        default:    return(OrderSelect(index,select,pool));
    }
    return(false);
}

void GhostFreeSelect(bool incr=true)
{
    bool ret;
    
    switch(GhostMode)
    {
        case 1:     return(0);
        case 2:     SqLiteFreeSelect(incr);
                    return(0);
        default:    return(0);
    }
    return(0);
}

double GhostOrderStopLoss()
{
    double ret;
    
    switch(GhostMode)
    {
        case 1:     ret=ExcelOrderStopLoss();
                    return(ret);
        case 2:     ret=SqLiteOrderStopLoss();
                    return(ret);
        default:    return(OrderStopLoss());
    }
    return(0.0);
}

double GhostOrderSwap()
{
    double ret;
    
    switch(GhostMode)
    {
        case 1:     ret=0.0;            //ExcelOrderSwap() to be implemented
                    return(ret);
        case 2:     ret=0.0;
                    return(ret);
        default:    return(OrderSwap());
    }
    return(0.0);
}

string GhostOrderSymbol()
{
    string ret;
    
    switch(GhostMode)
    {
        case 1:     ret=ExcelOrderSymbol();
                    return(ret);
        case 2:     ret=SqLiteOrderSymbol();
                    return(ret);
        default:    return(OrderSymbol());
    }
    return("");
}

double GhostOrderTakeProfit()
{
    double ret;
    
    switch(GhostMode)
    {
        case 1:     ret=ExcelOrderTakeProfit();
                    return(ret);
        case 2:     ret=SqLiteOrderTakeProfit();
                    return(ret);
        default:    return(OrderTakeProfit());
    }
    return(0.0);
}

int GhostOrderType()
{
    int ret;
    
    switch(GhostMode)
    {
        case 1:     ret=ExcelOrderType();
                    return(ret);
        case 2:     ret=SqLiteOrderType();
                    return(ret);
        default:    return(OrderType());
    }
    return(0);
}

int GhostOrderMagicNumber()
{
    int ret;
    
    switch(GhostMode)
    {
        case 1:     ret=ExcelOrderMagicNumber();
                    return(ret);
        case 2:     ret=SqLiteOrderMagicNumber();
                    return(ret);
        default:    return(OrderMagicNumber());
    }
    return(0);
}

int GhostOrderTicket()
{
    int ret;
    
    switch(GhostMode)
    {
        case 1:     ret=ExcelOrderTicket();
                    return(ret);
        case 2:     ret=SqLiteOrderTicket();
                    return(ret);
        default:    return(OrderTicket());
    }
    return(0);
}

double GhostAccountBalance()
{
    double ret;
    
    switch(GhostMode)
    {
        case 1:     ret=ExcelAccountBalance();
                    return(ret);
        case 2:     ret=SqLiteAccountBalance();
                    return(ret);
        default:    return(AccountBalance());
    }
    return(0.0);
}

double GhostAccountEquity()
{
    double ret;
    
    switch(GhostMode)
    {
        case 1:     ret=ExcelAccountEquity();
                    return(ret);
        case 2:     ret=SqLiteAccountEquity();
                    return(ret);
        default:    return(AccountEquity());
    }
    return(0.0);
}

double GhostAccountFreeMargin()
{
    double ret;
    
    switch(GhostMode)
    {
        case 1:     ret=ExcelAccountFreeMargin();
                    return(ret);
        case 2:     ret=SqLiteAccountFreeMargin();
                    return(ret);
        default:    return(AccountFreeMargin());
    }
    return(0.0);
}

double GhostAccountMargin()
{
    double ret;
    
    switch(GhostMode)
    {
        case 1:     ret=ExcelAccountMargin();
                    return(ret);
        case 2:     ret=SqLiteAccountMargin();
                    return(ret);
        default:    return(AccountMargin());
    }
    return(0.0);
}

int GhostAccountNumber()
{
    int ret;
    
    switch(GhostMode)
    {
        case 1:     ret=AccountNumber();
                    return(ret);
        case 2:     ret=SqLiteAccountNumber();
                    return(ret);
        default:    return(AccountNumber());
    }
    return(0.0);
}

//|-----------------------------------------------------------------------------------------|
//|                                  C L O S E  O R D E R S                                 |
//|-----------------------------------------------------------------------------------------|
bool GhostOrderClose(int ticket, double lots, double price, int slippage, color arrow=CLR_NONE)
{
    int ret;
    
    switch(GhostMode)
    {
        case 1:     ret=ExcelOrderClose(ticket,lots,price,slippage,arrow);
                    ExcelSaveFile(ExcelFileName);
                    return(ret);
        case 2:     ret=SqLiteOrderClose(ticket,lots,price,slippage,arrow);
                    return(ret);
        default:    return(OrderClose(ticket,lots,price,slippage,arrow));
    }
}

bool GhostOrderDelete(int ticket, color arrow=CLR_NONE)
{
    int ret;
    
    switch(GhostMode)
    {
        case 1:     ret=ExcelOrderDelete(ticket,arrow);
                    ExcelSaveFile(ExcelFileName);
                    return(ret);
        case 2:     ret=SqLiteOrderDelete(ticket,arrow);
                    return(ret);
        default:    return(OrderDelete(ticket,arrow));
    }
    return(false);
}

//|-----------------------------------------------------------------------------------------|
//|                                     C O M M E N T                                       |
//|-----------------------------------------------------------------------------------------|
string GhostComment(string cmt="")
{
   int total;
   
   string strtmp = cmt+"  -->"+GhostName+" "+GhostVer+"<--";

//---- Assert Trade info in comment
   total=GhostOrdersTotal();
   if(GhostMode==0)
   {
      strtmp=strtmp+"\n    No Ghost Trading.";
      if( GhostStatistics )
         strtmp=strtmp+" (Broker "+BrokerVer+")";
   }
   else 
   {
   //---- Assert Basic settings in comment
      strtmp=strtmp+"\n    Mode="+DoubleToStr(GhostMode,0);
      if(GhostMode==1)
         strtmp=strtmp+" (Excel "+ExcelVer+")";
      else
         strtmp=strtmp+" (SqLite "+SqLiteVer+")";
      if(total<=0)
         strtmp=strtmp+"\n    No Active Ghost Trades.";
      else
         strtmp=strtmp+"\n    Ghost Trades="+total;
   }
//--- Assert Statistics kept for both live and paper trading
   if(GhostStatistics==false)
      strtmp=strtmp+"\n    No Statistics.";
   else
   {
      strtmp=strtmp+"\n    Keep Statistics.";
      if( GhostMode==0 )
         strtmp=strtmp+" (SqLite "+SqLiteVer+")";
   }
                         
   strtmp=strtmp+"\n";
   return(strtmp);
}

void GhostDebugPrint(int dbg, string fn, string msg, bool incr=true, int mod=0)
{
   if(GhostDebug>=dbg)
   {
      if(dbg>=2 && GhostCount>0)
      {
         if( MathMod(gCount,GhostCount) == mod )
            Print(GhostDebug,"-",gCount,":",fn,"(): ",msg);
         if( incr )
            gCount ++;
      }
      else
         Print(GhostDebug,":",fn,"(): ",msg);
   }
}
string GhostDebugInt(string key, int val)
{
   return( StringConcatenate(";",key,"=",val) );
}
string GhostDebugDbl(string key, double val, int dgt=5)
{
   return( StringConcatenate(";",key,"=",NormalizeDouble(val,dgt)) );
}
string GhostDebugStr(string key, string val)
{
   return( StringConcatenate(";",key,"=\"",val,"\"") );
}
string GhostDebugBln(string key, bool val)
{
   string valType;
   if( val )   valType="true";
   else        valType="false";
   return( StringConcatenate(";",key,"=",valType) );
}


//|-----------------------------------------------------------------------------------------|
//|                             T E R M I N A L   F U N C T I O N S                         |
//|-----------------------------------------------------------------------------------------|
void GhostTerminalRefresh(double Pts)
{
	bool    summLineOK = false;
	double  summProfit=0.0;
	color   tmp_MainColor, tmp_SLColor, tmp_TPColor, tmp_OPColor;

//-- Assert find window for terminal.
    GhostWin = WindowFind(GhostTerminal);
//-- Assert NOT testing mode.
    if(IsTesting()) GhostWin=-1;
//-- Assert GhostTerminal exists.
    if(GhostWin<0) return(-1);
    
//-- Assert refresh terminal line by line.    
	for(int i=0; i<GhostRows; i++)
	{
		if(i<GhostCurOpenPositions)
		{
			if(GhostOpenPositions[i][TwType]=="Buy")
			{
				tmp_MainColor = GhostBuyColor;

				if ( StrToDouble( GhostOpenPositions[i][TwStopLoss] ) > 0 &&  NormalizeDouble( GhostPipLimit*Pts - ( StrToDouble( GhostOpenPositions[i][TwCurPrice] ) - StrToDouble( GhostOpenPositions[i][TwStopLoss] ) ), Digits ) >= 0.0 )
				{ tmp_SLColor = GhostBuySLColor; }
				else
				{ tmp_SLColor = GhostBuyColor; }

				if ( StrToDouble( GhostOpenPositions[i][TwTakeProfit] ) > 0 && NormalizeDouble( GhostPipLimit*Pts - ( StrToDouble( GhostOpenPositions[i][TwTakeProfit] ) - StrToDouble( GhostOpenPositions[i][TwCurPrice] ) ), Digits ) >= 0.0 )
				{ tmp_TPColor = GhostBuyTPColor; }
				else
				{ tmp_TPColor = GhostBuyColor; }
			}
			else
			{
				tmp_MainColor = GhostSellColor;

				if ( StrToDouble( GhostOpenPositions[i][TwStopLoss] ) > 0 &&  NormalizeDouble( GhostPipLimit*Pts - ( StrToDouble( GhostOpenPositions[i][TwStopLoss] ) - StrToDouble( GhostOpenPositions[i][TwCurPrice] ) ), Digits ) >= 0.0 )
				{ tmp_SLColor = GhostSellSLColor; }
				else
				{ tmp_SLColor = GhostSellColor; }

				if ( StrToDouble( GhostOpenPositions[i][TwTakeProfit] ) > 0 && NormalizeDouble( GhostPipLimit*Pts - ( StrToDouble( GhostOpenPositions[i][TwCurPrice] ) - StrToDouble( GhostOpenPositions[i][TwTakeProfit] ) ), Digits ) >= 0.0 )
				{ tmp_TPColor = GhostSellTPColor; }
				else
				{ tmp_TPColor = GhostSellColor; }
			}

			GhostSetText( "Ticket_" 	+ i, GhostOpenPositions[i][TwTicket]	, tmp_MainColor );
			GhostSetText( "OpenTime_" 	+ i, GhostOpenPositions[i][TwOpenTime]	, tmp_MainColor );
			GhostSetText( "Type_" 		+ i, GhostOpenPositions[i][TwType]   	, tmp_MainColor );
			GhostSetText( "Lots_" 		+ i, GhostOpenPositions[i][TwLots]   	, tmp_MainColor );
			GhostSetText( "OpenPrice_" 	+ i, GhostOpenPositions[i][TwOpenPrice]	, tmp_MainColor );
			GhostSetText( "StopLoss_" 	+ i, GhostOpenPositions[i][TwStopLoss]	, tmp_SLColor );
			GhostSetText( "TakeProfit_" + i, GhostOpenPositions[i][TwTakeProfit], tmp_TPColor );
			GhostSetText( "CurPrice_" 	+ i, GhostOpenPositions[i][TwCurPrice]	, tmp_MainColor );
			GhostSetText( "Swap_" 		+ i, GhostOpenPositions[i][TwSwap]   	, tmp_MainColor );
			GhostSetText( "Profit_" 	+ i, GhostOpenPositions[i][TwProfit]	, tmp_MainColor );
			GhostSetText( "Comment_" 	+ i, GhostOpenPositions[i][TwComment]	, tmp_MainColor );
		}
		else
		{
			if(!summLineOK)
			{
            switch(GhostMode)
            {
               case 1:     GhostSummaryDisplay(i,ExcelAccountBalance(),ExcelAccountEquity(),ExcelAccountMargin(),0.0);
                           break;
               case 2:     GhostSummaryDisplay(i,SqLiteAccountBalance(),SqLiteAccountEquity(),SqLiteAccountMargin(),SqLiteAccountFreeMargin());
                           break;
               default:    GhostSummaryDisplay(i,AccountBalance(),AccountEquity(),AccountMargin(),AccountFreeMargin());
            }
         	i ++;
				summLineOK = true;
			}

			if ( i <= GhostCurOpenPositions + GhostCurPendingOrders )
			{
				if ( GhostPendingOrders[i-GhostCurOpenPositions-1][TwType] == "BuyLimit" || GhostPendingOrders[i-GhostCurOpenPositions-1][TwType] == "BuyStop" )
				{
					tmp_MainColor = GhostBuyColor;

					if ( NormalizeDouble( GhostPipLimit*Pts - MathAbs( StrToDouble( GhostPendingOrders[i-GhostCurOpenPositions-1][TwOpenPrice] ) - StrToDouble( GhostPendingOrders[i-GhostCurOpenPositions-1][TwCurPrice] ) ), Digits ) >= 0.0 )
					{ tmp_OPColor = GhostBuyOPColor; }
					else
					{ tmp_OPColor = GhostBuyColor; }
				}
				else
				{
					tmp_MainColor = GhostSellColor;

					if ( NormalizeDouble( GhostPipLimit*Pts - MathAbs( StrToDouble( GhostPendingOrders[i-GhostCurOpenPositions-1][TwOpenPrice] ) - StrToDouble( GhostPendingOrders[i-GhostCurOpenPositions-1][TwCurPrice] ) ), Digits ) >= 0.0 )
					{ tmp_OPColor = GhostSellOPColor; }
					else
					{ tmp_OPColor = GhostSellColor; }
				}
				GhostSetText( "Ticket_" 	+ i, GhostPendingOrders[i-GhostCurOpenPositions-1][TwTicket]    , tmp_MainColor );
				GhostSetText( "OpenTime_" 	+ i, GhostPendingOrders[i-GhostCurOpenPositions-1][TwOpenTime]  , tmp_MainColor );
				GhostSetText( "Type_" 		+ i, GhostPendingOrders[i-GhostCurOpenPositions-1][TwType]      , tmp_MainColor );
				GhostSetText( "Lots_" 		+ i, GhostPendingOrders[i-GhostCurOpenPositions-1][TwLots]      , tmp_MainColor );
				GhostSetText( "OpenPrice_" 	+ i, GhostPendingOrders[i-GhostCurOpenPositions-1][TwOpenPrice] , tmp_OPColor	);
				GhostSetText( "StopLoss_" 	+ i, GhostPendingOrders[i-GhostCurOpenPositions-1][TwStopLoss]  , tmp_MainColor );
				GhostSetText( "TakeProfit_" + i, GhostPendingOrders[i-GhostCurOpenPositions-1][TwTakeProfit], tmp_MainColor );
				GhostSetText( "CurPrice_" 	+ i, GhostPendingOrders[i-GhostCurOpenPositions-1][TwCurPrice]  , tmp_MainColor );
				GhostSetText( "Swap_" 		+ i, GhostPendingOrders[i-GhostCurOpenPositions-1][TwSwap]      , tmp_MainColor );
				GhostSetText( "Profit_" 	+ i, GhostPendingOrders[i-GhostCurOpenPositions-1][TwProfit]    , tmp_MainColor );
				GhostSetText( "Comment_" 	+ i, GhostPendingOrders[i-GhostCurOpenPositions-1][TwComment]   , tmp_MainColor );
			}
			else
			{
				GhostSetText( "Ticket_" 	+ i );
				GhostSetText( "OpenTime_" 	+ i );
				GhostSetText( "Type_" 		+ i );
				GhostSetText( "Lots_" 		+ i );
				GhostSetText( "OpenPrice_" 	+ i );
				GhostSetText( "StopLoss_" 	+ i );
				GhostSetText( "TakeProfit_" + i );
				GhostSetText( "CurPrice_" 	+ i );
				GhostSetText( "Swap_" 		+ i );
				GhostSetText( "Profit_" 	+ i );
				GhostSetText( "Comment_" 	+ i );
			}
		}
	}
	ObjectsRedraw();
	return(0);    
}

void GhostTerminalInit()
{
//-- Assert Dynamically resize buffers.
	ArrayResize(GhostOpenPositions,GhostRows);
	ArrayResize(GhostPendingOrders,GhostRows);

//-- Assert find window for terminal.
    GhostWin = WindowFind(GhostTerminal);
//-- Assert NOT testing mode.
    if(IsTesting()) GhostWin=-1;
//-- Assert GhostTerminal exists.
    if(GhostWin<0) return(-1);

	int vshift=13, shift1=3, shift2=60, shift3=160, shift4=220, shift5=260, shift6=325, shift7=385, shift8=445, shift9=500, shift10=555, shift11=610;
	if(GhostBigText)
	{
		GhostFontSize++; 
        vshift=15; shift1=3; shift2=70; shift3=185; shift4=255; shift5=305; shift6=380; shift7=450; shift8=520; shift9=605; shift10=660; shift11=725;
	}

	GhostLabel( "Ticket_Head"		, shift1	, vshift ); GhostSetText( "Ticket_Head"		, "Ticket"		, GhostMainColor );
	GhostLabel( "OpenTime_Head"		, shift2	, vshift ); GhostSetText( "OpenTime_Head"	, "OpenTime"	, GhostMainColor );
	GhostLabel( "Type_Head"			, shift3	, vshift ); GhostSetText( "Type_Head"		, "Type"		, GhostMainColor );
	GhostLabel( "Lots_Head"			, shift4	, vshift ); GhostSetText( "Lots_Head"		, "Lots"		, GhostMainColor );
	GhostLabel( "OpenPrice_Head"	, shift5	, vshift ); GhostSetText( "OpenPrice_Head"	, "OpenPrice"	, GhostMainColor );
	GhostLabel( "StopLoss_Head"	    , shift6	, vshift ); GhostSetText( "StopLoss_Head"	, "StopLoss"	, GhostMainColor );
	GhostLabel( "TakeProfit_Head"   , shift7	, vshift ); GhostSetText( "TakeProfit_Head"	, "TakeProfit"	, GhostMainColor );
	GhostLabel( "CurPrice_Head"		, shift8	, vshift ); GhostSetText( "CurPrice_Head"	, "CurPrice"	, GhostMainColor );
	GhostLabel( "Swap_Head"			, shift9    , vshift ); GhostSetText( "Swap_Head"		, "Swap"		, GhostMainColor );
	GhostLabel( "Profit_Head"		, shift10   , vshift ); GhostSetText( "Profit_Head"		, "Profit"		, GhostMainColor );
	GhostLabel( "Comment_Head"		, shift11   , vshift ); GhostSetText( "Comment_Head"		, "Comment"		, GhostMainColor );

	for(int i=0; i<GhostRows; i++)
	{
		GhostLabel ( "Ticket_" 		+ i, shift1, vshift*(i+2) );
		GhostLabel ( "OpenTime_" 	+ i, shift2, vshift*(i+2) );
		GhostLabel ( "Type_" 		+ i, shift3, vshift*(i+2) );
		GhostLabel ( "Lots_" 		+ i, shift4, vshift*(i+2) );
		GhostLabel ( "OpenPrice_" 	+ i, shift5, vshift*(i+2) );
		GhostLabel ( "StopLoss_" 	+ i, shift6, vshift*(i+2) );
		GhostLabel ( "TakeProfit_" 	+ i, shift7, vshift*(i+2) );
		GhostLabel ( "CurPrice_" 	+ i, shift8, vshift*(i+2) );
		GhostLabel ( "Swap_" 		+ i, shift9, vshift*(i+2) );
		GhostLabel ( "Profit_" 		+ i, shift10, vshift*(i+2) );
		GhostLabel ( "Comment_" 	+ i, shift11, vshift*(i+2) );
	}
    
}

void GhostTerminalDeInit()
{
//---- Assert Create label if it does not exist.
    if(!ObjectFind("Ticket_Head")<0)        { ObjectDelete("Ticket_Head"); }
    if(!ObjectFind("OpenTime_Head")<0)      { ObjectDelete("OpenTime_Head"); }
    if(!ObjectFind("Type_Head")<0)          { ObjectDelete("Type_Head"); }
    if(!ObjectFind("Lots_Head")<0)          { ObjectDelete("Lots_Head"); }
    if(!ObjectFind("OpenPrice_Head")<0)     { ObjectDelete("OpenPrice_Head"); }
    if(!ObjectFind("StopLoss_Head")<0)      { ObjectDelete("StopLoss_Head"); }
    if(!ObjectFind("TakeProfit_Head")<0)    { ObjectDelete("TakeProfit_Head"); }
    if(!ObjectFind("CurPrice_Head")<0)      { ObjectDelete("CurPrice_Head"); }
    if(!ObjectFind("Swap_Head")<0)          { ObjectDelete("Swap_Head"); }
    if(!ObjectFind("Profit_Head")<0)        { ObjectDelete("Profit_Head"); }
    if(!ObjectFind("Comment_Head")<0)       { ObjectDelete("Comment_Head"); }
    
	for(int i=0; i<GhostRows; i++)
	{
        if(!ObjectFind("Ticket_"    +i)<0)  { ObjectDelete("Ticket_"    +i); }
        if(!ObjectFind("OpenTime_"  +i)<0)  { ObjectDelete("OpenTime_"  +i); }
        if(!ObjectFind("Type_"      +i)<0)  { ObjectDelete("Type_"      +i); }
        if(!ObjectFind("Lots_"      +i)<0)  { ObjectDelete("Lots_"      +i); }
        if(!ObjectFind("OpenPrice_" +i)<0)  { ObjectDelete("OpenPrice_" +i); }
        if(!ObjectFind("StopLoss_"  +i)<0)  { ObjectDelete("StopLoss_"  +i); }
        if(!ObjectFind("TakeProfit_"+i)<0)  { ObjectDelete("TakeProfit_"+i); }
        if(!ObjectFind("CurPrice_"  +i)<0)  { ObjectDelete("CurPrice_"  +i); }
        if(!ObjectFind("Swap_"      +i)<0)  { ObjectDelete("Swap_"      +i); }
        if(!ObjectFind("Profit_"    +i)<0)  { ObjectDelete("Profit_"    +i); }
        if(!ObjectFind("Comment_"   +i)<0)  { ObjectDelete("Comment_"   +i); }
	}
}

void GhostSummaryDisplay(int i, double balance, double equity, double margin, double free)
{

	string tmp_margin = StringConcatenate("Margin: ",DoubleToStr(margin,2));
	string tmp_marginLevel = "";
	if(margin>0)
	{
		tmp_marginLevel = StringConcatenate("  MarginLevel: ",DoubleToStr(equity/margin*100,2),"%");
	}
	GhostSetText( "Ticket_" 	+ i, StringConcatenate("Balance: ",DoubleToStr(balance,2),"  Equity: ",DoubleToStr(equity,2)),GhostMainColor);
	GhostSetText( "OpenTime_" 	+ i );
	GhostSetText( "Type_" 		+ i );
	GhostSetText( "Lots_" 		+ i, StringConcatenate(tmp_margin,"  FreeMargin: ",DoubleToStr(free,2),tmp_marginLevel),GhostMainColor);
	GhostSetText( "OpenPrice_" 	+ i );
	GhostSetText( "StopLoss_" 	+ i );
	GhostSetText( "TakeProfit_" + i );
	GhostSetText( "CurPrice_" 	+ i );
	GhostSetText( "Swap_" 		+ i );
	GhostSetText( "Profit_" 	+ i, DoubleToStr(GhostSummProfit,2),GhostMainColor);
	GhostSetText( "Comment_" 	+ i );
}

void GhostLabel(string labelName, int xDist, int yDist, int labelCorner=0)
{
    int lastErr;
    
//---- Assert Create label if it does not exist.
    if(!ObjectCreate(labelName,OBJ_LABEL,GhostWin,0,0))
    {
        lastErr=GetLastError();
        if(lastErr!=4200)
        {
            Print("ObjectCreate(\"",labelName,"\",OBJ_LABEL,0,0,0) - Error #",lastErr);
            return(-1);
        }
    }
    
//---- Set values if label exists.
    if(!ObjectSet(labelName,OBJPROP_CORNER,labelCorner))
    {
        lastErr=GetLastError();
        Print("ObjectSet(\"",labelName,"\",OBJPROP_CORNER,",labelCorner,") - Error #",lastErr);
    }
    if(!ObjectSet(labelName,OBJPROP_XDISTANCE,xDist))
    {
        lastErr=GetLastError();
        Print("ObjectSet(\"",labelName,"\",OBJPROP_XDISTANCE,",xDist,") - Error #",lastErr);
    }
    if(!ObjectSet(labelName,OBJPROP_YDISTANCE,yDist))
    {
        lastErr=GetLastError();
        Print("ObjectSet(\"",labelName,"\",OBJPROP_YDISTANCE,",yDist,") - Error #",lastErr);
    }
    if(!ObjectSetText(labelName,"",GhostFontSize))
    {
        lastErr=GetLastError();
        Print("ObjectSetText(\"",labelName,"\",\"\",",GhostFontSize,") - Error #",lastErr);
    }
}

void GhostSetText(string labelName, string labelText="", color labelColor=Black)
{
//---- Set text, fontsize, fonttype, fontcolor if label exists.
    if(!ObjectSetText(labelName,labelText,GhostFontSize,GhostFontType,labelColor))
    {
        int lastErr=GetLastError();
        Print("ObjectSetText(\"",labelName,"\",\"",labelText,"\",",GhostFontSize,"\"",GhostFontType,"\",",labelColor,") - Error #",lastErr);
    }
}

string OrderTypeToStr(int orderType)
{
    switch(orderType)
    {
        case OP_BUY:        return("Buy");
        case OP_SELL:       return("Sell");
        case OP_BUYLIMIT:   return("BuyLimit");
        case OP_BUYSTOP:    return("BuyStop");
        case OP_SELLLIMIT:  return("SellLimit");
        case OP_SELLSTOP:   return("SellStop");
        default:            return("UnknownOrderType");
    }
}

//|-----------------------------------------------------------------------------------------|
//|                             T E R M I N A L   B U F F E R S                             |
//|-----------------------------------------------------------------------------------------|
void GhostReorderBuffers()
{
	string tmp[11];

	for ( int i = GhostCurOpenPositions - 1; i >= 0; i-- )
	{
		for ( int j = GhostCurOpenPositions - 1; j >= 0; j-- )
		{
			if ( StrToInteger( GhostOpenPositions[i][0] ) > StrToInteger( GhostOpenPositions[j][0] ) )
			{
				for ( int n = 0; n < 11; n ++ ) { tmp[n] = GhostOpenPositions[i][n]; }
				for ( n = 0; n < 11; n ++ ) { GhostOpenPositions[i][n] = GhostOpenPositions[j][n]; }
				for ( n = 0; n < 11; n ++ ) { GhostOpenPositions[j][n] = tmp[n]; }
			}
		}
	}
	for ( i = GhostCurPendingOrders - 1; i >= 0; i-- )
	{
		for ( j = GhostCurPendingOrders - 1; j >= 0; j-- )
		{
			if ( StrToInteger( GhostPendingOrders[i][0] ) > StrToInteger( GhostPendingOrders[j][0] ) )
			{
				for ( n = 0; n < 11; n ++ ) { tmp[n] = GhostPendingOrders[i][n]; }
				for ( n = 0; n < 11; n ++ ) { GhostPendingOrders[i][n] = GhostPendingOrders[j][n]; }
				for ( n = 0; n < 11; n ++ ) { GhostPendingOrders[j][n] = tmp[n]; }
			}
		}
	}
}

//|-----------------------------------------------------------------------------------------|
//|                       E N D   O F   E X P E R T   A D V I S O R                         |
//|-----------------------------------------------------------------------------------------|
