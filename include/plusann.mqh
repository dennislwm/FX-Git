//|-----------------------------------------------------------------------------------------|
//|                                                                             PlusAnn.mqh |
//|                                                            Copyright © 2012, Dennis Lee |
//| Assert History                                                                          |
//| 1.00    Originated from Asirikuy member section on Neural Network.                      |
//|-----------------------------------------------------------------------------------------|
#property   copyright "Copyright © 2012, Dennis Lee"

#import "PlusAnn.dll"
double  GetMse();
double  PredictDirectionNN(double& trades[], int size, int fileToLoad);
void    Retrain(double& trades[], int size, int FileName) ; 
#import

//|-----------------------------------------------------------------------------------------|
//|                 P L U S L I N E X   E X T E R N A L   V A R I A B L E S                 |
//|-----------------------------------------------------------------------------------------|
extern   string g1                      = "Basic Settings";
extern   int    AnnCommitteeSize        = 3;
extern   int    AnnMinBars              = 60;
extern   int    AnnMaxBars              = 130;
extern   string g2                      = "Debug: 0-Crit; 1-Core; 2-Detail";
extern   int    AnnDebug                = 1;
extern   int    AnnDebugCount           = 1000;

//|-----------------------------------------------------------------------------------------|
//|                           I N T E R N A L   V A R I A B L E S                           |
//|-----------------------------------------------------------------------------------------|
string   AnnName="PlusAnn";
string   AnnVer="1.00";
int      AnnTotalBars;
int      AnnCount;

//|-----------------------------------------------------------------------------------------|
//|                             I N I T I A L I Z A T I O N                                 |
//|-----------------------------------------------------------------------------------------|
void AnnInit()
{
//-- Assert Excel or SQL files are created.
}

//|-----------------------------------------------------------------------------------------|
//|                               M A I N   P R O C E D U R E                               |
//|-----------------------------------------------------------------------------------------|

//|-----------------------------------------------------------------------------------------|
//|                             D E I N I T I A L I Z A T I O N                             |
//|-----------------------------------------------------------------------------------------|
void AnnDeInit()
{
//-- Assert Excel or SQL files are saved.
}

//|-----------------------------------------------------------------------------------------|
//|                                     C O M M E N T                                       |
//|-----------------------------------------------------------------------------------------|
string AnnComment(string cmt="")
{
   int total;
   
   string strtmp = cmt+"  -->"+AnnName+" "+AnnVer+"<--";

//---- Assert Trade info in comment
   /*if(GhostMode==0)
   {
      strtmp=strtmp+"\n    No Ghost Trading.";
   }
   else 
   {
   //---- Assert Basic settings in comment
      strtmp=strtmp+"\n    Mode="+DoubleToStr(GhostMode,0);
      if(GhostMode==1)
         strtmp=strtmp+" (Excel "+ExcelVer+")";
      else
         strtmp=strtmp+" (SqLite "+SqLiteVer+")";
      if(total<=0)
         strtmp=strtmp+"\n    No Active Ghost Trades.";
      else
         strtmp=strtmp+"\n    Ghost Trades="+total;
   }*/
                         
   strtmp=strtmp+"\n";
   return(strtmp);
}

void AnnDebugPrint(int dbg, string fn, string msg, bool incr=true, int mod=0)
{
   if(AnnDebug>=dbg)
   {
      if(dbg>=2 && AnnDebugCount>0)
      {
         if( MathMod(AnnCount,AnnDebugCount) == mod )
            Print(AnnDebug,"-",AnnCount,":",fn,"(): ",msg);
         if( incr )
            AnnCount ++;
      }
      else
         Print(AnnDebug,":",fn,"(): ",msg);
   }
}
string AnnDebugInt(string key, int val)
{
   return( StringConcatenate(";",key,"=",val) );
}
string AnnDebugDbl(string key, double val, int dgt=5)
{
   return( StringConcatenate(";",key,"=",NormalizeDouble(val,dgt)) );
}
string AnnDebugStr(string key, string val)
{
   return( StringConcatenate(";",key,"=\"",val,"\"") );
}
string AnnDebugBln(string key, bool val)
{
   string valType;
   if( val )   valType="true";
   else        valType="false";
   return( StringConcatenate(";",key,"=",valType) );
}

//|-----------------------------------------------------------------------------------------|
//|                       E N D   O F   E X P E R T   A D V I S O R                         |
//|-----------------------------------------------------------------------------------------|

