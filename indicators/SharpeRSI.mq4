//|-----------------------------------------------------------------------------------------|
//|                                                                           SharpeRSI.mq4 |
//|                                                            Copyright © 2011, Dennis Lee |
//| Assert History                                                                          |
//| 1.10    Added a new ExtMapBuffer to calculate the RSI from Sharpe MACD.                 |
//| 1.00    Originated from SharpeMACD AlleeH4 4.43 (that does not repaint).                |
//|-----------------------------------------------------------------------------------------|
#property copyright "Copyright © 2011, Dennis Lee"
#property link      ""

#property indicator_separate_window
#property indicator_minimum 0
#property indicator_maximum 100
#property indicator_buffers 7
#property indicator_color1 Red
#property indicator_color2 Yellow
#property indicator_color3 LimeGreen
#property indicator_color4 Thistle
#property indicator_level1 15
#property indicator_level2 85

//--- input parameters
extern int EmaFast=12;
extern int EmaSlow=26;
extern int EmaSignal=9;
//---- Assert indicator name and version
string IndName="SharpeRSI";
string IndVer="1.1";
//---- Assert indicators for outputs (3) and calculations (3)
double ExtMapBuffer1[];    // rsi of sharpe
double ExtMapBuffer2[];    // macd of sharpe
double ExtMapBuffer3[];    // signal of sharpe
double ExtMapBuffer4[];    // histogram of sharpe
double ExtMapBuffer5[];    // cross product of deviation from mean
double ExtMapBuffer6[];    // ema fast of sharpe
double ExtMapBuffer7[];    // ema slow of sharpe
//---- Assert variables for cumulative mean
double mean=0;
double sum=0;
int n=0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- Assert indicators for outputs (3) and calculations (3)
   IndicatorBuffers(7);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexStyle(2,DRAW_LINE);
   SetIndexStyle(3,DRAW_HISTOGRAM);
   SetIndexStyle(4,DRAW_NONE);
   SetIndexStyle(5,DRAW_NONE);
   SetIndexStyle(6,DRAW_NONE);
   
   IndicatorDigits(Digits+10);
   SetIndexDrawBegin(0,EmaSlow);
   SetIndexDrawBegin(1,EmaSlow);
   SetIndexDrawBegin(2,EmaSlow);
   SetIndexDrawBegin(3,EmaSlow);
   SetIndexDrawBegin(4,EmaSlow);
   SetIndexDrawBegin(5,EmaSlow);
   SetIndexDrawBegin(6,EmaSlow);

   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexBuffer(1,ExtMapBuffer2);
   SetIndexBuffer(2,ExtMapBuffer3);
   SetIndexBuffer(3,ExtMapBuffer4);
   SetIndexBuffer(4,ExtMapBuffer5);
   SetIndexBuffer(5,ExtMapBuffer6);
   SetIndexBuffer(6,ExtMapBuffer7);
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
{
//---- Assert variables for count from last bar
   int i;
   int unused_bars;
   int used_bars=IndicatorCounted();

   string debug;

//---- check for possible errors
   if (used_bars<0) return(-1);
//---- last counted bar will be recounted
   if (used_bars>0) used_bars--;
   unused_bars=Bars-used_bars;

//---- Assert count from last bar (function Bars) to current bar (0)
   for (i=unused_bars-1;i>=0;i--)
   {
   //---- Assert cumulative mean (exclude current Bar)
      if (n<Bars)
      {
         n+=1;
         sum+=Close[i];
         mean=sum/n;
      }

   //---- Assert variance in decimal
   //---- Assert parameter cross_prod is changed from array to timeseries
      ExtMapBuffer5[i]=(Close[i]-mean)*(Close[i]-mean);
   }

   for (i=unused_bars-1;i>=0;i--)
   {
   //---- Assert EMA values in decimal
      ExtMapBuffer6[i]=MathSqrt(iMAOnArray(ExtMapBuffer5,0,EmaFast,0,MODE_EMA,i));
      ExtMapBuffer7[i]=MathSqrt(iMAOnArray(ExtMapBuffer5,0,EmaSlow,0,MODE_EMA,i));

   //---- Assert MACD values in decimal
      ExtMapBuffer2[i]=MathSqrt(iMAOnArray(ExtMapBuffer5,0,EmaFast,0,MODE_EMA,i))-MathSqrt(iMAOnArray(ExtMapBuffer5,0,EmaSlow,0,MODE_EMA,i));
   }

   for (i=unused_bars-1;i>=0;i--)
   {
   //---- Assert signal values in decimal
      ExtMapBuffer3[i]=iMAOnArray(ExtMapBuffer2,0,EmaSignal,0,MODE_EMA,i);

   //---- Assert histogram values in decimal 
      ExtMapBuffer4[i]=ExtMapBuffer2[i]-iMAOnArray(ExtMapBuffer2,0,EmaSignal,0,MODE_EMA,i);
      
   //---- Assert RSI values in decimal 
      ExtMapBuffer1[i]=iRSIOnArray(ExtMapBuffer2,0,14,i);
   }
   IndicatorShortName( StringConcatenate(IndName," ",IndVer) );
//----
   return(0);
}
//+------------------------------------------------------------------+
