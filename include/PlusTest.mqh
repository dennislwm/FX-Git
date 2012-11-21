//|-----------------------------------------------------------------------------------------|
//|                                                                            PlusTest.mqh |
//|                                                            Copyright © 2012, Dennis Lee |
//| Assert History                                                                          |
//| 1.0.0    Created PlusTest and PlusExpect to perform unit tests of MQ4 functions.        |
//|-----------------------------------------------------------------------------------------|
#property   copyright "Copyright © 2012, Dennis Lee"
#include <PlusExpect.mqh>

//|-----------------------------------------------------------------------------------------|
//|                           E X T E R N A L   V A R I A B L E S                           |
//|-----------------------------------------------------------------------------------------|
extern string test_s1                = "0-No debug; 1-Debug minimal; 2-Debug stack";
extern int TestViewDebug             = 1;
extern int TestViewDebugNoStack      = 1000;
extern int TestViewDebugNoStackEnd   = 0;

//|-----------------------------------------------------------------------------------------|
//|                           I N T E R N A L   V A R I A B L E S                           |
//|-----------------------------------------------------------------------------------------|
string   TestName    ="PlusTest";
string   TestVer     ="1.0.0";
bool     TestVerbose;

//|-----------------------------------------------------------------------------------------|
//|                             I N I T I A L I Z A T I O N                                 |
//|-----------------------------------------------------------------------------------------|
void TestInit(string context, bool verbose=true)
{
   TestVerbose=verbose;
   Print(context, " ------------------------------------>");
}

//|-----------------------------------------------------------------------------------------|
//|                           E X T E R N A L   F U N C T I O N S                           |
//|-----------------------------------------------------------------------------------------|
void TestThat(string verbose, bool pass)
{
   if( TestVerbose )
   {
      string out="   "+verbose+"\n";
      if( pass )  Print(".... ", out);
      else        Print("Fail ", out);
   }
   else
   {
      if( pass )  Print(".");
      else        Print("F");
   }
}

//|-----------------------------------------------------------------------------------------|
//|                             D E I N I T I A L I Z A T I O N                             |
//|-----------------------------------------------------------------------------------------|
void TestDeInit()
{
   Print("End ------------------------------------>\n");
}

//|-----------------------------------------------------------------------------------------|
//|                           I N T E R N A L   F U N C T I O N S                           |
//|-----------------------------------------------------------------------------------------|

//|-----------------------------------------------------------------------------------------|
//|                                     C O M M E N T                                       |
//|-----------------------------------------------------------------------------------------|
string TestComment(string cmt="")
{
   string strtmp = cmt+"  -->"+TestName+"_"+TestVer+"<--";

                         
   strtmp = strtmp+"\n";
   return(strtmp);
}

void TestDebugPrint(int dbg, string fn, string msg)
{
   static int noStackCount;
   if(TestViewDebug>=dbg)
   {
      if(dbg>=2 && TestViewDebugNoStack>0)
      {
         if( MathMod(noStackCount,TestViewDebugNoStack) <= TestViewDebugNoStackEnd )
            Print(TestViewDebug,"-",noStackCount,":",fn,"(): ",msg);
            
         noStackCount ++;
      }
      else
         Print(TestViewDebug,":",fn,"(): ",msg);
   }
}
string TestDebugInt(string key, int val)
{
   return( StringConcatenate(";",key,"=",val) );
}
string TestDebugDbl(string key, double val, int dgt=5)
{
   return( StringConcatenate(";",key,"=",NormalizeDouble(val,dgt)) );
}
string TestDebugStr(string key, string val)
{
   return( StringConcatenate(";",key,"=\"",val,"\"") );
}
string TestDebugBln(string key, bool val)
{
   string valType;
   if( val )   valType="true";
   else        valType="false";
   return( StringConcatenate(";",key,"=",valType) );
}

//|-----------------------------------------------------------------------------------------|
//|                       E N D   O F   E X P E R T   A D V I S O R                         |
//|-----------------------------------------------------------------------------------------|