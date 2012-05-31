//+------------------------------------------------------------------+
//|                                                   SharpeMACD.mq4 |
//|                                     Copyright © 2011, Dennis Lee |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2011, Dennis Lee"
#property link      ""

#property indicator_separate_window
#property indicator_buffers 6
#property indicator_color1 Red
#property indicator_color2 LimeGreen
#property indicator_color3 Thistle
//--- input parameters
extern int EmaFast=12;
extern int EmaSlow=26;
extern int EmaSignal=9;
//---- Assert indicators for outputs (3) and calculations (3)
double ExtMapBuffer1[];
double ExtMapBuffer2[];
double ExtMapBuffer3[];
double ExtMapBuffer4[];
double ExtMapBuffer5[];
double ExtMapBuffer6[];
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
   IndicatorBuffers(6);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexStyle(2,DRAW_HISTOGRAM);
   SetIndexStyle(3,DRAW_NONE);
   SetIndexStyle(4,DRAW_NONE);
   SetIndexStyle(5,DRAW_NONE);
   
   IndicatorDigits(Digits+10);
   SetIndexDrawBegin(0,EmaSlow);
   SetIndexDrawBegin(1,EmaSlow);
   SetIndexDrawBegin(2,EmaSlow);
   SetIndexDrawBegin(3,EmaSlow);
   SetIndexDrawBegin(4,EmaSlow);
   SetIndexDrawBegin(5,EmaSlow);

   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexBuffer(1,ExtMapBuffer2);
   SetIndexBuffer(2,ExtMapBuffer3);
   SetIndexBuffer(3,ExtMapBuffer4);
   SetIndexBuffer(4,ExtMapBuffer5);
   SetIndexBuffer(5,ExtMapBuffer6);
   
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
      //debug="n="+n+";mean="+mean+";Bars="+Bars;

//---- Assert variance in decimal
//---- Assert parameter cross_prod is changed from array to timeseries
      //ArraySetAsSeries(cross_prod,true);
      //ArrayResize(cross_prod,n);
      ExtMapBuffer4[i]=(Close[i]-mean)*(Close[i]-mean);
   }

   for (i=unused_bars-1;i>=0;i--)
   {
//      debug="n="+n+";cross_prod="+cross_prod[i];

//---- Assert EMA values in decimal
      ExtMapBuffer5[i]=MathSqrt(iMAOnArray(ExtMapBuffer4,0,EmaFast,0,MODE_EMA,i));
      ExtMapBuffer6[i]=MathSqrt(iMAOnArray(ExtMapBuffer4,0,EmaSlow,0,MODE_EMA,i));

//---- Assert MACD values in decimal
      ExtMapBuffer1[i]=MathSqrt(iMAOnArray(ExtMapBuffer4,0,EmaFast,0,MODE_EMA,i))-MathSqrt(iMAOnArray(ExtMapBuffer4,0,EmaSlow,0,MODE_EMA,i));
   }

   for (i=unused_bars-1;i>=0;i--)
   {
//---- Assert signal values in decimal
      ExtMapBuffer2[i]=iMAOnArray(ExtMapBuffer1,0,EmaSignal,0,MODE_EMA,i);

//---- Assert histogram values in decimal 
      ExtMapBuffer3[i]=ExtMapBuffer1[i]-iMAOnArray(ExtMapBuffer1,0,EmaSignal,0,MODE_EMA,i);
   }
   //debug=debug+";macd="+ExtMapBuffer1[0];
   IndicatorShortName("SharpeMACD 2.0");
//----
   return(0);
}
//+------------------------------------------------------------------+