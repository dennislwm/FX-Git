//|-----------------------------------------------------------------------------------------|
//|                                                                           PlusSwiss.mqh |
//|                                                            Copyright © 2011, Dennis Lee |
//| Assert History                                                                          |
//| 1.23    Replaced EasyProfitsMagic() with EasyProfitsBasket().                           |
//| 1.22    Fixed bug in reset status.                                                      |
//| 1.21    Fixed bug in Trade Decision Sell Zone for Target2.                              |
//| 1.20    Added PlusLinex.mqh for take profit lines.                                      |
//| 1.10    Added SwissParabolicSarManager().                                               |
//|         Added SwissInit().                                                              |
//|         Added SwissManager().                                                           |
//| 1.00    Copied from decompiled Swiss Army EA v1.51.                                     |
//|             breakEvenManager()  --> SwissEvenManager()                                  |
//|             trailingStopManager()   --> SwissTrailingStopManager()                      |
//|-----------------------------------------------------------------------------------------|
#property   copyright "Copyright © 2011, Dennis Lee"

//|-----------------------------------------------------------------------------------------|
//|                 P L U S E A S Y   E X T E R N A L   V A R I A B L E S                   |
//|-----------------------------------------------------------------------------------------|
//---- Assert Swiss externs
extern bool SwissUseParabolic=false;
extern bool SwissUseTrailing=false;
extern double SwissEvenAt=14;
extern double SwissEvenSlide=5;
extern double SwissTrailingStop=9;
extern bool SwissOnlyTakeProfits=true;
//---- Assert Added PlusLinex.mqh.
extern string SwissTarget1="target1";
extern bool SwissTarget1NoMove=false;
extern string SwissTarget2="target2";
extern bool SwissTarget2NoMove=false;
extern double SwissPipLimit=1;
extern double SwissPipWide=3;
extern double SwissPipMove=2;
extern int SwissDebug=0;

//|-----------------------------------------------------------------------------------------|
//|                           I N T E R N A L   V A R I A B L E S                           |
//|-----------------------------------------------------------------------------------------|
//---- Assert Added PlusLinex.mqh.
double   I_TargetLineLevel, I_TargetHLimit, I_TargetLLimit, I_TargetHLimit1, I_TargetLLimit1;
double   II_TargetLineLevel, II_TargetHLimit, II_TargetLLimit, II_TargetHLimit1, II_TargetLLimit1;
//-- Assert new concept trailing trendline
//       0 - not crossed yet; 1 - crossed once; 2 - crossed second
double   I_TargetMLimit, II_TargetMLimit;
double   I_TargetLineLevelStart, II_TargetLineLevelStart;
int      I_TargetStatus, II_TargetStatus;
int      I_TargetMagic, II_TargetMagic;
string SwissName="PlusSwiss";
string SwissVer="1.23";

//|-----------------------------------------------------------------------------------------|
//|                             I N I T I A L I Z A T I O N                                 |
//|-----------------------------------------------------------------------------------------|
void SwissInit(int mgctarget1, int mgctarget2)
{
//--- Assert Added PlusLinex.mqh
   I_TargetMagic=mgctarget1;
   II_TargetMagic=mgctarget2;
   
//--- Use either Parabolic or Trailing Stop, but not both.
   if (SwissUseParabolic && SwissUseTrailing)
   {
      SwissUseParabolic=false;
      Alert("User has to set either Parabolic or Trailing Stop to True (but not both). SwissUseParabolic has been set to False.");
   }
}

//|-----------------------------------------------------------------------------------------|
//|                              M A I N   P R O C E D U R E                                |
//|-----------------------------------------------------------------------------------------|
void SwissManager(int mgc, string sym, double pt) {
   if (SwissUseTrailing) {
      SwissEvenManager(mgc,sym,SwissEvenAt,SwissEvenSlide,pt);
      SwissTrailingStopManager(mgc,sym,SwissTrailingStop,SwissOnlyTakeProfits,pt);
   }
   if (SwissUseParabolic) {
      SwissParabolicSarManager(mgc,sym);
   }
}

//|-----------------------------------------------------------------------------------------|
//|                     P A R A B O L I C   S A R   M A N A G E R                           |
//|-----------------------------------------------------------------------------------------|
void SwissParabolicSarManager(int mgc, string sym) {
   double pricebid;
   double priceask;
   double pricestop=iSAR(sym,0,0.02,0.2,0);
   
   for (int i = 0; i < OrdersTotal(); i++) {
      OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
      if (OrderMagicNumber() == mgc && OrderSymbol() == sym) {
         pricebid = MarketInfo(sym, MODE_BID);
         priceask = MarketInfo(sym, MODE_ASK);
         if (OrderType() == OP_BUY) {
         //--- pricestop has to be above current stop and below open price.
            if (OrderStopLoss() >= pricestop) continue;
            if (OrderOpenPrice() <= pricestop) continue;
            
            OrderModify(OrderTicket(), OrderOpenPrice(), pricestop, OrderTakeProfit(), 0, Green);
            if (SwissDebug>=1) Print(SwissName," ",SwissVer,": ",mgc," ",Symbol(),": ",OrderTicket()," parabolic stop at ",DoubleToStr(pricestop,5));
            
            continue;            
         }
         if (OrderType() == OP_SELL) {
         //--- pricestop has to be below current stop and above open price.
            if (OrderStopLoss() > 0.0 && OrderStopLoss() <= pricestop) continue;
            if (OrderOpenPrice() >= pricestop) continue;
            
            OrderModify(OrderTicket(), OrderOpenPrice(), pricestop, OrderTakeProfit(), 0, Red);
            if (SwissDebug>=1) Print(SwissName," ",SwissVer,": ",mgc," ",Symbol(),": ",OrderTicket()," parabolic stop at ",DoubleToStr(pricestop,5));
         }
      }
   }
}

//|-----------------------------------------------------------------------------------------|
//|                           B R E A K E V E N   M A N A G E R                             |
//|-----------------------------------------------------------------------------------------|
void SwissEvenManager(int mgc, string sym, int evenat, int evenslide, double pt) {
   double pricebid;
   double priceask;
   for (int i = 0; i < OrdersTotal(); i++) {
      OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
      if (evenat > 0 && OrderMagicNumber() == mgc && OrderSymbol() == sym) {
         pricebid = MarketInfo(OrderSymbol(), MODE_BID);
         priceask = MarketInfo(OrderSymbol(), MODE_ASK);
         if (OrderType() == OP_BUY) {
            if (pricebid - OrderOpenPrice() < pt * evenat) continue;
            if (OrderStopLoss() >= OrderOpenPrice() + evenslide * pt) continue;
            
            OrderModify(OrderTicket(), OrderOpenPrice(), OrderOpenPrice() + evenslide * pt, OrderTakeProfit(), 0, Green);
            if (SwissDebug>=1) Print(SwissName," ",SwissVer,": ",mgc," ", Symbol(),": ",OrderTicket()," EvenAt ",DoubleToStr(OrderOpenPrice()+evenslide*pt,5));
            
            continue;
         }
         if (OrderType() == OP_SELL) {
            if (OrderOpenPrice() - priceask >= pt * evenat)
               if (OrderStopLoss() > OrderOpenPrice() - evenslide * pt || OrderStopLoss() == 0.0) 
               {
                  OrderModify(OrderTicket(), OrderOpenPrice(), OrderOpenPrice() - evenslide * pt, OrderTakeProfit(), 0, Red);
                  if (SwissDebug>=1) Print(SwissName," ",SwissVer,": ",mgc," ", Symbol(),": ",OrderTicket()," BreakEven at ",DoubleToStr(OrderOpenPrice()-evenslide*pt,5));
               }
         }
      }
   }
}

//|-----------------------------------------------------------------------------------------|
//|                        T R A I L I N G   S T O P   M A N A G E R                        |
//|-----------------------------------------------------------------------------------------|
void SwissTrailingStopManager(int mgc, string sym, int tstop, bool tprofitsonly, double pt) {
   double pricebid;
   double priceask;
   for (int i = 0; i < OrdersTotal(); i++) {
      OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
      if (tstop > 0 && OrderMagicNumber() == mgc && OrderSymbol() == sym) {
         pricebid = MarketInfo(OrderSymbol(), MODE_BID);
         priceask = MarketInfo(OrderSymbol(), MODE_ASK);
         if (OrderType() == OP_BUY) {
            if (!(pricebid - OrderOpenPrice() > pt * tstop || tprofitsonly == 0)) continue;
            if (OrderStopLoss() >= pricebid - pt * tstop) continue;

            OrderModify(OrderTicket(), OrderOpenPrice(), pricebid - pt * tstop, OrderTakeProfit(), 0, Green);
            if (SwissDebug>=1) Print(SwissName," ",SwissVer,": ",mgc," ", Symbol(),": ",OrderTicket()," TrailingStop at ",DoubleToStr(pricebid-pt*tstop,5));

            continue;
         }
         if (OrderType() == OP_SELL) {
            if (OrderOpenPrice() - priceask > pt * tstop || tprofitsonly == 0)
               if (OrderStopLoss() > priceask + pt * tstop || OrderStopLoss() == 0.0) 
               {
                  OrderModify(OrderTicket(), OrderOpenPrice(), priceask + pt * tstop, OrderTakeProfit(), 0, Red);
                  if (SwissDebug>=1) Print(SwissName," ",SwissVer,": ",mgc," ", Symbol(),": ",OrderTicket()," TrailingStop at ",DoubleToStr(pricebid+pt*tstop,5));
               }
         }
      }
   }
}
//|-----------------------------------------------------------------------------------------|
//|                        S W I S S   L I N E X   P R O C E D U R E                        |
//|-----------------------------------------------------------------------------------------|
int SwissTargetLinex(double Pts)
{
   // Check for Trendline and Determine the Limits
   // ============================================
   
   if (ObjectFind(SwissTarget1)<0) 
   {
      I_TargetLineLevel = -1;
      I_TargetStatus = 0;
   }
   else
   {
      I_TargetLineLevel = ObjectGetValueByShift(SwissTarget1,0);
      if (""==ObjectDescription(SwissTarget1)) ObjectSetText(SwissTarget1, SwissTarget1, 10, "Arial");
   }
   I_TargetHLimit=0; I_TargetLLimit=0;
   if (I_TargetLineLevel>0)
   {
//-- Assert new concept moving trendline - Stage 1 of 5: Record price of original line.
      if (I_TargetStatus==0 && !SwissTarget1NoMove) I_TargetLineLevelStart=I_TargetLineLevel;
//-- Assert new concept moving trendline - Stage 4 of 5: Move trendline to narrow the gap with closing price.
      if (I_TargetStatus==1 && !SwissTarget1NoMove)
      {
         double I_LinePrice1=ObjectGet(SwissTarget1,OBJPROP_PRICE1);
         double I_LinePrice2=ObjectGet(SwissTarget1,OBJPROP_PRICE2);
         if (LinexOpenLast(I_TargetMagic)==OP_BUY)
         {
            I_TargetMLimit=I_TargetLineLevel+(SwissPipLimit+SwissPipMove)*Pts;
            if (Close[0]>I_TargetMLimit)
            {
               ObjectSet(SwissTarget1,OBJPROP_PRICE1,I_LinePrice1+(Close[0]-I_TargetMLimit));
               ObjectSet(SwissTarget1,OBJPROP_PRICE2,I_LinePrice2+(Close[0]-I_TargetMLimit));
               if (1==SwissDebug) Print("PlusSwiss: Target1 BUY Close[0]=",DoubleToStr(Close[0],5),">I_TargetMLimit=",DoubleToStr(I_TargetMLimit,5)
                ," I_LinePrice1=",DoubleToStr(I_LinePrice1,5)," I_LinePrice2=",DoubleToStr(I_LinePrice2,5)," Delta=",DoubleToStr(Close[0]-I_TargetMLimit,5));
            }
         }
         if (LinexOpenLast(I_TargetMagic)==OP_SELL)
         {
            I_TargetMLimit=I_TargetLineLevel-(SwissPipLimit+SwissPipMove)*Pts;
            if (Close[0]<I_TargetMLimit)
            {
               ObjectSet(SwissTarget1,OBJPROP_PRICE1,I_LinePrice1-(I_TargetMLimit-Close[0]));
               ObjectSet(SwissTarget1,OBJPROP_PRICE2,I_LinePrice2-(I_TargetMLimit-Close[0]));
               if (1==SwissDebug) Print("PlusSwiss: Target1 SELL Close[0]=",DoubleToStr(Close[0],5),"<I_TargetMLimit=",DoubleToStr(I_TargetMLimit,5),
                " I_LinePrice1=",DoubleToStr(I_LinePrice1,5)," I_LinePrice2=",DoubleToStr(I_LinePrice2,5)," Delta=",DoubleToStr(I_TargetMLimit-Close[0],5));
            }
         }
      }   
      I_TargetHLimit  = I_TargetLineLevel + (SwissPipLimit*Pts);
      I_TargetHLimit1 = I_TargetHLimit    + (SwissPipWide *Pts);
      I_TargetLLimit  = I_TargetLineLevel - (SwissPipLimit*Pts);
      I_TargetLLimit1 = I_TargetLLimit    - (SwissPipWide *Pts);
   }
   if (ObjectFind(SwissTarget2)<0)   
   {
      II_TargetLineLevel = -1;
      II_TargetStatus = 0;
   }
   else
   {
      II_TargetLineLevel = ObjectGetValueByShift(SwissTarget2,0);
      if (""==ObjectDescription(SwissTarget2)) ObjectSetText(SwissTarget2, SwissTarget2, 10, "Arial");
   }
   II_TargetHLimit=0; II_TargetLLimit=0;
   if (II_TargetLineLevel>0)
   {
//-- Assert new concept moving trendline - Stage 1 of 5: Record price of original line.
      if (II_TargetStatus==0 && !SwissTarget2NoMove) II_TargetLineLevelStart=II_TargetLineLevel;
//-- Assert new concept moving trendline - Stage 4 of 5: Move trendline to narrow the gap with closing price.
      if (II_TargetStatus==1 && !SwissTarget2NoMove)
      {
         double II_LinePrice1=ObjectGet(SwissTarget2,OBJPROP_PRICE1);
         double II_LinePrice2=ObjectGet(SwissTarget2,OBJPROP_PRICE2);
         if (LinexOpenLast(II_TargetMagic)==OP_BUY)
         {
            II_TargetMLimit=II_TargetLineLevel+(SwissPipLimit+SwissPipMove)*Pts;
            if (Close[0]>II_TargetMLimit)
            {
               ObjectSet(SwissTarget2,OBJPROP_PRICE1,II_LinePrice1+(Close[0]-II_TargetMLimit));
               ObjectSet(SwissTarget2,OBJPROP_PRICE2,II_LinePrice2+(Close[0]-II_TargetMLimit));
               if (1==SwissDebug) Print("PlusSwiss: Target2 BUY Close[0]=",DoubleToStr(Close[0],5),">II_TargetMLimit=",DoubleToStr(II_TargetMLimit,5)
                ," II_LinePrice1=",DoubleToStr(II_LinePrice1,5)," II_LinePrice2=",DoubleToStr(II_LinePrice2,5)," Delta=",DoubleToStr(Close[0]-II_TargetMLimit,5));
            }
         }
         if (LinexOpenLast(II_TargetMagic)==OP_SELL)
         {
            II_TargetMLimit=II_TargetLineLevel-(SwissPipLimit+SwissPipMove)*Pts;
            if (Close[0]<II_TargetMLimit)
            {
               ObjectSet(SwissTarget2,OBJPROP_PRICE1,II_LinePrice1-(II_TargetMLimit-Close[0]));
               ObjectSet(SwissTarget2,OBJPROP_PRICE2,II_LinePrice2-(II_TargetMLimit-Close[0]));
               if (1==SwissDebug) Print("PlusSwiss: Target2 SELL Close[0]=",DoubleToStr(Close[0],5),">II_TargetMLimit=",DoubleToStr(II_TargetMLimit,5)
                ," II_LinePrice1=",DoubleToStr(II_LinePrice1,5)," II_LinePrice2=",DoubleToStr(II_LinePrice2,5)," Delta=",DoubleToStr(II_TargetMLimit-Close[0],5));
            }
         }
      }
      II_TargetHLimit  = II_TargetLineLevel + (SwissPipLimit*Pts);
      II_TargetHLimit1 = II_TargetHLimit    + (SwissPipWide *Pts);
      II_TargetLLimit  = II_TargetLineLevel - (SwissPipLimit*Pts);
      II_TargetLLimit1 = II_TargetLLimit    - (SwissPipWide *Pts);
   }

   // Trade Decision
   // ==============
   if (I_TargetLineLevel>0)
   {
      // Target Buy Zone
      // ===============
      if (Close[0]>I_TargetHLimit && Close[0]<I_TargetHLimit1)
      {
      //-- Assert new concept moving trendline - Stage 2 of 5: Set Status from 0 (or 2) to 1.      
         if (LinexOpenLast(I_TargetMagic)==OP_BUY && I_TargetStatus!=1 && !SwissTarget1NoMove) I_TargetStatus=1;
      //-- Assert Added option to turn off buy or sell
      //-- Assert new concept moving trendline - Stage 5 of 5: Open pending order and no need to reset Status.
         if (LinexOpenLast(I_TargetMagic)==OP_SELL)
         {
            if (I_TargetStatus!=1 && !SwissTarget1NoMove)   {}   // do nothing
            else
            //--  Assert Open orders are removed
               if (LinexOpenOrd(I_TargetMagic)==0)   return(0);
               else
                  if (LinexOpenLast(I_TargetMagic)==OP_SELL)
                  {  
                     if (SwissOnlyTakeProfits && EasyProfitsBasket(I_TargetMagic,Symbol())<=0)  {}  // do nothing
                     else
                     {
                        LinexCloseOrders(I_TargetMagic);
                        if (1==SwissDebug) Print("PlusSwiss: Target1 CLOSE SELL Close[0]=",DoubleToStr(Close[0],5),">I_TargetMLimit=",DoubleToStr(I_TargetMLimit,5)
                            ," I_LinePrice1=",DoubleToStr(I_LinePrice1,5)," I_LinePrice2=",DoubleToStr(I_LinePrice2,5)," Delta=",DoubleToStr(Close[0]-I_TargetMLimit,5));
                        Sleep(300);
                    //--  Assert Open orders are removed
                        return(-1);
                     }
                  }
         }
      }
      // Sell Zone
      // =========
   //--  Assert Added option to turn off buy or sell
      if (Close[0]<I_TargetLLimit && Close[0]>I_TargetLLimit1)
      {
      //-- Assert new concept moving trendline - Stage 2 of 5: Set Status from 0 (or 2) to 1.
         if (LinexOpenLast(I_TargetMagic)==OP_SELL && I_TargetStatus!=1 && !SwissTarget1NoMove) I_TargetStatus=1;
      //-- Assert Added option to turn off buy or sell
      //-- Assert new concept moving trendline - Stage 5 of 5: Open pending order.
         if (LinexOpenLast(I_TargetMagic)==OP_BUY)
         {
            if (I_TargetStatus!=1 && !SwissTarget1NoMove)   {}   // do nothing
            else
            //--  Assert Open orders are removed
               if (LinexOpenOrd(I_TargetMagic)==0)   return(0);
               else
                  if (LinexOpenLast(I_TargetMagic)==OP_BUY)
                  {   
                     if (SwissOnlyTakeProfits && EasyProfitsBasket(I_TargetMagic,Symbol())<=0)  {}  // do nothing
                     else
                     {
                        LinexCloseOrders(I_TargetMagic); 
                        if (1==SwissDebug) Print("PlusSwiss: Target1 CLOSE BUY Close[0]=",DoubleToStr(Close[0],5),"<I_TargetMLimit=",DoubleToStr(I_TargetMLimit,5)
                            ," I_LinePrice1=",DoubleToStr(I_LinePrice1,5)," I_LinePrice2=",DoubleToStr(I_LinePrice2,5)," Delta=",DoubleToStr(I_TargetMLimit-Close[0],5));
                        Sleep(300); 
                    //--  Assert Open orders are removed
                        return(1);
                     }
                  }
         }
      }
   }
   else
//-- Assert new concept moving trendline - Stage 6 of 5: Reset Status from 1 to 0.
      I_TargetStatus=0;
      

   // Trade Decision
   // ==============
   if (II_TargetLineLevel>0)
   {
      // Buy Zone
      // ========
      if (Close[0]>II_TargetHLimit && Close[0]<II_TargetHLimit1)
      {
      //-- Assert new concept moving trendline - Stage 2 of 5: Set Status from 0 (or 2) to 1.
         if (LinexOpenLast(II_TargetMagic)==OP_BUY && II_TargetStatus!=1 && !SwissTarget2NoMove) II_TargetStatus=1;
      //-- Assert Added option to turn off buy or sell
      //-- Assert new concept moving trendline - Stage 5 of 5: Open pending order and no need to reset Status.
         if (LinexOpenLast(II_TargetMagic)==OP_SELL)
         {
            if (II_TargetStatus!=1 && !SwissTarget2NoMove)  {}    // do nothing
            else
            //--  Assert Open orders are removed
               if (LinexOpenOrd(II_TargetMagic)==0)   return(0);
               else
                  if (LinexOpenLast(II_TargetMagic)==OP_SELL)
                  {   
                     if (SwissOnlyTakeProfits && EasyProfitsBasket(II_TargetMagic,Symbol())<=0)  {}  // do nothing
                     else
                     {
                        LinexCloseOrders(II_TargetMagic); 
                        if (1==SwissDebug) Print("PlusSwiss: Target2 CLOSE SELL Close[0]=",DoubleToStr(Close[0],5),">II_TargetMLimit=",DoubleToStr(II_TargetMLimit,5)
                            ," II_LinePrice1=",DoubleToStr(II_LinePrice1,5)," II_LinePrice2=",DoubleToStr(II_LinePrice2,5)," Delta=",DoubleToStr(Close[0]-II_TargetMLimit,5));
                        Sleep(300); 
                    //--  Assert Open orders are removed
                        return(-2);
                     }
                  }
         }
      }
      // Sell Zone
      // =========
   //--  Assert Added option to turn off buy or sell
      if (Close[0]<II_TargetLLimit && Close[0]>II_TargetLLimit1)
      {
      //-- Assert new concept moving trendline - Stage 2 of 5: Set Status from 0 (or 2) to 1.
         if (LinexOpenLast(II_TargetMagic)==OP_SELL && II_TargetStatus!=1 && !SwissTarget2NoMove) II_TargetStatus=1;
      //-- Assert Added option to turn off buy or sell
      //-- Assert new concept moving trendline - Stage 5 of 5: Open pending order.
         if (LinexOpenLast(II_TargetMagic)==OP_BUY)
         {
            if (II_TargetStatus!=1 && !SwissTarget2NoMove)  {}    // do nothing
            else
            //-- Assert Open orders are removed
               if (LinexOpenOrd(II_TargetMagic)==0)   return(0);
               else
                  if (LinexOpenLast(II_TargetMagic)==OP_BUY)
                  {   
                     if (SwissOnlyTakeProfits && EasyProfitsBasket(II_TargetMagic,Symbol())<=0)  {}  // do nothing
                     else
                     {
                        LinexCloseOrders(II_TargetMagic); 
                        if (1==SwissDebug) Print("PlusSwiss: Target2 CLOSE BUY Close[0]=",DoubleToStr(Close[0],5),"<II_TargetMLimit=",DoubleToStr(II_TargetMLimit,5)
                            ," II_LinePrice1=",DoubleToStr(II_LinePrice1,5)," II_LinePrice2=",DoubleToStr(II_LinePrice2,5)," Delta=",DoubleToStr(II_TargetMLimit-Close[0],5));
                        Sleep(300); 
                    //--  Assert Open orders are removed
                        return(2);
                     }
                  }
         }
      }
   }
   else
//-- Assert new concept moving trendline - Stage 6 of 5: Reset Status from 1 to 0.
      II_TargetStatus=0;
      
   return(0);
}

//|-----------------------------------------------------------------------------------------|
//|                                     C O M M E N T                                       |
//|-----------------------------------------------------------------------------------------|
string SwissComment(string cmt="")
{
   string strtmp = cmt+"  -->"+SwissName+" "+SwissVer+"<--";

//---- Assert Basic settings in comment
   if (SwissUseTrailing)
   {
      strtmp=strtmp+"\n    EvenAt="+DoubleToStr(SwissEvenAt,0)+"  EvenSlide="+DoubleToStr(SwissEvenSlide,0)+"  TrailingStop="+DoubleToStr(SwissTrailingStop,0)+"  ";
      if (SwissOnlyTakeProfits) strtmp=strtmp+"(Only trail profits)";
   }
   if (SwissUseParabolic)
   {
      double pricestop=iSAR(Symbol(),0,0.02,0.2,0);
      strtmp=strtmp+"\n    Parabolic="+DoubleToStr(pricestop,5);
   }
//---- Assert Added PlusLinex.mqh
strtmp = strtmp + "\n    PipLimit=" + DoubleToStr(SwissPipLimit,0) + " PipWide=" + DoubleToStr(SwissPipWide,0);
   if (!SwissTarget1NoMove || !SwissTarget2NoMove) 
      strtmp = strtmp + " PipMove=" + DoubleToStr(SwissPipMove,0)+"  ";
   if (SwissOnlyTakeProfits) strtmp=strtmp+"(Only take profits)";
   if (I_TargetLineLevel<0 && II_TargetLineLevel<0) 
      strtmp = strtmp + "\n    No Active Stealthlines.";
   if (I_TargetLineLevel>=0)
   {
         strtmp = strtmp + "\n    " +SwissTarget1+ " : " + DoubleToStr(I_TargetLineLevel,Digits);
         if (!SwissTarget1NoMove)
            switch (I_TargetStatus)
            {
               case 0:
                  strtmp = strtmp + " Stealth:";
                  break;
               case 1:
                  strtmp = strtmp + " Move " + DoubleToStr(MathAbs((I_TargetLineLevel-I_TargetLineLevelStart)/Pts),1) + " Target:";
                  break;
            }
         else
            strtmp = strtmp + " Target:";
         if (LinexOpenLast(I_TargetMagic)==OP_BUY)    strtmp = strtmp + " (TP >" + DoubleToStr(I_TargetHLimit,Digits) + " && <" + DoubleToStr(I_TargetHLimit1,Digits) + ")";
         if (LinexOpenLast(I_TargetMagic)==OP_SELL)   strtmp = strtmp + " (TP >" + DoubleToStr(I_TargetLLimit1,Digits) + " && <" + DoubleToStr(I_TargetLLimit,Digits) + ")";

         strtmp = strtmp + " Last Order: ";  
         switch (LinexOpenLast(I_TargetMagic))
         {
            case 0:  strtmp = strtmp + "BUY";    break;
            case 1:  strtmp = strtmp + "SELL";   break;
            default: strtmp = strtmp + "NIL";
         }
   }
   if (II_TargetLineLevel>=0)
   {
         strtmp = strtmp + "\n    " +SwissTarget2+ " : " + DoubleToStr(II_TargetLineLevel,Digits);
         if (!SwissTarget2NoMove)
            switch (II_TargetStatus)
            {
               case 0:
                  strtmp = strtmp + " Stealth:";
                  break;
               case 1:
                  strtmp = strtmp + " Move " + DoubleToStr(MathAbs((II_TargetLineLevel-II_TargetLineLevelStart)/Pts),1) + " Target:";
                  break;
            }
         else
            strtmp = strtmp + " Target:";
         if (LinexOpenLast(II_TargetMagic)==OP_BUY)    strtmp = strtmp + " (TP >" + DoubleToStr(II_TargetHLimit,Digits) + " && <" + DoubleToStr(II_TargetHLimit1,Digits) + ")";
         if (LinexOpenLast(II_TargetMagic)==OP_SELL)   strtmp = strtmp + " (TP >" + DoubleToStr(II_TargetLLimit1,Digits) + " && <" + DoubleToStr(II_TargetLLimit,Digits) + ")";

         strtmp = strtmp + " Last Order: ";
         switch (LinexOpenLast(II_TargetMagic))
         {
            case 0:  strtmp = strtmp + "BUY";    break;
            case 1:  strtmp = strtmp + "SELL";   break;
            default: strtmp = strtmp + "NIL";
         }
   }
   
   strtmp=strtmp+"\n";
   return(strtmp);
}

//|-----------------------------------------------------------------------------------------|
//|                       E N D   O F   E X P E R T   A D V I S O R                         |
//|-----------------------------------------------------------------------------------------|
