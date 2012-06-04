//|-----------------------------------------------------------------------------------------|
//|                                                                            PlusFann.mqh |
//|                                                            Copyright © 2012, Dennis Lee |
//| Assert History                                                                          |
//| 1.00    Translated from Lazarus (Asirikuy Neural Network Kit).                          |
//|            Note that function f2M_create_standard cannot be called with layer=3.        |
//|-----------------------------------------------------------------------------------------|
#property   copyright "Copyright © 2012, Dennis Lee"

//|-----------------------------------------------------------------------------------------|
//|                              F A N N 2 M Q L   A D D O N                                |
//|-----------------------------------------------------------------------------------------|
#include    <Fann2MQL.mqh>

//|-----------------------------------------------------------------------------------------|
//|                 P L U S L I N E X   E X T E R N A L   V A R I A B L E S                 |
//|-----------------------------------------------------------------------------------------|
extern   string g1                      = "Basic Settings";
extern   int    FannCommitteeSize       = 3;
extern   bool   FannParallel            = true;
extern   int    FannLayer               = 4;
extern   int    FannInput               = 50;
extern   int    FannHidden1             = 50;
extern   int    FannHidden2             = 49;
extern   int    FannOutput              = 1;
extern   int    FannEpoch               = 1000;
extern   int    FannMinBars             = 60;
extern   int    FannMaxBars             = 130;
extern   string g2                      = "Debug: 0-Crit; 1-Core; 2-Detail";
extern   int    FannDebug               = 1;
extern   int    FannDebugCount          = 1000;

//|-----------------------------------------------------------------------------------------|
//|                           I N T E R N A L   V A R I A B L E S                           |
//|-----------------------------------------------------------------------------------------|
string   FannName="PlusFann";
string   FannVer="1.00";
int      FannTotalBars;
int      FannCount;
int      FannHandle[];
int      FannFunction = FANN_SIGMOID;
string   FannFileName;

//|-----------------------------------------------------------------------------------------|
//|                             I N I T I A L I Z A T I O N                                 |
//|-----------------------------------------------------------------------------------------|
void FannInit()
{
//-- Assert filename.
   FannFileName = StringConcatenate( Symbol(), "_", Period() );
//-- Assert handle created.
   ArrayResize(FannHandle, FannCommitteeSize);
}

//|-----------------------------------------------------------------------------------------|
//|                               M A I N   P R O C E D U R E                               |
//|-----------------------------------------------------------------------------------------|

void FannLoad(int file, bool isLoad=false)
{
   int ann = -1;

//--- Assert Load the Ann
   if( isLoad )
   {
      ann = f2M_create_from_file( StringConcatenate(FannFileName,file) );
      if(ann != -1) 
      {
         FannDebugPrint( 1, "FannLoad",
            "Neural network created successfully: "+
            FannDebugStr("path",StringConcatenate(FannFileName,file))+
	         FannDebugInt("ann",ann) );
      }
   }
   if(ann == -1) 
   {
	//--- Assert create Ann
      if( FannLayer == 3 )
	      ann = f2M_create_standard( FannLayer, FannInput, FannHidden1, FannOutput, 0);
      if( FannLayer == 4 )
	      ann = f2M_create_standard( FannLayer, FannInput, FannHidden1, FannHidden2, FannOutput);
	   f2M_set_act_function_hidden (ann, FANN_SIGMOID);
	   f2M_set_act_function_output (ann, FANN_SIGMOID);
	   f2M_randomize_weights (ann, -0.4, 0.4);
   }
   if(ann == -1)
      FannDebugPrint ( 0, "FannLoad",
         " Error Initializing Neural network.");
   else
      FannDebugPrint ( 1, "FannLoad",
	      " Neural network created successfully: "+
	      FannDebugStr("path",StringConcatenate(FannFileName,file))+
	      FannDebugInt("ann",ann) );
   
   FannHandle[ file ] = ann;
   return(ann);
}

void FannUnload(int file)
{
   f2M_destroy( FannHandle[ file ] );
}

void FannRetrain(double tradeHistory[], int size, int file)
{
   int      e;
   double   mse = 1;
   double   input[];
   double   output[];
   int      error;
   
//--- Assert handle created 0 = OK, -1 = error
   if( FannHandle[ file ] < 0 )
   {
      FannDebugPrint( 0, "FannRetrain",
         FannDebugInt("file",file)+
         FannDebugInt("FannHandle",FannHandle[file])+
         " Not initialized. Use FannLoad to init.");
      return(0);
   }
   
   ArrayResize(input,   FannInput);
   ArrayResize(output,  FannOutput);
   
//--- Assert train number of epochs
   f2M_reset_MSE( FannHandle[ file ] );
   while( e < FannEpoch )
   {
      for(int i=FannInput; i<size; i++)
      {
         for(int j=0; j<FannInput; j++)
         {
            input[j] = tradeHistory[i-j-1];
         }
         output[0] = tradeHistory[i];
         error = f2M_train( FannHandle[ file ], input, output );
         
         FannDebugPrint( 2, "FannRetrain",
            FannDebugInt("e",e)+
            FannDebugInt("i",i)+
            FannDebugDbl("error",error)+
            FannDebugDbl("mse",FannGetMse(file),10),
            true, 0);
      }
      e ++;
   }
   
//--- Assert save to file   
   error = f2M_save( FannHandle[ file ], StringConcatenate(FannFileName,file) );
   if( error == 0 )
      FannDebugPrint( 0, "FannRetrain",
         " Training completed: "+
         FannDebugDbl("mse",FannGetMse(file),10)+
         FannDebugInt("file",file)+
         FannDebugInt("FannHandle",FannHandle[file])+
         FannDebugStr("FannFileName",StringConcatenate(FannFileName,file)) );
   else
      FannDebugPrint( 0, "FannRetrain",
         " Training completed but save file error: "+
         FannDebugDbl("mse",FannGetMse(file),10)+
         FannDebugInt("file",file)+
         FannDebugInt("FannHandle",FannHandle[file])+
         FannDebugStr("FannFileName",StringConcatenate(FannFileName,file))+
         FannDebugInt("error",error) );
}

double FannPredict(double tradeHistory[], int size, int file)
{
   int      handle;
   double   input[];
   double   output;
   int      error;
   double   ret;
   
   ArrayResize(input,   FannInput);
   
//--- Assert file to load exists 0 = OK, -1 = error
   if( FannHandle[ file ] < 0 )
   {
      FannDebugPrint( 0, "FannPredict",
         " Could not load file: "+
         FannDebugStr("FannFileName",StringConcatenate(FannFileName,file)) );
      return(0);
   }
   
//--- Assert run prediction with last 50 period
   for(int j=size-51; j<size; j++)
   {
      input[j-(size-51)] = tradeHistory[j];
   }
   error = f2M_run( FannHandle[ file ], input );
   if( error == 0 )
   {
   //--- Assert return output   
      output = f2M_get_output( FannHandle[ file ], 0 );
      if( output != FANN_DOUBLE_ERROR ) 
         ret = output;
         
      FannDebugPrint( 1, "FannPredict",
         FannDebugDbl("output",output) );
   }
   else
      FannDebugPrint( 0, "FannPredict",
         " Error from Neural Network: "+
         FannDebugInt("error",error) );
      
//--- Assert destroy handle.
   f2M_destroy( FannHandle[ file ] );
   FannHandle[ file ] = -1;
   
   return(ret);
}

double FannGetMse(int file)
{
   if( FannHandle[ file ] >= 0 ) 
      return( f2M_get_MSE( FannHandle[file] ) );
   else 
      return(-1);
}

//|-----------------------------------------------------------------------------------------|
//|                             D E I N I T I A L I Z A T I O N                             |
//|-----------------------------------------------------------------------------------------|
void FannDeInit()
{
//-- Assert free handle
   f2M_destroy_all_anns();
}

//|-----------------------------------------------------------------------------------------|
//|                                     C O M M E N T                                       |
//|-----------------------------------------------------------------------------------------|
string FannComment(string cmt="")
{
   int total;
   
   string strtmp = cmt+"  -->"+FannName+" "+FannVer+"<--";

//---- Assert Basic settings in comment
   strtmp=strtmp+"\n    C="+DoubleToStr(FannCommitteeSize,0);
   strtmp=strtmp+" L="+DoubleToStr(FannLayer,0);
   strtmp=strtmp+" I="+DoubleToStr(FannInput,0);
   strtmp=strtmp+" H1="+DoubleToStr(FannHidden1,0);
   if( FannLayer == 4) 
      strtmp=strtmp+" H2="+DoubleToStr(FannHidden2,0);
   strtmp=strtmp+" O="+DoubleToStr(FannOutput,0);
                         
   strtmp=strtmp+"\n";
   return(strtmp);
}

void FannDebugPrint(int dbg, string fn, string msg, bool incr=true, int mod=0)
{
   if(FannDebug>=dbg)
   {
      if(dbg>=2 && FannDebugCount>0)
      {
         if( MathMod(FannCount,FannDebugCount) == mod )
            Print(FannDebug,"-",FannCount,":",fn,"(): ",msg);
         if( incr )
            FannCount ++;
      }
      else
         Print(FannDebug,":",fn,"(): ",msg);
   }
}
string FannDebugInt(string key, int val)
{
   return( StringConcatenate(";",key,"=",val) );
}
string FannDebugDbl(string key, double val, int dgt=5)
{
   return( StringConcatenate(";",key,"=",NormalizeDouble(val,dgt)) );
}
string FannDebugStr(string key, string val)
{
   return( StringConcatenate(";",key,"=\"",val,"\"") );
}
string FannDebugBln(string key, bool val)
{
   string valType;
   if( val )   valType="true";
   else        valType="false";
   return( StringConcatenate(";",key,"=",valType) );
}

//|-----------------------------------------------------------------------------------------|
//|                       E N D   O F   E X P E R T   A D V I S O R                         |
//|-----------------------------------------------------------------------------------------|