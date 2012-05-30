//|-----------------------------------------------------------------------------------------|
//|                                                                            ForexRed.mq4 |
//|                                                            Copyright © 2012, Dennis Lee |
//| Assert History                                                                          |
//| 1.00    Originated from RedAuto 1.00. This EA is a Martingale Swing EA that uses        |
//|            SharpeRSI_Ann to determine when to open. The Neural Net wave signal is then  |
//|            validated by looking for a similar TDSetup wave signal n bars back.          |
//|-----------------------------------------------------------------------------------------|
#property   copyright "Copyright © 2012, Dennis Lee"
#import "WinUser32.mqh"

#include <plusinit.mqh>
extern   int      Fred1Magic     = 11000;
extern   int      Fred2Magic     = 12000;
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
string   EaVer    ="1.00";

// ------------------------------------------------------------------------------------------|
//                             I N I T I A L I S A T I O N                                   |
// ------------------------------------------------------------------------------------------|
int init()
{
   InitInit();
   RedInit(EasySL,Fred1Magic,Fred2Magic);
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
   string strtmp;
   int wave,ticket;
   int period;

   RedOrderManager();
   GhostRefresh();
   Comment(EaComment());

//--- Assert there are NO opened trades.   
   int total=GhostOrdersTotal();
   if( total > 0 ) return(0);

   if( isNewBar() )
   {
   //--- Determine period based on Short or Long cycle.
      if( RedShortCycle ) period = RedShortPeriod;
      else period = RedLongPeriod;
   //--- Determine if a signal is generated.
      int shWave = iCustom( NULL, period, "SharpeRSI_Ann", 12, 26, 9, 0, 0 );
      if( shWave == 0 ) return(0);
      
   //--- Verify wave signal by checking TDSetup n bars back.
      int tdWave;
      int n=MathAbs(shWave);
      
      for(int i=0; i<n; i++)
      {
         tdWave = iCustom( NULL, period, "TDSetup", 5, 30, 0, i );
         if( tdWave < 0 && shWave < 0 ) 
         {
            wave = -1;
            break;
         }
         if( tdWave > 0 && shWave > 0 )
         {
            wave = 1;
            break;
         }
      }
   }

   switch(wave)
   {
      case 1:  
         ticket = EasyOrderSell(Fred1Magic,Symbol(),RedBaseLot,EasySL,EasyTP,EaName,EasyMaxAccountTrades);
         if(ticket>0) strtmp = EaName+": "+Fred1Magic+" "+Symbol()+" "+ticket+" sell at " + DoubleToStr(Close[0],Digits);   
         break;
      case -1: 
         ticket = EasyOrderBuy(Fred1Magic,Symbol(),RedBaseLot,EasySL,EasyTP,EaName,EasyMaxAccountTrades); 
         if(ticket>0) strtmp = EaName+": "+Fred1Magic+" "+Symbol()+" "+ticket+" buy at " + DoubleToStr(Close[0],Digits);   
         break;
      case 2:  
         ticket = EasyOrderSell(Fred2Magic,Symbol(),RedBaseLot,EasySL,EasyTP,EaName,EasyMaxAccountTrades);
         if(ticket>0) strtmp = EaName+": "+Fred2Magic+" "+Symbol()+" "+ticket+" sell at " + DoubleToStr(Close[0],Digits);   
         break;
      case -2:  
         ticket = EasyOrderBuy(Fred2Magic,Symbol(),RedBaseLot,EasySL,EasyTP,EaName,EasyMaxAccountTrades);
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

//|------------------------------------------------------------------------------------------|
//|                       E N D   O F   E X P E R T   A D V I S O R                          |
//|------------------------------------------------------------------------------------------|

