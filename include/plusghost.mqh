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
//|-----------------------------------------------------------------------------------------|
#property   copyright "Copyright © 2012, Dennis Lee"
//#include    <sqlite.mqh>

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
//|                 P L U S L I N E X   E X T E R N A L   V A R I A B L E S                 |
//|-----------------------------------------------------------------------------------------|
extern   string GhostTerminal           = "GhostTerminal";
extern   string g1                      = "Mode: 0-Broker; 1-Excel; 2-SQL";
extern   int    GhostMode               = 0;
extern   int    GhostRows               = 10;
extern   int	GhostPipLimit			= 10;
extern   bool   GhostTradeHistory       = false;
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
extern   int    GhostDebug              = 1;

//|-----------------------------------------------------------------------------------------|
//|                           I N T E R N A L   V A R I A B L E S                           |
//|-----------------------------------------------------------------------------------------|
string   GhostName="PlusGhost";
string   GhostVer="1.50";
string   GhostExpertName="";

//---- Assert internal variables for GhostTerminal
string   GhostFontType="Arial";
int      GhostFontSize=8;
int      GhostWin=-1;
string   GhostOpenPositions[1][11];
string   GhostPendingOrders[1][11];
int      GhostCurOpenPositions=0;
int      GhostCurPendingOrders=0;
double   GhostSummProfit=0.0;

//---- Assert internal variables for ExcelLink
string   ExcelFileName;
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
int      OpMagicNo      = 11;
int      OpAccountNo    = 12;
int      OpSymbol       = 13;
int      OpComment      = 14;
int      OpExpertName   = 15;
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
int      PoCloseTime    = 10;
int      PoMagicNo      = 11;
int      PoAccountNo    = 12;
int      PoSymbol       = 13;
int      PoComment      = 14;
int      PoExpertName   = 15;
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
int      ThCloseTime    = 10;
int      ThMagicNo      = 11;
int      ThAccountNo    = 12;
int      ThSymbol       = 13;
int      ThComment      = 14;
int      ThExpertName   = 15;
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

//---- Assert internal variables for SQLite
string   GhostDb="ghost.db";
string   GhostTable="orders";


//|-----------------------------------------------------------------------------------------|
//|                             I N I T I A L I Z A T I O N                                 |
//|-----------------------------------------------------------------------------------------|
void GhostInit(string eaName)
{
    GhostTerminalInit();

//-- Assert Excel or SQL files are created.
    switch(GhostMode)
    {
        case 1:     if(!ExcelCreate(AccountNumber(),Symbol(),eaName)) { GhostMode=0; }
                    break;
        default:    break;
    }
    
    GhostExpertName=eaName;
/*
    if(GhostMaxAccountTrades>0)
    {
    //  Check if table exists - create
        if(!IsTableExists(GhostDb,GhostTable))
        {
        //--- Create table schema
            DbCreateTable(GhostDb,GhostTable);
            DbAlterTableInteger(GhostDb,GhostTable,"ticket");
            DbAlterTableDT(GhostDb,GhostTable,"opentime");
            DbAlterTableDT(GhostDb,GhostTable,"closetime");
        //--- Status: Enum OPENED, PENDING, CLOSED, CANCELLED
            DbAlterTableInteger(GhostDb,GhostTable,"status");
            DbAlterTableText(GhostDb,GhostTable,"symbol");
            DbAlterTableInteger(GhostDb,GhostTable,"type");
            DbAlterTableReal(GhostDb,GhostTable,"lots");
            DbAlterTableReal(GhostDb,GhostTable,"price");
            DbAlterTableReal(GhostDb,GhostTable,"slippage");
            DbAlterTableReal(GhostDb,GhostTable,"stoploss");
            DbAlterTableReal(GhostDb,GhostTable,"takeprofit");
            DbAlterTableText(GhostDb,GhostTable,"comment");
            DbAlterTableInteger(GhostDb,GhostTable,"magic");
            DbAlterTableDT(GhostDb,GhostTable,"expiration");
        //--- Net Profit Value without swaps or commissions
        //      For opened, it is the current unrealized profit
        //      For closed, it is the fixed profit
            DbAlterTableReal(GhostDb,GhostTable,"profit");
            DbAlterTableReal(GhostDb,GhostTable,"swap");
            DbAlterTableReal(GhostDb,GhostTable,"commission");
        }
    
    //  Check if table created successfully
        if(!IsTableExists(GhostDb,GhostTable))
        {
            Print("Creation of database and table failed. Ghost trading has been disabled.");
            GhostMaxAccountTrades=0;
        }
        else if(GhostDebug>=1)
            Print("Database "+GhostDb+" and table "+GhostTable+" created.");
    }
*/
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
        default:    BrokerLoadBuffers();    
                    break;
    }

//-- Assert GhostTerminal exists.
    if(GhostWin<0) return(-1);
    
//--- Assert refresh terminal window.
    GhostTerminalRefresh(Pts);
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
        default:    break;
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
        case 2:
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
        case 2:
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
        case 2:
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
        case 2:
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
        case 2:
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
        case 2:
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
        case 2:
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
        case 2:
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
        case 2:
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
        case 2:
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
        case 2:
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
        case 2:
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
        case 2:
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
        case 2:
        default:    return(OrderProfit());
    }
    return(0.0);
}

bool GhostOrderSelect(int index,int select, int pool=MODE_TRADES)
{
    bool ret;
    
    switch(GhostMode)
    {
        case 1:     ret=ExcelOrderSelect(index,select,pool);
                    return(ret);
        case 2:
        default:    return(OrderSelect(index,select,pool));
    }
    return(false);
}

double GhostOrderStopLoss()
{
    double ret;
    
    switch(GhostMode)
    {
        case 1:     ret=ExcelOrderStopLoss();
                    return(ret);
        case 2:
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
        case 2:
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
        case 2:
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
        case 2:
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
        case 2:
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
        case 2:
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
        case 2:
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
        case 2:
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
        case 2:
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
        case 2:
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
        case 2:
        default:    return(AccountMargin());
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
        case 2:
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
        case 2:
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
   if (GhostMode==0)
      strtmp=strtmp+"\n    No Ghost Trading.";
   else 
   {
      if (total<=0)
         strtmp=strtmp+"\n    No Active Ghost Trades.";
      else
         strtmp=strtmp+"\n    Ghost Trades="+total;
      if (GhostTradeHistory==false)
         strtmp=strtmp+"\n    No Trade History.";
      else
         strtmp=strtmp+"\n    Keep Trade History.";
   }
                         
   strtmp=strtmp+"\n";
   return(strtmp);
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
               case 2:
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
         calcProfitPip  = (closePrice-openPrice)/Pts;
      }
		else if ( ExcelGetValue(OpSheet,r,OpType) == OP_SELL )
		{ 
         closePrice = MarketInfo( ExcelGetString(OpSheet,r,OpSymbol), MODE_ASK ); 
      //--- Assert calculate profits      
         calcProfit     = (openPrice-closePrice)*lots*TurtleBigValue(Symbol())/pts;
         calcProfitPip  = (openPrice-closePrice)/Pts;
      }
      GhostOpenPositions[GhostCurOpenPositions][TwCurPrice]   = DoubleToStr( closePrice, digits ); 
		GhostOpenPositions[GhostCurOpenPositions][TwSwap]       = DoubleToStr( ExcelGetValue(OpSheet,r,OpSwap), 2 );
		GhostOpenPositions[GhostCurOpenPositions][TwProfit]     = DoubleToStr( calcProfit, 2 );
		GhostOpenPositions[GhostCurOpenPositions][TwComment]    = ExcelGetString(OpSheet,r,OpComment);
        
    //--- Assert record statistics for SINGLE trade
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

void BrokerLoadBuffers()
{
	int lastErr, ordersTotal = OrdersTotal(), digits;

    GhostCurOpenPositions=0; GhostCurPendingOrders=0;
	for ( int z = ordersTotal - 1; z >= 0; z -- )
	{
		if ( !OrderSelect( z, SELECT_BY_POS, MODE_TRADES ) )
		{
			lastErr = GetLastError();
			Print( "OrderSelect( ", z, ", SELECT_BY_POS, MODE_TRADES ) - Error #", lastErr );
			continue;
		}

		digits = MarketInfo( OrderSymbol(), MODE_DIGITS );

		if ( OrderType() < 2 )
		{
			GhostOpenPositions[GhostCurOpenPositions][TwTicket]     = OrderTicket();
			GhostOpenPositions[GhostCurOpenPositions][TwOpenTime]   = TimeToStr( OrderOpenTime() );
			GhostOpenPositions[GhostCurOpenPositions][TwType]       = OrderTypeToStr( OrderType() );
			GhostOpenPositions[GhostCurOpenPositions][TwLots]       = DoubleToStr( OrderLots(), 1 );
			GhostOpenPositions[GhostCurOpenPositions][TwOpenPrice]  = DoubleToStr( OrderOpenPrice(), digits );
			GhostOpenPositions[GhostCurOpenPositions][TwStopLoss]   = DoubleToStr( OrderStopLoss(), digits );
			GhostOpenPositions[GhostCurOpenPositions][TwTakeProfit] = DoubleToStr( OrderTakeProfit(), digits );

			if ( OrderType() == OP_BUY )
			{ GhostOpenPositions[GhostCurOpenPositions][TwCurPrice] = DoubleToStr( MarketInfo( OrderSymbol(), MODE_BID ), digits ); }
			else
			{ GhostOpenPositions[GhostCurOpenPositions][TwCurPrice] = DoubleToStr( MarketInfo( OrderSymbol(), MODE_ASK ), digits ); }

			GhostOpenPositions[GhostCurOpenPositions][TwSwap]       = DoubleToStr( OrderSwap(), 2 );
			GhostOpenPositions[GhostCurOpenPositions][TwProfit]     = DoubleToStr( OrderProfit(), 2 );
			GhostOpenPositions[GhostCurOpenPositions][TwComment]    = OrderComment();

			GhostSummProfit += OrderProfit();
			GhostCurOpenPositions ++;
			if ( GhostCurOpenPositions >= GhostRows ) { break; }
		}
		else
		{
			GhostPendingOrders[GhostCurPendingOrders][TwTicket]     = OrderTicket();
			GhostPendingOrders[GhostCurPendingOrders][TwOpenTime]   = TimeToStr( OrderOpenTime() );
			GhostPendingOrders[GhostCurPendingOrders][TwType]       = OrderTypeToStr( OrderType() );
			GhostPendingOrders[GhostCurPendingOrders][TwLots]       = DoubleToStr( OrderLots(), 1 );
			GhostPendingOrders[GhostCurPendingOrders][TwOpenPrice]  = DoubleToStr( OrderOpenPrice(), digits );
			GhostPendingOrders[GhostCurPendingOrders][TwStopLoss]   = DoubleToStr( OrderStopLoss(), digits );
			GhostPendingOrders[GhostCurPendingOrders][TwTakeProfit] = DoubleToStr( OrderTakeProfit(), digits );

			if ( OrderType() == OP_SELLSTOP || OrderType() == OP_SELLLIMIT )
			{ GhostPendingOrders[GhostCurPendingOrders][TwCurPrice] = DoubleToStr( MarketInfo( OrderSymbol(), MODE_BID ), digits ); }
			else
			{ GhostPendingOrders[GhostCurPendingOrders][TwCurPrice] = DoubleToStr( MarketInfo( OrderSymbol(), MODE_ASK ), digits ); }

			GhostPendingOrders[GhostCurPendingOrders][TwSwap]       = DoubleToStr( OrderSwap(), 2 );
			GhostPendingOrders[GhostCurPendingOrders][TwProfit]     = DoubleToStr( OrderProfit(), 2 );
			GhostPendingOrders[GhostCurPendingOrders][TwComment]    = OrderComment();

			GhostCurPendingOrders ++;
			if ( GhostCurOpenPositions + GhostCurPendingOrders >= GhostRows ) { break; }
		}
	}
    GhostReorderBuffers();
}

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
//|                             E X C E L   F U N C T I O N S                               |
//|-----------------------------------------------------------------------------------------|
bool ExcelCreate(int acctNo, string symbol, string eaName)
{
    int handle;
    bool init;
    
//--- Assert Check if file exists, e.g. "Acc440660-EURUSD-Growthbot.xls"
    ExcelFileName=StringConcatenate("AccNo",acctNo,"-",symbol,"-",eaName,".xls");
    
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

void ExcelManager()
{
    int r, histRow, type;
    double closePrice;
    double calcProfit, openPrice;
    double openSL, openTP;
    string sym;

//--- Assert for each Open Position, check if SL or TP reached.
//--- First row is header
    r=OpFirstRow;
    while (ExcelGetValue(OpSheet,r,OpTicket)>0)
    {
        type = ExcelGetValue(OpSheet,r,OpType);
        sym  = ExcelGetString(OpSheet,r,OpSymbol);
    //--- Assert get real-time info.
        openPrice=ExcelGetValue(OpSheet,r,OpOpenPrice);
        openSL=ExcelGetValue(OpSheet,r,OpStopLoss);
        openTP=ExcelGetValue(OpSheet,r,OpTakeProfit);
        if(type==OP_BUY)
        {
            closePrice = MarketInfo( sym, MODE_BID ); 
            if( (openSL!=0.0 && closePrice<=openSL) ||
                (openTP!=0.0 && closePrice>=openTP) )
            {
            //--- Assert calculate profit/loss
                calcProfit=(closePrice-openPrice)*TurtleBigValue(sym)/Pts;
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
                calcProfit=(openPrice-closePrice)*TurtleBigValue(sym)/Pts;
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
        if(GhostTradeHistory)
        {
            histRow=ExcelCopyRow(OpSheet,OpTicket,OpFirstRow,r,ThSheet,ThTicket,ThFirstRow);
            if(histRow>0)
            {
            //--- Adjust trade history values.
               ExcelPutValue(ThSheet,histRow,ThClosePrice,  closePrice);
               ExcelPutValue(ThSheet,histRow,ThCloseTime,   TimeCurrent());
            }
        }
        
        if(r>=OpFirstRow) { ExcelDeleteRow(OpSheet,OpTicket,OpFirstRow,r); GhostCurOpenPositions --; }

    //--- Debug    
        if(GhostDebug>=1)   Print(GhostDebug,":ExcelManager(): r=",r,";openPrice=",NormalizeDouble(openPrice,5),";closePrice=",NormalizeDouble(closePrice,5),";openSL=",NormalizeDouble(openSL,5),";openTP=",NormalizeDouble(openTP,5),";calcProfit=",calcProfit);
    }
}

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
            if(type==OP_BUY)
            {
               curPrice = MarketInfo( sym, MODE_ASK ); 
               if(SL!=0.0) modifySL=NormalizeDouble(curPrice-SL*Pts,Digits);
               if(TP!=0.0) modifyTP=NormalizeDouble(curPrice+TP*Pts,Digits);
            }
            else if(type==OP_SELL)
            {
               curPrice = MarketInfo( sym, MODE_BID ); 
               if(SL!=0.0) modifySL=NormalizeDouble(curPrice+SL*Pts,Digits);
               if(TP!=0.0) modifyTP=NormalizeDouble(curPrice-TP*Pts,Digits);
            }
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
            if(SL!=0.0) modifySL=NormalizeDouble(modifyPrice-SL*Pts,Digits);
            if(TP!=0.0) modifyTP=NormalizeDouble(modifyPrice+TP*Pts,Digits);
        }
        else if(OP_SELL==ExcelGetValue(PoSheet,r,PoType))
        {
            if(price==0.0)
            {   modifyPrice=ExcelGetValue(PoSheet,r,PoOpenPrice); }
            else
            {   modifyPrice=price; }
            if(SL!=0.0) modifySL=NormalizeDouble(modifyPrice+SL*Pts,Digits);
            if(TP!=0.0) modifyTP=NormalizeDouble(modifyPrice-TP*Pts,Digits);
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
    if(GhostDebug>=1)   Print(GhostDebug,":ExcelOrderModify(",ticket,",",price,",",SL,",",TP,",",exp,",",arrow,"): return=false");
    return(false);
}

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
        if(GhostDebug>=1)   Print(GhostDebug,":ExcelOrderClose(",ticket,",",lots,",",price,",",slippage,",",arrow,"): return=false");
        return(false);        
    }
//--- Exclude ALL pending orders
   if ( ExcelGetValue(OpSheet,r,OpType) > OP_SELL ) 
   { 
    //--- Debug    
        if(GhostDebug>=1)   Print(GhostDebug,":ExcelOrderClose(",ticket,",",lots,",",price,",",slippage,",",arrow,"): return=false");
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
      if(GhostTradeHistory)
      {
         histRow=ExcelCopyRow(OpSheet,OpTicket,OpFirstRow,r,ThSheet,ThTicket,ThFirstRow);
         if(histRow>0)  
         {
         //--- Adjust trade history values.
            ExcelPutValue(ThSheet,histRow,ThLots,        calcLots);
            ExcelPutValue(ThSheet,histRow,ThClosePrice,  closePrice);
            ExcelPutValue(ThSheet,histRow,ThCloseTime,   TimeCurrent());
         }
      }
    }
    else
    { 
    //--- Assert copy row to Trade History
      if(GhostTradeHistory)   
      {
         histRow=ExcelCopyRow(OpSheet,OpTicket,OpFirstRow,r,ThSheet,ThTicket,ThFirstRow);
         if(histRow>0)
         {
         //--- Adjust trade history values.
            ExcelPutValue(ThSheet,histRow,ThClosePrice,  closePrice);
            ExcelPutValue(ThSheet,histRow,ThCloseTime,   TimeCurrent());
         }
      }

      if(r>=OpFirstRow) { ExcelDeleteRow(OpSheet,OpTicket,OpFirstRow,r); GhostCurOpenPositions --; }
    }
    
//--- Debug    
    if(GhostDebug>=1)   Print(GhostDebug,":ExcelOrderClose(",ticket,",",lots,",",price,",",slippage,",",arrow,"): return=true");
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
    if(0==rowFound) 
    {
    //--- Debug    
        if(GhostDebug>=2)   Print(GhostDebug,":ExcelFindTicket(",sheet,",",keyCol,",",firstRow,",",ticket,"): return=-1");
        return(-1);
    }
    else 
    {
    //--- Debug    
        if(GhostDebug>=2)   Print(GhostDebug,":ExcelFindTicket(",sheet,",",keyCol,",",firstRow,",",ticket,"): return=",rowFound);
        return(rowFound);
    }
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
        if(GhostDebug>=2)   Print(GhostDebug,":ExcelOrderSelect(",index,",",select,",",pool,"): row=",ExcelSelectRow,";return=",ret);

        return(ExcelSelectRow>0);
    }
//--- Assert SELECT_BY_POS where index=0 is FirstRow.
    else
    {
        if(pool==MODE_TRADES)
        {
        //--- Find total orders
            ExcelSelectRow=index+OpFirstRow;
        //--- Assert OrdersTotal>0
            if(ExcelOrdersTotal()>0)
            {
            //--- Assert index is within range
                if(index>=0 && index<ExcelOrdersTotal()) ret=true;
            }
            
        //--- Debug    
            if(GhostDebug>=2)   Print(GhostDebug,":ExcelOrderSelect(",index,",",select,",",pool,"): total=",ExcelOrdersTotal(),";return=",ret);

            return(ret);
        }
        else if(pool==MODE_HISTORY)
        {
        //--- Find total history
            ExcelSelectRow=index+ThFirstRow;
        //--- Assert OrdersHistoryTotal>0
            if(ExcelOrdersHistoryTotal()>0)
            {
            //--- Assert index is within range
                if(index>=0 && index<ExcelOrdersHistoryTotal()) ret=true;
            }

        //--- Debug    
            if(GhostDebug>=2)   Print(GhostDebug,":ExcelOrderSelect(",index,",",select,",",pool,"): historyTotal=",ExcelOrdersHistoryTotal(),";return=false");

            return(false);
        }
    }
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
        case MODE_HISTORY:
        //--- Assert get lots, open and close prices
            lots        = ExcelGetValue(ThSheet,ExcelSelectRow,   ThLots);
            openPrice   = ExcelGetValue(ThSheet,ExcelSelectRow,   ThOpenPrice);
            closePrice  = ExcelGetValue(ThSheet,ExcelSelectRow,   ThClosePrice);
        //--- Assert calculate profits
            sym         = ExcelGetString(ThSheet,ExcelSelectRow,  ThSymbol);
            pts = MarketInfo( sym, MODE_POINT );
            if ( ExcelGetValue(ThSheet,ExcelSelectRow,ThType) == OP_BUY )
            { 
               calcProfit = (closePrice-openPrice)*lots*TurtleBigValue(sym)/pts;
            }
            else if (ExcelGetValue(ThSheet,ExcelSelectRow,ThType) == OP_SELL )
            { 
               calcProfit = (openPrice-closePrice)*lots*TurtleBigValue(sym)/pts;
            }
            return(calcProfit);
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

double ExcelAccountProfit()
{
    return(ExcelGetValue(AdSheet,AdFirstRow,AdProfit));
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
    if(GhostDebug>=2)   Print(GhostDebug,":ExcelCreateRow(",sheet,",",keyCol,",",firstRow,"): return=",r);

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
    if(GhostDebug>=2)   Print(GhostDebug,":ExcelCreateTicket(): return=",ExcelNextTicket);
    return(ExcelNextTicket);
}

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
   ExcelPutString(destSheet,destCopyRow,11,  ExcelGetString(sheet,copyRow,11));
   ExcelPutString(destSheet,destCopyRow,12,  ExcelGetString(sheet,copyRow,12));
   ExcelPutString(destSheet,destCopyRow,13,  ExcelGetString(sheet,copyRow,13));
   ExcelPutString(destSheet,destCopyRow,14,  ExcelGetString(sheet,copyRow,14));
   ExcelPutString(destSheet,destCopyRow,15,  ExcelGetString(sheet,copyRow,15));

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
        ExcelPutString(sheet,r-1,11,    ExcelGetString(sheet,r,11));
        ExcelPutString(sheet,r-1,12,    ExcelGetString(sheet,r,12));
        ExcelPutString(sheet,r-1,13,    ExcelGetString(sheet,r,13));
        ExcelPutString(sheet,r-1,14,    ExcelGetString(sheet,r,14));
        ExcelPutString(sheet,r-1,15,    ExcelGetString(sheet,r,15));
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
    ExcelPutString(sheet,lastRow,11,  "");
    ExcelPutString(sheet,lastRow,12,  "");
    ExcelPutString(sheet,lastRow,13,  "");
    ExcelPutString(sheet,lastRow,14,  "");
    ExcelPutString(sheet,lastRow,15,  "");
}

//|-----------------------------------------------------------------------------------------|
//|                                S C H E M A   S T A T U S                                |
//|-----------------------------------------------------------------------------------------|
/*
bool IsTableExists(string db, string table)
{
    int err=sqlite_table_exists(db,table);
    if(err<0)
    {
        Print("Check for table "+table+" existence. Error Code: "+err);
        return(false);
    }
    return(err>0);
}

void DbCreateTable(string db, string table)
{
    string exp="CREATE TABLE "+table+" (id INTEGER PRIMARY KEY ASC)";
    DbExec(db,exp);
}

void DbAlterTableText(string db, string table, string field)
{
    string exp="ALTER TABLE "+table+" ADD COLUMN "+field+" TEXT NOT NULL DEFAULT ''";
    DbExec(db,exp);
}

void DbAlterTableInteger(string db, string table, string field)
{
    string exp="ALTER TABLE "+table+" ADD COLUMN "+field+" INTEGER NOT NULL DEFAULT '0'";
    DbExec(db,exp);
}

void DbAlterTableReal(string db, string table, string field)
{
    string exp="ALTER TABLE "+table+" ADD COLUMN "+field+" REAL NOT NULL DEFAULT '0.0'";
    DbExec(db,exp);
}

void DbAlterTableDT(string db, string table, string field)
{
//--- DT can be stored as TEXT, REAL or INTEGER
    string exp="ALTER TABLE "+table+" ADD COLUMN "+field+" INTEGER NOT NULL DEFAULT '0'";
    DbExec(db,exp);
}

void DbExec(string db, string exp)
{
    int err=sqlite_exec(db,exp);
    if (err!=0)
        Print("Check expression '"+exp+"'. Error Code: "+err);
}
*/
//|-----------------------------------------------------------------------------------------|
//|                       E N D   O F   E X P E R T   A D V I S O R                         |
//|-----------------------------------------------------------------------------------------|

