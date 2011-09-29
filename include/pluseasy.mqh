//|-----------------------------------------------------------------------------------------|
//|                                                                            pluseasy.mqh |
//|                                                            Copyright © 2011, Dennis Lee |
//| Assert History                                                                          |
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
string PlusVer="1.11";

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
   int total=OrdersTotal();
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
int EasyOrdersMagic(int mgc)
{
   int count=0;

//---- Assert determine count of all trades done with this MagicNumber
   for(int j=0;j<OrdersTotal();j++)
   {
      OrderSelect(j,SELECT_BY_POS,MODE_TRADES);

   //---- Assert MagicNumber and Symbol is same as Order
      if (OrderMagicNumber()==mgc && OrderSymbol()==Symbol())
         count++;
   }
   return(count);
}

double EasyProfitsMagic(int mgc)
{
   double profit=0.0;

//---- Assert determine count of all trades done with this MagicNumber
   for(int j=0;j<OrdersTotal();j++)
   {
      OrderSelect(j,SELECT_BY_POS,MODE_TRADES);

   //---- Assert MagicNumber and Symbol is same as Order
      if (OrderMagicNumber()==mgc && OrderSymbol()==Symbol())
         profit+=OrderProfit();
   }
   return(profit);
}


//+-----------------------------------------------------------------------------------------|
//|                             O P E N   N E W   T R A D E                                 |
//+-----------------------------------------------------------------------------------------|
int EasyBuy(int mgc, double lot)
{
//---- Assert account has money.
   if(AccountFreeMargin()<(1000*lot))
   {
      Print("We have no money. Free Margin = ", AccountFreeMargin());
      return(0);
   }
//---- Assert AccountMaxTrades has not been exceeded
   if(OrdersTotal()>=EasyMaxAccountTrades)
   {
      Print("Total trades have exceeded maximum account trades of ",EasyMaxAccountTrades);
      return(0);
   }
//---- Assert Spread < MaxSpread.
   double spread=MarketInfo(Symbol(),MODE_SPREAD)/Pip;
   if (spread>EasyMaxSpread)
   {
      Print("Spread has exceeded maximum spread of ",EasyMaxSpread);
      return(0);
   }
//---- Assert Trade Context not Busy
   if (IsTradeAllowed()==false)
   {
      Print("EasyBuy():Symbol()=",Symbol()," Trade Context Busy");
      return(0);
   }
   
   int ticket=OrderSend(Symbol(),OP_BUY,NormalizeDouble(lot,2),MarketInfo(Symbol(),MODE_ASK),EasySlipPage,0,0,PlusName,mgc,0,EasyColorBuy);
   if(ticket>0)
   {
      if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)) 
      {
      //---- Assert Open Buy
         Print("BUY order opened : ",OrderOpenPrice());
         //OpenWave=-1;
         if (EasySL!=0) double SL=NormalizeDouble(OrderOpenPrice()-EasySL*Pts,Digits);
         if (EasyTP!=0) double TP=NormalizeDouble(OrderOpenPrice()+EasyTP*Pts,Digits);
         if (EasySL!=0 || EasyTP!=0)
            if (!OrderModify(ticket,OrderOpenPrice(),SL,TP,0,0))
            {
               Print("Error modifying BUY order : ",GetLastError());
               if (EasyDebug>=2) Print("EasyBuy():Symbol()=",Symbol(),",Price=",OrderOpenPrice(),",SL=",SL,",TP=",0);
            }
      }
      return(ticket);
   }
   else 
   {
      Print("Error opening BUY order : ",GetLastError());
      if (EasyDebug>=2) Print("EasyBuy():Symbol()=",Symbol(),",Lots=",lot,",Ask=",MarketInfo(Symbol(),MODE_ASK),",SlipPage=",EasySlipPage,",SL=,",SL,",TP=",TP); //Ask+TakeProfit*Pts
   }
   return(0);
}

// =====================
// sell to open function                                            
// =====================
int EasySell(int mgc, double lot)
{
//---- Assert account has money.
   if(AccountFreeMargin()<(1000*lot))
   {
      Print("We have no money. Free Margin = ", AccountFreeMargin());
      return(0);
   }
//---- Assert AccountMaxTrades has not been exceeded
   if(OrdersTotal()>=EasyMaxAccountTrades)
   {
      Print("Total trades have exceeded maximum account trades of ",EasyMaxAccountTrades);
      return(0);
   }
//---- Assert Spread < MaxSpread.
   double spread=MarketInfo(Symbol(),MODE_SPREAD)/Pip;
   if (spread>EasyMaxSpread)
   {
      Print("Spread has exceeded maximum spread of ",EasyMaxSpread);
      return(0);
   }
//---- Assert Trade Context not Busy
   if (IsTradeAllowed()==false)
   {
      Print("EasySell():Symbol()=",Symbol()," Trade Context Busy");
      return(0);
   }

   int ticket=OrderSend(Symbol(),OP_SELL,NormalizeDouble(lot,2),MarketInfo(Symbol(),MODE_BID),EasySlipPage,0,0,PlusName,mgc,0,EasyColorSell);
   if(ticket>0)
   {
      if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)) 
      {
      //---- Assert Open Sell
         Print("SELL order opened : ",OrderOpenPrice());
         //OpenWave=1;
         if (EasySL!=0) double SL=NormalizeDouble(OrderOpenPrice()+EasySL*Pts,Digits);
         if (EasyTP!=0) double TP=NormalizeDouble(OrderOpenPrice()-EasyTP*Pts,Digits);
         if (EasySL!=0 || EasyTP!=0)
            if (!OrderModify(ticket,OrderOpenPrice(),SL,TP,0,0))
            {
               Print("Error modifying SELL order : ",GetLastError());
               if (EasyDebug>=2) Print("EasySell():Symbol()=",Symbol(),",Price=",OrderOpenPrice(),",SL=",SL,",TP=",TP);
            }
      }
      return(ticket);
   }
   else 
   {
      Print("Error opening SELL order : ",GetLastError());
      if (EasyDebug>=2) Print("EasySell():Symbol()=",Symbol(),",Lots=",lot,",Bid=",MarketInfo(Symbol(),MODE_BID),",SlipPage=",EasySlipPage,",SL=,",SL,",TP=",TP); //Ask+TakeProfit*Pts
   }

   return(0);
}
//+------------------------------------------------------------------+
//| Sell to close function                                           |
//+------------------------------------------------------------------+
bool EasySellToClose(int ticket)
{
   bool Closed;

//---- Assert ticket is valid.
   if (ticket<=0)
   {
      Print("EasySellToClose():ticket=",ticket," number is invalid.");
      return(false);
   }

   OrderSelect(ticket, SELECT_BY_TICKET);

//---- Assert ticket is open and orderlots should be closed at current bid price.
   if (OrderCloseTime()==0)
   {
      Closed=OrderClose(ticket,OrderLots(),MarketInfo(Symbol(),MODE_BID),EasySlipPage,EasyColorSell);
      
      if (!Closed)
      {
         Print("Error closing BUY order : ",GetLastError());
         if (EasyDebug>=2) Print("EasySellToClose():Symbol()=",Symbol(),",Bid=",MarketInfo(Symbol(),MODE_BID),",SlipPage=",EasySlipPage);
      }
   }
   return(Closed);
}
//+------------------------------------------------------------------+
//| Buy to close function                                            |
//+------------------------------------------------------------------+
bool EasyBuyToClose(int ticket)
{
   bool Closed;

//---- Assert ticket is valid.
   if (ticket<=0)
   {
      Print("EasyBuyToClose():ticket=",ticket," number is invalid.");
      return(false);
   }

   OrderSelect(ticket, SELECT_BY_TICKET);

//---- Assert ticket is open and orderlots should be closed at current ask price.
   if (OrderCloseTime()==0)
   {
      Closed=OrderClose(ticket,OrderLots(),MarketInfo(Symbol(),MODE_ASK),EasySlipPage,EasyColorBuy);
      
      if (!Closed)
      {
         Print("Error closing SELL order : ",GetLastError());
         if (EasyDebug>=2) Print("EasyBuyToClose():Symbol()=",Symbol(),",Ask=",MarketInfo(Symbol(),MODE_ASK),",SlipPage=",EasySlipPage);
      }
   }
   return(Closed);
}

