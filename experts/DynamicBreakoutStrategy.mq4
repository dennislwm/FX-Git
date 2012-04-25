//|-----------------------------------------------------------------------------------------|
//|                                                             DynamicBreakoutStrategy.mq4 |
//|                                                            Copyright © 2012, Dennis Lee |
//| Assert History                                                                          |
//| 2.00    Originated from Pruitt, G. & Hill, J. R., 2003, Building Winning Trading        |
//|            Systems with TradeStation, pp144-5.                                          |
//| 2.01    Manage existing positions: (a) One BUY and One SELL stop ONLY; (b) One OPENED   |
//|            position ONLY. Fixed code to check for new bar.                              |
//|-----------------------------------------------------------------------------------------|
#property   copyright "Copyright © 2012, Dennis Lee"
#import "WinUser32.mqh"

//---- Assert Basic externs
extern   string   s1="-->Basic Settings<--";
extern   double   DbsLot         =  0.1;
extern   int      DbsMagic       =  2060;
extern   string   s2="-->Lookback Period Settings<--";
extern   int      DbsCeiling     =  60;
extern   int      DbsFloor       =  20;
extern   string   s3="-->Bollinger Band Settings<--";
extern   double   DbsBandDev     =  2.0;
//---- Assert Extra externs
extern   string   s4="-->Extra Settings<--";
extern   int      DbsDebug       =  0;
//---- Assert PlusEasy
extern   string   s5="-->PlusEasy Settings<--";
#include <PlusEasy.mqh>
//---- Assert PlusTurtle
extern   string   s6="-->PlusTurtle Settings<--";
#include <PlusTurtle.mqh>
//---- Assert PlusGhost
extern   string   s7="-->PlusGhost Settings<--";
#include <PlusGhost.mqh>

//|------------------------------------------------------------------------------------------|
//|                           I N T E R N A L   V A R I A B L E S                            |
//|------------------------------------------------------------------------------------------|
string   EaName               =  "DynamicBreakoutStrategy";
string   EaVer                =  "2.00";
//---- Assert internal variables for Lookback Period
int      DbsLookBackBar       =  20;
//---- Assert variables for trigger limits to open
double   DbsHiPrice;
double   DbsLoPrice;
//---- Assert variables for trigger limits to close
double   DbsExitPrice;
//---- Assert variables for limits of Bollinger Band
double   DbsUpBand;
double   DbsDnBand;
//---- Assert variables to detect new bar
int      nextBarTime;

// ------------------------------------------------------------------------------------------|
//                             I N I T I A L I S A T I O N                                   |
// ------------------------------------------------------------------------------------------|

int init()
{
   EasyInit();
   TurtleInit();
   GhostInit(EaName);
   return(0);    
}

bool isNewBar()
{
   if ( nextBarTime == Time[0] )
      return(false);
   else
      nextBarTime = Time[0];
   return(true);
}

//|------------------------------------------------------------------------------------------|
//|                            D E - I N I T I A L I S A T I O N                             |
//|------------------------------------------------------------------------------------------|

int deinit()
{
   GhostDeInit();
   return(0);
}


//|------------------------------------------------------------------------------------------|
//|                               M A I N   P R O C E D U R E                                |
//|------------------------------------------------------------------------------------------|

int start()
{
//---- Assert variables for volatility
double   volatility0;      // Current bar
double   volatility1;      // Previous bar
double   volatilityDelta;  // Change in volatility
//---- Assert variables for signal
double   closePrice;
int      wave;
int      ticket;

//--- Assert Determine volatility based on close prices of last THIRTY bars.
   volatility0=iStdDev(NULL,0,30,0,MODE_SMA,PRICE_CLOSE,0);
   volatility1=iStdDev(NULL,0,30,0,MODE_SMA,PRICE_CLOSE,1);
//--- Assert Calculate the delta volatility
   volatilityDelta      =  (volatility0 - volatility1) / volatility0;

//--- Assert Calculate Dynamic Lookback period once per bar
   if(isNewBar())
   {
      DbsLookBackBar       =  DbsLookBackBar * (1 + volatilityDelta);
      DbsLookBackBar       =  MathRound(DbsLookBackBar);
   }
//--- Assert Lookback period is within the range of ceiling and floor
   DbsLookBackBar       =  MathMin(DbsCeiling,DbsLookBackBar);
   DbsLookBackBar       =  MathMax(DbsFloor,DbsLookBackBar);
   
//--- Assert Determine limits of Bollinger Band using Dynamic Lookback period
   DbsUpBand=iBands(NULL,0,DbsLookBackBar,DbsBandDev,0,PRICE_CLOSE,MODE_UPPER,0);
   DbsDnBand=iBands(NULL,0,DbsLookBackBar,DbsBandDev,0,PRICE_CLOSE,MODE_LOWER,0);
//--- Assert Determine trigger limits to open using Dynamic Lookback period
   DbsHiPrice=High[iHighest(NULL,0,MODE_HIGH,DbsLookBackBar,0)];
   DbsLoPrice=Low[iLowest(NULL,0,MODE_LOW,DbsLookBackBar,0)];
//--- Assert Determine trigger limits to close using Dynamic Lookback period
   DbsExitPrice=iMA(NULL,0,DbsLookBackBar,0,MODE_SMA,PRICE_CLOSE,0);

//--- Assert Determine if Signal to Open has been reached
   if (Close[0] > DbsUpBand)  {  wave = -2; }   // open buy stop
   if (Close[0] < DbsDnBand)  {  wave = 2; }    // open sell stop

//--- Comments   
   Comment(DbsComment());

//--- Assert Manage existing pending orders
   if (wave==2    && DbsTotalSellStops()>0) return(0);
   if (wave==-2   && DbsTotalBuyStops()>0) return(0);

//--- Assert Manage existing opened positions, i.e. only ONE trade permitted at a time
   if (DbsGetBuyTicket()>0) 
   {
   //--- Check if BID is <= Exit Price
      closePrice = MarketInfo( Symbol(), MODE_BID ); 
      if (closePrice <= DbsExitPrice) 
      {
         GhostOrderClose(GhostOrderTicket(),GhostOrderLots(),closePrice,EasySlipPage,EasyColorSell);
      }
      else return(0);
   }
   if (DbsGetSellTicket()>0) 
   {
   //--- Check if ASK is >= Exit Price
      closePrice = MarketInfo( Symbol(), MODE_ASK ); 
      if (closePrice >= DbsExitPrice) 
      {
         GhostOrderClose(GhostOrderTicket(),GhostOrderLots(),closePrice,EasySlipPage,EasyColorBuy);
      }
      else return(0);
   }
   
//--- Assert Open Buy or Sell STOP order at hiPrice or loPrice respectively
   switch(wave)
   {
      case 2:  // open sell stop
         ticket = GhostOrderSend(Symbol(),OP_SELLSTOP,NormalizeDouble(DbsLot,2),DbsLoPrice,EasySlipPage,0,0,EaName,DbsMagic,0,EasyColorSell);
         if(ticket<0)   Print(EaName,": Error: ", GetLastError(),": OrderSend(",Symbol(),",OP_SELLSTOP,",DoubleToStr(DbsLot,2),
                           ",",DoubleToStr(DbsLoPrice,5),",",EasySlipPage,",0,0,..) failed at Close=",DoubleToStr(Close[0],5));
         break;
      case -2:  
         ticket = GhostOrderSend(Symbol(),OP_BUYSTOP,NormalizeDouble(DbsLot,2),DbsHiPrice,EasySlipPage,0,0,EaName,DbsMagic,0,EasyColorBuy);
         if(ticket<0)   Print(EaName,": Error: ", GetLastError(),": OrderSend(",Symbol(),",OP_BUYSTOP,",DoubleToStr(DbsLot,2),
                           ",",DoubleToStr(DbsHiPrice,5),",",EasySlipPage,",0,0,..) failed at Close=",DoubleToStr(Close[0],5));
         break;
   }
   return(0);
}

int DbsGetBuyTicket()
{
   int count=0;

//---- Assert determine count of all trades done with this MagicNumber
   for(int j=0;j<GhostOrdersTotal();j++)
   {
      GhostOrderSelect(j,SELECT_BY_POS,MODE_TRADES);

   //---- Assert MagicNumber and Symbol is same as Order
      if (GhostOrderType()==OP_BUY && GhostOrderMagicNumber()==DbsMagic && GhostOrderSymbol()==Symbol())
         return(GhostOrderTicket());
   }
   return(0);
}

int DbsGetSellTicket()
{
   int count=0;

//---- Assert determine count of all trades done with this MagicNumber
   for(int j=0;j<GhostOrdersTotal();j++)
   {
      GhostOrderSelect(j,SELECT_BY_POS,MODE_TRADES);

   //---- Assert MagicNumber and Symbol is same as Order
      if (GhostOrderType()==OP_SELL && GhostOrderMagicNumber()==DbsMagic && GhostOrderSymbol()==Symbol())
         return(GhostOrderTicket());
   }
   return(0);
}

int DbsTotalBuyStops()
{
   int count=0;

//---- Assert determine count of all trades done with this MagicNumber
   for(int j=0;j<GhostOrdersTotal();j++)
   {
      GhostOrderSelect(j,SELECT_BY_POS,MODE_TRADES);

   //---- Assert MagicNumber and Symbol is same as Order
      if (GhostOrderType()==OP_BUYSTOP && GhostOrderMagicNumber()==DbsMagic && GhostOrderSymbol()==Symbol())
         count++;
   }
   return(count);
}

int DbsTotalSellStops()
{
   int count=0;

//---- Assert determine count of all trades done with this MagicNumber
   for(int j=0;j<GhostOrdersTotal();j++)
   {
      GhostOrderSelect(j,SELECT_BY_POS,MODE_TRADES);

   //---- Assert MagicNumber and Symbol is same as Order
      if (GhostOrderType()==OP_SELLSTOP && GhostOrderMagicNumber()==DbsMagic && GhostOrderSymbol()==Symbol())
         count++;
   }
   return(count);
}

//|-----------------------------------------------------------------------------------------|
//|                                     C O M M E N T                                       |
//|-----------------------------------------------------------------------------------------|
string DbsComment(string cmt="")
{
   string strtmp = cmt+"-->"+EaName+" "+EaVer+"<--";

//---- Assert Basic settings in comment
   strtmp   =  strtmp+"\n    Lot="+DoubleToStr(DbsLot,2);
   strtmp   =  strtmp+"\n    LookBack="+DoubleToStr(DbsLookBackBar,0)+"  Ceiling="+DoubleToStr(DbsCeiling,0)+"  Floor="+DoubleToStr(DbsFloor,0);
//---- Assert internal variables in comment
   strtmp   =  strtmp+"\n    HiPrice="+DoubleToStr(DbsHiPrice,5)+"  LoPrice="+DoubleToStr(DbsLoPrice,5);
   strtmp   =  strtmp+"\n    UpBand="+DoubleToStr(DbsUpBand,5)+"  DnBand="+DoubleToStr(DbsDnBand,5);
   strtmp   =  strtmp+"\n    ExitPrice="+DoubleToStr(DbsExitPrice,5);
   strtmp   =  strtmp+"\n";
//---- Assert daisy chain comments
   strtmp   =  GhostComment(strtmp);
   
   strtmp = strtmp+"\n";
   return(strtmp);
}

//|------------------------------------------------------------------------------------------|
//|                       E N D   O F   E X P E R T   A D V I S O R                          |
//|------------------------------------------------------------------------------------------|

