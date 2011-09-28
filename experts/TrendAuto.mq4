//|-----------------------------------------------------------------------------------------|
//|                                                                           TrendAuto.mq4 |
//|                                                            Copyright © 2011, Dennis Lee |
//| Assert History                                                                          |
//| 1.00    Added PlusLinex.mqh                                                             |
//|         Added 
//|-----------------------------------------------------------------------------------------|
#property   copyright "Copyright © 2011, Dennis Lee"
#import "WinUser32.mqh"

//---- Assert Basic externs
extern string s1="-->Basic Settings<--";
extern double StopLoss=120;
extern double MaxSpread=10;
double TakeProfit=0;
double SecureProfit=2;
double SecureProfitTrigger=0;
//---- Assert Money Management externs
extern string s2="-->Money Management<--";
extern double AutoMM=1.0;
extern double MaxLot=0.5;
extern double MinLot=0.05;
extern int MaxAccountTrades=4;
extern int MaxSamePairTrades=1;
double ContractSize=100000;
string s2_1="Assign value below (hour) to take profit.";
string s2_2="Each x hour, 40% of lots closed on profit.";
double SecureProfitOnMins=0;
double securetime;
double SecureProfitOnInit=0;
//---- Assert PlusLinex externs
extern string s3="-->PlusLinex Settings<--";
#include <pluslinex.mqh>
//---- Assert Extra externs
extern string s4="-->Extra Settings<--";
extern double SlipPage=3;
extern string TradeComment="-->TrendAuto v1.00<--";
extern int Debug=2;

//|-----------------------------------------------------------------------------------------|
//|                           I N T E R N A L   V A R I A B L E S                           |
//|-----------------------------------------------------------------------------------------|
double Pip;
double Pts;
double MinStop;
//---- Assert MaxWaveTrades global variables
int MaxWaveTrades=1;
int OpenWave=0;
//---- Assert Dampener global variables
int DampenerCount=5;

// ------------------------------------------------------------------------------------------ //
//                             I N I T I A L I S A T I O N                                    //
// ------------------------------------------------------------------------------------------ //

int init()
{
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
   int wave;
   string strtmp;
   
   wave=Linex();
   switch(wave)
   {
      case 1:  strtmp = Linex1+ " Open Sell: " + DoubleToStr(Close[0],Digits);   break;
      case -1:  strtmp = Linex1+ " Open Buy: " + DoubleToStr(Close[0],Digits);   break;
      case 2:  strtmp = Linex2+ " Open Sell: " + DoubleToStr(Close[0],Digits);   break;
      case -2:  strtmp = Linex1+ " Open Buy: " + DoubleToStr(Close[0],Digits);   break;
   }
   if (wave!=0) Print(strtmp);
   Comment(LinexComment());
   return(0);
}

//|-----------------------------------------------------------------------------------------|
//|                       E N D   O F   E X P E R T   A D V I S O R                         |
//|-----------------------------------------------------------------------------------------|


