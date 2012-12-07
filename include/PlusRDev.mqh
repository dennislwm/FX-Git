//|-----------------------------------------------------------------------------------------|
//|                                                                            PlusRDev.mqh |
//|                                                            Copyright © 2012, Dennis Lee |
//| Assert History                                                                          |
//|   0.9.0    Created PlusRDev.mqh as a wrapper for PlusDev.R external functions.          |
//|               WARN: The R functions textplot(), sinkplot() and family of dev.fn() MUST  |
//|               NOT be nested in another R function, when executed from Metatrader.       |
//|-----------------------------------------------------------------------------------------|
#property   copyright "Copyright © 2012, Dennis Lee"
#include    <stdlib.mqh>
#include    <mt4R.mqh>

//|-----------------------------------------------------------------------------------------|
//|                           I N T E R N A L   V A R I A B L E S                           |
//|-----------------------------------------------------------------------------------------|
string   RDevName="PlusRDev";
string   RDevVer="1.0.0";
int      RhUsedbySink;

//|-----------------------------------------------------------------------------------------|
//|                             I N I T I A L I Z A T I O N                                 |
//|-----------------------------------------------------------------------------------------|
void RDevInit()
{
   if( RIsStopped() ) return(0);
   
//--- Assert load R library
   Rx( "source"+Rbr( Rqd("C:/Users/denbrige/100 FxOption/103 FxOptionVerBack/080 Fx Git/R-source/PlusDev.R") ) );
}

//|-----------------------------------------------------------------------------------------|
//|                            W R A P P E R   F U N C T I O N S                            |
//|-----------------------------------------------------------------------------------------|
void RDevConsoleExprPlot(int devInt, string exprStr, double cex=0.9, bool quoteBln=TRUE)
{
   string retStr = exprStr;
//--- Check that arguments are valid
//       Use devSetNum() to switch device with retNum
//       if retNum==devNum, then NO need to switch back
   if( RDevIsNull(devInt) ) return(0);
   int hInt = RDevSetNum(devInt);
   if( quoteBln )
   {
      string Tlq = StringSubstr(exprStr, 1, 1);
      if( StringFind(Tlq, "\"") == 0 || StringFind(Tlq, "'")==0 )
         retStr = Rqd("Error: exprStr MUST be enclosed in quotes.");
   }
   
   Rx( "textplot"+Rbr( Rrd("capture")+Rrc("output"+Rbr( retStr ))+
      Rrc(Rre("halign")+Rqs("left"))+ Rrc(Rre("valign")+Rqs("top"))+
      Rre("cex") + cex ) );
      
   if( hInt != devInt ) RDevSetNum(hInt);
}

void RDevConsoleTextPlot(int devInt, string textStr, double cex=0.9, bool quoteBln=TRUE)
{
   string retStr = textStr;
//--- Check that arguments are valid
//       Use devSetNum() to switch device with retNum
//       if retNum==devNum, then NO need to switch back
   if( RDevIsNull(devInt) ) return(0);
   int hInt = RDevSetNum(devInt);
   if( quoteBln )
   {
      string Tlq = StringSubstr(textStr, 1, 1);
      if( StringFind(Tlq, "\"") == 0 || StringFind(Tlq, "'")==0 )
         retStr = Rqd("Error: textStr MUST be enclosed in quotes.");
   }
   
   Rx( "textplot"+Rbr( Rrc( retStr )+
      Rrc(Rre("halign")+Rqs("left"))+ Rrc(Rre("valign")+Rqs("top"))+
      Rre("cex") + cex ) );
      
   if( hInt != devInt ) RDevSetNum(hInt);
}

void RDevConsoleSinkOff(int devInt, double cex=0.9)
{
//--- Check that arguments are valid
//       Use devSetNum() to switch device with retNum
//       if retNum==devNum, then NO need to switch back
   if( RDevIsNull(devInt) ) return(0);
   
   Rx( "sinkplot"+Rbr( Rrc("c"+Rbr(Rqs("plot")))+
      Rrc(Rre("halign")+Rqs("left"))+ Rrc(Rre("valign")+Rqs("top"))+
      Rre("cex") + cex ) );

   if( RhUsedbySink != devInt ) RDevSetNum(RhUsedbySink);
}

void RDevConsoleSinkOn(int devInt)
{
//--- Check that arguments are valid
//       Use devSetNum() to switch device with retNum
//       if retNum==devNum, then NO need to switch back
   if( RDevIsNull(devInt) ) return(0);
   RhUsedbySink = RDevSetNum(devInt);
   
   Rx( "sinkplot"+Rbr("c"+Rbr(Rqs("start"))) );
}

int RDevConsoleNewInt()
{
//--- Initialize a new device and return its device number
//       Check for success by counting before and after
//       Start capture of output
   int bgnInt = RDevLengthNum();
   Rx( "dev.new('windows')" );
   int endInt = RDevLengthNum();
   
   if( endInt==bgnInt )
      return(0);
   else
      return( RxInt( "as.numeric(dev.cur())" ) );
}

bool RDevConsoleOffBln(int devInt)
{
   if( RDevIsNull(devInt) ) return(false);
   Rx( "dev.off"+Rbr(""+devInt) );
   return(true);
}

int RDevSetNum(int devInt)
{
   if( RDevIsNull(devInt) ) return(0);
   
   if( RDevIsCur(devInt) ) return(devInt);
   
   int retInt = RxInt( "as.numeric(dev.cur())" );
   Rx( "dev.set"+Rbr(""+devInt) );
   return(retInt);
}

bool RDevIsCur(int devInt)
{
   return( RxBln( "as.numeric(dev.cur())=="+devInt ) );
}

bool RDevIsNull(int devInt)
{
   return( RxBln( "length(which(as.numeric(dev.list())=="+devInt+")) == 0" ) );
}

int RDevLengthNum()
{
   return( RxInt( "length(as.numeric(dev.list()))" ) );
}

//|-----------------------------------------------------------------------------------------|
//|                             D E I N I T I A L I Z A T I O N                             |
//|-----------------------------------------------------------------------------------------|
void RDevDeInit()
{
   return(0);
}

//|-----------------------------------------------------------------------------------------|
//|                       E N D   O F   E X P E R T   A D V I S O R                         |
//|-----------------------------------------------------------------------------------------|

