//|-----------------------------------------------------------------------------------------|
//|                                                                             TDSetup.mq4 |
//|                                                            Copyright © 2012, Dennis Lee |
//| Assert History                                                                          |
//| 1.00    Standalone Tom DeMark's Setup indicator (wave signal).                          |
//|-----------------------------------------------------------------------------------------|
#property copyright "Copyright © 2011, Dennis Lee"
//---- indicator settings
#property  indicator_separate_window
#property  indicator_buffers 3
#property  indicator_color1  Thistle
#property  indicator_color2  FireBrick
#property  indicator_color3  Green
#property  indicator_maximum 4
#property  indicator_minimum -4
//---- Assert indicator buffers for output(2) and calculation(1)
double     TDSetup[];
double     TDSetupFlip[];
double     TDCountdownFlip[];
//--- input parameters
extern int Debug=3;
extern int DebugLookBackPeriod=50;
//--- global variables
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- Assert indicator buffers for output(1) and calculation(4)
   IndicatorBuffers(3);
   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexStyle(1,DRAW_NONE);
   SetIndexStyle(2,DRAW_NONE);
   IndicatorDigits(Digits);
//---- indicator buffers mapping
   SetIndexBuffer(0,TDSetup);
   SetIndexBuffer(1,TDSetupFlip);
   SetIndexBuffer(2,TDCountdownFlip);
//---- name for DataWindow and indicator subwindow label
   IndicatorShortName(StringConcatenate("TDSetupH4(",DebugLookBackPeriod,")"));
//---- initialization done
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
//| Custom TDSetupFlip indicator used with TDSetup[]                 |
//+------------------------------------------------------------------+
void iTDSetupFlip(double& setupflip[], int i)
{
//---- Assert local variables

//       Market records a Close LESS than the Close 4 bars earlier, 
//          preceded by a Close GREATER than the close 4 bars before.
   if (Close[i]<Close[i+4] && Close[i+1]>Close[i+5])
   {
      setupflip[i]=-2;
      //if (Debug>=3 && i<DebugLookBackPeriod) Print("iTDSetupFlip(): Bearish TD Price Flip initiate TD Buy Setup at ",i);
   }
//       Assert exit if there is a break in consecutive closes.
   else if (Close[i]<=Close[i+4])
   {
      setupflip[i]=-1;
   }
//       Market records a Close GREATER than the Close 4 bars before, 
//          preceded by a Close LESS than the close 4 bars earlier.
   if (Close[i]>Close[i+4] && Close[i+1]<Close[i+5])
   {
      setupflip[i]=2;
      //if (Debug>=3 && i<DebugLookBackPeriod) Print("iTDSetupFlip(): Bullish TD Price Flip initiate TD Sell Setup at ",i);
   }
//       Assert exit if there is a break in consecutive closes.
   else if (Close[i]>=Close[i+4])
   {
      setupflip[i]=1;
   }
}
//+------------------------------------------------------------------+
//| Custom TDSetupCancel indicator used with TDSetup[]               |
//+------------------------------------------------------------------+
void iTDSetupFlipCancel(double& setup[], double& setupflip[], int i)
{
//---- Assert local variables
   int c;
//       Assert complete a TD Buy Setup if more than NINE.
   if (setupflip[i+8]==-2 && setupflip[i+7]==-1 && setupflip[i+6]==-1 && setupflip[i+5]==-1 && setupflip[i+4]==-1 && setupflip[i+3]==-1 && setupflip[i+2]==-1 && setupflip[i+1]==-1 && setupflip[i]==-1)
   {
      setup[i+8]=-2;
      //for (c=1;c<8;c++) setup[i+c]=-1;
//       TD Buy Setup "Perfection" is the prerequisite for entering
//          a long position based on a completed TD Buy Setup
//          The low of bars 8 OR 9 of the TD Buy Setup must be LESS
//             than, or equal to, the lows of bars 6 AND 7.
//          If the above is not met, a subsequent low must be LESS
//             than, or equal to, the lows of bars 6 and 7.
      if ((Low[i]<=Low[i+3] && Low[i]<=Low[i+2]) || (Low[i+1]<=Low[i+3] && Low[i+1]<=Low[i+2])) 
         setup[i]=-4;
      else
         setup[i]=-3;
   }
//       Assert complete a TD Sell Setup if more than NINE.
   if (setupflip[i+8]==2 && setupflip[i+7]==1 && setupflip[i+6]==1 && setupflip[i+5]==1 && setupflip[i+4]==1 && setupflip[i+3]==1 && setupflip[i+2]==1 && setupflip[i+1]==1 && setupflip[i]==1)
   {
      setup[i+8]=2;
      //for (c=1;c<8;c++) setup[i+c]=1;
//       TD Sell Setup "Perfection" is the prerequisite for entering
//          a short position based on a completed TD Sell Setup
//          The high of bars 8 OR 9 of the TD Sell Setup must be MORE
//             than, or equal to, the highs of bars 6 AND 7.
//          If the above is not met, a subsequent high must be MORE
//             than, or equal to, the highs of bars 6 and 7.
      if ((High[i]>=High[i+3] && High[i]>=High[i+2]) || (High[i+1]>=High[i+3] && High[i+1]>=High[i+2])) 
         setup[i]=4;
      else
         setup[i]=3;
   }
}
//+------------------------------------------------------------------+
//| Custom TDSetupPerfect indicator used with TDSetup[]              |
//+------------------------------------------------------------------+
void iTDSetupPerfect(double& setup[], int i)
{
//---- Assert local variables
   static bool bimperfect,simperfect;
   static double low6,low7,high6,high7;

//       Assert entry if there is an imperfection
   if (!simperfect && setup[i]==3)
   {
      high6=High[i+3];
      high7=High[i+2];
      simperfect=true;
      if (Debug>=3 && i<DebugLookBackPeriod) Print("iTDSetupPerfect(): sell imperfection entry at ",i,". Set high6=",high6," high7=",high7);
   }
//       Assert exit if there is a next imperfection
   else if (simperfect && setup[i]==3)
   {
      high6=High[i+3];
      high7=High[i+2];
      if (Debug>=3 && i<DebugLookBackPeriod) Print("iTDSetupPerfect(): sell imperfection exit routed by imperfection at ",i,". Set high6=",high6," high7=",high7);
   }
//       Assert exit if there is a perfection
   else if (simperfect && setup[i]==4)
   {
      simperfect=false;
      if (Debug>=3 && i<DebugLookBackPeriod) Print("iTDSetupPerfect(): sell imperfection exit routed by perfection at ",i);
   }
//       Assert imperfection becomes perfection
//          If perfection is not met, a subsequent high must be MORE
//             than, or equal to, the highs of bars 6 and 7.
   else if (simperfect && High[i]>=high6 && High[i]>=high7)
   {
      setup[i]=4;
      simperfect=false;
      if (Debug>=3 && i<DebugLookBackPeriod) Print("iTDSetupPerfect(): sell imperfection exit found perfection at ",i);
   }
//       Assert entry if there is an imperfection
   if (!bimperfect && setup[i]==-3)
   {
      low6=Low[i+3];
      low7=Low[i+2];
      bimperfect=true;
      if (Debug>=3 && i<DebugLookBackPeriod) Print("iTDSetupPerfect(): buy imperfection entry at ",i,". Set low6=",low6," low7=",low7);
   }
//       Assert exit if there is a next imperfection
   else if (bimperfect && setup[i]==-3)
   {
      low6=Low[i+3];
      low7=Low[i+2];
      if (Debug>=3 && i<DebugLookBackPeriod) Print("iTDSetupPerfect(): buy imperfection exit and entry at ",i,". Set low6=",low6," low7=",low7);
   }
//       Assert exit if there is a perfection
   else if (bimperfect && setup[i]==-4)
   {
      bimperfect=false;
      if (Debug>=3 && i<DebugLookBackPeriod) Print("iTDSetupPerfect(): buy imperfection exit routed by perfection at ",i);
   }
//       Assert imperfection becomes perfection
//          If perfection is not met, a subsequent low must be LESS
//             than, or equal to, the lows of bars 6 and 7.
   else if (bimperfect && Low[i]<=low6 && Low[i]<=low7)
   {
      setup[i]=-4;
      bimperfect=false;
      if (Debug>=3 && i<DebugLookBackPeriod) Print("iTDSetupPerfect(): buy imperfection exit found perfection at ",i);
   }
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
{
//---- Assert variables used by count from last bar
   int i;
   int unused_bars;
   int used_bars=IndicatorCounted();

//---- check for possible errors
   if (used_bars<0) return(-1);
//---- last counted bar will be recounted
   if (used_bars>0) used_bars--;

//---- Assert count from last bar (function Bars) to current bar (0)
   unused_bars=Bars-used_bars;

   for (i=unused_bars-1;i>=0;i--)
   {
//---- Assert TD Setup Flip
      iTDSetupFlip(TDSetupFlip,i);
   }
   for (i=unused_bars-1;i>=0;i--)
   {
//---- Assert TD Setup Flip cancel
      iTDSetupFlipCancel(TDSetup,TDSetupFlip,i);
   }
   for (i=unused_bars-1;i>=0;i--)
   {
//---- Assert TD Setup Perfection
      iTDSetupPerfect(TDSetup,i);
   }

   Comment(StringConcatenate("TDSetupH4(",DebugLookBackPeriod,")  ",DoubleToStr(TDSetup[0],Digits)),"  Copyright © 2011, Dennis Lee");
   return(0);
}//+------------------------------------------------------------------+