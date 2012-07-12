//|-----------------------------------------------------------------------------------------|
//|                                                                       ImportDrawHst.mq4 |
//|                                                            Copyright © 2012, Dennis Lee |
//| Assert History                                                                          |
//| 1.00    Import CSV file into a chart and export to history file.                        |
//|            1) For the CSV file, if EOF is not correct, file will not be read;           |
//|            2) For the HST file, version must be 400, or offline chart cannot be viewed; |
//|            3) For the HST file, OHLC candle must be well formed;                        |
//|            4) For the HST file, time uses Time[] instead of CSV's time (To be fixed).   |
//|-----------------------------------------------------------------------------------------|
#property   copyright "Copyright © 2012, Dennis Lee"
#property   show_inputs
#import "WinUser32.mqh"

#property indicator_chart_window
#property indicator_buffers 5

//|------------------------------------------------------------------------------------------|
//|                           E X T E R N A L   V A R I A B L E S                            |
//|------------------------------------------------------------------------------------------|
extern   string   FileNameCsv    = "";
extern   int      Delimiter      = ',';
extern   string   s1             = " UseCustom: set Symbol and Period.";
extern   string   s1_1           = " Period: 15-M15, 30-M30,.. 1440-D1";
extern   bool     UseCustom      = true;
extern   string   CustomSymbol   = "";
extern   int      CustomPeriod   = 1440;
extern   color    BullishBar     = White;
extern   color    BearishBar     = Black;
extern   int      IndDebug       = 2;
extern   int      IndDebugMod    = 1000;

//|------------------------------------------------------------------------------------------|
//|                              O U T P U T   B U F F E R S                                 |
//|------------------------------------------------------------------------------------------|
double ExtMapBuffer1[];    // Open
double ExtMapBuffer2[];    // High
double ExtMapBuffer3[];    // Low
double ExtMapBuffer4[];    // Close
double ExtMapBuffer5[];    // Volume

//|------------------------------------------------------------------------------------------|
//|                           I N T E R N A L   V A R I A B L E S                            |
//|------------------------------------------------------------------------------------------|
string   IndName   ="ImportDrawHst";
string   IndVer    ="1.00";
string   IndCopyr  ="Copyright © 2012, Dennis Lee";
string   IndSymbol;
int      IndPeriod;
string   FileNameHst;
int      FileHandleHst=-1;
int      FileHandleCsv=-1;
bool     IsDone=false;
int      IndDebugCount;

// ------------------------------------------------------------------------------------------|
//                             I N I T I A L I S A T I O N                                   |
// ------------------------------------------------------------------------------------------|
int init()
{
//--- Assert check validity of user externs
   if( UseCustom )
   {
      IndSymbol = CustomSymbol;
      IndPeriod = CustomPeriod;
   }
   else
   {
      IndSymbol = Symbol();
      IndPeriod = Period();
   }
   if( IndPeriod <= 0 )
   {
      IndDebugPrint( 1, "init", "Period cannot be negative or zero. Set Period=1440");
      IndPeriod = PERIOD_D1;
   }
   if( Delimiter <= 0 )
   {
      IndDebugPrint( 1, "init", "Delimiter cannot be empty. Set Delimiter=';'");
      Delimiter = ',';
   }
   
//--- Assert initialize internal variables
   FileNameHst     = IndSymbol+IndPeriod+".hst";

   int i_unused[13];
   
//--- Assert file csv is opened.
   FileHandleCsv   = FileOpen( FileNameCsv, FILE_CSV|FILE_READ, Delimiter );
   if( FileHandleCsv < 0)
   {
      IndDebugPrint( 1, "init", "Cannot open csv file "+FileNameCsv+". Check file or EOF.");
      int handle=FileOpen("test", FILE_CSV|FILE_WRITE, ',');
      if(handle>0)
      {
         FileWrite(handle, 1.0);
         FileWrite(handle, 1.0);
         FileWrite(handle, 1.0);
         FileClose(handle);
      }
      IndDebugPrint( 1, "init", "File test contains the correct EOF character.");
   }
   
//--- Assert file history is opened.
   FileHandleHst   = FileOpenHistory( FileNameHst, FILE_BIN|FILE_WRITE);
   if( FileHandleHst < 0)
   {
      IndDebugPrint( 1, "init", "Cannot create history file "+FileNameHst+". Check write permission.");
   }
//--- Assert write history header file
   FileWriteInteger(FileHandleHst,   400, LONG_VALUE);
   FileWriteString(FileHandleHst,    IndCopyr, 64);
   FileWriteString(FileHandleHst,    IndSymbol, 12);
   FileWriteInteger(FileHandleHst,   IndPeriod, LONG_VALUE);
   FileWriteInteger(FileHandleHst,   Digits, LONG_VALUE);
   FileWriteInteger(FileHandleHst,   0, LONG_VALUE);       //timesign
   FileWriteInteger(FileHandleHst,   0, LONG_VALUE);       //last_sync
   FileWriteArray(FileHandleHst,     i_unused, 0, 13);
   IndDebugPrint( 1, "init", "File header successfully written.");


//---- Assert indicators for outputs (4) 
   IndicatorBuffers(5);
   SetIndexStyle( 0, DRAW_HISTOGRAM, STYLE_SOLID, 3, BullishBar );
   SetIndexStyle( 1, DRAW_HISTOGRAM, STYLE_SOLID, 1, BullishBar );
   SetIndexStyle( 2, DRAW_HISTOGRAM, STYLE_SOLID, 1, BearishBar );
   SetIndexStyle( 3, DRAW_HISTOGRAM, STYLE_SOLID, 3, BearishBar );
   SetIndexStyle( 4, DRAW_NONE );
   
   IndicatorDigits(Digits+10);

   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexBuffer(1,ExtMapBuffer2);
   SetIndexBuffer(2,ExtMapBuffer3);
   SetIndexBuffer(3,ExtMapBuffer4);
   SetIndexBuffer(4,ExtMapBuffer5);

   SetIndexEmptyValue( 0, 0.0 );
   SetIndexEmptyValue( 1, 0.0 );
   SetIndexEmptyValue( 2, 0.0 );
   SetIndexEmptyValue( 3, 0.0 );
   SetIndexEmptyValue( 4, 0.0 );
   
   SetIndexLabel(0,"Open");
   SetIndexLabel(1,"High");
   SetIndexLabel(2,"Low");
   SetIndexLabel(3,"Close");
   SetIndexLabel(4,"Volume");
   
   IndicatorShortName( StringConcatenate(IndName," ",IndVer) );
   
   return(0);    
}

//|------------------------------------------------------------------------------------------|
//|                            D E - I N I T I A L I S A T I O N                             |
//|------------------------------------------------------------------------------------------|
int deinit()
{
//--- Assert close handles
   if( FileHandleHst >= 0 )
   {
      FileClose(FileHandleHst);
      FileHandleHst = -1;
   }
   if( FileHandleCsv >= 0 )
   {
      FileClose(FileHandleCsv);
      FileHandleCsv = -1;
   }
   IndDebugPrint( 1, "deinit", "File handles closed.");
   return(0);
}


//|------------------------------------------------------------------------------------------|
//|                               M A I N   P R O C E D U R E                                |
//|------------------------------------------------------------------------------------------|
int start()
{
//---- Assert variables used by count from last bar
   int i;
   int unused_bars=Bars-1;
   
   int count;
   int last_fpos;
   int periodSeconds = IndPeriod*60;

//---- Assert files are opened   
   if( FileHandleHst < 0) return(-1);
   if( FileHandleCsv < 0) return(-1);

//---- Assert run once only
   if( IsDone ) return(0);
   
   ArrayInitialize( ExtMapBuffer1, 0.0 );
   ArrayInitialize( ExtMapBuffer2, 0.0 );
   ArrayInitialize( ExtMapBuffer3, 0.0 );
   ArrayInitialize( ExtMapBuffer4, 0.0 );
   ArrayInitialize( ExtMapBuffer5, 0.0 );
   
//---- Assert declare variables used to store write values
   string   rTime;
   int      wTime;
   double   wOpen;
   double   wHigh;
   double   wLow;
   double   wClose;
   double   wVolume;

//---- Assert read csv file
   while( !FileIsEnding(FileHandleCsv) )
   {
      rTime    = FileReadString(FileHandleCsv);
      wOpen    = FileReadNumber(FileHandleCsv);
      wHigh    = FileReadNumber(FileHandleCsv);
      wLow     = FileReadNumber(FileHandleCsv);
      wClose   = FileReadNumber(FileHandleCsv);
      wVolume  = FileReadNumber(FileHandleCsv);
      count ++;
   }
   IndDebugPrint( 1, "start", count+" line(s) read.");
   IsDone = true;
   
   FileSeek(FileHandleCsv,0,SEEK_SET);
   unused_bars=count-1;
   
   for (i=unused_bars-1;i>=0;i--)
   {
      rTime             = FileReadString(FileHandleCsv);
      ExtMapBuffer1[i]  = FileReadNumber(FileHandleCsv);
      ExtMapBuffer2[i]  = FileReadNumber(FileHandleCsv);
      ExtMapBuffer3[i]  = FileReadNumber(FileHandleCsv);
      ExtMapBuffer4[i]  = FileReadNumber(FileHandleCsv);
      ExtMapBuffer5[i]  = FileReadNumber(FileHandleCsv);
   }
   IndDebugPrint( 1, "start", unused_bars+" record(s) drawn.");
   
//---- Assert count from last bar (function Bars) to current bar (0)
   count=0;
   for (i=unused_bars-1;i>=0;i--)
   {
   //--- Assert populate values
      wTime    = Time[i]/periodSeconds;
      wTime    = wTime*periodSeconds;
      wOpen    = ExtMapBuffer1[i];
      wHigh    = ExtMapBuffer2[i];
      wLow     = ExtMapBuffer3[i];
      wClose   = ExtMapBuffer4[i];
      wVolume  = ExtMapBuffer5[i];
   //--- Assert write to history file
      last_fpos = FileTell(FileHandleHst);
      FileWriteInteger(FileHandleHst,   wTime, LONG_VALUE);
      FileWriteDouble(FileHandleHst,    wOpen, DOUBLE_VALUE);
      FileWriteDouble(FileHandleHst,    wLow, DOUBLE_VALUE);
      FileWriteDouble(FileHandleHst,    wHigh, DOUBLE_VALUE);
      FileWriteDouble(FileHandleHst,    wClose, DOUBLE_VALUE);
      FileWriteDouble(FileHandleHst,    wVolume, DOUBLE_VALUE);
      
      IndDebugPrint( 2, "start",
         IndDebugInt("i",i)+
         IndDebugInt("wTime",wTime)+
         IndDebugDbl("wOpen",wOpen)+
         IndDebugDbl("wHigh",wHigh)+
         IndDebugDbl("wLow",wLow)+
         IndDebugDbl("wClose",wClose)+
         IndDebugDbl("wVolume",wVolume) );

      FileFlush(FileHandleHst);
      count++;
   }
   FileFlush(FileHandleHst);
   IndDebugPrint( 1, "start", count+" record(s) written successfully.");

   return(0);
}

//|-----------------------------------------------------------------------------------------|
//|                                     C O M M E N T                                       |
//|-----------------------------------------------------------------------------------------|
string IndComment(string cmt="")
{
   string strtmp = cmt+"-->"+IndName+" "+IndVer+"<--";
   strtmp=strtmp+"\n";
   
   return(strtmp);
}
void IndDebugPrint(int dbg, string fn, string msg, bool incr=true, int mod=0)
{
   if(IndDebug>=dbg)
   {
      if(dbg>=2 && IndDebugMod>0)
      {
         if( MathMod(IndDebugCount,IndDebugMod) == mod )
            Print(IndDebug,"-",IndDebugCount,":",fn,"(): ",msg);
         if( incr )
            IndDebugCount ++;
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

//|------------------------------------------------------------------------------------------|
//|                     E N D   O F   C U S T O M   I N D I C A T O R                        |
//|------------------------------------------------------------------------------------------|