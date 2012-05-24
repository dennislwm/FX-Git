//|-----------------------------------------------------------------------------------------|
//|                                                                             RedAuto.mq4 |
//|                                                            Copyright © 2012, Dennis Lee |
//| Assert History                                                                          |
//| 1.00    Originated from TrendAuto 1.23 incorporating PlusRed.mqh with fixed TP.         |
//|-----------------------------------------------------------------------------------------|
#property   copyright "Copyright © 2012, Dennis Lee"
#import "WinUser32.mqh"

#include <plusinit.mqh>
extern   string   s1             ="-->PlusRed Settings<--";
#include <plusred.mqh>
//---- Assert Basic externs
extern   string   s2             ="-->PlusEasy Settings<--";
#include <pluseasy.mqh>
//---- Assert PlusSwiss externs
extern   string   s3             ="-->PlusSwiss Settings<--";
#include <plusswiss.mqh>
//---- Assert PlusLinex externs
extern   string   s4             ="-->PlusLinex Settings<--";
#include <pluslinex.mqh>
//---- Assert PlusTurtle externs
extern   string   s5             ="-->PlusTurtle Settings<--";
#include <plusturtle.mqh>
//---- Assert PlusGhost externs
extern   string   s6             ="-->PlusGhost Settings<--";
#include <plusghost.mqh>


//|------------------------------------------------------------------------------------------|
//|                           I N T E R N A L   V A R I A B L E S                            |
//|------------------------------------------------------------------------------------------|
string   EaName   ="RedAuto";
string   EaVer    ="1.00";

// ------------------------------------------------------------------------------------------|
//                             I N I T I A L I S A T I O N                                   |
// ------------------------------------------------------------------------------------------|
int init()
{
   InitInit();
   RedInit(EasySL,Linex1Magic,Linex2Magic);
   EasyInit();
   SwissInit(Linex1Magic,Linex2Magic);
   LinexInit();
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

//--- Assert PlusSwiss.mqh
   /*if (EasyOrdersMagic(Linex1Magic)>0)
   {
      SwissManager(Linex1Magic,Symbol(),Pts);
   }
   if (EasyOrdersMagic(Linex2Magic)>0)
   {
      SwissManager(Linex2Magic,Symbol(),Pts);
   }
   SwissTargetLinex(Pts);*/

   RedOrderManager();
   GhostRefresh();
   wave=Linex(Pts);
   switch(wave)
   {
      case 1:  
         ticket = EasyOrderSell(Linex1Magic,Symbol(),RedBaseLot,EasySL,EasyTP,PlusName,EasyMaxAccountTrades);
         if(ticket>0) strtmp = "EasySell: "+Linex1+" "+Linex1Magic+" "+Symbol()+" "+ticket+" sell at " + DoubleToStr(Close[0],Digits);   
         break;
      case -1: 
         ticket = EasyOrderBuy(Linex1Magic,Symbol(),RedBaseLot,EasySL,EasyTP,PlusName,EasyMaxAccountTrades); 
         if(ticket>0) strtmp = "EasyBuy: "+Linex1+" "+Linex1Magic+" "+Symbol()+" "+ticket+" buy at " + DoubleToStr(Close[0],Digits);   
         break;
      case 2:  
         ticket = EasyOrderSell(Linex2Magic,Symbol(),RedBaseLot,EasySL,EasyTP,PlusName,EasyMaxAccountTrades);
         if(ticket>0) strtmp = "EasySell: "+Linex2+" "+Linex2Magic+" "+Symbol()+" "+ticket+" sell at " + DoubleToStr(Close[0],Digits);   
         break;
      case -2:  
         ticket = EasyOrderBuy(Linex2Magic,Symbol(),RedBaseLot,EasySL,EasyTP,PlusName,EasyMaxAccountTrades);
         if(ticket>0) strtmp = "EasyBuy: "+Linex2+" "+Linex2Magic+" "+Symbol()+" "+ticket+" buy at " + DoubleToStr(Close[0],Digits);   
         break;
   }
   if (wave!=0) Print(strtmp);

   Comment(EaComment());
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
   double profit=EasyProfitsBasket(Linex1Magic,Symbol())+EasyProfitsBasket(Linex2Magic,Symbol());
   strtmp=EasyComment(profit,strtmp);
   strtmp=SwissComment(strtmp);
   strtmp=LinexComment(strtmp);
   strtmp=GhostComment(strtmp);
   
   strtmp = strtmp+"\n";
   return(strtmp);
}

//|------------------------------------------------------------------------------------------|
//|                       E N D   O F   E X P E R T   A D V I S O R                          |
//|------------------------------------------------------------------------------------------|

