//|-----------------------------------------------------------------------------------------|
//|                                                                       SharpeRSI_Ann.mq4 |
//|                                                            Copyright © 2012, Dennis Lee |
//| Assert History                                                                          |
//| 1.00    Standalone SharpeRSI indicator with Neural Net wave signal. The length of the   |
//|            wave indicates the validity length in bars. E.g. 10 means SELL with a 10-bar |
//|            validity. Requires PlusAnn.                                                  |
//|-----------------------------------------------------------------------------------------|
#property copyright "Copyright © 2012, Dennis Lee"
#property link      ""

#property indicator_separate_window
#property indicator_minimum -20
#property indicator_maximum 20
#property indicator_buffers 2
#property indicator_color1 Thistle
#property indicator_color2 Black
#property indicator_color3 Black

#include    <PlusAnn.mqh>

//--- input parameters
extern int       EmaFast=12;
extern int       EmaSlow=26;
extern int       EmaSignal=9;
//--- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
//--- Assert variables used by variance
double cross_prod[];
//--- Assert variables used by EMA values
double ema_fast[];
double ema_slow[];
//--- Assert variables used by MACD
double macd[];
//--- Assert variables used by signal
double signal[];
//--- Assert variables used by RSI
double rsi[];
double aHigh[], aLow[], aClose[], aOpen[];
//--- Assert variables used by Ann
double inRsi[], outRsi[], sumRsi=0.0;
int    posCount, negCount;
//--- Assert variables to detect new bar
int    nextBarTime;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexStyle(1,DRAW_NONE);
   SetIndexBuffer(1,ExtMapBuffer2);
//----
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
//---- Assert variables used by count from last bar
   int i;
   int unused_bars;
   int used_bars=IndicatorCounted();
//---- Assert variables used by cumulative mean
   static double mean=0;
   static double sum=0;
   static int n=0;

   string debug;
   
//---- check for possible errors
   if (used_bars<0) return(-1);
//---- last counted bar will be recounted
//   if (used_bars>0) used_bars--;

//---- Assert count from last bar (function Bars) to current bar (0)
   unused_bars=Bars-used_bars;


   for (i=unused_bars-1; i>0; i--)
   {
//---- Assert cumulative mean
      n+=1;
      sum+=Close[i];
      mean=sum/n;

//---- Assert variance in decimal
      ArrayResize(cross_prod,n);
      cross_prod[i]=(Close[i]-mean)*(Close[i]-mean);
//---- Assert parameter cross_prod is changed from array to timeseries
      ArraySetAsSeries(cross_prod,true);
//---- Assert EMA values in decimal
      ArrayResize(ema_fast,n);
      ArrayResize(ema_slow,n);
      ema_fast[i]=MathSqrt(iMAOnArray(cross_prod,0,EmaFast,0,MODE_EMA,i));
      ema_slow[i]=MathSqrt(iMAOnArray(cross_prod,0,EmaSlow,0,MODE_EMA,i));
//---- Assert MACD values in decimal
      ArrayResize(macd,n);
      macd[i]=ema_fast[i]-ema_slow[i];
//---- Assert RSI values in decimal
      ArrayResize(rsi,n);
      rsi[i]=iRSIOnArray(macd,0,14,i);
      ArraySetAsSeries(macd,true);
//---- Display arrays as a timeseries
      ExtMapBuffer2[i]=rsi[i];
   }

//--- Assert Ann   
   if(isNewBar())
   {
      AnnTotalBars = CalcLookBackBar(AnnMinBars,AnnMaxBars,AnnTotalBars);
      posCount=0; negCount=0; sumRsi=0.0;
   //--- Assert resize dynamic input Array.
      populateRsi(AnnTotalBars);
      ArrayResize(outRsi, AnnCommitteeSize);
      if(AnnTotalBars >= AnnMinBars)
      {
         for(i=0; i<AnnCommitteeSize; i++)
         {
            Retrain(inRsi, ArraySize(inRsi), i);
            outRsi[i] = PredictDirectionNN(inRsi, ArraySize(inRsi), i) * 100;
            sumRsi = sumRsi + outRsi[i];
            if(outRsi[i]>=rsi[1]) posCount ++;
            else negCount++;
         }
         if( posCount == AnnCommitteeSize || negCount == AnnCommitteeSize ) {}
         else sumRsi=0.0;
         if(sumRsi!=0.0) 
         {
            double avg=sumRsi/AnnCommitteeSize;
            int hiRsi   =CalcSeqBackBar(rsi,AnnTotalBars);
            int loRsi   =CalcSeqBackBar(rsi,AnnTotalBars,true);
            populateArray(High,aHigh,AnnTotalBars);
            int hiHigh  =CalcSeqBackBar(aHigh,AnnTotalBars);
            int loHigh  =CalcSeqBackBar(aHigh,AnnTotalBars,true);
            populateArray(Low,aLow,AnnTotalBars);
            int hiLow   =CalcSeqBackBar(aLow,AnnTotalBars);
            int loLow   =CalcSeqBackBar(aLow,AnnTotalBars,true);
            populateArray(Close,aClose,AnnTotalBars);
            int hiClose =CalcSeqBackBar(aClose,AnnTotalBars);
            int loClose =CalcSeqBackBar(aClose,AnnTotalBars,true);
            populateArray(Open,aOpen,AnnTotalBars);
            int hiOpen  =CalcSeqBackBar(aOpen,AnnTotalBars);
            int loOpen  =CalcSeqBackBar(aOpen,AnnTotalBars,true);
            double avgLo= ( loOpen+loHigh+loLow+loClose )/4;
            double avgHi= ( hiOpen+hiHigh+hiLow+hiClose )/4;
   
         //--- Assert find the closest OHLC bars to the validity bars.
            if( hiRsi > loRsi && avg > rsi[1] )
            {
                //Print("Continuation up rsi[1]=", rsi[1] ," AvgNN=", avg, " (validity ", hiRsi, " bars).");
                if( MathAbs(avgLo-hiRsi) > MathAbs(avgHi-hiRsi) )
                //--- Assert smaller delta of number of bars implies greater correlation between SharpeRSI direction and OHLC trend.
                   //Print("Continuation of UP trend");
                   ExtMapBuffer1[0]=0;
                else
                   //Print("Continuation of DN trend");
                   ExtMapBuffer1[0]=0;
            }
            else if( hiRsi > loRsi && avg <= rsi[1] )
            {
                Print("REVERSAL up rsi[1]=", rsi[1] ," AvgNN=", avg, " (validity ", hiRsi, " bars).");
                if( MathAbs(avgLo-hiRsi) > MathAbs(avgHi-hiRsi) )
                //--- Assert smaller delta of number of bars implies greater correlation between SharpeRSI direction and OHLC trend.
                   //Print("REVERSAL of UP trend");
                   ExtMapBuffer1[0]=hiRsi;
                else
                   //Print("REVERSAL of DN trend");
                   ExtMapBuffer1[0]=-hiRsi;
            }
            else if( loRsi > hiRsi && rsi[1] > avg )
            {
                Print("Continuation dn rsi[1]=", rsi[1] ," AvgNN=", avg, " (validity ", loRsi, " bars).");
                if( MathAbs(avgLo-loRsi) > MathAbs(avgHi-loRsi) )
                //--- Assert smaller delta of number of bars implies greater correlation between SharpeRSI direction and OHLC trend.
                   //Print("Continuation of UP trend");
                   ExtMapBuffer1[0]=0;
                else
                   //Print("Continuation of DN trend");
                   ExtMapBuffer1[0]=0;
            }
            else if( loRsi > hiRsi && rsi[1] <= avg )
            {
                Print("REVERSAL dn rsi[1]=", rsi[1] ," AvgNN=", avg, " (validity ", loRsi, " bars).");
                if( MathAbs(avgLo-loRsi) > MathAbs(avgHi-loRsi) )
                //--- Assert smaller delta of number of bars implies greater correlation between SharpeRSI direction and OHLC trend.
                   //Print("REVERSAL of UP trend");
                   ExtMapBuffer1[0]=loRsi;
                else
                   //Print("REVERSAL of DN trend");
                   ExtMapBuffer1[0]=-loRsi;
            }
            else
            {
                Print("Indeterminate trend for last ", hiRsi, " bars.");
                ExtMapBuffer1[0]=0;
            }
            //Print("hiHigh=", hiHigh," loHigh=", loHigh," hiLow=", hiLow," loLow=", loLow);
            //Print("hiOpen=", hiOpen," loOpen=", loOpen," hiClose=", hiClose," loClose=", loClose);
            
         }
      }
   }
   
//----
   debug="SharpeRSI rsi[1]="+DoubleToStr(rsi[1],4);
   debug=debug+" Bars="+AnnTotalBars;
   debug=debug+" mse="+DoubleToStr(GetMse()*1000,4);
   if(sumRsi==0.0)
      debug=debug+" No cons (+"+posCount+" -"+negCount+")";
   else
      debug=debug+" Avg NN="+DoubleToStr(sumRsi/AnnCommitteeSize,4);
   IndicatorShortName(debug);
   
   return(0);
}

void populateRsi(int n)
{
//--- Assert resize dynamic input Array.
    ArrayResize(inRsi, n);
    
//--- Assert populate inputs for Max bars.
    for(int i=0; i<n; i++)
    {
    //--- Assert first element of Array is the last Bar
    //      Last element of inRsi[] is Bar[1].
        if(rsi[ n - i ]!=0) inRsi[ i ] = rsi[ n - i ]/100;
        else inRsi[ i ]=0;
        
        /*if(i==n-1) Print("inRsi[",i,"]=",DoubleToStr(inRsi[i],5),"; rsi[",n-i,"]=",DoubleToStr(rsi[n-i],5));*/
    }
    /*Print("ArraySize=",ArraySize(inRsi));*/
}
void populateArray(double srcArray[], double& dstArray[], int n, int shift=1)
{
//--- Assert resize dynamic input Array.
    ArrayResize(dstArray, n);
//--- Assert populate inputs for Max bars.
    for(int i=0; i<n; i++)
        dstArray[i]  = srcArray[i+shift];
}
int CalcLookBackBar(int min, int max, int bar)
{
//--- Assert Determine volatility on close prices of last THIRTY bars.
   double volatility1=iStdDev(NULL,0,30,0,MODE_SMA,PRICE_CLOSE,1);
   double volatility2=iStdDev(NULL,0,30,0,MODE_SMA,PRICE_CLOSE,2);
   double volatilityDelta;
//--- Assert Calculate the delta volatility
   volatilityDelta  = (volatility1 - volatility2) / volatility1;
//--- Assert Calculate dynamic Lookback period once per bar
   bar              = bar * (1 + volatilityDelta);
   bar              = MathRound(bar);
//--- Assert Lookback period is within range of ceiling and floor
   bar              = MathMin(max,bar);
   bar              = MathMax(min,bar);
   
   return(bar);
}
int CalcSeqBackBar(double& indicator[], int max, bool lo=false, int shift=1)
{
    int seq=shift;
    double next, prev;
    
    next=indicator[0+shift];
    for(int i=1; i<max; i++)
    {
        prev=indicator[i+shift];
        if(lo)
            if(next<prev) seq++;
            else break;
        else
            if(next>prev) seq++;
            else break;
        next=prev;
    }
    return(seq);
}
//+------------------------------------------------------------------+