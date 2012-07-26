//|-----------------------------------------------------------------------------------------|
//|                                                                      SharpeRSI_Fann.mq4 |
//|                                                            Copyright © 2012, Dennis Lee |
//| Assert History                                                                          |
//| 1.22    Added multiplier. Change Strategy #2 to use Close price instead of HL prices.   |
//|            Multiplier works only when validity > 20, then factor is 1.1, 1.2, etc. when |
//|            validity is 21, 22, etc respectively. Otherwise, factor is 1.0 * cyclePip.   |
//| 1.21    Added Strategy #2 (default is false) that has the following characteristics:    |
//|            a) UseStrategy2 is true;                                                     |
//|            b) Divergence line on main chart is found;                                   |
//|            c) Cycle pip > 5;                                                            |
//|            d) Range of divergence line pip >= Cycle pip;                                |
//|            e) Validity of divergence line > validity of Strategy #1.                    |
//| 1.20    Draw divergence line on main chart.                                             |
//| 1.11    Added a global boolean variable to indicate when a new signal has formed. The   |
//|            variable is named NewBar, with a prefix, i.e. USDCAD_M30_NewBar.             |
//| 1.10    A wave signal generated has the following characteristics:                      |
//|            a) NN committee has to agree on a reversal of SharpeRSI;                     |
//|            b) length of SharpeRsi cannot exceed 5, if average length of trend below 3;  |
//|            c) a smaller delta between length of uptrend and length of SharpeRsi implies |
//|               a sell signal;                                                            |
//|            d) a smaller delta between length of downtrend and length of SharpeRsi       |
//|               implies a buy signal;                                                     |
//|            e) validity of wave signal is the minimum of either the length of SharpeRsi  |
//|               or the longest length of trend's OHLC.                                    |
//| 1.02    Fixed bug in shift, MetaTrader's OHLC[0] begins from bar 1, when passed as a    |
//|            parameter. Changed validity to the minimum of rsi and average bars.          |
//| 1.01    Fixed bug to disable signal when delta is larger than FIVE (5) and average bar  |
//|            in trend is smaller than THREE (3). Added DebugPrint and basic stats.        |
//| 1.00    Originated from standalone SharpeRSI_Ann 1.11 indicator with Neural Net, and    |
//|            adapted to incorporate PlusFann.                                             |
//|-----------------------------------------------------------------------------------------|
#property copyright "Copyright © 2012, Dennis Lee"
#property link      ""

#property indicator_separate_window
#property indicator_minimum -20
#property indicator_maximum 100
#property indicator_buffers 8
#property indicator_color1 Thistle
#property indicator_color2 Red
#property indicator_color3 Black
#property indicator_color4 Black
#property indicator_color5 Black

//|-----------------------------------------------------------------------------------------|
//|                           E X T E R N A L   V A R I A B L E S                           |
//|-----------------------------------------------------------------------------------------|
extern bool      UseStrategy2=false;
extern int       EmaFast=12;
extern int       EmaSlow=26;
extern int       EmaSignal=9;
#include    <PlusInit.mqh>
#include    <PlusFann.mqh>
#include    <PlusDiv.mqh>
//|-----------------------------------------------------------------------------------------|
//|                           I N T E R N A L   V A R I A B L E S                           |
//|-----------------------------------------------------------------------------------------|
string IndName="SharpeRSI_Fann";
string IndVer="1.22";
extern int       IndDebug=1;
extern int       IndDebugCount=1000;
int    IndCount;
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
//--- Assert variables used by statistics
bool   bContinueUp;
bool   bContinueDn;
bool   bReversalUp;
bool   bReversalDn;
int    cContinueUp;
int    cContinueDn;
int    cReversalUp;
int    cReversalDn;
int    iContinueUp;
int    iContinueDn;
int    iReversalUp;
int    iReversalDn;
//--- Assert variables to detect new bar
int    nextBarTime;

//|-----------------------------------------------------------------------------------------|
//|                             I N I T I A L I Z A T I O N                                 |
//|-----------------------------------------------------------------------------------------|
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
   IndicatorShortName(IndName+" "+IndVer);
   InitInit();
   DivInit(IndName+" "+IndVer);
   FannInit();
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

//|-----------------------------------------------------------------------------------------|
//|                             D E I N I T I A L I Z A T I O N                             |
//|-----------------------------------------------------------------------------------------|
int deinit()
  {
//----
   string gFredStr = StringConcatenate( Symbol(), "_", Period() );
   GlobalVariableDel( gFredStr );
//----
   DivDeInit();
   FannDeInit();
   return(0);
  }
//|-----------------------------------------------------------------------------------------|
//|                               M A I N   P R O C E D U R E                               |
//|-----------------------------------------------------------------------------------------|
int start()
{
//---- Assert variables used by count from last bar
   int i;
   int unused_bars;
   int used_bars=IndicatorCounted();

   string trendName;
   double sumMse;
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
   //--- Assert collate past predictions
      if( bContinueUp || bContinueDn || bReversalUp || bReversalDn )
      {
         if( bContinueUp && ExtMapBuffer2[1] > ExtMapBuffer2[2] )
         {
            Print( Symbol(),",",Period()," Last Correct Continuation Up: rsi[1]=",ExtMapBuffer2[1],">rsi[2]=",ExtMapBuffer2[2] );
            cContinueUp ++;
         }
         else
         {
            Print( Symbol(),",",Period()," Last Incorrect Continuation Up: rsi[1]=",ExtMapBuffer2[1],"!>rsi[2]=",ExtMapBuffer2[2] );
            iContinueUp ++;
         }
         if( bContinueDn && ExtMapBuffer2[1] < ExtMapBuffer2[2] )
         {
            Print( Symbol(),",",Period()," Last Correct Continuation Dn: rsi[1]=",ExtMapBuffer2[1],"<rsi[2]=",ExtMapBuffer2[2] );
            cContinueDn ++;
         }
         else
         {
            Print( Symbol(),",",Period()," Last Incorrect Continuation Dn: rsi[1]=",ExtMapBuffer2[1],"!<rsi[2]=",ExtMapBuffer2[2] );
            iContinueDn ++;
         }
         if( bReversalUp && ExtMapBuffer2[1] <= ExtMapBuffer2[2] )
         {
            Print( Symbol(),",",Period()," Last Correct Reversal Up: rsi[1]=",ExtMapBuffer2[1],"<=rsi[2]=",ExtMapBuffer2[2] );
            cReversalUp ++;
         }
         else
         {
            Print( Symbol(),",",Period()," Last Incorrect Reversal Up: rsi[1]=",ExtMapBuffer2[1],"!<=rsi[2]=",ExtMapBuffer2[2] );
            iReversalUp ++;
         }
         if( bReversalDn && ExtMapBuffer2[1] >= ExtMapBuffer2[2] )
         {
            Print( Symbol(),",",Period()," Last Correct Reversal Dn: rsi[1]=",ExtMapBuffer2[1],">=rsi[2]=",ExtMapBuffer2[2] );
            cReversalDn ++;
         }
         else
         {
            Print( Symbol(),",",Period()," Last Incorrect Reversal Dn: rsi[1]=",ExtMapBuffer2[1],"!>=rsi[2]=",ExtMapBuffer2[2] );
            iReversalDn ++;
         }
      }
      int correct =  cContinueUp + cContinueDn + cReversalUp + cReversalDn;
      int incorrect =iContinueUp + iContinueDn + iReversalUp + iReversalDn;
      Print( Symbol(),",",Period()," Correct Total=",DoubleToStr(correct,0)," Incorrect Total=",DoubleToStr(incorrect,0),
         " Correct Reversal=",DoubleToStr(cReversalUp+cReversalDn,0)," Incorrect Reversal=",DoubleToStr(iReversalUp+iReversalDn,0) );
      bContinueUp=false;   bContinueDn=false;
      bReversalUp=false;   bReversalDn=false;
      
      FannTotalBars = CalcLookBackBar(FannMinBars,FannMaxBars,FannTotalBars);
      posCount=0; negCount=0; sumRsi=0.0; sumMse=0.0;
   //--- Assert resize dynamic input Array.
      populateRsi(FannTotalBars);
      ArrayResize(outRsi,     FannCommitteeSize);
      if(FannTotalBars >= FannMinBars)
      {
         for(i=0; i<FannCommitteeSize; i++)
         {
            FannLoad(i);
            FannRetrain(inRsi, ArraySize(inRsi), i);
            outRsi[i] = FannPredict(inRsi, ArraySize(inRsi), i) * 100;
            sumRsi = sumRsi + outRsi[i];
            sumMse = sumMse + FannGetMse(i)*1000;
            if(outRsi[i]>=ExtMapBuffer2[1]) posCount ++;
            else negCount++;
         }
         
         if( posCount == FannCommitteeSize || negCount == FannCommitteeSize ) {}
         else sumRsi=0.0;
         if(sumRsi!=0.0) 
         {
            double avg=sumRsi/FannCommitteeSize;
            int hiRsi   =CalcSeqBackBar(ExtMapBuffer2,FannTotalBars);
            int loRsi   =CalcSeqBackBar(ExtMapBuffer2,FannTotalBars,true);
            populateArray(Open,aOpen,FannTotalBars);
            int hiOpen  =CalcSeqBackBar(aOpen,FannTotalBars,false,0);
            int loOpen  =CalcSeqBackBar(aOpen,FannTotalBars,true,0);
            populateArray(High,aHigh,FannTotalBars);
            int hiHigh  =CalcSeqBackBar(aHigh,FannTotalBars,false,0);
            int loHigh  =CalcSeqBackBar(aHigh,FannTotalBars,true,0);
            populateArray(Low,aLow,FannTotalBars);
            int hiLow   =CalcSeqBackBar(aLow,FannTotalBars,false,0);
            int loLow   =CalcSeqBackBar(aLow,FannTotalBars,true,0);
            populateArray(Close,aClose,FannTotalBars);
            int hiClose =CalcSeqBackBar(aClose,FannTotalBars,false,0);
            int loClose =CalcSeqBackBar(aClose,FannTotalBars,true,0);
            double avgLo= ( loOpen+loHigh+loLow+loClose )/4;
            double avgHi= ( hiOpen+hiHigh+hiLow+hiClose )/4;
            /*IndDebugPrint( 0, "start",
               IndDebugDbl("Open[0]",Open[0])+
               IndDebugDbl("High[0]",High[0])+
               IndDebugDbl("Low[0]",Low[0])+
               IndDebugDbl("Close[0]",Close[0]),
               false, 0 );
            IndDebugPrint( 0, "start",
               IndDebugDbl("Open[1]",Open[1])+
               IndDebugDbl("High[1]",High[1])+
               IndDebugDbl("Low[1]",Low[1])+
               IndDebugDbl("Close[1]",Close[1]),
               false, 0 );*/
   
         //--- Assert find the closest OHLC bars to the validity bars.
            if( hiRsi > loRsi && avg > ExtMapBuffer2[1] )
            {
               /*Print("Continuation up rsi[1]=", ExtMapBuffer2[1] ," AvgNN=", avg, " (validity ", hiRsi, " bars).");*/
               if( MathAbs(avgLo-hiRsi) > MathAbs(avgHi-hiRsi) )
               //--- Assert smaller delta of number of bars implies greater correlation between SharpeRSI direction and OHLC trend.
                  /*Print("Continuation of UP trend");*/
                  ExtMapBuffer1[0]=0;
               else
                  /*Print("Continuation of DN trend");*/
                  ExtMapBuffer1[0]=0;
               bContinueUp=true;
            }
            else if( hiRsi > loRsi && avg <= ExtMapBuffer2[1] )
            {
               Print("REVERSAL up rsi[1]=", ExtMapBuffer2[1] ," AvgNN=", avg, " (validity ", hiRsi, " bars).");
               if( hiRsi > 5 && avgHi < 3 && avgLo < 3 )
               {
                  ExtMapBuffer1[0]=0;
                  if( avgHi > avgLo )
                  //--- Assert draw trend lines on main chart
                     trendName=DivDrawPriceTrendLine(Time[1], Time[hiRsi+1], High[1], High[hiRsi+1], Green, STYLE_SOLID, 3);
                  else
                  //--- Assert draw trend lines on main chart
                     trendName=DivDrawPriceTrendLine(Time[1], Time[hiRsi+1], Low[1], Low[hiRsi+1], Green, STYLE_SOLID, 3);
               }
               else if( MathAbs(avgLo-hiRsi) > MathAbs(avgHi-hiRsi) )
               {
               //--- Assert smaller delta of number of bars implies greater correlation 
               //       between SharpeRSI direction and OHLC trend.
                  /*Print("REVERSAL of UP trend");*/
                  ExtMapBuffer1[0]=NormalizeDouble(MathMin( hiRsi, MathMax( hiOpen, MathMax( hiHigh, MathMax( hiLow, hiClose ) ) ) ),0);
               //--- Assert draw trend lines on main chart
                  trendName=DivDrawPriceTrendLine(Time[1], Time[hiRsi+1], High[1], High[hiRsi+1], Green, STYLE_SOLID, 3);
               }
               else
               {
                  /*Print("REVERSAL of DN trend");*/
                  ExtMapBuffer1[0]=-NormalizeDouble(MathMin( hiRsi, MathMax( loOpen, MathMax( loHigh, MathMax( loLow, loClose ) ) ) ),0);
               //--- Assert draw trend lines on main chart
                  trendName=DivDrawPriceTrendLine(Time[1], Time[hiRsi+1], Low[1], Low[hiRsi+1], Green, STYLE_SOLID, 3);
               }
               bReversalUp=true;
                
               IndDebugPrint( 1, "Reversal up rsi",
                  IndDebugDbl("hiOpen",hiOpen)+
                  IndDebugDbl("hiHigh",hiHigh)+
                  IndDebugDbl("hiLow",hiLow)+
                  IndDebugDbl("hiClose",hiClose)+
                  IndDebugDbl("avgHi",avgHi),
                  false, 0 );
               IndDebugPrint( 1, "Reversal up rsi",
                  IndDebugDbl("loOpen",loOpen)+
                  IndDebugDbl("loHigh",loHigh)+
                  IndDebugDbl("loLow",loLow)+
                  IndDebugDbl("loClose",loClose)+
                  IndDebugDbl("avgLo",avgLo),
                  false, 0 );
               IndDebugPrint( 1, "Reversal up rsi",
                  IndDebugDbl("deltaLo",avgLo-hiRsi)+
                  IndDebugDbl("deltaHi",avgHi-hiRsi)+
                  IndDebugInt("ExtMapBuffer1",ExtMapBuffer1[0]),
                  false, 0 );
            }
            else if( loRsi > hiRsi && ExtMapBuffer2[1] > avg )
            {
               /*Print("Continuation dn rsi[1]=", ExtMapBuffer2[1] ," AvgNN=", avg, " (validity ", loRsi, " bars).");*/
               if( MathAbs(avgLo-loRsi) > MathAbs(avgHi-loRsi) )
               //--- Assert smaller delta of number of bars implies greater correlation between SharpeRSI direction and OHLC trend.
                  /*Print("Continuation of UP trend");*/
                  ExtMapBuffer1[0]=0;
               else
                  /*Print("Continuation of DN trend");*/
                  ExtMapBuffer1[0]=0;
               bContinueDn=true;
            }
            else if( loRsi > hiRsi && ExtMapBuffer2[1] <= avg )
            {
               Print("REVERSAL dn rsi[1]=", ExtMapBuffer2[1] ," AvgNN=", avg, " (validity ", loRsi, " bars).");
               if( loRsi > 5 && avgHi < 3 && avgLo < 3 )
               {
                  ExtMapBuffer1[0]=0;
                  if( avgHi > avgLo )
                  //--- Assert draw trend lines on main chart
                     trendName=DivDrawPriceTrendLine(Time[1], Time[loRsi+1], High[1], High[loRsi+1], Green, STYLE_SOLID, 3);
                  else
                  //--- Assert draw trend lines on main chart
                     trendName=DivDrawPriceTrendLine(Time[1], Time[loRsi+1], Low[1], Low[loRsi+1], Green, STYLE_SOLID, 3);
               }
               else if( MathAbs(avgLo-loRsi) > MathAbs(avgHi-loRsi) )
               {
               //--- Assert smaller delta of number of bars implies greater correlation between SharpeRSI direction and OHLC trend.
                  /*Print("REVERSAL of UP trend");*/
                  ExtMapBuffer1[0]=NormalizeDouble(MathMin( loRsi, MathMax( hiOpen, MathMax( hiHigh, MathMax( hiLow, hiClose ) ) ) ),0);
                  trendName=DivDrawPriceTrendLine(Time[1], Time[loRsi+1], High[1], High[loRsi+1], Green, STYLE_SOLID, 3);
               }
               else
               {
                  /*Print("REVERSAL of DN trend");*/
                  ExtMapBuffer1[0]=-NormalizeDouble(MathMin( loRsi, MathMax( loOpen, MathMax( loHigh, MathMax( loLow, loClose ) ) ) ),0);
                  trendName=DivDrawPriceTrendLine(Time[1], Time[loRsi+1], Low[1], Low[loRsi+1], Green, STYLE_SOLID, 3);
               }
               bReversalDn=true;
                
               IndDebugPrint( 1, "Reversal dn rsi",
                  IndDebugDbl("hiOpen",hiOpen)+
                  IndDebugDbl("hiHigh",hiHigh)+
                  IndDebugDbl("hiLow",hiLow)+
                  IndDebugDbl("hiClose",hiClose)+
                  IndDebugDbl("avgHi",avgHi),
                  false, 0 );
               IndDebugPrint( 1, "Reversal up rsi",
                  IndDebugDbl("loOpen",loOpen)+
                  IndDebugDbl("loHigh",loHigh)+
                  IndDebugDbl("loLow",loLow)+
                  IndDebugDbl("loClose",loClose)+
                  IndDebugDbl("avgLo",avgLo),
                  false, 0 );
               IndDebugPrint( 1, "Reversal up rsi",
                  IndDebugDbl("deltaLo",avgLo-loRsi)+
                  IndDebugDbl("deltaHi",avgHi-loRsi)+
                  IndDebugInt("ExtMapBuffer1",ExtMapBuffer1[0]),
                  false, 0 );
            }
            else
            {
               Print("Indeterminate trend for last ", hiRsi, " bars.");
               ExtMapBuffer1[0]=0;
            }
         //--- Assert use Strategy #2 divergence (if true) and Strategy #1 reversal is true
            if( UseStrategy2 && StringLen(trendName)>0 )
            {
               bool     bFound=true;
               double   price0, price1;
               double   range;
               int      sign;
               double   time0, time1;
               int      validityBar;
            //--- Assert find the slope of the trend line on main chart
               if( ObjectFind(trendName)<0 )
               {
                  bFound = false;
               }
               else
               {
                  if( bReversalUp ) validityBar = hiRsi+1;
                  if( bReversalDn ) validityBar = loRsi+1;
                  
                  price0 = ObjectGetValueByShift(trendName, 1);
                  price1 = ObjectGetValueByShift(trendName, validityBar);
                  if( price0 > price1)
                  {
                     range = Close[1] - Low[validityBar];
                     sign  = 1;
                  }
                  else
                  {
                     range = High[validityBar] - Close[1];
                     sign  = -1;
                  }
               }
            //-- Assert if range of trend line is greater than cycle then generate wave signal
               if( bFound )
               {
                  int      cyclePip = CycleGap(60, Symbol(), Period());
                  int      rangePip = MathRound(range/InitPts);
               //--- Print Strategy #2 divergence
                  IndDebugPrint( 1, "Strategy #2 Divergence",
                     IndDebugDbl("price0",price0)+
                     IndDebugDbl("price1",price1)+
                     IndDebugInt("validityBar",validityBar)+
                     IndDebugInt("cyclePip",cyclePip)+
                     IndDebugInt("rangePip",rangePip)+
                     IndDebugInt("sign",sign),
                     false, 0 );
               
                  if( cyclePip >= 5 )
                     if( rangePip >= cyclePip )
                        if( validityBar > MathAbs(ExtMapBuffer1[0]) )
                        {
                           double   factor = MathMax( 1.0, (validityBar/10) - 1 );
                        //--- Print Strategy #2 divergence
                           IndDebugPrint( 1, "Strategy #2 Divergence passed cyclePip",
                              IndDebugInt("validityBar",validityBar)+
                              IndDebugDbl("factor",factor)+
                              IndDebugDbl("new cyclePip",factor*cyclePip),
                              false, 0 );
                              
                           if( rangePip >= factor*cyclePip )
                           {
                           //--- Print Strategy #2 divergence
                              IndDebugPrint( 1, "Strategy #2 Divergence overwrites Strategy #1",
                                 IndDebugInt("validityBar",validityBar)+
                                 IndDebugInt("ExtMapBuffer1",ExtMapBuffer1[0])+
                                 IndDebugInt("new wave",sign*validityBar),
                                 false, 0 );
                              
                              ExtMapBuffer1[0] = sign*validityBar;
                           }
                        }
               }
            }
            
            string gFredStr = StringConcatenate( Symbol(), "_", Period() );
            string gFredNewBarStr = StringConcatenate( Symbol(), "_", Period(), "_NewBar" );
            GlobalVariableSet( gFredStr, ExtMapBuffer1[0] );
            GlobalVariableSet( gFredNewBarStr, TRUE );
            bool newBar = GlobalVariableGet( gFredNewBarStr );
            IndDebugPrint( 0, IndName,
               IndDebugDbl(gFredStr,ExtMapBuffer1[0]) +
               IndDebugBln(gFredNewBarStr,newBar),
               false, 0 );
         }
      }
   }
   
//----
   debug=IndName+" "+IndVer+" rsi[1]="+DoubleToStr(ExtMapBuffer2[1],3);
   debug=debug+" Bars="+DoubleToStr(FannTotalBars,0);
   if(sumRsi==0.0)
      debug=debug+" No cons (+"+posCount+" -"+negCount+")";
   else
      debug=debug+" Avg NN="+DoubleToStr(sumRsi/FannCommitteeSize,3);
   IndicatorShortName(debug);
   
   return(0);
}

//|-----------------------------------------------------------------------------------------|
//|                           I N T E R N A L   F U N C T I O N S                           |
//|-----------------------------------------------------------------------------------------|
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
   int seq=0;
   double next, prev;
    
   /*IndDebugPrint( 1, "CalcSeqBackBar",
      IndDebugDbl("indicator[0]",indicator[0])+
      false, 0 );*/
    
   next=indicator[0+shift];
   for(int i=1; i<max; i++)
   {
      prev=indicator[i+shift];
      if(lo)
      {
         if(next<prev)
         {  
            IndDebugPrint( 2, "CalcSeqBackBar",
               IndDebugInt("i",i)+
               IndDebugDbl("next",next)+"<"+
               IndDebugDbl("prev",prev)+
               IndDebugInt("seq",seq),
               false, 0 );
            seq++;
         }
         else break;
      }
      else
      {
         if(next>prev)
         {
            IndDebugPrint( 2, "CalcSeqBackBar",
               IndDebugInt("i",i)+
               IndDebugDbl("next",next)+">"+
               IndDebugDbl("prev",prev)+
               IndDebugInt("seq",seq),
               true, 0 );
            seq++;
         }
         else break;
      }
      next=prev;
   }
   return(seq);
}
int CycleGap(int n, string sym, int period)
{
   double range, maxRange;
   for(int i=0; i<n; i++)
   {
      range = iHigh(sym,period,i) - iLow(sym,period,i);
      if( range > maxRange ) maxRange = range;
   }
   maxRange = MathRound(maxRange/InitPts);
   if( maxRange < 5 ) maxRange = 5;
   return( maxRange );
}
void IndDebugPrint(int dbg, string fn, string msg, bool incr=true, int mod=0)
{
   if(IndDebug>=dbg)
   {
      if(dbg>=2 && IndDebugCount>0)
      {
         if( MathMod(IndCount,IndDebugCount) == mod )
            Print(IndDebug,"-",IndCount,":",fn,"(): ",msg);
         if( incr )
            IndCount ++;
      }
      else
         Print(IndDebug,":",fn,"(): ",msg);
   }
}
string IndDebugInt(string key, int val)
{
   return( StringConcatenate(";",key,"=",val) );
}
string IndDebugDbl(string key, double val, int dgt=5)
{
   return( StringConcatenate(";",key,"=",NormalizeDouble(val,dgt)) );
}
string IndDebugStr(string key, string val)
{
   return( StringConcatenate(";",key,"=\"",val,"\"") );
}
string IndDebugBln(string key, bool val)
{
   string valType;
   if( val )   valType="true";
   else        valType="false";
   return( StringConcatenate(";",key,"=",valType) );
}
//+------------------------------------------------------------------+
