//|-----------------------------------------------------------------------------------------|
//|                                                                               PlusR.mqh |
//|                                                            Copyright © 2012, Dennis Lee |
//| Assert History                                                                          |
//| 1.00    Created PlusR for R functions. Added ONE (1) new function.                      |
//|            RYahooImport - imports historical data (OHLC+V) of any ticker from Yahoo.    |
//|-----------------------------------------------------------------------------------------|
#property   copyright "Copyright © 2012, Dennis Lee"
#include    <stdlib.mqh>
#include    <mt4R.mqh>

//|-----------------------------------------------------------------------------------------|
//|                           E X T E R N A L   V A R I A B L E S                           |
//|-----------------------------------------------------------------------------------------|
extern string RPath     = "C:/Program Files/R/R-2.15.1/bin/i386/Rterm.exe --no-save";
extern string d1        = "0-No debug; 1-Debug minimal; 2-Debug stack";
extern int RViewDebug   = 1;
extern string d2        = "Stacking of debug messages every n";
extern int RViewDebugNoStack = 1000;
extern string d3        = "View stacked messages from n to m";
extern int RViewDebugNoStackEnd = 0;

//|-----------------------------------------------------------------------------------------|
//|                           I N T E R N A L   V A R I A B L E S                           |
//|-----------------------------------------------------------------------------------------|
string   RName="PlusR";
string   RVer="1.00";
int      RDebug= 2;

//|-----------------------------------------------------------------------------------------|
//|                             I N I T I A L I Z A T I O N                                 |
//|-----------------------------------------------------------------------------------------|
void RInit()
{
   RBgn(RPath,RDebug);
   if( RIsStopped() ) return(0);
   
//--- Assert load R library
   RExeStr("library(tseries)");
   RExeStr("library(zoo)");
}

//|-----------------------------------------------------------------------------------------|
//|                           E X T E R N A L   F U N C T I O N S                           |
//|-----------------------------------------------------------------------------------------|
int RYahooImport(string ticker, double &open[], double &high[], double &low[], double &close[], double &vol[])
{
   int n;
   string cmd;
   
//--- Assert R is initialized
   if( RIsStopped() ) return(0);
   
//--- Assert call R function to import historical data from Yahoo Finance to an R variable named ticker
   cmd = ticker + "<-" + "read.csv(\"" + "http://ichart.finance.yahoo.com/table.csv?s=" + ticker +
         "&ignore=.csv\"" + ", stringsAsFactors=F)";
   RExeStr(cmd);
   
//--- Count number of rows
   n = RGetInt( "nrow(" + ticker + ")" );
   RDebugPrint( 1, "RYahooImport",
      RDebugStr("cmd", cmd) +
      RDebugInt("n", n) );
   
//--- Assert dynamically resize arrays based on number of rows
   ArrayResize(open,n);
   ArrayResize(high,n);
   ArrayResize(low,n);
   ArrayResize(close,n);
   ArrayResize(vol,n);

//--- Populate arrays with data (Note: array[0] has the latest price)
   RGetVtr(ticker + "$Open",        open);
   RGetVtr(ticker + "$High",        high);
   RGetVtr(ticker + "$Low",         low);
   RGetVtr(ticker + "$Adj.Close",   close);
   RGetVtr(ticker + "$Volume",      vol);
   
//--- Assert return number of rows n
   return( n );
}

//|-----------------------------------------------------------------------------------------|
//|                             D E I N I T I A L I Z A T I O N                             |
//|-----------------------------------------------------------------------------------------|
void RDeInit()
{
   REnd();
   return(0);
}

//|-----------------------------------------------------------------------------------------|
//|                           I N T E R N A L   F U N C T I O N S                           |
//|-----------------------------------------------------------------------------------------|

//|-----------------------------------------------------------------------------------------|
//|                              C R E A T E   O B J E C T S                                |
//|-----------------------------------------------------------------------------------------|

//|-----------------------------------------------------------------------------------------|
//|                                     C O M M E N T                                       |
//|-----------------------------------------------------------------------------------------|
string RComment(string cmt="")
{
   string strtmp = cmt+"  -->"+RName+"_"+RVer+"<--";

                         
   strtmp = strtmp+"\n";
   return(strtmp);
}

void RDebugPrint(int dbg, string fn, string msg)
{
   static int noStackCount;
   if(RViewDebug>=dbg)
   {
      if(dbg>=2 && RViewDebugNoStack>0)
      {
         if( MathMod(noStackCount,RViewDebugNoStack) <= RViewDebugNoStackEnd )
            Print(RViewDebug,"-",noStackCount,":",fn,"(): ",msg);
            
         noStackCount ++;
      }
      else
         Print(RViewDebug,":",fn,"(): ",msg);
   }
}
string RDebugInt(string key, int val)
{
   return( StringConcatenate(";",key,"=",val) );
}
string RDebugDbl(string key, double val, int dgt=5)
{
   return( StringConcatenate(";",key,"=",NormalizeDouble(val,dgt)) );
}
string RDebugStr(string key, string val)
{
   return( StringConcatenate(";",key,"=\"",val,"\"") );
}
string RDebugBln(string key, bool val)
{
   string valType;
   if( val )   valType="true";
   else        valType="false";
   return( StringConcatenate(";",key,"=",valType) );
}

//|-----------------------------------------------------------------------------------------|
//|                       E N D   O F   E X P E R T   A D V I S O R                         |
//|-----------------------------------------------------------------------------------------|

