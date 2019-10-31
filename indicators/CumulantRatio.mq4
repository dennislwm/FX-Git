//|-----------------------------------------------------------------------------------------|
//|                                                                       CumulantRatio.mq4 |
//|                                                            Copyright © 2013, Dennis Lee |
//|                                                                                         |
//| Disclaimer: You understand and agree to the following terms and conditions for use:     |
//|   (a) you do not remove any of the copyright information from the source code, or       |
//|       attempt to commercialize the source code or indicator.                            |
//|   (b) you are allowed to modify the source code, but you do not attempt to              |
//|       commercialize any variation of the source code or indicator.                      |
//|   (c) I am not liable for any damages or losses as a result of you using the indicator  |
//|       or any variation of the indicator for any purposes.                               |
//|-----------------------------------------------------------------------------------------|
#property copyright "Copyright © 2013, Dennis Lee"

#property indicator_separate_window
#property indicator_buffers 7
//#property indicator_minimum -10
//#property indicator_maximum 10
#property indicator_level1 0
#property indicator_color1 Yellow
#property indicator_color2 Green
#property indicator_color3 Silver

//|-----------------------------------------------------------------------------------------|
//|                           E X T E R N A L   V A R I A B L E S                           |
//|-----------------------------------------------------------------------------------------|
extern int        CrPeriod       = 7;
extern int        CrAlpha        = 100;
//|-----------------------------------------------------------------------------------------|
string IndName                   = "CumulantRatio";
string IndVer                    = "0.9.0";
//|-----------------------------------------------------------------------------------------|

//|-----------------------------------------------------------------------------------------|
//|                           I N T E R N A L   V A R I A B L E S                           |
//|-----------------------------------------------------------------------------------------|
double ExtMapBuffer1[];    // cumulant ratio
double ExtMapBuffer2[];    // sum of divisor
double ExtMapBuffer3[];    // sum of numerator
double ExtMapBuffer4[];    // divisor, i.e. Close0 - Close
double ExtMapBuffer5[];    // numerator, i.e. |Close - average|
double ExtMapBuffer6[];    // Close0
double ExtMapBuffer7[];    // simple average iMA
//|-----------------------------------------------------------------------------------------|
double mean=0;
double sum=0;
int n=0;

//|-----------------------------------------------------------------------------------------|
//|                             I N I T I A L I Z A T I O N                                 |
//|-----------------------------------------------------------------------------------------|
int init()
{
//---- Assert indicators for outputs (1) and calculations (6)
   IndicatorBuffers(7);
   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexStyle(2,DRAW_LINE);
   SetIndexStyle(3,DRAW_NONE);
   SetIndexStyle(4,DRAW_NONE);
   SetIndexStyle(5,DRAW_NONE);
   SetIndexStyle(6,DRAW_NONE);
   
   IndicatorDigits(Digits+10);
   SetIndexDrawBegin(0,CrPeriod);
   SetIndexDrawBegin(1,CrPeriod);
   SetIndexDrawBegin(2,CrPeriod);
   SetIndexDrawBegin(3,CrPeriod);
   SetIndexDrawBegin(4,CrPeriod);
   SetIndexDrawBegin(5,CrPeriod);
   SetIndexDrawBegin(6,CrPeriod);

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
  
//|-----------------------------------------------------------------------------------------|
//|                             D E I N I T I A L I Z A T I O N                             |
//|-----------------------------------------------------------------------------------------|
int deinit()
{
//----
   
//----
   return(0);
}
  
//|-----------------------------------------------------------------------------------------|
//|                               M A I N   P R O C E D U R E                               |
//|-----------------------------------------------------------------------------------------|
int start()
{
//---- Assert variables for count from last bar
   int i;
   int unused_bars;
   int used_bars=IndicatorCounted();
//---- Assert variables for maths
   int fracInt;
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
   }

   for (i=unused_bars-1;i>=0;i--)
   {
   //---- Assert SMA values in decimal
      ExtMapBuffer7[i]=iMA(NULL,0,CrPeriod,0,MODE_SMA,PRICE_CLOSE,i);

   //---- Calculate fraction and remove decimal
      fracInt = i / CrPeriod;
      fracInt = fracInt * CrPeriod;
      ExtMapBuffer6[i]=Close[fracInt];
   }
   
   for (i=unused_bars-1;i>=0;i--)
   {
   //---- Assert divisor, i.e. |Close - average|
      ExtMapBuffer5[i]=MathAbs(Close[i]-ExtMapBuffer7[i]);
   //---- Assert numerator, i.e. Close0 - Close
      ExtMapBuffer4[i]=ExtMapBuffer6[i] - Close[i];
   }
   
   for (i=unused_bars-1;i>=0;i--)
   {
   //---- Sum of divisor
      ExtMapBuffer3[i] = iMAOnArray(ExtMapBuffer5,0,CrPeriod,0,MODE_SMA,i) * CrAlpha;
   //---- Sum of numerator
      ExtMapBuffer2[i] = iMAOnArray(ExtMapBuffer4,0,CrPeriod,0,MODE_SMA,i) * CrAlpha;
   }
   
   for (i=unused_bars-1;i>=0;i--)
   {
   //---- Cumulant ratio
      if( ExtMapBuffer3[i] > 0 ) ExtMapBuffer1[i] = ExtMapBuffer2[i]/ExtMapBuffer3[i];
   }
   
   IndicatorShortName( StringConcatenate(IndName," ",IndVer) );
   return(0);
}
//|-----------------------------------------------------------------------------------------|
//|                       E N D   O F   E X P E R T   A D V I S O R                         |
//|-----------------------------------------------------------------------------------------|