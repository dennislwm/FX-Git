//|-----------------------------------------------------------------------------------------|
//|                                                                    StochasticSharpe.mq4 |
//|                                                            Copyright © 2012, Dennis Lee |
//| Assert History                                                                          |
//| 1.00    Created a stochastic oscillator based on variance of price.                     |
//|            %K = 100 * ( Variance of Close - Lowest Variance of Low (n) ) /              |
//|                       ( Highest Variance of High (n) - Lowest Variance of Low (n) )     |
//|            %D = 3-period simple moving average of %K                                    |
//|            Note: Variance of Low may be higher than Variance of High, and vice-versa.   |
//|-----------------------------------------------------------------------------------------|
#property copyright "Copyright © 2012, Dennis Lee"
#property link      ""

#property indicator_separate_window
#property indicator_minimum 0
#property indicator_maximum 100
#property indicator_buffers 7
#property indicator_color1 Red
#property indicator_color2 Yellow
//#property indicator_color3 LimeGreen
#property indicator_level1 20
#property indicator_level2 80

//|-----------------------------------------------------------------------------------------|
//|                           E X T E R N A L   V A R I A B L E S                           |
//|-----------------------------------------------------------------------------------------|
extern int KPeriod=5;
extern int DPeriod=3;
extern int Slowing=3;
//|-----------------------------------------------------------------------------------------|
//|                              O U T P U T   B U F F E R S                                |
//|-----------------------------------------------------------------------------------------|
double ExtMapBuffer1[];    // %K stochastic oscillator
double ExtMapBuffer2[];    // %D signal line (3-day SMA of %K)
//|-----------------------------------------------------------------------------------------|
//|                           C A L C U L A T I O N   B U F F E R S                         |
//|-----------------------------------------------------------------------------------------|
double ExtMapBuffer3[];    // High
double ExtMapBuffer4[];    // Low
double ExtMapBuffer5[];    // Close
double ExtMapBuffer6[];    // Highest High (n)
double ExtMapBuffer7[];    // Lowest Low (n)
//|-----------------------------------------------------------------------------------------|
//|                           I N T E R N A L   V A R I A B L E S                           |
//|-----------------------------------------------------------------------------------------|
string IndName="StochasticSharpe";
string IndVer="1.00";
double highMean=0;
double lowMean=0;
double closeMean=0;
double highSum=0;
double lowSum=0;
double closeSum=0;
int n=0;
//|-----------------------------------------------------------------------------------------|
//|                            I N I T I A L I S A T I O N                                  |
//|-----------------------------------------------------------------------------------------|
int init()
  {
//---- Assert indicators for outputs (3) and calculations (3)
   IndicatorBuffers(7);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexStyle(2,DRAW_NONE);
   SetIndexStyle(3,DRAW_NONE);
   SetIndexStyle(4,DRAW_NONE);
   SetIndexStyle(5,DRAW_NONE);
   SetIndexStyle(6,DRAW_NONE);
   
   IndicatorDigits(Digits+10);
   SetIndexDrawBegin(0,KPeriod+Slowing);
   SetIndexDrawBegin(1,KPeriod+Slowing);

   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexBuffer(1,ExtMapBuffer2);
   SetIndexBuffer(2,ExtMapBuffer3);
   SetIndexBuffer(3,ExtMapBuffer4);
   SetIndexBuffer(4,ExtMapBuffer5);
   SetIndexBuffer(5,ExtMapBuffer6);
   SetIndexBuffer(6,ExtMapBuffer7);
   
   SetIndexLabel(0,"Stochastic");
   SetIndexLabel(1,"Signal");
   SetIndexLabel(2,"High");
   SetIndexLabel(3,"Low");
   SetIndexLabel(4,"Close");
   SetIndexLabel(5,"HighestHigh");
   SetIndexLabel(6,"LowestLow");
   
   IndicatorShortName( StringConcatenate(IndName," ",IndVer) );
//----
   return(0);
  }
//|-----------------------------------------------------------------------------------------|
//|                            D E - I N I T I A L I S A T I O N                            |
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
   int i, j;
   int unused_bars;
   int used_bars=IndicatorCounted();
//---- Assert variables for lowest and highest
   double price;

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
         highSum+=High[i];
         lowSum+=Low[i];
         closeSum+=Close[i];
         highMean=highSum/n;
         lowMean=lowSum/n;
         closeMean=closeSum/n;
      }

   //---- Assert variance in decimal 
   //       Note: To check the code, just replace buffers 3,4,5 with High,Low,Close respectively.
      /*ExtMapBuffer3[i]=High[i];
      ExtMapBuffer4[i]=Low[i];
      ExtMapBuffer5[i]=Close[i];*/
      ExtMapBuffer3[i]=(High[i]-highMean)*(High[i]-highMean);
      ExtMapBuffer4[i]=(Low[i]-lowMean)*(Low[i]-lowMean);
      ExtMapBuffer5[i]=(Close[i]-closeMean)*(Close[i]-closeMean);
      double maxBuf=MathMax( ExtMapBuffer3[i], MathMax(ExtMapBuffer4[i],ExtMapBuffer5[i]) );
      double minBuf=MathMin( ExtMapBuffer3[i], MathMin(ExtMapBuffer4[i],ExtMapBuffer5[i]) );
      if (ExtMapBuffer3[i]<maxBuf) ExtMapBuffer3[i]=maxBuf;
      if (ExtMapBuffer4[i]>minBuf) ExtMapBuffer4[i]=minBuf;
   }
   
//---- determine start bar   
   unused_bars=Bars-KPeriod+1;
   if (used_bars>KPeriod) 
      unused_bars=Bars-used_bars;
   
   for (i=unused_bars-1;i>=0;i--)
   {
      double max=-10000000;
      for (j=i+KPeriod-1; j>=i; j--)
      {
         price=ExtMapBuffer3[j];
         if (max<price) max=price;
      }
   //---- Assert highest high (n) values
      ExtMapBuffer6[i]=max;
   }

   for (i=unused_bars-1;i>=0;i--)
   {
      double min=10000000;
      for (j=i+KPeriod-1; j>=i; j--)
      {
         price=ExtMapBuffer4[j];
         if (min>price) min=price;
      }
   //---- Assert lowest low (n) values
      ExtMapBuffer7[i]=min;
   }
   
//---- determine start bar   
   unused_bars=Bars-(KPeriod+Slowing)+1;
   if (used_bars>(KPeriod+Slowing)) 
      unused_bars=Bars-used_bars;

   for (i=unused_bars-1;i>=0;i--)
   {
      double highDeltaSum=0;
      double closeDeltaSum=0;
      
      for (j=i+Slowing-1; j>=i; j--)
      {
         highDeltaSum   += MathSqrt( ExtMapBuffer6[j]-ExtMapBuffer7[j] );
         closeDeltaSum  += MathSqrt( ExtMapBuffer5[j]-ExtMapBuffer7[j] );
      }
   //---- Assert %K line
      if (highDeltaSum==0.0) 
         ExtMapBuffer1[i]=100.0;
      else
         ExtMapBuffer1[i]=closeDeltaSum/highDeltaSum*100;
   }
   
   for (i=unused_bars-1;i>=0;i--)
   {
   //---- Assert %D signal values in decimal
      ExtMapBuffer2[i]=iMAOnArray(ExtMapBuffer1,0,DPeriod,0,MODE_SMA,i);
   }
//----
   return(0);
}
//|-----------------------------------------------------------------------------------------|
//|                        E N D   O F   C U S T O M   I N D I C A T O R                    |
//|-----------------------------------------------------------------------------------------|
