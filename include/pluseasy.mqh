//+------------------------------------------------------------------+
//|                                                     pluseasy.mqh |
//|                                     Copyright © 2011, Dennis Lee |
//|                                                                  |
//| Assert History                                                   |
//| 1.00    Copied from AlleeH4 4.43, functions that relate to       |
//|           open/close:                                            |
//|           buy_to_open()                                          |
//|           sell_to_open()                                         |
//|           sell_to_close()                                        |
//|           buy_to_close()                                         |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2011, Dennis Lee"
//+------------------------------------------------------------------+
//| buy to open function                                             |
//+------------------------------------------------------------------+
int buy_to_open(int total)
{
//---- Assert account has money.
   if(AccountFreeMargin()<(1000*get_lots()))
   {
      Print("We have no money. Free Margin = ", AccountFreeMargin());
      return(0);
   }
//---- Assert AccountMaxTrades has not been exceeded
   if(total>=MaxAccountTrades)
   {
      Print("Total trades have exceeded MaxAccountTrades of ",MaxAccountTrades);
      return(0);
   }
//---- Assert SymbolMaxTrades has not been exceeded
   if(count_magic_total()>=MaxSamePairTrades)
   {
      Print("Total same pair trades have exceeded MaxSamePairTrades of ",MaxSamePairTrades);
      return(0);
   }   
//---- Assert BearBullRatio is not 2.
   if (BearBullRatio==2)
   {
      Print("BearBullRatio=",BearBullRatio,". Buy to Open has been disabled.");
      return(0);
   }
//---- Assert Spread < MaxSpread.
   double spread=MarketInfo(Symbol(),MODE_SPREAD)/Pip;
   if (spread>MaxSpread)
   {
      Print("Spread has exceeded MaxSpread of ",MaxSpread);
      return(0);
   }
   
   double bbr_bto;
//---- Assert step-down dampening of BbrBTO if BbrBTO>1
   if (BbrBTO>1) bbr_bto=dampener(BbrBTO);
   else bbr_bto=BbrBTO;
   
   int ticket=OrderSend(Symbol(),OP_BUY,NormalizeDouble(get_lots()*bbr_bto,2),MarketInfo(Symbol(),MODE_ASK),SlipPage,0,0,TradeComment,MagicNumber,0,Thistle);
   if(ticket>0)
   {
      if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)) 
      {
      //---- Clear UserLot and UserOpenSignal
         if (UserLot!=0 && UserOpenSignal!=0)
         {
            UserOpenSignal=0;
         }
      //---- SecureProfitOnHour assigned
         if (SecureProfitOnMins>0)
         {
            securetime=TimeCurrent();
            handle_secureprofitonhour(false);
         }
      //---- Assert Open Buy
         Print("BUY order opened : ",OrderOpenPrice());
         OpenWave=-1;
         double SL=NormalizeDouble(OrderOpenPrice()-StopLoss*Pts,Digits);
         //double TP=NormalizeDouble(OrderOpenPrice()+TakeProfit*bbr_bto*Pts,Digits);
         if (!OrderModify(ticket,OrderOpenPrice(),SL,0,0,0))
         {
            Print("Error modifying BUY order : ",GetLastError());
            if (Debug>=2) Print("buy_to_open():Symbol()=",Symbol(),",Price=",OrderOpenPrice(),",SL=",SL,",TP=",0);
         }
      }
      return(ticket);
   }
   else 
   {
      Print("Error opening BUY order : ",GetLastError());
      if (Debug>=2) Print("buy_to_open():Symbol()=",Symbol(),",Lots=",get_lots(),",Ask=",MarketInfo(Symbol(),MODE_ASK),",SlipPage=",SlipPage,",SL=,",0,",TP=",0); //Ask+TakeProfit*Pts
      PlaySound("Alert.wav");
   }
   return(0);
}
//+------------------------------------------------------------------+
//| sell to open function                                            |
//+------------------------------------------------------------------+
int sell_to_open(int total)
{
//---- Assert account has money.
   if(AccountFreeMargin()<(1000*get_lots()))
   {
      Print("We have no money. Free Margin = ", AccountFreeMargin());
      return(0);
   }
//---- Assert AccountMaxTrades has not been exceeded
   if(total>=MaxAccountTrades)
   {
      Print("Total trades have exceeded MaxAccountTrades of ",MaxAccountTrades);
      return(0);
   }
//---- Assert SymbolMaxTrades has not been exceeded
   if(count_magic_total()>=MaxSamePairTrades)
   {
      Print("Total same pair trades have exceeded MaxSamePairTrades of ",MaxSamePairTrades);
      return(0);
   }   
//---- Assert BearBullRatio is not 0.
   if (BearBullRatio==0)
   {
      Print("BearBullRatio=",BearBullRatio,". Sell to Open has been disabled.");
      return(0);
   }
//---- Assert Spread < MaxSpread.
   double spread=MarketInfo(Symbol(),MODE_SPREAD)/Pip;
   if (spread>MaxSpread)
   {
      Print("Spread has exceeded MaxSpread of ",MaxSpread);
      return(0);
   }

//---- Assert step-down dampening of BbrBTO if BbrBTO>1
   double bbr_sto;
   if (BbrSTO>1) bbr_sto=dampener(BbrSTO);
   else bbr_sto=BbrSTO;
   
   int ticket=OrderSend(Symbol(),OP_SELL,NormalizeDouble(get_lots()*bbr_sto,2),MarketInfo(Symbol(),MODE_BID),SlipPage,0,0,TradeComment,MagicNumber,0,Red);
   if(ticket>0)
   {
      if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)) 
      {
      //---- Clear UserLot and UserOpenSignal
         if (UserLot!=0 && UserOpenSignal!=0)
         {
            UserOpenSignal=0;
         }
      //---- SecureProfitOnHour assigned
         if (SecureProfitOnMins>0)
         {
            securetime=TimeCurrent();
            handle_secureprofitonhour(false);
         }
      //---- Assert Open Sell
         Print("SELL order opened : ",OrderOpenPrice());
         OpenWave=1;
         double SL=NormalizeDouble(OrderOpenPrice()+StopLoss*Pts,Digits);
         //double TP=NormalizeDouble(OrderOpenPrice()-TakeProfit*bbr_sto*Pts,Digits);
         if (!OrderModify(ticket,OrderOpenPrice(),SL,0,0,0))
         {
            Print("Error modifying SELL order : ",GetLastError());
            if (Debug>=2) Print("sell_to_open():Symbol()=",Symbol(),",Price=",OrderOpenPrice(),",SL=",SL,",TP=",0);
         }
      }
      return(ticket);
   }
   else 
   {
      Print("Error opening SELL order : ",GetLastError());
      if (Debug>=2) Print("sell_to_open():Symbol()=",Symbol(),",Lots=",get_lots(),",Bid=",MarketInfo(Symbol(),MODE_BID),",SlipPage=",SlipPage,",SL=,",0,",TP=",0); //Ask+TakeProfit*Pts
      PlaySound("Alert.wav");
   }

   return(0);
}
//+------------------------------------------------------------------+
//| Sell to close function                                           |
//+------------------------------------------------------------------+
bool sell_to_close(int ticket)
{
   bool Closed;

//---- Assert ticket is valid.
   if (ticket<=0)
   {
      Print("sell_to_close():ticket=",ticket," number is invalid.");
      return(false);
   }

   OrderSelect(ticket, SELECT_BY_TICKET);

//---- Assert ticket is open and orderlots should be closed at current bid price.
   if (OrderCloseTime()==0)
   {
      Closed=OrderClose(ticket,OrderLots(),MarketInfo(Symbol(),MODE_BID),SlipPage,Red);
      
      if (!Closed)
      {
         Print("Error closing BUY order : ",GetLastError());
         if (Debug>=2) Print("sell_to_close():Symbol()=",Symbol(),",Bid=",MarketInfo(Symbol(),MODE_BID),",SlipPage=",SlipPage);
      }
   }
   return(Closed);
}
//+------------------------------------------------------------------+
//| Buy to close function                                            |
//+------------------------------------------------------------------+
bool buy_to_close(int ticket)
{
   bool Closed;

//---- Assert ticket is valid.
   if (ticket<=0)
   {
      Print("buy_to_close():ticket=",ticket," number is invalid.");
      return(false);
   }

   OrderSelect(ticket, SELECT_BY_TICKET);

//---- Assert ticket is open and orderlots should be closed at current ask price.
   if (OrderCloseTime()==0)
   {
      Closed=OrderClose(ticket,OrderLots(),MarketInfo(Symbol(),MODE_ASK),SlipPage,Thistle);
      
      if (!Closed)
      {
         Print("Error closing SELL order : ",GetLastError());
         if (Debug>=2) Print("buy_to_close():Symbol()=",Symbol(),",Ask=",MarketInfo(Symbol(),MODE_ASK),",SlipPage=",SlipPage);
      }
   }
   return(Closed);
}

