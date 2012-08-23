//|-----------------------------------------------------------------------------------------|
//|                                                                              TDLine.mq4 |
//|                                                            Copyright © 2012, Dennis Lee |
//| Assert History                                                                          |
//| 0.2.0   Added externs for Line properties and comments. Fixed function getTDArrayIndex  |
//|            to return -1 if TDPoint not found.                                           |
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
extern int        LookBackBars            = 100;
extern int        TDPointLevel            = 3;
/*extern string     l2_1                    = "Style: 0-Solid, 1-Dash, 2-Dot, 3 or 4";
extern int        TDLineStyle             = 1;*/
extern string     l2_2                    = "Ray: 0-None, 1-Show";
extern int        TDLineRay               = 1;
extern int        TDLineWidth             = 2;
extern bool       ShowComment             = false;
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
string IndVer="0.2.0";
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
int indexDemand0;
int indexDemand1;
int indexSupply0;
int indexSupply1;
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
   if(ShowComment) Comment("");
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
      indexDemand0 = getTDArrayIndex(arrDemand,LookBackBars,  -TDPointLevel, 1);
      indexDemand1 = getTDArrayIndex(arrDemand,LookBackBars,  -TDPointLevel, 2);
      if( indexDemand0>=0 )   indexDemand0 += TDPointLevel;
      if( indexDemand1>=0 )   indexDemand1 += TDPointLevel;
      if(indexDemand0>=0 && indexDemand1>=0) trendDemandStr = DivDrawPriceTrendLine(
         Time[indexDemand1], Time[indexDemand0], Low[indexDemand1], Low[indexDemand0], Thistle, STYLE_SOLID, TDLineWidth, TDLineRay);

      DivDelete(trendSupplyStr);
      indexSupply0 = getTDArrayIndex(arrSupply,LookBackBars,   TDPointLevel,  1);
      indexSupply1 = getTDArrayIndex(arrSupply,LookBackBars,   TDPointLevel,  2);
      if( indexSupply0>=0 )   indexSupply0 += TDPointLevel;
      if( indexSupply1>=0 )   indexSupply1 += TDPointLevel;
      if(indexSupply0>=0 && indexSupply1>=0) trendSupplyStr = DivDrawPriceTrendLine(
         Time[indexSupply1], Time[indexSupply0], High[indexSupply1], High[indexSupply0], Red, STYLE_SOLID, TDLineWidth, TDLineRay);
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
   if( ShowComment ) Comment(IndComment());
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
   if(count>=rank) return( pos );
   else return(-1);
}
//|-----------------------------------------------------------------------------------------|
//|                                     C O M M E N T                                       |
//|-----------------------------------------------------------------------------------------|
string IndComment(string cmt="")
{
   string strtmp = cmt+"-->"+IndName+" "+IndVer+"<--";
   strtmp=strtmp+"\n";

//--- Assert wave properties here
   strtmp=strtmp+"  Use Wave:";
   if( UseWave1ReverseBreak )    strtmp = strtmp+"  1";
   if( UseWave2GapBreak )        strtmp = strtmp+"  2";
   if( UseWave3PressureBreak )   strtmp = strtmp+"  3";
   if( !UseWave1ReverseBreak && !UseWave2GapBreak && !UseWave3PressureBreak)
                                 strtmp = strtmp+"  None";
   strtmp=strtmp+"\n";
//--- Assert line properties here
   strtmp=strtmp+"  Supply:  ";
   if( indexSupply1>=0 )
      strtmp=strtmp+DoubleToStr(High[indexSupply1],5)+"  ";
   if( indexSupply0>=0 )
      strtmp=strtmp+DoubleToStr(High[indexSupply0],5);
   strtmp=strtmp+"\n";
   strtmp=strtmp+"  Demand:  ";
   if( indexDemand1>=0 )
      strtmp=strtmp+DoubleToStr(Low[indexDemand1],5)+"  ";
   if( indexDemand0>=0 )
      strtmp=strtmp+DoubleToStr(Low[indexDemand0],5);
   strtmp=strtmp+"\n";
                                 
//--- Assert additional comments here
   
   strtmp=strtmp+"\n";
   return(strtmp);
}
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
