//|-----------------------------------------------------------------------------------------|
//|                                                                         TestPlusRed.mq4 |
//|                                                            Copyright © 2012, Dennis Lee |
//| Assert Test Procedure                                                                   |
//| Assert History                                                                          |
//| 1.00    This script performs unit test on the include file PlusRed_fifo.mqh.            |
//|-----------------------------------------------------------------------------------------|
#property copyright "Copyright © 2012, Dennis Lee"
#property link      ""
#property show_inputs

#include <PlusTest.mqh>
#include <PlusInit.mqh>
#include <PlusEasy.mqh>
#include <PlusGhost.mqh>
#include <PlusRed.mqh>
#include <PlusTurtle.mqh>

//|-----------------------------------------------------------------------------------------|
//|                           E X T E R N A L   V A R I A B L E S                           |
//|-----------------------------------------------------------------------------------------|

//|-----------------------------------------------------------------------------------------|
//|                           I N T E R N A L   V A R I A B L E S                           |
//|-----------------------------------------------------------------------------------------|
int      mgc1  = 81000;
int      mgc2  = 82000;

//|-----------------------------------------------------------------------------------------|
//|                            I N I T I A L I S A T I O N                                  |
//|-----------------------------------------------------------------------------------------|
int init()
{
   InitInit();
   EasyInit();
   GhostInit();
   RedInit(EasySL,mgc1,mgc2);
   TurtleInit();
//--- MUST be the last init line   
   TestInit("PlusRed");
}

//|-----------------------------------------------------------------------------------------|
//|                            D E - I N I T I A L I S A T I O N                            |
//|-----------------------------------------------------------------------------------------|
int deinit()
{
//--- MUST be the first line of deinit
   TestDeInit();
//--- Clean up data
   
}

//|-----------------------------------------------------------------------------------------|
//|                               M A I N   P R O C E D U R E                               |
//|-----------------------------------------------------------------------------------------|
int start()
{
//--- Prepare mock data for testing
//       (1)(1) Create a Long trade with NO SL and TP
   int ticket1_1 = GhostOrderSend( Symbol(), OP_BUY, 0.1, MarketInfo(Symbol(),MODE_ASK), 
                                   EasySlipPage, 0, 0, "", mgc1);

   Print("(1) RedOrderModifyBasket");
   TestThat( "(1)(1) Modify SL for ONE (1) Long trade", 
      ExpectTrueBln( RedOrderModifyBasket( mgc1, Symbol(), 50, 0, 0, EasyMaxAccountTrades) ) );
      
}

//|-----------------------------------------------------------------------------------------|
//|                        E N D   O F   C U S T O M   I N D I C A T O R                    |
//|-----------------------------------------------------------------------------------------|