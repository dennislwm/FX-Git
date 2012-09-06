//|-----------------------------------------------------------------------------------------|
//|                                                                            pluseasy.mqh |
//|                                                            Copyright © 2011, Dennis Lee |
//| Assert History                                                                          |
//| 1.33    Added EasyOrdersBuyBasket() and EasyOrdersSellBasket() that returns count of    |
//|            BUY trades and SELL trades, respectively. Optional parameter noPending       |
//|            (default: T), if false pending orders will be counted.                       |
//| 1.32    Set maxTrades=0 (optional) will use EasyMaxAccountTrades in order functions.    |
//| 1.31    Minor fixes in functions Comment, GetFirstTicket, OrderBuy and OrderSell.       |
//| 1.30    Replaced Order functions with GhostOrder functions.                             |
//|            Added CloseBasket() functions.                                               |
//| 1.20    Added EasyTicketMagic() that returns first open ticket no.                      |
//| 1.11    Fixed trade context busy.                                                       |
//| 1.10    Comment has been added to show:                                                 |
//|             Basic settings                                                              |
//|             Trades opened                                                               |
//| 1.00    Copied from AlleeH4 4.43, functions that relate to buy/sell, opened trades,     |
//|           but exclude lot sizing, signal logic, risk, and closing/closed trades:        |
//|             //AssertWaveSameOpen()    --> EasyIsSameBar()                               |
//|             count_magic_profit()    --> EasyProfitsMagic()                              |
//|                                     --> EasyProfits()                                   |
//|             count_magic_total()     --> EasyOrdersMagic()                               |
//|                                     --> OrdersTotal()                                   |
//|             handle_digit()  --> EasyInit()                                              |
//|             buy_to_open()   --> EasyBuy                                                 |
//|             sell_to_open()  --> EasySell                                                |
//|             buy_to_close()  --> EasyBuyToClose                                          |
//|             sell_to_close() --> EasySellToClose                                         |
//|-----------------------------------------------------------------------------------------|
#property   copyright "Copyright © 2011, Dennis Lee"

//|-----------------------------------------------------------------------------------------|
//|                 P L U S E A S Y   E X T E R N A L   V A R I A B L E S                   |
//|-----------------------------------------------------------------------------------------|
//---- Assert Money Management externs
extern double EasyTP=0;
extern double EasySL=0;
extern double EasySlipPage=3;
extern double EasyMaxSpread=5;
extern int EasyMaxAccountTrades=0;
extern color EasyColorBuy=Thistle;
extern color EasyColorSell=Red;
extern bool EasyDebug=0;

//|-----------------------------------------------------------------------------------------|
//|                           I N T E R N A L   V A R I A B L E S                           |
//|-----------------------------------------------------------------------------------------|
//double ContractSize=100000;
double Pip;
double Pts;
string PlusName="PlusEasy";
string PlusVer="1.33";

//|-----------------------------------------------------------------------------------------|
//|                             I N I T I A L I Z A T I O N                                 |
//|-----------------------------------------------------------------------------------------|
void EasyInit()
{
//---- Automatically adjust to Full-Pip or Sub-Pip Accounts
   if (Digits==4||Digits==2)
   {
      EasySlipPage=EasySlipPage;
      Pip=1;
      Pts=Point;
   }
   if (Digits==5||Digits==3)
   {
      EasySlipPage=EasySlipPage*10;
      Pip=10;
      Pts=Point*10;
   }
//---- Automatically adjust one decimal place left for Gold
   if (Symbol()=="XAUUSD") 
   {
      EasySlipPage*=10;
      Pip*=10;
      Pts*=10;
   }
}

//|-----------------------------------------------------------------------------------------|
//|                                     C O M M E N T                                       |
//|-----------------------------------------------------------------------------------------|
string EasyComment(double profit, string cmt="")
{
   string strtmp = cmt+"  -->"+PlusName+" "+PlusVer+"<--";

//---- Assert Basic settings in comment
   strtmp=strtmp+"\n    TP="+DoubleToStr(EasyTP,0)+"  SL="+DoubleToStr(EasySL,0)+"  SlipPage="+DoubleToStr(EasySlipPage,0);
   
   double spread=MarketInfo(Symbol(),MODE_SPREAD)/Pip;
   if (EasyMaxSpread==0)
      strtmp=strtmp+"\n    No Spread Allowed.";
   else if (spread<=0)
      strtmp=strtmp+"\n    Zero Spread.";
   else if (spread>EasyMaxSpread)
      strtmp=strtmp+"\n    Spread="+DoubleToStr(spread,1)+" (Exceeded the maximum of "+DoubleToStr(EasyMaxSpread,1)+")";
   else
      strtmp=strtmp+"\n    Spread="+DoubleToStr(spread,1)+" (OK <= "+DoubleToStr(EasyMaxSpread,1)+")";
   
//---- Assert Trade info in comment
   int total=GhostOrdersTotal();
   if (EasyMaxAccountTrades==0)
      strtmp=strtmp+"\n    No Trades Allowed.";
   else if (total<=0)
      strtmp=strtmp+"\n    No Active Trades.";
   else if (total==EasyMaxAccountTrades)
      strtmp=strtmp+"\n    Trades="+total+" (Filled the maximum of "+DoubleToStr(EasyMaxAccountTrades,0)+")";
   else
      strtmp=strtmp+"\n    Trades="+total+" (OK <= "+DoubleToStr(EasyMaxAccountTrades,0)+")";
                         
   strtmp = strtmp+"\n";
   return(strtmp);
}

//|-----------------------------------------------------------------------------------------|
//|                                O R D E R S   S T A T U S                                |
//|-----------------------------------------------------------------------------------------|
int EasyOrdersBasket(int mgc, string sym, bool noPending=true)
{
   int count=0;
   int total=GhostOrdersTotal();
//---- Assert optimize function by checking total > 0
   if( total<=0 ) return(count);
//---- Assert determine count of all trades done with this MagicNumber
//       Init OrderSelect #1
   GhostInitSelect(true,0,SELECT_BY_POS,MODE_TRADES);
   for(int j=0;j<total;j++)
   {
      GhostOrderSelect(j,SELECT_BY_POS,MODE_TRADES);

   //---- Assert MagicNumber and Symbol is same as Order
      if (GhostOrderMagicNumber()==mgc && GhostOrderSymbol()==sym)
      {
         if( noPending==false ) count ++;
         else
            if( GhostOrderType() <= 1 ) count ++;
      }
   }
//---- Assert 1: Free OrderSelect #1
   GhostFreeSelect(false);
   return(count);
}
int EasyOrdersBuyBasket(int mgc, string sym, bool noPending=true)
{
   int count=0;
   int total=GhostOrdersTotal();
//---- Assert optimize function by checking total > 0
   if( total<=0 ) return(count);
//---- Assert determine count of all trades done with this MagicNumber
//       Init OrderSelect #9
   GhostInitSelect(true,0,SELECT_BY_POS,MODE_TRADES);
   for(int j=0;j<total;j++)
   {
      GhostOrderSelect(j,SELECT_BY_POS,MODE_TRADES);

   //---- Assert MagicNumber and Symbol is same as Order
      if (GhostOrderMagicNumber()==mgc && GhostOrderSymbol()==sym)
      {
         if( noPending==false ) 
         {
            if( GhostOrderType() == OP_BUY || GhostOrderType() == OP_BUYLIMIT || GhostOrderType() == OP_BUYSTOP ) 
               count ++;
         }
         else
            if( GhostOrderType() == OP_BUY ) count ++;
      }
   }
//---- Assert 1: Free OrderSelect #9
   GhostFreeSelect(false);
   return(count);
}
int EasyOrdersSellBasket(int mgc, string sym, bool noPending=true)
{
   int count=0;
   int total=GhostOrdersTotal();
//---- Assert optimize function by checking total > 0
   if( total<=0 ) return(count);
//---- Assert determine count of all trades done with this MagicNumber
//       Init OrderSelect #10
   GhostInitSelect(true,0,SELECT_BY_POS,MODE_TRADES);
   for(int j=0;j<total;j++)
   {
      GhostOrderSelect(j,SELECT_BY_POS,MODE_TRADES);

   //---- Assert MagicNumber and Symbol is same as Order
      if (GhostOrderMagicNumber()==mgc && GhostOrderSymbol()==sym)
      {
         if( noPending==false ) 
         {
            if( GhostOrderType() == OP_SELL || GhostOrderType() == OP_SELLLIMIT || GhostOrderType() == OP_SELLSTOP ) 
               count ++;
         }
         else
            if( GhostOrderType() == OP_SELL ) count ++;
      }
   }
//---- Assert 1: Free OrderSelect #10
   GhostFreeSelect(false);
   return(count);
}
double EasyProfitsBasket(int mgc, string sym, bool noPending=true)
{
   double profit=0.0;
   int total=GhostOrdersTotal();
//---- Assert optimize function by checking total > 0
   if( total<=0 ) return(profit);
//---- Assert determine count of all trades done with this MagicNumber
//       Init OrderSelect #2
   GhostInitSelect(true,0,SELECT_BY_POS,MODE_TRADES);
   for(int j=0;j<total;j++)
   {
      GhostOrderSelect(j,SELECT_BY_POS,MODE_TRADES);

   //---- Assert MagicNumber and Symbol is same as Order
      if (GhostOrderMagicNumber()==mgc && GhostOrderSymbol()==sym)
      {
         if( noPending==false ) profit+=GhostOrderProfit();
         else
            if( GhostOrderType() <= 1 ) profit+=GhostOrderProfit();
      }
   }
//---- Assert 1: Free OrderSelect #2
   GhostFreeSelect(false);
   return(profit);
}

int EasyGetFirstTicket(int mgc, string sym, bool noPending=true)
{
   int ticket=-1;
   int total=GhostOrdersTotal();
//---- Assert optimize function by checking total > 0
   if( total<=0 ) return(ticket);
//---- Assert determine count of all trades done with this MagicNumber
//       Init OrderSelect #3
   GhostInitSelect(true,0,SELECT_BY_POS,MODE_TRADES);
   for(int j=0;j<total;j++)
   {
      GhostOrderSelect(j,SELECT_BY_POS,MODE_TRADES);

   //---- Assert MagicNumber and Symbol is same as Order
      if (GhostOrderMagicNumber()==mgc && GhostOrderSymbol()==sym)
      {
         if( noPending==false ) ticket=GhostOrderTicket();
         else
            if( GhostOrderType() <= 1 ) ticket=GhostOrderTicket();
      }
   }
//---- Assert 1: Free OrderSelect #3
   GhostFreeSelect(false);
   return(ticket);
}

//+-----------------------------------------------------------------------------------------|
//|                             O P E N   N E W   T R A D E                                 |
//+-----------------------------------------------------------------------------------------|
int EasyOrderBuy(int mgc, string sym, double lot, double SL, double TP, string cmt, int maxTrades=0)
{
   if( maxTrades==0 ) maxTrades = EasyMaxAccountTrades;
//---- Assert Check limits of externs
//       MaxTrades has not been exceeded
//       MaxSpread has not been exceeded
   int total=GhostOrdersTotal();
   if( total >= maxTrades)
   {
      Print("EasyOrderBuy: Total trades have exceeded maximum account trades of ",maxTrades);
      return(0);
   }
   double spread=MarketInfo(sym,MODE_SPREAD)/Pip;
   if (spread>EasyMaxSpread)
   {
      Print("EasyOrderBuy: Spread has exceeded maximum spread of ",EasyMaxSpread);
      return(0);
   }
//---- Assert check limits of account
//       Account has sufficient margin
   double mgn=MarketInfo(sym,MODE_MARGINREQUIRED)*lot;
   if( GhostAccountFreeMargin() < mgn*1.1 )
   {
      Print("EasyOrderBuy: Margin requirement exceeds free margin of ", GhostAccountFreeMargin());
      return(0);
   }
//---- Assert Trade Context not Busy
   if (IsTradeAllowed()==false)
   {
      Print("EasyOrderBuy: sym=",sym," Trade Context Busy");
      return(0);
   }

//--- Assert 10: Declare variables for OrderSelect #3
//       1-OrderModify BUY; 2-OrderClose BUY; 3-OrderModify SELL; 4-OrderClose SELL;
   int      aCommand[];
   int      aTicket[];
   double   aLots[];
   double   aOpenPrice[];
   double   aStopLoss[];
   double   aTakeProfit[];
   double   calcSL;
   double   calcTP;
   bool     aOk;
   int      aCount;
//--- Assert 6: Dynamically resize arrays for OrderSelect #3
   ArrayResize(aCommand,maxTrades);
   ArrayResize(aTicket,maxTrades);
   ArrayResize(aLots,maxTrades);
   ArrayResize(aOpenPrice,maxTrades);
   ArrayResize(aStopLoss,maxTrades);
   ArrayResize(aTakeProfit,maxTrades);
   
   int ticket=GhostOrderSend(sym,OP_BUY,NormalizeDouble(lot,2),MarketInfo(sym,MODE_ASK),EasySlipPage,0,0,cmt,mgc,0,EasyColorBuy);
   if(ticket>0)
   {
   //--- Assert 1: Init OrderSelect #3
      GhostInitSelect(true,ticket,SELECT_BY_TICKET,MODE_TRADES);
      if(GhostOrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)) 
      {
      //--- Assert 6: Populate arrays for OrderSelect #3
         aCommand[aCount]     =  0;
         aTicket[aCount]      =  GhostOrderTicket();
         aLots[aCount]        =  GhostOrderLots();
         aOpenPrice[aCount]   =  GhostOrderOpenPrice();
         aStopLoss[aCount]    =  GhostOrderStopLoss();
         aTakeProfit[aCount]  =  GhostOrderTakeProfit();
         
      //---- Assert Open Buy
         Print("EasyOrderBuy: Order opened : ticket=",ticket," openPrice=",DoubleToStr(GhostOrderOpenPrice(),5));
         //OpenWave=-1;
         if (SL!=0) calcSL=NormalizeDouble(GhostOrderOpenPrice()-SL*Pts,Digits);
         if (TP!=0) calcTP=NormalizeDouble(GhostOrderOpenPrice()+TP*Pts,Digits);
         if (SL!=0 || TP!=0)
         {
            //--- Assert 4: replace OrderModify a buy with arrays
               aCommand[aCount]     = 1;
               aStopLoss[aCount]    = calcSL;
               aTakeProfit[aCount]  = calcTP;
               aCount ++;
         }
      }
   //--- Assert 1: Free OrderSelect #3
      GhostFreeSelect(true);
   //--- Assert for: process array of commands for OrderSelect #3
      for(int i=0; i<aCount; i++)
      {
         switch( aCommand[i] )
         {
            case 1:  // OrderModify Buy
               GhostOrderModify( aTicket[i], aOpenPrice[i], aStopLoss[i], aTakeProfit[i], 0, EasyColorBuy );
               break;
         }
      }
      return(ticket);
   }
   else 
   {
      Print("EasyOrderBuy: Error opening BUY order : ",GetLastError());
      if (EasyDebug>=2) Print("EasyOrderBuy(): sym=",sym,",Lots=",lot,",Ask=",MarketInfo(sym,MODE_ASK),",SlipPage=",EasySlipPage,",SL=,",calcSL,",TP=",calcTP); //Ask+TakeProfit*Pts
   }
   return(0);
}

// =====================
// sell to open function                                            
// =====================
int EasyOrderSell(int mgc, string sym, double lot, double SL, double TP, string cmt, int maxTrades=0)
{
   if( maxTrades==0 ) maxTrades = EasyMaxAccountTrades;
//---- Assert Check limits of externs
//       MaxTrades has not been exceeded
//       MaxSpread has not been exceeded
   int total=GhostOrdersTotal();
   if( total >= maxTrades)
   {
      Print("EasyOrderSell: Total trades have exceeded maximum account trades of ",maxTrades);
      return(0);
   }
   double spread=MarketInfo(sym,MODE_SPREAD)/Pip;
   if (spread>EasyMaxSpread)
   {
      Print("EasyOrderSell: Spread has exceeded maximum spread of ",EasyMaxSpread);
      return(0);
   }
//---- Assert check limits of account
//       Account has sufficient margin
   double mgn=MarketInfo(sym,MODE_MARGINREQUIRED)*lot;
   if( GhostAccountFreeMargin() < mgn*1.1 )
   {
      Print("EasyOrderSell: Margin requirement exceeds free margin of ", GhostAccountFreeMargin());
      return(0);
   }
//---- Assert Trade Context not Busy
   if (IsTradeAllowed()==false)
   {
      Print("EasyOrderSell(): sym=",sym," Trade Context Busy");
      return(0);
   }

//--- Assert 10: Declare variables for OrderSelect #4
//       1-OrderModify BUY; 2-OrderClose BUY; 3-OrderModify SELL; 4-OrderClose SELL;
   int      aCommand[];
   int      aTicket[];
   double   aLots[];
   double   aOpenPrice[];
   double   aStopLoss[];
   double   aTakeProfit[];
   double   calcSL;
   double   calcTP;
   bool     aOk;
   int      aCount;
//--- Assert 6: Dynamically resize arrays for OrderSelect #4
   ArrayResize(aCommand,maxTrades);
   ArrayResize(aTicket,maxTrades);
   ArrayResize(aLots,maxTrades);
   ArrayResize(aOpenPrice,maxTrades);
   ArrayResize(aStopLoss,maxTrades);
   ArrayResize(aTakeProfit,maxTrades);

   int ticket=GhostOrderSend(sym,OP_SELL,NormalizeDouble(lot,2),MarketInfo(sym,MODE_BID),EasySlipPage,0,0,cmt,mgc,0,EasyColorSell);
   if(ticket>0)
   {
   //--- Assert 1: Init OrderSelect #4
      GhostInitSelect(true,ticket,SELECT_BY_TICKET,MODE_TRADES);
      if(GhostOrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)) 
      {
      //--- Assert 6: Populate arrays for OrderSelect #4
         aCommand[aCount]     =  0;
         aTicket[aCount]      =  GhostOrderTicket();
         aLots[aCount]        =  GhostOrderLots();
         aOpenPrice[aCount]   =  GhostOrderOpenPrice();
         aStopLoss[aCount]    =  GhostOrderStopLoss();
         aTakeProfit[aCount]  =  GhostOrderTakeProfit();
         
      //---- Assert Open Sell
         Print("EasySellOrder: Order opened: ticket=",ticket," openPrice=",DoubleToStr(GhostOrderOpenPrice(),5));
         //OpenWave=1;
         if (SL!=0) calcSL=NormalizeDouble(GhostOrderOpenPrice()+SL*Pts,Digits);
         if (TP!=0) calcTP=NormalizeDouble(GhostOrderOpenPrice()-TP*Pts,Digits);
         if (SL!=0 || TP!=0)
         {
            //--- Assert 4: replace OrderModify a sell with arrays
               aCommand[aCount]     = 3;
               aStopLoss[aCount]    = calcSL;
               aTakeProfit[aCount]  = calcTP;
               aCount ++;
         }
      }
   //--- Assert 1: Free OrderSelect #4
      GhostFreeSelect(true);
   //--- Assert for: process array of commands for OrderSelect #4
      for(int i=0; i<aCount; i++)
      {
         switch( aCommand[i] )
         {
            case 3:  // OrderModify Sells
               GhostOrderModify( aTicket[i], aOpenPrice[i], aStopLoss[i], aTakeProfit[i], 0, EasyColorSell );
               break;
         }
      }
      return(ticket);
   }
   else 
   {
      Print("EasyOrderSell: Error opening SELL order : ",GetLastError());
      if (EasyDebug>=2) Print("EasyOrderSell(): sym=",sym,",Lots=",lot,",Bid=",MarketInfo(sym,MODE_BID),",SlipPage=",EasySlipPage,",SL=,",calcSL,",TP=",calcTP); //Ask+TakeProfit*Pts
   }
   return(0);
}

//+------------------------------------------------------------------+
//| Sell to close function                                           |
//+------------------------------------------------------------------+
bool EasySellToCloseBasket(int mgc, string sym, int maxTrades=0)
{
   if( maxTrades==0 ) maxTrades = EasyMaxAccountTrades;
//--- Assert 5: Declare variables for OrderSelect #7
//       1-OrderModify BUY; 2-OrderClose BUY; 3-OrderModify SELL; 4-OrderClose SELL;
   int      aCommand[];
   int      aTicket[];
   double   aLots[];
   bool     aOk;
   int      aCount;
//--- Assert 3: Dynamically resize arrays for OrderSelect #7
   ArrayResize(aCommand,maxTrades);
   ArrayResize(aTicket,maxTrades);
   ArrayResize(aLots,maxTrades);
//--- Assert 2: Init OrderSelect #7
   int total=GhostOrdersTotal();
   GhostInitSelect(true,0,SELECT_BY_POS,MODE_TRADES);
   for(int j=0;j<total;j++)
   {
      GhostOrderSelect(j,SELECT_BY_POS,MODE_TRADES);
   //--- Assert 3: Populate arrays for OrderSelect #7
      aCommand[aCount]     =  0;
      aTicket[aCount]      =  GhostOrderTicket();
      aLots[aCount]        =  GhostOrderLots();

   //---- Assert ticket is open and orderlots should be closed at current bid price.
      if (GhostOrderMagicNumber()==mgc && GhostOrderSymbol()==sym && GhostOrderCloseTime()==0)
      {
      //--- Assert 3: replace OrderClose Buy trade with arrays
         aCommand[aCount]     = 2;
         aCount ++;
      }
   }
//--- Assert 1: Free OrderSelect #7
   GhostFreeSelect(false);
//--- Assert for: process array of commands for OrderSelect #7
   aOk = true;
   for(int i=0; i<aCount; i++)
   {
      switch( aCommand[i] )
      {
         case 2:  // OrderClose a buy trade
            aOk = aOk && GhostOrderClose( aTicket[i], aLots[i], MarketInfo(sym,MODE_BID), EasySlipPage, EasyColorSell);
            break;
      }
   }
   if (!aOk)
   {
      Print("EasySellToCloseBasket: Error closing BUY order : ",GetLastError());
      if (EasyDebug>=2) Print("EasySellToCloseBasket: aCount=",aCount," Bid=",MarketInfo(sym,MODE_BID),",SlipPage=",EasySlipPage);
   }
   return(aOk);
}
bool EasySellToClose(int ticket, string sym, int maxTrades=0)
{
   if( maxTrades==0 ) maxTrades = EasyMaxAccountTrades;
   bool Closed;
//---- Assert ticket is valid.
   if (ticket<=0)
   {
      Print("EasySellToClose():ticket=",ticket," number is invalid.");
      return(false);
   }
//--- Assert 5: Declare variables for OrderSelect #5
//       1-OrderModify BUY; 2-OrderClose BUY; 3-OrderModify SELL; 4-OrderClose SELL;
   int      aCommand[];
   int      aTicket[];
   double   aLots[];
   bool     aOk;
   int      aCount;
//--- Assert 3: Dynamically resize arrays for OrderSelect #5
   ArrayResize(aCommand,maxTrades);
   ArrayResize(aTicket,maxTrades);
   ArrayResize(aLots,maxTrades);
//--- Assert 1: Init OrderSelect #5
   GhostInitSelect(true,ticket,SELECT_BY_TICKET,MODE_TRADES);
 
   GhostOrderSelect(ticket, SELECT_BY_TICKET);
//--- Assert 3: Populate arrays for OrderSelect #5
   aCommand[aCount]     =  0;
   aTicket[aCount]      =  GhostOrderTicket();
   aLots[aCount]        =  GhostOrderLots();

//---- Assert ticket is open and orderlots should be closed at current bid price.
   if (GhostOrderCloseTime()==0)
   {
   //--- Assert 3: replace OrderClose Buy trade with arrays
      aCommand[aCount]     = 2;
      aCount ++;
   
      /*Closed=OrderClose(ticket,OrderLots(),MarketInfo(Symbol(),MODE_BID),EasySlipPage,EasyColorSell);
      if (!Closed)
      {
         Print("Error closing BUY order : ",GetLastError());
         if (EasyDebug>=2) Print("EasySellToClose():Symbol()=",Symbol(),",Bid=",MarketInfo(Symbol(),MODE_BID),",SlipPage=",EasySlipPage);
      }*/
   }
//--- Assert 1: Free OrderSelect #5
   GhostFreeSelect(true);
//--- Assert for: process array of commands for OrderSelect #5
   for(int i=0; i<aCount; i++)
   {
      switch( aCommand[i] )
      {
         case 2:  // OrderClose a buy trade
            GhostOrderClose( aTicket[i], aLots[i], MarketInfo(sym,MODE_BID), EasySlipPage, EasyColorSell);
            break;
      }
   }
   if (!Closed)
   {
      Print("EasySellToClose: Error closing BUY order : ",GetLastError());
      if (EasyDebug>=2) Print("EasySellToClose(): ticket=",ticket,",Bid=",MarketInfo(sym,MODE_BID),",SlipPage=",EasySlipPage);
   }
   return(Closed);
}

//+------------------------------------------------------------------+
//| Buy to close function                                            |
//+------------------------------------------------------------------+
bool EasyBuyToCloseBasket(int mgc, string sym, int maxTrades)
{
//--- Assert 5: Declare variables for OrderSelect #8
//       1-OrderModify BUY; 2-OrderClose BUY; 3-OrderModify SELL; 4-OrderClose SELL;
   int      aCommand[];
   int      aTicket[];
   double   aLots[];
   bool     aOk;
   int      aCount;
//--- Assert 3: Dynamically resize arrays for OrderSelect #8
   ArrayResize(aCommand,maxTrades);
   ArrayResize(aTicket,maxTrades);
   ArrayResize(aLots,maxTrades);
//--- Assert 2: Init OrderSelect #8
   int total=GhostOrdersTotal();
   GhostInitSelect(true,0,SELECT_BY_POS,MODE_TRADES);
   for(int j=0;j<total;j++)
   {
      GhostOrderSelect(j,SELECT_BY_POS,MODE_TRADES);
   //--- Assert 3: Populate arrays for OrderSelect #8
      aCommand[aCount]     =  0;
      aTicket[aCount]      =  GhostOrderTicket();
      aLots[aCount]        =  GhostOrderLots();

   //---- Assert ticket is open and orderlots should be closed at current ask price.
      if (GhostOrderMagicNumber()==mgc && GhostOrderSymbol()==sym && GhostOrderCloseTime()==0)
      {
      //--- Assert 3: replace OrderClose Sell trade with arrays
         aCommand[aCount]     = 4;
         aCount ++;
      }
   }
//--- Assert 1: Free OrderSelect #8
   GhostFreeSelect(false);
//--- Assert for: process array of commands for OrderSelect #8
   aOk = true;
   for(int i=0; i<aCount; i++)
   {
      switch( aCommand[i] )
      {
         case 4:  // OrderClose a sell trade
            aOk = aOk && GhostOrderClose( aTicket[i], aLots[i], MarketInfo(sym,MODE_ASK), EasySlipPage, EasyColorBuy);
            break;
      }
   }
   if (!aOk)
   {
      Print("EasyBuyToCloseBasket: Error closing SELL order : ",GetLastError());
      if (EasyDebug>=2) Print("EasyBuyToCloseBasket: aCount=",aCount,",Ask=",MarketInfo(sym,MODE_ASK),",SlipPage=",EasySlipPage);
   }
   return(aOk);
}
bool EasyBuyToClose(int ticket, string sym, int maxTrades)
{
   bool Closed;
//---- Assert ticket is valid.
   if (ticket<=0)
   {
      Print("EasyBuyToClose():ticket=",ticket," number is invalid.");
      return(false);
   }
//--- Assert 5: Declare variables for OrderSelect #6
//       1-OrderModify BUY; 2-OrderClose BUY; 3-OrderModify SELL; 4-OrderClose SELL;
   int      aCommand[];
   int      aTicket[];
   double   aLots[];
   bool     aOk;
   int      aCount;
//--- Assert 3: Dynamically resize arrays for OrderSelect #6
   ArrayResize(aCommand,maxTrades);
   ArrayResize(aTicket,maxTrades);
   ArrayResize(aLots,maxTrades);
//--- Assert 1: Init OrderSelect #6
   GhostInitSelect(true,ticket,SELECT_BY_TICKET,MODE_TRADES);

   GhostOrderSelect(ticket, SELECT_BY_TICKET);
//--- Assert 3: Populate arrays for OrderSelect #6
   aCommand[aCount]     =  0;
   aTicket[aCount]      =  GhostOrderTicket();
   aLots[aCount]        =  GhostOrderLots();

//---- Assert ticket is open and orderlots should be closed at current ask price.
   if (GhostOrderCloseTime()==0)
   {
   //--- Assert 3: replace OrderClose Sell trade with arrays
      aCommand[aCount]     = 4;
      aCount ++;
      
      /*Closed=OrderClose(ticket,OrderLots(),MarketInfo(Symbol(),MODE_ASK),EasySlipPage,EasyColorBuy);
      if (!Closed)
      {
         Print("Error closing SELL order : ",GetLastError());
         if (EasyDebug>=2) Print("EasyBuyToClose():Symbol()=",Symbol(),",Ask=",MarketInfo(Symbol(),MODE_ASK),",SlipPage=",EasySlipPage);
      }*/
   }
//--- Assert 1: Free OrderSelect #6
   GhostFreeSelect(true);
//--- Assert for: process array of commands for OrderSelect #6
   for(int i=0; i<aCount; i++)
   {
      switch( aCommand[i] )
      {
         case 4:  // OrderClose a sell trade
            GhostOrderClose( aTicket[i], aLots[i], MarketInfo(sym,MODE_ASK), EasySlipPage, EasyColorBuy);
            break;
      }
   }
   if (!Closed)
   {
      Print("EasyBuyToClose: Error closing SELL order : ",GetLastError());
      if (EasyDebug>=2) Print("EasyBuyToClose(): ticket=",ticket,",Ask=",MarketInfo(sym,MODE_ASK),",SlipPage=",EasySlipPage);
   }
   return(Closed);
}

