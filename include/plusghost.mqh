//|-----------------------------------------------------------------------------------------|
//|                                                                           PlusGhost.mqh |
//|                                                            Copyright © 2012, Dennis Lee |
//| Assert History                                                                          |
//| 1.00    Show trades in a separate window "GhostTerminal".                               |
//|-----------------------------------------------------------------------------------------|
#property   copyright "Copyright © 2012, Dennis Lee"
#include    <sqlite.mqh>

//|-----------------------------------------------------------------------------------------|
//|                 P L U S L I N E X   E X T E R N A L   V A R I A B L E S                 |
//|-----------------------------------------------------------------------------------------|
extern   string GhostTerminal           = "GhostTerminal";
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
string   GhostVer="1.0";

//---- Assert internal variables for GhostTerminal
string   GhostFontType="Arial";
int      GhostFontSize=8;
int      GhostWin=-1;
string   GhostOpenPositions[1][11];
string   GhostPendingOrders[1][11];
int      GhostCurOpenPositions=0;
int      GhostCurPendingOrders=0;

//---- Assert internal variables for SQLite
string   GhostDb="ghost.db";
string   GhostTable="orders";


//|-----------------------------------------------------------------------------------------|
//|                             I N I T I A L I Z A T I O N                                 |
//|-----------------------------------------------------------------------------------------|
void GhostInit()
{
    GhostTerminalInit();
    
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
    GhostLoadBuffersFromBroker();

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
}

//|-----------------------------------------------------------------------------------------|
//|                                 O P E N   O R D E R S                                   |
//|-----------------------------------------------------------------------------------------|
int GhostOrderSend(string symbol, int type, double lots, double price, int slippage,
                    double stoploss, double takeprofit, string comment="", int magic=0,
                    datetime expiration=0, color arrow_color=CLR_NONE)
{
/*
    string exp= "insert into "+GhostTable+" (
                 ticket,opentime,closetime,status,symbol,type,lots,price,slippage,stoploss,
                 takeprofit,comment,magic,expiration,profit,swap,commission) ";
    string val= "values ("+
                 StringConcatenate(
                 0,0,0,0,symbol,type,lots,price,slippage,stoploss,
                 takeprofit,comment,magic,expiration,0,0,0)";
*/
    return(0);
}

bool GhostOrderModify(int ticket, double price, double stoploss, double takeprofit, 
                        datetime expiration=0, color arrow_color=CLR_NONE)
{
    return(false);
}

//|-----------------------------------------------------------------------------------------|
//|                                O R D E R S   S T A T U S                                |
//|-----------------------------------------------------------------------------------------|
int GhostOrdersMagic(int mgc)
{
    return(0);
}

int GhostOrderTicket()
{
    return(0);
}

//|-----------------------------------------------------------------------------------------|
//|                                  C L O S E  O R D E R S                                 |
//|-----------------------------------------------------------------------------------------|
bool GhostOrderClose(int ticket, double lots, double price, int slippage, color Color=CLR_NONE)
{
    return(false);
}

bool GhostOrderDelete(int ticket, color Color=CLR_NONE)
{
    return(false);
}

//|-----------------------------------------------------------------------------------------|
//|                                     C O M M E N T                                       |
//|-----------------------------------------------------------------------------------------|
string GhostComment(string cmt="")
{
   string strtmp = cmt+"  -->"+GhostName+" "+GhostVer+"<--";

//---- Assert Trade info in comment
/*
   int total=GhostOrdersTotal();
   if (GhostMaxAccountTrades==0)
      strtmp=strtmp+"\n    No Ghost Allowed.";
   else if (total<=0)
      strtmp=strtmp+"\n    No Active Ghost Trades.";
   else if (total==GhostMaxAccountTrades)
      strtmp=strtmp+"\n    Ghost Trades="+total+" (Filled the maximum of "+DoubleToStr(GhostMaxAccountTrades,0)+")";
   else
      strtmp=strtmp+"\n    Ghost Trades="+total+" (OK <= "+DoubleToStr(GhostMaxAccountTrades,0)+")";
*/
                         
   strtmp = strtmp+"\n";
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
    
//-- Assert refresh terminal line by line.    
	
	for(int i=0; i<GhostRows; i++)
	{
		if(i<GhostCurOpenPositions)
		{
			if(GhostOpenPositions[i][2]=="Buy")
			{
				tmp_MainColor = GhostBuyColor;

				if ( StrToDouble( GhostOpenPositions[i][5] ) > 0 &&  NormalizeDouble( GhostPipLimit*Pts - ( StrToDouble( GhostOpenPositions[i][7] ) - StrToDouble( GhostOpenPositions[i][5] ) ), Digits ) >= 0.0 )
				{ tmp_SLColor = GhostBuySLColor; }
				else
				{ tmp_SLColor = GhostBuyColor; }

				if ( StrToDouble( GhostOpenPositions[i][6] ) > 0 && NormalizeDouble( GhostPipLimit*Pts - ( StrToDouble( GhostOpenPositions[i][6] ) - StrToDouble( GhostOpenPositions[i][7] ) ), Digits ) >= 0.0 )
				{ tmp_TPColor = GhostBuyTPColor; }
				else
				{ tmp_TPColor = GhostBuyColor; }
			}
			else
			{
				tmp_MainColor = GhostSellColor;

				if ( StrToDouble( GhostOpenPositions[i][5] ) > 0 &&  NormalizeDouble( GhostPipLimit*Pts - ( StrToDouble( GhostOpenPositions[i][5] ) - StrToDouble( GhostOpenPositions[i][7] ) ), Digits ) >= 0.0 )
				{ tmp_SLColor = GhostSellSLColor; }
				else
				{ tmp_SLColor = GhostSellColor; }

				if ( StrToDouble( GhostOpenPositions[i][6] ) > 0 && NormalizeDouble( GhostPipLimit*Pts - ( StrToDouble( GhostOpenPositions[i][7] ) - StrToDouble( GhostOpenPositions[i][6] ) ), Digits ) >= 0.0 )
				{ tmp_TPColor = GhostSellTPColor; }
				else
				{ tmp_TPColor = GhostSellColor; }
			}

			GhostSetText( "Ticket_" 	+ i, GhostOpenPositions[i][0]	, tmp_MainColor );
			GhostSetText( "OpenTime_" 	+ i, GhostOpenPositions[i][1]	, tmp_MainColor );
			GhostSetText( "Type_" 		+ i, GhostOpenPositions[i][2]	, tmp_MainColor );
			GhostSetText( "Lots_" 		+ i, GhostOpenPositions[i][3]	, tmp_MainColor );
			GhostSetText( "OpenPrice_" 	+ i, GhostOpenPositions[i][4]	, tmp_MainColor );
			GhostSetText( "StopLoss_" 	+ i, GhostOpenPositions[i][5]	, tmp_SLColor );
			GhostSetText( "TakeProfit_" + i, GhostOpenPositions[i][6]	, tmp_TPColor );
			GhostSetText( "CurPrice_" 	+ i, GhostOpenPositions[i][7]	, tmp_MainColor );
			GhostSetText( "Swap_" 		+ i, GhostOpenPositions[i][8]	, tmp_MainColor );
			GhostSetText( "Profit_" 	+ i, GhostOpenPositions[i][9]	, tmp_MainColor );
			GhostSetText( "Comment_" 	+ i, GhostOpenPositions[i][10]	, tmp_MainColor );
		}
		else
		{
			if(!summLineOK)
			{
				string tmp_margin = StringConcatenate("Margin: ",DoubleToStr(AccountMargin(),2));
				string tmp_marginLevel = "";
				if(AccountMargin()>0)
				{
					tmp_marginLevel = StringConcatenate("  MarginLevel: ",DoubleToStr(AccountEquity()/AccountMargin()*100,2),"%");
				}
				GhostSetText( "Ticket_" 	+ i, StringConcatenate("Balance: ",DoubleToStr(AccountBalance(),2),"  Equity: ",DoubleToStr(AccountEquity(),2)),GhostMainColor);
				GhostSetText( "OpenTime_" 	+ i );
				GhostSetText( "Type_" 		+ i );
				GhostSetText( "Lots_" 		+ i, StringConcatenate(tmp_margin,"  FreeMargin: ",DoubleToStr(AccountFreeMargin(),2),tmp_marginLevel),GhostMainColor);
				GhostSetText( "OpenPrice_" 	+ i );
				GhostSetText( "StopLoss_" 	+ i );
				GhostSetText( "TakeProfit_" + i );
				GhostSetText( "CurPrice_" 	+ i );
				GhostSetText( "Swap_" 		+ i );
				GhostSetText( "Profit_" 	+ i, DoubleToStr(summProfit,2),GhostMainColor);
				GhostSetText( "Comment_" 	+ i );
				i ++;
				summLineOK = true;
			}

			if ( i <= GhostCurOpenPositions + GhostCurPendingOrders )
			{
				if ( GhostPendingOrders[i-GhostCurOpenPositions-1][2] == "BuyLimit" || GhostPendingOrders[i-GhostCurOpenPositions-1][2] == "BuyStop" )
				{
					tmp_MainColor = GhostBuyColor;

					if ( NormalizeDouble( GhostPipLimit*Pts - MathAbs( StrToDouble( GhostPendingOrders[i-GhostCurOpenPositions-1][4] ) - StrToDouble( GhostPendingOrders[i-GhostCurOpenPositions-1][7] ) ), Digits ) >= 0.0 )
					{ tmp_OPColor = GhostBuyOPColor; }
					else
					{ tmp_OPColor = GhostBuyColor; }
				}
				else
				{
					tmp_MainColor = GhostSellColor;

					if ( NormalizeDouble( GhostPipLimit*Pts - MathAbs( StrToDouble( GhostPendingOrders[i-GhostCurOpenPositions-1][4] ) - StrToDouble( GhostPendingOrders[i-GhostCurOpenPositions-1][7] ) ), Digits ) >= 0.0 )
					{ tmp_OPColor = GhostSellOPColor; }
					else
					{ tmp_OPColor = GhostSellColor; }
				}

				GhostSetText( "Ticket_" 	+ i, GhostPendingOrders[i-GhostCurOpenPositions-1][0], tmp_MainColor );
				GhostSetText( "OpenTime_" 	+ i, GhostPendingOrders[i-GhostCurOpenPositions-1][1], tmp_MainColor );
				GhostSetText( "Type_" 		+ i, GhostPendingOrders[i-GhostCurOpenPositions-1][2], tmp_MainColor );
				GhostSetText( "Lots_" 		+ i, GhostPendingOrders[i-GhostCurOpenPositions-1][3], tmp_MainColor );
				GhostSetText( "OpenPrice_" 	+ i, GhostPendingOrders[i-GhostCurOpenPositions-1][4], tmp_OPColor	);
				GhostSetText( "StopLoss_" 	+ i, GhostPendingOrders[i-GhostCurOpenPositions-1][5], tmp_MainColor );
				GhostSetText( "TakeProfit_" + i, GhostPendingOrders[i-GhostCurOpenPositions-1][6], tmp_MainColor );
				GhostSetText( "CurPrice_" 	+ i, GhostPendingOrders[i-GhostCurOpenPositions-1][7], tmp_MainColor );
				GhostSetText( "Swap_" 		+ i, GhostPendingOrders[i-GhostCurOpenPositions-1][8], tmp_MainColor );
				GhostSetText( "Profit_" 	+ i, GhostPendingOrders[i-GhostCurOpenPositions-1][9], tmp_MainColor );
				GhostSetText( "Comment_" 	+ i, GhostPendingOrders[i-GhostCurOpenPositions-1][10],tmp_MainColor );
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

string GhostOrderType(int orderType)
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
void GhostLoadBuffersFromExcel()
{
}

void GhostLoadBuffersFromBroker()
{
	int lastErr, ordersTotal = OrdersTotal(), digits;
	double summProfit = 0.0;

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
			GhostOpenPositions[GhostCurOpenPositions][2] = GhostOrderType( OrderType() );
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

			summProfit += OrderProfit();
			GhostCurOpenPositions ++;
			if ( GhostCurOpenPositions >= GhostRows ) { break; }
		}
		else
		{
			GhostPendingOrders[GhostCurPendingOrders][0] = OrderTicket();
			GhostPendingOrders[GhostCurPendingOrders][1] = TimeToStr( OrderOpenTime() );
			GhostPendingOrders[GhostCurPendingOrders][2] = GhostOrderType( OrderType() );
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

