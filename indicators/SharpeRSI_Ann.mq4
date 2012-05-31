//|-----------------------------------------------------------------------------------------|
//|                                                                       SharpeRSI_Ann.mq4 |
//|                                                            Copyright © 2012, Dennis Lee |
//| Assert History                                                                          |
//| 1.11    Set global variable to NN value, e.g. USDCAD_M30=33.33                          |
//| 1.10    Fixed repainting code by using the Sharpe MACD AlleeH4 4.43.                    |
//| 1.00    Standalone SharpeRSI indicator with Neural Net wave signal. The length of the   |
//|            wave indicates the validity length in bars. E.g. 10 means SELL with a 10-bar |
//|            validity. Requires PlusAnn.                                                  |
//|-----------------------------------------------------------------------------------------|
#property copyright "Copyright © 2012, Dennis Lee"
#property link      ""

#property indicator_separate_window
#property indicator_minimum -20
#property indicator_maximum 20
#property indicator_buffers 8
#property indicator_color1 Thistle
#property indicator_color2 Red
#property indicator_color3 Yellow
#property indicator_color4 LimeGreen
#property indicator_color5 Cyan

#include    <PlusAnn.mqh>

//--- input parameters
extern int       EmaFast=12;
extern int       EmaSlow=26;
extern int       EmaSignal=9;
//---- Assert indicator name and version
string IndName="SharpeRSI_Ann";
string IndVer="1.11";
//---- Assert indicators for outputs (1) and calculations (7)
double ExtMapBuffer1[];    // wave signal by Neural Net
double ExtMapBuffer2[];    // rsi of sharpe
double ExtMapBuffer3[];    // macd of sharpe
double ExtMapBuffer4[];    // signal of sharpe
double ExtMapBuffer5[];    // histogram of sharpe
double ExtMapBuffer6[];    // cross product of deviation from mean
double ExtMapBuffer7[];    // ema fast of sharpe
double ExtMapBuffer8[];    // ema slow of sharpe
//---- Assert variables for cumulative mean of MACD
double mean=0;
double sum=0;
int    n=0;
//--- Assert variables used by Ann
double aOpen[];
double aHigh[];
double aLow[];
double aClose[];
double inRsi[];
double outRsi[];
double sumRsi=0.0;
int    posCount;
int    negCount;
//--- Assert variables to detect new bar
int    nextBarTime;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   IndicatorBuffers(8);
   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexStyle(2,DRAW_LINE);
   SetIndexStyle(3,DRAW_LINE);
   SetIndexStyle(4,DRAW_HISTOGRAM);
   SetIndexStyle(5,DRAW_NONE);
   SetIndexStyle(6,DRAW_NONE);
   SetIndexStyle(7,DRAW_NONE);
   
   IndicatorDigits(Digits+10);
   SetIndexDrawBegin(0,EmaSlow);
   SetIndexDrawBegin(1,EmaSlow);
   SetIndexDrawBegin(2,EmaSlow);
   SetIndexDrawBegin(3,EmaSlow);
   SetIndexDrawBegin(4,EmaSlow);
   SetIndexDrawBegin(5,EmaSlow);
   SetIndexDrawBegin(6,EmaSlow);
   SetIndexDrawBegin(7,EmaSlow);

   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexBuffer(1,ExtMapBuffer2);
   SetIndexBuffer(2,ExtMapBuffer3);
   SetIndexBuffer(3,ExtMapBuffer4);
   SetIndexBuffer(4,ExtMapBuffer5);
   SetIndexBuffer(5,ExtMapBuffer6);
   SetIndexBuffer(6,ExtMapBuffer7);
   SetIndexBuffer(7,ExtMapBuffer8);
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
   string gFredStr = StringConcatenate( Symbol(), "_", Period() );
   GlobalVariableDel( gFredStr );
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
      ExtMapBuffer6[i]=(Close[i]-mean)*(Close[i]-mean);
   }

   for (i=unused_bars-1;i>=0;i--)
   {
   //---- Assert EMA values in decimal
      ExtMapBuffer7[i]=MathSqrt(iMAOnArray(ExtMapBuffer6,0,EmaFast,0,MODE_EMA,i));
      ExtMapBuffer8[i]=MathSqrt(iMAOnArray(ExtMapBuffer6,0,EmaSlow,0,MODE_EMA,i));

   //---- Assert MACD values in decimal
      ExtMapBuffer3[i]=MathSqrt(iMAOnArray(ExtMapBuffer6,0,EmaFast,0,MODE_EMA,i))-MathSqrt(iMAOnArray(ExtMapBuffer6,0,EmaSlow,0,MODE_EMA,i));
   }

   for (i=unused_bars-1;i>=0;i--)
   {
   //---- Assert signal values in decimal
      ExtMapBuffer4[i]=iMAOnArray(ExtMapBuffer3,0,EmaSignal,0,MODE_EMA,i);

   //---- Assert histogram values in decimal 
      ExtMapBuffer5[i]=ExtMapBuffer3[i]-iMAOnArray(ExtMapBuffer3,0,EmaSignal,0,MODE_EMA,i);
      
   //---- Assert RSI values in decimal 
      ExtMapBuffer2[i]=iRSIOnArray(ExtMapBuffer3,0,14,i);
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
            if(outRsi[i]>=ExtMapBuffer2[1]) posCount ++;
            else negCount++;
         }
         if( posCount == AnnCommitteeSize || negCount == AnnCommitteeSize ) {}
         else sumRsi=0.0;
         if(sumRsi!=0.0) 
         {
            double avg=sumRsi/AnnCommitteeSize;
            int hiRsi   =CalcSeqBackBar(ExtMapBuffer2,AnnTotalBars);
            int loRsi   =CalcSeqBackBar(ExtMapBuffer2,AnnTotalBars,true);
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
            if( hiRsi > loRsi && avg > ExtMapBuffer2[1] )
            {
                //Print("Continuation up rsi[1]=", ExtMapBuffer2[1] ," AvgNN=", avg, " (validity ", hiRsi, " bars).");
                if( MathAbs(avgLo-hiRsi) > MathAbs(avgHi-hiRsi) )
                //--- Assert smaller delta of number of bars implies greater correlation between SharpeRSI direction and OHLC trend.
                   //Print("Continuation of UP trend");
                   ExtMapBuffer1[0]=0;
                else
                   //Print("Continuation of DN trend");
                   ExtMapBuffer1[0]=0;
            }
            else if( hiRsi > loRsi && avg <= ExtMapBuffer2[1] )
            {
                Print("REVERSAL up rsi[1]=", ExtMapBuffer2[1] ," AvgNN=", avg, " (validity ", hiRsi, " bars).");
                if( MathAbs(avgLo-hiRsi) > MathAbs(avgHi-hiRsi) )
                //--- Assert smaller delta of number of bars implies greater correlation between SharpeRSI direction and OHLC trend.
                   //Print("REVERSAL of UP trend");
                   ExtMapBuffer1[0]=hiRsi;
                else
                   //Print("REVERSAL of DN trend");
                   ExtMapBuffer1[0]=-hiRsi;
            }
            else if( loRsi > hiRsi && ExtMapBuffer2[1] > avg )
            {
                //Print("Continuation dn rsi[1]=", ExtMapBuffer2[1] ," AvgNN=", avg, " (validity ", loRsi, " bars).");
                if( MathAbs(avgLo-loRsi) > MathAbs(avgHi-loRsi) )
                //--- Assert smaller delta of number of bars implies greater correlation between SharpeRSI direction and OHLC trend.
                   //Print("Continuation of UP trend");
                   ExtMapBuffer1[0]=0;
                else
                   //Print("Continuation of DN trend");
                   ExtMapBuffer1[0]=0;
            }
            else if( loRsi > hiRsi && ExtMapBuffer2[1] <= avg )
            {
                Print("REVERSAL dn rsi[1]=", ExtMapBuffer2[1] ," AvgNN=", avg, " (validity ", loRsi, " bars).");
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
            string gFredStr = StringConcatenate( Symbol(), "_", Period() );
            GlobalVariableSet( gFredStr, ExtMapBuffer1[0] );
         }
      }
   }
   
//----
   debug=IndName+" "+IndVer+" rsi[1]="+DoubleToStr(ExtMapBuffer2[1],3);
   debug=debug+" Bars="+DoubleToStr(AnnTotalBars,0);
   debug=debug+" mse="+DoubleToStr(GetMse()*1000,1);
   if(sumRsi==0.0)
      debug=debug+" No cons (+"+posCount+" -"+negCount+")";
   else
      debug=debug+" Avg NN="+DoubleToStr(sumRsi/AnnCommitteeSize,3);
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
        if(ExtMapBuffer2[ n - i ]!=0) inRsi[ i ] = ExtMapBuffer2[ n - i ]/100;
        else inRsi[ i ]=0;
        
        /*if(i==n-1) Print("inRsi[",i,"]=",DoubleToStr(inRsi[i],5),"; ExtMapBuffer2[",n-i,"]=",DoubleToStr(ExtMapBuffer2[n-i],5));*/
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