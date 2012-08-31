//|-----------------------------------------------------------------------------------------|
//|                                                                             TDSetup.mq4 |
//|                                                            Copyright © 2012, Dennis Lee |
//| Assert History                                                                          |
//| 1.2.2   Fixed minor bug to find the TD Buy / Sell Setup that is completed. A completed  |
//|            setup is indicated by the values FOUR (4) or FIVE (5).                       |
//| 1.2.1   Added TWO (2) global boolean variables to indicate when UpLine and DnLine are   |
//|            broken. The variable names are IsOkUpLine and IsOkDnLine, with a prefix,     |
//|            i.e. EURUSD_M15_IsOkUpLine and EURUSD_M15_IsOkDnLine.                        |
//| 1.2.0   Generate a wave signal +/- FIVE (5) if TD Sell/Buy Setup does not break the     |
//|            Resistance/Support lines, respectively.                                      |
//| 1.1.0   Added TDST Support and Resistance lines. If market closes beneath TDST Support  |
//|            before completing a TD Buy Setup, there is an increased probability that the |
//|            downtrend continues toward a TD Countdown 13. Conversely, if market closes   |
//|            above TDST Resistance before completing a TD Sell Setup, there is increased  |
//|            probability that the uptrend continues toward a TD Countdown THIRTEEN (13).  |
//|            TDST Support is drawn at the low of the bar, where an initiation of TD Sell  |
//|            Setup occured (that is completed?). Conversely, TDST Resistance is at the    |
//|            high of the bar, where an initiation of a recent TD Buy Setup occured.       |
//| 1.00    Standalone Tom DeMark's Setup indicator (wave signal).                          |
//|-----------------------------------------------------------------------------------------|
#property copyright "Copyright © 2012, Dennis Lee"
//---- indicator settings
#property  indicator_separate_window
#property  indicator_buffers 3
#property  indicator_color1  Thistle
#property  indicator_color2  FireBrick
#property  indicator_color3  Green
#property  indicator_maximum 4
#property  indicator_minimum -4
//|-----------------------------------------------------------------------------------------|
//|                           E X T E R N A L   V A R I A B L E S                           |
//|-----------------------------------------------------------------------------------------|
extern string     l1                      = "Setup Properties";
extern string     l2                      = "Line Properties";
extern string     l2_2                    = "Ray: 0-None, 1-Show";
extern int        TDLineRay               = 1;
extern int        TDLineWidth             = 2;
extern bool       IndShowComment          = false;
extern bool       IndViewDebugNotify      = false;
extern int        IndViewDebug            = 1;
extern int        IndViewDebugNoStack     = 1000;
extern int        IndViewDebugNoStackEnd  = 10;
#include    <PlusInit.mqh>
#include    <PlusDiv.mqh>
//|-----------------------------------------------------------------------------------------|
//|                           I N T E R N A L   V A R I A B L E S                           |
//|-----------------------------------------------------------------------------------------|
string     IndName="TDSetup";
string     IndVer="1.2.2";
//---- Assert indicator buffers for output(2) and calculation(1)
double     TDSetup[];
double     TDSetupFlip[];
double     TDCountdownFlip[];
//---- Assert variables used by TDST Support and Resistance
string     TDUpLine;
string     TDDnLine;
int        barUpLine=-1;
int        barDnLine=-1;
bool       isOkUpLine=false;
bool       isOkDnLine=false;
//--- Assert variables to detect new bar
int nextBarTime;
//|-----------------------------------------------------------------------------------------|
//|                             I N I T I A L I Z A T I O N                                 |
//|-----------------------------------------------------------------------------------------|
int init()
{
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
   IndicatorShortName(IndName+" "+IndVer);
//---- Assert Init includes
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
   if(IndShowComment) Comment("");
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
//---- Assert calculate TDST Support and Resistance lines
   if(isNewBar())
   {
      double barNinth   = -1;
      double barTenth   = -1;
      double barFirst   = -1;
   //---- Assert find completed TD Buy Setup (High of first bar will be resistance line)
      barNinth    = findTDSetupIndex( TDSetup, -4, ArraySize(TDSetup)-0,         0 );
      barTenth    = findTDSetupIndex( TDSetup, -5, ArraySize(TDSetup)-0,         0 );
      if( barNinth >= 0 && barTenth >= 0 )
         barNinth = MathMin( barNinth, barTenth );
      if( barNinth >= 0 )
         barFirst = findTDSetupIndex( TDSetup, -2, ArraySize(TDSetup)-barNinth,  barNinth);
      if( barNinth >= 0 && barFirst >= 0 )
      {
      //---- Assert that line is not the same as previous line
         if( barFirst != barUpLine )
         {
            barUpLine   = barFirst;
            DivDelete( TDUpLine );
            TDUpLine    = DivDrawPriceTrendLine( Time[barUpLine], Time[barUpLine-1],
               High[barUpLine], High[barUpLine], Red, STYLE_SOLID, TDLineWidth, TDLineRay);
         }
      }
      isOkUpLine=isUpLineIntact( 1, barUpLine );
   //---- Assert set global boolean variable
      string gTDIsOkUpLineStr = StringConcatenate( Symbol(), "_", Period(), "_IsOkUpLine" );
      GlobalVariableSet( gTDIsOkUpLineStr, isOkUpLine );
      barNinth    = -1;
      barTenth    = -1;
      barFirst    = -1;
   //---- Assert find completed TD Sell Setup (Low of first bar will be support line)
      barNinth    = findTDSetupIndex( TDSetup, 4, ArraySize(TDSetup)-0,          0 );
      barTenth    = findTDSetupIndex( TDSetup, 5, ArraySize(TDSetup)-0,          0 );
      if( barNinth >= 0 && barTenth >= 0 )
         barNinth = MathMin( barNinth, barTenth );
      if( barNinth >= 0 )
         barFirst = findTDSetupIndex( TDSetup, 2, ArraySize(TDSetup)-barNinth,   barNinth);
      if( barNinth >=0 && barFirst >= 0 )
      {
      //---- Assert that line is not the same as previous line
         if( barFirst != barDnLine )
         {
            barDnLine   = barFirst;
            DivDelete( TDDnLine );
            TDDnLine    = DivDrawPriceTrendLine( Time[barDnLine], Time[barDnLine-1],
               Low[barDnLine], Low[barDnLine], Thistle, STYLE_SOLID, TDLineWidth, TDLineRay);
         }
      }
      isOkDnLine=isDnLineIntact( 1, barDnLine );
   //---- Assert set global boolean variable
      string gTDIsOkDnLineStr = StringConcatenate( Symbol(), "_", Period(), "_IsOkDnLine" );
      GlobalVariableSet( gTDIsOkDnLineStr, isOkDnLine );
   }
//---- Assert apply wave signal +/- FIVE (5) retrospectively
   for (i=barUpLine;i>=0;i--)
   {
      if(isOkUpLine)
      {
         if( TDSetup[i]==4 )  TDSetup[i]=5;
      }
      else
      {
         if( TDSetup[i]==5 )  TDSetup[i]=4;
      }
   }
   for (i=barDnLine;i>=0;i--)
   {
      if(isOkDnLine)
      {
         if( TDSetup[i]==-4 )  TDSetup[i]=-5;
      }
      else
      {
         if( TDSetup[i]==-5 )  TDSetup[i]=-4;
      }
   }

   if(IndShowComment)   Comment(IndComment());
   else                 
   {
      string strtmp  = IndName+" "+IndVer;
      if(isOkUpLine)
         strtmp      = strtmp + " Up Intact";
      else
         strtmp      = strtmp + " Up Broken";
      if(isOkDnLine)
         strtmp      = strtmp + " Dn Intact";
      else
         strtmp      = strtmp + " Dn Broken";
      IndicatorShortName(strtmp);
   }
   return(0);
}
//|-----------------------------------------------------------------------------------------|
//|                           I N T E R N A L   F U N C T I O N S                           |
//|-----------------------------------------------------------------------------------------|
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
      IndDebugPrint( 2, "iTDSetupFlip", 
         IndDebugInt("i",i)+
         " Bearish TD Price Flip initiate TD Buy Setup" );
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
      IndDebugPrint( 2, "iTDSetupFlip",
         IndDebugInt("i",i)+
         " Bullish TD Price Flip initiate TD Sell Setup" );
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
      IndDebugPrint( 2, "iTDSetupPerfect",
         IndDebugInt("i",i)+
         IndDebugDbl("high6",high6)+
         IndDebugDbl("high7",high7)+
         " sell imperfection initiated." );
   }
//       Assert exit if there is a next imperfection
   else if (simperfect && setup[i]==3)
   {
      high6=High[i+3];
      high7=High[i+2];
      IndDebugPrint( 2, "iTDSetupPerfect",
         IndDebugInt("i",i)+
         IndDebugDbl("new high6",high6)+
         IndDebugDbl("new high7",high7)+
         " sell imperfection interrupted by another imperfection." );
   }
//       Assert exit if there is a perfection
   else if (simperfect && setup[i]==4)
   {
      simperfect=false;
      IndDebugPrint( 2, "iTDSetupPerfect",
         IndDebugInt("i",i)+
         " sell imperfection interrupted by another perfection (closed).");
   }
//       Assert imperfection becomes perfection
//          If perfection is not met, a subsequent high must be MORE
//             than, or equal to, the highs of bars 6 and 7.
   else if (simperfect && High[i]>=high6 && High[i]>=high7)
   {
      setup[i]=4;
      simperfect=false;
      IndDebugPrint( 2, "iTDSetupPerfect",
         IndDebugInt("i",i)+
         " sell imperfection found a perfection (closed)." );
   }
//       Assert entry if there is an imperfection
   if (!bimperfect && setup[i]==-3)
   {
      low6=Low[i+3];
      low7=Low[i+2];
      bimperfect=true;
      IndDebugPrint( 2, "iTDSetupPerfect",
         IndDebugInt("i",i)+
         IndDebugDbl("low6",low6)+
         IndDebugDbl("low7",low7)+
         " buy imperfection initiated." );
   }
//       Assert exit if there is a next imperfection
   else if (bimperfect && setup[i]==-3)
   {
      low6=Low[i+3];
      low7=Low[i+2];
      IndDebugPrint( 2, "iTDSetupPerfect",
         IndDebugInt("i",i)+
         IndDebugDbl("new low6",low6)+
         IndDebugDbl("new low7",low7)+
         " buy imperfection interrupted by another imperfection." );
   }
//       Assert exit if there is a perfection
   else if (bimperfect && setup[i]==-4)
   {
      bimperfect=false;
      IndDebugPrint( 2, "iTDSetupPerfect",
         IndDebugInt("i",i)+
         " buy imperfection interrupted by another perfection (closed)." );
   }
//       Assert imperfection becomes perfection
//          If perfection is not met, a subsequent low must be LESS
//             than, or equal to, the lows of bars 6 and 7.
   else if (bimperfect && Low[i]<=low6 && Low[i]<=low7)
   {
      setup[i]=-4;
      bimperfect=false;
      IndDebugPrint( 2, "iTDSetupPerfect",
         IndDebugInt("i",i)+
         " buy imperfection found a perfection (closed)." );
   }
}
int findTDSetupIndex(double srcArray[], int val, int n, int start=0)
{
   bool bFound = false;
   for(int i=start; i<start+n; i++)
   {
      if( val == srcArray[i] )
      {
         bFound=true;
         break;
      }
   }
   if(bFound)  return(i);
   else        return(-1);
}
bool isUpLineIntact(int bar0, int bar1)
{
   if( bar1 < bar0 ) return( false );
   
   bool     isOk        = true;
   double   linePrice   = High[barUpLine];

//--- Assert check all lows between bar0 and bar1
   for(int i=bar0; i<=bar1; i++)
   {
      if( Close[i] > linePrice )
      {
         isOk = false;
         break;
      }
   }
   return(isOk);
}
bool isDnLineIntact(int bar0, int bar1)
{
   if( bar1 < bar0 ) return( false );
   
   bool     isOk        = true;
   double   linePrice   = Low[barDnLine];

//--- Assert check all lows between bar0 and bar1
   for(int i=bar0; i<=bar1; i++)
   {
      if( Close[i] < linePrice )
      {
         isOk = false;
         break;
      }
   }
   return(isOk);
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
   strtmp=strtmp+"\n";
//--- Assert line properties for Supply here
   strtmp=strtmp+"  Resistance:  ";
   if( StringLen(TDUpLine)>0 )
   {
      if(isOkUpLine)
      {
         strtmp=strtmp+"UpLine Intact  High="+DoubleToStr(High[barUpLine],5);
         strtmp=strtmp+"\n";
      }
      else
         strtmp=strtmp+"UpLine Broken\n";
   }
   else
      strtmp=strtmp+"No UpLine\n";
//--- Assert line properties for Supply here
   strtmp=strtmp+"  Support:  ";
   if( StringLen(TDDnLine)>0 )
   {
      if(isOkDnLine)   
      {
         strtmp=strtmp+"DnLine Intact  Low="+DoubleToStr(Low[barDnLine],5);
         strtmp=strtmp+"\n";
      }
      else                 
         strtmp=strtmp+"DnLine Broken\n";
   }
   else
      strtmp=strtmp+"No DnLine\n";
                                 
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
      {
         if(IndViewDebugNotify)  SendNotification( IndViewDebug + ":" + fn + "(): " + msg );
         Print(IndViewDebug,":",fn,"(): ",msg);
      }
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
//|-----------------------------------------------------------------------------------------|
//|                        E N D   O F   C U S T O M   I N D I C A T O R                    |
//|-----------------------------------------------------------------------------------------|