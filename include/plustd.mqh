//|-----------------------------------------------------------------------------------------|
//|                                                                              PlusTD.mqh |
//|                                                            Copyright © 2012, Dennis Lee |
//| Assert History                                                                          |
//| 1.0.0    Created PlusTD for Tom DeMark indicators.                                      |
//|-----------------------------------------------------------------------------------------|
#property   copyright "Copyright © 2012, Dennis Lee"
#include    <stdlib.mqh>

//|-----------------------------------------------------------------------------------------|
//|                           E X T E R N A L   V A R I A B L E S                           |
//|-----------------------------------------------------------------------------------------|
extern string     w1                         = "Wave Properties";
extern bool       TDUseWave1                 = true;
extern bool       TDAllowTradeOnError        = false;
extern string     w1_1                       = "Period: 0-Default";
extern int        TDPeriod                   = 0;
extern string     w1_2                       = "DoNotBuy: 0-F; 1-Ok; 2-Brk";
extern int        TDDoNotBuyUpLine           = 0;
extern int        TDDoNotBuy2UpLine          = 0;
extern int        TDDoNotBuyDnLine           = 0;
extern int        TDDoNotBuy2DnLine          = 0;
extern string     w1_3                       = "DoNotSell: 0-F; 1-Ok; 2-Brk";
extern int        TDDoNotSellUpLine          = 0;
extern int        TDDoNotSell2UpLine         = 0;
extern int        TDDoNotSellDnLine          = 0;
extern int        TDDoNotSell2DnLine         = 0;

//|-----------------------------------------------------------------------------------------|
//|                           I N T E R N A L   V A R I A B L E S                           |
//|-----------------------------------------------------------------------------------------|
string TDName     ="PlusTD";
string TDVer      ="1.0.0";
string gTDIsOkUpLineStr;
string gTDIsOk2UpLineStr;
string gTDIsOkDnLineStr;
string gTDIsOk2DnLineStr;
bool isOkUpLine   = false;
bool isOk2UpLine  = false;
bool isOkDnLine   = false;
bool isOk2DnLine  = false;
extern string     d1                         = "Debug Properties";
extern bool       TDViewDebugNotify          = false;
extern int        TDViewDebug                = 0;
extern int        TDViewDebugNoStack         = 1000;
extern int        TDViewDebugNoStackEnd      = 10;

//|-----------------------------------------------------------------------------------------|
//|                             I N I T I A L I Z A T I O N                                 |
//|-----------------------------------------------------------------------------------------|
void TDInit()
{
//--- Assert 1: Checks for TDPeriod is valid.
   if( TDPeriod == 0 )  TDPeriod = Period();

//--- Assert : TDUseWave1 true checks for existing global vars
   if( TDUseWave1 )
   {
      bool found = true;
      gTDIsOkUpLineStr  = StringConcatenate( Symbol(), "_", TDPeriod, "_IsOkUpLine" );
      gTDIsOk2UpLineStr = StringConcatenate( Symbol(), "_", TDPeriod, "_IsOk2UpLine" );
      gTDIsOkDnLineStr  = StringConcatenate( Symbol(), "_", TDPeriod, "_IsOkDnLine" );
      gTDIsOk2DnLineStr = StringConcatenate( Symbol(), "_", TDPeriod, "_IsOk2DnLine" );
      found = found && GlobalVariableCheck( gTDIsOkUpLineStr );
      found = found && GlobalVariableCheck( gTDIsOk2UpLineStr );
      found = found && GlobalVariableCheck( gTDIsOkDnLineStr );
      found = found && GlobalVariableCheck( gTDIsOk2DnLineStr );
      if( !found )
      {
         EaDebugPrint( 0, "init",
            EaDebugStr("TDName",TDName)+
            EaDebugStr("TDVer",TDVer)+
            EaDebugStr("sym",Symbol())+
            EaDebugInt("AccountNumber",AccountNumber())+
            EaDebugInt("TDPeriod", TDPeriod)+
            EaDebugBln("found", found)+
            " At least ONE of FOUR (4) global variables do not exist." );
      }
   }
   
//--- Assert Print Diagnostic for dbg>=1
   TDDebugPrintDiagnose();
   return(0);
}

//|-----------------------------------------------------------------------------------------|
//|                               M A I N   P R O C E D U R E                               |
//|-----------------------------------------------------------------------------------------|
bool isOkWave1Buy(bool isOkUp, bool isOk2Up, bool isOkDn, bool isOk2Dn)
{
//--- Assert default is Ok to trade
   if( !TDUseWave1 )  return(TDAllowTradeOnError);
   
   bool ret=true;
   if( TDDoNotBuyUpLine == 1 )   ret = ret && isOkUp == false;
   if( TDDoNotBuyUpLine == 2 )   ret = ret && isOkUp == true;
   if( TDDoNotBuy2UpLine == 1 )  ret = ret && isOk2Up == false;
   if( TDDoNotBuy2UpLine == 2 )  ret = ret && isOk2Up == true;
   if( TDDoNotBuyDnLine == 1 )   ret = ret && isOkDn == false;
   if( TDDoNotBuyDnLine == 2 )   ret = ret && isOkDn == true;
   if( TDDoNotBuy2DnLine == 1 )  ret = ret && isOk2Dn == false;
   if( TDDoNotBuy2DnLine == 2 )  ret = ret && isOk2Dn == true;
   return(ret);
}
bool isOkWave1Sell(bool isOkUp, bool isOk2Up, bool isOkDn, bool isOk2Dn)
{
//--- Assert default is Ok to trade
   if( !TDUseWave1 )  return(TDAllowTradeOnError);

   bool ret=true;
   if( TDDoNotSellUpLine == 1 )  ret = ret && isOkUp == false;
   if( TDDoNotSellUpLine == 2 )  ret = ret && isOkUp == true;
   if( TDDoNotSell2UpLine == 1 ) ret = ret && isOk2Up == false;
   if( TDDoNotSell2UpLine == 2 ) ret = ret && isOk2Up == true;
   if( TDDoNotSellDnLine == 1 )  ret = ret && isOkDn == false;
   if( TDDoNotSellDnLine == 2 )  ret = ret && isOkDn == true;
   if( TDDoNotSell2DnLine == 1 ) ret = ret && isOk2Dn == false;
   if( TDDoNotSell2DnLine == 2 ) ret = ret && isOk2Dn == true;
   return(ret);
}

void LoadGlobalVars(int type)
{
//--- Assert default is Ok to trade
   bool isOkUp, isOk2Up, isOkDn, isOk2Dn;
   bool allowTrade = TDAllowTradeOnError;

   if( type == OP_BUY )
   {
      if( TDDoNotBuyUpLine == 1 )   isOkUp   = !allowTrade;
      if( TDDoNotBuyUpLine == 2 )   isOkUp   = allowTrade;
      if( TDDoNotBuy2UpLine == 1 )  isOk2Up  = !allowTrade;
      if( TDDoNotBuy2UpLine == 2 )  isOk2Up  = allowTrade;
      if( TDDoNotBuyDnLine == 1 )   isOkDn   = !allowTrade;
      if( TDDoNotBuyDnLine == 2 )   isOkDn   = allowTrade;
      if( TDDoNotBuy2DnLine == 1 )  isOk2Dn  = !allowTrade;
      if( TDDoNotBuy2DnLine == 2 )  isOk2Dn  = allowTrade;
   }
   if( type == OP_SELL )
   {
      if( TDDoNotSellUpLine == 1 )  isOkUp   = !allowTrade;
      if( TDDoNotSellUpLine == 2 )  isOkUp   = allowTrade;
      if( TDDoNotSell2UpLine == 1 ) isOk2Up  = !allowTrade;
      if( TDDoNotSell2UpLine == 2 ) isOk2Up  = allowTrade;
      if( TDDoNotSellDnLine == 1 )  isOkDn   = !allowTrade;
      if( TDDoNotSellDnLine == 2 )  isOkDn   = allowTrade;
      if( TDDoNotSell2DnLine == 1 ) isOk2Dn  = !allowTrade;
      if( TDDoNotSell2DnLine == 2 ) isOk2Dn  = allowTrade;
   }
   
   if( !TDUseWave1 )
   {
      isOkUpLine  = isOkUp;
      isOk2UpLine = isOk2Up;
      isOkDnLine  = isOkDn;
      isOk2DnLine = isOk2Dn;
      return(0);
   }
   
   if( GlobalVariableCheck( gTDIsOkUpLineStr ) ) 
      isOkUpLine  = GlobalVariableGet( gTDIsOkUpLineStr );
   else
      isOkUpLine  = isOkUp;
   if( GlobalVariableCheck( gTDIsOk2UpLineStr ) ) 
      isOk2UpLine = GlobalVariableGet( gTDIsOk2UpLineStr );
   else
      isOk2UpLine = isOk2Up;
      
   if( GlobalVariableCheck( gTDIsOkDnLineStr ) ) 
      isOkDnLine = GlobalVariableGet( gTDIsOkDnLineStr );
   else
      isOkDnLine = isOkDn;
   if( GlobalVariableCheck( gTDIsOk2DnLineStr ) ) 
      isOk2DnLine = GlobalVariableGet( gTDIsOk2DnLineStr );
   else
      isOk2DnLine = isOk2Dn;
}

//|-----------------------------------------------------------------------------------------|
//|                           I N T E R N A L   F U N C T I O N S                           |
//|-----------------------------------------------------------------------------------------|

//|-----------------------------------------------------------------------------------------|
//|                             D E I N I T I A L I Z A T I O N                             |
//|-----------------------------------------------------------------------------------------|
void TDDeInit()
{
   return(0);
}

//|-----------------------------------------------------------------------------------------|
//|                                     C O M M E N T                                       |
//|-----------------------------------------------------------------------------------------|
string TDComment(string cmt="")
{
   string strtmp = cmt+"  -->"+TDName+"_"+TDVer+"<--";

                         
   strtmp = strtmp+"\n";
   return(strtmp);
}
void TDDebugPrintDiagnose()
{
   if(!TDUseWave1)   return(0);
   if(TDViewDebug<1) return(0);

//--- Assert print every combination of global var inputs and the wave signal output
   TDDebugPrint(1, "PrintDiagnose",
      TDDebugInt("DoNotBuyUpLine",TDDoNotBuyUpLine)+
      TDDebugInt("DoNotBuy2UpLine",TDDoNotBuy2UpLine)+
      TDDebugInt("DoNotBuyDnLine",TDDoNotBuyDnLine)+
      TDDebugInt("DoNotBuy2DnLine",TDDoNotBuy2DnLine) );
   TDDebugPrint(1, "PrintDiagnose", TDDebugInt("#",1)+
      TDDebugBln("isOkUp",true)+TDDebugBln("isOk2Up",true)+
      TDDebugBln("isOkDn",true)+TDDebugBln("isOk2Dn",true)+
      TDDebugBln("isOkWave1Buy",isOkWave1Buy(true,true,true,true)) );
   TDDebugPrint(1, "PrintDiagnose", TDDebugInt("#",2)+
      TDDebugBln("isOkUp",true)+TDDebugBln("isOk2Up",true)+
      TDDebugBln("isOkDn",true)+TDDebugBln("isOk2Dn",false)+
      TDDebugBln("isOkWave1Buy",isOkWave1Buy(true,true,true,false)) );
   TDDebugPrint(1, "PrintDiagnose", TDDebugInt("#",3)+
      TDDebugBln("isOkUp",true)+TDDebugBln("isOk2Up",true)+
      TDDebugBln("isOkDn",false)+TDDebugBln("isOk2Dn",true)+
      TDDebugBln("isOkWave1Buy",isOkWave1Buy(true,true,false,true)) );
   TDDebugPrint(1, "PrintDiagnose", TDDebugInt("#",4)+
      TDDebugBln("isOkUp",true)+TDDebugBln("isOk2Up",false)+
      TDDebugBln("isOkDn",true)+TDDebugBln("isOk2Dn",true)+
      TDDebugBln("isOkWave1Buy",isOkWave1Buy(true,false,true,true)) );
   TDDebugPrint(1, "PrintDiagnose", TDDebugInt("#",5)+
      TDDebugBln("isOkUp",false)+TDDebugBln("isOk2Up",true)+
      TDDebugBln("isOkDn",true)+TDDebugBln("isOk2Dn",true)+
      TDDebugBln("isOkWave1Buy",isOkWave1Buy(false,true,true,true)) );
   TDDebugPrint(1, "PrintDiagnose", TDDebugInt("#",6)+
      TDDebugBln("isOkUp",false)+TDDebugBln("isOk2Up",true)+
      TDDebugBln("isOkDn",true)+TDDebugBln("isOk2Dn",false)+
      TDDebugBln("isOkWave1Buy",isOkWave1Buy(false,true,true,false)) );
   TDDebugPrint(1, "PrintDiagnose", TDDebugInt("#",7)+
      TDDebugBln("isOkUp",false)+TDDebugBln("isOk2Up",true)+
      TDDebugBln("isOkDn",false)+TDDebugBln("isOk2Dn",true)+
      TDDebugBln("isOkWave1Buy",isOkWave1Buy(false,true,false,true)) );
   TDDebugPrint(1, "PrintDiagnose", TDDebugInt("#",8)+
      TDDebugBln("isOkUp",false)+TDDebugBln("isOk2Up",false)+
      TDDebugBln("isOkDn",true)+TDDebugBln("isOk2Dn",true)+
      TDDebugBln("isOkWave1Buy",isOkWave1Buy(false,false,true,true)) );
   TDDebugPrint(1, "PrintDiagnose", TDDebugInt("#",9)+
      TDDebugBln("isOkUp",true)+TDDebugBln("isOk2Up",false)+
      TDDebugBln("isOkDn",true)+TDDebugBln("isOk2Dn",false)+
      TDDebugBln("isOkWave1Buy",isOkWave1Buy(true,false,true,false)) );
   TDDebugPrint(1, "PrintDiagnose", TDDebugInt("#",10)+
      TDDebugBln("isOkUp",true)+TDDebugBln("isOk2Up",false)+
      TDDebugBln("isOkDn",false)+TDDebugBln("isOk2Dn",true)+
      TDDebugBln("isOkWave1Buy",isOkWave1Buy(true,false,false,true)) );
   TDDebugPrint(1, "PrintDiagnose", TDDebugInt("#",11)+
      TDDebugBln("isOkUp",true)+TDDebugBln("isOk2Up",true)+
      TDDebugBln("isOkDn",false)+TDDebugBln("isOk2Dn",false)+
      TDDebugBln("isOkWave1Buy",isOkWave1Buy(true,true,false,false)) );
   TDDebugPrint(1, "PrintDiagnose", TDDebugInt("#",12)+
      TDDebugBln("isOkUp",false)+TDDebugBln("isOk2Up",false)+
      TDDebugBln("isOkDn",true)+TDDebugBln("isOk2Dn",false)+
      TDDebugBln("isOkWave1Buy",isOkWave1Buy(false,false,true,false)) );
   TDDebugPrint(1, "PrintDiagnose", TDDebugInt("#",13)+
      TDDebugBln("isOkUp",false)+TDDebugBln("isOk2Up",false)+
      TDDebugBln("isOkDn",false)+TDDebugBln("isOk2Dn",true)+
      TDDebugBln("isOkWave1Buy",isOkWave1Buy(false,false,false,true)) );
   TDDebugPrint(1, "PrintDiagnose", TDDebugInt("#",14)+
      TDDebugBln("isOkUp",false)+TDDebugBln("isOk2Up",true)+
      TDDebugBln("isOkDn",false)+TDDebugBln("isOk2Dn",false)+
      TDDebugBln("isOkWave1Buy",isOkWave1Buy(false,true,false,false)) );
   TDDebugPrint(1, "PrintDiagnose", TDDebugInt("#",15)+
      TDDebugBln("isOkUp",true)+TDDebugBln("isOk2Up",false)+
      TDDebugBln("isOkDn",false)+TDDebugBln("isOk2Dn",false)+
      TDDebugBln("isOkWave1Buy",isOkWave1Buy(true,false,false,false)) );
   TDDebugPrint(1, "PrintDiagnose", TDDebugInt("#",16)+
      TDDebugBln("isOkUp",false)+TDDebugBln("isOk2Up",false)+
      TDDebugBln("isOkDn",false)+TDDebugBln("isOk2Dn",false)+
      TDDebugBln("isOkWave1Buy",isOkWave1Buy(false,false,false,false)) );
      
//--- Assert print every combination of global var inputs and the wave signal output
   TDDebugPrint(1, "PrintDiagnose",
      TDDebugInt("DoNotSellUpLine",TDDoNotSellUpLine)+
      TDDebugInt("DoNotSell2UpLine",TDDoNotSell2UpLine)+
      TDDebugInt("DoNotSellDnLine",TDDoNotSellDnLine)+
      TDDebugInt("DoNotSell2DnLine",TDDoNotSell2DnLine) );
   TDDebugPrint(1, "PrintDiagnose", TDDebugInt("#",1)+
      TDDebugBln("isOkUp",true)+TDDebugBln("isOk2Up",true)+
      TDDebugBln("isOkDn",true)+TDDebugBln("isOk2Dn",true)+
      TDDebugBln("isOkWave1Sell",isOkWave1Sell(true,true,true,true)) );
   TDDebugPrint(1, "PrintDiagnose", TDDebugInt("#",2)+
      TDDebugBln("isOkUp",true)+TDDebugBln("isOk2Up",true)+
      TDDebugBln("isOkDn",true)+TDDebugBln("isOk2Dn",false)+
      TDDebugBln("isOkWave1Sell",isOkWave1Sell(true,true,true,false)) );
   TDDebugPrint(1, "PrintDiagnose", TDDebugInt("#",3)+
      TDDebugBln("isOkUp",true)+TDDebugBln("isOk2Up",true)+
      TDDebugBln("isOkDn",false)+TDDebugBln("isOk2Dn",true)+
      TDDebugBln("isOkWave1Sell",isOkWave1Sell(true,true,false,true)) );
   TDDebugPrint(1, "PrintDiagnose", TDDebugInt("#",4)+
      TDDebugBln("isOkUp",true)+TDDebugBln("isOk2Up",false)+
      TDDebugBln("isOkDn",true)+TDDebugBln("isOk2Dn",true)+
      TDDebugBln("isOkWave1Sell",isOkWave1Sell(true,false,true,true)) );
   TDDebugPrint(1, "PrintDiagnose", TDDebugInt("#",5)+
      TDDebugBln("isOkUp",false)+TDDebugBln("isOk2Up",true)+
      TDDebugBln("isOkDn",true)+TDDebugBln("isOk2Dn",true)+
      TDDebugBln("isOkWave1Sell",isOkWave1Sell(false,true,true,true)) );
   TDDebugPrint(1, "PrintDiagnose", TDDebugInt("#",6)+
      TDDebugBln("isOkUp",false)+TDDebugBln("isOk2Up",true)+
      TDDebugBln("isOkDn",true)+TDDebugBln("isOk2Dn",false)+
      TDDebugBln("isOkWave1Sell",isOkWave1Sell(false,true,true,false)) );
   TDDebugPrint(1, "PrintDiagnose", TDDebugInt("#",7)+
      TDDebugBln("isOkUp",false)+TDDebugBln("isOk2Up",true)+
      TDDebugBln("isOkDn",false)+TDDebugBln("isOk2Dn",true)+
      TDDebugBln("isOkWave1Sell",isOkWave1Sell(false,true,false,true)) );
   TDDebugPrint(1, "PrintDiagnose", TDDebugInt("#",8)+
      TDDebugBln("isOkUp",false)+TDDebugBln("isOk2Up",false)+
      TDDebugBln("isOkDn",true)+TDDebugBln("isOk2Dn",true)+
      TDDebugBln("isOkWave1Sell",isOkWave1Sell(false,false,true,true)) );
   TDDebugPrint(1, "PrintDiagnose", TDDebugInt("#",9)+
      TDDebugBln("isOkUp",true)+TDDebugBln("isOk2Up",false)+
      TDDebugBln("isOkDn",true)+TDDebugBln("isOk2Dn",false)+
      TDDebugBln("isOkWave1Sell",isOkWave1Sell(true,false,true,false)) );
   TDDebugPrint(1, "PrintDiagnose", TDDebugInt("#",10)+
      TDDebugBln("isOkUp",true)+TDDebugBln("isOk2Up",false)+
      TDDebugBln("isOkDn",false)+TDDebugBln("isOk2Dn",true)+
      TDDebugBln("isOkWave1Sell",isOkWave1Sell(true,false,false,true)) );
   TDDebugPrint(1, "PrintDiagnose", TDDebugInt("#",11)+
      TDDebugBln("isOkUp",true)+TDDebugBln("isOk2Up",true)+
      TDDebugBln("isOkDn",false)+TDDebugBln("isOk2Dn",false)+
      TDDebugBln("isOkWave1Sell",isOkWave1Sell(true,true,false,false)) );
   TDDebugPrint(1, "PrintDiagnose", TDDebugInt("#",12)+
      TDDebugBln("isOkUp",false)+TDDebugBln("isOk2Up",false)+
      TDDebugBln("isOkDn",true)+TDDebugBln("isOk2Dn",false)+
      TDDebugBln("isOkWave1Sell",isOkWave1Sell(false,false,true,false)) );
   TDDebugPrint(1, "PrintDiagnose", TDDebugInt("#",13)+
      TDDebugBln("isOkUp",false)+TDDebugBln("isOk2Up",false)+
      TDDebugBln("isOkDn",false)+TDDebugBln("isOk2Dn",true)+
      TDDebugBln("isOkWave1Sell",isOkWave1Sell(false,false,false,true)) );
   TDDebugPrint(1, "PrintDiagnose", TDDebugInt("#",14)+
      TDDebugBln("isOkUp",false)+TDDebugBln("isOk2Up",true)+
      TDDebugBln("isOkDn",false)+TDDebugBln("isOk2Dn",false)+
      TDDebugBln("isOkWave1Sell",isOkWave1Sell(false,true,false,false)) );
   TDDebugPrint(1, "PrintDiagnose", TDDebugInt("#",15)+
      TDDebugBln("isOkUp",true)+TDDebugBln("isOk2Up",false)+
      TDDebugBln("isOkDn",false)+TDDebugBln("isOk2Dn",false)+
      TDDebugBln("isOkWave1Sell",isOkWave1Sell(true,false,false,false)) );
   TDDebugPrint(1, "PrintDiagnose", TDDebugInt("#",16)+
      TDDebugBln("isOkUp",false)+TDDebugBln("isOk2Up",false)+
      TDDebugBln("isOkDn",false)+TDDebugBln("isOk2Dn",false)+
      TDDebugBln("isOkWave1Sell",isOkWave1Sell(false,false,false,false)) );
}

void TDDebugPrint(int dbg, string fn, string msg)
{
   static int noStackCount;
   if(TDViewDebug>=dbg)
   {
      if(dbg>=2 && TDViewDebugNoStack>0)
      {
         if( MathMod(noStackCount,TDViewDebugNoStack) <= TDViewDebugNoStackEnd )
            Print(TDViewDebug,"-",noStackCount,":",fn,"(): ",msg);
            
         noStackCount ++;
      }
      else
      {
         if(TDViewDebugNotify) SendNotification( TDViewDebug + ":" + fn + "(): " + msg );
         Print(TDViewDebug,":",fn,"(): ",msg);
      }
   }
}
string TDDebugInt(string key, int val)
{
   return( StringConcatenate(";",key,"=",val) );
}
string TDDebugDbl(string key, double val, int dgt=5)
{
   return( StringConcatenate(";",key,"=",NormalizeDouble(val,dgt)) );
}
string TDDebugStr(string key, string val)
{
   return( StringConcatenate(";",key,"=\"",val,"\"") );
}
string TDDebugBln(string key, bool val)
{
   string valType;
   if( val )   valType="true";
   else        valType="false";
   return( StringConcatenate(";",key,"=",valType) );
}

//|-----------------------------------------------------------------------------------------|
//|                       E N D   O F   E X P E R T   A D V I S O R                         |
//|-----------------------------------------------------------------------------------------|

