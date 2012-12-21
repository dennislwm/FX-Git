//|-----------------------------------------------------------------------------------------|
//|                                                                          TestPlusTD.mq4 |
//|                                                            Copyright © 2012, Dennis Lee |
//| Assert Test Procedure                                                                   |
//| Assert History                                                                          |
//| 1.0.1    Additional test on the parameters DoNotBuyGreedy and DoNotSellGreedy.          |
//| 1.0.0    This script performs unit test on the include file PlusTD.mqh.                 |
//|-----------------------------------------------------------------------------------------|
#property copyright "Copyright © 2012, Dennis Lee"
#property link      ""
#property show_inputs

#include <PlusTest.mqh>
#include <PlusTD.mqh>

//|-----------------------------------------------------------------------------------------|
//|                           E X T E R N A L   V A R I A B L E S                           |
//|-----------------------------------------------------------------------------------------|

//|-----------------------------------------------------------------------------------------|
//|                           I N T E R N A L   V A R I A B L E S                           |
//|-----------------------------------------------------------------------------------------|

//|-----------------------------------------------------------------------------------------|
//|                            I N I T I A L I S A T I O N                                  |
//|-----------------------------------------------------------------------------------------|
int init()
{
   TDInit();
//--- MUST be the last init line   
   TestInit("PlusTD");
}

//|-----------------------------------------------------------------------------------------|
//|                            D E - I N I T I A L I S A T I O N                            |
//|-----------------------------------------------------------------------------------------|
int deinit()
{
//--- MUST be the first line of deinit
   TestDeInit();
//--- Clean up data
   TDDeInit();
}

//|-----------------------------------------------------------------------------------------|
//|                               M A I N   P R O C E D U R E                               |
//|-----------------------------------------------------------------------------------------|
int start()
{
//--- Prepare mock data for testing
//       (1)(1) Check that at least ONE (1) global name is correct
//       (1)(2) Check that ALL global vars exist
//       (1)(3) Check that at least ONE (1) global vars is missing
//       (2)(1) Assume ALL global vars are missing with AllowTrade TRUE, check Buy is allowed
//       (2)(2) Assume ALL global vars are missing with AllowTrade TRUE, check Sell is allowed
//       (2)(3) Assume ALL global vars are missing with AllowTrade FALSE, check Buy is NOT allowed
//       (2)(4) Assume ALL global vars are missing with AllowTrade FALSE, check Sell is NOT allowed
//       (3)(1) Assume ALL global vars exist with DoNotBuyUp1=Ok, and Up1=Brk, check Buy is allowed
//       (3)(2) Assume ALL global vars exist with DoNotBuyUp1=Ok, and Up1=Ok, check Buy is NOT allowed
//       (3)(3) Assume ALL global vars exist with DoNotSellUp1=Ok, and Up1=Brk, check Sell is allowed
//       (3)(4) Assume ALL global vars exist with DoNotSellUp1=Ok, and Up1=Ok, check Sell is NOT allowed
//       (4)(1) Assume DoNotBuyDn1=Brk, DoNotBuyDn2=Brk, and Dn1=Brk, Dn2=Brk, check Buy is NOT allowed
//       (4)(2) Assume DoNotBuyDn1=Brk, DoNotBuyDn2=Brk, and Dn1=Brk, Dn2=Ok, check Buy is NOT allowed
//       (4)(3) Assume DoNotBuyDn1=Brk, DoNotBuyDn2=Brk, and Dn1=Ok, Dn2=Brk, check Buy is NOT allowed
//       (4)(4) Assume DoNotBuyDn1=Brk, DoNotBuyDn2=Brk, and Dn1=Ok, Dn2=Ok, check Buy is allowed
//       (5)(1) Assume DoNotSellUp1=Brk, DoNotSellUp2=Brk, and Up1=Brk, Up2=Brk, check Sell is NOT allowed
//       (5)(2) Assume DoNotSellUp1=Brk, DoNotSellUp2=Brk, and Up1=Brk, Up2=Ok, check Sell is NOT allowed
//       (5)(3) Assume DoNotSellUp1=Brk, DoNotSellUp2=Brk, and Up1=Ok, Up2=Brk, check Sell is NOT allowed
//       (5)(4) Assume DoNotSellUp1=Brk, DoNotSellUp2=Brk, and Up1=Ok, Up2=Ok, check Sell is allowed
//       (6)(1) Assume DoNotBuyGreedy=true, DoNotBuyDn1=Brk, DoNotBuyDn2=Brk, and Dn1=Brk, Dn2=Brk, check Buy is NOT allowed
//       (6)(2) Assume DoNotBuyGreedy=true, DoNotBuyDn1=Brk, DoNotBuyDn2=Brk, and Dn1=Brk, Dn2=Ok, check Buy is allowed
//       (6)(3) Assume DoNotBuyGreedy=true, DoNotBuyDn1=Brk, DoNotBuyDn2=Brk, and Dn1=Ok, Dn2=Brk, check Buy is allowed
//       (6)(4) Assume DoNotBuyGreedy=true, DoNotBuyDn1=Brk, DoNotBuyDn2=Brk, and Dn1=Ok, Dn2=Ok, check Buy is allowed
//       (7)(1) Assume DoNotSellGreedy=true, DoNotSellUp1=Brk, DoNotSellUp2=Brk, and Up1=Brk, Up2=Brk, check Sell is NOT allowed
//       (7)(2) Assume DoNotSellGreedy=true, DoNotSellUp1=Brk, DoNotSellUp2=Brk, and Up1=Brk, Up2=Ok, check Sell is allowed
//       (7)(3) Assume DoNotSellGreedy=true, DoNotSellUp1=Brk, DoNotSellUp2=Brk, and Up1=Ok, Up2=Brk, check Sell is allowed
//       (7)(4) Assume DoNotSellGreedy=true, DoNotSellUp1=Brk, DoNotSellUp2=Brk, and Up1=Ok, Up2=Ok, check Sell is allowed

   int      tmpPeriod;
   string   tmpGUpStr;
   bool     tmpAllowTrade;
   int      tmpDoNotBuyUpLine;
   int      tmpDoNotBuy2UpLine;
   int      tmpDoNotBuyDnLine;
   int      tmpDoNotBuy2DnLine;
   int      tmpDoNotSellUpLine;
   int      tmpDoNotSell2UpLine;
   int      tmpDoNotSellDnLine;
   int      tmpDoNotSell2DnLine;
   bool     tmpDoNotBuyGreedy;
   bool     tmpDoNotSellGreedy;
   bool     tmpOkUpLine;
   bool     tmpOk2UpLine;
   bool     tmpOkDnLine;
   bool     tmpOk2DnLine;
   
   tmpGUpStr = StringConcatenate( Symbol(), "_", TDPeriod, "_IsOkUpLine" );
   TestThat( "(1)(1) Check that at least ONE (1) global name is correct", 
             ExpectEqualStr( tmpGUpStr, TDGlobalUpStr(1) ) );
   TestThat( "(1)(2) Check that ALL global vars exist", ExpectTrueBln( TDGlobalCheck() ) );
   {
   tmpPeriod = TDPeriod;
   TDPeriod=10;
   TestThat( "(1)(3) Check that at least ONE (1) global vars is missing", ExpectFalseBln( TDGlobalCheck() ) );
   tmpAllowTrade=TDAllowTradeOnError;
   TDAllowTradeOnError=true;
   TestThat( "(2)(1) Assume ALL global vars are missing with AllowTrade TRUE, check Buy is allowed",
             ExpectTrueBln( TDWave1Buy() ) );
   TestThat( "(2)(2) Assume ALL global vars are missing with AllowTrade TRUE, check Sell is allowed",
             ExpectTrueBln( TDWave1Sell() ) );
   TDAllowTradeOnError=false;
   TestThat( "(2)(3) Assume ALL global vars are missing with AllowTrade FALSE, check Buy is NOT allowed",
             ExpectFalseBln( TDWave1Buy() ) );
   TestThat( "(2)(4) Assume ALL global vars are missing with AllowTrade FALSE, check Sell is NOT allowed",
             ExpectFalseBln( TDWave1Sell() ) );
   TDAllowTradeOnError=tmpAllowTrade;
   TDPeriod=tmpPeriod;
   }
   {
   tmpDoNotBuyUpLine    =TDDoNotBuyUpLine;
   tmpDoNotBuy2UpLine   =TDDoNotBuy2UpLine;
   tmpDoNotBuyDnLine    =TDDoNotBuyDnLine;
   tmpDoNotBuy2DnLine   =TDDoNotBuy2DnLine;
   tmpDoNotSellUpLine   =TDDoNotSellUpLine;
   tmpDoNotSell2UpLine  =TDDoNotSell2UpLine;
   tmpDoNotSellDnLine   =TDDoNotSellDnLine;
   tmpDoNotSell2DnLine  =TDDoNotSell2DnLine;
   TDDoNotBuyUpLine=1;
   TDDoNotBuy2UpLine=0;
   TDDoNotBuyDnLine=0;
   TDDoNotBuy2DnLine=0;
   TDDoNotSellUpLine=1;
   TDDoNotSell2UpLine=0;
   TDDoNotSellDnLine=0;
   TDDoNotSell2DnLine=0;
   tmpOkUpLine=TDGetUpBln(1);
   GlobalVariableSet( TDGlobalUpStr(1), false );
   TestThat( "(3)(1) Assume ALL global vars exist with DoNotBuyUp1=Ok, and Up1=Brk, check Buy is allowed",
             ExpectTrueBln( TDWave1Buy() ) );
   GlobalVariableSet( TDGlobalUpStr(1), true );
   TestThat( "(3)(2) Assume ALL global vars exist with DoNotBuyUp1=Ok, and Up1=Ok, check Buy is NOT allowed",
             ExpectFalseBln( TDWave1Buy() ) );
   GlobalVariableSet( TDGlobalUpStr(1), false );
   TestThat( "(3)(3) Assume ALL global vars exist with DoNotSellUp1=Ok, and Up1=Brk, check Sell is allowed",
             ExpectTrueBln( TDWave1Sell() ) );
   GlobalVariableSet( TDGlobalUpStr(1), true );
   TestThat( "(3)(4) Assume ALL global vars exist with DoNotSellUp1=Ok, and Up1=Ok, check Sell is NOT allowed",
             ExpectFalseBln( TDWave1Sell() ) );
             
   GlobalVariableSet( TDGlobalUpStr(1), tmpOkUpLine );
   TDDoNotBuyUpLine     =tmpDoNotBuyUpLine;
   TDDoNotBuy2UpLine    =tmpDoNotBuy2UpLine;
   TDDoNotBuyDnLine     =tmpDoNotBuyDnLine;
   TDDoNotBuy2DnLine    =tmpDoNotBuy2DnLine;
   TDDoNotSellUpLine    =tmpDoNotSellUpLine;
   TDDoNotSell2UpLine   =tmpDoNotSell2UpLine;
   TDDoNotSellDnLine    =tmpDoNotSellDnLine;
   TDDoNotSell2DnLine   =tmpDoNotSell2DnLine;
   }
//       (4)(1) Assume DoNotBuyDn1=Brk, DoNotBuyDn2=Brk, and Dn1=Brk, Dn2=Brk, check Buy is NOT allowed
//       (4)(2) Assume DoNotBuyDn1=Brk, DoNotBuyDn2=Brk, and Dn1=Brk, Dn2=Ok, check Buy is NOT allowed
//       (4)(3) Assume DoNotBuyDn1=Brk, DoNotBuyDn2=Brk, and Dn1=Ok, Dn2=Brk, check Buy is NOT allowed
//       (4)(4) Assume DoNotBuyDn1=Brk, DoNotBuyDn2=Brk, and Dn1=Ok, Dn2=Ok, check Buy is allowed
   {
   tmpDoNotBuyUpLine    =TDDoNotBuyUpLine;
   tmpDoNotBuy2UpLine   =TDDoNotBuy2UpLine;
   tmpDoNotBuyDnLine    =TDDoNotBuyDnLine;
   tmpDoNotBuy2DnLine   =TDDoNotBuy2DnLine;
   TDDoNotBuyUpLine=0;
   TDDoNotBuy2UpLine=0;
   TDDoNotBuyDnLine=2;
   TDDoNotBuy2DnLine=2;
   tmpOkDnLine=TDGetDnBln(1);
   tmpOk2DnLine=TDGetDnBln(2);
   GlobalVariableSet( TDGlobalDnStr(1), false );
   GlobalVariableSet( TDGlobalDnStr(2), false );
   TestThat( "(4)(1) Assume DoNotBuyDn1=Brk, DoNotBuyDn2=Brk, and Dn1=Brk, Dn2=Brk, check Buy is NOT allowed",
             ExpectFalseBln( TDWave1Buy() ) );
   GlobalVariableSet( TDGlobalDnStr(1), false );
   GlobalVariableSet( TDGlobalDnStr(2), true );
   TestThat( "(4)(2) Assume DoNotBuyDn1=Brk, DoNotBuyDn2=Brk, and Dn1=Brk, Dn2=Ok, check Buy is NOT allowed",
             ExpectFalseBln( TDWave1Buy() ) );
   GlobalVariableSet( TDGlobalDnStr(1), true );
   GlobalVariableSet( TDGlobalDnStr(2), false );
   //Print( TestDebugBln( "TDGetDnBln(1)", TDGetDnBln(1) ) );
   //Print( TestDebugBln( "TDGetDnBln(2)", TDGetDnBln(2) ) );
   TestThat( "(4)(3) Assume DoNotBuyDn1=Brk, DoNotBuyDn2=Brk, and Dn1=Ok, Dn2=Brk, check Buy is NOT allowed",
             ExpectFalseBln( TDWave1Buy() ) );
   //Print( TestDebugBln( "TDGetDnBln(1)", TDGetDnBln(1) ) );
   //Print( TestDebugBln( "TDGetDnBln(2)", TDGetDnBln(2) ) );
   //Print( TestDebugBln( "TDIsOkWave1Buy", TDIsOkWave1Buy( TDGetUpBln(1),TDGetUpBln(2),TDGetDnBln(1),TDGetDnBln(2)) ) );
   GlobalVariableSet( TDGlobalDnStr(1), true );
   GlobalVariableSet( TDGlobalDnStr(2), true );
   TestThat( "(4)(4) Assume DoNotBuyDn1=Brk, DoNotBuyDn2=Brk, and Dn1=Ok, Dn2=Ok, check Buy is allowed",
             ExpectTrueBln( TDWave1Buy() ) );
   GlobalVariableSet( TDGlobalDnStr(1), tmpOkDnLine );
   GlobalVariableSet( TDGlobalDnStr(2), tmpOk2DnLine );
   TDDoNotBuyUpLine     =tmpDoNotBuyUpLine;
   TDDoNotBuy2UpLine    =tmpDoNotBuy2UpLine;
   TDDoNotBuyDnLine     =tmpDoNotBuyDnLine;
   TDDoNotBuy2DnLine    =tmpDoNotBuy2DnLine;
   }
//       (5)(1) Assume DoNotSellUp1=Brk, DoNotSellUp2=Brk, and Up1=Brk, Up2=Brk, check Sell is NOT allowed
//       (5)(2) Assume DoNotSellUp1=Brk, DoNotSellUp2=Brk, and Up1=Brk, Up2=Ok, check Sell is NOT allowed
//       (5)(3) Assume DoNotSellUp1=Brk, DoNotSellUp2=Brk, and Up1=Ok, Up2=Brk, check Sell is NOT allowed
//       (5)(4) Assume DoNotSellUp1=Brk, DoNotSellUp2=Brk, and Up1=Ok, Up2=Ok, check Sell is allowed
   {
   tmpDoNotSellUpLine    =TDDoNotSellUpLine;
   tmpDoNotSell2UpLine   =TDDoNotSell2UpLine;
   tmpDoNotSellDnLine    =TDDoNotSellDnLine;
   tmpDoNotSell2DnLine   =TDDoNotSell2DnLine;
   TDDoNotSellUpLine=2;
   TDDoNotSell2UpLine=2;
   TDDoNotSellDnLine=0;
   TDDoNotSell2DnLine=0;
   tmpOkUpLine=TDGetUpBln(1);
   tmpOk2UpLine=TDGetUpBln(2);
   
   GlobalVariableSet( TDGlobalUpStr(1), false );
   GlobalVariableSet( TDGlobalUpStr(2), false );
   TestThat( "(5)(1) Assume DoNotSellUp1=Brk, DoNotSellUp2=Brk, and Up1=Brk, Up2=Brk, check Sell is NOT allowed",
             ExpectFalseBln( TDWave1Sell() ) );
   GlobalVariableSet( TDGlobalUpStr(1), false );
   GlobalVariableSet( TDGlobalUpStr(2), true );
   TestThat( "(5)(2) Assume DoNotSellUp1=Brk, DoNotSellUp2=Brk, and Up1=Brk, Up2=Ok, check Sell is NOT allowed",
             ExpectFalseBln( TDWave1Sell() ) );
   GlobalVariableSet( TDGlobalUpStr(1), true );
   GlobalVariableSet( TDGlobalUpStr(2), false );
   TestThat( "(5)(3) Assume DoNotSellUp1=Brk, DoNotSellUp2=Brk, and Up1=Ok, Up2=Brk, check Sell is NOT allowed",
             ExpectFalseBln( TDWave1Sell() ) );
   GlobalVariableSet( TDGlobalUpStr(1), true );
   GlobalVariableSet( TDGlobalUpStr(2), true );
   TestThat( "(5)(4) Assume DoNotSellUp1=Brk, DoNotSellUp2=Brk, and Up1=Ok, Up2=Ok, check Sell is allowed",
             ExpectTrueBln( TDWave1Sell() ) );
             
   GlobalVariableSet( TDGlobalUpStr(1), tmpOkUpLine );
   GlobalVariableSet( TDGlobalUpStr(2), tmpOk2UpLine );
   TDDoNotSellUpLine     =tmpDoNotSellUpLine;
   TDDoNotSell2UpLine    =tmpDoNotSell2UpLine;
   TDDoNotSellDnLine     =tmpDoNotSellDnLine;
   TDDoNotSell2DnLine    =tmpDoNotSell2DnLine;
   }
//       (6)(1) Assume DoNotBuyGreedy=true, DoNotBuyDn1=Brk, DoNotBuyDn2=Brk, and Dn1=Brk, Dn2=Brk, check Buy is NOT allowed
//       (6)(2) Assume DoNotBuyGreedy=true, DoNotBuyDn1=Brk, DoNotBuyDn2=Brk, and Dn1=Brk, Dn2=Ok, check Buy is allowed
//       (6)(3) Assume DoNotBuyGreedy=true, DoNotBuyDn1=Brk, DoNotBuyDn2=Brk, and Dn1=Ok, Dn2=Brk, check Buy is allowed
//       (6)(4) Assume DoNotBuyGreedy=true, DoNotBuyDn1=Brk, DoNotBuyDn2=Brk, and Dn1=Ok, Dn2=Ok, check Buy is allowed
   {
//--- Save user environment
   tmpDoNotBuyUpLine    =TDDoNotBuyUpLine;
   tmpDoNotBuy2UpLine   =TDDoNotBuy2UpLine;
   tmpDoNotBuyDnLine    =TDDoNotBuyDnLine;
   tmpDoNotBuy2DnLine   =TDDoNotBuy2DnLine;
   tmpDoNotBuyGreedy    =TDDoNotBuyGreedy;

//--- Set test environment
   TDDoNotBuyUpLine=0;
   TDDoNotBuy2UpLine=0;
   TDDoNotBuyDnLine=2;
   TDDoNotBuy2DnLine=2;
   TDDoNotBuyGreedy=true;
   tmpOkDnLine=TDGetDnBln(1);
   tmpOk2DnLine=TDGetDnBln(2);
   GlobalVariableSet( TDGlobalDnStr(1), false );
   GlobalVariableSet( TDGlobalDnStr(2), false );
   TestThat( "(6)(1) Assume DoNotBuyGreedy=true, DoNotBuyDn1=Brk, DoNotBuyDn2=Brk, and Dn1=Brk, Dn2=Brk, check Buy is NOT allowed",
             ExpectFalseBln( TDWave1Buy() ) );
   GlobalVariableSet( TDGlobalDnStr(1), false );
   GlobalVariableSet( TDGlobalDnStr(2), true );
   TestThat( "(6)(2) Assume DoNotBuyGreedy=true, DoNotBuyDn1=Brk, DoNotBuyDn2=Brk, and Dn1=Brk, Dn2=Ok, check Buy is allowed",
             ExpectTrueBln( TDWave1Buy() ) );
   GlobalVariableSet( TDGlobalDnStr(1), true );
   GlobalVariableSet( TDGlobalDnStr(2), false );
   TestThat( "(6)(3) Assume DoNotBuyGreedy=true, DoNotBuyDn1=Brk, DoNotBuyDn2=Brk, and Dn1=Ok, Dn2=Brk, check Buy is allowed",
             ExpectTrueBln( TDWave1Buy() ) );
   GlobalVariableSet( TDGlobalDnStr(1), true );
   GlobalVariableSet( TDGlobalDnStr(2), true );
   TestThat( "(6)(4) Assume DoNotBuyGreedy=true, DoNotBuyDn1=Brk, DoNotBuyDn2=Brk, and Dn1=Ok, Dn2=Ok, check Buy is allowed",
             ExpectTrueBln( TDWave1Buy() ) );
             
//--- Restore user environment
   GlobalVariableSet( TDGlobalDnStr(1), tmpOkDnLine );
   GlobalVariableSet( TDGlobalDnStr(2), tmpOk2DnLine );
   TDDoNotBuyUpLine     =tmpDoNotBuyUpLine;
   TDDoNotBuy2UpLine    =tmpDoNotBuy2UpLine;
   TDDoNotBuyDnLine     =tmpDoNotBuyDnLine;
   TDDoNotBuy2DnLine    =tmpDoNotBuy2DnLine;
   TDDoNotBuyGreedy     =tmpDoNotBuyGreedy;
   }
//       (7)(1) Assume DoNotSellGreedy=true, DoNotSellUp1=Brk, DoNotSellUp2=Brk, and Up1=Brk, Up2=Brk, check Sell is NOT allowed
//       (7)(2) Assume DoNotSellGreedy=true, DoNotSellUp1=Brk, DoNotSellUp2=Brk, and Up1=Brk, Up2=Ok, check Sell is allowed
//       (7)(3) Assume DoNotSellGreedy=true, DoNotSellUp1=Brk, DoNotSellUp2=Brk, and Up1=Ok, Up2=Brk, check Sell is allowed
//       (7)(4) Assume DoNotSellGreedy=true, DoNotSellUp1=Brk, DoNotSellUp2=Brk, and Up1=Ok, Up2=Ok, check Sell is allowed
   {
//--- Save user environment
   tmpDoNotSellUpLine    =TDDoNotSellUpLine;
   tmpDoNotSell2UpLine   =TDDoNotSell2UpLine;
   tmpDoNotSellDnLine    =TDDoNotSellDnLine;
   tmpDoNotSell2DnLine   =TDDoNotSell2DnLine;
   tmpDoNotSellGreedy    =TDDoNotSellGreedy;
   
//--- Set test environment
   TDDoNotSellUpLine=2;
   TDDoNotSell2UpLine=2;
   TDDoNotSellDnLine=0;
   TDDoNotSell2DnLine=0;
   TDDoNotSellGreedy=true;
   tmpOkUpLine=TDGetUpBln(1);
   tmpOk2UpLine=TDGetUpBln(2);
   
   GlobalVariableSet( TDGlobalUpStr(1), false );
   GlobalVariableSet( TDGlobalUpStr(2), false );
   TestThat( "(7)(1) Assume DoNotSellGreedy=true, DoNotSellUp1=Brk, DoNotSellUp2=Brk, and Up1=Brk, Up2=Brk, check Sell is NOT allowed",
             ExpectFalseBln( TDWave1Sell() ) );
   GlobalVariableSet( TDGlobalUpStr(1), false );
   GlobalVariableSet( TDGlobalUpStr(2), true );
   TestThat( "(7)(2) Assume DoNotSellGreedy=true, DoNotSellUp1=Brk, DoNotSellUp2=Brk, and Up1=Brk, Up2=Ok, check Sell is allowed",
             ExpectTrueBln( TDWave1Sell() ) );
   GlobalVariableSet( TDGlobalUpStr(1), true );
   GlobalVariableSet( TDGlobalUpStr(2), false );
   TestThat( "(7)(3) Assume DoNotSellGreedy=true, DoNotSellUp1=Brk, DoNotSellUp2=Brk, and Up1=Ok, Up2=Brk, check Sell is allowed",
             ExpectTrueBln( TDWave1Sell() ) );
   GlobalVariableSet( TDGlobalUpStr(1), true );
   GlobalVariableSet( TDGlobalUpStr(2), true );
   TestThat( "(7)(4) Assume DoNotSellGreedy=true, DoNotSellUp1=Brk, DoNotSellUp2=Brk, and Up1=Ok, Up2=Ok, check Sell is allowed",
             ExpectTrueBln( TDWave1Sell() ) );
             
//--- Restore user environment
   GlobalVariableSet( TDGlobalUpStr(1), tmpOkUpLine );
   GlobalVariableSet( TDGlobalUpStr(2), tmpOk2UpLine );
   TDDoNotSellUpLine     =tmpDoNotSellUpLine;
   TDDoNotSell2UpLine    =tmpDoNotSell2UpLine;
   TDDoNotSellDnLine     =tmpDoNotSellDnLine;
   TDDoNotSell2DnLine    =tmpDoNotSell2DnLine;
   TDDoNotSellGreedy     =tmpDoNotSellGreedy;
   }
}

//|-----------------------------------------------------------------------------------------|
//|                        E N D   O F   C U S T O M   I N D I C A T O R                    |
//|-----------------------------------------------------------------------------------------|