//|-----------------------------------------------------------------------------------------|
//|                                                                           PlusSwiss.mqh |
//|                                                            Copyright © 2011, Dennis Lee |
//| Assert History                                                                          |
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
extern double SwissEvenAt=0;
extern double SwissEvenSlide=0;
extern double SwissTrailingStop=0;
extern bool SwissOnlyTrailProfits=false;
extern int SwissDebug=0;

//|-----------------------------------------------------------------------------------------|
//|                           I N T E R N A L   V A R I A B L E S                           |
//|-----------------------------------------------------------------------------------------|
string SwissName="PlusSwiss";
string SwissVer="1.10";

//|-----------------------------------------------------------------------------------------|
//|                             I N I T I A L I Z A T I O N                                 |
//|-----------------------------------------------------------------------------------------|
void SwissInit()
{
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
      SwissTrailingStopManager(mgc,sym,SwissTrailingStop,SwissOnlyTrailProfits,pt);
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
//|                                     C O M M E N T                                       |
//|-----------------------------------------------------------------------------------------|
string SwissComment(string cmt="")
{
   string strtmp = cmt+"  -->"+SwissName+" "+SwissVer+"<--";

//---- Assert Basic settings in comment
   if (SwissUseTrailing)
   {
      strtmp=strtmp+"\n    EvenAt="+DoubleToStr(SwissEvenAt,0)+"  EvenSlide="+DoubleToStr(SwissEvenSlide,0)+"  TrailingStop="+DoubleToStr(SwissTrailingStop,0)+"  ";
      if (SwissOnlyTrailProfits) strtmp=strtmp+"(Only trail profits)";
   }
   if (SwissUseParabolic)
   {
      double pricestop=iSAR(Symbol(),0,0.02,0.2,0);
      strtmp=strtmp+"\n    Parabolic="+DoubleToStr(pricestop,5);
   }
   
   strtmp=strtmp+"\n";
   return(strtmp);
}

