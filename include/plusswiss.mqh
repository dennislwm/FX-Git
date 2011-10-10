//|-----------------------------------------------------------------------------------------|
//|                                                                           PlusSwiss.mqh |
//|                                                            Copyright © 2011, Dennis Lee |
//| Assert History                                                                          |
//| 1.00    Copied from decompiled Swiss Army EA v1.51.                                     |
//|             breakEvenManager()  --> SwissEvenManager()                                  |
//|             trailingStopManager()   --> SwissTrailingStopManager()                      |
//|-----------------------------------------------------------------------------------------|
#property   copyright "Copyright © 2011, Dennis Lee"

//|-----------------------------------------------------------------------------------------|
//|                 P L U S E A S Y   E X T E R N A L   V A R I A B L E S                   |
//|-----------------------------------------------------------------------------------------|
//---- Assert Swiss externs
extern double SwissEvenAt=0;
extern double SwissEvenSlide=0;
extern double SwissTrailingStop=0;
extern bool SwissOnlyTrailProfits=false;
extern int SwissDebug=0;

//|-----------------------------------------------------------------------------------------|
//|                           I N T E R N A L   V A R I A B L E S                           |
//|-----------------------------------------------------------------------------------------|
string SwissName="PlusSwiss";
string SwissVer="1.00";

//|-----------------------------------------------------------------------------------------|
//|                             I N I T I A L I Z A T I O N                                 |
//|-----------------------------------------------------------------------------------------|

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
   strtmp=strtmp+"\n    EvenAt="+DoubleToStr(SwissEvenAt,0)+"  EvenSlide="+DoubleToStr(SwissEvenSlide,0)+"  TrailingStop="+DoubleToStr(SwissTrailingStop,0)+"  ";
   if (SwissOnlyTrailProfits) strtmp=strtmp+"(Only trail profits)";
   
   strtmp=strtmp+"\n";
   return(strtmp);
}
