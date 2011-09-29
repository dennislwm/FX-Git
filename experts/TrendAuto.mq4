//|-----------------------------------------------------------------------------------------|
//|                                                                           TrendAuto.mq4 |
//|                                                            Copyright © 2011, Dennis Lee |
//| Assert History                                                                          |
//| 1.10    First EA to open pending orders using trendlines.                               |
//| 1.00    Added PlusLinex.mqh                                                             |
//|         Added PlusEasy.mqh                                                              |
//|-----------------------------------------------------------------------------------------|
#property   copyright "Copyright © 2011, Dennis Lee"
#import "WinUser32.mqh"

//---- Assert Basic externs
extern string s1="-->PlusEasy Settings<--";
#include <pluseasy.mqh>
//---- Assert PlusLinex externs
extern string s2="-->PlusLinex Settings<--";
#include <pluslinex.mqh>
//---- Assert Extra externs
extern string s3="-->Extra Settings<--";
extern string TradeComment="-->TrendAuto v1.10<--";
extern int Debug=2;

//|-----------------------------------------------------------------------------------------|
//|                           I N T E R N A L   V A R I A B L E S                           |
//|-----------------------------------------------------------------------------------------|
double Lot=0.1;

// ------------------------------------------------------------------------------------------ //
//                             I N I T I A L I S A T I O N                                    //
// ------------------------------------------------------------------------------------------ //

int init()
{
   EasyInit();
   return(0);    
}


// ------------------------------------------------------------------------------------------ //
//                            D E - I N I T I A L I S A T I O N                               //
// ------------------------------------------------------------------------------------------ //

int deinit()
{
   return(0);
}


// ------------------------------------------------------------------------------------------ //
//                                M A I N   P R O C E D U R E                                 //
// ------------------------------------------------------------------------------------------ //

int start()
{
   double profit;
   string strtmp;
   int wave;
   
   wave=Linex(Pts);
   switch(wave)
   {
      case 1:  
         EasySell(Linex1Magic,Lot);
         strtmp = Linex1+ " Open Sell: " + DoubleToStr(Close[0],Digits);   
         break;
      case -1: 
         EasyBuy(Linex1Magic,Lot); 
         strtmp = Linex1+ " Open Buy: " + DoubleToStr(Close[0],Digits);   
         break;
      case 2:  
         EasySell(Linex2Magic,Lot);
         strtmp = Linex2+ " Open Sell: " + DoubleToStr(Close[0],Digits);   
         break;
      case -2:  
         EasyBuy(Linex2Magic,Lot);
         strtmp = Linex1+ " Open Buy: " + DoubleToStr(Close[0],Digits);   
         break;
   }
   if (wave!=0) Print(strtmp);

   profit=EasyProfitsMagic(Linex1Magic)+EasyProfitsMagic(Linex2Magic);
   strtmp=EasyComment(profit);
   strtmp=LinexComment(strtmp);
   Comment(strtmp);
   return(0);
}

//|-----------------------------------------------------------------------------------------|
//|                       E N D   O F   E X P E R T   A D V I S O R                         |
//|-----------------------------------------------------------------------------------------|

