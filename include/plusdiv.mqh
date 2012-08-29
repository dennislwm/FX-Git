//|-----------------------------------------------------------------------------------------|
//|                                                                             PlusDiv.mqh |
//|                                                            Copyright © 2012, Dennis Lee |
//| Assert History                                                                          |
//| 1.13    New function DivDelete(). Added parameter ray (default: 0) in functions         |
//|            DivDrawPriceTrendLine() and DivDrawIndicatorTrendLine().                     |
//| 1.12    Functions that draw trend line returns the name of line (string).               |
//| 1.11    Added parameter width (default: 1) in draw trend line functions.                |
//| 1.10    Added ShowArrows, BullishColor and BearishColor.                                |
//| 1.00    Created PlusDiv for divergence functions.                                       |
//|-----------------------------------------------------------------------------------------|
#property   copyright "Copyright © 2012, Dennis Lee"
#include    <stdlib.mqh>

//|-----------------------------------------------------------------------------------------|
//|                           E X T E R N A L   V A R I A B L E S                           |
//|-----------------------------------------------------------------------------------------|
extern bool   DivShowIndicatorTrendLines = true;
extern bool   DivShowPriceTrendLines = true;
extern bool   DivShowArrows = false;
extern color  DivBullishColor = Blue;
extern color  DivBearishColor = Red;

//|-----------------------------------------------------------------------------------------|
//|                           I N T E R N A L   V A R I A B L E S                           |
//|-----------------------------------------------------------------------------------------|
#define  arrowsDisplacement 0.0001
string   DivName="PlusDiv";
string   DivVer="1.13";
string   DivWinName;

//|-----------------------------------------------------------------------------------------|
//|                             I N I T I A L I Z A T I O N                                 |
//|-----------------------------------------------------------------------------------------|
void DivInit(string win)
{
   DivWinName=win;
   return(0);
}

//|-----------------------------------------------------------------------------------------|
//|                               M A I N   P R O C E D U R E                               |
//|-----------------------------------------------------------------------------------------|
void DivCatchBullishDivergence(double x[], double y[], double lo[], double& buf[], int shift=0)
{
   if( !DivIsIndicatorTrough(x, shift) ) return;
   int currentTrough = shift;
   int lastTrough = DivGetIndicatorLastTrough(x, y, shift);
//----   
   if( x[currentTrough] > x[lastTrough] && lo[currentTrough] < lo[lastTrough] )
   {
      if( DivShowArrows )
         buf[currentTrough] = x[currentTrough] - arrowsDisplacement;
   //----
      if( DivShowPriceTrendLines )
         DivDrawPriceTrendLine( Time[currentTrough], Time[lastTrough], 
                               lo[currentTrough], lo[lastTrough], 
                               DivBullishColor, STYLE_SOLID );
   //----
      if( DivShowIndicatorTrendLines )
         DivDrawIndicatorTrendLine( DivWinName,
                                   Time[currentTrough], Time[lastTrough], 
                                   x[currentTrough], x[lastTrough], 
                                   DivBullishColor, STYLE_SOLID );
   }
//----   
   if( x[currentTrough] < x[lastTrough] && lo[currentTrough] > lo[lastTrough] )
   {
      if( DivShowArrows )
         buf[currentTrough] = x[currentTrough] - arrowsDisplacement;
   //----
      if( DivShowPriceTrendLines )
         DivDrawPriceTrendLine( Time[currentTrough], Time[lastTrough], 
                               lo[currentTrough], lo[lastTrough], 
                               DivBearishColor, STYLE_SOLID );
   //----
      if( DivShowIndicatorTrendLines )
         DivDrawIndicatorTrendLine( DivWinName,
                                   Time[currentTrough], Time[lastTrough], 
                                   x[currentTrough], x[lastTrough], 
                                   DivBearishColor, STYLE_SOLID );
   }      
}
void DivCatchBearishDivergence(double x[], double y[], double hi[], double& buf[], int shift=0)
{
   if( !DivIsIndicatorPeak(x, shift) ) return;
   int currentPeak = shift;
   int lastPeak = DivGetIndicatorLastPeak(x, y, shift);
//----   
   if( x[currentPeak] < x[lastPeak] && hi[currentPeak] > hi[lastPeak] )
   {
      if( DivShowArrows )
         buf[currentPeak] = x[currentPeak] + arrowsDisplacement;
   //----
      if( DivShowPriceTrendLines )
         DivDrawPriceTrendLine( Time[currentPeak], Time[lastPeak], 
                               hi[currentPeak], hi[lastPeak], 
                               DivBearishColor, STYLE_DOT );
   //----
      if( DivShowIndicatorTrendLines )
         DivDrawIndicatorTrendLine( DivWinName,
                                   Time[currentPeak], Time[lastPeak], 
                                   x[currentPeak], x[lastPeak], 
                                   DivBearishColor, STYLE_DOT );
   }
   if( x[currentPeak] > x[lastPeak] && hi[currentPeak] < hi[lastPeak] )
   {
      if( DivShowArrows )
         buf[currentPeak] = x[currentPeak] + arrowsDisplacement;
   //----
      if( DivShowPriceTrendLines )
         DivDrawPriceTrendLine( Time[currentPeak], Time[lastPeak], 
                               hi[currentPeak], hi[lastPeak], 
                               DivBullishColor, STYLE_DOT );
   //----
      if( DivShowIndicatorTrendLines )
         DivDrawIndicatorTrendLine( DivWinName,
                                   Time[currentPeak], Time[lastPeak], 
                                   x[currentPeak], x[lastPeak], 
                                   DivBullishColor, STYLE_DOT );
   }   
}

//|-----------------------------------------------------------------------------------------|
//|                           I N T E R N A L   F U N C T I O N S                           |
//|-----------------------------------------------------------------------------------------|
bool DivIsIndicatorPeak(double x[], int shift)
{
   if(x[shift] >= x[shift+1] && x[shift] > x[shift+2] && 
      x[shift] > x[shift-1])
      return(true);
   else 
      return(false);
}
bool DivIsIndicatorTrough(double x[], int shift)
{
   if(x[shift] <= x[shift+1] && x[shift] < x[shift+2] && 
      x[shift] < x[shift-1])
      return(true);
   else 
      return(false);
}
int DivGetIndicatorLastPeak(double x[], double y[], int shift)
{
   for(int i = shift + 5; i < Bars; i++)
   {
      if(y[i] >= y[i+1] && y[i] >= y[i+2] &&
         y[i] >= y[i-1] && y[i] >= y[i-2])
      {
         for(int j = i; j < Bars; j++)
         {
            if(x[j] >= x[j+1] && x[j] > x[j+2] &&
               x[j] >= x[j-1] && x[j] > x[j-2])
               return(j);
         }
      }
   }
   return(-1);
}
int DivGetIndicatorLastTrough(double x[], double y[], int shift)
{
   for(int i = shift + 5; i < Bars; i++)
   {
      if(y[i] <= y[i+1] && y[i] <= y[i+2] &&
         y[i] <= y[i-1] && y[i] <= y[i-2])
      {
         for (int j = i; j < Bars; j++)
         {
            if(x[j] <= x[j+1] && x[j] < x[j+2] &&
               x[j] <= x[j-1] && x[j] < x[j-2])
               return(j);
         }
      }
   }
   return(-1);
}

//|-----------------------------------------------------------------------------------------|
//|                              C R E A T E   O B J E C T S                                |
//|-----------------------------------------------------------------------------------------|
string DivDrawPriceTrendLine(datetime x1, datetime x2, double y1, double y2, color lineColor, double style, double width=1, int ray=0)
{
   if( !DivShowPriceTrendLines ) return("");
   string label = DivName+"_"+DivVer+"_Main_"+DoubleToStr(x1, 0);
   ObjectDelete(label);
   ObjectCreate(label, OBJ_TREND, 0, x1, y1, x2, y2, 0, 0);
   ObjectSet(label, OBJPROP_RAY, ray);
   ObjectSet(label, OBJPROP_COLOR, lineColor);
   ObjectSet(label, OBJPROP_STYLE, style);
   ObjectSet(label, OBJPROP_WIDTH, width);
   return( label );
}

string DivDrawIndicatorTrendLine(string win, datetime x1, datetime x2, double y1, double y2, color lineColor, double style, double width=1, int ray=0)
{
   if( !DivShowIndicatorTrendLines ) return("");
   int indicatorWindow = WindowFind(win);
   if(indicatorWindow < 0) return("");
   string label = DivName+"_"+DivVer+"_Sub_"+DoubleToStr(x1, 0);
   ObjectDelete(label);
   ObjectCreate(label, OBJ_TREND, indicatorWindow, x1, y1, x2, y2, 0, 0);
   ObjectSet(label, OBJPROP_RAY, ray);
   ObjectSet(label, OBJPROP_COLOR, lineColor);
   ObjectSet(label, OBJPROP_STYLE, style);
   ObjectSet(label, OBJPROP_WIDTH, width);
   return( label );
}

void DivDelete(string name)
{
   if( StringLen( name )>0 ) if( ObjectFind( name )>=0 ) ObjectDelete(name);
}

//|-----------------------------------------------------------------------------------------|
//|                             D E I N I T I A L I Z A T I O N                             |
//|-----------------------------------------------------------------------------------------|
void DivDeInit()
{
   for(int i = ObjectsTotal() - 1; i >= 0; i--)
   {
      string label = ObjectName(i);
      if( StringSubstr(label, 0, 12) != StringConcatenate(DivName,"_",DivVer) )
         continue;
      ObjectDelete(label);   
   }
   return(0);
}

//|-----------------------------------------------------------------------------------------|
//|                                     C O M M E N T                                       |
//|-----------------------------------------------------------------------------------------|
string DivComment(string cmt="")
{
   string strtmp = cmt+"  -->"+DivName+"_"+DivVer+"<--";

                         
   strtmp = strtmp+"\n";
   return(strtmp);
}

//|-----------------------------------------------------------------------------------------|
//|                       E N D   O F   E X P E R T   A D V I S O R                         |
//|-----------------------------------------------------------------------------------------|

