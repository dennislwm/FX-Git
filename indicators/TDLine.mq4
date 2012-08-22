//|-----------------------------------------------------------------------------------------|
//|                                                                              TDLine.mq4 |
//|                                                            Copyright © 2012, Dennis Lee |
//| Assert History                                                                          |
//| 0.1.0   Originated from Perl J (2008) DeMark Indicators (Chapter 4).                    |
//|            Implemented TDPoint and TDLine. (To be implemented Disqualifier, Qualifiers, |
//|            Objective, and exits.                                                        |
//|-----------------------------------------------------------------------------------------|
#property copyright "Copyright © 2012, Dennis Lee"
#property link      ""

#property indicator_separate_window
#property indicator_minimum -10
#property indicator_maximum 10
#property indicator_buffers 3
#property indicator_color1 Yellow
#property indicator_color2 Thistle
#property indicator_color3 Red

//|-----------------------------------------------------------------------------------------|
//|                           E X T E R N A L   V A R I A B L E S                           |
//|-----------------------------------------------------------------------------------------|
extern string     l1                      = "Wave Properties";
extern bool       UseWave1ReverseBreak    = true;
extern bool       UseWave2GapBreak        = true;
extern bool       UseWave3PressureBreak   = true;
extern string     l2                      = "Line Properties";
extern int        LookBackBars            = 40;
extern int        TDPointLevel            = 3;
extern string     d1                      = "Debug: 0-None; 1-Minimal; 2-Stack";
extern int        IndViewDebug            = 0;
extern string     d2                      = "No stacking of debug messages; View every n";
extern int        IndViewDebugNoStack     = 1000;
extern string     d3                      = "View debug every n ... n+m";
extern int        IndViewDebugNoStackEnd  = 0;
#include    <PlusInit.mqh>
#include    <PlusDiv.mqh>
//|-----------------------------------------------------------------------------------------|
//|                           I N T E R N A L   V A R I A B L E S                           |
//|-----------------------------------------------------------------------------------------|
string IndName="TDLine";
string IndVer="0.1.0";
//---- Assert indicators for outputs (1) and calculations (2)
double ExtMapBuffer1[];    // wave signal
double ExtMapBuffer2[];    // TD Demand Points
double ExtMapBuffer3[];    // TD Supply Points
/*double ExtMapBuffer4[];    // signal of sharpe
double ExtMapBuffer5[];    // histogram of sharpe
double ExtMapBuffer6[];    // cross product of deviation from mean
double ExtMapBuffer7[];    // ema fast of sharpe
double ExtMapBuffer8[];    // ema slow of sharpe*/
//--- Assert variables used by TD Point
int arrDemand[];
int arrSupply[];
//--- Assert variables used by TD Line
string trendDemandStr;
string trendSupplyStr;
//--- Assert variables to detect new bar
int nextBarTime;

//|-----------------------------------------------------------------------------------------|
//|                             I N I T I A L I Z A T I O N                                 |
//|-----------------------------------------------------------------------------------------|
int init()
  {
//---- indicators
   IndicatorBuffers(3);
   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexStyle(2,DRAW_HISTOGRAM);
   /*SetIndexStyle(3,DRAW_LINE);
   SetIndexStyle(4,DRAW_HISTOGRAM);
   SetIndexStyle(5,DRAW_NONE);
   SetIndexStyle(6,DRAW_NONE);
   SetIndexStyle(7,DRAW_NONE);*/
   
   IndicatorDigits(Digits+10);
   SetIndexDrawBegin(0,TDPointLevel);
   SetIndexDrawBegin(1,TDPointLevel);
   SetIndexDrawBegin(2,TDPointLevel);
   /*SetIndexDrawBegin(3,EmaSlow);
   SetIndexDrawBegin(4,EmaSlow);
   SetIndexDrawBegin(5,EmaSlow);
   SetIndexDrawBegin(6,EmaSlow);
   SetIndexDrawBegin(7,EmaSlow);*/

   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexBuffer(1,ExtMapBuffer2);
   SetIndexBuffer(2,ExtMapBuffer3);
   /*SetIndexBuffer(3,ExtMapBuffer4);
   SetIndexBuffer(4,ExtMapBuffer5);
   SetIndexBuffer(5,ExtMapBuffer6);
   SetIndexBuffer(6,ExtMapBuffer7);
   SetIndexBuffer(7,ExtMapBuffer8);*/
//----
   IndicatorShortName(IndName+" "+IndVer);
   InitInit();
   DivInit(IndName+" "+IndVer);
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
   DivDeInit();
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

   string debug;
   
//---- check for possible errors
   if (used_bars<0) return(-1);
//---- last counted bar will be recounted
   if (used_bars>0) used_bars--;
   unused_bars=Bars-used_bars;

//--- Assert array resize
   if( ArraySize(arrDemand)!= LookBackBars ) ArrayResize( arrDemand, LookBackBars );
   if( ArraySize(arrSupply)!= LookBackBars ) ArrayResize( arrSupply, LookBackBars );

//--- Assert generate TD point
   if(isNewBar())
   {
      calcTDDemandPoint( arrDemand, LookBackBars, TDPointLevel );
      calcTDSupplyPoint( arrSupply, LookBackBars, TDPointLevel );

      DivDelete(trendDemandStr);
      int index0 = getTDArrayIndex(arrDemand,LookBackBars,  -TDPointLevel, 1);
      int index1 = getTDArrayIndex(arrDemand,LookBackBars,  -TDPointLevel, 2);
      index0 += TDPointLevel;
      index1 += TDPointLevel;
      trendDemandStr = DivDrawPriceTrendLine(
         Time[index1], Time[index0], Low[index1], Low[index0], Thistle, STYLE_SOLID, TDPointLevel, 1);

      DivDelete(trendSupplyStr);
      index0 = getTDArrayIndex(arrSupply,LookBackBars,   TDPointLevel,  1);
      index1 = getTDArrayIndex(arrSupply,LookBackBars,   TDPointLevel,  2);
      index0 += TDPointLevel;
      index1 += TDPointLevel;
      trendSupplyStr = DivDrawPriceTrendLine(
         Time[index1], Time[index0], High[index1], High[index0], Red, STYLE_SOLID, TDPointLevel, 1);
   }
   
//---- Assert count from last bar (function Bars) to current bar (0)
   for (i=unused_bars-1;i>=0;i--)
   {
   //---- Assert TD point values in integer
      if (i < LookBackBars )
      {
         ExtMapBuffer2[ i + TDPointLevel ] = arrDemand[ i ];
         ExtMapBuffer3[ i + TDPointLevel ] = arrSupply[ i ];
         IndDebugPrint( 2, "start",
            IndDebugInt("i",i)+
            IndDebugDbl("arrDemand[]",arrDemand[i])+
            IndDebugDbl("arrSupply[]",arrSupply[i]) );
      }
   }
   
//----
   debug=IndName+" "+IndVer;
   debug=debug+" Bars="+DoubleToStr(LookBackBars,0)+" Level="+DoubleToStr(TDPointLevel,0);
   IndicatorShortName(debug);
   
   return(0);
}

//|-----------------------------------------------------------------------------------------|
//|                           I N T E R N A L   F U N C T I O N S                           |
//|-----------------------------------------------------------------------------------------|
void calcTDDemandPoint(int &dstArray[], int n, int level=1)
{
   bool isOkLhs;
   bool isOkRhs;
   int curr;
   double tdPointPrice;
//--- Assert populate inputs for Max bars.
   for(int i=0; i<n; i++)
   {
   //--- Assert first element of Array[0] is the current Bar[0]
   //       Last element of Array[n-1] is Bar[n-1].
   //--- Assert a Level 5 TD Demand Point is a low that has five higher lows on either side.
   //       Level is also shift, i.e. Level 5 is shift 5.
   //       First element of Array[0] is Bar[5].
   //       Last element of Array[n-1] is Bar[n+5-1].
      curr           = i + level;
      tdPointPrice   = Low[curr];
   //--- Assert assume current bar is a TD Point, unless shown otherwise
      isOkLhs = true;
      isOkRhs = true;
      for(int j=1; j<=level; j++)
      {
      //--- Check Rhs
         if( Low[curr-j] <= tdPointPrice ) isOkRhs = false;
      //--- Check Lhs
         if( Low[curr+j] <= tdPointPrice ) isOkLhs = false;
      }
   //--- Assert write to array only if TD Point exists.
      if( isOkLhs && isOkRhs ) dstArray[i] = -level;
      else dstArray[i] = 0;
   }
}
void calcTDSupplyPoint(int &dstArray[], int n, int level=1)
{
   bool isOkLhs;
   bool isOkRhs;
   int curr;
   double tdPointPrice;
//--- Assert populate inputs for Max bars.
   for(int i=0; i<n; i++)
   {
   //--- Assert first element of Array[0] is the current Bar[0]
   //       Last element of Array[n-1] is Bar[n-1].
   //--- Assert a Level 5 TD Supply Point is a high that has five lower highs on either side.
   //       Level is also shift, i.e. Level 5 is shift 5.
   //       First element of Array[0] is Bar[5].
   //       Last element of Array[n-1] is Bar[n+5-1].
      curr           = i + level;
      tdPointPrice   = High[curr];
   //--- Assert assume current bar is a TD Point, unless shown otherwise
      isOkLhs = true;
      isOkRhs = true;
      for(int j=1; j<=level; j++)
      {
      //--- Check Rhs
         if( High[curr-j] >= tdPointPrice ) isOkRhs = false;
      //--- Check Lhs
         if( High[curr+j] >= tdPointPrice ) isOkLhs = false;
      }
   //--- Assert write to array only if TD Point exists.
      if( isOkLhs && isOkRhs ) dstArray[i] = level;
      else dstArray[i] = 0;
   }
}
int getTDArrayIndex(int srcArray[], int n, int level=1, int rank=1)
{
   int pos;
   int count;
   for(int i=0; i<n; i++)
   {
      if( srcArray[i] == level ) 
      {
         count ++;
         pos = i;
      }
      if( count >= rank ) break;
   }
   return( pos );
}
//|-----------------------------------------------------------------------------------------|
//|                                     C O M M E N T                                       |
//|-----------------------------------------------------------------------------------------|
void IndDebugPrint(int dbg, string fn, string msg)
{
   static int noStackCount;
   if(IndViewDebug>=dbg)
   {
      if(dbg>=2 && IndViewDebugNoStack>0)
      {
         if( MathMod(noStackCount,IndViewDebugNoStack) <= IndViewDebugNoStackEnd )
            Print(IndViewDebug,"-",noStackCount,":",fn,"(): ",msg);
            
         noStackCount ++;
      }
      else
         Print(IndViewDebug,":",fn,"(): ",msg);
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
