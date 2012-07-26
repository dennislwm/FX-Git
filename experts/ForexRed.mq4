//|-----------------------------------------------------------------------------------------|
//|                                                                            ForexRed.mq4 |
//|                                                            Copyright © 2012, Dennis Lee |
//| Assert History                                                                          |
//| 1.11    Added parameter fifo to RedInit. If fifo is false, Magic2 is enabled and        |
//|            RedLoadBuffer executes on every tick. Works with PlusRed 1.16+.              |
//| 1.10    Added extern Fifo (default: true). If false, ForexRed will use Magic1 for sell  |
//|            trades and Magic2 for buy trades independently. Otherwise, it will use       |
//|            Magic1 and trades in ONE (1) direction only.                                 |
//| 1.02    Use global variable NewBar, i.e. USDCAD_M30_NewBar, to flag when a new value    |
//|            is available, as the NN results may be delayed by several ticks.             |
//| 1.01    Fixed EMPTY_VALUE returned from Custom indicators.                              |
//|            Valid TDSetup signal is either 4 or -4.                                      |
//| 1.00    Originated from RedAuto 1.00. This EA is a Martingale Swing EA that uses        |
//|            SharpeRSI_Ann to determine when to open. The Neural Net wave signal is then  |
//|            validated by looking for a similar TDSetup wave signal n bars back.          |
//|-----------------------------------------------------------------------------------------|
#property   copyright "Copyright © 2012, Dennis Lee"
#import "WinUser32.mqh"

#include <plusinit.mqh>
extern   int      Fred1Magic     = 11000;
extern   int      Fred2Magic     = 12000;
extern   bool     FredFifo       = true;
extern   int      FredDebug      = 1;
extern   int      FredDebugCount = 1000;
extern   string   s1             ="-->PlusRed Settings<--";
#include <plusred.mqh>
//---- Assert Basic externs
extern   string   s2             ="-->PlusEasy Settings<--";
#include <pluseasy.mqh>
//---- Assert PlusTurtle externs
extern   string   s3             ="-->PlusTurtle Settings<--";
#include <plusturtle.mqh>
//---- Assert PlusGhost externs
extern   string   s4             ="-->PlusGhost Settings<--";
#include <plusghost.mqh>


//|------------------------------------------------------------------------------------------|
//|                           I N T E R N A L   V A R I A B L E S                            |
//|------------------------------------------------------------------------------------------|
string   EaName   ="ForexRed";
string   EaVer    ="1.11";
int      EaDebugCount;

// ------------------------------------------------------------------------------------------|
//                             I N I T I A L I S A T I O N                                   |
// ------------------------------------------------------------------------------------------|
int init()
{
   InitInit();
   RedInit(EasySL,Fred1Magic,Fred2Magic,FredFifo);
   EasyInit();
   TurtleInit();
   GhostInit();
   return(0);    
}

bool isNewBar()
{
   if( nextBarTime == Time[0] )
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
   string strtmp, dbg;
   int wave,ticket;
   int period;

   RedOrderManager();
   GhostRefresh();
   Comment(EaComment());

//--- Assert there are NO opened trades.   
   int total1 = EasyOrdersBasket(Fred1Magic, Symbol());
   int total2 = EasyOrdersBasket(Fred2Magic, Symbol());
   int total = total1 + total2;

//--- Assert Fifo trades in one direction only.
   if( FredFifo ) 
   {
      if( total > 0 ) return(0);
   }
   else
   {
      if( total1 > 0 && total2 > 0 ) return(0);
   }
   EaDebugPrint( 2,"start",
      EaDebugInt("total",total),
      true, 0 );

   string gFredNewBarStr = StringConcatenate( Symbol(), "_", period, "_NewBar" );
   bool newBar = GlobalVariableGet( gFredNewBarStr );
   if( isNewBar() || newBar )
   {
   //--- Assert reset global boolean variable NewBar to false.
      GlobalVariableSet( gFredNewBarStr, FALSE );
      
   //--- Determine period based on Short or Long cycle.
      if( RedShortCycle ) period = RedShortPeriod;
      else period = RedLongPeriod;
   //--- Determine if a signal is generated.
      //int shWave = iCustom( Symbol(), period, "SharpeRSI_Ann", 12, 26, 9, 0, 1 );
      string gFredStr = StringConcatenate( Symbol(), "_", period );
      int shWave = GlobalVariableGet( gFredStr );
      EaDebugPrint( 2,"start",
         EaDebugStr("sym",Symbol())+
         EaDebugInt("period",period)+
         EaDebugInt("total",total)+
         EaDebugInt("shWave",shWave)+
         EaDebugBln(gFredNewBarStr,newBar),
         false, 1 );
      if( shWave == 0 || shWave == EMPTY_VALUE ) return(0);
      
   //--- Verify wave signal by checking TDSetup n bars back.
      int tdWave;
      int n=MathAbs(shWave)+1;
      
      for(int i=0; i<n; i++)
      {
         tdWave = iCustom( NULL, 0, "TDSetup", 3, 50, 0, i );
         EaDebugPrint( 2,"start",
            EaDebugInt("i",i)+
            EaDebugInt("tdWave",tdWave),
            false, 1 );
         Print(i,": tdWave=",tdWave," shWave=",shWave);
         if( tdWave!= EMPTY_VALUE && tdWave <= -4 && shWave < 0 ) 
         {
            wave = -1;
            break;
         }
         if( tdWave!= EMPTY_VALUE && tdWave >= 4 && shWave > 0 )
         {
            wave = 1;
            break;
         }
      }
      EaDebugPrint( 2,"start",
         EaDebugInt("n",n)+
         EaDebugInt("shWave",shWave)+
         EaDebugInt("tdWave",tdWave),
         false, 1 );
   }

//--- Assert Fifo has no trades opened
   if( !FredFifo )
   {
   //--- Always use Fred1Magic for sell and Fred2Magic for buy, if Fifo is false.
      if( total1 > 0 && wave > 0 ) return(0);
      if( total2 > 0 && wave < 0 ) return(0);
      
      if( wave == -1 ) wave = -2;
   }

   switch(wave)
   {
      case 1:  
         ticket = EasyOrderSell(Fred1Magic,Symbol(),RedBaseLot,EasySL,EasyTP,EaName+" "+Fred1Magic+" "+Symbol()+" "+Period(),EasyMaxAccountTrades);
         if(ticket>0) strtmp = EaName+": "+Fred1Magic+" "+Symbol()+" "+ticket+" sell at " + DoubleToStr(Close[0],Digits);   
         break;
      case -1: 
         ticket = EasyOrderBuy(Fred1Magic,Symbol(),RedBaseLot,EasySL,EasyTP,EaName+" "+Fred1Magic+" "+Symbol()+" "+Period(),EasyMaxAccountTrades); 
         if(ticket>0) strtmp = EaName+": "+Fred1Magic+" "+Symbol()+" "+ticket+" buy at " + DoubleToStr(Close[0],Digits);   
         break;
      case 2:  
         ticket = EasyOrderSell(Fred2Magic,Symbol(),RedBaseLot,EasySL,EasyTP,EaName+" "+Fred2Magic+" "+Symbol()+" "+Period(),EasyMaxAccountTrades);
         if(ticket>0) strtmp = EaName+": "+Fred2Magic+" "+Symbol()+" "+ticket+" sell at " + DoubleToStr(Close[0],Digits);   
         break;
      case -2:  
         ticket = EasyOrderBuy(Fred2Magic,Symbol(),RedBaseLot,EasySL,EasyTP,EaName+" "+Fred2Magic+" "+Symbol()+" "+Period(),EasyMaxAccountTrades);
         if(ticket>0) strtmp = EaName+": "+Fred2Magic+" "+Symbol()+" "+ticket+" buy at " + DoubleToStr(Close[0],Digits);   
         break;
   }
   if (wave!=0) Print(strtmp);
   
   return(0);
}

//|-----------------------------------------------------------------------------------------|
//|                                     C O M M E N T                                       |
//|-----------------------------------------------------------------------------------------|
string EaComment(string cmt="")
{
   string strtmp = cmt+"-->"+EaName+" "+EaVer+"<--";
//--- Assert Basic info in comment
   /*string strFifo;
   if( FredFifo ) strFifo = "true";
   else           strFifo = "false";
   strtmp=strtmp+"\n  Fifo="+strFifo;*/
   strtmp=strtmp+"\n";
   
//--- Assert additional comments here
   strtmp=RedComment(strtmp);
   double profit=EasyProfitsBasket(Fred1Magic,Symbol())+EasyProfitsBasket(Fred2Magic,Symbol());
   strtmp=EasyComment(profit,strtmp);
   strtmp=TurtleComment(strtmp);
   strtmp=GhostComment(strtmp);
   
   strtmp = strtmp+"\n";
   return(strtmp);
}
void EaDebugPrint(int dbg, string fn, string msg, bool incr=true, int mod=0)
{
   if(FredDebug>=dbg)
   {
      if(dbg>=2 && FredDebugCount>0)
      {
         if( MathMod(EaDebugCount,FredDebugCount) == mod )
            Print(FredDebug,"-",EaDebugCount,":",fn,"(): ",msg);
         if( incr )
            EaDebugCount ++;
      }
      else
         Print(FredDebug,":",fn,"(): ",msg);
   }
}
string EaDebugInt(string key, int val)
{
   return( StringConcatenate(";",key,"=",val) );
}
string EaDebugDbl(string key, double val, int dgt=5)
{
   return( StringConcatenate(";",key,"=",NormalizeDouble(val,dgt)) );
}
string EaDebugStr(string key, string val)
{
   return( StringConcatenate(";",key,"=\"",val,"\"") );
}
string EaDebugBln(string key, bool val)
{
   string valType;
   if( val )   valType="true";
   else        valType="false";
   return( StringConcatenate(";",key,"=",valType) );
}

//|------------------------------------------------------------------------------------------|
//|                       E N D   O F   E X P E R T   A D V I S O R                          |
//|------------------------------------------------------------------------------------------|