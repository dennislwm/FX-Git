//|-----------------------------------------------------------------------------------------|
//|                                                                              PlusTD.mqh |
//|                                                            Copyright © 2012, Dennis Lee |
//| Assert History                                                                          |
//| 1.0.3    Added externs DoNotBuyGreedy and DoNotSellGreedy for a slightly LESS           |
//|            conservative stance on signals from functions TDIsOkWave1Buy() and           |
//|            TDIsOkWave1Sell() respectively.                                              |
//| 1.0.2    Replace global variables gTDIsOkUpLineStr, gTDIsOk2UpLineStr, gTDIsOkDnLineStr |
//|            and gTDIsOk2DnLineStr with new functions TDGlobalUpStr() and TDGlobalDnStr().|
//|            Replace global variables isOkUpLine, isOk2UpLine, isOkDnLine and isOk2DnLine |
//|            with new functions TDGetUpBln() and TDGetDnBln().                            |
//|          Replace function TDDebugPrintDiagnose() with a new script TestPlusTD.mq4.      |
//| 1.0.1    Added several support functions: Wave1Buy(), Wave1Sell(), GlobalCheck(),       |
//|            IsOkUpLine(), IsOkDnLine(), IsOk2UpLine(), IsOk2DnLine().                    |
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
extern bool       TDDoNotBuyGreedy           = false;
extern string     w1_3                       = "DoNotSell: 0-F; 1-Ok; 2-Brk";
extern int        TDDoNotSellUpLine          = 0;
extern int        TDDoNotSell2UpLine         = 0;
extern int        TDDoNotSellDnLine          = 0;
extern int        TDDoNotSell2DnLine         = 0;
extern bool       TDDoNotSellGreedy          = false;

//|-----------------------------------------------------------------------------------------|
//|                           I N T E R N A L   V A R I A B L E S                           |
//|-----------------------------------------------------------------------------------------|
string TDName     ="PlusTD";
string TDVer      ="1.0.3";
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
      found = found && GlobalVariableCheck( TDGlobalUpStr(1) );
      found = found && GlobalVariableCheck( TDGlobalUpStr(2) );
      found = found && GlobalVariableCheck( TDGlobalDnStr(1) );
      found = found && GlobalVariableCheck( TDGlobalDnStr(2) );
      if( !found )
      {
         TDDebugPrint( 0, "init",
            TDDebugStr("TDName",TDName)+
            TDDebugStr("TDVer",TDVer)+
            TDDebugStr("sym",Symbol())+
            TDDebugStr("AccountNumber",AccountNumber())+
            TDDebugStr("TDPeriod", TDPeriod)+
            TDDebugStr("found", found)+
            " At least ONE of FOUR (4) global variables do not exist." );
      }
   }
   
   return(0);
}

//|-----------------------------------------------------------------------------------------|
//|                               M A I N   P R O C E D U R E                               |
//|-----------------------------------------------------------------------------------------|
bool TDWave1Buy()
{
   TDGlobalLoad( OP_BUY );
   return( TDIsOkWave1Buy( TDGetUpBln(1), 
                           TDGetUpBln(2), 
                           TDGetDnBln(1), 
                           TDGetDnBln(2) ) );
}
bool TDWave1Sell()
{
   TDGlobalLoad( OP_SELL );
   return( TDIsOkWave1Sell( TDGetUpBln(1), 
                            TDGetUpBln(2), 
                            TDGetDnBln(1), 
                            TDGetDnBln(2) ) );
}

bool TDIsOkWave1Buy(bool isOkUp, bool isOk2Up, bool isOkDn, bool isOk2Dn)
{
   bool retUp, ret2Up, retDn, ret2Dn;
   
//--- Assert default is Ok to trade
   if( !TDUseWave1 )  return(true);
   
   if( !TDAllowTradeOnError )
   {
      if( ! TDGlobalCheck() ) return( false );
   }
//--- By default, TDDoNotBuyGreedy is false, which means that the most
//      conservative buy is allowed, i.e. if BOTH lines are true.
//    However, if TDDoNotBuyGreedy is true, then there is a slightly
//      less conservative buy, i.e. if ONE line is true, then buy.
   if( TDDoNotBuyGreedy == true )
   {
      retUp=true;
      if( TDDoNotBuyUpLine == 1 && !(isOkUp == false) ) retUp=false;
      if( TDDoNotBuyUpLine == 2 && !(isOkUp == true) ) retUp=false;
      ret2Up=true;
      if( TDDoNotBuy2UpLine == 1 && !(isOk2Up == false) ) ret2Up=false;
      if( TDDoNotBuy2UpLine == 2 && !(isOk2Up == true) ) ret2Up=false;
      retDn=true;
      if( TDDoNotBuyDnLine == 1 && !(isOkDn == false) ) retDn=false;
      if( TDDoNotBuyDnLine == 2 && !(isOkDn == true) ) retDn=false;
      ret2Dn=true;
      if( TDDoNotBuy2DnLine == 1 && !(isOk2Dn == false) ) ret2Dn=false;
      if( TDDoNotBuy2DnLine == 2 && !(isOk2Dn == true) ) ret2Dn=false;
         /*TDDebugPrint( 0, "TDIsOkWave1Buy",
            TDDebugBln("retUp",retUp)+
            TDDebugBln("ret2Up",ret2Up)+
            TDDebugBln("retDn",retDn)+
            TDDebugBln("ret2Dn",ret2Dn) );*/
   //--- Check for TWO (2) cases:
   //     (1) TRUE and FALSE
   //     (2) FALSE and TRUE
   //    Any other combination is the same as TDDoNotBuyGreedy is false
   //     therefore just continue with the rest of code
      if( (retUp == true && ret2Up == false) ) return( true );
      if( (retUp == false && ret2Up == true) ) return( true );
      if( (retDn == true && ret2Dn == false) ) return( true );
      if( (retDn == false && ret2Dn == true) ) return( true );
   }
   if( TDDoNotBuyUpLine == 1 )
   {
      if( ! (isOkUp == false) ) return( false );
   }
   if( TDDoNotBuyUpLine == 2 )
   {
      if( ! (isOkUp == true) ) return( false );
   }
   if( TDDoNotBuy2UpLine == 1 )
   {
      if( ! (isOk2Up == false) ) return( false );
   }
   if( TDDoNotBuy2UpLine == 2 )  
   {
      if( ! (isOk2Up == true) ) return( false );
   }
   if( TDDoNotBuyDnLine == 1 )
   {
      if( ! (isOkDn == false) ) return( false );
   }
   if( TDDoNotBuyDnLine == 2 )
   {
      if( ! (isOkDn == true) ) return( false );
   }
   if( TDDoNotBuy2DnLine == 1 )
   {
      if( ! (isOk2Dn == false) ) return( false );
   }
   if( TDDoNotBuy2DnLine == 2 )  
   {
      if( ! (isOk2Dn == true) ) return( false );
   }
   return(true);
}
bool TDIsOkWave1Sell(bool isOkUp, bool isOk2Up, bool isOkDn, bool isOk2Dn)
{
   bool retUp, ret2Up, retDn, ret2Dn;
   
//--- Assert default is Ok to trade
   if( !TDUseWave1 )  return(true);

   if( !TDAllowTradeOnError )
   {
      if( ! TDGlobalCheck() ) return( false );
   }
//--- By default, TDDoNotSellGreedy is false, which means that the most
//      conservative sell is allowed, i.e. if BOTH lines are true.
//    However, if TDDoNotSellGreedy is true, then there is a slightly
//      less conservative sell, i.e. if ONE line is true, then sell.
   if( TDDoNotSellGreedy == true )
   {
      retUp=true;
      if( TDDoNotSellUpLine == 1 && !(isOkUp == false) ) retUp=false;
      if( TDDoNotSellUpLine == 2 && !(isOkUp == true) ) retUp=false;
      ret2Up=true;
      if( TDDoNotSell2UpLine == 1 && !(isOk2Up == false) ) ret2Up=false;
      if( TDDoNotSell2UpLine == 2 && !(isOk2Up == true) ) ret2Up=false;
      retDn=true;
      if( TDDoNotSellDnLine == 1 && !(isOkDn == false) ) retDn=false;
      if( TDDoNotSellDnLine == 2 && !(isOkDn == true) ) retDn=false;
      ret2Dn=true;
      if( TDDoNotSell2DnLine == 1 && !(isOk2Dn == false) ) ret2Dn=false;
      if( TDDoNotSell2DnLine == 2 && !(isOk2Dn == true) ) ret2Dn=false;
   //--- Check for TWO (2) cases:
   //     (1) TRUE and FALSE
   //     (2) FALSE and TRUE
   //    Any other combination is the same as TDDoNotSellGreedy is false
   //     therefore just continue with the rest of code
      if( (retUp == true && ret2Up == false) ) return( true );
      if( (retUp == false && ret2Up == true) ) return( true );
      if( (retDn == true && ret2Dn == false) ) return( true );
      if( (retDn == false && ret2Dn == true) ) return( true );
   }
   if( TDDoNotSellUpLine == 1 )
   {
      if( ! (isOkUp == false) ) return( false );
   }
   if( TDDoNotSellUpLine == 2 )
   {
      if( ! (isOkUp == true) ) return( false );
   }
   if( TDDoNotSell2UpLine == 1 )
   {
      if( ! (isOk2Up == false) ) return( false );
   }
   if( TDDoNotSell2UpLine == 2 )
   {
      if( ! (isOk2Up == true) ) return( false );
   }
   if( TDDoNotSellDnLine == 1 )
   {
      if( ! (isOkDn == false) ) return( false );
   }
   if( TDDoNotSellDnLine == 2 )
   {
      if( ! (isOkDn == true) ) return( false );
   }
   if( TDDoNotSell2DnLine == 1 )
   {
      if( ! (isOk2Dn == false) ) return( false );
   }
   if( TDDoNotSell2DnLine == 2 )
   {
      if( ! (isOk2Dn == true) ) return( false );
   }
   return(true);
}
void TDGlobalLoad(int type)
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
      return(0);
   }
}

//|-----------------------------------------------------------------------------------------|
//|                           I N T E R N A L   F U N C T I O N S                           |
//|-----------------------------------------------------------------------------------------|
bool TDGlobalCheck()
{
//--- return false if at least ONE (1) check failed.
   return( GlobalVariableCheck( TDGlobalUpStr(1) ) && 
           GlobalVariableCheck( TDGlobalUpStr(2) ) &&
           GlobalVariableCheck( TDGlobalDnStr(1) ) && 
           GlobalVariableCheck( TDGlobalDnStr(2) ) );
}
string TDGlobalUpStr( int num )
{
   string retStr = "";
   if( num == 1 ) retStr = StringConcatenate( Symbol(), "_", TDPeriod, "_IsOkUpLine" );
   if( num == 2 ) retStr = StringConcatenate( Symbol(), "_", TDPeriod, "_IsOk2UpLine" );
   return( retStr );
}
string TDGlobalDnStr( int num )
{
   string retStr = "";
   if( num == 1 ) retStr = StringConcatenate( Symbol(), "_", TDPeriod, "_IsOkDnLine" );
   if( num == 2 ) retStr = StringConcatenate( Symbol(), "_", TDPeriod, "_IsOk2DnLine" );
   return( retStr );
}
bool TDGetUpBln( int num )
{
//--- Assume missing global var, we have to estimate whether the line is ok OR not
//       (1) DoNotBuyUpLine=Ok with AllowTrade TRUE, then UpLine is ALWAYS Brk
//       (2) DoNotBuyUpLine=Ok with AllowTrade FALSE, then UpLine is ALWAYS Ok
//       (3) DoNotBuyUpLine=Brk with AllowTrade TRUE, then UpLine is ALWAYS Ok
//       (3) DoNotBuyUpLine=Brk with AllowTrade FALSE, then UpLine is ALWAYS Brk
   bool upLine;
   bool missingBln = !GlobalVariableCheck( TDGlobalUpStr(1) );

   if( num == 1 )
   {
   //--- Assume AllowTrade FALSE
      if( TDDoNotBuyUpLine == 1 )   upLine=true;
      if( TDDoNotBuyUpLine == 2 )   upLine=false;
   }
   if( num == 2 )
   {
   //--- Assume AllowTrade FALSE
      if( TDDoNotBuy2UpLine == 1 )   upLine=true;
      if( TDDoNotBuy2UpLine == 2 )   upLine=false;
   }
   if( TDAllowTradeOnError ) upLine = !upLine;
   
   if( missingBln ) 
      return( upLine );
   else
      return( GlobalVariableGet( TDGlobalUpStr(num) ) );
}
bool TDGetDnBln( int num )
{
//--- Assume missing global var, we have to estimate whether the line is ok OR not
//       (1) DoNotBuyDnLine=Ok with AllowTrade TRUE, then DnLine is ALWAYS Brk
//       (2) DoNotBuyDnLine=Ok with AllowTrade FALSE, then DnLine is ALWAYS Ok
//       (3) DoNotBuyDnLine=Brk with AllowTrade TRUE, then DnLine is ALWAYS Ok
//       (3) DoNotBuyDnLine=Brk with AllowTrade FALSE, then DnLine is ALWAYS Brk
   bool dnLine;
   bool missingBln = !GlobalVariableCheck( TDGlobalDnStr(1) );

   if( num == 1 )
   {
   //--- Assume AllowTrade FALSE
      if( TDDoNotBuyDnLine == 1 )   dnLine=true;
      if( TDDoNotBuyDnLine == 2 )   dnLine=false;
   }
   if( num == 2 )
   {
   //--- Assume AllowTrade FALSE
      if( TDDoNotBuy2DnLine == 1 )   dnLine=true;
      if( TDDoNotBuy2DnLine == 2 )   dnLine=false;
   }
   if( TDAllowTradeOnError ) dnLine = !dnLine;
   
   if( missingBln ) 
      return( dnLine );
   else
      return( GlobalVariableGet( TDGlobalDnStr(num) ) );
}

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
   string strtmp = cmt+"  -->"+TDName+" "+TDVer+"<--";
   strtmp = strtmp+"\n";

   if(TDUseWave1)
   {
      strtmp=strtmp+"    Wave1 Enabled.";
      strtmp=strtmp+"  Period="+TDPeriod;
      strtmp=strtmp+"  Check=";
      if( TDGlobalCheck() )
         strtmp=strtmp+"Ok";
      else
         strtmp=strtmp+"Fail";
      strtmp=strtmp+"\n";
   //--- Wave1 logic for Do Not Buy
      if( TDDoNotBuyUpLine>0 || TDDoNotBuy2UpLine>0 || TDDoNotBuyDnLine>0 || TDDoNotBuy2DnLine>0 )
      {
         strtmp=strtmp+"    Do Not Buy Cond:";
         if( TDDoNotBuyUpLine==1 )  strtmp=strtmp+"  UpOk";
         if( TDDoNotBuyUpLine==2 )  strtmp=strtmp+"  UpBrk";
         if( TDDoNotBuy2UpLine==1 ) strtmp=strtmp+"  Up2Ok";
         if( TDDoNotBuy2UpLine==2 ) strtmp=strtmp+"  Up2Brk";
         if( TDDoNotBuyDnLine==1 )  strtmp=strtmp+"  DnOk";
         if( TDDoNotBuyDnLine==2 )  strtmp=strtmp+"  DnBrk";
         if( TDDoNotBuy2DnLine==1 ) strtmp=strtmp+"  Dn2Ok";
         if( TDDoNotBuy2DnLine==2 ) strtmp=strtmp+"  Dn2Brk";
         strtmp=strtmp+"\n";
      }
   //--- Wave 1 logic for Do Not Sell
      if( TDDoNotSellUpLine>0 || TDDoNotSell2UpLine>0 || TDDoNotSellDnLine>0 || TDDoNotSell2DnLine>0 )
      {
         strtmp=strtmp+"    Do Not Sell Cond:";
         if( TDDoNotSellUpLine==1 )  strtmp=strtmp+"  UpOk";
         if( TDDoNotSellUpLine==2 )  strtmp=strtmp+"  UpBrk";
         if( TDDoNotSell2UpLine==1 ) strtmp=strtmp+"  Up2Ok";
         if( TDDoNotSell2UpLine==2 ) strtmp=strtmp+"  Up2Brk";
         if( TDDoNotSellDnLine==1 )  strtmp=strtmp+"  DnOk";
         if( TDDoNotSellDnLine==2 )  strtmp=strtmp+"  DnBrk";
         if( TDDoNotSell2DnLine==1 ) strtmp=strtmp+"  Dn2Ok";
         if( TDDoNotSell2DnLine==2 ) strtmp=strtmp+"  Dn2Brk";
         strtmp=strtmp+"\n";
      }
   }
   
   return(strtmp);
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
string TDDebugGlobal()
{
   if(!TDUseWave1)   return("");

//--- Assert print every combination of global var inputs and the wave signal output
   return( TDDebugBln("isOkUpLine", TDGetUpBln(1))+
           TDDebugBln("isOk2UpLine",TDGetUpBln(2))+
           TDDebugBln("isOkDnLine", TDGetDnBln(1))+
           TDDebugBln("isOk2DnLine",TDGetDnBln(2)) );
}
//|-----------------------------------------------------------------------------------------|
//|                       E N D   O F   E X P E R T   A D V I S O R                         |
//|-----------------------------------------------------------------------------------------|
