//+-------------------------------------------------------------------+
//|                                                   Gday mark 2.mq4 |
//|                                    Copyright 2012, Steve Hopwood  |
//|                              http://www.hopwood3.freeserve.co.uk  |
//+-------------------------------------------------------------------+
#define  version "Version 1h"

#property copyright "Copyright 2012, Steve Hopwood"
#property link      "http://www.hopwood3.freeserve.co.uk"
#include <WinUser32.mqh>
#include <stdlib.mqh>
#define  NL    "\n"
#define  up "Up"
#define  down "Down"
#define  ranging "Ranging"
#define  none "None"
#define  both "Both"
#define  buy "Buy"
#define  sell "Sell"

//Pending trade price line
#define  pendingpriceline "Pending price line"
//Hidden sl and tp lines. If used, the bot will close trades on a touch/break of these lines.
//Each line is named with its appropriate prefix and the ticket number of the relevant trade
#define  TpPrefix "Tp"
#define  SlPrefix "Sl"

//Trade setup constants
#define  longsetup "There is a long trade setup"
#define  shortsetup "There is a short trade setup"
#define  nosetup "There is no trade setup"

//Slope constants
#define  buyonly "Buy Only. "
#define  sellonly "Sell Only. "
#define  buyhold "Buy and hold. "
#define  sellhold "Sell and hold. "
#define  rising   ": Angle is rising. "
#define  falling   ": Angle is falling. "
#define  unchanged   ": Angle is unchanged. "

//Error reporting
#define  slm " stop loss modification failed with error "
#define  tpm " take profit modification failed with error "
#define  ocm " order close failed with error "
#define  odm " order delete failed with error "
#define  pcm " part close failed with error "

/*
http://www.stevehopwoodforex.com/phpBB3/viewtopic.php?f=5&t=917

Matt Kennel has provided the code for bool O_R_CheckForHistory(int ticket). Cheers Matt, You are a star.

Code for adding debugging Sleep
Alert("G");
int x = 0;
while (x == 0) Sleep(100);

Standard order loop code
   for (int cc = OrdersTotal() - 1; cc >= 0; cc--)
   {
      if (!OrderSelect(cc, SELECT_BY_POS) ) continue;
      if (OrderSymbol() != Symbol() ) continue;
      if (OrderMagicNumber() != MagicNumber) continue;

   }//for (int cc = OrdersTotal() - 1; cc >= 0; cc--)

Code from George, to detect the shift of an order open time
int shift = iBarShift(NULL,Period(),OrderOpenTime(), false);

To calculate what percentage a small number is of a larger one:
(Given amount Divided by Total amount) x100 = %
as in UpperWickPercentage = (UpperWick / CandleSize) * 100; where CandleSize is the size of the the candle and UpperWick the size of the top of the body to the High.

FUNCTIONS LIST
void DisplayUserFeedback()
int init()
int start()

----Trading----

void LookForTradingOpportunities()
   double CalculateStopLoss(int type)
   double CalculateTakeProfit(int type)
   bool IsTradingAllowed()
   double CalculateLotSize(double price1, double price2)
bool SendSingleTrade(int type, string comment, double lotsize, double price, double stop, double take)
   void ModifyOrder(int ticket, double stop, double take)
void CountOpenTrades()
   void InsertStopLoss(int ticket)
   void InsertTakeProfit(int ticket)
bool CloseTrade(int ticket)
bool LookForTradeClosure(int ticket)
bool CheckTradingTimes()
void CloseAllTrades()
double CalculateTradeProfitInPips()
bool CloseEnough(double num1, double num2)
double PFactor(string pair)

----Hidden sl/tp---- Doubles up for pending trades-based ea's
void DrawPendingPriceLines()
void DeletePendingPriceLines()
void ReplaceMissingSlTpLines()
void DeleteOrphanTpSlLines()



----Matt's Order Reliable library code
bool O_R_CheckForHistory(int ticket) Cheers Matt, You are a star.
void O_R_Sleep(double mean_time, double max_time)

----Indicator readings----
void ReadIndicatorValues()
void CalculateDailyResult()


----Trade management module----
void TradeManagementModule()
void BreakEvenStopLoss()
void JumpingStopLoss() 
void TrailingStopLoss()
void CandlestickTrailingStop()
void ReportError()

*/

extern string   gen="----General inputs----";
extern double   Lot=0.03;
extern int      RiskPercent = 0;//Set to zero to disable and use Lot
extern bool     TradeLong=true;
extern bool     TradeShort=true;
extern int      TakeProfitPips=0;
extern int      StopLossPips=0;
extern int      MagicNumber=2;
extern string   TradeComment="";
extern bool     CriminalIsECN=false;
extern double   MaxSpread=12;
extern double   MaxSlippagePips=5;
extern bool     KeepOpenPositiveSwapLosers=true;
////////////////////////////////////////////////////////////////////////////////////////
double          TakeProfit, StopLoss;
double          factor;//For pips/points stuff. Set up in int init()
datetime        OldBarsTime;
double          OldAsk, OldBid;
////////////////////////////////////////////////////////////////////////////////////////

extern string   top="----Trading options----";
extern bool     Option1=true;//Setup yesterday, trigger the first tick of the new candle
extern bool     Option2=true;//ob/os Close[2]: out of ob/os Close[1]: still out of ob/os. Trigger at Open[0];

extern string   ssc="----Saturday and Sunday candles----";
extern bool     TradeSundayCandle=false;//For Europeans
extern bool     TradeSaturdayCandle=false;//For Uside-Down landers

//Stoch
extern string   st="--- Stochastic ---";
extern int      StochTimeFrame=1440;
extern int      K_Period=7;
extern int      D_Period=2;
extern int      Slowing=2;
extern int      MaMethod=0;
extern int      PriceField=0;
extern int      OverBought=80;//For trade setup
extern int      ShortTradeTrigger=80;//For trade trigger
extern int      OverSold=20;//For trade setup
extern int      LongTradeTrigger=20;//For trade trigger
////////////////////////////////////////////////////////////////////////////////////////
double          StochMain, StochSignal;
string          TradeSetupStatus;//For feedback display
////////////////////////////////////////////////////////////////////////////////////////

//Hidden tp/sl inputs.
extern string   hts="----Stealth stop loss and take profit inputs----";
extern int      PipsHiddenFromCriminal=0;//Added to the 'hard' sl and tp and used for closure calculations
////////////////////////////////////////////////////////////////////////////////////////
double          HiddenStopLoss, HiddenTakeProfit;
double          HiddenPips=0;//Added to the 'hard' sl and tp and used for closure calculations
////////////////////////////////////////////////////////////////////////////////////////

extern string   slo="----Slope inputs----";
extern int      HtfTimeFrame=0;//Zero to disable
extern double   HtfBuyOnlyLevel=0.4;
//~ extern double   HtfBuyHoldLevel=0.8;
//~ extern double   HtfBuyCloseLevel=0.3;
extern double   HtfSellOnlyLevel=-0.4;
//~ extern double   HtfSellHoldLevel=-0.8;
//~ extern double   HtfSellCloseLevel=-0.3;
extern int      LtfTimeFrame=0;//Zero to disable
extern double   LtfBuyOnlyLevel=0.4;
//~ extern double   LtfBuyHoldLevel=0.8;
//~ extern double   LtfBuyCloseLevel=0.3;
extern double   LtfSellOnlyLevel=-0.4;
//~ extern double   LtfSellHoldLevel=-0.8;
//~ extern double   LtfSellCloseLevel=-0.3;
////////////////////////////////////////////////////////////////////////////////////////
double          HtfSlopeVal, LtfSlopeVal, PrevHtfSlopeVal, PrevLtfSlopeVal;
string          HtfSlopeTrend, LtfSlopeTrend, HtfSlopeAngle, LtfSlopeAngle;
////////////////////////////////////////////////////////////////////////////////////////

extern string   bf="----Trading balance filters----";
extern bool     UseZeljko=true;
extern bool     OnlyTradeCurrencyTwice=true;
////////////////////////////////////////////////////////////////////////////////////////
bool            CanTradeThisPair;
////////////////////////////////////////////////////////////////////////////////////////

extern string   pts="----Swap filter----";
extern bool     CadPairsPositiveOnly=true;
extern bool     AudPairsPositiveOnly=true;
extern bool     NzdPairsPositiveOnly=true;
extern bool     OnlyTradePositiveSwap=false;
////////////////////////////////////////////////////////////////////////////////////////
double          LongSwap, ShortSwap;
////////////////////////////////////////////////////////////////////////////////////////

extern string  amc="----Available Margin checks----";
extern string  sco="Scoobs";
extern bool    UseScoobsMarginCheck=false;
extern string  fk="ForexKiwi";
extern bool    UseForexKiwi=true;
extern int     FkMinimumMarginPercent=1000;
////////////////////////////////////////////////////////////////////////////////////////
bool           EnoughMargin;
string         MarginMessage;
////////////////////////////////////////////////////////////////////////////////////////

extern string   ems="----Email thingies----";
extern bool     EmailTradeNotification=false;
extern bool     SendAlertNotTrade=false;
////////////////////////////////////////////////////////////////////////////////////////
bool            AlertSent;//To alert to a trade trigger without actually sending the trade
////////////////////////////////////////////////////////////////////////////////////////

extern string   tmm="----Trade management module----";
extern bool     EnablePartClosure=true;//Lot must be divisible by 3 for this to work.
//Breakeven has to be enabled for JS and TS to work.
extern string   BE="Break even settings";
extern bool     BreakEven=true;
extern int      BreakEvenTargetPips=50;
extern int      BreakEvenTargetProfit=2;
bool     HalfCloseEnabled=false;//Leave it; you never know
////////////////////////////////////////////////////////////////////////////////////////
double          BreakEvenPips, BreakEvenProfit;
////////////////////////////////////////////////////////////////////////////////////////

extern string   JSL="Jumping stop loss settings";
extern bool     JumpingStop=true;
extern int      JumpingStopTargetPips=50;
extern bool     AddBEP=true;
////////////////////////////////////////////////////////////////////////////////////////
double          JumpingStopPips;
////////////////////////////////////////////////////////////////////////////////////////

extern string   cts="----Candlestick trailing stop----";
extern bool     UseCandlestickTrailingStop=false;
extern bool     CandleTrailAfterBreakevenOnly=true;
extern int      CstTimeFrame=0;//Defaults to current chart
extern int      CstTrailCandles=1;//Defaults to previous candle
////////////////////////////////////////////////////////////////////////////////////////
int             OldCstBars;//For candlestick ts
////////////////////////////////////////////////////////////////////////////////////////

extern string   TSL="Trailing stop loss settings";
extern bool     TrailingStop=false;
extern int      TrailingStopTargetPips=20;
////////////////////////////////////////////////////////////////////////////////////////
double          TrailingStopPips;
////////////////////////////////////////////////////////////////////////////////////////

extern string   mis="----Odds and ends----";
extern int      DisplayGapSize=30;
////////////////////////////////////////////////////////////////////////////////////////
string          Gap, ScreenMessage;
////////////////////////////////////////////////////////////////////////////////////////


//Matt's O-R stuff
int 	        O_R_Setting_max_retries 	= 10;
double 	        O_R_Setting_sleep_time 		= 4.0; /* seconds */
double 	        O_R_Setting_sleep_max 		= 15.0; /* seconds */
int             RetryCount = 10;//Will make this number of attempts to get around the trade context busy error.

//Trading variables
int             TicketNo = -1, OpenTrades, OldOpenTrades;
bool            BuyOpen, SellOpen, PendingBuyOpen, PendingSellOpen;//Might need further refinement to reflect the pending type
double          upl;//For keeping track of the upl of hedged positions





//Running total of trades
int             LossTrades, WinTrades;
double          OverallProfit;

//Misc
int             OldBars;
string          PipDescription=" pips";
bool            ForceTradeClosure;
int             TurnOff=0;//For turning off functions without removing their code



void DisplayUserFeedback()
{
   
   if (IsTesting() && !IsVisualMode()) return;

   ScreenMessage = "";
   //ScreenMessage = StringConcatenate(ScreenMessage,Gap + NL);
   SM(NL);
   
   SM("Updates for this EA are to be found at http://www.stevehopwoodforex.com" + NL);
   SM("Feeling generous? Help keep the coder going with a small Paypal donation to pianodoodler@hotmail.com" + NL);
   SM(TimeToStr(TimeLocal() + TIME_DATE|TIME_MINUTES|TIME_SECONDS) + NL );
   SM(version + NL);
   /*
   //Code for time to bar-end display from Candle Time by Nick Bilak
   double i;
   int m +s +k;
   m=Time[0]+Period()*60-CurTime();
   i=m/60.0;
   s=m%60;
   m=(m-m%60)/60;
   SM(m + " minutes " + s + " seconds left to bar end" + NL);
   */
      
   SM(NL);     
   if (TradeLong) SM("Taking long trades" + NL);
   if (TradeShort) SM("Taking short trades" + NL);
   if (!TradeLong && !TradeShort) SM("Both TradeLong and TradeShort are set to false" + NL);
   SM("Lot size: " + DoubleToStr(Lot, 2) + " (Criminal's minimum lot size: " + DoubleToStr(MarketInfo(Symbol(), MODE_MINLOT) , 2)+ ")" + NL);
   SM("Take profit: " + DoubleToStr(TakeProfit, 0) + PipDescription +  NL);
   SM("Stop loss: " + DoubleToStr(StopLoss, 0) + PipDescription +  NL);
   if (KeepOpenPositiveSwapLosers) SM("KeepOpenPositiveSwapLosers is enabled" + NL);
   SM("Magic number: " + MagicNumber + NL);
   SM("Trade comment: " + TradeComment + NL);
   if (CriminalIsECN) SM("CriminalIsECN = true" + NL);
   else SM("CriminalIsECN = false" + NL);
   double spread = (Ask - Bid) * factor;   
   SM("MaxSpread = " + DoubleToStr(MaxSpread, 0) + ": Spread = " + DoubleToStr(spread, 1) + NL);
   SM("Long swap " + DoubleToStr(LongSwap, 2) + ": ShortSwap " + DoubleToStr(ShortSwap, 2) + NL);
   SM("Stochastic setup status: " + TradeSetupStatus + NL);
   if (MarginMessage != "") SM(NL + MarginMessage + NL);


   //Running total of trades
   SM(Gap + NL);
   SM("Results today. Wins: " + WinTrades + ": Losses " + LossTrades + ": P/L " + DoubleToStr(OverallProfit, 2) + NL);
   
      
   SM(NL);
   
   if (BreakEven)
   {
      SM("Breakeven is set to " + DoubleToStr(BreakEvenPips, 0) + PipDescription + ": BreakEvenProfit = " + DoubleToStr(BreakEvenProfit, 0) + PipDescription);
      SM(NL);
   }//if (BreakEven)

   if (UseCandlestickTrailingStop)
   {
      SM("Using candlestick trailing stop" + NL);      
   }//if (UseCandlestickTrailingStop)
   
   if (JumpingStop)
   {
      SM("Jumping stop is set to " + DoubleToStr(JumpingStopPips, 0) + PipDescription);
      SM(NL);  
   }//if (JumpingStop)
   

   if (TrailingStop)
   {
      SM("Trailing stop is set to " + DoubleToStr(TrailingStopPips, 0) + PipDescription);
      SM(NL);  
   }//if (TrailingStop)
   
   if (HtfTimeFrame > 0)
   {
      SM("Htf value " + DoubleToStr(HtfSlopeVal, 4) + ": Trend is " + HtfSlopeTrend + NL);
      //SM("Htf value " + DoubleToStr(HtfSlopeVal, 4) + ": Trend is " + HtfSlopeTrend + HtfSlopeAngle + NL);                                                                
   }//if (HtfTimeFrame > 0)

   if (LtfTimeFrame > 0)
   {
      SM("Ltf value " + DoubleToStr(LtfSlopeVal, 4) + ": Trend is " + LtfSlopeTrend + NL);
      //SM("Ltf value " + DoubleToStr(LtfSlopeVal, 4) + ": Trend is " + LtfSlopeTrend + LtfSlopeAngle + NL);
   }//if (HtfTimeFrame > 0)
   
   
   Comment(ScreenMessage);


}//void DisplayUserFeedback()

void SM(string message)
{
   
   ScreenMessage = StringConcatenate(ScreenMessage,Gap, message);
      
}//End void DM()

//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
{
//----


   //~ Set up the pips factor. tp and sl etc.
   //~ The EA uses doubles and assume the value of the integer user inputs. This: 
   //~    1) minimises the danger of the inputs becoming corrupted by restarts; 
   //~    2) the integer inputs cannot be divided by factor - doing so results in zero.
   
   factor = PFactor(Symbol());
   StopLoss = StopLossPips;
   TakeProfit = TakeProfitPips;
   BreakEvenPips = BreakEvenTargetPips;
   BreakEvenProfit = BreakEvenTargetProfit;
   JumpingStopPips = JumpingStopTargetPips;
   TrailingStopPips = TrailingStopTargetPips;
   HiddenPips = PipsHiddenFromCriminal;
   
   while (IsConnected()==false)
   {
      Comment("Waiting for MT4 connection...");
      Sleep(1000);
   }//while (IsConnected()==false)

   //Lot size and part-close idiot check for the cretins. Code provided by phil_trade. Many thanks, Philippe.
   //adjust Min_lot
   if (Lot < MarketInfo(Symbol(), MODE_MINLOT)) 
   {
   Alert(Symbol()+" Lot was adjusted to Minlot = "+DoubleToStr(MarketInfo(Symbol(), MODE_MINLOT),Digits ) );
   Lot = MarketInfo(Symbol(), MODE_MINLOT);
   }//if (Lot < MarketInfo(Symbol(), MODE_MINLOT)) 
   /*
   //check Partial close parameters
   if (PartCloseEnabled == true)
   {
      if (Lot < Close_Lots + Preserve_Lots || Lot < MarketInfo(Symbol(), MODE_MINLOT) + Close_Lots )
      {
         Alert(Symbol()+" PartCloseEnabled is disabled because Lot < Close_Lots + Preserve_Lots or Lot < MarketInfo(Symbol(), MODE_MINLOT) + Close_Lots !");
         PartCloseEnabled = false;
      }//if (Lot < Close_Lots + Preserve_Lots || Lot < MarketInfo(Symbol(), MODE_MINLOT) + Close_Lots )
   }//if (PartCloseEnabled == true)
   */

   //Jumping/trailing stops need breakeven set before they work properly
   if ((JumpingStop || TrailingStop) && !BreakEven) 
   {
      BreakEven = true;
      if (JumpingStop) BreakEvenPips = JumpingStopPips;
      if (TrailingStop) BreakEvenPips = TrailingStopPips;
   }//if (JumpingStop || TrailingStop) 
   
   //Candlestick js
   if (CandleTrailAfterBreakevenOnly && UseCandlestickTrailingStop)
   {
      BreakEven = true;
      if (CloseEnough(BreakEvenPips, 0) ) BreakEvenPips = 50;
   }//if (CandlestickTrailAfterBreakevenOnly && UseCandlestickTrailingStop)
   
   
   Gap="";
   if (DisplayGapSize >0)
   {
      for (int cc=0; cc< DisplayGapSize; cc++)
      {
         Gap = StringConcatenate(Gap, " ");
      }   
   }//if (DisplayGapSize >0)
   
   //Reset CriminIsECN if crim is IBFX and the punter does not know or, like me, keeps on forgetting
   string name = TerminalCompany();
   int ispart = StringFind(name, "IBFX", 0);
   if (ispart < 0) ispart = StringFind(name, "Interbank FX", 0);
   if (ispart > -1) CriminalIsECN = true;   
   
   	
   if (TradeComment == "") TradeComment = " ";
   OldBarsTime = iTime(NULL, StochTimeFrame, 0);//Force the bot to wait for the new candle before trading, unless EveryTickMode is enabled
   TicketNo = -1;
   ReadIndicatorValues();//For initial display in case user has turned of constant re-display
   GetSwap(Symbol());//This will need editing/removing in a multi-pair ea.
   TradeDirectionBySwap();
   CountOpenTrades();
   OldOpenTrades = OpenTrades;
   GetSetupStatus();//For display
   DisplayUserFeedback();

   
   //Call sq's show trades indi
   //iCustom(NULL, 0, "SQ_showTrades",Magic, 0,0);

   
//----
   return(0);
}
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
{
//----
   Comment("");
//----
   return(0);
}

bool SendSingleTrade(int type, string comment, double lotsize, double price, double stop, double take)
{
   //pah (Paul) contributed the code to get around the trade context busy error. Many thanks, Paul.
   
   double slippage = MaxSlippagePips * MathPow(10, Digits) / PFactor(Symbol());

   
   
   color col = Red;
   if (type == OP_BUY || type == OP_BUYSTOP) col = Green;
   
   int expiry = 0;
   //if (SendPendingTrades) expiry = TimeCurrent() + (PendingExpiryMinutes * 60);

   //RetryCount is declared as 10 in the Trading variables section at the top of this file
   for (int cc = 0; cc < RetryCount; cc++)
   {
      //for (int d = 0; (d < RetryCount) && IsTradeContextBusy(); d++) Sleep(100);

      RefreshRates();
      if (type == OP_BUY) price = NormalizeDouble(Ask, Digits);
      if (type == OP_SELL) price = NormalizeDouble(Bid, Digits);
      
      while(IsTradeContextBusy()) Sleep(100);//Put here so that excess slippage will cancel the trade if the ea has to wait for some time.
      
      if (!CriminalIsECN) int ticket = OrderSend(Symbol(),type, lotsize, price, slippage, stop, take, comment, MagicNumber, expiry, col);
   
   
      //Is a 2 stage criminal
      if (CriminalIsECN)
      {
         ticket = OrderSend(Symbol(),type, lotsize, price, slippage, 0, 0, comment, MagicNumber, expiry, col);
         if (ticket > -1)
         {
	           ModifyOrder(ticket, stop, take);
         }//if (ticket > 0)}
      }//if (CriminalIsECN)
      
      if (ticket > -1) break;//Exit the trade send loop
      if (cc == RetryCount - 1) return(false);
   
      //Error trapping for both
      if (ticket < 0)
      {
         string stype;
         if (type == OP_BUY) stype = "OP_BUY";
         if (type == OP_SELL) stype = "OP_SELL";
         if (type == OP_BUYLIMIT) stype = "OP_BUYLIMIT";
         if (type == OP_SELLLIMIT) stype = "OP_SELLLIMIT";
         if (type == OP_BUYSTOP) stype = "OP_BUYSTOP";
         if (type == OP_SELLSTOP) stype = "OP_SELLSTOP";
         int err=GetLastError();
         Alert(Symbol(), " ", WindowExpertName(), " ", stype," order send failed with error(",err,"): ",ErrorDescription(err));
         Print(Symbol(), " ", WindowExpertName(), " ", stype," order send failed with error(",err,"): ",ErrorDescription(err));
         return(false);
      }//if (ticket < 0)  
   }//for (int cc = 0; cc < RetryCount; cc++);
   
   
   TicketNo = ticket;
   //Make sure the trade has appeared in the platform's history to avoid duplicate trades.
   //My mod of Matt's code attempts to overcome the bastard crim's attempts to overcome Matt's code.
   bool TradeReturnedFromCriminal = false;
   while (!TradeReturnedFromCriminal)
   {
      TradeReturnedFromCriminal = O_R_CheckForHistory(ticket);
      if (!TradeReturnedFromCriminal)
      {
         Alert(Symbol(), " sent trade not in your trade history yet. Turn of this ea NOW.");
      }//if (!TradeReturnedFromCriminal)
   }//while (!TradeReturnedFromCriminal)
   
   //Got this far, so trade send succeeded
   return(true);
   
}//End bool SendSingleTrade(int type, string comment, double lotsize, double price, double stop, double take)

void ModifyOrder(int ticket, double stop, double take)
{
   //Modifies an order already sent if the crim is ECN.

   if (stop == 0 && take == 0) return; //nothing to do

   if (!OrderSelect(ticket, SELECT_BY_TICKET) ) return;//Trade does not exist, so no mod needed
   
   if (OrderCloseTime() > 0) return;//Somehow, we are examining a closed trade
   
   //In case some errant behaviour/code creates a tp the wrong side of the market, which would cause an instant close.
   if (OrderType() == OP_BUY && take < OrderOpenPrice() ) 
   {
      take = 0;
      ReportError(" ModifyOrder()", " take profit < market ");
   }//if (OrderType() == OP_BUY && take < OrderOpenPrice() ) 
   
   if (OrderType() == OP_SELL && take > OrderOpenPrice() ) 
   {
      take = 0;
      ReportError(" ModifyOrder()", " take profit < market ");
   }//if (OrderType() == OP_SELL && take > OrderOpenPrice() ) 
   
   //In case some errant behaviour/code creates a sl the wrong side of the market, which would cause an instant close.
   if (OrderType() == OP_BUY && stop > OrderOpenPrice() ) 
   {
      stop = 0;
      ReportError(" ModifyOrder()", " stop loss > market ");
   }//if (OrderType() == OP_BUY && take < OrderOpenPrice() ) 
   
   if (OrderType() == OP_SELL && stop < OrderOpenPrice() ) 
   {
      stop = 0;
      ReportError(" ModifyOrder()", " stop loss > market ");
   }//if (OrderType() == OP_SELL && take > OrderOpenPrice() ) 
   
   string Reason;
   //RetryCount is declared as 10 in the Trading variables section at the top of this file   
   for (int cc = 0; cc < RetryCount; cc++)
   {
      for (int d = 0; (d < RetryCount) && IsTradeContextBusy(); d++) Sleep(100);
        if (take > 0 && stop > 0)
        {
           while(IsTradeContextBusy()) Sleep(100);
           if (OrderModify(ticket, OrderOpenPrice(), stop, take, OrderExpiration(), CLR_NONE)) return;
           Reason = " TP or SL modification failed with error ";//For error report
        }//if (take > 0 && stop > 0)
   
        if (take != 0 && stop == 0)
        {
           while(IsTradeContextBusy()) Sleep(100);
           if (OrderModify(ticket, OrderOpenPrice(), OrderStopLoss(), take, OrderExpiration(), CLR_NONE)) return;
           Reason = tpm;//For error report
        }//if (take == 0 && stop != 0)

        if (take == 0 && stop != 0)
        {
           while(IsTradeContextBusy()) Sleep(100);
           if (OrderModify(ticket, OrderOpenPrice(), stop, OrderTakeProfit(), OrderExpiration(), CLR_NONE)) return;
           Reason = slm;//For error report
        }//if (take == 0 && stop != 0)
   }//for (int cc = 0; cc < RetryCount; cc++)
   
   //Got this far, so the order modify failed
   ReportError(" ModifyOrder()", Reason);
   
}//void ModifyOrder(int ticket, double tp, double sl)

//=============================================================================
//                           O_R_CheckForHistory()
//
//  This function is to work around a very annoying and dangerous bug in MT4:
//      immediately after you send a trade, the trade may NOT show up in the
//      order history, even though it exists according to ticket number.
//      As a result, EA's which count history to check for trade entries
//      may give many multiple entries, possibly blowing your account!
//
//  This function will take a ticket number and loop until
//  it is seen in the history.
//
//  RETURN VALUE:
//     TRUE if successful, FALSE otherwise
//
//
//  FEATURES:
//     * Re-trying under some error conditions, sleeping a random
//       time defined by an exponential probability distribution.
//
//     * Displays various error messages on the log for debugging.
//
//  ORIGINAL AUTHOR AND DATE:
//     Matt Kennel, 2010
//
//=============================================================================
bool O_R_CheckForHistory(int ticket)
{
   //My thanks to Matt for this code. He also has the undying gratitude of all users of my trading robots
   
   int lastTicket = OrderTicket();

   int cnt = 0;
   int err = GetLastError(); // so we clear the global variable.
   err = 0;
   bool exit_loop = false;
   bool success=false;

   while (!exit_loop) {
      /* loop through open trades */
      int total=OrdersTotal();
      for(int c = 0; c < total; c++) {
         if(OrderSelect(c,SELECT_BY_POS,MODE_TRADES) == true) {
            if (OrderTicket() == ticket) {
               success = true;
               exit_loop = true;
            }
         }
      }
      if (cnt > 3) {
         /* look through history too, as order may have opened and closed immediately */
         total=OrdersHistoryTotal();
         for(c = 0; c < total; c++) {
            if(OrderSelect(c,SELECT_BY_POS,MODE_HISTORY) == true) {
               if (OrderTicket() == ticket) {
                  success = true;
                  exit_loop = true;
               }
            }
         }
      }

      cnt = cnt+1;
      if (cnt > O_R_Setting_max_retries) {
         exit_loop = true;
      }
      if (!(success || exit_loop)) {
         Print("Did not find #"+ticket+" in history, sleeping, then doing retry #"+cnt);
         O_R_Sleep(O_R_Setting_sleep_time, O_R_Setting_sleep_max);
      }
   }
   // Select back the prior ticket num in case caller was using it.
   if (lastTicket >= 0) {
      OrderSelect(lastTicket, SELECT_BY_TICKET, MODE_TRADES);
   }
   if (!success) {
      Print("Never found #"+ticket+" in history! crap!");
   }
   return(success);
}//End bool O_R_CheckForHistory(int ticket)

//=============================================================================
//                              O_R_Sleep()
//
//  This sleeps a random amount of time defined by an exponential
//  probability distribution. The mean time, in Seconds is given
//  in 'mean_time'.
//  This returns immediately if we are backtesting
//  and does not sleep.
//
//=============================================================================
void O_R_Sleep(double mean_time, double max_time)
{
   if (IsTesting()) {
      return;   // return immediately if backtesting.
   }

   double p = (MathRand()+1) / 32768.0;
   double t = -MathLog(p)*mean_time;
   t = MathMin(t,max_time);
   int ms = t*1000;
   if (ms < 10) {
      ms=10;
   }
   Sleep(ms);
}//End void O_R_Sleep(double mean_time, double max_time)


////////////////////////////////////////////////////////////////////////////////////////


bool IsTradingAllowed()
{
   //Returns false if any of the filters should cancel trading, else returns true to allow trading
   
      
   //Maximum spread
   if (!IsDemo() )
   {
      double spread = (Ask - Bid) * factor;
      if (spread > MaxSpread) return(false);
   }//if (!IsDemo() )
   
    
   //An individual currency can only be traded twice, so check for this
   CanTradeThisPair = true;
   if (OnlyTradeCurrencyTwice && OpenTrades == 0)
   {
      IsThisPairTradable();      
   }//if (OnlyTradeCurrencyTwice)
   if (!CanTradeThisPair) return(false);
   
   //Swap filter
   if (OpenTrades == 0) TradeDirectionBySwap();
   
   return(true);


}//End bool IsTradingAllowed()

////////////////////////////////////////////////////////////////////////////////////////
//Balance/swap filters module
void TradeDirectionBySwap()
{

   //Sets TradeLong & TradeShort according to the positive/negative swap it attracts

   //Swap is read in init() and start()


   if (CadPairsPositiveOnly)
   {
      if (StringSubstr(Symbol(), 0, 3) == "CAD" || StringSubstr(Symbol(), 0, 3) == "cad" || StringSubstr(Symbol(), 3, 3) == "CAD" || StringSubstr(Symbol(), 3, 3) == "cad" )      
      {
         if (LongSwap > 0) TradeLong = true;
         else TradeLong = false;
         if (ShortSwap > 0) TradeShort = true;
         else TradeShort = false;         
      }//if (StringSubstr()      
   }//if (CadPairsPositiveOnly)
   
   if (AudPairsPositiveOnly)
   {
      if (StringSubstr(Symbol(), 0, 3) == "AUD" || StringSubstr(Symbol(), 0, 3) == "aud" || StringSubstr(Symbol(), 3, 3) == "AUD" || StringSubstr(Symbol(), 3, 3) == "aud" )      
      {
         if (LongSwap > 0) TradeLong = true;
         else TradeLong = false;
         if (ShortSwap > 0) TradeShort = true;
         else TradeShort = false;         
      }//if (StringSubstr()      
   }//if (AudPairsPositiveOnly)
   
   
   if (NzdPairsPositiveOnly)
   {
      if (StringSubstr(Symbol(), 0, 3) == "NZD" || StringSubstr(Symbol(), 0, 3) == "nzd" || StringSubstr(Symbol(), 3, 3) == "NZD" || StringSubstr(Symbol(), 3, 3) == "nzd" )      
      {
         if (LongSwap > 0) TradeLong = true;
         else TradeLong = false;
         if (ShortSwap > 0) TradeShort = true;
         else TradeShort = false;         
      }//if (StringSubstr()      
   }//if (AudPairsPositiveOnly)
   
   //OnlyTradePositiveSwap filter
   if (OnlyTradePositiveSwap)
   {
      if (LongSwap < 0) TradeLong = false;
      if (ShortSwap < 0) TradeShort = false;      
   }//if (OnlyTradePositiveSwap)
   

}//void TradeDirectionBySwap()

bool IsThisPairTradable()
{
   //Checks to see if either of the currencies in the pair is already being traded twice.
   //If not, then return true to show that the pair can be traded, else return false
   
   string c1 = StringSubstr(Symbol(), 0, 3);//First currency in the pair
   string c2 = StringSubstr(Symbol(), 3, 3);//Second currency in the pair
   int c1open = 0, c2open = 0;
   CanTradeThisPair = true;
   for (int cc = OrdersTotal() - 1; cc >= 0; cc--)
   {
      if (!OrderSelect(cc, SELECT_BY_POS) ) continue;
      if (OrderSymbol() != Symbol() ) continue;
      if (OrderMagicNumber() != MagicNumber) continue;
      int index = StringFind(OrderSymbol(), c1);
      if (index > -1)
      {
         c1open++;         
      }//if (index > -1)
   
      index = StringFind(OrderSymbol(), c2);
      if (index > -1)
      {
         c2open++;         
      }//if (index > -1)
   
      if (c1open == 1 && c2open == 1) 
      {
         CanTradeThisPair = false;
         return(false);   
      }//if (c1open == 1 && c2open == 1) 
   }//for (int cc = OrdersTotal() - 1; cc >= 0; cc--)

   //Got this far, so ok to trade
   return(true);
   
}//End bool IsThisPairTradable()

bool BalancedPair(int type)
{

   //Only allow an individual currency to trade if it is a balanced trade
   //e.g. UJ Buy open, so only allow Sell xxxJPY.
   //The passed parameter is the proposed trade, so an existing one must balance that

   //This code courtesy of Zeljko (zkucera) who has my grateful appreciation.
   
   string BuyCcy1, SellCcy1, BuyCcy2, SellCcy2;

   if (type == OP_BUY || type == OP_BUYSTOP)
   {
      BuyCcy1 = StringSubstr(Symbol(), 0, 3);
      SellCcy1 = StringSubstr(Symbol(), 3, 3);
   }//if (type == OP_BUY || type == OP_BUYSTOP)
   else
   {
      BuyCcy1 = StringSubstr(Symbol(), 3, 3);
      SellCcy1 = StringSubstr(Symbol(), 0, 3);
   }//else

   for (int cc = OrdersTotal() - 1; cc >= 0; cc--)
   {
      if (!OrderSelect(cc, SELECT_BY_POS)) continue;
      if (OrderSymbol() == Symbol()) continue;
      if (OrderMagicNumber() != MagicNumber) continue;      
      if (OrderType() == OP_BUY || OrderType() == OP_BUYSTOP)
      {
         BuyCcy2 = StringSubstr(OrderSymbol(), 0, 3);
         SellCcy2 = StringSubstr(OrderSymbol(), 3, 3);
      }//if (OrderType() == OP_BUY || OrderType() == OP_BUYSTOP)
      else
      {
         BuyCcy2 = StringSubstr(OrderSymbol(), 3, 3);
         SellCcy2 = StringSubstr(OrderSymbol(), 0, 3);
      }//else
      if (BuyCcy1 == BuyCcy2 || SellCcy1 == SellCcy2) return(false);
   }//for (int cc = OrdersTotal() - 1; cc >= 0; cc--)

   //Got this far, so it is ok to send the trade
   return(true);

}//End bool BalancedPair(int type)



//End Balance/swap filters module
////////////////////////////////////////////////////////////////////////////////////////
double CalculateLotSize(double price1, double price2)
{
   //Calculate the lot size by risk. Code kindly supplied by jmw1970. Nice one jmw.
   
   if (price1 == 0 || price2 == 0) return(Lot);//Just in case
   
   double FreeMargin = AccountFreeMargin();
   double TickValue = MarketInfo(Symbol(),MODE_TICKVALUE) ;
   double LotStep = MarketInfo(Symbol(),MODE_LOTSTEP);


   double SLPts = MathAbs(price1 - price2);
   SLPts/= Point;//No idea why *= factor does not work here, but it doesn't
   
   double Exposure = SLPts * TickValue; // Exposure based on 1 full lot

   double AllowedExposure = (FreeMargin * RiskPercent) / 100;
   
   int TotalSteps = ((AllowedExposure / Exposure) / LotStep);
   double LotSize = TotalSteps * LotStep;

   double MinLots = MarketInfo(Symbol(), MODE_MINLOT);
   double MaxLots = MarketInfo(Symbol(), MODE_MAXLOT);
   
   if (LotSize < MinLots) LotSize = MinLots;
   if (LotSize > MaxLots) LotSize = MaxLots;
   return(LotSize);

}//double CalculateLotSize(double price1, double price1)

double CalculateStopLoss(int type)
{
   //Returns the stop loss for use in LookForTradingOpps and InsertMissingStopLoss
   double stop, price;

   RefreshRates();
   
   if (type == OP_BUY)
   {
      price = Ask;
      if (!CloseEnough(StopLoss, 0) )
      {
         stop = price - (StopLoss / factor);
         HiddenStopLoss = stop;
      }//if (!CloseEnough(StopLoss, 0) )

      
      if (HiddenPips > 0 && stop > 0) stop = NormalizeDouble(stop - (HiddenPips / factor), Digits);
   }//if (type == OP_BUY)
   
   if (type == OP_SELL)
   {
      price = Bid;
      if (!CloseEnough(StopLoss, 0) )
      {
         stop = price + (StopLoss / factor);
         HiddenStopLoss = stop;         
      }//if (!CloseEnough(StopLoss, 0) )
      
      if (HiddenPips > 0 && stop > 0) stop = NormalizeDouble(stop + (HiddenPips / factor), Digits);

   }//if (type == OP_SELL)
   
   return(stop);
   
}//End double CalculateStopLoss(int type)

double CalculateTakeProfit(int type)
{
   //Returns the stop loss for use in LookForTradingOpps and InsertMissingStopLoss
   double take, price;

   RefreshRates();
   
   if (type == OP_BUY)
   {
      price = Ask;
      if (!CloseEnough(TakeProfit, 0) )
      {
         take = price + (TakeProfit / factor);
         HiddenTakeProfit = take;
      }//if (!CloseEnough(TakeProfit, 0) )

         
      if (HiddenPips > 0 && take > 0) take = NormalizeDouble(take + (HiddenPips / factor), Digits);

   }//if (type == OP_BUY)
   
   if (type == OP_SELL)
   {
      price = Bid;
      if (!CloseEnough(TakeProfit, 0) )
      {
         take = price - (TakeProfit / factor);
         HiddenTakeProfit = take;         
      }//if (!CloseEnough(TakeProfit, 0) )
      

      if (HiddenPips > 0 && take > 0) take = NormalizeDouble(take - (HiddenPips / factor), Digits);

   }//if (type == OP_SELL)
   
   return(take);
   
}//End double CalculateTakeProfit(int type)

bool LookForLongSetup()
{
   //Examine the conditions for a long setup
   double v;
   bool status = true;
   if (!Option1 && !Option2) return(false);//Idiot check. You never know.
   
   //Option1;//Setup yesterday, trigger the first tick of the new candle
   if (Option1)
   {
      v = iStochastic(NULL, StochTimeFrame,K_Period,D_Period,Slowing,MaMethod,PriceField,MODE_MAIN,1);
      if (v > OverSold) status = false;
      
      v = iStochastic(NULL, StochTimeFrame,K_Period,D_Period,Slowing,MaMethod,PriceField,MODE_SIGNAL,1);
      if (v > OverSold) status = false;
   }//if (Option1)

   //Option2;////ob/os Close[2]: out of ob/os Close[1]: still out of ob/os Open[0];
   if (Option2 && (!status || !Option1))
   {
      status = true;
      v = iStochastic(NULL, StochTimeFrame,K_Period,D_Period,Slowing,MaMethod,PriceField,MODE_MAIN,1);
      if (v <= OverSold) status = false;
      
      v = iStochastic(NULL, StochTimeFrame,K_Period,D_Period,Slowing,MaMethod,PriceField,MODE_SIGNAL,1);
      if (v <= OverSold) status = false;

      v = iStochastic(NULL, StochTimeFrame,K_Period,D_Period,Slowing,MaMethod,PriceField,MODE_MAIN,2);
      if (v > OverSold) status = false;
      
      v = iStochastic(NULL, StochTimeFrame,K_Period,D_Period,Slowing,MaMethod,PriceField,MODE_SIGNAL,2);
      if (v > OverSold) status = false;
   }//if (Option2)


   
   //Got this far, so there is a long setup
   return(status);

}//End bool LookForLongSetup()

bool LookForShortSetup()
{
   //Examine the conditions for a long setup

   double v;
   bool status = true;
   if (!Option1 && !Option2) return(false);//Idiot check. You never know.
   
   //Option1;//Setup yesterday, trigger the first tick of the new candle
   if (Option1)
   {
      v = iStochastic(NULL, StochTimeFrame,K_Period,D_Period,Slowing,MaMethod,PriceField,MODE_MAIN,1);
      if (v < OverBought) status = false;
      
      v = iStochastic(NULL, StochTimeFrame,K_Period,D_Period,Slowing,MaMethod,PriceField,MODE_SIGNAL,1);
      if (v < OverBought) status = false;
   }//if (Option1)

   //Option2;////ob/os Close[2]: out of ob/os Close[1]: still out of ob/os Open[0];
   if (Option2 && (!status || !Option1))
   {
      status = true;
      v = iStochastic(NULL, StochTimeFrame,K_Period,D_Period,Slowing,MaMethod,PriceField,MODE_MAIN,1);
      if (v > OverBought) status = false;
      
      v = iStochastic(NULL, StochTimeFrame,K_Period,D_Period,Slowing,MaMethod,PriceField,MODE_SIGNAL,1);
      if (v > OverBought) status = false;

      v = iStochastic(NULL, StochTimeFrame,K_Period,D_Period,Slowing,MaMethod,PriceField,MODE_MAIN,2);
      if (v < OverBought) status = false;
      
      v = iStochastic(NULL, StochTimeFrame,K_Period,D_Period,Slowing,MaMethod,PriceField,MODE_SIGNAL,2);
      if (v < OverBought) status = false;
   }//if (Option2)


   
   //Got this far, so there is a long setup
   return(status);

}//End bool LookForShortSetup()

void LookForTradingOpportunities()
{

   RefreshRates();
   double take, stop, price;
   int type;
   string stype;//For the alert
   bool SendTrade = false, result = false;

   double SendLots = Lot;
   //Check filters
   if (!IsTradingAllowed() ) return;
   
   //Cannot trade without a stoch setup
   if (TradeSetupStatus == nosetup) return;
   //Cannot trade if stoch is ob/os
   if ((StochMain < OverSold || StochMain > OverBought) || (StochSignal < OverSold || StochSignal > OverBought)) return;
   /////////////////////////////////////////////////////////////////////////////////////
   
   //Trading decision.
   //Examine the filters one by one.
   //Work on the basis that a failed filter turns off SendLong/Short
   bool SendLong = false, SendShort = false;

   //Long trade
   if (LookForLongSetup() )
   {
      SendLong = true;
      
      //User choice of trade direction
      if (!TradeLong) SendLong = false;

      //Other filters
      //Slope must be in the buy area
      if (HtfTimeFrame > 0 && HtfSlopeVal < HtfBuyOnlyLevel) SendLong = false;
      if (LtfTimeFrame > 0 && LtfSlopeVal < LtfBuyOnlyLevel) SendLong = false;
      
      if (UseZeljko && !BalancedPair(OP_BUY) ) SendLong = false;
      
      //Stoch must be > LongTradeTrigger
      if (StochMain <= LongTradeTrigger) SendLong = false;
      if (StochSignal <= LongTradeTrigger) SendLong = false;
      
      
      //Change of market state - explanation at the end of start()
      //if (OldAsk <= some_condition) SendLong = false;   
   }//if (LookForLongSetup() )
      
   if (SendLong) SendShort = false;
   /////////////////////////////////////////////////////////////////////////////////////

   if (!SendLong)
   {
      if (LookForShortSetup() )
      {
         SendShort = true;

         //Short trade
         //Usual filters

         //User choice of trade direction
         if (!TradeShort) SendShort = false;
         
         //Other filters
         //Slope must be in the sell area
         if (HtfTimeFrame > 0 && HtfSlopeVal > HtfSellOnlyLevel) SendShort = false;
         if (LtfTimeFrame > 0 && LtfSlopeVal > LtfSellOnlyLevel) SendShort = false;
         
         if (UseZeljko && !BalancedPair(OP_SELL) ) SendShort = false;

         //Stoch must be < overbought
         if (StochMain >= ShortTradeTrigger) SendShort = false;
         if (StochSignal >= ShortTradeTrigger) SendShort = false;

         //Change of market state - explanation at the end of start()
         //if (OldBid += some_condition) SendShort = false;   
      }//if (LookForShortSetup() )
      
}//if (!SendLong)
     
   
   //Long 
   if (SendLong)
   {
       
      stype = " Buy ";
      
      if (!SendAlertNotTrade)
      {
         //Got this far, so there is going to be a trade send of some sort. Setting up price here makes
         //this code most easily adaptable to easy alteration
         price = Ask;//Change this to whatever the price needs to be
         
         
         take = CalculateTakeProfit(OP_BUY);
         
         stop = CalculateStopLoss(OP_BUY);
         
         
         //Lot size calculated by risk
         if (RiskPercent > 0) SendLots = CalculateLotSize(price, NormalizeDouble(stop, Digits) );

         type = OP_BUY;
         
      }//if (!SendAlertNotTrade)
      
      SendTrade = true;
      
}//if (SendLong)
   
   //Short
   if (SendShort)
   {
      stype = " Sell ";
      
      if (!SendAlertNotTrade)
      {
         //Got this far, so there is going to be a trade send of some sort. Setting up price here makes
         //this code most easily adaptable to easy alteration
         price = Bid;//Change this to whatever the price needs to be

         take = CalculateTakeProfit(OP_SELL);
         
         stop = CalculateStopLoss(OP_SELL);
         
         
         //Lot size calculated by risk
         if (RiskPercent > 0) SendLots = CalculateLotSize(NormalizeDouble(stop, Digits), price);
         
         type = OP_SELL;
      }//if (!SendAlertNotTrade)
         
      SendTrade = true;      
   
      
   }//if (SendShort)
   

   if (SendTrade)
   {
      if (!SendAlertNotTrade) 
      { 
         result = SendSingleTrade(type, TradeComment, SendLots, price, stop, take);
         if (result && EmailTradeNotification) SendMail("Trade sent ", Symbol() + stype + "trade at " + TimeToStr(TimeCurrent(), TIME_DATE|TIME_MINUTES));
      }//if (!SendAlertNotTrade) 
      
      if (SendAlertNotTrade && !AlertSent)
      {
         Alert(WindowExpertName(), " ", Symbol(), " ", stype, "trade has triggered. ",  TimeToStr(TimeLocal(), TIME_DATE|TIME_MINUTES|TIME_SECONDS) );
         SendMail("Trade alert. ", Symbol() + " " + stype + " trade has triggered. " +  TimeToStr(TimeLocal(), TIME_DATE|TIME_MINUTES|TIME_SECONDS ));
         AlertSent=true;
       }//if (SendAlertNotTrade && !AlertSent)
   }//if (SendTrade)
   
   //Actions when trade send succeeds
   if (SendTrade && result)
   {      
      if (!SendAlertNotTrade && HiddenPips > 0) ReplaceMissingSlTpLines();
   }//if (result)
   
   //Actions when trade send fails
   if (SendTrade && !result)
   {
      OldBarsTime = 0;
   }//if (!result)
   
   
   

}//void LookForTradingOpportunities()


bool CloseTrade(int ticket)
{   
   while(IsTradeContextBusy()) Sleep(100);
   bool result = OrderClose(ticket, OrderLots(), OrderClosePrice(), 1000, CLR_NONE);

   //Actions when trade send succeeds
   if (result)
   {
      return(true);
   }//if (result)
   
   //Actions when trade send fails
   if (!result)
   {
      ReportError(" CloseTrade()", ocm);
      return(false);
   }//if (!result)
   

}//End bool CloseTrade(ticket)

////////////////////////////////////////////////////////////////////////////////////////
//Indicator module


void CalculateDailyResult()
{
   //Calculate the no of winners and losers from today's trading. These are held in the history tab.

   LossTrades = 0;
   WinTrades = 0;
   OverallProfit = 0;
   
   
   for (int cc = 0; cc <= OrdersHistoryTotal(); cc++)
   {
      if (!OrderSelect(cc, SELECT_BY_POS, MODE_HISTORY) ) continue;
      if (OrderSymbol() != Symbol() ) continue;
      if (OrderMagicNumber() != MagicNumber) continue;
      
      OverallProfit+= (OrderProfit() + OrderSwap() + OrderCommission() );
      if (OrderProfit() > 0) WinTrades++;
      if (OrderProfit() < 0) LossTrades++;
   }//for (int cc = 0; cc <= tot -1; cc++)
   
   

}//End void CalculateDailyResult()

    //+------------------------------------------------------------------+
    //| GetSlope()                                                       |
    //+------------------------------------------------------------------+
    double GetSlope(string symbol, int tf, int shift)
    {
       double atr = iATR(symbol, tf, 100, shift + 10) / 10;
       double gadblSlope = 0.0;
       if ( atr != 0 )
       {
          double dblTma = calcTma( symbol, tf, shift );
          double dblPrev = calcTma( symbol, tf, shift + 1 );
          gadblSlope = ( dblTma - dblPrev ) / atr;
       }
       
       return ( gadblSlope );

    }

    //+------------------------------------------------------------------+
    //| calcTma()                                                        |
    //+------------------------------------------------------------------+
    double calcTma( string symbol, int tf,  int shift )
    {
       double dblSum  = iClose(symbol, tf, shift) * 21;
       double dblSumw = 21;
       int jnx, knx;
             
       for ( jnx = 1, knx = 20; jnx <= 20; jnx++, knx-- )
       {
          dblSum  += ( knx * iClose(symbol, tf, shift + jnx) );
          dblSumw += knx;

          if ( jnx <= shift )
          {
             dblSum  += ( knx * iClose(symbol, tf, shift - jnx) );
             dblSumw += knx;
          }
       }
       
       return( dblSum / dblSumw );

    }

void GetStoch(int shift)
{

   StochMain = iStochastic(NULL, StochTimeFrame,K_Period,D_Period,Slowing,MaMethod,PriceField,MODE_MAIN,0);
   StochSignal = iStochastic(NULL, StochTimeFrame,K_Period,D_Period,Slowing,MaMethod,PriceField,MODE_SIGNAL,0);
	
}//End void GetStoch();

void GetSetupStatus()
{

   TradeSetupStatus = nosetup;
   if (LookForLongSetup() ) TradeSetupStatus = longsetup;
   if (LookForShortSetup() ) TradeSetupStatus = shortsetup;
   
   
}//End void GetSetuoStatus()

void ReadIndicatorValues()
{
   
   //Stochastic
   GetStoch(0);

   //Slope.
   //Delete whichever lines are not required by the program you are coding.
   static datetime OldHtfBarTime;
   static datetime OldLtfBarTime;
   
   if (HtfTimeFrame > 0)
   {
      HtfSlopeVal = GetSlope(Symbol(), HtfTimeFrame, 0);
      //~ HtfSlopeTrend = ranging;
      //~ if (HtfSlopeVal >= HtfBuyOnlyLevel) HtfSlopeTrend = buyonly;
      //~ if (HtfSlopeVal >= HtfBuyHoldLevel) HtfSlopeTrend = buyhold;
      //~ if (HtfSlopeVal <= HtfSellOnlyLevel) HtfSlopeTrend = sellonly;
      //~ if (HtfSlopeVal <= HtfSellHoldLevel) HtfSlopeTrend = sellhold;
   
      //~ if (OldHtfBarTime != iTime(NULL, HtfTimeFrame, 0) )
      //~ {
         //~ PrevHtfSlopeVal = GetSlope(Symbol(), HtfTimeFrame, 1);
         //~ OldHtfBarTime = iTime(NULL, HtfTimeFrame, 0);
      //~ }//if (OldBarTime != iTime(NULL, HtfTimeFrame, 0)
      
      
      //~ HtfSlopeAngle = unchanged;
      //~ if (HtfSlopeVal > PrevHtfSlopeVal) HtfSlopeAngle = rising;
      //~ if (HtfSlopeVal < PrevHtfSlopeVal) HtfSlopeAngle = falling;      
   }//IF (HtfTimeFrame > 0)

   if (LtfTimeFrame > 0)
   {
      LtfSlopeVal = GetSlope(Symbol(), LtfTimeFrame, 0);
      //~ LtfSlopeTrend = ranging;
      //~ if (LtfSlopeVal >= LtfBuyOnlyLevel) LtfSlopeTrend = buyonly;
      //~ if (LtfSlopeVal >= LtfBuyHoldLevel) LtfSlopeTrend = buyhold;
      //~ if (LtfSlopeVal <= LtfSellOnlyLevel) LtfSlopeTrend = sellonly;
      //~ if (LtfSlopeVal <= LtfSellHoldLevel) LtfSlopeTrend = sellhold;
   
      //~ if (OldLtfBarTime != iTime(NULL, LtfTimeFrame, 0) )
      //~ {
         //~ PrevLtfSlopeVal = GetSlope(Symbol(), LtfTimeFrame, 1);
         //~ OldLtfBarTime = iTime(NULL, LtfTimeFrame, 0);
      //~ }//if (OldBarTime != iTime(NULL, HtfTimeFrame, 0)
         
      //~ LtfSlopeAngle = unchanged;
      //~ if (LtfSlopeVal > PrevLtfSlopeVal) LtfSlopeAngle = rising;
      //~ if (LtfSlopeVal < PrevLtfSlopeVal) LtfSlopeAngle = falling;      
   }//if (LtfTimeFrame > 0)
   
      
}//void ReadIndicatorValues()

//End Indicator module
////////////////////////////////////////////////////////////////////////////////////////

bool LookForTradeClosure(int ticket, bool CheckStoch)
{
   //Close the trade if the close conditions are met.
   //Called from within CountOpenTrades(). Returns true if a close is needed and succeeds, so that COT can increment cc,
   //else returns false
   
   ForceTradeClosure = false;//To force a rety of a stoch recross close fails
   
   if (!OrderSelect(ticket, SELECT_BY_TICKET) ) return(true);
   if (OrderSelect(ticket, SELECT_BY_TICKET) && OrderCloseTime() > 0) return(true);
   
   bool CloseThisTrade;
   if (CheckStoch) GetStoch(0);//Only need to re-read stoch at the open of a new candle
   string LineName = TpPrefix + DoubleToStr(ticket, 0);
   //Work with the lines on the chart that represent the hidden tp/sl
   double take = ObjectGet(LineName, OBJPROP_PRICE1);
   LineName = SlPrefix + DoubleToStr(ticket, 0);
   double stop = ObjectGet(LineName, OBJPROP_PRICE1);
   if (CloseEnough(stop, 0) ) stop = OrderStopLoss();
   
   //Is this a high-swap pair?
   bool IsHighSwap = false;
   if (StringFind(OrderSymbol(), "AUD") > -1 || StringFind(OrderSymbol(), "aud") > -1  ) IsHighSwap = true;
   if (StringFind(OrderSymbol(), "CAD") > -1 || StringFind(OrderSymbol(), "cad") > -1  ) IsHighSwap = true;
   if (StringFind(OrderSymbol(), "NZD") > -1 || StringFind(OrderSymbol(), "nzd") > -1  ) IsHighSwap = true;
   
   if (OrderType() == OP_BUY)
   {
      //TP
      if (Bid >= take && !CloseEnough(take, 0) ) CloseThisTrade = true;
      //SL
      if (Bid <= stop && !CloseEnough(stop, 0) ) CloseThisTrade = true;

      //Stoch recross of Signal by Main, if price is not at BE
      if (CheckStoch && stop < OrderOpenPrice() && StochMain < StochSignal) 
      {
         if (!KeepOpenPositiveSwapLosers) CloseThisTrade = true;
         if (KeepOpenPositiveSwapLosers && LongSwap < 0) CloseThisTrade = true;
         //Users can elect to keep open a positive high-swap loser, but close it if the pair is not high swap
         if (KeepOpenPositiveSwapLosers && LongSwap > 0 && !IsHighSwap) CloseThisTrade = true;
      }//if (CheckStoch && stop < OrderOpenPrice() && StochMain < StochSignal) 
      
      //~ //Slope closures
      //~ if (HtfTimeFrame > 0)
      //~ {
         //~ if (HtfSlopeVal <= HtfBuyCloseLevel)  CloseThisTrade = true;            
      //~ }//if (HtfTimeFrame > 0)
      
      //~ if (LtfTimeFrame > 0)
      //~ {
         //~ if (LtfSlopeVal <= LtfBuyCloseLevel)  CloseThisTrade = true;            
      //~ }//if (LtfTimeFrame > 0)

   }//if (OrderType() == OP_BUY)
   
   
   if (OrderType() == OP_SELL)
   {
      //TP
      if (Bid <= take && !CloseEnough(take, 0) ) CloseThisTrade = true;
      //SL
      if (Bid >= stop && !CloseEnough(stop, 0) ) CloseThisTrade = true;

      //Stoch recross of Signal by Main, if price is not at BE
      if (CheckStoch && (stop > OrderOpenPrice() || CloseEnough(stop, 0) ) && StochMain > StochSignal) 
      {
         if (!KeepOpenPositiveSwapLosers) CloseThisTrade = true;
         if (KeepOpenPositiveSwapLosers && ShortSwap < 0) CloseThisTrade = true;
         //Users can elect to keep open a positive high-swap loser, but close it if the pair is not high swap
         if (KeepOpenPositiveSwapLosers && ShortSwap > 0 && !IsHighSwap) CloseThisTrade = true;
      }//if (CheckStoch && (stop > OrderOpenPrice() || CloseEnough(stop, 0) ) && StochMain
      //~ //Slope closures
      //~ if (HtfTimeFrame > 0)
      //~ {
         //~ if (HtfSlopeVal >= HtfSellCloseLevel)  CloseThisTrade = true;            
      //~ }//if (HtfTimeFrame > 0)
      
      //~ if (LtfTimeFrame > 0)
      //~ {
         //~ if (LtfSlopeVal >= LtfSellCloseLevel)  CloseThisTrade = true;            
      //~ }//if (LtfTimeFrame > 0)

   }//if (OrderType() == OP_SELL)
   
   if (CloseThisTrade)
   {
      bool result = CloseTrade(ticket);
      //Actions when trade close succeeds
      if (result)
      {
         DeletePendingPriceLines();
         TicketNo = -1;//TicketNo is the most recently trade opened, so this might need editing in a multi-trade EA
         OpenTrades--;//Rather than OpenTrades = 0 to cater for multi-trade EA's
         return(true);//Makes CountOpenTrades increment cc to avoid missing out ccounting a trade
      }//if (result)
   
      //Actions when trade close fails
      if (!result)
      {
         ForceTradeClosure = true;
         return(false);//Do not increment cc
      }//if (!result)
   }//if (CloseThisTrade)
   
   //Got this far, so no trade closure
   return(false);//Do not increment cc
   
}//End bool LookForTradeClosure()

void CloseAllTrades()
{
   ForceTradeClosure= false;
   
   if (OrdersTotal() == 0) return;
   
   for (int cc = OrdersTotal() - 1; cc >= 0; cc--)
   {
      if (!OrderSelect(cc, SELECT_BY_POS) ) continue;
      if (OrderMagicNumber() != MagicNumber) continue;
      if (OrderSymbol() != Symbol() ) continue;
      while(IsTradeContextBusy()) Sleep(100);
      if (OrderType() == OP_BUY || OrderType() == OP_SELL) bool result = OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), 1000, CLR_NONE);
      if (result) cc++;
      if (!result) ForceTradeClosure= true;
      
   }//for (int cc = OrdersTotal() - 1; cc >= 0; cc--)

   //If full closure succeeded, then allow new trading
   if (!ForceTradeClosure) 
   {
      OpenTrades = 0;
      BuyOpen = false;
      SellOpen = false;
   }//if (!ForceTradeClosure) 

}//End void CloseAllTrades()

void CountOpenTrades()
{
   //Not all these will be needed. Which ones are depends on the individual EA.
   OpenTrades = 0;
   TicketNo = -1;
   BuyOpen = false;
   SellOpen = false;
   PendingBuyOpen = false;
   PendingSellOpen = false;
   int type;//Saves the OrderType() for consulatation later in the function
   
   upl = 0;//Unrealised profit and loss for hedging/recovery basket closure decisions

   if (OrdersTotal() == 0) return;
   
   //Iterating backwards through the orders list caters more easily for closed trades than iterating forwards
   for (int cc = OrdersTotal() - 1; cc >= 0; cc--)
   {
      bool TradeWasClosed = false;//See 'check for possible trade closure'

      //Ensure the trade is still open
      if (!OrderSelect(cc, SELECT_BY_POS, MODE_TRADES) ) continue;
      //Ensure the EA 'owns' this trade
      if (OrderSymbol() != Symbol() ) continue;
      if (OrderMagicNumber() != MagicNumber) continue;
      if (OrderCloseTime() > 0) continue;
      
      //All conditions passed, so carry on
      type = OrderType();//Store the order type
      
      OpenTrades++;
      //Store the latest trade sent. Most of my EA's only need this final ticket number as either they are single trade
      //bots or the last trade in the sequence is the important one. Adapt this code for your own use.
      if (TicketNo  == -1) TicketNo = OrderTicket();
      
      //upl might not be needed. Depends on the individual EA
      upl+= (OrderProfit() + OrderSwap() + OrderCommission()); 
      //The next line of code calculates the pips upl of an open trade. As yet, I have done nothing with it.
      //something = CalculateTradeProfitInPips()
      
      //Trade types
      bool success;
      if (OrderType() == OP_BUY) 
      {
         BuyOpen = true;
         if (HalfCloseEnabled && OrderLots() == Lot && OrderStopLoss() >= OrderOpenPrice() ) success = HalfCloseTrade();
      }//if (OrderType() == OP_BUY) 
      
      if (OrderType() == OP_SELL) 
      {
         SellOpen = true;
         if (HalfCloseEnabled && OrderLots() == Lot && OrderStopLoss() <= OrderOpenPrice()  && !CloseEnough(OrderStopLoss(), 0)) success = HalfCloseTrade();
      }//if (OrderType() == OP_SELL) 
      
      //Add missing tp/sl in case rapidly moving markets prevent their addition - ECN
      if (OrderStopLoss() == 0 && !CloseEnough(StopLoss, 0)) InsertStopLoss(TicketNo);
      if (OrderTakeProfit() == 0 && !CloseEnough(TakeProfit, 0)) InsertTakeProfit(TicketNo);

      //Replace missing tp and sl lines
      if (HiddenPips > 0) ReplaceMissingSlTpLines();
      
      //Possible trade closure
      if (OldBarsTime == iTime(NULL, StochTimeFrame, 0) ) TradeWasClosed = LookForTradeClosure(OrderTicket(), false);
      if (OldBarsTime != iTime(NULL, StochTimeFrame, 0) ) TradeWasClosed = LookForTradeClosure(OrderTicket(), true);
      if (TradeWasClosed) 
      {
         if (type == OP_BUY) BuyOpen = false;//Will be reset if subsequent trades are buys that are not closed
         if (type == OP_SELL) SellOpen = false;//Will be reset if subsequent trades are sells that are not closed
         cc++;
      }//if (TradeWasClosed) 
         
      //Profitable trade management
      if (OrderProfit() > 0 && !TradeWasClosed) 
      {
         double PartLot = Lot / 3;
         if (OrderLots() > PartLot && EnablePartClosure)
         {
            TradeManagementModule();//This will move the stop to BE come what may
            //pp = pips profit
            double pp = CalculateTradeProfitInPips(OrderType() );
            if (pp >= BreakEvenPips && pp < (JumpingStopPips * 2) && OrderLots() == Lot) PartCloseThisTrade();
            if (pp >= (JumpingStopPips * 2) && OrderLots() > PartLot) PartCloseThisTrade();
             
            //This snippet is to take care of the situation where the stop has been moved to BE but the part-close failed. Then the market retraced, so the part-close was not attempted again.
            if (OrderType() == OP_BUY && OrderStopLoss() >= OrderOpenPrice() && OrderLots() == Lot)
            {
               PartCloseThisTrade();
            }//if (OrderType() == OP_BUY)
             
            if (OrderType() == OP_SELL && (OrderStopLoss() <= OrderOpenPrice() && !CloseEnough(OrderStopLoss(), 0) ) && OrderLots() == Lot)
            {
               PartCloseThisTrade();
            }//if (OrderType() == OP_SELL)
          
             //This snippet is to take care of the same situation but following the first jumping stop, when the second third of the trade should have   closed. This is all a bit messy, so if someone can see a better way of coding all this, then please do sing out.
            if (OrderType() == OP_BUY && OrderStopLoss() >= OrderOpenPrice() + (BreakEvenProfit / factor) + JumpingStopPips && OrderLots() > PartLot)
            {
               PartCloseThisTrade();
            }//if (OrderType() == OP_BUY && OrderStopLoss() >= OrderOpenPrice() 
            
            if (OrderType() == OP_SELL && (OrderStopLoss() <= OrderOpenPrice() - (BreakEvenProfit / factor) - JumpingStopPips  && !CloseEnough(OrderStopLoss(), 0) ) && OrderLots() > PartLot)
            {
               PartCloseThisTrade();
            }//if (OrderType() == OP_BUY && OrderStopLoss() >= OrderOpenPrice() 
         }//if (OrderLots() > PartLot && EnablePartClosure)  
         else TradeManagementModule();//This deals with subsequent jumping/trailing stops once part-close has already taken place
      }//if (OrderProfit() > 0 && !TradeWasClosed) 

   }//for (int cc = OrdersTotal() - 1; cc <= 0; c`c--)
   
   
   
}//End void CountOpenTrades();
void PartCloseThisTrade()
{
   //Called from CountOpenTrades() to close one third of the trade at Breakeven, then at the first subsequent jumping stop
   
   double PartLot = Lot / 3;
   bool result = OrderClose(OrderTicket(), PartLot, OrderClosePrice(), 1000, Blue);
   if (!result) ReportError(" PartCloseThisTrade() ", pcm);
}//void PartCloseThisTrade()

void InsertStopLoss(int ticket)
{
   //Inserts a stop loss if the ECN crim managed to swindle the original trade out of the modification at trade send time
   //Called from CountOpenTrades() if StopLoss > 0 && OrderStopLoss() == 0.
   
   if (!OrderSelect(ticket, SELECT_BY_TICKET)) return;
   if (OrderCloseTime() > 0) return;//Somehow, we are examining a closed trade
   if (OrderStopLoss() > 0) return;//Function called unnecessarily.
   
   while(IsTradeContextBusy()) Sleep(100);
   
   double stop;
   
   if (OrderType() == OP_BUY)
   {
      stop = CalculateStopLoss(OP_BUY);
   }//if (OrderType() == OP_BUY)
   
   if (OrderType() == OP_SELL)
   {
      stop = CalculateStopLoss(OP_SELL);
   }//if (OrderType() == OP_SELL)
   
   if (CloseEnough(stop, 0) ) return;
   
   //In case some errant behaviour/code creates a sl the wrong side of the market, which would cause an instant close.
   if (OrderType() == OP_BUY && stop > OrderOpenPrice() ) 
   {
      stop = 0;
      ReportError(" InsertStopLoss()", " stop loss > market ");
   }//if (OrderType() == OP_BUY && take < OrderOpenPrice() ) 
   
   if (OrderType() == OP_SELL && stop < OrderOpenPrice() ) 
   {
      stop = 0;
      ReportError(" InsertStopLoss()", " stop loss > market ");
   }//if (OrderType() == OP_SELL && take > OrderOpenPrice() ) 

   
   OrderModify(ticket, OrderOpenPrice(), stop, OrderTakeProfit(), OrderExpiration(), CLR_NONE);

}//End void InsertStopLoss(int ticket)

void InsertTakeProfit(int ticket)
{
   //Inserts a TP if the ECN crim managed to swindle the original trade out of the modification at trade send time
   //Called from CountOpenTrades() if TakeProfit > 0 && OrderTakeProfit() == 0.
   
   if (!OrderSelect(ticket, SELECT_BY_TICKET)) return;
   if (OrderCloseTime() > 0) return;//Somehow, we are examining a closed trade
   if (OrderTakeProfit() > 0) return;//Function called unnecessarily.
   
   while(IsTradeContextBusy()) Sleep(100);
   
   double take;
   
   if (OrderType() == OP_BUY)
   {
      take = CalculateTakeProfit(OP_BUY);
   }//if (OrderType() == OP_BUY)
   
   if (OrderType() == OP_SELL)
   {
      take = CalculateTakeProfit(OP_SELL);
   }//if (OrderType() == OP_SELL)
   
   if (CloseEnough(take, 0) ) return;
   
   //In case some errant behaviour/code creates a tp the wrong side of the market, which would cause an instant close.
   if (OrderType() == OP_BUY && take < OrderOpenPrice() ) 
   {
      take = 0;
      ReportError(" InsertTakeProfit()", " take profit < market ");
      return;
   }//if (OrderType() == OP_BUY && take < OrderOpenPrice() ) 
   
   if (OrderType() == OP_SELL && take > OrderOpenPrice() ) 
   {
      take = 0;
      ReportError(" InsertTakeProfit()", " take profit < market ");
      return;
   }//if (OrderType() == OP_SELL && take > OrderOpenPrice() ) 
   
   
   OrderModify(ticket, OrderOpenPrice(), OrderStopLoss(), take, OrderExpiration(), CLR_NONE);

}//End void InsertStopLoss(int ticket)




////////////////////////////////////////////////////////////////////////////////////////
//Pending trade price lines module.
//Doubles up by providing missing lines for the stealth stuff
void DrawPendingPriceLines()
{
   //This function will work for a full pending-trade EA.
   //The pending tp/sl can be used for hiding the stops in a market-trading ea
   
   /*
   ObjectDelete(pendingpriceline);
   ObjectCreate(pendingpriceline, OBJ_HLINE, 0, TimeCurrent(), PendingPrice);
   if (PendingBuy) ObjectSet(pendingpriceline, OBJPROP_COLOR, Green);
   if (PendingSell) ObjectSet(pendingpriceline, OBJPROP_COLOR, Red);
   ObjectSet(pendingpriceline, OBJPROP_WIDTH, 1);
   ObjectSet(pendingpriceline, OBJPROP_STYLE, STYLE_DASH);
   */
   string LineName = TpPrefix + DoubleToStr(TicketNo, 0);//TicketNo is set by the calling function - either CountOpenTrades or DoesTradeExist
   HiddenTakeProfit = 0;
   if (TicketNo > -1 && OrderTakeProfit() > 0)
   {
      if (OrderType() == OP_BUY || OrderType() == OP_BUYSTOP || OrderType() == OP_BUYLIMIT)
      {
         HiddenTakeProfit = NormalizeDouble(OrderTakeProfit() - (HiddenPips / factor), Digits);
      }//if (OrderType() == OP_BUY)
      
      if (OrderType() == OP_SELL)
      {
         HiddenTakeProfit = NormalizeDouble(OrderTakeProfit() + (HiddenPips / factor), Digits);
      }//if (OrderType() == OP_BUY)      
   }//if (TicketNo > -1 && OrderTakeProfit() > 0)
   
   if (HiddenTakeProfit > 0 && ObjectFind(LineName) == -1)
   {
      ObjectDelete(LineName);
      ObjectCreate(LineName, OBJ_HLINE, 0, TimeCurrent(), HiddenTakeProfit);
      ObjectSet(LineName, OBJPROP_COLOR, Green);
      ObjectSet(LineName, OBJPROP_WIDTH, 1);
      ObjectSet(LineName, OBJPROP_STYLE, STYLE_DOT);
   }//if (HiddenTakeProfit > 0)
   
   
   LineName = SlPrefix + DoubleToStr(TicketNo, 0);//TicketNo is set by the calling function - either CountOpenTrades or DoesTradeExist
   HiddenStopLoss = 0;
   if (TicketNo > -1 && OrderStopLoss() > 0)
   {
      if (OrderType() == OP_BUY)
      {
         HiddenStopLoss = NormalizeDouble(OrderStopLoss() + (HiddenPips / factor), Digits);
      }//if (OrderType() == OP_BUY)
      
      if (OrderType() == OP_SELL || OrderType() == OP_SELLSTOP || OrderType() == OP_SELLLIMIT)
      {
         HiddenStopLoss = NormalizeDouble(OrderStopLoss() - (HiddenPips / factor), Digits);
      }//if (OrderType() == OP_BUY)      
   }//if (TicketNo > -1 && OrderStopLoss() > 0)
   
   if (HiddenStopLoss > 0 && ObjectFind(LineName) == -1)
   {
      ObjectDelete(LineName);
      ObjectCreate(LineName, OBJ_HLINE, 0, TimeCurrent(), HiddenStopLoss);
      ObjectSet(LineName, OBJPROP_COLOR, Red);
      ObjectSet(LineName, OBJPROP_WIDTH, 1);
      ObjectSet(LineName, OBJPROP_STYLE, STYLE_DOT);
   }//if (HiddenStopLoss > 0)
   
   

}//End void DrawPendingPriceLines()


void DeletePendingPriceLines()
{

   
   //ObjectDelete(pendingpriceline);
   string LineName = TpPrefix + DoubleToStr(TicketNo, 0);
   ObjectDelete(LineName);
   LineName = SlPrefix + DoubleToStr(TicketNo, 0);
   ObjectDelete(LineName);
   
}//End void DeletePendingPriceLines()

void ReplaceMissingSlTpLines()
{

   if (OrderTakeProfit() > 0 || OrderStopLoss() > 0) DrawPendingPriceLines();

}//End void ReplaceMissingSlTpLines()

void DeleteOrphanTpSlLines()
{

   if (ObjectsTotal() == 0) return;
   
   for (int cc = ObjectsTotal() - 1; cc >= 0; cc--)
   {
      string name = ObjectName(cc);
      
      if ((StringSubstr(name, 0, 2) == TpPrefix || StringSubstr(name, 0, 2) == SlPrefix) && ObjectType(name) == OBJ_HLINE)
      {
         int tn = StrToDouble(StringSubstr(name, 2));
         if (tn > 0) 
         {
            if (!OrderSelect(tn, SELECT_BY_TICKET, MODE_TRADES) || OrderCloseTime() > 0)
            {
               ObjectDelete(name);
            }//if (!OrderSelect(tn, SELECT_BY_TICKET, MODE_TRADES) || OrderCloseTime() > 0)
            
         }//if (tn > 0) 
         
         
      }//if (StringSubstr(name, 0, 1) == TpPrefix)
      
   }//for (int cc = ObjectsTotal() - 1; cc >= 0; cc--)
   
   
}//End void DeleteOrphanTpSlLines()


//END Pending trade price lines module
////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////
//TRADE MANAGEMENT MODULE

void ReportError(string function, string message)
{
   //All purpose sl mod error reporter. Called when a sl mod fails
   
   int err=GetLastError();
      
   Alert(WindowExpertName(), " ", OrderTicket(), function, message, err,": ",ErrorDescription(err));
   Print(WindowExpertName(), " ", OrderTicket(), function, message, err,": ",ErrorDescription(err));
   
}//void ReportError()



void BreakEvenStopLoss() // Move stop loss to breakeven
{

   double NewStop;
   bool result;
   bool modify=false;
   string LineName = SlPrefix + DoubleToStr(OrderTicket(), 0);
   double sl = ObjectGet(LineName, OBJPROP_PRICE1);
   double target = OrderOpenPrice();
   
   if (OrderType()==OP_BUY)
   {
      if (HiddenPips > 0) target-= (HiddenPips / factor);
      if (OrderStopLoss() >= target) return;
      if (Bid >= OrderOpenPrice () + (BreakEvenPips / factor))          
      {
         //Calculate the new stop
         NewStop = NormalizeDouble(OrderOpenPrice()+(BreakEvenProfit / factor), Digits);
         if (HiddenPips > 0)
         {
            if (ObjectFind(LineName) == -1)
            {
               ObjectCreate(LineName, OBJ_HLINE, 0, TimeCurrent(), 0);
               ObjectSet(LineName, OBJPROP_COLOR, Red);
               ObjectSet(LineName, OBJPROP_WIDTH, 1);
               ObjectSet(LineName, OBJPROP_STYLE, STYLE_DOT);
            }//if (ObjectFind(LineName == -1) )
         
            ObjectMove(LineName, 0, TimeCurrent(), NewStop);         
         }//if (HiddenPips > 0)
         modify = true;   
      }//if (Bid >= OrderOpenPrice () + (Point*BreakEvenPips) && 
   }//if (OrderType()==OP_BUY)               			         
    
   if (OrderType()==OP_SELL)
   {
     if (HiddenPips > 0) target+= (HiddenPips / factor);
      if (OrderStopLoss() <= target && OrderStopLoss() > 0) return;
     if (Ask <= OrderOpenPrice() - (BreakEvenPips / factor)) 
     {
         //Calculate the new stop
         NewStop = NormalizeDouble(OrderOpenPrice()-(BreakEvenProfit / factor), Digits);
         if (HiddenPips > 0)
         {
            if (ObjectFind(LineName) == -1)
            {
               ObjectCreate(LineName, OBJ_HLINE, 0, TimeCurrent(), 0);
               ObjectSet(LineName, OBJPROP_COLOR, Red);
               ObjectSet(LineName, OBJPROP_WIDTH, 1);
               ObjectSet(LineName, OBJPROP_STYLE, STYLE_DOT);
            }//if (ObjectFind(LineName == -1) )
         
            ObjectMove(LineName, 0, Time[0], NewStop);
         }//if (HiddenPips > 0)         
         modify = true;   
     }//if (Ask <= OrderOpenPrice() - (Point*BreakEvenPips) && (OrderStopLoss()>OrderOpenPrice()|| OrderStopLoss()==0))     
   }//if (OrderType()==OP_SELL)

   //Move 'hard' stop loss whether hidden or not. Don't want to risk losing a breakeven through disconnect.
   if (modify)
   {
      if (NewStop == OrderStopLoss() ) return;
      while (IsTradeContextBusy() ) Sleep(100);
      result = OrderModify(OrderTicket(), OrderOpenPrice(), NewStop, OrderTakeProfit(), OrderExpiration(), CLR_NONE);      
      if (!result) ReportError(" BreakEvenStopLoss()", slm);
      
      while (IsTradeContextBusy() ) Sleep(100);
      if (HalfCloseEnabled && OrderLots() == Lot) bool success = HalfCloseTrade();
   }//if (modify)
   
} // End BreakevenStopLoss sub

bool HalfCloseTrade()
{
   //Close half the trade.
   //Return true if close succeeds, else false
   
   bool Success = OrderClose(OrderTicket(), OrderLots() / 2, OrderClosePrice(), 1000, Blue);
   if (!Success) 
   {
      ReportError(" HalfCloseTrade()", pcm);
      return (false);
   }//if (!Success) 
   
   //Got this far, so closure succeeded
   return (true);   

}//bool HalfCloseTrade()

void JumpingStopLoss() 
{
   // Jump sl by pips and at intervals chosen by user .

   //if (OrderProfit() < 0) return;//Nothing to do
   string LineName = SlPrefix + DoubleToStr(OrderTicket(), 0);
   double sl = ObjectGet(LineName, OBJPROP_PRICE1);
   
   //if (sl == 0) return;//No line, so nothing to do
   double NewStop;
   bool modify=false;
   bool result;
   
   
    if (OrderType()==OP_BUY)
    {
       //if (sl < OrderOpenPrice() ) return;//Not at breakeven yet
       // Increment sl by sl + JumpingStopPips.
       // This will happen when market price >= (sl + JumpingStopPips)
       //if (Bid>= sl + ((JumpingStopPips*2) / factor) )
       if (sl == 0) sl = MathMax(OrderStopLoss(), OrderOpenPrice());
       if (Bid >=  sl + ((JumpingStopPips * 2) / factor) )//George{
       {
          NewStop = NormalizeDouble(sl + (JumpingStopPips / factor), Digits);
          if (AddBEP) NewStop = NormalizeDouble(NewStop + (BreakEvenProfit / factor), Digits);
          if (HiddenPips > 0) ObjectMove(LineName, 0, Time[0], NewStop);
          if (NewStop - OrderStopLoss() >= Point) modify = true;//George again. What a guy
       }// if (Bid>= sl + (JumpingStopPips / factor) && sl>= OrderOpenPrice())     
    }//if (OrderType()==OP_BUY)
       
       if (OrderType()==OP_SELL)
       {
          //if (sl > OrderOpenPrice() ) return;//Not at breakeven yet
          // Decrement sl by sl - JumpingStopPips.
          // This will happen when market price <= (sl - JumpingStopPips)
          //if (Bid<= sl - ((JumpingStopPips*2) / factor)) Original code
          if (sl == 0) sl = MathMin(OrderStopLoss(), OrderOpenPrice());
          if (sl == 0) sl = OrderOpenPrice();
          if (Bid <= sl - ((JumpingStopPips * 2) / factor) )//George
          {
             NewStop = NormalizeDouble(sl - (JumpingStopPips / factor), Digits);
             if (AddBEP) NewStop = NormalizeDouble(NewStop - (BreakEvenProfit / factor), Digits);
             if (HiddenPips > 0) ObjectMove(LineName, 0, Time[0], NewStop);
             if (OrderStopLoss() - NewStop >= Point || OrderStopLoss() == 0) modify = true;//George again. What a guy   
          }// close if (Bid>= sl + (JumpingStopPips / factor) && sl>= OrderOpenPrice())         
       }//if (OrderType()==OP_SELL)



   //Move 'hard' stop loss whether hidden or not. Don't want to risk losing a breakeven through disconnect.
   if (modify)
   {
      while (IsTradeContextBusy() ) Sleep(100);
      result = OrderModify(OrderTicket(), OrderOpenPrice(), NewStop, OrderTakeProfit(), OrderExpiration(), CLR_NONE);      
      if (!result) ReportError(" JumpingStopLoss()", slm);      
   }//if (modify)

} //End of JumpingStopLoss sub


void TrailingStopLoss()
{
   
   if (OrderProfit() < 0) return;//Nothing to do
   string LineName = SlPrefix + DoubleToStr(OrderTicket(), 0);
   double sl = ObjectGet(LineName, OBJPROP_PRICE1);
   //if (sl == 0) return;//No line, so nothing to do
   double NewStop;
   bool modify=false;
   bool result;
   
    if (OrderType()==OP_BUY)
       {
          //if (sl < OrderOpenPrice() ) return;//Not at breakeven yet
          // Increment sl by sl + TrailingStopPips.
          // This will happen when market price >= (sl + JumpingStopPips)
          //if (Bid>= sl + (TrailingStopPips / factor) ) Original code
          if (sl == 0) sl = MathMax(OrderStopLoss(), OrderOpenPrice());
          if (Bid >= sl + (TrailingStopPips / factor) )//George
          {
             NewStop = NormalizeDouble(sl + (TrailingStopPips / factor), Digits);
             if (HiddenPips > 0) ObjectMove(LineName, 0, Time[0], NewStop);
             if (NewStop - OrderStopLoss() >= Point) modify = true;//George again. What a guy
          }//if (Bid >= MathMax(sl,OrderOpenPrice()) + (TrailingStopPips / factor) )//George
       }//if (OrderType()==OP_BUY)
       
       if (OrderType()==OP_SELL)
       {
          //if (sl > OrderOpenPrice() ) return;//Not at breakeven yet
          // Decrement sl by sl - TrailingStopPips.
          // This will happen when market price <= (sl - JumpingStopPips)
          //if (Bid<= sl - (TrailingStopPips / factor) ) Original code
          if (sl == 0) sl = MathMin(OrderStopLoss(), OrderOpenPrice());
          if (sl == 0) sl = OrderOpenPrice();
          if (Bid <= sl  - (TrailingStopPips / factor))//George
          {
             NewStop = NormalizeDouble(sl - (TrailingStopPips / factor), Digits);
             if (HiddenPips > 0) ObjectMove(LineName, 0, Time[0], NewStop);
             if (OrderStopLoss() - NewStop >= Point || OrderStopLoss() == 0) modify = true;//George again. What a guy   
          }//if (Bid <= MathMin(sl, OrderOpenPrice() ) - (TrailingStopPips / factor) )//George
       }//if (OrderType()==OP_SELL)


   //Move 'hard' stop loss whether hidden or not. Don't want to risk losing a breakeven through disconnect.
   if (modify)
   {
      while (IsTradeContextBusy() ) Sleep(100);
      result = OrderModify(OrderTicket(), OrderOpenPrice(), NewStop, OrderTakeProfit(), OrderExpiration(), CLR_NONE);      
      if (!result) ReportError(" TrailingStopLoss()", slm);
   }//if (modify)
      
} // End of TrailingStopLoss sub

void CandlestickTrailingStop()
{
   
   //Trails the stop at the hi/lo of the previous candle shifted by the user choice.
   //Only tries to do this once per bar, so an invalid stop error will only be generated once. I could code for
   //a too-close sl, but cannot be arsed. Coders, sort this out for yourselves.
   
   if (OldCstBars == iBars(NULL, CstTimeFrame)) return;
   OldCstBars = iBars(NULL, CstTimeFrame);

   if (OrderProfit() < 0) return;//Nothing to do
   string LineName = SlPrefix + DoubleToStr(OrderTicket(), 0);
   double sl = ObjectGet(LineName, OBJPROP_PRICE1);
   if (sl == 0) sl = OrderStopLoss();
   double NewStop;
   bool modify=false;
   bool result;
   

   if (OrderType() == OP_BUY)
   {
      if (iLow(NULL, CstTimeFrame, CstTrailCandles) > sl)
      {
         if (CandleTrailAfterBreakevenOnly && OrderStopLoss() < OrderOpenPrice() ) return;//Not at breakeven yet, so do not trail the candle.
         NewStop = NormalizeDouble(iLow(NULL, CstTimeFrame, CstTrailCandles), Digits);
         //Don't want to move the stop if the previous low was < OrderStopLoss(), or the market is below the new stop
         if (NewStop <= OrderStopLoss() || Bid < NewStop) return;
         if (HiddenPips > 0) 
         {
            ObjectMove(LineName, 0, Time[0], NewStop);
            NewStop = NormalizeDouble(NewStop - (HiddenPips / factor), Digits);
         }//if (HiddenPips > 0) 
         modify = true;   
      }//if (iLow(NULL, CstTimeFrame, CstTrailCandles) > sl)
   }//if (OrderType == OP_BUY)
   
   if (OrderType() == OP_SELL)
   {
      if (iHigh(NULL, CstTimeFrame, CstTrailCandles) < sl)
      {
         if (CandleTrailAfterBreakevenOnly && OrderStopLoss() > OrderOpenPrice() ) return;//Not at breakeven yet, so do not trail the candle.
         
         //Don't want to move the stop if the previous high was > OrderStopLoss(), or the market is above the new stop
         if (NewStop >= OrderStopLoss() || Bid > NewStop) return;
         NewStop = NormalizeDouble(iHigh(NULL, CstTimeFrame, CstTrailCandles), Digits);
         if (HiddenPips > 0) 
         {
            ObjectMove(LineName, 0, Time[0], NewStop);
            NewStop = NormalizeDouble(NewStop + (HiddenPips / factor), Digits);
         }//if (HiddenPips > 0) 
         modify = true;   
      }//if (iHigh(NULL, CstTimeFrame, CstTrailCandles) < sl)
   }//if (OrderType() == OP_SELL)
   
   //Move 'hard' stop loss whether hidden or not. Don't want to risk losing a breakeven through disconnect.
   if (modify)
   {
      while (IsTradeContextBusy() ) Sleep(100);
      result = OrderModify(OrderTicket(), OrderOpenPrice(), NewStop, OrderTakeProfit(), OrderExpiration(), CLR_NONE);      
      if (!result) ReportError(" CandlestickTrailingStop()", slm);
   }//if (modify)

}//End void CandlestickTrailingStop()


void TradeManagementModule()
{

   // Call the working subroutines one by one. 


   // Breakeven
   if(BreakEven) BreakEvenStopLoss();

   //Candlestick trailing stop
   static datetime OldCstBarTime;
   if (UseCandlestickTrailingStop && OldCstBarTime!= iTime(NULL, CstTimeFrame, 0) )
   {
      OldCstBarTime = iTime(NULL, CstTimeFrame, 0);
      CandlestickTrailingStop();
   }//if (UseCandlestickTrailingStop && OldCstBarTime!= iTime(NULL, CstTimeFrame, 0) )
   
   // JumpingStop
   if(JumpingStop) JumpingStopLoss();

   //TrailingStop
   if(TrailingStop) TrailingStopLoss();

   

}//void TradeManagementModule()
//END TRADE MANAGEMENT MODULE
////////////////////////////////////////////////////////////////////////////////////////



double CalculateTradeProfitInPips(int type)
{
   //This code supplied by Lifesys. Many thanks Paul.
   
   //Returns the pips Upl of the currently selected trade. Called by CountOpenTrades()
   double profit;
   // double point = BrokerPoint(OrderSymbol() ); // no real use
   double ask = MarketInfo(OrderSymbol(), MODE_ASK);
   double bid = MarketInfo(OrderSymbol(), MODE_BID);

   if (type == OP_BUY)
   {
      profit = bid - OrderOpenPrice();
   }//if (OrderType() == OP_BUY)

   if (type == OP_SELL)
   {
      profit = OrderOpenPrice() - ask;
   }//if (OrderType() == OP_SELL)
   //profit *= PFactor(OrderSymbol()); // use PFactor instead of point. This line for multi-pair ea's
   profit *= factor; // use PFactor instead of point.

   return(profit); // in real pips
}//double CalculateTradeProfitInPips(int type)

bool CloseEnough(double num1, double num2)
{
   /*
   This function addresses the problem of the way in which mql4 compares doubles. It often messes up the 8th
   decimal point.
   For example, if A = 1.5 and B = 1.5, then these numbers are clearly equal. Unseen by the coder, mql4 may
   actually be giving B the value of 1.50000001, and so the variable are not equal, even though they are.
   This nice little quirk explains some of the problems I have endured in the past when comparing doubles. This
   is common to a lot of program languages, so watch out for it if you program elsewhere.
   Gary (garyfritz) offered this solution, so our thanks to him.
   */
   
   if (num1 == 0 && num2 == 0) return(true); //0==0
   if (MathAbs(num1 - num2) / (num1 + num2) < 0.00000001) return(true);
   
   //Doubles are unequal
   return(false);

}//End bool CloseEnough(double num1, double num2)

double PFactor(string pair)
{
   //This code supplied by Lifesys. Many thanks Paul - we all owe you. Gary was trying to make me see this, but I
   //coould not understand his explanation. Paul used Janet and John words
   
   double PipFactor=10000; // correct factor for most pairs

   if (StringFind(pair,"JPY",0) != -1 || StringFind(pair,"XAG",0) != -1)
   PipFactor = 100; // if jpy or silver

   if (StringFind(pair,"XAU",0) != -1)
   PipFactor = 10; // if gold

   return (PipFactor);
}//End double PFactor(string pair)


void GetSwap(string symbol)
{
   LongSwap = MarketInfo(symbol, MODE_SWAPLONG);
   ShortSwap = MarketInfo(symbol, MODE_SWAPSHORT);

}//End void GetSwap()

void DrawTrendLine(string name, datetime time1, double val1, datetime time2, double val2, color col, int width, int style, bool ray)
{
   //Plots a trendline with the given parameters
   
   ObjectDelete(name);
   
   ObjectCreate(name, OBJ_TREND, 0, time1, val1, time2, val2);
   ObjectSet(name, OBJPROP_COLOR, col);
   ObjectSet(name, OBJPROP_WIDTH, width);
   ObjectSet(name, OBJPROP_STYLE, style);
   ObjectSet(name, OBJPROP_RAY, ray);
   
}//End void DrawLine()

void DrawHorizontalLine(string name, double price, color col, int style, int width)
{
   
   ObjectDelete(name);
   
   ObjectCreate(name, OBJ_HLINE, 0, TimeCurrent(), price);
   ObjectSet(name, OBJPROP_COLOR, col);
   ObjectSet(name, OBJPROP_STYLE, style);
   ObjectSet(name, OBJPROP_WIDTH, width);
   

}//void DrawLine(string name, double price, color col)


bool MarginCheck()
{

   EnoughMargin = true;//For user display
   MarginMessage = "";
   if (UseScoobsMarginCheck && OpenTrades > 0)
   {
      if(AccountMargin() > (AccountFreeMargin()/100)) 
      {
         MarginMessage = "There is insufficient margin to allow trading. You might want to turn off the UseScoobsMarginCheck input.";
         return(false);
      }//if(AccountMargin() > (AccountFreeMargin()/100)) 
      
   }//if (UseScoobsMarginCheck)


   if (UseForexKiwi && AccountMargin() > 0)
   {
      
      double ml = NormalizeDouble(AccountEquity() / AccountMargin() * 100, 2);
      if (ml < FkMinimumMarginPercent)
      {
         MarginMessage = StringConcatenate("There is insufficient margin percent to allow trading. ", DoubleToStr(ml, 2), "%");
         return(false);
      }//if (ml < FkMinimumMarginPercent)
   }//if (UseForexKiwi && AccountMargin() > 0)
   
  
   //Got this far, so there is sufficient margin for trading
   return(true);
}//End bool MarginCheck()


string PeriodText(int per)
{

	switch (per)
	{
	case PERIOD_M1:
		return("M1");
	case PERIOD_M5:
		return("M5");
	case PERIOD_M15:
		return("M15");
	case PERIOD_M30:
		return("M30");
	case PERIOD_H1:
		return("H1");
	case PERIOD_H4:
		return("H4");
	case PERIOD_D1:
		return("D1");
	case PERIOD_MN1:
		return("MN1");
	default:
		return("");
	}

}//End string PeriodText(int per)


//+------------------------------------------------------------------+
//  Code to check that there are at least 100 bars of history in
//  the sym / per in the passed params
//+------------------------------------------------------------------+
bool HistoryOK(string sym,int per)
{

	double tempArray[][6];  //used for the call to ArrayCopyRates()

    //get the number of bars
	int bars = iBars(sym,per);
	//and report it in the log
	Print("Checking ",sym," for complete data.... number of ",PeriodText(per)," bars = ",bars);

	if (bars < 100)
	{   
	    //we didn't have enough, so set the comment and try to trigger the DL another way
		Comment("Symbol ",sym," -- Waiting for "+PeriodText(per)+" data.");
		ArrayCopyRates(tempArray,sym,per);
		int error=GetLastError();
		if (error != 0) Print(sym," - requesting data from the server...");

        //return false so the caller knows we don't have the data
		return(false);
	}
	
	//if we got here, the data is fine, so clear the comment and return true
	Comment("");
	return(true);

}//End bool HistoryOK(string sym,int per)



//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
{
//----

   //Code to check that there are sufficient bars in the chart's history. Gaheitman provided this. Many thanks George.
   static bool NeedToCheckHistory=true;
   if (NeedToCheckHistory)
   {
        //Customize these for the EA.  You can use externs for the periods 
        //if the user can change the timeframes used.
        //In a multi-currency bot, you'd put the calls in a loop across
        //all pairs
        
        //The following are customized for GDay Mark 2
        if (!HistoryOK(Symbol(),StochTimeFrame)) return(0);
        if (!HistoryOK(Symbol(),HtfTimeFrame)) return(0);
        if (!HistoryOK(Symbol(),LtfTimeFrame)) return(0);
        if (!HistoryOK(Symbol(),PERIOD_M15)) return(0);
        //if we get here, history is OK, so stop checking
        NeedToCheckHistory=false;
   }//if (NeedToCheckHistory)


   /*
   People get twitchy when reading the code being removed from the ex4 file warning, so here is a neat method of
   turning off a function without deleting it, just in case you change your mind and want it later. I actually call
   CalculateTradeProfitInPips() from within CountOpenTrades() and include it here merely as an example.
   */
   if (TurnOff == 1) CalculateTradeProfitInPips(OP_BUY);//TurnOff is never 1, so the function is not called
   if (TurnOff == 1) CloseEnough(1,1);
   if (TurnOff == 1) DrawTrendLine("w", 0, 0, 0, 0, 0, 0, 0, true);
   if (TurnOff == 1) DrawHorizontalLine("w", 0, 0, 0, 0);
   
   if (OrdersTotal() == 0)
   {
      TicketNo = -1;
      ForceTradeClosure = false;
   }//if (OrdersTotal() == 0)


   if (ForceTradeClosure) 
   {
      CloseAllTrades();
      return;
   }//if (ForceTradeClosure) 

   GetSwap(Symbol() );//For the swap filters, and in case crim has changed swap rates
   
   //New candle. Cancel an existing alert sent. By default, all the email stuff is turned off, so this is probably redundant.
   static datetime OldAlertBarsTime;
   if (OldAlertBarsTime != iTime(NULL, 0, 0) )
   {
      AlertSent = false;
      OldAlertBarsTime = iTime(NULL, 0, 0);
   }//if (OldAlertBarsTimeBarsTime != iTime(NULL, 0, 0) )
   
   
   //Daily results so far - they work on what in in the history tab, so users need warning that
   //what they see displayed on screen depends on that.   
   //Code courtesy of TIG yet again. Thanks, George.
   static int OldHistoryTotal;
   if (OrdersHistoryTotal() != OldHistoryTotal)
   {
      CalculateDailyResult();//Does no harm to have a recalc from time to time
      OldHistoryTotal = OrdersHistoryTotal();
   }//if (OrdersHistoryTotal() != OldHistoryTotal)
   
   
   //Delete orphaned tp/sl lines
   static int M15Bars;
   if (M15Bars != iBars(NULL, PERIOD_M15) )
   {
      M15Bars = iBars(NULL, PERIOD_M15);
      DeleteOrphanTpSlLines();
   }//if (M15Bars != iBars(NULL, PERIOD_M15)
   
   ///////////////////////////////////////////////////////////////////////////////////
   //Find open trades.
   CountOpenTrades();
   if (OldOpenTrades != OpenTrades)
   {
   }//if (OldOpenTrades != OpenTrades)
   
   //Reset various bools
   if (OpenTrades == 0)
   {

   }//if (OpenTrades > 0)

   ///////////////////////////////////////////////////////////////////////////////////
  
   
   //Check that there is sufficient margin for trading
   if (!MarginCheck() )
   {
      DisplayUserFeedback();
      return;
   }//if (!MarginCheck() )
     
   
   if (OldBarsTime != iTime(NULL, StochTimeFrame, 0) )
   {
      ReadIndicatorValues();
      GetSetupStatus();
      if (ForceTradeClosure) return;
      OldBarsTime = iTime(NULL, StochTimeFrame, 0);
      
      //Sat/Sun candles
      if (!TradeSundayCandle && TimeDayOfWeek(TimeCurrent() ) == 0) return;
      if (!TradeSaturdayCandle && TimeDayOfWeek(TimeCurrent() ) == 6) return;
      
      if (TicketNo == -1 && TradeSetupStatus != nosetup) LookForTradingOpportunities();
   }//if (TicketNo == -1)
   
   ///////////////////////////////////////////////////////////////////////////////////
  
   DisplayUserFeedback();


//----
   return(0);
}
//+------------------------------------------------------------------+

