//|-----------------------------------------------------------------------------------------|
//|                                                                            ForexRed.mq4 |
//|                                                            Copyright © 2012, Dennis Lee |
//| Assert History                                                                          |
//| 1.1.3   Works with PlusTD 1.0.2, which has been unit tested.                            |
//| 1.1.2   Check if MagicNumber is returned correctly by broker. If not then set           |
//|            MaxAccountTrades=0 (disable the EA).                                         |
//|         Added function GetAccountOrdersTotal() to ensure total trades do not exceed.    |
//| 1.1.0   Added PlusTD to fix a MAJOR bug where the EA should NOT open trades when ANY    |
//|            of a pair of TDST lines is broken.                                           |
//| 1.0.7   Use GlobalVariableCheck() in function init(). If ANY of the FOUR (4) global     |
//|            variables do not exist, then set SmartExit=F.                                |
//| 1.0.6   Added extern SmartExit (default: F). If true, EA will closed ALL BUY basket, if |
//|            the pair of TDST Support lines are broken. Conversely, EA will closed ALL    |
//|            SELL basket, if the pair of TDST Resistance lines are broken.                |
//|         This version is compatible with TDSetup 1.2.3+ or greater.                      |
//| 1.0.5   Added wave +/- FIVE (5). This is compatible with TDSetup 1.2.0+.                |
//| 1.0.4   Added extern DebugNotify ( where Debug Level <= ONE (1) ) to notify user on     |
//|            mobile phone. There is a limit of no more than TWO (2) notifications per     |
//|            second, and no more than TEN (10) notifications per minute.                  |
//| 1.0.3   Added extern DoNotTrade: 0:false, 1:sell, -1:buy.                               |
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
//---- Assert Uni trade direction
extern   string   s0             = "DoNotTrade: 0:false, 1:sell, -1:buy";
extern   int      FredDoNotTrade = 0;
extern   bool     FredSmartExit  = false;
extern   bool     FredDebugNotify= false;
extern   int      FredDebug      = 1;
extern   int      FredDebugCount = 1000;
extern   string   s1             ="-->PlusTD Settings<--";
#include <plustd.mqh>
extern   string   s2             ="-->PlusRed Settings<--";
#include <plusred.mqh>
//---- Assert Basic externs
extern   string   s3             ="-->PlusEasy Settings<--";
#include <pluseasy.mqh>
//---- Assert PlusTurtle externs
extern   string   s4             ="-->PlusTurtle Settings<--";
#include <plusturtle.mqh>
//---- Assert PlusGhost externs
extern   string   s5             ="-->PlusGhost Settings<--";
#include <plusghost.mqh>

//|------------------------------------------------------------------------------------------|
//|                           I N T E R N A L   V A R I A B L E S                            |
//|------------------------------------------------------------------------------------------|
string   EaName      ="ForexRed";
string   EaVer       ="1.1.3";
int      EaDebugCount;

//|------------------------------------------------------------------------------------------|
//|                            I N I T I A L I S A T I O N                                   |
//|------------------------------------------------------------------------------------------|
int init()
{
   InitInit();
   TDInit();
   RedInit(EasySL,Fred1Magic,Fred2Magic);
   EasyInit();
   TurtleInit();
   GhostInit();
//--- Assert SmartExit true checks for existing global vars
   if( FredSmartExit )
   {
      if( !TDGlobalCheck() )
      {
         FredSmartExit = false;
         EaDebugPrint( 0, "init",
            EaDebugStr("EaName",EaName)+
            EaDebugStr("EaVer",EaVer)+
            EaDebugInt("mgc",Fred1Magic)+
            EaDebugStr("sym",Symbol())+
            " At least ONE of FOUR (4) global variables do not exist. Set SmartExit=False.",
            false, 0 );
      }
   }
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
   int total=EasyOrdersBasket(Fred1Magic, Symbol());
   if( total > 0 ) 
   {
   //--- Assert SmartExit means that EA will not check for exit condition (SL will be used instead).
      if(!FredSmartExit) return(0);
      
      if( EasyOrdersSellBasket(Fred1Magic, Symbol()) > 0 )
      {
      //--- Check SmartExit condition (default: exit condition fails)
      //--- Assert check exit condition for SELL basket
         if( TDGetUpBln(1) == false && TDGetUpBln(2) == false )
         {
            EasyBuyToCloseBasket( Fred1Magic, Symbol(), EasyMaxAccountTrades );
            EaDebugPrint(0, "start",
               EaDebugStr("EaName",EaName)+
               EaDebugStr("EaVer",EaVer)+
               EaDebugInt("mgc",Fred1Magic)+
               EaDebugStr("sym",Symbol())+
               EaDebugDbl("price",MarketInfo(Symbol(),MODE_ASK))+
               " SmartExit closed ALL SELL basket.",
               false, 0);
         }
      }
      else if( EasyOrdersBuyBasket(Fred1Magic, Symbol()) > 0 )
      {
      //--- Check SmartExit condition (default: exit condition fails)
      //--- Assert check exit condition for BUY basket
         if( TDGetDnBln(1) == false && TDGetDnBln(2) == false )
         {
            EasySellToCloseBasket( Fred1Magic, Symbol(), EasyMaxAccountTrades );
            EaDebugPrint(0, "start",
               EaDebugStr("EaName",EaName)+
               EaDebugStr("EaVer",EaVer)+
               EaDebugInt("mgc",Fred1Magic)+
               EaDebugStr("sym",Symbol())+
               EaDebugDbl("price",MarketInfo(Symbol(),MODE_BID))+
               " SmartExit closed ALL BUY basket.",
               false, 0);
         }
      }
   //--- Assert if there are ANY trades opened, that means exit condition failed.
      total=EasyOrdersBasket(Fred1Magic, Symbol());
      if(total>0) return(0);
   }

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
         if( tdWave!= EMPTY_VALUE && tdWave <= -5 && shWave < 0 ) 
         {
            if( TDWave1Buy() )   
            {
               wave = -1;
               EaDebugPrint(0, "start",
                  TDDebugGlobal()+
                  EaDebugBln("TDWave1Buy",true) );
            }
            else                 
               wave = 0;
            break;
         }
         if( tdWave!= EMPTY_VALUE && tdWave >= 5 && shWave > 0 )
         {
            if( TDWave1Sell() )  
            {
               wave = 1;
               EaDebugPrint(0, "start",
                  TDDebugGlobal()+
                  EaDebugBln("TDWave1Sell",true) );
            }
            else
               wave = 0;
            break;
         }
      }
      EaDebugPrint( 2,"start",
         EaDebugInt("n",n)+
         EaDebugInt("shWave",shWave)+
         EaDebugInt("tdWave",tdWave),
         false, 1 );
   }

//--- Assert uni trade direction
   if( FredDoNotTrade>0 && wave>0 ) 
      wave = 0;
   if( FredDoNotTrade<0 && wave<0 )
      wave = 0;

//--- Assert max account trades
   if( GetAccountOrdersTotal() >= EasyMaxAccountTrades )
   {
      EaDebugPrint( 1, "start",
         EaDebugStr("EaName", EaName)+
         EaDebugStr("EaVer", EaVer)+
         EaDebugStr("sym", Symbol())+
         EaDebugInt("mgc", Fred1Magic)+
         EaDebugInt("wave_old", wave)+
         EaDebugInt("wave_new", 0)+
         " Maximum account trades = "+
         EaDebugInt("EasyMaxAccountTrades", EasyMaxAccountTrades)+
         " has been exceeded.");
      wave = 0;
   }
      
   switch(wave)
   {
      case 1:  
         ticket = EasyOrderSell(Fred1Magic,Symbol(),RedBaseLot,EasySL,EasyTP,EaName,EasyMaxAccountTrades);
         if(ticket>0) 
            strtmp = EaName+": "+Fred1Magic+" "+Symbol()+" Open "+ticket+" sell at " + DoubleToStr(Close[0],Digits);   
         break;
      case -1: 
         ticket = EasyOrderBuy(Fred1Magic,Symbol(),RedBaseLot,EasySL,EasyTP,EaName,EasyMaxAccountTrades); 
         if(ticket>0) strtmp = EaName+": "+Fred1Magic+" "+Symbol()+" Open "+ticket+" buy at " + DoubleToStr(Close[0],Digits);   
         break;
      case 2:  
         ticket = EasyOrderSell(Fred2Magic,Symbol(),RedBaseLot,EasySL,EasyTP,EaName,EasyMaxAccountTrades);
         if(ticket>0) strtmp = EaName+": "+Fred2Magic+" "+Symbol()+" Open "+ticket+" sell at " + DoubleToStr(Close[0],Digits);   
         break;
      case -2:  
         ticket = EasyOrderBuy(Fred2Magic,Symbol(),RedBaseLot,EasySL,EasyTP,EaName,EasyMaxAccountTrades);
         if(ticket>0) strtmp = EaName+": "+Fred2Magic+" "+Symbol()+" Open "+ticket+" buy at " + DoubleToStr(Close[0],Digits);   
         break;
   }
   if (wave!=0) 
   {
      EaDebugPrint( 0, "start", strtmp );
   
      if (ticket > 0) 
      {
      //--- Assert 1: Init OrderSelect #2
         GhostInitSelect(true,ticket,SELECT_BY_TICKET,MODE_TRADES);
         if( GhostOrderSelect(ticket, SELECT_BY_TICKET, MODE_TRADES) ) 
         {
         //--- Check if Magic is set correctly by broker
            if( GhostOrderMagicNumber() == Fred1Magic || GhostOrderMagicNumber() == Fred2Magic)
            {}
            else
            {
               EaDebugPrint( 0, "start",
                  EaDebugStr("EaName", EaName)+
                  EaDebugStr("EaVer", EaVer)+
                  EaDebugStr("sym", Symbol())+
                  EaDebugInt("period", Period())+
                  EaDebugInt("mgc", GhostOrderMagicNumber())+
                  EaDebugInt("ticket", ticket)+
                  EaDebugInt("type", GhostOrderType())+
                  EaDebugDbl("lot", GhostOrderLots())+
                  EaDebugDbl("openPrice", GhostOrderOpenPrice())+
                  " Magic number not returned by broker. Set MaxAccountTrades=0." );
               EasyMaxAccountTrades=0;
            }
         }
      //--- Assert 1: Free OrderSelect #2
         GhostFreeSelect(false);
      }
   }
   
   return(0);
}

double GetAccountOrdersTotal() 
{
   int ret;
//--- Assert 2: Init OrderSelect #13
   int total = GhostOrdersTotal();
   GhostInitSelect(true,0,SELECT_BY_POS,MODE_TRADES);
   for( int pos = 0; pos <= total - 1; pos++ ) 
   {
      if( GhostOrderSelect(pos, SELECT_BY_POS, MODE_TRADES) )
      {
      //--- Count ALL trades in account
      //       For ALL symbols
      //       For ALL magic / non-magic numbers
      //       For ALL opened trades
      //       Exclude pending orders
      //       Exclude historical orders
         if (GhostOrderType() <= OP_SELL) ret ++;
      }
   }
//--- Assert 1: Free OrderSelect #13
   GhostFreeSelect(false);
   return (ret);
}

//|-----------------------------------------------------------------------------------------|
//|                                     C O M M E N T                                       |
//|-----------------------------------------------------------------------------------------|
string EaComment(string cmt="")
{
   string strtmp = cmt+"-->"+EaName+" "+EaVer+"<--";
   strtmp=strtmp+"\n";

//--- Assert uni trade direction
   if( FredDoNotTrade>0 )
      strtmp = strtmp + "  Do Not Trade Sell\n";
   if( FredDoNotTrade<0 )
      strtmp = strtmp + "  Do Not Trade Buy\n";
   if( FredSmartExit )
      strtmp = strtmp + "  SmartExit Enabled.\n";
   
//--- Assert additional comments here
   strtmp=TDComment(strtmp);
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
      {
         if(FredDebugNotify)  SendNotification( FredDebug + ":" + fn + "(): " + msg );
         Print(FredDebug,":",fn,"(): ",msg);
      }
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