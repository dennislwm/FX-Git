//|-----------------------------------------------------------------------------------------|
//|                                                                               PlusR.mqh |
//|                                                            Copyright © 2012, Dennis Lee |
//| Assert History                                                                          |
//| 1.1.0   Added RAugDickFull() function to test for cointegration of TWO (2) currencies.  |
//|            Works with mt4R.mqh 1.1.1+ due to syntax changes. Enhanced function          |
//|            RDebugPrint() to print to R device.                                          |
//|         TODO: Unit test functions.                                                      |
//| 1.00    Created PlusR for R functions. Added ONE (1) new function.                      |
//|            RYahooImport - imports historical data (OHLC+V) of any ticker from Yahoo.    |
//|-----------------------------------------------------------------------------------------|
#property   copyright "Copyright © 2012, Dennis Lee"
#include    <stdlib.mqh>
#include    <mt4R.mqh>

//|-----------------------------------------------------------------------------------------|
//|                           E X T E R N A L   V A R I A B L E S                           |
//|-----------------------------------------------------------------------------------------|
extern string  RPath                = "C:/Program Files/R/R-2.15.1/bin/i386/Rterm.exe --no-save";
extern bool    RViewDebugNotify     = false;
extern int     RViewDebug           = 1;
extern int     RViewDebugNoStack    = 1000;
extern int     RViewDebugNoStackEnd = 0;

//|-----------------------------------------------------------------------------------------|
//|                           I N T E R N A L   V A R I A B L E S                           |
//|-----------------------------------------------------------------------------------------|
string   RName="PlusR";
string   RVer="1.1.0";
int      RDebug= 2;
int      RhComment;

//|-----------------------------------------------------------------------------------------|
//|                             I N I T I A L I Z A T I O N                                 |
//|-----------------------------------------------------------------------------------------|
void RInit()
{
   RBgn(RPath,RDebug);
   if( RIsStopped() ) return(0);
   
//--- Assert load R library
   Rx("library(tseries)");
   Rx("library(zoo)");
   Rx("library(gplots)");
}

//|-----------------------------------------------------------------------------------------|
//|                           E X T E R N A L   F U N C T I O N S                           |
//|-----------------------------------------------------------------------------------------|
//|-----------------------------------------------------------------------------------------|
//|                         E X T E R N A L   B   F U N C T I O N S                         |
//|-----------------------------------------------------------------------------------------|
double RAugDickFull(double &pair1[], double &pair2[], int lookBackBar=0, string sym1="", string sym2="", int period=0)
{
   double result;
   
//--- Assert R is initialized
   if( RIsStopped() ) return(0);
   
//--- Assert user may pass arrays that is empty or full (custom)
//       Note that a custom array does not require loading of data
   if( lookBackBar>0 && sym1!="" && sym2!="" )
   {
   //--- Assert resize empty arrays to fill data
      ArrayResize( pair1, lookBackBar );
      ArrayResize( pair2, lookBackBar );
   //--- Assert fill with lookBackBar data
      for( int i=lookBackBar; i>=0; i-- )
      {
         pair1[i] = iClose( sym1, period, i );
         pair2[i] = iClose( sym2, period, i );
      }
   }
   else
   //--- Assert custom array must not be empty
      if( ArraySize(pair1)==0 || ArraySize(pair2)==0 ) return(0);
   
//--- Assert call R function for Augmented Dicker-Fuller Test
   RxVtr("pair1",pair1);
   RxVtr("pair2",pair2);
   Rx("m <- lm(pair2 ~ pair1 + 0)");
   Rx("beta <- coef(m)[1]");
   Rx("sprd <- pair1 - beta*pair2");
   Rx("ht <- adf.test(sprd, alternative='stationary', k=0)");
   Rx("pval <- as.numeric(ht$p.value)");
   result = RxDbl("pval");
   return(result);
}

int RYahooImport(string sym, string ticker, double &open[], double &high[], double &low[], double &close[], double &vol[])
{
   int n;
   string cmd;
   
//--- Assert R is initialized
   if( RIsStopped() ) return(0);
   
//--- Assert call R function to import historical data from Yahoo Finance to an R variable named ticker
   cmd = sym + "<-" + "read.csv(\"" + "http://ichart.finance.yahoo.com/table.csv?s=" + ticker +
         "&ignore=.csv\"" + ", stringsAsFactors=F)";
   Rx(cmd);
   
//--- Count number of rows
   n = RxInt( "nrow" + Rbr(sym) );
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
   RxVtr(sym + "$Open",        open);
   RxVtr(sym + "$High",        high);
   RxVtr(sym + "$Low",         low);
   RxVtr(sym + "$Adj.Close",   close);
   RxVtr(sym + "$Volume",      vol);
   
//--- Assert return number of rows n
   return( n );
}
//|-----------------------------------------------------------------------------------------|
//|                         E X T E R N A L   A   F U N C T I O N S                         |
//|-----------------------------------------------------------------------------------------|
bool RxExists(string dat)
{
   double result;
   
//--- Assert R is initialized
   if( RIsStopped() ) return(0);

//--- Return bool from expression
//       exists("dat")
   return( RxBln( "exists"+Rbr( Rqd(dat) ) ) );
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
      {
         if(RViewDebugNotify) SendNotification( RViewDebug + ":" + fn + "(): " + msg );
         Print(RViewDebug,":",fn,"(): ",msg);
      }
   }
//--- Initialize R device
//       dev.cur()
   if( RhComment == 0 )
   {
      Rx("options(device='windows')");
      RhComment = RxInt( Rrd("dev")+"cur"+Rbr("") );
      Print("Initializing graphics device RhComment=",RhComment);
   }

//--- Display comment in R device
//       a = dev.cur()
//       dev.set(h)
//       textplot("comment", halign="left", valign="top" )
//       dev.set(a)
   if( RhComment > 0 )
   {
      Print( Rrd("dev")+"cur"+Rbr("") );
      int a = RxInt( Rrd("dev")+"cur"+Rbr("") );
      
      Print( Rrd("dev")+"set"+Rbr(""+RhComment) );
      Rx( Rrd("dev")+"set"+Rbr(""+RhComment) );
      string cmd = "textplot" + Rbr( Rrc(Rqs(msg))+
         Rrc(Rre("halign")+Rqd("left"))+Rre("valign")+Rqd("top") ); 
      Rx( cmd );
      
      Print( Rrd("dev")+"set"+Rbr(""+a) );
      Rx( Rrd("dev")+"set"+Rbr(""+a) );
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

