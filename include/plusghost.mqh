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
//|-----------------------------------------------------------------------------------------|
#property   copyright "Copyright © 2012, Dennis Lee"
#include    <sqlite.mqh>

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
string   GhostVer="1.22";
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
//---- Excel sheet positions
int      AdSheet    = 1;
int      OpSheet    = 2;
int      PoSheet    = 3;
//---- Excel first row for each sheet
int      AdFirstRow = 2;
int      OpFirstRow = 2;
int      PoFirstRow = 2;
//---- Excel column positions for Account Details
int      AdAccountNo    = 1;
int      AdCurrency     = 2;
int      AdBalance      = 3;
int      AdEquity       = 4;
int      AdMargin       = 5;
int      AdProfit       = 6;
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

double GhostOrderProfit()
{
    double ret;
    
    switch(GhostMode)
    {
        case 1:     ret=0.0;                //ExcelOrderProfit() to be implemented
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
    return(0);
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
   else if (total<=0)
      strtmp=strtmp+"\n    No Active Ghost Trades.";
   else
      strtmp=strtmp+"\n    Ghost Trades="+total;
                         
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
               case 1:     GhostSummaryDisplay(i,ExcelGetValue(AdSheet,AdFirstRow,AdBalance),ExcelGetValue(AdSheet,AdFirstRow,AdEquity),ExcelAccountMargin(),0.0);
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

    GhostCurOpenPositions=0; GhostCurPendingOrders=0;

//--- Assert Load OpenPositions
//--- First row is header
    r=OpFirstRow;
    while (ExcelGetValue(OpSheet,r,OpTicket)>0)
    {
		digits = MarketInfo( ExcelGetString(OpSheet,r,OpSymbol), MODE_DIGITS );

        GhostOpenPositions[GhostCurOpenPositions][0] = DoubleToStr( ExcelGetValue(OpSheet,r,OpTicket), 0 );
		GhostOpenPositions[GhostCurOpenPositions][1] = TimeToStr( ExcelGetValue(OpSheet,r,OpOpenTime) );
		GhostOpenPositions[GhostCurOpenPositions][2] = OrderTypeToStr( ExcelGetValue(OpSheet,r,OpType) );
		GhostOpenPositions[GhostCurOpenPositions][3] = DoubleToStr( ExcelGetValue(OpSheet,r,OpLots), 1 );
		GhostOpenPositions[GhostCurOpenPositions][4] = DoubleToStr( ExcelGetValue(OpSheet,r,OpOpenPrice), digits );
		GhostOpenPositions[GhostCurOpenPositions][5] = DoubleToStr( ExcelGetValue(OpSheet,r,OpStopLoss), digits );
		GhostOpenPositions[GhostCurOpenPositions][6] = DoubleToStr( ExcelGetValue(OpSheet,r,OpTakeProfit), digits );
        
        if ( ExcelGetValue(OpSheet,r,OpType) == OP_BUY )
        { GhostOpenPositions[GhostCurOpenPositions][7] = DoubleToStr( MarketInfo( ExcelGetString(OpSheet,r,OpSymbol), MODE_BID ), digits ); }
		else
		{ GhostOpenPositions[GhostCurOpenPositions][7] = DoubleToStr( MarketInfo( ExcelGetString(OpSheet,r,OpSymbol), MODE_ASK ), digits ); }

		GhostOpenPositions[GhostCurOpenPositions][8] = DoubleToStr( ExcelGetValue(OpSheet,r,OpSwap), 2 );
		GhostOpenPositions[GhostCurOpenPositions][9] = DoubleToStr( ExcelGetValue(OpSheet,r,OpProfit), 2 );
		GhostOpenPositions[GhostCurOpenPositions][10] = ExcelGetString(OpSheet,r,OpComment);

    //---- Increment row
        GhostSummProfit += ExcelGetValue(OpSheet,r,OpProfit);
        GhostCurOpenPositions ++;
        r ++;
        if ( GhostCurOpenPositions >= GhostRows ) { break; }
    }

//--- Assert Load PendingOrders
//--- First row is header
    r=PoFirstRow;
    while (ExcelGetValue(PoSheet,r,PoTicket)>0)
    {
		digits = MarketInfo( ExcelGetString(PoSheet,r,PoSymbol), MODE_DIGITS );

		GhostPendingOrders[GhostCurPendingOrders][0] = DoubleToStr( ExcelGetValue(PoSheet,r,PoTicket), 0 );
		GhostPendingOrders[GhostCurPendingOrders][1] = TimeToStr( ExcelGetValue(PoSheet,r,PoOpenTime) );
		GhostPendingOrders[GhostCurPendingOrders][2] = OrderTypeToStr( ExcelGetValue(PoSheet,r,PoType) );
		GhostPendingOrders[GhostCurPendingOrders][3] = DoubleToStr( ExcelGetValue(PoSheet,r,PoLots), 1 );
		GhostPendingOrders[GhostCurPendingOrders][4] = DoubleToStr( ExcelGetValue(PoSheet,r,PoOpenPrice), digits );
		GhostPendingOrders[GhostCurPendingOrders][5] = DoubleToStr( ExcelGetValue(PoSheet,r,PoStopLoss), digits );
		GhostPendingOrders[GhostCurPendingOrders][6] = DoubleToStr( ExcelGetValue(PoSheet,r,PoTakeProfit), digits );

		if ( ExcelGetValue(PoSheet,r,PoType) == OP_SELLSTOP || ExcelGetValue(PoSheet,r,PoType) == OP_SELLLIMIT )
		{ GhostPendingOrders[GhostCurPendingOrders][7] = DoubleToStr( MarketInfo( ExcelGetString(PoSheet,r,PoSymbol), MODE_BID ), digits ); }
		else
		{ GhostPendingOrders[GhostCurPendingOrders][7] = DoubleToStr( MarketInfo( ExcelGetString(PoSheet,r,PoSymbol), MODE_ASK ), digits ); }

		GhostPendingOrders[GhostCurPendingOrders][8] = DoubleToStr( ExcelGetValue(PoSheet,r,PoSwap), 2 );
		GhostPendingOrders[GhostCurPendingOrders][9] = DoubleToStr( 0, 2 );
		GhostPendingOrders[GhostCurPendingOrders][10] = ExcelGetString(PoSheet,r,PoComment);

    //---- Increment row
        GhostCurPendingOrders ++;
        r ++;
        if ( GhostCurOpenPositions + GhostCurPendingOrders >= GhostRows ) { break; }
	}

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
			GhostOpenPositions[GhostCurOpenPositions][0] = OrderTicket();
			GhostOpenPositions[GhostCurOpenPositions][1] = TimeToStr( OrderOpenTime() );
			GhostOpenPositions[GhostCurOpenPositions][2] = OrderTypeToStr( OrderType() );
			GhostOpenPositions[GhostCurOpenPositions][3] = DoubleToStr( OrderLots(), 1 );
			GhostOpenPositions[GhostCurOpenPositions][4] = DoubleToStr( OrderOpenPrice(), digits );
			GhostOpenPositions[GhostCurOpenPositions][5] = DoubleToStr( OrderStopLoss(), digits );
			GhostOpenPositions[GhostCurOpenPositions][6] = DoubleToStr( OrderTakeProfit(), digits );

			if ( OrderType() == OP_BUY )
			{ GhostOpenPositions[GhostCurOpenPositions][7] = DoubleToStr( MarketInfo( OrderSymbol(), MODE_BID ), digits ); }
			else
			{ GhostOpenPositions[GhostCurOpenPositions][7] = DoubleToStr( MarketInfo( OrderSymbol(), MODE_ASK ), digits ); }

			GhostOpenPositions[GhostCurOpenPositions][8] = DoubleToStr( OrderSwap(), 2 );
			GhostOpenPositions[GhostCurOpenPositions][9] = DoubleToStr( OrderProfit(), 2 );
			GhostOpenPositions[GhostCurOpenPositions][10] = OrderComment();

			GhostSummProfit += OrderProfit();
			GhostCurOpenPositions ++;
			if ( GhostCurOpenPositions >= GhostRows ) { break; }
		}
		else
		{
			GhostPendingOrders[GhostCurPendingOrders][0] = OrderTicket();
			GhostPendingOrders[GhostCurPendingOrders][1] = TimeToStr( OrderOpenTime() );
			GhostPendingOrders[GhostCurPendingOrders][2] = OrderTypeToStr( OrderType() );
			GhostPendingOrders[GhostCurPendingOrders][3] = DoubleToStr( OrderLots(), 1 );
			GhostPendingOrders[GhostCurPendingOrders][4] = DoubleToStr( OrderOpenPrice(), digits );
			GhostPendingOrders[GhostCurPendingOrders][5] = DoubleToStr( OrderStopLoss(), digits );
			GhostPendingOrders[GhostCurPendingOrders][6] = DoubleToStr( OrderTakeProfit(), digits );

			if ( OrderType() == OP_SELLSTOP || OrderType() == OP_SELLLIMIT )
			{ GhostPendingOrders[GhostCurPendingOrders][7] = DoubleToStr( MarketInfo( OrderSymbol(), MODE_BID ), digits ); }
			else
			{ GhostPendingOrders[GhostCurPendingOrders][7] = DoubleToStr( MarketInfo( OrderSymbol(), MODE_ASK ), digits ); }

			GhostPendingOrders[GhostCurPendingOrders][8] = DoubleToStr( OrderSwap(), 2 );
			GhostPendingOrders[GhostCurPendingOrders][9] = DoubleToStr( OrderProfit(), 2 );
			GhostPendingOrders[GhostCurPendingOrders][10] = OrderComment();

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
    if("AccountNo"!=ExcelGetString(AdSheet,1,AdAccountNo)) init=true;
    
    if(init)
    {
    //--- Assert rename worksheets to AccountDetails,OpenPositions,PendingOrders,TradeHistory
        ExcelSheetRename(AdSheet,"AccountDetails");
        ExcelSheetRename(OpSheet,"OpenPositions");
        ExcelSheetRename(PoSheet,"PendingOrders");
        
    //--- Assert add headers to AccountDetails: BrokerName, AccountNo, Currency, Balance, Equity, Margin, PL
        ExcelPutString(AdSheet, 1,  AdAccountNo,    "AccountNo");
        ExcelPutString(AdSheet, 1,  AdCurrency,     "Currency");
        ExcelPutString(AdSheet, 1,  AdBalance,      "Balance");
        ExcelPutString(AdSheet, 1,  AdEquity,       "Equity");
        ExcelPutString(AdSheet, 1,  AdMargin,       "Margin");
        ExcelPutString(AdSheet, 1,  AdProfit,       "Profit");
        
    //--- Assert add headers to OpenPositions: Ticket, OpenTime, Type, Lots, OpenPrice, StopLoss, TakeProfit, CurPrice, Profit, Comment, AccountNo, ExpertName, Symbol, MagicNo
        ExcelPutString(OpSheet, 1,  OpTicket,       "Ticket");
        ExcelPutString(OpSheet, 1,  OpOpenTime,     "OpenTime");
        ExcelPutString(OpSheet, 1,  OpType,         "Type");
        ExcelPutString(OpSheet, 1,  OpLots,         "Lots");
        ExcelPutString(OpSheet, 1,  OpOpenPrice,    "OpenPrice");
        ExcelPutString(OpSheet, 1,  OpStopLoss,     "StopLoss");
        ExcelPutString(OpSheet, 1,  OpTakeProfit,   "TakeProfit");
        ExcelPutString(OpSheet, 1,  OpCurPrice,     "CurPrice");
        ExcelPutString(OpSheet, 1,  OpSwap,         "Swap");
        ExcelPutString(OpSheet, 1,  OpProfit,       "Profit");
        ExcelPutString(OpSheet, 1,  OpMagicNo,      "MagicNo");
        ExcelPutString(OpSheet, 1,  OpAccountNo,    "AccountNo");
        ExcelPutString(OpSheet, 1,  OpSymbol,       "Symbol");
        ExcelPutString(OpSheet, 1,  OpComment,      "Comment");
        ExcelPutString(OpSheet, 1,  OpExpertName,   "ExpertName");
    
    //--- Assert add headers to Pending Orders: Ticket, OpenTime, Type, Lots, OpenPrice, StopLoss, TakeProfit, Comment, AccountNo, ExpertName, Symbol, MagicNo
        ExcelPutString(PoSheet, 1,  PoTicket,       "Ticket");
        ExcelPutString(PoSheet, 1,  PoOpenTime,     "OpenTime");
        ExcelPutString(PoSheet, 1,  PoType,         "Type");
        ExcelPutString(PoSheet, 1,  PoLots,         "Lots");
        ExcelPutString(PoSheet, 1,  PoOpenPrice,    "OpenPrice");
        ExcelPutString(PoSheet, 1,  PoStopLoss,     "StopLoss");
        ExcelPutString(PoSheet, 1,  PoTakeProfit,   "TakeProfit");
        ExcelPutString(PoSheet, 1,  PoClosePrice,   "ClosePrice");
        ExcelPutString(PoSheet, 1,  PoSwap,         "Swap");
        ExcelPutString(PoSheet, 1,  PoCloseTime,    "CloseTime");
        ExcelPutString(PoSheet, 1,  PoMagicNo,      "MagicNo");
        ExcelPutString(PoSheet, 1,  PoAccountNo,    "AccountNo");
        ExcelPutString(PoSheet, 1,  PoSymbol,       "Symbol");
        ExcelPutString(PoSheet, 1,  PoComment,      "Comment");
        ExcelPutString(PoSheet, 1,  PoExpertName,   "ExpertName");
        
    //--- Assert Populate AccountDetails: AccountNo, Currency, Balance, Equity, Margin, PL
        ExcelPutValue(AdSheet,  AdFirstRow,  AdAccountNo,    AccountNumber());
        ExcelPutString(AdSheet, AdFirstRow,  AdCurrency,     AccountCurrency());
        ExcelPutValue(AdSheet,  AdFirstRow,  AdBalance,      AccountBalance());
    }

    return(true);
}

void ExcelManager()
{
    int r;
    double closePrice;
    double calcProfit, openPrice;
    double openSL, openTP;

//--- Assert for each Open Position, check if SL or TP reached.
//--- First row is header
    r=OpFirstRow;
    while (ExcelGetValue(OpSheet,r,OpTicket)>0)
    {
    //--- Assert get real-time info.
        openPrice=ExcelGetValue(OpSheet,r,OpOpenPrice);
        openSL=ExcelGetValue(OpSheet,r,OpStopLoss);
        openTP=ExcelGetValue(OpSheet,r,OpTakeProfit);
        if(OP_BUY==ExcelGetValue(OpSheet,r,OpType))
        {
            closePrice = MarketInfo( Symbol(), MODE_BID ); 
            if( (openSL!=0.0 && closePrice<=openSL) ||
                (openTP!=0.0 && closePrice>=openTP) )
            {
            //--- Assert calculate profit/loss
                calcProfit=(closePrice-openPrice)*TurtleBigValue(Symbol())/Pts;
                break;
            }
                    
        }
        else if(OP_SELL==ExcelGetValue(OpSheet,r,OpType))
        {
            closePrice = MarketInfo( Symbol(), MODE_ASK ); 
            if( (openSL!=0.0 && closePrice>=openSL) ||
                (openTP!=0.0 && closePrice<=openTP) )
            {
            //--- Assert calculate profit/loss
                calcProfit=(openPrice-closePrice)*TurtleBigValue(Symbol())/Pts;
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
        if(r>=OpFirstRow) ExcelDeleteRow(OpSheet,OpTicket,OpFirstRow,r);

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
    double curPrice;
    double modifyPrice;
    double modifySL;
    double modifyTP;
    
//--- Assert ticket no exists in Open Positions.
    r=ExcelFindTicket(OpSheet,OpTicket,OpFirstRow,ticket);
    if(r>0)
    {
    //--- Assert get open position info.
        if(OP_BUY==ExcelGetValue(OpSheet,r,OpType))
        {
            curPrice = MarketInfo( ExcelGetString(OpSheet,r,OpSymbol), MODE_ASK ); 
            if(SL!=0.0) modifySL=NormalizeDouble(curPrice-SL*Pts,Digits);
            if(TP!=0.0) modifyTP=NormalizeDouble(curPrice+TP*Pts,Digits);
        }
        else if(OP_SELL==ExcelGetValue(OpSheet,r,OpType))
        {
            curPrice = MarketInfo( ExcelGetString(OpSheet,r,OpSymbol), MODE_BID ); 
            if(SL!=0.0) modifySL=NormalizeDouble(curPrice+SL*Pts,Digits);
            if(TP!=0.0) modifyTP=NormalizeDouble(curPrice-TP*Pts,Digits);
        }
        ExcelPutValue(OpSheet,r,OpStopLoss,     SL);
        ExcelPutValue(OpSheet,r,OpTakeProfit,   TP);
    //--- Debug    
        if(GhostDebug>=1)   Print(GhostDebug,":ExcelOrderModify(",ticket,",",price,",",SL,",",TP,",",exp,",",arrow,"): return=true");
        return(true);
    }

//--- Assert ticket no exists in Pending Orders.
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

//--- Assert ticket not found.
//--- Debug    
    if(GhostDebug>=1)   Print(GhostDebug,":ExcelOrderModify(",ticket,",",price,",",SL,",",TP,",",exp,",",arrow,"): return=false");
    return(false);
}

bool ExcelOrderClose(int ticket, double lots, double price, int slippage, color arrow=CLR_NONE)
{
    int r;
    double calcLots, closePrice, orderLots;
    double calcProfit, openPrice;

//--- Assert ticket no exists in Open Positions ONLY.
    r=ExcelFindTicket(OpSheet,OpTicket,OpFirstRow,ticket);
    if(r<=0) 
    {
    //--- Debug    
        if(GhostDebug>=1)   Print(GhostDebug,":ExcelOrderClose(",ticket,",",lots,",",price,",",slippage,",",arrow,"): return=false");
        return(false);        
    }

//--- Assert get close price and calculate profits
    openPrice = ExcelGetValue(OpSheet,r,OpOpenPrice);
    if ( ExcelGetValue(OpSheet,r,OpType) == OP_BUY )
    { 
      closePrice = MarketInfo( ExcelGetString(OpSheet,r,OpSymbol), MODE_BID ); 
      
   //--- Assert calculate profits      
      calcProfit = (closePrice-openPrice)*TurtleBigValue(Symbol())/Pts;
    }
    else
    { 
      closePrice = MarketInfo( ExcelGetString(OpSheet,r,OpSymbol), MODE_ASK ); 

   //--- Assert calculate profits      
      calcProfit = (openPrice-closePrice)*TurtleBigValue(Symbol())/Pts;
    }
    
//--- Assert check if partial close or full close.
    orderLots=ExcelGetValue(OpSheet,r,OpLots);
    if(lots>=orderLots)
    { calcLots = ExcelGetValue(OpSheet,r,OpLots); }
    else
    { calcLots = lots; }
    
//--- Assert adjustment to account details using BigValue.
    ExcelPutValue(AdSheet,AdFirstRow,AdBalance, ExcelGetValue(AdSheet,AdFirstRow,AdBalance)+calcProfit);

//--- Assert partial close to update Lots in row; otherwise delete entire row.
    if(calcLots<orderLots)
    { ExcelPutValue(OpSheet,r,OpLots,orderLots-calcLots); }
    else
    { if(r>=OpFirstRow) ExcelDeleteRow(OpSheet,OpTicket,OpFirstRow,r); }
    
//--- Debug    
    if(GhostDebug>=1)   Print(GhostDebug,":ExcelOrderClose(",ticket,",",lots,",",price,",",slippage,",",arrow,"): return=true");
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

bool ExcelOrderSelect(int index, int select, int pool=MODE_TRADES)
{
    int r;
//--- Assert SELECT_BY_TICKET index is order ticket.
    if(select==SELECT_BY_TICKET)
    {
    //--- Find order by ticket
        ExcelSelectRow=ExcelFindTicket(OpSheet,OpTicket,OpFirstRow,index);
    //--- Debug    
        if(GhostDebug>=1)   Print(GhostDebug,":ExcelOrderSelect(",index,",",select,",",pool,"): return=",ExcelSelectRow>0);

        return(ExcelSelectRow>0);
    }
//--- Assert SELECT_BY_POS where index=0 is FirstRow.
    else
    {
        if(pool==MODE_TRADES)
        {
        //--- Find total orders
            ExcelSelectRow=index+OpFirstRow;
        //--- Debug    
            if(GhostDebug>=1)   Print(GhostDebug,":ExcelOrderSelect(",index,",",select,",",pool,"): return=",index<ExcelOrdersTotal());

            return(index<ExcelOrdersTotal());
        }
        else
        {
        //--- Find total history (to be implemented)
        //--- Debug    
            if(GhostDebug>=1)   Print(GhostDebug,":ExcelOrderSelect(",index,",",select,",",pool,"): return=false");

            return(false);
        }
    }
}

double ExcelOrderClosePrice()
{
    return(ExcelGetValue(PoSheet,ExcelSelectRow,PoClosePrice));
}

datetime ExcelOrderCloseTime()
{
    return(ExcelGetValue(PoSheet,ExcelSelectRow,PoCloseTime));
}

string ExcelOrderComment()
{
    return(ExcelGetString(OpSheet,ExcelSelectRow,OpComment));
}

double ExcelOrderLots()
{
    return(ExcelGetValue(OpSheet,ExcelSelectRow,OpLots));
}

int ExcelOrderMagicNumber()
{
    return(ExcelGetValue(OpSheet,ExcelSelectRow,OpMagicNo));
}

double ExcelOrderOpenPrice()
{
    return(ExcelGetValue(OpSheet,ExcelSelectRow,OpOpenPrice));
}

datetime ExcelOrderOpenTime()
{
    return(ExcelGetValue(OpSheet,ExcelSelectRow,OpOpenTime));
}

double ExcelOrderStopLoss()
{
    return(ExcelGetValue(OpSheet,ExcelSelectRow,OpStopLoss));
}

string ExcelOrderSymbol()
{
    return(ExcelGetString(OpSheet,ExcelSelectRow,OpSymbol));
}

double ExcelOrderTakeProfit()
{
    return(ExcelGetValue(OpSheet,ExcelSelectRow,OpTakeProfit));
}

int ExcelOrderTicket()
{
    return(ExcelGetValue(OpSheet,ExcelSelectRow,OpTicket));
}

int ExcelOrderType()
{
    return(ExcelGetValue(OpSheet,ExcelSelectRow,OpType));
}

double ExcelAccountMargin()
{
    int r;
    double mgn, sum;

//--- Assert ticket no exists.    
//--- First row is header
    r=OpFirstRow;
    while (ExcelGetValue(OpSheet,r,OpTicket)>0)
    {
        mgn=MarketInfo(ExcelGetString(OpSheet,r,OpSymbol),MODE_MARGINREQUIRED)*ExcelGetValue(OpSheet,r,OpLots);
        sum=sum+mgn;
        r ++;
    }
    return(sum);
}

double ExcelAccountFreeMargin()
{
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
    r=OpFirstRow;
    while(ExcelGetValue(OpSheet,r,OpTicket)>0)
    {
        if(maxTicket<ExcelGetValue(OpSheet,r,OpTicket))
        {
            maxTicket=ExcelGetValue(OpSheet,r,OpTicket);
        }
        r ++;
    }
    r=PoFirstRow;
    while(ExcelGetValue(PoSheet,r,PoTicket)>0)
    {
        if(maxTicket<ExcelGetValue(PoSheet,r,PoTicket))
        {
            maxTicket=ExcelGetValue(PoSheet,r,PoTicket);
        }
        r ++;
    }
    
    maxTicket ++;
//--- Debug
    if(GhostDebug>=2)   Print(GhostDebug,":ExcelCreateTicket(): return=",maxTicket);
    return(maxTicket);
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

//|-----------------------------------------------------------------------------------------|
//|                       E N D   O F   E X P E R T   A D V I S O R                         |
//|-----------------------------------------------------------------------------------------|

