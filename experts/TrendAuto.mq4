//|-----------------------------------------------------------------------------------------|
//|                                                                           TrendAuto.mq4 |
//|                                                            Copyright © 2011, Dennis Lee |
//| Assert History                                                                          |
//| 1.23    Updated with Swiss target profit lines.                                         |
//|         Note this version can be used in conjunction with a custom indicator.           |
//|         E.g. ForexGrowthBot.                                                            |
//| 1.22    Updated with Swiss Parabolic SAR.                                               |
//| 1.21    Added PlusSwiss.mqh.                                                            |
//| 1.11    Changed Lot from internal to extern.                                            |
//|         Added LinexInit().                                                              |
//| 1.10    First EA to open pending orders using trendlines.                               |
//| 1.00    Added PlusLinex.mqh                                                             |
//|         Added PlusEasy.mqh                                                              |
//|-----------------------------------------------------------------------------------------|
#property   copyright "Copyright © 2011, Dennis Lee"
#import "WinUser32.mqh"

//---- Assert Basic externs
extern string s1="-->PlusEasy Settings<--";
#include <pluseasy.mqh>
extern double EasyLot=0.1;
//---- Assert PlusSwiss externs
extern string s2="-->PlusSwiss Settings<--";
#include <plusswiss.mqh>
//---- Assert PlusLinex externs
extern string s3="-->PlusLinex Settings<--";
#include <pluslinex.mqh>
//---- Assert Extra externs
extern string s4="-->Extra Settings<--";
extern int TrendDebug=0;

//|------------------------------------------------------------------------------------------|
//|                           I N T E R N A L   V A R I A B L E S                            |
//|------------------------------------------------------------------------------------------|
string   TrendName="TrendAuto";
string   TrendVer="1.23";

// ------------------------------------------------------------------------------------------|
//                             I N I T I A L I S A T I O N                                   |
// ------------------------------------------------------------------------------------------|

int init()
{
   EasyInit();
   SwissInit(Linex1Magic,Linex2Magic);
   LinexInit();
   return(0);    
}


//|------------------------------------------------------------------------------------------|
//|                            D E - I N I T I A L I S A T I O N                             |
//|------------------------------------------------------------------------------------------|

int deinit()
{
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
   if (EasyOrdersMagic(Linex1Magic)>0)
   {
      SwissManager(Linex1Magic,Symbol(),Pts);
   }
   if (EasyOrdersMagic(Linex2Magic)>0)
   {
      SwissManager(Linex2Magic,Symbol(),Pts);
   }
   SwissTargetLinex(Pts);

   wave=Linex(Pts);
   switch(wave)
   {
      case 1:  
         ticket = EasySell(Linex1Magic,EasyLot);
         if(ticket>0) strtmp = "EasySell: "+Linex1+" "+Linex1Magic+" "+Symbol()+" "+ticket+" sell at " + DoubleToStr(Close[0],Digits);   
         break;
      case -1: 
         ticket = EasyBuy(Linex1Magic,EasyLot); 
         if(ticket>0) strtmp = "EasyBuy: "+Linex1+" "+Linex1Magic+" "+Symbol()+" "+ticket+" buy at " + DoubleToStr(Close[0],Digits);   
         break;
      case 2:  
         ticket = EasySell(Linex2Magic,EasyLot);
         if(ticket>0) strtmp = "EasySell: "+Linex2+" "+Linex2Magic+" "+Symbol()+" "+ticket+" sell at " + DoubleToStr(Close[0],Digits);   
         break;
      case -2:  
         ticket = EasyBuy(Linex2Magic,EasyLot);
         if(ticket>0) strtmp = "EasyBuy: "+Linex2+" "+Linex2Magic+" "+Symbol()+" "+ticket+" buy at " + DoubleToStr(Close[0],Digits);   
         break;
   }
   if (wave!=0) Print(strtmp);

   Comment(TrendComment());
   return(0);
}

//|-----------------------------------------------------------------------------------------|
//|                                     C O M M E N T                                       |
//|-----------------------------------------------------------------------------------------|
string TrendComment(string cmt="")
{
   string strtmp = cmt+"-->"+TrendName+" "+TrendVer+"<--\n";

//--- Assert additional comments here
   double profit=EasyProfitsMagic(Linex1Magic)+EasyProfitsMagic(Linex2Magic);
   strtmp=EasyComment(profit,strtmp);
   strtmp=StringConcatenate(strtmp,"    Lot=",DoubleToStr(EasyLot,2),"\n");
   strtmp=SwissComment(strtmp);
   strtmp=LinexComment(strtmp);
   
   strtmp = strtmp+"\n";
   return(strtmp);
}

//|------------------------------------------------------------------------------------------|
//|                       E N D   O F   E X P E R T   A D V I S O R                          |
//|------------------------------------------------------------------------------------------|

