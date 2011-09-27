//+------------------------------------------------------------------+
//|                                                   plusturtle.mqh |
//|                                     Copyright © 2011, Dennis Lee |
//|                                                                  |
//| Assert History                                                   |
//| 1.00    Copied from AlleeH4 4.43, functions that relate to lots: |
//|           dampener()                                             |
//|           get_lots()                                             |
//|           handle_bearbullratio()                                 |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2011, Dennis Lee"
//+------------------------------------------------------------------+
//| Dampener function inputs a BearBullMagnifier and returns a dampen|
//| BearBullMagnifier                                                |
//+------------------------------------------------------------------+
double dampener(double amp)
{
   static int step;
//---- Assert BbrSTO>1 or BbrBTO>1
   //if (amp<=1) return(amp);
   
//---- Assert step-down dampening of the BbrSTO or BbrBTO.
   double stepdown_amp=amp-(amp-1)*MathMin(DampenerCount,step)/DampenerCount;
   
   if (Debug>=2) Print("dampener():StepDown=",step);
   
//---- Assert step is incremented and persist until deinit()
//---- If step exceeds DampenerCount, then BbrSTO=1 or BbrBTO=1
   step++;
   
   return(stepdown_amp);
}
//+------------------------------------------------------------------+
//| Lots Sizes and Automatic Money Management                        |
//+------------------------------------------------------------------+
double get_lots()
{
   double LotStep, MaxBLot, MinBLot;
//---- Assert variables for AutoMM
   double CalcLot, Atr;

//---- Assert AutoMM>0
   if (AutoMM<0.1) AutoMM=0.1;

//---- Retrieve broker info on lots in Pips (either base 1 or base 10 depending on broker)
   LotStep=MarketInfo(Symbol(),MODE_LOTSTEP);
   MaxBLot=MarketInfo(Symbol(),MODE_MAXLOT);
   MinBLot=MarketInfo(Symbol(),MODE_MINLOT);



//---- Assert maximum risk in lots is calculated as % of equity divided by maximum stop loss
   if (UserLot!=0 && UserOpenSignal!=0) CalcLot=UserLot;
   else
   {
      Atr=iATR(NULL,0,14,0);
      CalcLot=AutoMM*0.01*AccountEquity()/(Atr*MarketInfo(Symbol(),MODE_LOTSIZE));
   }
   
//---- Assert user's MinLot and MaxLot
   if (MaxLot!=0 && CalcLot>MaxLot) CalcLot=MaxLot;
   else if (MinLot!=0 && CalcLot<MinLot) CalcLot=MinLot;

//---- Assert broker's MinLot and MaxLot
   if (CalcLot>MaxBLot) return(MaxBLot);
   else if (CalcLot<MinBLot) return(MinBLot);
   else return(CalcLot);
}
//+------------------------------------------------------------------+
//| Handle Bull and Bear Factor                                      |
//+------------------------------------------------------------------+
bool handle_bearbullratio()
{
//---- Assert variables for Signal
   double rsi_max;
   double rsi_off;
   
//---- Assert BullBearRatio is between 0 and 2.
   if (BearBullRatio<0)
   {
      Print("BearBullRatio=",BearBullRatio," is less than 0. Set BearBullRatio=0.");
      BearBullRatio=0;
   }
   else if (BearBullRatio>2)
   {
      Print("BearBullRatio=",BearBullRatio," is more than 2. Set BearBullRatio=2.");
      BearBullRatio=2;
   }
   else
   {
      BearBullRatio=NormalizeDouble(BearBullRatio,1);
      Print("BearBullRatio=",BearBullRatio,".");
   }
//---- Assert RSI factor is set proportionately to BBR
//---- BBR=1, RSISTO=65, RSIBTO=35
//---- BBR=2, RSIBTO=20
//---- BBR=0, RSISTO=80
//---- Assert recommended TakeProfit for different Time periodicity.
// M1,   RSISTO=70,RSIBTO=30
// M5,   RSISTO=70,RSIBTO=30
// M15,  RSISTO=65,RSIBTO=35
// M30,  RSISTO=65,RSIBTO=35
//----
   switch (Period())
   {
      case 1   : RsiSTO=70;RsiBTO=30;  break;
      case 5   : RsiSTO=65;RsiBTO=35;  break;
      case 15  : RsiSTO=65;RsiBTO=35;  break;
      default  : RsiSTO=65;RsiBTO=35;
   }
//---- Automatically signal factor for Gold and Silver
   if (Symbol()=="XAUUSD" || Symbol()=="XAGUSD") 
   {
      switch (Period())
      {
         case 1   : RsiSTO=65;RsiBTO=35;  break;
         case 5   : RsiSTO=65;RsiBTO=35;  break;
         case 15  : RsiSTO=65;RsiBTO=35;  break;
         default  : RsiSTO=65;RsiBTO=35;
      }
   }
   rsi_max=80-RsiSTO;
   rsi_off=MathMin(1,MathAbs(BearBullRatio-1))*rsi_max*(2-1);
   if (BearBullRatio<1) RsiSTO=RsiSTO+rsi_off;
   if (BearBullRatio>1) RsiBTO=RsiBTO-rsi_off;
//---- Assert Money Management is set proportionately to BBR
//---- BBR=1, Lots=L, TP=T
//---- BBR=2, Sell Lots=L*2, TP=T*2, Buy Lots=L/2, TP=T/2
//---- BBR=0, Buy Lots=L*2, TP=T*2, Sell Lots=L/2, TP=T/2
   if (BearBullRatio<1) 
      {
         BbrBTO=MathMin(1,MathAbs(BearBullRatio-1))*(BearBullMax-1)+1;
         BbrSTO=NormalizeDouble(1/BbrBTO,1);
         BbrBTO=NormalizeDouble(BbrBTO,1);
      }
   if (BearBullRatio>1)
      { 
         BbrSTO=MathMin(1,MathAbs(BearBullRatio-1))*(BearBullMax-1)+1;
         BbrBTO=NormalizeDouble(1/BbrSTO,1);
         BbrSTO=NormalizeDouble(BbrSTO,1);
      }
   
   //if (BearBullRatio==0) Print("BearBullRatio=",BearBullRatio,". SELL to Open has been disabled.");
   //if (BearBullRatio==2) Print("BearBullRatio=",BearBullRatio,". BUY to Open has been disabled.");
}
