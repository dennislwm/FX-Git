//|-----------------------------------------------------------------------------------------|
//|                                                                             PlusRed.mqh |
//|                                                            Copyright © 2012, Dennis Lee |
//| Assert History                                                                          |
//| 1.00    The PlusRed module is a martingale strategy comprising TWO baskets.             |
//|            The RedOrderManager() places subsequent orders for both baskets.             |
//|            Note that the first order is never placed by this module.                    |
//|            Created functions Init, LoadBuffer, ChildOrderSend, CycleGap, and Comment.   |
//|-----------------------------------------------------------------------------------------|
#property   copyright "Copyright © 2012, Dennis Lee"

//|-----------------------------------------------------------------------------------------|
//|                           E X T E R N A L   V A R I A B L E S                           |
//|-----------------------------------------------------------------------------------------|
extern   double   RedBaseLot     =0.01;
extern   string   red_1          =" Mode 0-Use 1x only; BasketLevel <= 12";
extern   string   red_2          =" 1-Envy: 1,1,2,3,5,9,17,33,65,127,245,466";
extern   string   red_3          =" 2-Fibo: 1,1,2,3,5,8,13,21,34,55,89,144";
extern   int      RedMode        =0;
extern   int      RedBasketLevel =1;
extern   bool     RedShortCycle  =false;
extern   int      RedDebug       =1;
extern   int      RedDebugCount  =1000;

//|-----------------------------------------------------------------------------------------|
//|                           I N T E R N A L   V A R I A B L E S                           |
//|-----------------------------------------------------------------------------------------|
string   RedName="PlusAnn";
string   RedVer="1.00";
//--- Assert variables for Basic
double   redSL;
double   redTP;
int      red1Magic;
int      red2Magic;
//--- Assert variables for Buffer
int      redTicket[];
int      redType[];
double   redLots[];
double   redOpenPrice[];
double   redStopLoss[];
double   redTakeProfit[];
double   redProfit[];
string   redComment[];

//--- Assert variables for Martingale Mode
int      redMultiplier[];
//--- Assert variables to detect new bar
int      nextBarTime;
//--- Assert variables for cycle gaps
int      redCyclePip;
double   redBaseOpenPrice;
//--- Assert variables for debug
int      RedCount;

//|-----------------------------------------------------------------------------------------|
//|                             I N I T I A L I Z A T I O N                                 |
//|-----------------------------------------------------------------------------------------|
void RedInit(double SL, double TP, int mgc1, int mgc2)
{
//-- Assert Excel or SQL files are created.
//--- Assert Mode <= 2 and BasketLevel <= 12
   if( RedMode < 0 || RedMode > 2 )
   {
      Print("RedInit: Mode=",RedMode," is invalid. Set Mode=0");
      RedMode = 0;
   }
   if( RedBasketLevel > 12 )
   {
      Print("RedInit: BasketLevel exceeded maximum of 12. Set BasketLevel=12");
      RedBasketLevel = 12;
   }
//--- Initialize arrays
   ArrayResize(redMultiplier, 12);
//--- Populate arrays
//       0-Disabled: 1x for all levels
//       1-Envy: 1,1,2,3,5,9,17,33,65,127,245,466
//       2-Fibo: 1,1,2,3,5,8,13,21,34,55,89,144
   switch( RedMode )
   {
      case 0:
         for(int i=0; i<12; i++)
         {
            redMultiplier[i]=1;
         }
         break;
      case 1:
         redMultiplier[0]=1;
         redMultiplier[1]=1;
         redMultiplier[2]=2;
         redMultiplier[3]=3;
         redMultiplier[4]=5;
         redMultiplier[5]=9;
         redMultiplier[6]=17;
         redMultiplier[7]=33;
         redMultiplier[8]=65;
         redMultiplier[9]=127;
         redMultiplier[10]=245;
         redMultiplier[11]=466;
         break;
      case 2:
         redMultiplier[0]=1;
         redMultiplier[1]=1;
         redMultiplier[2]=2;
         redMultiplier[3]=3;
         redMultiplier[4]=5;
         redMultiplier[5]=8;
         redMultiplier[6]=13;
         redMultiplier[7]=21;
         redMultiplier[8]=34;
         redMultiplier[9]=55;
         redMultiplier[10]=89;
         redMultiplier[11]=144;
         break;
   }
//--- Initialize cycle gaps
   if( RedShortCycle )
      redCyclePip = RedCycleGap(60,Symbol(),PERIOD_H1);
   else
      redCyclePip = RedCycleGap(60,Symbol(),PERIOD_D1);
//--- Initialize stop loss and take profit
   if( SL < redCyclePip * 2 )
   {
      redSL = redCyclePip * 2;
      Print("RedInit: SL is less than 2x CyclePip=",DoubleToStr(redCyclePip,0),". Set redSL=",DoubleToStr(redSL,0));
   }
   redTP = TP;
   red1Magic = mgc1;
   red2Magic = mgc2;
}

//|-----------------------------------------------------------------------------------------|
//|                               M A I N   P R O C E D U R E                               |
//|-----------------------------------------------------------------------------------------|
void RedOrderManager()
{
}

//|-----------------------------------------------------------------------------------------|
//|                                 O R D E R   B U F F E R                                 |
//|-----------------------------------------------------------------------------------------|
int RedLoadBuffer(int mgc, string sym)
{
   int total=EasyOrdersBasket(mgc,sym);
//--- Assert 7: Dynamically resize arrays for OrderSelect #1
   ArrayResize(redTicket,     total);
   ArrayResize(redType,       total);
   ArrayResize(redLots,       total);
   ArrayResize(redOpenPrice,  total);
   ArrayResize(redStopLoss,   total);
   ArrayResize(redTakeProfit, total);
   ArrayResize(redProfit,     total);
   ArrayResize(redComment,    total);
   
//--- Assert 1: Init OrderSelect #1
   GhostInitSelect(true,0,SELECT_BY_POS,MODE_TRADES);
   for(int j=0; j<total; j++)
   {
   //--- Assert 7: Populate arrays for OrderSelect #1
      redTicket[j]      =  GhostOrderTicket();
      redType[j]        =  GhostOrderType();
      redLots[j]        =  GhostOrderLots();
      redOpenPrice[j]   =  GhostOrderOpenPrice();
      redStopLoss[j]    =  GhostOrderStopLoss();
      redTakeProfit[j]  =  GhostOrderTakeProfit();
      redProfit[j]      =  GhostOrderProfit();
      redComment[j]     =  GhostOrderComment();
   }
//--- Assert 1: Free OrderSelect #1
   GhostFreeSelect(false);
   
   return(total);
}

//+-----------------------------------------------------------------------------------------|
//|                             O P E N   C H I L D   T R A D E S                           |
//+-----------------------------------------------------------------------------------------|
int RedChildOrderSend(int mgc, string sym, double SL, double TP, int maxTrades, int maxSpread)
{
   int ticket=-1;
   int total=RedLoadBuffer(mgc,sym);
   int beg=0, end=total-1;
   int newLevel=total;
//--- Assert optimize function check total > 0
   if( total <= 0 ) return(-1);
//--- Assert copy values to child order   
   int      childType;
   double   childLots;
   double   childOpenPrice;
   double   childStopLoss;
   double   childTakeProfit;
   string   childComment;
   double   curPrice;
//--- Assert populate values for child order
   childType         = redType[beg];
   childLots         = redLots[beg] * redMultiplier[newLevel];
   if( childType == OP_BUY )
   {
      curPrice = MarketInfo( sym, MODE_ASK );
      childOpenPrice = redOpenPrice[end] - ( redCyclePip * InitPts );
      if (SL!=0) childStopLoss=NormalizeDouble(childOpenPrice-SL*InitPts,Digits);
      childComment   = redComment[end];
      if( curPrice <= childOpenPrice )
         ticket=EasyOrderBuy( mgc, sym, childLots, childStopLoss, childTakeProfit, childComment, maxTrades, maxSpread );
   }
   if( childType == OP_SELL )
   {
      curPrice = MarketInfo( sym, MODE_BID );
      childOpenPrice = redOpenPrice[end] + ( redCyclePip * InitPts );
      if (SL!=0) childStopLoss=NormalizeDouble(childOpenPrice+SL*InitPts,Digits);
      if( curPrice >= childOpenPrice)
         ticket=EasyOrderBuy( mgc, sym, childLots, childStopLoss, childTakeProfit, childComment, maxTrades, maxSpread );
   }
   return(ticket);
}

//|-----------------------------------------------------------------------------------------|
//|                             D E I N I T I A L I Z A T I O N                             |
//|-----------------------------------------------------------------------------------------|
void RedDeInit()
{
//-- Assert Excel or SQL files are saved.
}

//|-----------------------------------------------------------------------------------------|
//|                                     C O M M E N T                                       |
//|-----------------------------------------------------------------------------------------|
string RedComment(string cmt="", string basket1="Basket1", string basket2="Basket2")
{
   int i, total;
   
   string strtmp = cmt+"  -->"+RedName+" "+RedVer+"<--";

//--- Assert Mode info in comment
   strtmp=strtmp+"\n    BaseLot="+DoubleToStr(RedBaseLot,2)+"  BasketLevel="+DoubleToStr(RedBasketLevel,0);
   strtmp=strtmp+"\n    Mode="+DoubleToStr(RedMode,0);
   switch( RedMode )
   {
      case 0:
         strtmp=strtmp+" (Use 1x only)";
         break;
      case 1:
         strtmp=strtmp+" (Envy)";
         break;
      case 2:
         strtmp=strtmp+" (Fibo)";
         break;
   }
//--- Assert Cycle info in comment
   if( RedShortCycle )
      strtmp=strtmp+"  ShortCycle";
   else
      strtmp=strtmp+"  LongCycle";
   strtmp=strtmp+" (Pip="+DoubleToStr(redCyclePip,0)+")";
//--- Assert Basket info in comment
   int total1Magic = EasyOrdersBasket(red1Magic,Symbol());
   if( total1Magic >= RedBasketLevel )
      strtmp=strtmp+"\n    "+basket1+": Basket Level reached.";
   else
   {
      strtmp=strtmp+"\n    "+basket1+": Expected orders:";
      for(i=total1Magic; i<RedBasketLevel; i++)
      {
         strtmp=strtmp+"\n      "+DoubleToStr(i+1,0)+": lots="+DoubleToStr( RedBaseLot * redMultiplier[i], 2 );
      }
   }
   int total2Magic = EasyOrdersBasket(red2Magic,Symbol());
   if( total2Magic >= RedBasketLevel )
      strtmp=strtmp+"\n    "+basket2+": Basket Level reached.";
   else
   {
      strtmp=strtmp+"\n    "+basket2+": Expected orders:";
      for(i=total2Magic; i<RedBasketLevel; i++)
      {
         strtmp=strtmp+"\n      "+DoubleToStr(i+1,0)+": lots="+DoubleToStr( RedBaseLot * redMultiplier[i], 2 );
      }
   }
                         
   strtmp=strtmp+"\n";
   return(strtmp);
}

void RedDebugPrint(int dbg, string fn, string msg, bool incr=true, int mod=0)
{
   if(RedDebug>=dbg)
   {
      if(dbg>=2 && RedDebugCount>0)
      {
         if( MathMod(RedCount,RedDebugCount) == mod )
            Print(RedDebug,"-",RedCount,":",fn,"(): ",msg);
         if( incr )
            RedCount ++;
      }
      else
         Print(RedDebug,":",fn,"(): ",msg);
   }
}
string RedDebugInt(string key, int val)
{
   return( StringConcatenate(";",key,"=",val) );
}
string RedDebugDbl(string key, double val, int dgt=5)
{
   return( StringConcatenate(";",key,"=",NormalizeDouble(val,dgt)) );
}
string RedDebugStr(string key, string val)
{
   return( StringConcatenate(";",key,"=\"",val,"\"") );
}
string RedDebugBln(string key, bool val)
{
   string valType;
   if( val )   valType="true";
   else        valType="false";
   return( StringConcatenate(";",key,"=",valType) );
}

//|-----------------------------------------------------------------------------------------|
//|                           I N T E R N A L   F U N C T I O N S                           |
//|-----------------------------------------------------------------------------------------|
int RedCycleGap(int n, string sym, int period)
{
   double range, maxRange;
   for(int i=0; i<n; i++)
   {
      range = iHigh(sym,period,i) - iLow(sym,period,i);
      if( range > maxRange ) maxRange = range;
   }
   return( MathRound( maxRange/InitPts ) * InitPip );
}

//|-----------------------------------------------------------------------------------------|
//|                       E N D   O F   E X P E R T   A D V I S O R                         |
//|-----------------------------------------------------------------------------------------|

