//+-------------------------------------------------------------------+
//|                                    Nanningbob 10.2 autotrader.mq4 |
//|                                  Copyright © 2009, Steve Hopwood  |
//|                              http://www.hopwood3.freeserve.co.uk  |
//|                                           Copyright © 2012, Alex  |
//+-------------------------------------------------------------------+
#define  version "Version 1.2"

#property copyright "Copyright © 2012, Alex"
#property link      ""
#include <WinUser32.mqh>
#include <stdlib.mqh>
#define  NL    "\n"
#define  up "Up. "
#define  down "Down. "
#define  ranging "Ranging. "
#define  none "None. "
#define  both "Both. "
#define  buy "Buy"
#define  sell "Sell"

//Pending trade price line
#define  pendingpriceline "Pending price line"
//Hidden sl and tp lines. If used, the bot will close trades on a touch/break of these lines.
//Each line is named with its appropriate prefix and the ticket number of the relevant trade
#define  TpPrefix "Tp"
#define  SlPrefix "Sl"

//Indi definitions
#define  buyonly "Buy Only. "
#define  sellonly "Sell Only. "
#define  buyhold "Buy and hold. "
#define  sellhold "Sell and hold. "
#define  rising   "Angle is rising. "
#define  falling   "Angle is falling. "
#define  unchanged   "Angle is unchanged. "


//Trade origin constants
#define  D1TrendTrade "D1 trend trade"
#define  H4TrendTrade "H4 trend trade"
#define  BbRangeTrade "BB Range trade"
#define  WpcRangeTrade "WPC Range trade"

#define  stacktradeline "Next stack trade line"

/*

Matt Kennel has provided the code for bool O_R_CheckForHistory(int ticket). Cheers Matt, You are a star.


Code for adding debugging Sleep
Alert("G");
int x = 0;
while (x == 0) Sleep(100);

Code for returning a value as pips. The example returns the range of the previous candle
   int PipDivisor = 1;
   if (Digits == 3 || Digits == 5) PipDivisor = 10;
   double CandleRange = ((High[1] - Low[1]) / Point) / PipDivisor;

Standard order loop code
   for (int cc = OrdersTotal() - 1; cc >= 0; cc--)
   {
      if (!OrderSelect(cc, SELECT_BY_POS) ) continue;
      if (OrderSymbol() != Symbol() ) continue;
      if (OrderMagicNumber() != MagicNumber) continue;

   }//for (int cc = OrdersTotal() - 1; cc >= 0; cc--)

Code from George, to detect the shift of an order open time
int shift = iBarShift(NULL,Period(),OrderOpenTime(), false);

FUNCTIONS LIST
void DisplayUserFeedback()
int init()
int start()

----Trading----

void LookForTradingOpportunities()
   bool LookForLongTrend(int tf)
   bool LookForShortTrend(int tf)
   double GetHighestMovingAverage(int tf)
   double GetLowestMovingAverage(int tf)
   void LookForD1TrendTrade(int type)
   void LookForD1H4TrendTrade(int type)
      bool DetectWeeklyPivotCross(int type)
   void LookForWeeklyCrossRangeTrade()
   void LookForBbRangeTrade(int type)
   bool OkToStack(int type)

   double CalculateStopLoss(int type)
   double CalculateTakeProfit(int type, string origin)
   bool IsTradingAllowed()
   double CalculateLotSize(double price1, double price2)
bool SendSingleTrade(int type, string comment, double lotsize, double price, double stop, double take)
   void ModifyOrder(int ticket, double stop, double take)
void CountOpenTrades()
   void InsertStopLoss(int ticket)
   void InsertTakeProfit(int ticket)
   bool MagicNumberTest()
   void AdjustTakeProfit();
   void AdjustStopLoss()
bool CloseTrade(int ticket)
bool LookForTradeClosure(int ticket)
bool CheckTradingTimes()
void CloseAllTrades()
double CalculateTradeProfitInPips()
bool CloseEnough(double num1, double num2)
void GetVolatilityGroup{}

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
double GetSlope(int tf, int shift)
double GetWoh(int tf, int shift)
double GetMa(int tf, int period, int mashift, int method, int ap, int shift)
void GetBB(int shift)

----Pivots and support/resistance----
void CalculatePivots()
void GetSupport(int tf)
void GetResistance(int tf)
void CreateLine(string name, double price, color col, int style)

----Trade management module----
void TradeManagementModule()
void BreakEvenStopLoss()
void JumpingStopLoss() 
void HiddenTakeProfit()
void HiddenStopLoss()
void TrailingStopLoss()
void CandlestickTrailingStop()
void ReportError()

*/

extern string  gen="----General inputs----";
extern double  Lot=0.06;
extern int     StopLossPips=200;
extern int     RiskPercent = 2;//Set to zero to disable and use Lot
//If you use recovery, the value below will be used to calculate LotSize if RiskPercent > 0. Set to zero to disable
extern int    RecoveryVirtualStop = 100;
extern bool    StopTrading=false;
extern bool    CriminalIsECN=true;
extern double  MaxSpread=120;
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
bool           TradeLong, TradeShort;
double		 StopLoss;
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

extern string  tpi="----Take Profit----";
extern int     TakeProfitPips=100;
extern int     MinD1TrendTradeTpPipsTarget=50;
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
double         factor;//For pips/points stuff. Set up in int init()
double         TakeProfit;
double		   MinD1TrendTradeTpPips;
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//Remember to add new magic numbers to bool MagicNumberTest() and InsertTakeProfit functions
extern string  mns="----Magic numbers and trade comments----";
extern string  ams="----enter 0 to autocal magic number-----";
extern int     D1TrendTradeMN=1425;
extern string  D1TrendTradeComment="D1 trend trade";
extern int     D1H4TrendTradeMN=1426;
extern string  D1H4TrendTradeComment="D1/H4 trend trade";
extern int     BbRangeTradeMN=1427;
extern string  BbRangeTradeComment="Bb range trade";
extern int     WpcRangeTradeMN=1428;
extern string  WpcRangeTradeComment="WPC range trade";

extern string  pai="----Trading style inputs----";
extern bool    EnforcePricePivotIntegrity=true;//Market must be correct side of the pivots to trade.
extern bool    TradeD1Trend=true;
extern bool    TradeD1H4Trend=true;
extern int     MaxTrendStackTrades=6;
extern color   StackTradeLineColour=Blue;
extern int     MinStackTradePipsDistance=50;
extern string  rti="Range trading inputs";
extern bool    TradeRange=true;
extern string  bbi="Bollinger Band inputs for range trading";
extern bool    UseBollingerBands=true;
extern int     BbTimeFrame=60;
extern int     BbPeriod=25;
extern int     BbDeviation=2;
extern int     MinimumRangeTakeProfit=15;
//Pips above this means not valid cross. E.g cross happened before you load the ea. Set to zero to disable
extern string  vlc="Pips to verify Line Crossover";
extern int     MaxPipsCrossed=5;
extern string  wab="----Enforce price above/below weekly open----";
extern bool    EnforcePriceToWeeklyOpen=false;
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
double         BbUpper, BbMiddle, BbLower, BbExtent;
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
extern bool    TradeWeeklyPivotCross=true;
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
string         bias;
bool           SendLong, SendShort;
int            magic;
string         comment;
bool           D1TrendTradeOpen, D1H4TrendTradeOpen, RangeTradeOpen;//Set in CountOpenTrades
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

extern string  ind="----10.2 Indicators----";
extern bool    EveryTickMode=false;//Tells the bot to read the indis at every tick
extern int     IndiReadTimeFrame=1;
extern string  ltf="Lower time frame";
extern int     LowerTimeFrame=240;
string  slo="Slope";//No externs. Uses my adapted version of the indi that has no externs
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Slope
double         D1SlopeVal, LtfSlopeVal, PrevD1SlopeVal, PrevLtfSlopeVal;
string         D1SlopeTrend, LtfSlopeTrend, D1SlopeAngle, LtfSlopeAngle;
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Weekly open trend finding
extern string  wot="WeeklyOpenHistogram 2x1";
extern int     barsToProcess = 1000;
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
double         D1WohVal, LtfWohVal, PrevD1WohVal, PrevLtfWohVal;
string         D1WohTrend, LtfWohTrend, D1WohAngle, LtfWohAngle;
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Weekly direction
string         WeeklyDirection;
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Pivots and s/r
double         MonthlyPivot, WeeklyPivot;
double         MMR1, MR1, MMR2, MR2, MMR3, MR3, MMS1, MS1, MMS2, MS2, MMS3, MS3;//MonthlyMidResistance1. MonthlyResistance1 etc
double         WR1, WR2, WR3, WS1, WS2, WS3;//WeeklyResistance1 etc
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
extern string  mai="----Moving averages----";
extern int     MaLtf=240;//Lower time frame. Higher tf is D1
extern int     MaPeriod=5;
extern string  mame="Method: 0=sma; 1=ema; 2=smma;  3=lwma";
extern int     MaMethod=3;
extern string  maap="Applied price: 0=Close; 1=Open; 2=High";
extern string  maap1="3=Low; 4=Median; 5=Typical; 6=Weighted";
extern int     MaAppliedPrice=1;
extern int     BlueMaShift=1;//The MA Shift input
extern int     GreenMaShift=3;//The MA Shift input
extern int     MaroonMaShift=5;//The MA Shift input
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
double         LtfBlueMaVal, LtfGreenMaVal, LtfMaroonMaVal, D1BlueMaVal, D1GreenMaVal, D1MaroonMaVal;
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//Support and resistance
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
double         D1Support, D1Resistance, LtfSupport, LtfResistance;
string         D1SupportText, D1ResistanceText, LtfSupportText, LtfResistanceText;
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//Hidden tp/sl inputs.
extern string  hts="----Stealth stop loss and take profit inputs----";
extern int     PipsHiddenFromCriminal=0;//Added to the 'hard' sl and tp and used for closure calculations
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
double			HiddenPips;//Needed for factor conversions
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

extern string  tt="----Trading hours----";
extern string  Trade_Hours= "Set Morning & Evening Hours";
extern string  Trade_Hoursi= "Use 24 hour, local time clock";
extern string  Trade_Hours_M= "Morning Hours 0-12";
extern int     start_hourm = 0;
extern int     end_hourm = 12;
extern string  Trade_Hours_E= "Evening Hours 12-24";
extern int     start_houre = 12;
extern int     end_houre = 24;
extern int     MondayStartHour=0;

extern string  amc="----Available Margin checks----";
extern string  sco="Scoobs";
extern bool    UseScoobsMarginCheck=false;
extern string  fk="ForexKiwi";
extern bool    UseForexKiwi=true;
extern int     FkMinimumMarginPercent=600;
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
bool           EnoughMargin;
string         MarginMessage;
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

extern string  bf="----Trading balance filters----";
extern bool    UseZeljko=false;
extern bool    OnlyTradeCurrencyTwice=true;

extern string  pts="----Swap filter----";
extern bool    CadPairsPositiveOnly=false;
extern bool    AudPairsPositiveOnly=false;
extern bool    NzdPairsPositiveOnly=false;

extern string  cor="------Correlation filter-------";
extern bool    UseCorrelationFilter=false;
extern int     HighCorrelation=80;

extern string  tmm="----Trade management module----";
//Breakeven has to be enabled for JS and TS to work.
extern string  BE="Break even settings";
extern bool    BreakEven=true;
extern int     BreakEvenTargetPips=50;
extern int     BreakEvenTargetProfit=10;
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
bool           AdaptedBreakEven;
double     BreakEvenPips;
double     BreakEvenProfit;
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
extern string  cts="----Candlestick trailing stop----";
extern bool    UseCandlestickTrailingStop=false;
extern int     CstTimeFrame=0;//Defaults to current chart
extern int     CstTrailCandles=1;//Defaults to previous candle
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
int            OldCstBars;//For candlestick ts
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

extern string  JSL="Jumping stop loss settings";
extern bool    JumpingStop=true;
extern int     JumpingStopTargetPips=30;
extern bool    AddBEP=false;
extern string  TSL="Trailing stop loss settings";
extern bool    TrailingStop=false;
extern int     TrailingStopTargetPips=20;
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
bool           AdaptedJumpingStop;
double		 JumpingStopPips;
double		 TrailingStopPips;
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

extern string  pcbe="PartClose settings can be used in";
extern string  pcbe1="conjunction with Breakeven settings";
extern bool    PartCloseEnabled=false;
extern double  Close_Lots = 0.5;
extern double  Preserve_Lots=0.5;

extern string  vg="----Volatility groups----";
extern string  Group.1="NZDCAD, AUDUSD, EURCHF, EURGBP";
extern string  Group.2="AUDNZD, NZDUSD, CHFJPY, AUDCAD, USDCAD";
extern string  Group.3="NZDJPY, AUDCHF, AUDJPY, USDJPY, EURUSD, NZDCHF, CADCHF";
extern string  Group.4="GBPJPY, GBPCHF, CADJPY, EURCAD, EURAUD, USDCHF, GBPUSD, EURJPY";
extern string  Group.5="GBPNZD, EURNZD, GBPAUD, GBPCAD";
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
int            VolatilityGroup;//Will be 1,2,3,4 or 5 depending on the group
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

extern string  mis="----Odds and ends----";
extern int     DisplayGapSize=30;
extern bool    HideDisplayPanel=false;
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
string         Gap, ScreenMessage;
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


//Matt's O-R stuff
int 	         O_R_Setting_max_retries 	= 10;
double 	      O_R_Setting_sleep_time 		= 4.0; /* seconds */
double 	      O_R_Setting_sleep_max 		= 15.0; /* seconds */
int            RetryCount = 10;//Will make this number of attempts to get around the trade context busy error.


//Trading variables
int            TicketNo = -1, OpenTrades;
bool           CanTradeThisPair = true;//Will be false when this pair fails the currency can only trade twice filter, or the balanced trade filter
double         upl;//For keeping track of the upl of hedged positions
string         TradeOrigin;

//Running total of trades
int            LossTrades, WinTrades;
double         OverallProfit;

//Misc
int            OldBars;
string         PipDescription=" pips";
bool           ForceTradeClosure;
int            TurnOff=0;//For turning off functions without removing their code



void DisplayUserFeedback()
{
   
   if (IsTesting() && !IsVisualMode()) return;

   ScreenMessage = "";
   ScreenMessage = StringConcatenate(ScreenMessage,Gap, NL);
   ScreenMessage = StringConcatenate(ScreenMessage,Gap, "Updates for this EA are to be found at http://www.stevehopwoodforex.com", NL);
   ScreenMessage = StringConcatenate(ScreenMessage,Gap, "Feeling generous? Help keep the coder going with a small Paypal donation to pianodoodler@hotmail.com", NL);
   ScreenMessage = StringConcatenate(ScreenMessage, Gap, TimeToStr(TimeLocal(), TIME_DATE|TIME_MINUTES|TIME_SECONDS), NL );
   ScreenMessage = StringConcatenate(ScreenMessage, Gap, version, NL );

   if (HideDisplayPanel)
   {
      Comment(ScreenMessage);
      return;
   }//if (HideDisplayPanel)   
   ScreenMessage = StringConcatenate(ScreenMessage,Gap, NL);      
   ScreenMessage = StringConcatenate(ScreenMessage,Gap, "Lot size: ", Lot, " (Criminal's minimum lot size: ", MarketInfo(Symbol(), MODE_MINLOT), ")", NL);
   if (TakeProfit > 0) ScreenMessage = StringConcatenate(ScreenMessage,Gap, "Take profit: ", TakeProfit, PipDescription,  NL);
   if (StopLoss > 0) ScreenMessage = StringConcatenate(ScreenMessage,Gap, "Stop loss: ", StopLoss, PipDescription,  NL);
   if (CriminalIsECN) ScreenMessage = StringConcatenate(ScreenMessage,Gap, "CriminalIsECN = true", NL);
   else ScreenMessage = StringConcatenate(ScreenMessage,Gap, "CriminalIsECN = false", NL);
   ScreenMessage = StringConcatenate(ScreenMessage,Gap, "MaxSpread = ", MaxSpread, ": Spread = ", MarketInfo(Symbol(), MODE_SPREAD),
                                                        ": Long swap ",  MarketInfo(Symbol(), MODE_SWAPLONG),
                                                        ": Short swap ",  MarketInfo(Symbol(), MODE_SWAPSHORT),
                                                         NL);
   
   ScreenMessage = StringConcatenate(ScreenMessage,Gap, NL);
   ScreenMessage = StringConcatenate(ScreenMessage,Gap, "Trading hours", NL);
   if (start_hourm == 0 && end_hourm == 12 && start_houre && end_houre == 24) ScreenMessage = StringConcatenate(ScreenMessage,Gap, "            24H trading", NL);
   else
   {
      ScreenMessage = StringConcatenate(ScreenMessage,Gap, "            start_hourm: ", DoubleToStr(start_hourm, 2), 
                      ": end_hourm: ", DoubleToStr(end_hourm, 2), NL);
      ScreenMessage = StringConcatenate(ScreenMessage,Gap, "            start_houre: ", DoubleToStr(start_houre, 2), 
                      ": end_houre: ", DoubleToStr(end_houre, 2), NL);
                      
   }//else

      
   //Running total of trades
   ScreenMessage = StringConcatenate(ScreenMessage,Gap, NL);
   ScreenMessage = StringConcatenate(ScreenMessage, Gap, "Results today. Wins: ", WinTrades, ": Losses ", LossTrades,
                                     ": P/L ", DoubleToStr(OverallProfit, 2), NL);
   
   if (MarginMessage != "") ScreenMessage = StringConcatenate(ScreenMessage,NL, Gap, MarginMessage, NL);
   
   if (AdaptedBreakEven)
   {
      ScreenMessage = StringConcatenate(ScreenMessage,Gap, "Breakeven is set to ", BreakEvenPips, PipDescription);
      ScreenMessage = StringConcatenate(ScreenMessage,": BreakEvenProfit = ", BreakEvenProfit, PipDescription);
      ScreenMessage = StringConcatenate(ScreenMessage,Gap, NL); 
   }//if (BreakEven)

   if (UseCandlestickTrailingStop)
   {
      ScreenMessage = StringConcatenate(ScreenMessage,Gap, "Using candlestick trailing stop", NL);      
   }//if (UseCandlestickTrailingStop)
   
   if (AdaptedJumpingStop)
   {
      ScreenMessage = StringConcatenate(ScreenMessage,Gap, "Jumping stop is set to ", JumpingStopPips, PipDescription);
      ScreenMessage = StringConcatenate(ScreenMessage,Gap, NL);   
   }//if (JumpingStop)
   

   if (TrailingStop)
   {
      ScreenMessage = StringConcatenate(ScreenMessage,Gap, "Trailing stop is set to ", TrailingStopPips, PipDescription);
      ScreenMessage = StringConcatenate(ScreenMessage,Gap, NL);   
   }//if (TrailingStop)

   if (PartCloseEnabled)
   {
      ScreenMessage = StringConcatenate(ScreenMessage, Gap, "Trade part-close is enabled. Closing ",Close_Lots, ": Preserving ", Preserve_Lots, NL);
   }


   ScreenMessage = StringConcatenate(ScreenMessage,Gap, NL);
   
   /*
   string Indent = "        ";
   ScreenMessage = StringConcatenate(ScreenMessage,Gap, version, NL);
   ScreenMessage = StringConcatenate(ScreenMessage,Gap, NL);
   ScreenMessage = StringConcatenate(ScreenMessage,Gap, "Volatility group: ", VolatilityGroup, NL);
   ScreenMessage = StringConcatenate(ScreenMessage,Gap, "Slope indi", NL);
   ScreenMessage = StringConcatenate(ScreenMessage,Gap, Indent, "D1 value ", D1SlopeVal, ": Trend is ", D1SlopeTrend, 
                                                                D1SlopeAngle, NL);                                                                
   if (Period() != PERIOD_D1) ScreenMessage = StringConcatenate(ScreenMessage,Gap, Indent, "Chart value ", LtfSlopeVal, 
                                                                                    ": Trend is ", LtfSlopeTrend, 
                                                                                   LtfSlopeAngle ,NL);

   ScreenMessage = StringConcatenate(ScreenMessage,Gap, "Woh 2x1 indi", NL);
   ScreenMessage = StringConcatenate(ScreenMessage,Gap, Indent, "D1 value ", D1WohVal, ": Trend is ", D1WohTrend, D1WohAngle, NL);
   if (Period() != PERIOD_D1) ScreenMessage = StringConcatenate(ScreenMessage,Gap, Indent, "Chart value ", LtfWohVal, ": Trend is ", LtfWohTrend, LtfWohAngle, NL);
   ScreenMessage = StringConcatenate(ScreenMessage,Gap, "Movement from start of week: ", WeeklyDirection, NL);

   ScreenMessage = StringConcatenate(ScreenMessage,Gap, "Pivots", NL);
   ScreenMessage = StringConcatenate(ScreenMessage,Gap, Indent, "Monthly: ", MonthlyPivot, NL);
   ScreenMessage = StringConcatenate(ScreenMessage,Gap, Indent, Indent, 
                                     "Mid R1 ", MMR1, ": R1 ", MR1,
                                     ": Mid R2 ", MMR2, ": R2 ", MR2,
                                     ": Mid R3 ", MMR3, ": R3 ", MR3, 
                                     NL, Gap, Indent, Indent,
                                     "Mid S1 ", MMS1, ": S1 ", MS1,
                                     ": Mid S2 ", MMS2, ": S2 ", MS2,
                                     ": Mid S3 ", MMS3, ": S3 ", MS3,   
                                     NL);
      
   ScreenMessage = StringConcatenate(ScreenMessage,Gap, Indent, "Weekly: ", WeeklyPivot, NL);
   ScreenMessage = StringConcatenate(ScreenMessage,Gap, Indent, Indent, 
                                     "R1 ", WR1,
                                     ": R2 ", WR2,
                                     ": R3 ", WR3, 
                                     NL, Gap, Indent, Indent,
                                     "S1 ", WS1,
                                     ": S2 ", WS2,
                                     ": S3 ", WS3,   
                                     NL);

   ScreenMessage = StringConcatenate(ScreenMessage,Gap, "Support/resistance", NL);
   ScreenMessage = StringConcatenate(ScreenMessage,Gap, Indent, 
                                     "Daily: Resistance ", D1ResistanceText, " at ", D1Resistance,
                                     ": Support ", D1SupportText, " at ", D1Support,
                                     NL);
   
   if (Period() != PERIOD_D1)
   {
      ScreenMessage = StringConcatenate(ScreenMessage,Gap, Indent, 
                                     "Chart: Resistance ", LtfResistanceText, " at ", LtfResistance,
                                     ": Support ", LtfSupportText, " at ", LtfSupport,
                                     NL);
   }//if (Period() != PERIOD_D1)

   ScreenMessage = StringConcatenate(ScreenMessage,Gap, "Moving Averages", NL);
   ScreenMessage = StringConcatenate(ScreenMessage,Gap, Indent, "Daily",
                                     "Blue ", D1BlueMaVal,
                                     ": Green ", D1GreenMaVal,
                                     ": Maroon ", D1MaroonMaVal,
                                     NL);
   if (Period() != PERIOD_D1)
   {
      ScreenMessage = StringConcatenate(ScreenMessage,Gap, Indent, "Chart",
                                     "Blue ", LtfBlueMaVal,
                                     ": Green ", LtfGreenMaVal,
                                     ": Maroon ", LtfMaroonMaVal,
                                     NL);
   }//if (Period() != PERIOD_D1)
   
      */

   
   Comment(ScreenMessage);


}//void DisplayUserFeedback()


//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
{
//----
   
   //Set up the pips factor. tp and sl etc.
   //The EA uses doubles and assume the value of the integer user inputs. This: 1) minimises the danger of
   //the inputs becoming corrupted by restarts; 2) the integer inputs cannot be divided by factor - doing so results 
   //in zero.
   factor = PFactor(Symbol());
   StopLoss = StopLossPips;
   TakeProfit = TakeProfitPips;
   BreakEvenPips = BreakEvenTargetPips;
   BreakEvenProfit = BreakEvenTargetProfit;
   JumpingStopPips = JumpingStopTargetPips;
   TrailingStopPips = TrailingStopTargetPips;
   HiddenPips = PipsHiddenFromCriminal;
   MinD1TrendTradeTpPips = MinD1TrendTradeTpPipsTarget;
   
   while (IsConnected()==false)
   {
      Comment("Waiting for MT4 connection...");
      Sleep(1000);
   }//while (IsConnected()==false)

   /*
   //Adapt to x digit criminals
   int multiplier = 1;
   if(Digits == 2 || Digits == 4) multiplier = 1;
   if(Digits == 3 || Digits == 5) multiplier = 10;
   if(Digits == 6) multiplier = 100;   
   if(Digits == 7) multiplier = 1000;   
   
   if (multiplier > 1) PipDescription = " points";
   
   TakeProfit*= multiplier;
   StopLoss*= multiplier;
   HiddenPips*= multiplier;
   MinD1TrendTradeTpPips*= multiplier;
   MinimumRangeTakeProfit*= multiplier;
   MinStackTradePipsDistance*= multiplier;
   
   BreakEvenPips*= multiplier;
   BreakEvenProfit*= multiplier;
   JumpingStopPips*= multiplier;
   TrailingStopPips*= multiplier;
	*/
	
   //Lot size and part-close idiot check for the cretins. Code provided by phil_trade. Many thanks, Philippe.
   //adjust Min_lot
   if (Lot < MarketInfo(Symbol(), MODE_MINLOT)) 
   {
   Alert(Symbol()+" Lot was adjusted to Minlot = "+DoubleToStr(MarketInfo(Symbol(), MODE_MINLOT),Digits ) );
   Lot = MarketInfo(Symbol(), MODE_MINLOT);
   }//if (Lot < MarketInfo(Symbol(), MODE_MINLOT)) 
   //check Partial close parameters
   if (PartCloseEnabled == true)
   {
      if (Lot < Close_Lots + Preserve_Lots || Lot < MarketInfo(Symbol(), MODE_MINLOT) + Close_Lots )
      {
         Alert(Symbol()+" PartCloseEnabled is disabled because Lot < Close_Lots + Preserve_Lots or Lot < MarketInfo(Symbol(), MODE_MINLOT) + Close_Lots !");
         PartCloseEnabled = false;
      }//if (Lot < Close_Lots + Preserve_Lots || Lot < MarketInfo(Symbol(), MODE_MINLOT) + Close_Lots )
   }//if (PartCloseEnabled == true)
   
   //Jumping/trailing stops need breakeven set before they work properly
   if ((JumpingStop || TrailingStop) && !BreakEven) 
   {
      BreakEven = true;
      if (JumpingStop) BreakEvenPips = JumpingStopPips;
      if (TrailingStop) BreakEvenPips = TrailingStopPips;
   }//if (JumpingStop || TrailingStop) 
   
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
   
   //Calculate volatioity group the pair belongs to
   GetVolatilityGroup();

   //NB sometimes enforces Brekeven and JumpingStop, so I use extra booleans to call be/js that can be reset
   //to the user's choice when there are no open trades
   AdaptedBreakEven = BreakEven;
   AdaptedJumpingStop = JumpingStop;
   
   OldBars = Bars;
   TicketNo = -1;
   ReadIndicatorValues();//For initial display in case user has turned of constant re-display
   DisplayUserFeedback();
   //This forces the platform to 2048 bars of data - necessary if this is a new CrapT4 installation
   iBars(NULL, Period() );
   
   //Call sq's show trades indi
   //iCustom(NULL, 0, "SQ_showTrades",Magic, 0,0);

   // Auto genenerate magic number if needed
   // added hopfi2k @ 29.08.2012
   if (D1TrendTradeMN==0) D1TrendTradeMN=GenMagic("D1");
   if (D1H4TrendTradeMN==0) D1H4TrendTradeMN=GenMagic("D1H4");
   if (BbRangeTradeMN==0) BbRangeTradeMN=GenMagic("Bb");
   if (WpcRangeTradeMN==0) WpcRangeTradeMN=GenMagic("Wpc");
   
   Print("Magic D1=",D1TrendTradeMN," / D1H4=",D1H4TrendTradeMN," / Bb=",BbRangeTradeMN," / Wpc=",WpcRangeTradeMN);
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
   ObjectDelete(stacktradeline);
//----
   return(0);
}

bool VerifyCrossOver(double  price, double line){
   double diff = 0.0;
   if(MaxPipsCrossed <= 0){
      return (true);
   }
   diff = MathAbs(price - line);
   if(diff < (MaxPipsCrossed / factor)){
      return (true);
   }
   return (false); 
}

void GetVolatilityGroup()
{
   string symbol = StringSubstr(Symbol(), 0, 6);

   if (StringFind(Group.1, symbol) > -1)
   {
      VolatilityGroup = 1;
   }//if (StringFind(Group.1, symbol) > -1)
   
   if (StringFind(Group.2, symbol) > -1)
   {
      VolatilityGroup = 2;
   }//if (StringFind(Group.1, symbol) > -1)
   
   if (StringFind(Group.3, symbol) > -1)
   {
      VolatilityGroup = 3;
   }//if (StringFind(Group.1, symbol) > -1)
   
   if (StringFind(Group.4, symbol) > -1)
   {
      VolatilityGroup = 4;
   }//if (StringFind(Group.1, symbol) > -1)
   
   if (StringFind(Group.5, symbol) > -1)
   {
      VolatilityGroup = 5;
   }//if (StringFind(Group.1, symbol) > -1)
   

}//End void GetVolatilityGroup{}


bool SendSingleTrade(int type, string comment, double lotsize, double price, double stop, double take, int MagicNumber)
{
   //pah (Paul) contributed the code to get around the trade context busy error. Many thanks, Paul.
   
   if (UseCorrelationFilter==true)
   {
      if (IsCorrelated(Symbol())==true)
      {
         return (true);
      }
   }
   int slippage = 10;
   if (Digits == 3 || Digits == 5) slippage = 100;
   
   
   color col = Red;
   if (type == OP_BUY || type == OP_BUYSTOP) col = Green;
   
   int expiry = 0;
   //if (SendPendingTrades) expiry = TimeCurrent() + (PendingExpiryMinutes * 60);

   //RetryCount is declared as 10 in the Trading variables section at the top of this file
   for (int cc = 0; cc < RetryCount; cc++)
   {
      for (int d = 0; (d < RetryCount) && IsTradeContextBusy(); d++) Sleep(100);

      RefreshRates();
      if (type == OP_BUY) price = NormalizeDouble(Ask, Digits);
      if (type == OP_SELL) price = NormalizeDouble(Bid, Digits);
      
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
   
   //RetryCount is declared as 10 in the Trading variables section at the top of this file   
   for (int cc = 0; cc < RetryCount; cc++)
   {
      for (int d = 0; (d < RetryCount) && IsTradeContextBusy(); d++) Sleep(100);
        if (take > 0 && stop > 0)
        {
           while(IsTradeContextBusy()) Sleep(100);
           if (OrderModify(ticket, OrderOpenPrice(), stop, take, OrderExpiration(), CLR_NONE)) return;           
        }//if (take > 0 && stop > 0)
   
        if (take != 0 && stop == 0)
        {
           while(IsTradeContextBusy()) Sleep(100);
           if (OrderModify(ticket, OrderOpenPrice(), OrderStopLoss(), take, OrderExpiration(), CLR_NONE)) return;
        }//if (take == 0 && stop != 0)

        if (take == 0 && stop != 0)
        {
           while(IsTradeContextBusy()) Sleep(100);
           if (OrderModify(ticket, OrderOpenPrice(), stop, OrderTakeProfit(), OrderExpiration(), CLR_NONE)) return;
        }//if (take == 0 && stop != 0)
   }//for (int cc = 0; cc < RetryCount; cc++)
   
   //Got this far, so the order modify failed
   int err=GetLastError();
   Print(Symbol(), " SL/TP  order modify failed with error(",err,"): ",ErrorDescription(err));               
   Alert(Symbol(), " SL/TP  order modify failed with error(",err,"): ",ErrorDescription(err));               

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


///////////////////////////////////////////////////////////////////////////////////////////////////////


bool IsTradingAllowed()
{
   //Returns false if any of the filters should cancel trading, else returns true to allow trading
   
      
   //Maximum spread
   if (MarketInfo(Symbol(), MODE_SPREAD) > MaxSpread) return(false);
 
   CanTradeThisPair = true;
   if (OnlyTradeCurrencyTwice && OpenTrades == 0)
   {
      IsThisPairTradable();      
   }//if (OnlyTradeCurrencyTwice)
   if (!CanTradeThisPair) return(false);

   //Sunday candle
   if (TimeDayOfWeek(TimeCurrent() ) == 0) return(false);
   
   //Monday start hour
   if (TimeDayOfWeek(TimeCurrent() ) == 1)
   {
      if (TimeHour(TimeCurrent() ) < MondayStartHour) return(false);
   }//if (TimeDayOfWeek(TimeCurrent() ) == 1)
   
   
   return(true);


}//End bool IsTradingAllowed()

double CalculateLotSize(double price1, double price2)
{
   //Calculate the lot size by risk. Code kindly supplied by jmw1970. Nice one jmw.
   
   if (price1 == 0 || price2 == 0) return(Lot);//Just in case
   
   double FreeMargin = AccountBalance();
   double TickValue = MarketInfo(Symbol(),MODE_TICKVALUE) ;
   double LotStep = MarketInfo(Symbol(),MODE_LOTSTEP);

   double SLPts = MathAbs(price1 - price2);
   SLPts/= Point;
   
   if(RecoveryVirtualStop > 0){
      SLPts = RecoveryVirtualStop / factor;
      SLPts/= Point;
   }
   
   double Exposure = SLPts * TickValue; // Exposure based on 1 full lot

   double AllowedExposure = (FreeMargin * RiskPercent) / 100;
   
   int TotalSteps = MathRound(((AllowedExposure / Exposure) / LotStep));
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
   
   double Stoplevel = MarketInfo(Symbol(),MODE_STOPLEVEL);

   if (type == OP_BUY)
   {
      price = Ask;
      if (StopLoss > 0) 
      {
         stop = NormalizeDouble(price - (StopLoss / factor), Digits);
      }//if (StopLoss > 0) 

      if (StopLoss == 0)
      {
         //BB Range trade. Use Bb extent
         if (TradeOrigin == BbRangeTrade)
         {
            double extent = BbUpper - BbLower;
            stop = NormalizeDouble(BbLower - extent, Digits);
         }//if (TradeOrigin == BbRangeTrade)

         //Wpc range trade. Uses S1/S2 as sl
         if (TradeOrigin == WpcRangeTrade)
         {
            stop = WS2;
            if (VolatilityGroup < 4) stop = WS1;
         }//if (TradeOrigin == WpcRangeTrade)
      
         //D1 trend trade
         if (TradeOrigin == D1TrendTrade)
         {
            stop = MS2;
            if (VolatilityGroup < 4) stop = MS1;
         }//if (TradeOrigin == D1TrendTrade)
            
         //H4 trend trade
         if (TradeOrigin == H4TrendTrade)
         {
            stop = WS2;
            if (VolatilityGroup < 4) stop = WS1;
         }//if (TradeOrigin == H4TrendTrade)
      }//if (StopLoss == 0)
      
      // Control stop level minima. Provided by Philippe. Thanks, P.
      if (stop > 0 && Bid-stop <= Stoplevel / factor)
      {
         stop = Bid - (Stoplevel / factor);
      }//if (Bid-stop <= Stoplevel / factor)

      if (HiddenPips > 0 && stop > 0) stop = NormalizeDouble(stop - (HiddenPips / factor), Digits);
   }//if (type == OP_BUY)
   
   if (type == OP_SELL)
   {
      price = Bid;
      if (StopLoss > 0) 
      {
         stop = NormalizeDouble(price + (StopLoss / factor), Digits);
      }//if (StopLoss > 0) 

      if (StopLoss == 0)
      {
         //BB Range trade. Use Bb extent
         if (TradeOrigin == BbRangeTrade)
         {
            extent = BbUpper - BbLower;
            stop = NormalizeDouble(BbUpper + extent, Digits);
         }//if (TradeOrigin == BbRangeTrade)

         //Wpc range trade. Uses R1/R2 as sl
         if (TradeOrigin == WpcRangeTrade)
         {
            stop = WR2;
            if (VolatilityGroup < 4) stop = WR1;
         }//if (TradeOrigin == WpcRangeTrade)

         //D1 trend trade
         if (TradeOrigin == D1TrendTrade)
         {
            stop = MR2;
            if (VolatilityGroup < 4) stop = MR1;
         }//if (TradeOrigin == D1TrendTrade)

         //H4 trend trade
         if (TradeOrigin == H4TrendTrade)
         {
            stop = WR2;
            if (VolatilityGroup < 4) stop = WR1;
         }//if (TradeOrigin == H4TrendTrade)
      
      }//if (StopLoss == 0)
      
      // Control stop level minima. Provided by Philippe. Thanks, P.
      if (stop > 0 && stop-Ask <= Stoplevel / factor)
      {
         stop = Ask + (Stoplevel / factor);
      }
      if (HiddenPips > 0 && stop > 0) stop = NormalizeDouble(stop + (HiddenPips / factor), Digits);

   }//if (type == OP_SELL)
   
   return(stop);
   
}//End double CalculateStopLoss(int type)

double CalculateTakeProfit(int type, string origin)
{
   //Returns the stop loss for use in LookForTradingOpps and InsertMissingStopLoss
   double take, price;

   RefreshRates();
   
   double Stoplevel = MarketInfo(Symbol(),MODE_STOPLEVEL);   
   
   if (type == OP_BUY)
   {
      price = Ask;
      if (TakeProfit > 0) 
      {
         take = NormalizeDouble(price + (TakeProfit / factor), Digits);
      }//if (TakeProfit > 0) 

      //D1 trend trade
      if (TradeOrigin == D1TrendTrade)
      {
         //Override any take profit choice if D1SlopeTrend is buy and hold
         if (D1SlopeTrend == buyhold)
         {
            take = 0;
            AdaptedBreakEven = true;
            AdaptedJumpingStop = true;
         }//if (D1SlopeTrend == buyhold)

         //If D1 slope is not buy and hold, then set a tp based on the next full resistance level
         if (D1SlopeTrend != buyhold)
         {
            //Work down through the Monthly Resistance levels until Bid is lower than the resistance. 
            //I have assumed that the market will be above the support levels, and can amend this easily if not.
            if (price < MR3)
            {
               if (MR3 - price >= (MinD1TrendTradeTpPips / factor) ) take = MR3;
            }//if (price < MR3)
            
            if (price < MR2)
            {
               if (MR2 - price >= (MinD1TrendTradeTpPips / factor) ) take = MR2;
            }//if (price < MR3)

            if (price < MR1)
            {
               if (MR1 - price >= (MinD1TrendTradeTpPips / factor) ) take = MR1;
            }//if (price < MR3)
            
            if (price < MonthlyPivot)
            {
               if (MonthlyPivot - price >= (MinD1TrendTradeTpPips / factor) ) take = MonthlyPivot;
            }//if (price < MonthlyPivot)
         }//if (D1SlopeTrend == buyhold)
         
      }//if (TradeOrigin = D1Trend)
      
      //H4 trend trade
      if (TradeOrigin == H4TrendTrade)
      {
         //Override any take profit choice if D1SlopeTrend is buy and hold
         if (D1SlopeTrend == buyhold)
         {
            take = 0;
            AdaptedBreakEven = true;
            AdaptedJumpingStop = true;
         }//if (D1SlopeTrend == buyhold)
         
         //D1 trend is not buy and hold, so set a tp based on the next resistance. 
         //This is weekly R1 for pairs in groups 1 to 3, R2 for the others.
         if (D1SlopeTrend == buy)
         {
            take = WR2;
            if (VolatilityGroup < 4) take = WR1;
         }//if (D1SlopeTrend == buy)         
      }//if (TradeOrigin == H4TrendTrade)
      
      //BB Range trade. Use Weekly pivot tp. Range trade should only be sent at 
      //MinimumRangeTakeProfit from the weekly pivot
      if (TradeOrigin == BbRangeTrade)
      {
         take = WeeklyPivot;         
      }//if (TradeOrigin == RangeTrade)
      
      //Wpc range trade. Uses R1/R2 as tp
      if (TradeOrigin == WpcRangeTrade)
      {
         take = WR2;
         if (VolatilityGroup < 4) take = WR1;
      }//if (TradeOrigin == WpcRangeTrade)
      
      // Control stop level minima. Provided by Philippe. Thanks, P.
       if (take > 0 && take-Ask <= Stoplevel / factor)
       {
         take = Ask + (Stoplevel / factor);
       }

      if (HiddenPips > 0 && take > 0) take = NormalizeDouble(take + (HiddenPips / factor), Digits);

   }//if (type == OP_BUY)
   
   if (type == OP_SELL)
   {
      price = Bid;
      if (TakeProfit > 0) 
      {
         take = NormalizeDouble(price - (TakeProfit / factor), Digits);
      }//if (TakeProfit > 0) 

      if (TradeOrigin == D1TrendTrade)
      {
         //Override any take profit choice if D1SlopeTrend is sell and hold
         if (D1SlopeTrend == sellhold)
         {
            take = 0;
            AdaptedBreakEven = true;
            AdaptedJumpingStop = true;
         }//if (D1SlopeTrend == buyhold)

         //If D1 slope is not sell and hold, then set a tp based on the next full support level
         if (D1SlopeTrend != sellhold)
         {
            //Work up through the Monthly support levels until Bid is higher than support. I have assumed that the
            //market will be below the resistance levels, and can amend this easily if not.
            if (price > MS3)
            {
               if (price - MS3 >= (MinD1TrendTradeTpPips / factor) ) take = MS3;
            }//if (price > MS3)
            
            if (price > MS2)
            {
               if (price - MS2 >= (MinD1TrendTradeTpPips / factor) ) take = MS2;
            }//if (price > MS2)
            
            if (price > MS1)
            {
               if (price - MS1 >= (MinD1TrendTradeTpPips / factor) ) take = MS1;
            }//if (price > MS1)
            
            if (price > MonthlyPivot)
            {
               if (price - MonthlyPivot >= (MinD1TrendTradeTpPips / factor) ) take = MonthlyPivot;
            }//if (price > MonthlyPivot)
         }//if (D1SlopeTrend == buyhold)
      }//if (TradeOrigin == D1Trend)
      
      //H4 trend trade
      if (TradeOrigin == H4TrendTrade)
      {
         //Override any take profit choice if D1SlopeTrend is buy and hold
         if (D1SlopeTrend == sellhold)
         {
            take = 0;
            AdaptedBreakEven = true;
            AdaptedJumpingStop = true;
         }//if (D1SlopeTrend == buyhold)
         
         //D1 trend is not buy and hold, so set a tp based on the next resistance. 
         //This is weekly R1 for pairs in groups 1 to 3, R2 for the others.
         if (D1SlopeTrend == sell)
         {
            take = WS2;
            if (VolatilityGroup < 4) take = WS1;
         }//if (D1SlopeTrend == sell)
      }//if (TradeOrigin == H4TrendTrade)

      //BB Range trade. Use Weekly pivot tp. Range trade should only be sent at 
      //MinimumRangeTakeProfit from the weekly pivot
      if (TradeOrigin == BbRangeTrade)
      {
         take = WeeklyPivot;         
      }//if (TradeOrigin == RangeTrade)

      //Wpc range trade. Uses S1/S2 as tp
      if (TradeOrigin == WpcRangeTrade)
      {
         take = WS2;
         if (VolatilityGroup < 4) take = WS1;
      }//if (TradeOrigin == WpcRangeTrade)

      // Control stop level minima. Provided by Philippe. Thanks, P.
       if (take > 0 && Bid-take <= Stoplevel / factor)
       {
         take = Bid - (Stoplevel/ factor);
       }
       
      if (HiddenPips > 0 && take > 0) take = NormalizeDouble(take - (HiddenPips / factor), Digits);

   }//if (type == OP_SELL)
   
   return(take);
   
}//End double CalculateTakeProfit(int type, string origin)

bool LookForLongTrend(int tf)
{
   /*
   Returns true if Slope and Woh trend are up, else returns false
   - Slope must be >= 0.4
   - Woh must be green   
   */
   
   if (tf == PERIOD_D1)
   {
      if (D1SlopeVal < 0.4) return(false);
      if (D1WohVal <= 0) return(false);
      if(EnforcePriceToWeeklyOpen){
         if (WeeklyDirection != up) return(false);
      }
   }//if (tf = PERIOD_D1)

   if (tf == LowerTimeFrame)
   {
      if (LtfSlopeVal < 0.4) return(false);
      if (LtfWohVal <= 0) return(false);
      if(EnforcePriceToWeeklyOpen){
         if (WeeklyDirection != up) return(false);
      }
   }//if (tf = LowerTimeFrame)
   
   
   //Got this far without returning false, so must be in trend
   return(true);

}//End bool LookForLongTrend(int tf)


bool LookForShortTrend(int tf)
{
   /*
   Returns true if D1 Slope and Woh trend are down, else returns false
   - Slope must be <= -0.4
   - Woh must be red   
   */
   
   if (tf == PERIOD_D1)
   {
      if (D1SlopeVal > -0.4) return(false);
      if (D1WohVal >= 0) return(false);
      if(EnforcePriceToWeeklyOpen){
         if (WeeklyDirection != down) return(false);
      }
   }//if (tf = PERIOD_D1)
   
   if (tf == LowerTimeFrame)
   {
      if (LtfSlopeVal > -0.4) return(false);
      if (LtfWohVal >= 0) return(false);
      if(EnforcePriceToWeeklyOpen){
         if (WeeklyDirection != down) return(false);
      }
   }//if (tf == LowerTimeFrame)
   
   
   //Got this far without returning false, so must be in trend
   return(true);

}//End bool LookForShortTrend(int tf)

double GetHighestMovingAverage(int tf)
{
   //Finds which of the 3 moving average is the highest
   if (tf == PERIOD_D1)
   {
      double ma = D1BlueMaVal;
      if (D1GreenMaVal > ma) ma = D1GreenMaVal;
      if (D1MaroonMaVal > ma) ma = D1MaroonMaVal;
   }//if (tf == PERIOD_D1)
   
   if (tf != PERIOD_D1)
   {
      ma = LtfBlueMaVal;
      if (LtfGreenMaVal > ma) ma = LtfGreenMaVal;
      if (LtfMaroonMaVal > ma) ma = LtfMaroonMaVal;
   }//if (tf != PERIOD_D1)
   
   
   return(ma);
   
}//double GetHighestMovingAverage()

double GetLowestMovingAverage(int tf)
{
   //Finds which of the 3 moving average is the highest
   if (tf == PERIOD_D1)
   {
      double ma = D1BlueMaVal;
      if (D1GreenMaVal < ma) ma = D1GreenMaVal;
      if (D1MaroonMaVal < ma) ma = D1MaroonMaVal;
   }//if (tf == PERIOD_D1)
   
   if (tf != PERIOD_D1)
   {
      ma = LtfBlueMaVal;
      if (LtfGreenMaVal < ma) ma = LtfGreenMaVal;
      if (LtfMaroonMaVal < ma) ma = LtfMaroonMaVal;
   }//if (tf != PERIOD_D1)
   
   
   return(ma);
   
}//double GetLowestMovingAverage(int tf)

void LookForD1TrendTrade(int type)
{
   //Called by void LookForTradingOpportunities(int type)
   //Sets up the trading variables

   if (OpenTrades >= MaxTrendStackTrades) return;
   
   if (!TradeD1Trend) return;

   double target;
   
   if (OpenTrades > 0)
   {
      if (!OkToStack(type)) return;
   }//if (OpenTrades > 0)
   
   //Buy trigger
   if (type == OP_BUY)
   {
      //Find the relevant ma to cross
      target = GetHighestMovingAverage(PERIOD_D1);
      if (Bid > target && bias == up && VerifyCrossOver(Bid, target))
      {
         if (iLow(NULL, PERIOD_D1, 0) < target || iLow(NULL, PERIOD_D1, 1) < target)
         {
            SendLong = true;
            TradeOrigin = D1TrendTrade;//TradeOrigin is used by CalculateTakeProfit()
            magic = D1TrendTradeMN;
            comment = D1TrendTradeComment;
         }//if (iOpen(NULL, PERIOD_D1, 0) < D1BlueMaVal || iOpen(NULL, PERIOD_D1, 1) < D1BlueMaVal)
      }//if (Bid > target)

      //Find a monthly pivot cross
      if (Bid > MonthlyPivot && bias == up && VerifyCrossOver(Bid, MonthlyPivot))
      {
         if (iLow(NULL, PERIOD_D1, 0) < MonthlyPivot || iLow(NULL, PERIOD_D1, 1) < MonthlyPivot)
         {
            SendLong = true;
            TradeOrigin = D1TrendTrade;//TradeOrigin is used by CalculateTakeProfit()
            magic = D1TrendTradeMN;
            comment = D1TrendTradeComment;
         }//if (iLow(NULL, PERIOD_D1, 0) < MonthlyPivot || iLow(NULL, PERIOD_D1, 1) < MonthlyPivot)
      }//if (Bid > target && bias == up)
   }//if (type == OP_BUY)
   
   //Sell trigger
   if (type == OP_SELL)
   {
      //Find the relevant ma to cross
      target = GetLowestMovingAverage(PERIOD_D1);
      if (Bid < target && bias == down && VerifyCrossOver(Bid, target))
      {
         if (iHigh(NULL, PERIOD_D1, 0) > target || iHigh(NULL, PERIOD_D1, 1) > target)
         {
            SendShort = true;
            TradeOrigin = D1TrendTrade;//TradeOrigin is used by CalculateTakeProfit()
            magic = D1TrendTradeMN;
            comment = D1TrendTradeComment;
         }//if (iHigh(NULL, PERIOD_D1, 0) > target || iHigh(NULL, PERIOD_D1, 1) > target)
      }//if (Bid < target && bias == down)

      //Find a monthly pivot cross
      if (Bid < MonthlyPivot && bias == down && VerifyCrossOver(Bid, MonthlyPivot))
      {
         if (iHigh(NULL, PERIOD_D1, 0) > MonthlyPivot || iHigh(NULL, PERIOD_D1, 1) > MonthlyPivot)
         {
            SendShort = true;
            TradeOrigin = D1TrendTrade;//TradeOrigin is used by CalculateTakeProfit()
            magic = D1TrendTradeMN;
            comment = D1TrendTradeComment;
         }//if (iHigh(NULL, PERIOD_D1, 0) > MonthlyPivot || iHigh(NULL, PERIOD_D1, 1) > MonthlyPivot)
      }//if (Bid < MonthlyPivot)
   }//if (type == OP_SELL)
   
   
}//End void LookForD1TrendTrade()

bool DetectWeeklyPivotCross(int type)
{
   //Returns true if there has been a weekly pivot cross, else false
   
   if (type == OP_BUY)
   {
      if (Bid > WeeklyPivot && VerifyCrossOver(Bid, WeeklyPivot))
      {
         if (iLow(NULL, LowerTimeFrame, 0) < WeeklyPivot || iLow(NULL, LowerTimeFrame, 1) < WeeklyPivot)
         {
            return(true);
         }//if (iLow(NULL, LowerTimeFrame, 0) < WeeklyPivot || iLow(NULL, LowerTimeFrame, 1) < WeeklyPivot)
      }//if (Bid > WeeklyPivot)
   }//if (type = OP_BUY)
   
   if (type == OP_SELL)
   {
      if (Bid < WeeklyPivot && VerifyCrossOver(Bid, WeeklyPivot))
      {
         if (iHigh(NULL, LowerTimeFrame, 0) > WeeklyPivot || iHigh(NULL, LowerTimeFrame, 1) > WeeklyPivot)
         {
            return(true);
         }//if (iHigh(NULL, LowerTimeFrame, 0) > WeeklyPivot || iHigh(NULL, LowerTimeFrame, 1) > WeeklyPivot)
      }//if (Bid < WeeklyPivot)
   }//if (type = OP_SELL)
   
   
   //Got this far, so no pivot cross
   
   return(false);
   
}//End bool DetectWeeklyPivotCross(int type)

void LookForD1H4TrendTrade(int type)
{
   //Finds an H4 cross of the weekly pivot for the first trade.
   //Eventually, will find a retreat into the moving averages followed by a breakout, to trigger a buy back into
   //the trade. I have not coded this yet.

   if (!TradeD1H4Trend) return;
   if (OpenTrades >= MaxTrendStackTrades) return;
   if (OpenTrades > 0)
   {
      if (!OkToStack(type)) return;
   }//if (OpenTrades > 0)
         
   double target;
   
   if (type == OP_BUY)
   {
      //Find a weekly pivot cross
      if (Bid > WeeklyPivot && bias == up)
      {
         if (DetectWeeklyPivotCross(OP_BUY))
         {
            SendLong = true;
            TradeOrigin = H4TrendTrade;//TradeOrigin is used by CalculateTakeProfit()
            magic = D1H4TrendTradeMN;
            comment = D1H4TrendTradeComment;
         }//if (DetectWeeklyPivotCross(OP_BUY))
      }//if (Bid > WeeklyPivot)
      
      //Find a move out of the moving averages
      if (magic == 0)
      {
         //Find the relevant ma to cross
         target = GetHighestMovingAverage(LowerTimeFrame);
         if (Bid > target && bias == up && VerifyCrossOver(Bid, target))
         {
            if (iLow(NULL, LowerTimeFrame, 0) < target || iLow(NULL, LowerTimeFrame, 1) < target)
            {
               SendLong = true;
               TradeOrigin = H4TrendTrade;//TradeOrigin is used by CalculateTakeProfit()
               magic = D1H4TrendTradeMN;
               comment = D1H4TrendTradeComment;
            }//if (iLow(NULL, LowerTimeFrame, 0) < target || iLow(NULL, LowerTimeFrame, 1) < target)
         }//if (Bid > target)         
      }//if (magic == 0)      
   }//if (type == OP_BUY)

   if (type == OP_SELL)
   {
      //Find a weekly pivot cross
      if (Bid < WeeklyPivot && bias == down)
      {
         if (DetectWeeklyPivotCross(OP_SELL) )
         {
            SendShort = true;
            TradeOrigin = H4TrendTrade;//TradeOrigin is used by CalculateTakeProfit()
            magic = D1H4TrendTradeMN;
            comment = D1H4TrendTradeComment;
         }//if (DetectWeeklyPivotCross(OP_SELL)
      }//if (Bid < WeeklyPivot)            

      //Find a move out of the moving averages
      if (magic == 0)
      {
         //Find the relevant ma to cross
         target = GetLowestMovingAverage(LowerTimeFrame);
          if (Bid < target && bias == down && VerifyCrossOver(Bid, target))
         {
            if (iHigh(NULL, LowerTimeFrame, 0) > target || iHigh(NULL, LowerTimeFrame, 1) > target)
            {
               SendShort = true;
               TradeOrigin = H4TrendTrade;//TradeOrigin is used by CalculateTakeProfit()
               magic = D1H4TrendTradeMN;
               comment = D1H4TrendTradeComment;
            }//if (iHigh(NULL, LowerTimeFrame, 0) > target || iHigh(NULL, LowerTimeFrame, 1) > target)
         }//if (Bid < target && bias == down)

      }//if (magic == 0)      
   }//if (type == OP_SELL)
   
}//End void LookForD1H4TrendTrade(int type)

void LookForBbRangeTrade(int type)
{
   
   //Look for a range trade if the ltf trend is ranging i.e. < 0.4 and > -0.4.

   if (!TradeRange) return;
   if (OpenTrades >= MaxTrendStackTrades) return;
   if (OpenTrades > 0)
   {
      if (!OkToStack(type)) return;
   }//if (OpenTrades > 0)

   if (type == OP_BUY)
   {
      //Look for a return inside the BbTimeFrame lower Bollinger Band from below. Only trade from the outside 
      //back towards the pivot, so trade only allowed when market is below the weekly pivot by 
      //MinimumRangeTakeProfit pips.
      
         if (Bid > BbLower)
         {
            if (iLow(NULL, BbTimeFrame, 0) < BbLower || iLow(NULL, BbTimeFrame, 1) < BbLower)
            {
               if (Bid < WeeklyPivot && WeeklyPivot - Bid >= (MinimumRangeTakeProfit / factor))
               {
                  SendLong = true;
                  TradeOrigin = BbRangeTrade;//TradeOrigin is used by CalculateTakeProfit()
                  magic = BbRangeTradeMN;
                  comment = BbRangeTradeComment;
               }//if (Bid < WeeklyPivot && WeeklyPivot - Bid >= (MinimumRangeTakeProfit / factor))                  
            }//if (iLow(NULL, BbTimeFrame, 0) < BbLower || iLow(NULL, BbTimeFrame, 1) < BbLower)
         }//if (Bid > BbLower)    
   }//if (type == OP_BUY)
   
   if (type == OP_SELL)
   {
      //Look for a return inside the BbTimeFrame upper Bollinger Band from above. Only trade from the outside 
      //back towards the pivot, so trade only allowed when market is below the weekly pivot by 
      //MinimumRangeTakeProfit pips.
         if (Bid < BbUpper)
         {
            if (iHigh(NULL, BbTimeFrame, 0) > BbUpper || iHigh(NULL, BbTimeFrame, 1) > BbUpper)
            {
               if (Bid > WeeklyPivot && Bid - WeeklyPivot >= (MinimumRangeTakeProfit / factor))
               {
                  SendShort = true;
                  TradeOrigin = BbRangeTrade;//TradeOrigin is used by CalculateTakeProfit()
                  magic = BbRangeTradeMN;
                  comment = BbRangeTradeComment;
               }//if (Bid > WeeklyPivot && Bid - WeeklyPivot >= (MinimumRangeTakeProfit / factor))
            }//if (iHigh(NULL, BbTimeFrame, 0) > BbUpper || iHigh(NULL, BbTimeFrame, 1) > BbUpper)
         }//if (Bid < BbUpper)
   }//if (type == OP_SELL)

}//End void LookForBbRangeTrade(int type)

void LookForWeeklyCrossRangeTrade()
{
   //Called from LookForTradingOpportunities() if magic = 0, indicating no trades have been triggered by other systems.
   //Looks for D1/H4 Slopes both ranging, or some part of the D1 candle tradubg within the moving averages
   
   if (!TradeRange) return;//Usaer option to trade this way.
      
   //Only allow one open trade when the market is ranging.
   if (OpenTrades > 0) return;
   /*
   bool NowRanging = false;
   
   //Detect a range when both Slopes are ranging.
   if (D1SlopeTrend == ranging && LtfSlopeTrend == ranging) NowRanging = true;
   //detect a range if any part of the D1 candle trading within the moving averages?
   if (!NowRanging)
   {
      //Get highest and lowest moving averages
      double Hma = GetHighestMovingAverage(PERIOD_D1);
      double Lma = GetLowestMovingAverage(PERIOD_D1);
      //Is any part of the D1 candle trading within the moving averages?
      if (iLow(NULL, PERIOD_D1, 0) > Hma || iHigh(NULL, PERIOD_D1, 0) < Lma) return;
   }//if (!NowRanging)
   */
   if (LtfSlopeTrend == ranging)
   {
      //Trade in the direction of the D1 bias.
      //Long
      if (D1SlopeVal >= 0.4)
      {
         //Got this far, so market is ranging, so look for a weekly pivot cross.
         if (DetectWeeklyPivotCross(OP_BUY) )
         {
            SendLong = true;
            TradeOrigin = WpcRangeTrade;//TradeOrigin is used by CalculateTakeProfit()
            magic = WpcRangeTradeMN;
            comment = WpcRangeTradeComment;
            return;
         }//if (DetectWeeklyPivotCross(OP_BUY) )
      }//if (D1SWlopeVal >= 0.4)
      
            //Trade in the direction of the D1 bias.
      //Long
      if (D1SlopeVal <= -0.4)
      {
         if (DetectWeeklyPivotCross(OP_SELL) )
         {
            SendShort = true;
            TradeOrigin = WpcRangeTrade;//TradeOrigin is used by CalculateTakeProfit()
            magic = WpcRangeTradeMN;
            comment = WpcRangeTradeComment;
         }//if (DetectWeeklyPivotCross(OP_SELL) )
      }//if (D1SWlopeVal <= -0.4)
      
   }//if (LtfSlopeTrend == ranging)
   
   
}//End void LookForWeeklyCrossRangeTrade()


bool OkToStack(int type)
{
   //Returns true if the market is beyond the stack trade line, else false
   
   double target = ObjectGet(stacktradeline, OBJPROP_PRICE1);
   if (target == 0) return(false);//No line
   
   if (type == OP_BUY)
   {
      if (Bid < target) return(false);      
   }//if (type == OP_BUY)
   
   if (type == OP_SELL)
   {
      if (Bid > target) return(false);      
   }//if (type == OP_SELL)
   
   
   //Got this far, so stack is ok
   return(true);

}//End bool OkToStack(int type)


void LookForTradingOpportunities()
{


   RefreshRates();
   double take, stop, price, target;
   int type;
   string stype;//For the alert
   bool SendTrade;
   string DailyTrend = none;
   string LtfTrend = none;
   magic = 0;
   
   /*Lets see if we can catch a thief.*/
   if(SendTrade){
      MessageBox("You should never see this! Report immediately.");
      SendTrade = false;
   }
   double SendLots = Lot;
   //Check filters
   if (!IsTradingAllowed() ) return;
   
   //User has the option to make NB wait until the market is the correct side of both pivots to trade.
   if (EnforcePricePivotIntegrity)
   {
      bias = none;
      if (Bid > MonthlyPivot && Bid > WeeklyPivot) bias = up;
      if (Bid < MonthlyPivot && Bid < WeeklyPivot) bias = down;
   }//if (EnforcePricePivotIntegrity)
   
   
   ////////////////////////////////////////////////////////////////////////////////////////////////////////
   //Trading decision.
   //Examine the filters one by one.
   //Work on the basis that a failed filter turns off SendLong/Short
   SendLong = false; SendShort = false;

   
   //Long trade
   
   //Look for a long D1 trend trade
   /*
   Nextfunction Returns true if D1 Slope and Woh trend are up, else returns false
   - D1 Slope must be >= 0.4
   - D1 Woh must be green   
   */
   if (LookForLongTrend(PERIOD_D1) )
   {
      DailyTrend = up;
   }//if (LookForLongTrend() )
   
   
   //If the LookForLongD1TrendOpp() function call returns true, then look for a blue ma or pivot cross
   if (DailyTrend == up)
   {
      
      
      //Balance filter
      if (UseZeljko && !BalancedPair(OP_BUY) ) return;
      
      //Swap filter
      TradeLong = true;
      TradeDirectionBySwap();
      if (!TradeLong) return;

      if (!EnforcePricePivotIntegrity) bias = up;//In case user has turned this filter off
      
      //D1 chart
      LookForD1TrendTrade(OP_BUY);
      
      //From here, any trigger will set magic to a >0 value, so no need to check subsequent triggers if magic > 0
      
      //H4 chart. Look for a trading opp on H4 if the D1 has not already triggered a trade. The magic
      //variable will be 0 if there was no D1 trigger.
      if (magic == 0)
      {
         //Look for a long ltf trend trade
         /*
         Nextfunction Returns true if D1 Slope and Woh trend are up, else returns false
         - Ltf Slope must be >= 0.4
         - Ltf Woh must be green   
         */
         if (LookForLongTrend(LowerTimeFrame) )
         {
            LtfTrend = up;
         }//if (LookForLongTrend(LowerTimeFrame) )
      }//if (magic == 0)
         
      //Look for a D1/H4 trend trade
      if (magic == 0)
      {
         if (LtfTrend == up)
         {
            LookForD1H4TrendTrade(OP_BUY);
         }//if (LtfTrend == up)
      }//if (magic == 0)
      
      if (magic == 0)
      {
         //Look for a range trade if the ltf trend is ranging i.e. < 0.4 and > -0.4.
         if (LtfSlopeTrend == ranging)
         {
            if (UseBollingerBands) LookForBbRangeTrade(OP_BUY);
         }//if (LtfSlopeTrend == ranging)
      }//if (magic == 0)
         
            
   }//if (DailyTrend == up)
   
   
   
   
   ////////////////////////////////////////////////////////////////////////////////////////////
   //Short trade
   //Look for a short D1 trend trade
   /*
   The next function returns true if D1 Slope and Woh trend are down, else returns false
   - D1 Slope must be <= -0.4
   - D1 Woh must be red   
   */
   if (LookForShortTrend(PERIOD_D1) )
   {
      DailyTrend = down;
   }//if (LookForLongD1TrendOpp() )

   //If the LookForShortD1TrendOpp() function call returns true, then look for a blue ma or pivot cross
   if (DailyTrend == down)
   {

      //Swap filter
      TradeShort = true;
      TradeDirectionBySwap();
      if (!TradeShort) return;
         

      //Balance filter
      if (UseZeljko && !BalancedPair(OP_SELL) ) return;

      if (!EnforcePricePivotIntegrity) bias = down;//In case user has turned this filter off
      
      //Cancel SendLong, then reset if a cross has occurred
      SendShort = false;
      
      //Find the relevant ma to cross
      //D1 chart
      LookForD1TrendTrade(OP_SELL);
      
      //From here, any trigger will set magic to a >0 value, so no need to check subsequent triggers if magic > 0
      
      //H4 chart. Look for a trading opp on H4 if the D1 has not already triggered a trade. The magic
      //variable will be 0 if there was no D1 trigger.
      if (magic == 0)
      {
         //Look for a short ltf trend trade
         /*
         Nextfunction Returns true if D1 Slope and Woh trend are up, else returns false
         - Ltf Slope must be >= 0.4
         - Ltf Woh must be green   
         */
         if (LookForShortTrend(LowerTimeFrame) )
         {
            LtfTrend = down;
         }//if (LookForShortTrend(LowerTimeFrame) )
      }//if (magic == 0)
         
      //Look for a D1/H4 trend trade
      if (magic == 0)
      {
         if (LtfTrend == down)
         {
            LookForD1H4TrendTrade(OP_SELL);
         }//if (LtfTrend == down)
      }//if (magic == 0)

      //Look for a range trade if the ltf trend is ranging i.e. < 0.4 and > -0.4.
      if (magic == 0)
      {
         if (LtfSlopeTrend == ranging)
         {
            if (UseBollingerBands) LookForBbRangeTrade(OP_SELL)         ;
         }//if (LtfTrend == ranging)
      }//if (magic == 0)
   }//if (DailyTrend == down)

   ////////////////////////////////////////////////////////////////////////////////////////////////////////
   //Look for WPC range trades
   if (magic == 0)
   {
      //D1 Slope either buy or sell, H4 ranging
      if (TradeWeeklyPivotCross) LookForWeeklyCrossRangeTrade();
   }//if (magic == 0)
   
   ////////////////////////////////////////////////////////////////////////////////////////////////////////
   
   
   //Long 
   if (SendLong)
   {
       
      //Got this far, so there is going to be a trade send of some sort. Setting up price here makes
      //this code most easily adaptable to easy alteration
      price = Ask;//Change this to whatever the price needs to be
      
      
      take = CalculateTakeProfit(OP_BUY, TradeOrigin);
      
      stop = CalculateStopLoss(OP_BUY);
      
      
      //Lot size calculated by risk
      if (RiskPercent > 0) SendLots = CalculateLotSize(price, NormalizeDouble(stop, Digits) );

      type = OP_BUY;
      stype = " Buy ";
      SendTrade = true;
   }//if (SendLong)
   
   //Short
   if (SendShort)
   {
      
      //Got this far, so there is going to be a trade send of some sort. Setting up price here makes
      //this code most easily adaptable to easy alteration
      price = Bid;//Change this to whatever the price needs to be

      take = CalculateTakeProfit(OP_SELL, TradeOrigin);
      
      stop = CalculateStopLoss(OP_SELL);
      
      
      //Lot size calculated by risk
      if (RiskPercent > 0) SendLots = CalculateLotSize(NormalizeDouble(stop, Digits), price);
      
      type = OP_SELL;
      stype = " Sell ";
      SendTrade = true;      
   }//if (SendShort)
   

   if (SendTrade)
   {
      bool result = SendSingleTrade(type, comment, SendLots, price, stop, take, magic);
   }//if (SendTrade)
   
   //Actions when trade send succeeds
   if (SendTrade && result)
   {
      if (HiddenPips > 0) ReplaceMissingSlTpLines();
   }//if (result)
   
   //Actions when trade send fails
   if (SendTrade && !result)
   {
   
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
      return(false);
   }//if (!result)
   

}//End bool CloseTrade(ticket)

////////////////////////////////////////////////////////////////////////////////////////////////
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
      if (!MagicNumberTest() ) continue;
      
      OverallProfit+= (OrderProfit() + OrderSwap() + OrderCommission() );
      if (OrderProfit() > 0) WinTrades++;
      if (OrderProfit() < 0) LossTrades++;
   }//for (int cc = 0; cc <= tot -1; cc++)
   
   

}//End void CalculateDailyResult()
   
double GetSlope(int tf, int shift)
{
   //This code contributed by Baluda. Balude, this is a monumental contribution and we are all in your debt.
   double atr = iATR(NULL, tf, 100, shift + 10) / 10;
   double gadblSlope = 0.0;
   if ( atr != 0 )
   {
      double dblTma = calcTma(tf, shift );
      double dblPrev = calcTma(tf, shift + 1 );
      gadblSlope = ( dblTma - dblPrev ) / atr;
   }
   
   return ( gadblSlope );

}//End double GetSlope(int tf, int shift)

//+------------------------------------------------------------------+
//| calcTma()                                                        |
//+------------------------------------------------------------------+
double calcTma(int tf,  int shift )
{
   double dblSum  = iClose(NULL, tf, shift) * 21;
   double dblSumw = 21;
   int jnx, knx;
         
   for ( jnx = 1, knx = 20; jnx <= 20; jnx++, knx-- )
   {
      dblSum  += ( knx * iClose(NULL, tf, shift + jnx) );
      dblSumw += knx;

      if ( jnx <= shift )
      {
         dblSum  += ( knx * iClose(NULL, tf, shift - jnx) );
         dblSumw += knx;
      }
   }
   
   return( dblSum / dblSumw );

}// End calcTma()

double GetWoh(int tf, int shift)
{

   //Up histo buffer
   double v = iCustom(NULL, tf, "10.2 WOH 2x1 5.22", barsToProcess, 0, shift);
   if (v > 0) return(v);
   
   //Down histo buffer
   v = iCustom(NULL, tf, "10.2 WOH 2x1 5.22", barsToProcess, 1, shift);
   if (v < 0) return(v);

   //Zero histo buffer. Not sure if this ever happens, but there is a buffer for it in the indi
   v = iCustom(NULL, tf, "10.2 WOH 2x1 5.22", barsToProcess, 1, shift);
   if (CloseEnough(v, 0) ) return(0);

}//End double GetWoh(int tf, int shift)

void CalculatePivots()
{
   //Calculates the monthly and weekly pivots and their associated s/r levels.
   //Calculation code copied from 10.2 MonthlyMIDPivots.mq4

//double         MMR1, MR1, MMR2, MR2, MMR3, MR3, MMS1, MS1, MMS2, MS2, MMS3, MS3;//MonthlyMidResistance1. MonthlyResistance1 etc
   
   //Monthly
   double last_low=iLow(NULL, PERIOD_MN1, 1);
   double last_high=iHigh(NULL, PERIOD_MN1, 1);
   double last_close=iClose(NULL, PERIOD_MN1, 1);
 
   //Pivot and s/r lines
   double P=(last_high+last_low+last_close)/3;
   double R1=(2*P)-last_low;
   double S1=(2*P)-last_high;
   double R2=P+(last_high-last_low);
   double S2=P-(last_high-last_low);
   double R3=(2*P)+(last_high-(2*last_low));
   double S3=(2*P)-((2*last_high)-last_low);

 
   // calculate mid S/R lines		    
   double tMS3 = S3 + ((S2-S3) / 2);
   double tMS2 = S2 + ((S1-S2) / 2);
   double tMS1 = S1 + ((P-S1) / 2);
   double tMR1 = P + ((R1-P) / 2);
   double tMR2 = R1 + ((R2-R1) / 2);
   double tMR3 = R2 + ((R3-R2) / 2);
 
   //Copy the calculated values into their permanent variables.
   //MR1 = Monthly R1; MMR1 = Monthly Mid R1 etc.
   //It might be better to turn these into arrays. We shall see.
   MonthlyPivot = P;
   MR1 = R1;
   MMR1 = tMR1;
   MR2 = R2;
   MMR2 = tMR2;
   MR3 = R3;
   MMR3 = tMR3;
   
   MS1 = S1;
   MMS1 = tMS1;
   MS2 = S2;
   MMS2 = tMS2;
   MS3 = S3;
   MMS3 = tMS3;
   
   
   //Monthly
   last_low=iLow(NULL, PERIOD_W1, 1);
   last_high=iHigh(NULL, PERIOD_W1, 1);
   last_close=iClose(NULL, PERIOD_W1, 1);
 
   //Pivot and s/r lines
   P=(last_high+last_low+last_close)/3;
   WeeklyPivot = P;
   P=(last_high+last_low+last_close)/3;
   R1=(2*P)-last_low;
   S1=(2*P)-last_high;
   R2=P+(last_high-last_low);
   S2=P-(last_high-last_low);
   R3=(2*P)+(last_high-(2*last_low));
   S3=(2*P)-((2*last_high)-last_low);
   
   WR1 = R1;
   WR2 = R2;
   WR3 = R3;
   
   WS1 = S1;
   WS2 = S2;
   WS3 = S3;
   
   
}//End void CalculatePivots()

double GetMa(int tf, int period, int mashift, int method, int ap, int shift)
{
   return(iMA(NULL, tf, period, mashift, method, ap, shift) );
}//End double GetMa(int tf, int period, int mashift, int method, int ap, int shift)

void GetSupport(int tf)
{
   //Sets nearest support level on the passed time frame param

   //D1 support
   if (tf == PERIOD_D1)
   {
      D1Support = 0;
      
      if (Bid < MS3)
      {
         D1SupportText = " Below Monthly S3";
         return;
      }//if (Bid < MS3)
      
      if (Bid > MMS1)
      {
         D1SupportText = " Monthly mid S1";
         D1Support = MMS1;
         return;
      }//if (Bid > MMS1)
      
      if (Bid > MS1)
      {
         D1SupportText = " Monthly S1";
         D1Support = MS1;
         return;
      }//if (Bid > MMS1)
      
      if (Bid > MMS2)
      {
         D1SupportText = " Monthly mid S2";
         D1Support = MMS2;
         return;
      }//if (Bid > MMS1)
      
      if (Bid > MS2)
      {
         D1SupportText = " Monthly S2";
         D1Support = MS2;
         return;
      }//if (Bid > MMS1)
      
      if (Bid > MMS3)
      {
         D1SupportText = " Monthly mid S3";
         D1Support = MMS3;
         return;
      }//if (Bid > MMS3)
      
      if (Bid > MS3)
      {
         D1SupportText = " Monthly S3";
         D1Support = MS3;
         return;
      }//if (Bid > MMS3)
   }//if (tf == PERIOD_D1)
   
   //Any other timeframe
   if (Bid > WS1)
   {
         LtfSupportText = " Weekly S1";
         LtfSupport = WS1;
         return;      
   }//if (Bid > Ws1)
   
   if (Bid > WS2)
   {
         LtfSupportText = " Weekly S2";
         LtfSupport = WS2;
         return;      
   }//if (Bid > Ws2)
   
   if (Bid > WS3)
   {
         LtfSupportText = " Weekly S3";
         LtfSupport = WS3;
         return;      
   }//if (Bid > Ws1)
   
   
}//End void GetSupport(int tf)

void GetResistance(int tf)
{
   //Sets nearest resistance level on the passed time frame param
   
   //D1 resistance
   if (tf == PERIOD_D1)
   {
      D1Resistance = 0;
      
      if (Bid > MR3)
      {
         D1SupportText = " Above Monthly R3";
         return;
      }//if (Bid < MS3)
      
      if (Bid < MMR1)
      {
         D1ResistanceText = " Monthly mid R1";
         D1Resistance = MMR1;
         return;
      }//if (Bid < MMR1)
      
      if (Bid < MR1)
      {
         D1ResistanceText = " Monthly R1";
         D1Resistance = MR1;
         return;
      }//if (Bid < MMR1)
      
      if (Bid < MMR2)
      {
         D1ResistanceText = " Monthly mid R2";
         D1Resistance = MMR2;
         return;
      }//if (Bid < MMR1)
      
      if (Bid < MR2)
      {
         D1ResistanceText = " Monthly R2";
         D1Resistance = MR2;
         return;
      }//if (Bid < MMR1)
      
      if (Bid < MMR3)
      {
         D1ResistanceText = " Monthly mid R3";
         D1Resistance = MMR3;
         return;
      }//if (Bid < MMR3)
      
      if (Bid < MR3)
      {
         D1ResistanceText = " Monthly R3";
         D1Resistance = MR3;
         return;
      }//if (Bid < MMR3)
   }//if (tf == PERIOD_D1)
   
   //Any other timeframe
   if (Bid < WR1)
   {
         LtfResistanceText = " Weekly R1";
         LtfResistance = WR1;
         return;      
   }//if (Bid < WR1)
   
   if (Bid < WR2)
   {
         LtfResistanceText = " Weekly R2";
         LtfResistance = WR2;
         return;      
   }//if (Bid < WR2)
   
   if (Bid < WR3)
   {
         LtfResistanceText = " Weekly R3";
         LtfResistance = WR3;
         return;      
   }//if (Bid < WR1)
   
   
}//End void GetResistance(int tf)

void GetBB(int shift)
{
   //Reads BB figures into BbUpper, BbMiddle, BbLower
   
   
   BbUpper = iBands(NULL, BbTimeFrame, BbPeriod, BbDeviation, 0, PRICE_OPEN, MODE_UPPER, shift);
   BbLower = iBands(NULL, BbTimeFrame, BbPeriod, BbDeviation, 0, PRICE_OPEN, MODE_LOWER, shift);
   //BbMiddle = iBands(NULL, BbTimeFrame, BbPeriod, BbDeviation, 0, PRICE_OPEN, MODE_MAIN, shift);
   
   //BbExtent = BbUpper - BbLower;
   
}//void GetBb(int shift)


void ReadIndicatorValues()
{
   //Called at the open of each M1 candle
   
   //Slope
   D1SlopeVal = GetSlope(PERIOD_D1, 0);
   D1SlopeTrend = ranging;
   if (D1SlopeVal >= 0.4) D1SlopeTrend = buyonly;
   if (D1SlopeVal <= -0.4) D1SlopeTrend = sellonly;
   if (D1SlopeVal >= 0.8) D1SlopeTrend = buyhold;
   if (D1SlopeVal <= -0.8) D1SlopeTrend = sellhold;

   //Calculate the angle
   static datetime OldD1BarTime;//Use this further down as well, so reset at the end of the function
   if (OldD1BarTime != iTime(NULL, PERIOD_D1, 0))
   {
      PrevD1SlopeVal = GetSlope(PERIOD_D1, 1);      
   }//if (OldD1BarTime != iTime(NULL, PERIOD_D1, 0)
   
   D1SlopeAngle = unchanged;
   if (D1SlopeVal  > PrevD1SlopeVal) D1SlopeAngle = rising;
   if (D1SlopeVal  < PrevD1SlopeVal) D1SlopeAngle = falling;
   

   if (LowerTimeFrame != PERIOD_D1)
   {
      LtfSlopeVal = GetSlope(LowerTimeFrame, 0);
      LtfSlopeTrend = ranging;
      if (LtfSlopeVal >= 0.4) LtfSlopeTrend = buyonly;
      if (LtfSlopeVal <= -0.4) LtfSlopeTrend = sellonly;
      if (LtfSlopeVal >= 0.8) LtfSlopeTrend = buyhold;
      if (LtfSlopeVal <= -0.8) LtfSlopeTrend = sellhold;

      static datetime OldChartBarTime;
      if (OldChartBarTime != iTime(NULL, LowerTimeFrame, 0))
      {
         PrevLtfSlopeVal = GetSlope(LowerTimeFrame, 1);      
      }//if (OldChartBarTime != iTime(NULL, PERIOD_Chart, 0)
   
      LtfSlopeAngle = unchanged;
      if (LtfSlopeVal  > PrevLtfSlopeVal) LtfSlopeAngle = rising;
      if (LtfSlopeVal  < PrevLtfSlopeVal) LtfSlopeAngle = falling;
   }//if (Period() != PERIOD_D1)
   //Calculate the angle

   ///////////////////////////////////////////////////////////////////////////////////////////////
   
   //Woh trend
   D1WohVal = GetWoh(PERIOD_D1, 0);
   
   if (OldD1BarTime != iTime(NULL, PERIOD_D1, 0))
   {
      PrevD1WohVal = GetWoh(PERIOD_D1, 1);
   }//if (OldD1BarTime != iTime(NULL, PERIOD_D1, 0)

   D1WohTrend = none;
   if (D1WohVal > 0) D1WohTrend = up;
   if (D1WohVal < 0) D1WohTrend = down;
   D1WohAngle = unchanged;
   if (D1WohVal > PrevD1WohVal) D1WohAngle = rising;
   if (D1WohVal < PrevD1WohVal) D1WohAngle = falling;
   
   if (LowerTimeFrame != PERIOD_D1)
   {
      LtfWohVal = GetWoh(LowerTimeFrame, 0);
      LtfWohTrend = ranging;
      if (LtfWohVal > 0) LtfWohTrend = up;
      if (LtfWohVal < 0) LtfWohTrend = down;

      if (OldChartBarTime != iTime(NULL, LowerTimeFrame, 0))
      {
         PrevLtfWohVal = GetWoh(LowerTimeFrame, 1);      
      }//if (OldChartBarTime != iTime(NULL, PERIOD_Chart, 0)
   
      LtfWohAngle = unchanged;
      if (LtfWohVal  > PrevLtfWohVal) LtfWohAngle = rising;
      if (LtfWohVal  < PrevLtfWohVal) LtfWohAngle = falling;
   }//if (LowerTimeFrame != PERIOD_D1)
   

   ///////////////////////////////////////////////////////////////////////////////////////////////
   //Direction of movement so far this week
   double wo = iMA(NULL,PERIOD_W1,1,0,MODE_SMA,PRICE_OPEN,0);
   double ma = iMA(NULL,PERIOD_H4,1,0,MODE_SMA,PRICE_MEDIAN,0);
   WeeklyDirection = none;
   if (ma > wo) WeeklyDirection = up;
   if (ma < wo) WeeklyDirection = down;

   ///////////////////////////////////////////////////////////////////////////////////////////////
   //Pivots. Calculate at the start of each week
   static datetime OldPivotBarTime;
   if (OldPivotBarTime != iTime(NULL, PERIOD_W1, 0) )
   {
      OldPivotBarTime = iTime(NULL, PERIOD_W1, 0);
      CalculatePivots();
   }//if (OldPivotBarTime != iTime(NULL, PERIOD_W1, 0) )
   

   ///////////////////////////////////////////////////////////////////////////////////////////////
   //Moving averages
   D1BlueMaVal = GetMa(PERIOD_D1, MaPeriod, BlueMaShift, MaMethod, MaAppliedPrice, 0);
   D1GreenMaVal = GetMa(PERIOD_D1, MaPeriod, GreenMaShift, MaMethod, MaAppliedPrice, 0);
   D1MaroonMaVal = GetMa(PERIOD_D1, MaPeriod, MaroonMaShift, MaMethod, MaAppliedPrice, 0);
   
   LtfBlueMaVal = GetMa(MaLtf, MaPeriod, BlueMaShift, MaMethod, MaAppliedPrice, 0);
   LtfGreenMaVal = GetMa(MaLtf, MaPeriod, GreenMaShift, MaMethod, MaAppliedPrice, 0);
   LtfMaroonMaVal = GetMa(MaLtf, MaPeriod, MaroonMaShift, MaMethod, MaAppliedPrice, 0);
   
   ///////////////////////////////////////////////////////////////////////////////////////////////
   //Support/resistance
   GetSupport(PERIOD_D1);
   GetSupport(LowerTimeFrame);
   GetResistance(PERIOD_D1);
   GetResistance(LowerTimeFrame);
   ///////////////////////////////////////////////////////////////////////////////////////////////
   //Resets
   OldD1BarTime = iTime(NULL, PERIOD_D1, 0);
   OldChartBarTime = iTime(NULL, LowerTimeFrame, 0);
      
   //Bollinger Bands for range trading. No need to call this unless the ltf slope is ranging.
   if (LtfSlopeTrend == ranging)
   {
      GetBB(0);
   }//if (LtfSlopeTrend == ranging)
   
}//void ReadIndicatorValues()

//End Indicator module
////////////////////////////////////////////////////////////////////////////////////////////////

bool MagicNumberTest()
{
   //Retruns true if the trade's magic number matches one of those used by this EA, else false.
   //Called by any function that cycles through the trades for any reason.
   
   if (OrderMagicNumber() != D1TrendTradeMN && OrderMagicNumber() != D1H4TrendTradeMN 
       && OrderMagicNumber() != BbRangeTradeMN && OrderMagicNumber() != WpcRangeTradeMN) 
   {
      return(false);
   }//if (OrderMagicNumber() != D1TrendTradeMN && OrderMagicNumber() != D1H4TrendTradeMN 
   
   return(true);

}//bool MagicNumberTest()


bool LookForTradeClosure(int ticket)
{
   //Close the trade if the close conditions are met.
   //Called from within CountOpenTrades(). Returns true if a close is needed and succeeds, so that COT can increment cc,
   //else returns false
   
   if (!OrderSelect(ticket, SELECT_BY_TICKET) ) return(true);
   if (OrderSelect(ticket, SELECT_BY_TICKET) && OrderCloseTime() > 0) return(true);
   
   bool CloseThisTrade;
   
   string LineName = TpPrefix + DoubleToStr(ticket, 0);
   //Work with the lines on the chart that represent the hidden tp/sl
   double take = ObjectGet(LineName, OBJPROP_PRICE1);
   LineName = SlPrefix + DoubleToStr(ticket, 0);
   double stop = ObjectGet(LineName, OBJPROP_PRICE1);
   
   if (OrderType() == OP_BUY)
   {
      //TP
      if (Bid >= take && take > 0) CloseThisTrade = true;
      //SL
      if (Bid <= stop && stop > 0) CloseThisTrade = true;

   }//if (OrderType() == OP_BUY)
   
   
   if (OrderType() == OP_SELL)
   {
      //TP
      if (Bid <= take && take > 0) CloseThisTrade = true;
      //SL
      if (Bid >= stop && stop > 0) CloseThisTrade = true;

   }//if (OrderType() == OP_SELL)
   
   if (CloseThisTrade)
   {
      bool result = CloseTrade(TicketNo);
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
      if (!MagicNumberTest() ) continue;
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
   }//if (!ForceTradeClosure) 

}//End void CloseAllTrades()


bool CheckTradingTimes()
{
   //This code contributed by squalou. Many thanks, sq.
   
   int hour = TimeHour(TimeLocal() );
   
   if (end_hourm < start_hourm)
	{
		end_hourm += 24;
	}
	

	if (end_houre < start_houre)
	{
		end_houre += 24;
	}
	
	bool ok2Trade = true;
	
	ok2Trade = (hour >= start_hourm && hour <= end_hourm) || (hour >= start_houre && hour <= end_houre);

	// adjust for past-end-of-day cases
	// eg in AUS, USDJPY trades 09-17 and 22-06
	// so, the above check failed, check if it is because of this condition
	if (!ok2Trade && hour < 12)
	{
 		hour += 24;
		ok2Trade = (hour >= start_hourm && hour <= end_hourm) || (hour >= start_houre && hour <= end_houre);		
		// so, if the trading hours are 11pm - 6am and the time is between  midnight to 11am, (say, 5am)
		// the above code will result in comparing 5+24 to see if it is between 23 (11pm) and 30(6+24), which it is...
	}


   // check for end of day by looking at *both* end-hours

   if (hour >= MathMax(end_hourm, end_houre))
   {      
      ok2Trade = false;
   }//if (hour >= MathMax(end_hourm, end_houre))

   return(ok2Trade);

}//bool CheckTradingTimes()

void CountOpenTrades()
{
   //Not all these will be needed. Which ones are depends on the individual EA.
   OpenTrades = 0;
   TicketNo = -1;
   int type;//Saves the OrderType() for consulatation later in the function
   D1TrendTradeOpen = false;
   D1H4TrendTradeOpen = false;
   RangeTradeOpen = false;
   
   upl = 0;//Unrealised profit and loss for hedging/recovery basket closure decisions

   if (OrdersTotal() == 0) return;
   
   //Iterating backwards through the orders list caters more easily for closed trades than iterating forwards
   for (int cc = OrdersTotal() - 1; cc >= 0; cc--)
   {
      bool TradeWasClosed = false;//See 'check for possible trade closure'

      //Ensure the trade is still open
      if (!OrderSelect(cc, SELECT_BY_POS) ) continue;
      //Ensure the EA 'owns' this trade
      if (OrderSymbol() != Symbol() ) continue;
      if (!MagicNumberTest() ) continue;
      
      if (OrderMagicNumber() == D1TrendTradeMN) D1TrendTradeOpen = true;
      if (OrderMagicNumber() == D1H4TrendTradeMN) D1H4TrendTradeOpen = true;
      if (OrderMagicNumber() == BbRangeTradeMN) RangeTradeOpen = true;
      if (OrderMagicNumber() == WpcRangeTradeMN) RangeTradeOpen = true;
      
      //All conditions passed, so carry on
      type = OrderType();//Store the order type
      
      OpenTrades++;
      //Store the latest trade sent. Most of my EA's only need this final ticket number as either they are single trade
      //bots or the last trade in the sequence is the important one. Adapt this code for your own use.
      //Here, create a trade stacking line the trade is a trend trade and the line is missing
      if (TicketNo  == -1) 
      {
         TicketNo = OrderTicket();
         if (MaxTrendStackTrades > 0)
         {
            if (D1TrendTradeOpen || D1H4TrendTradeOpen)
            {
               if (ObjectFind(stacktradeline) == -1)
               {
                  double price;
                  if (OrderType() == OP_BUY) price = NormalizeDouble(OrderOpenPrice() + (MinStackTradePipsDistance / factor), Digits);
                  if (OrderType() == OP_SELL) price = NormalizeDouble(OrderOpenPrice() - (MinStackTradePipsDistance / factor), Digits);
                  CreateLine(stacktradeline, price, StackTradeLineColour, STYLE_DASH);
               }else{
                  //Line exists. We move it to the next stack line
                  if (OrderType() == OP_BUY) price = NormalizeDouble(OrderOpenPrice() + (MinStackTradePipsDistance / factor), Digits);
                  if (OrderType() == OP_SELL) price = NormalizeDouble(OrderOpenPrice() - (MinStackTradePipsDistance / factor), Digits);
                  double CurrLine = ObjectGet(stacktradeline, OBJPROP_PRICE1);
                  if(!CloseEnough(price, CurrLine)){
                     if(!ObjectMove(stacktradeline, 0, Time[0], price)){
                        ShowError("Unable to move stack trade line. Warning! - You will have stack trades opening randomly.");
                     }
                  }
               }//if (ObjectFind(stacktradeline) == -1)               
            }//if (D1TrendTradeOpen || D1H4TrendTradeOpen)            
         }//if (MaxTrendStackTrades > 0)         
      }//if (TicketNo  == -1) 
      
      //upl might not be needed. Depends on the individual EA
      upl+= (OrderProfit() + OrderSwap() + OrderCommission()); 
      //The next line of code calculates the pips upl of an open trade. As yet, I have done nothing with it.
      //something = CalculateTradeProfitInPips()
      
      //Trade types
      if (OrderType() == OP_BUY) 
      {
         if (D1SlopeTrend == buyhold)
         {
            AdaptedBreakEven = true;
            AdaptedJumpingStop = true;
         }//if (D1SlopeTrend == buyhold)         
      }//if (OrderType() == OP_BUY) 
      
      if (OrderType() == OP_SELL) 
      {
         if (D1SlopeTrend == sellhold)
         {
            AdaptedBreakEven = true;
            AdaptedJumpingStop = true;
         }//if (D1SlopeTrend == sellhold)
      }//if (OrderType() == OP_SELL) 
      
      //Add missing tp/sl in case rapidly moving markets prevent their addition - ECN
      if (OrderStopLoss() == 0 && StopLoss > 0) InsertStopLoss(TicketNo);
      if (OrderTakeProfit() == 0 && TakeProfit > 0) InsertTakeProfit(TicketNo);

      //Replace missing tp and sl lines
      ReplaceMissingSlTpLines();
      
      //Check for tp/sl line movements by the user, and adjust the stops accordingly
      string LineName = TpPrefix + DoubleToStr(TicketNo, 0);//TicketNo is set by the calling function - either CountOpenTrades or DoesTradeExist
      if (ObjectFind(LineName) > -1)
      {
         AdjustTakeProfit();
      }//if (ObjectFind(LineName) > -1)
      
      LineName = SlPrefix + DoubleToStr(TicketNo, 0);//TicketNo is set by the calling function - either CountOpenTrades or DoesTradeExist
      if (ObjectFind(LineName) > -1)
      {
         AdjustStopLoss();
      }//if (ObjectFind(LineName) > -1)
      
      
      TradeWasClosed = LookForTradeClosure(OrderTicket() );
      if (TradeWasClosed) 
      {
         cc++;
      }//if (TradeWasClosed) 
         
      //Profitable trade management
      if (OrderProfit() > 0 && !TradeWasClosed) TradeManagementModule();
      
      //There will only ever be one range trade open, so if the open trade is a range, no need to continue
      if (RangeTradeOpen) break;
      
   }//for (int cc = OrdersTotal() - 1; cc <= 0; c`c--)
   
   
   
}//End void CountOpenTrades();

void AdjustTakeProfit()
{
   //Examine the take profit line and adjust the order tp if the user has moved the line
   
   string LineName = TpPrefix + DoubleToStr(TicketNo, 0);
   double take = 0;
   take = ObjectGet(LineName, OBJPROP_PRICE1);
   if (take == 0) return;//Nothing to do
   
   if (OrderType() == OP_BUY) take = NormalizeDouble(take + (HiddenPips / factor), Digits);
   if (OrderType() == OP_SELL) take = NormalizeDouble(take - (HiddenPips / factor), Digits);
   
   if (!CloseEnough(take, OrderTakeProfit()) )
   {
      OrderModify(TicketNo, OrderOpenPrice(), OrderStopLoss(), take, OrderExpiration(), CLR_NONE);
   }//if (!CloseEnough(take, OrderTakeProfit() )
   
}//End void AdjustTakeProfit()

void AdjustStopLoss()
{
   //Examine the stop loss line and adjust the order sl if the user has moved the line
   
   string LineName = SlPrefix + DoubleToStr(TicketNo, 0);
   double stop = 0;
   stop = ObjectGet(LineName, OBJPROP_PRICE1);
   if (stop == 0) return;//Nothing to do
   
   if (OrderType() == OP_BUY) stop = NormalizeDouble(stop - (HiddenPips / factor), Digits);
   if (OrderType() == OP_SELL) stop = NormalizeDouble(stop + (HiddenPips / factor), Digits);
   
   if (!CloseEnough(stop, OrderStopLoss()) )
   {
      Print(Symbol()+" AdjustStopLoss() stop = "+DoubleToStr(stop,Digits)+" OrderStopLoss()= "+DoubleToStr(OrderStopLoss(),Digits) );
      OrderModify(TicketNo, OrderOpenPrice(), stop, OrderTakeProfit(), OrderExpiration(), CLR_NONE);
   }//if (!CloseEnough(stop, OrderStopLoss() )
   
}//End void AdjustStopLoss()


void CreateLine(string name, double price, color col, int style)
{
   if (price == 0) return;
   
   //Delete an existing line
   ObjectDelete(name);
   
   ObjectCreate(name, OBJ_HLINE, 0, TimeCurrent(), price);
   ObjectSet(name, OBJPROP_COLOR, col);
   ObjectSet(name, OBJPROP_STYLE, style);

}//End void CreateLine(double price, color col)

void InsertStopLoss(int ticket)
{
   //Inserts a stop loss if the ECN crim managed to swindle the original trade out of the modification at trade send time
   //Called from CountOpenTrades() if StopLoss > 0 && OrderStopLoss() == 0.
   
   while(IsTradeContextBusy()) Sleep(100);
   if (!OrderSelect(ticket, SELECT_BY_TICKET) || OrderCloseTime() > 0) return;
   
   double stop;
   
   if (OrderType() == OP_BUY)
   {
      stop = CalculateStopLoss(OP_BUY);
   }//if (OrderType() == OP_BUY)
   
   if (OrderType() == OP_SELL)
   {
      stop = CalculateStopLoss(OP_SELL);
   }//if (OrderType() == OP_SELL)
   

   OrderModify(ticket, OrderOpenPrice(), stop, OrderTakeProfit(), OrderExpiration(), CLR_NONE);

}//End void InsertStopLoss(int ticket)

void InsertTakeProfit(int ticket)
{
   //Inserts a TP if the ECN crim managed to swindle the original trade out of the modification at trade send time
   //Called from CountOpenTrades() if TakeProfit > 0 && OrderTakeProfit() == 0.
   
   while(IsTradeContextBusy()) Sleep(100);
   if (!OrderSelect(ticket, SELECT_BY_TICKET) || OrderCloseTime() > 0) return;
   
   double take;
   string origin = D1TrendTrade;
   if (OrderMagicNumber() == D1H4TrendTradeMN) origin = H4TrendTrade;
   if (OrderMagicNumber() == BbRangeTradeMN) origin = BbRangeTrade;
   if (OrderMagicNumber() == WpcRangeTradeMN) origin = WpcRangeTrade;
   
   if (OrderType() == OP_BUY)
   {
      take = CalculateTakeProfit(OP_BUY, origin);
   }//if (OrderType() == OP_BUY)
   
   if (OrderType() == OP_SELL)
   {
      take = CalculateTakeProfit(OP_SELL, origin);
   }//if (OrderType() == OP_SELL)
   

   OrderModify(ticket, OrderOpenPrice(), OrderStopLoss(), take, OrderExpiration(), CLR_NONE);

}//End void InsertStopLoss(int ticket)




///////////////////////////////////////////////////////////////////////////////////////////////////////
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
   double HiddenTakeProfit, HiddenStopLoss;
   
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
   
   if (ObjectFind(LineName) == -1)
   {
      ObjectDelete(LineName);
      ObjectCreate(LineName, OBJ_HLINE, 0, TimeCurrent(), HiddenTakeProfit);
      ObjectSet(LineName, OBJPROP_COLOR, Green);
      ObjectSet(LineName, OBJPROP_WIDTH, 3);
      ObjectSet(LineName, OBJPROP_STYLE, STYLE_SOLID);
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
   
   if (ObjectFind(LineName) == -1)
   {
      ObjectDelete(LineName);
      ObjectCreate(LineName, OBJ_HLINE, 0, TimeCurrent(), HiddenStopLoss);
      ObjectSet(LineName, OBJPROP_COLOR, Red);
      ObjectSet(LineName, OBJPROP_WIDTH, 3);
      ObjectSet(LineName, OBJPROP_STYLE, STYLE_SOLID);
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
///////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////
//TRADE MANAGEMENT MODULE

void ReportError()
{
   //All purpose sl mod error reporter. Called when a sl mod fails
   
   int err=GetLastError();
      
   Alert(OrderTicket()," stop loss modification failed with error(",err,"): ",ErrorDescription(err));
   Print(OrderTicket()," stop loss modification failed with error(",err,"): ",ErrorDescription(err));      

}//void ReportError()

void ShowError(string message){
   int err=GetLastError();
      
   Alert("ERROR:(",err,"): ",ErrorDescription(err)," : ",message);
   Print("ERROR:(",err,"): ",ErrorDescription(err)," : ",message);
}


void BreakEvenStopLoss() // Move stop loss to breakeven
{

   double NewStop;
   bool result;
   bool modify=false;
   string LineName = SlPrefix + DoubleToStr(OrderTicket(), 0);
   double sl = ObjectGet(LineName, OBJPROP_PRICE1);
   
   if (OrderType()==OP_BUY)
   {
      if (OrderStopLoss() >= OrderOpenPrice() - (HiddenPips / factor) ) return;
      if (Bid >= OrderOpenPrice () + (BreakEvenPips / factor))          
      {
         //Calculate the new stop
         NewStop = NormalizeDouble(OrderOpenPrice()+(BreakEvenProfit/ factor), Digits);
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
      }//if (Bid >= OrderOpenPrice () + (BreakEvenPips / factor) && 
   }//if (OrderType()==OP_BUY)               			         
    
   if (OrderType()==OP_SELL)
   {
     if ((OrderStopLoss() <= OrderOpenPrice() + (HiddenPips / factor) ) && OrderStopLoss() > 0) return;
     if (Ask <= OrderOpenPrice() - (BreakEvenPips / factor)) 
     {
         //Calculate the new stop
         NewStop = NormalizeDouble(OrderOpenPrice()-(BreakEvenProfit/ factor), Digits);
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
     }//if (Ask <= OrderOpenPrice() - (BreakEvenPips / factor) && (OrderStopLoss()>OrderOpenPrice()|| OrderStopLoss()==0))     
   }//if (OrderType()==OP_SELL)

   //Move 'hard' stop loss whether hidden or not. Don't want to risk losing a breakeven through disconnect.
   if (modify)
   {
      if (NewStop == OrderStopLoss() ) return;
      while (IsTradeContextBusy() ) Sleep(100);
      result = OrderModify(OrderTicket(), OrderOpenPrice(), NewStop, OrderTakeProfit(), OrderExpiration(), CLR_NONE);      
      if (!result) ReportError();
      else
      {      
         Print(Symbol()+" Jumping SL");
      
         if (OrderType()==OP_BUY)  ObjectMove(LineName, 0, Time[0], NormalizeDouble(NewStop + (HiddenPips/ factor),Digits));
         if (OrderType()==OP_SELL) ObjectMove(LineName, 0, Time[0], NormalizeDouble(NewStop - (HiddenPips/ factor),Digits));
      }
      if (PartCloseEnabled && OrderLots() > Preserve_Lots)// Only try to do this if the jump stop worked
      {
         bool PartCloseSuccess = PartCloseTradeFunction();
         //if (!PartCloseSuccess) SetAGlobalTicketVariable();
      }//if (PartCloseEnabled && OrderLots() > Preserve_Lots)
   }//if (modify)
   
} // End BreakevenStopLoss sub

/*
void JumpingStopLoss() 
{
   // Jump sl by pips and at intervals chosen by user .

   //if (OrderProfit() < 0) return;//Nothing to do.
   
   //Use the sl line if this is drawn on the chart.
   string LineName = SlPrefix + DoubleToStr(OrderTicket(), 0);
   double sl = 0;
   if (ObjectFind(LineName) > -1)
   {
      sl = ObjectGet(LineName, OBJPROP_PRICE1);
   }//if (ObjectFind(LineName) > -1)
   
   //if (sl == 0) return;//No line, so nothing to do
   double NewStop;
   bool modify=false;
   bool result;
   
   
    if (OrderType()==OP_BUY)
    {
       //if (sl < OrderOpenPrice() ) return;//Not at breakeven yet
       // Increment sl by sl + JumpingStopPips.
       // This will happen when market price >= (sl + JumpingStopPips)
       //if (Bid>= sl + ((JumpingStopPips*2)/ factor) )
       if (sl == 0) sl = MathMax(sl, OrderOpenPrice());//No hidden stop loss line
       if (Bid >=  sl + ((JumpingStopPips * 2) / factor) )//George{
       {
          NewStop = NormalizeDouble(sl + (JumpingStopPips / factor), Digits);
          if (AddBEP) NewStop = NormalizeDouble(NewStop + (BreakEvenProfit/ factor), Digits);
          if (HiddenPips > 0) ObjectMove(LineName, 0, Time[0], NewStop);
          if (NewStop - OrderStopLoss() >= Point) modify = true;//George again. What a guy
       }// if (Bid>= sl + (JumpingStopPips/ factor) && sl>= OrderOpenPrice())     
    }//if (OrderType()==OP_BUY)
       
       if (OrderType()==OP_SELL)
       {
          //if (sl > OrderOpenPrice() ) return;//Not at breakeven yet
          // Decrement sl by sl - JumpingStopPips.
          // This will happen when market price <= (sl - JumpingStopPips)
          //if (Bid<= sl - ((JumpingStopPips*2)/ factor)) Original code
          if (sl == 0) sl = MathMin(sl, OrderOpenPrice());//No hidden stop loss line
          if (Bid <= sl - ((JumpingStopPips * 2) / factor) )//George
          {
             NewStop = NormalizeDouble(sl - (JumpingStopPips / factor), Digits);
             if (AddBEP) NewStop = NormalizeDouble(NewStop - (BreakEvenProfit/ factor), Digits);
             if (HiddenPips > 0) ObjectMove(LineName, 0, Time[0], NewStop);
             if (OrderStopLoss() - NewStop >= Point || OrderStopLoss() == 0) modify = true;//George again. What a guy   
          }// close if (Bid>= sl + (JumpingStopPips/ factor) && sl>= OrderOpenPrice())         
       }//if (OrderType()==OP_SELL)



   //Move 'hard' stop loss whether hidden or not. Don't want to risk losing a breakeven through disconnect.
   if (modify)
   {
      while (IsTradeContextBusy() ) Sleep(100);
      result = OrderModify(OrderTicket(), OrderOpenPrice(), NewStop, OrderTakeProfit(), OrderExpiration(), CLR_NONE);      
      if (!result) ReportError();      

      if (PartCloseEnabled && OrderLots() > Preserve_Lots)// Only try to do this if the jump stop worked
      {
         bool PartCloseSuccess = PartCloseTradeFunction();
         //if (!PartCloseSuccess) SetAGlobalTicketVariable();
      }//if (PartCloseEnabled && OrderLots() > Preserve_Lots)
   }//if (modify)

} //End of JumpingStopLoss sub
*/

//Philippe's code.
void JumpingStopLoss() 
{
   // Jump sl by pips and at intervals chosen by user .
   //if (OrderProfit() < 0) return;//Nothing to do.
   
   //Use the sl line if this is drawn on the chart.
   string LineName = SlPrefix + DoubleToStr(OrderTicket(), 0);
   double sl = OrderStopLoss();
   double real_sl = 0;
   
   if (ObjectFind(LineName) > -1 || HiddenPips > 0)
   {
      sl = ObjectGet(LineName, OBJPROP_PRICE1);
            
   }//if (ObjectFind(LineName) > -1)
   
   //if (sl == 0) return;//No line, so nothing to do
   double NewStop;
   bool modify=false;
   bool result;
   
   
    if (OrderType()==OP_BUY)
    {

       if (sl == 0) real_sl = OrderStopLoss();
       else real_sl = NormalizeDouble(sl - (HiddenPips/ factor),Digits);  

       if (real_sl < OrderOpenPrice() ) return;//Not at breakeven yet

       if (real_sl == 0) real_sl = OrderOpenPrice();                          //No hidden stop loss line
       if (Bid >=  real_sl + ((JumpingStopPips * 2) / factor) )
       {
          NewStop = NormalizeDouble(real_sl + (JumpingStopPips / factor), Digits);
          
          if (AddBEP) NewStop = NormalizeDouble(NewStop + (BreakEvenProfit/ factor), Digits);
          
                    
          if (NewStop - real_sl > Point) modify = true;//George again. What a guy
       }// if (Bid>= sl + (JumpingStopPips/ factor) && sl>= OrderOpenPrice())     
    }//if (OrderType()==OP_BUY)
       
       if (OrderType()==OP_SELL)
       {

       if (sl == 0) real_sl = OrderStopLoss();
       else real_sl = NormalizeDouble(sl + (HiddenPips/ factor),Digits);  
              
          if (real_sl > OrderOpenPrice() ) return;//Not at breakeven yet

          if (real_sl== 0) real_sl = OrderOpenPrice();                           //No hidden stop loss line
          if (Bid <= real_sl - ((JumpingStopPips * 2) / factor) )
          {
             NewStop = NormalizeDouble(real_sl - (JumpingStopPips / factor), Digits);
             
             if (AddBEP) NewStop = NormalizeDouble(NewStop - (BreakEvenProfit/ factor), Digits);
             
                          
             if (real_sl - NewStop > Point) modify = true;//George again. What a guy   
          }// close if (Bid>= sl + (JumpingStopPips/ factor) && sl>= OrderOpenPrice())         
       }//if (OrderType()==OP_SELL)


             
   //Move 'hard' stop loss whether hidden or not. Don't want to risk losing a breakeven through disconnect.
   if (modify)
   {
      while (IsTradeContextBusy() ) Sleep(100);
      result = OrderModify(OrderTicket(), OrderOpenPrice(), NewStop, OrderTakeProfit(), OrderExpiration(), CLR_NONE);      
      if (!result) ReportError();
      else
      {      
         Print(Symbol()+" Jumping SL");
      
         if (OrderType()==OP_BUY)  ObjectMove(LineName, 0, Time[0], NormalizeDouble(NewStop + (HiddenPips/ factor),Digits));
         if (OrderType()==OP_SELL) ObjectMove(LineName, 0, Time[0], NormalizeDouble(NewStop - (HiddenPips/ factor),Digits));
      }
      if (PartCloseEnabled && OrderLots() > Preserve_Lots)// Only try to do this if the jump stop worked
      {
         bool PartCloseSuccess = PartCloseTradeFunction();
         //if (!PartCloseSuccess) SetAGlobalTicketVariable();
      }//if (PartCloseEnabled && OrderLots() > Preserve_Lots)
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
          sl = MathMax(sl, OrderOpenPrice());
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
          sl = MathMin(sl, OrderOpenPrice());
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
      if (!result) ReportError();
      else
      {      
         Print(Symbol()+" Jumping SL");
      
         if (OrderType()==OP_BUY)  ObjectMove(LineName, 0, Time[0], NormalizeDouble(NewStop + (HiddenPips/ factor),Digits));
         if (OrderType()==OP_SELL) ObjectMove(LineName, 0, Time[0], NormalizeDouble(NewStop - (HiddenPips/ factor),Digits));
      }
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
   if (sl == 0) return;//No line, so nothing to do
   double NewStop;
   bool modify=false;
   bool result;
   

   if (OrderType() == OP_BUY)
   {
      if (iLow(NULL, CstTimeFrame, CstTrailCandles) > sl)
      {
         NewStop = NormalizeDouble(iLow(NULL, CstTimeFrame, CstTrailCandles), Digits);
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
      if (!result) ReportError();
      else
      {      
         Print(Symbol()+" Jumping SL");
      
         if (OrderType()==OP_BUY)  ObjectMove(LineName, 0, Time[0], NormalizeDouble(NewStop + (HiddenPips/ factor),Digits));
         if (OrderType()==OP_SELL) ObjectMove(LineName, 0, Time[0], NormalizeDouble(NewStop - (HiddenPips/ factor),Digits));
      }
   }//if (modify)

}//End void CandlestickTrailingStop()

bool PartCloseTradeFunction()
   {
      // Called when any attempt to part-close a long trade is needed.
      // Trade has already been selected 
      // Returns 'true' if succeeds, else false, after setting a global variable to tell
      // the basket monitoring function that a closure failed and needs to be attempted
      // again.
      
      double price;
      RefreshRates();
      if (OrderType()==OP_BUY) price = Bid;
      if (OrderType()==OP_SELL) price = Ask;
      
            
      bool result=OrderClose(OrderTicket(), Close_Lots, price, 5, CLR_NONE);
      if (result)
      {
         Alert("Partial close of ", OrderSymbol(), " ticket no ", OrderTicket());
         return(true);
      }
      else
      {
         int err=GetLastError();
         Alert("Partial close of ", OrderSymbol(), " ticket no ", OrderTicket()," failed with error (",err,"): ",ErrorDescription(err));
         Print("Partial close of ", OrderSymbol(), " ticket no ", OrderTicket()," failed with error (",err,"): ",ErrorDescription(err));
         return(false);
      }                          
   
}// End bool PartCloseTradeFunction()

void TradeManagementModule()
{

   // Call the working subroutines one by one. 

   //Candlestick trailing stop
   if (UseCandlestickTrailingStop) CandlestickTrailingStop();


   // Breakeven
   if(AdaptedBreakEven) BreakEvenStopLoss();

   // JumpingStop
   if(AdaptedJumpingStop) JumpingStopLoss();

   //TrailingStop
   if(TrailingStop) TrailingStopLoss();

   

}//void TradeManagementModule()
//END TRADE MANAGEMENT MODULE
////////////////////////////////////////////////////////////////////////////////////////////////



double CalculateTradeProfitInPips()
{
   //This function returns the profit/loss of an individual trade in pips. The function is called from
   //within CountTrades(), so the trade is already selected

   double Pips;
   
   //This returns Pips as a whole number
   Pips = (OrderProfit() / OrderLots()) / MarketInfo(OrderSymbol(),MODE_TICKVALUE);

   double digits = MarketInfo(OrderSymbol(), MODE_DIGITS);
   int multiplier;
   if (digits == 2) multiplier = 10;
   if (digits == 3) multiplier = 100;
   if (digits == 4) multiplier = 1000;
   if (digits == 5) multiplier = 10000;
   
   //This returns Pips as a decimal number i.e. Pips / factor
   //Pips = (OrderProfit() / OrderLots()) / MarketInfo(OrderSymbol(),MODE_TICKVALUE) / multiplier;

   return(Pips);

}//double CalculateTradeProfitInPips()

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
   
   if (MathAbs(num1 - num2) < 0.00001) return(true);//Doubles are equal
   
   //Doubles are unequal
   return(false);

}//End bool CloseEnough(double num1, double num2)

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Balance/swap filters module
void TradeDirectionBySwap()
{

   //Sets TradeLong & TradeShort according to the positive/negative swap it attracts

   double LongSwap = MarketInfo(Symbol(), MODE_SWAPLONG);
   double ShortSwap = MarketInfo(Symbol(), MODE_SWAPSHORT);
   

   if (CadPairsPositiveOnly)
   {
      if (StringSubstr(Symbol(), 0, 3) == "CAD" || StringSubstr(Symbol(), 0, 3) == "cad" || StringSubstr(Symbol(), 3, 3) == "CAD" || StringSubstr(Symbol(), 3, 3) == "cad" )      
      {
         if (LongSwap > 0) TradeLong = true;
         else TradeLong = false;
         if (ShortSwap > 0) TradeShort = true;
         else TradeShort = false;         
      }//if (StringSubstr(Symbol(), 0, 3) == "CAD" || StringSubstr(Symbol(), 0, 3) == "cad" )      
   }//if (CadPairsPositiveOnly)
   
   if (AudPairsPositiveOnly)
   {
      if (StringSubstr(Symbol(), 0, 3) == "AUD" || StringSubstr(Symbol(), 0, 3) == "aud" || StringSubstr(Symbol(), 3, 3) == "AUD" || StringSubstr(Symbol(), 3, 3) == "aud" )      
      {
         if (LongSwap > 0) TradeLong = true;
         else TradeLong = false;
         if (ShortSwap > 0) TradeShort = true;
         else TradeShort = false;         
      }//if (StringSubstr(Symbol(), 0, 3) == "AUD" || StringSubstr(Symbol(), 0, 3) == "aud" || StringSubstr(Symbol(), 3, 3) == "AUD" || StringSubstr(Symbol(), 3, 3) == "aud" )      
   }//if (AudPairsPositiveOnly)
   
   
   if (NzdPairsPositiveOnly)
   {
      if (StringSubstr(Symbol(), 0, 3) == "NZD" || StringSubstr(Symbol(), 0, 3) == "nzd" || StringSubstr(Symbol(), 3, 3) == "NZD" || StringSubstr(Symbol(), 3, 3) == "nzd" )      
      {
         if (LongSwap > 0) TradeLong = true;
         else TradeLong = false;
         if (ShortSwap > 0) TradeShort = true;
         else TradeShort = false;         
      }//if (StringSubstr(Symbol(), 0, 3) == "AUD" || StringSubstr(Symbol(), 0, 3) == "aud" || StringSubstr(Symbol(), 3, 3) == "AUD" || StringSubstr(Symbol(), 3, 3) == "aud" )      
   }//if (AudPairsPositiveOnly)
   
   

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
      if (!MagicNumberTest() ) continue;
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
      if (!MagicNumberTest() ) continue;
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
///////////////////////////////////////////////////////////////////////////////////////////////////////

bool CheckIfBadTrade()
{
   // Try to avoid rapid open/close trades

   int NbHistoTrade = OrdersHistoryTotal();
   if (NbHistoTrade == 0) return(false);

   // check  max last 10 trades
   int NbTradeToAnalyse = MathMin(10, NbHistoTrade);
   for (int i=NbHistoTrade; i > NbHistoTrade-NbTradeToAnalyse; i--)
   {
      if (OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)==false) continue;
      if (OrderSymbol() != Symbol()) continue;   
      if (TimeCurrent() - OrderOpenTime() < 60) return(true);
   }//for (int i=NbHistoTrade; i > NbHistoTrade-NbTradeToAnalyse; i--)
   return(false);
}//End bool CheckIfBadTrade()

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


//---------------------------------------------------------------------
// IsCorrelated()
// @desc    Calculates the correlation between a give fx pair and all open trades
// @param   string   fx1      first fx pair       
// @return  bool     returns true if there is a high correlation, else false
bool IsCorrelated(string fx1)
{
   if (OrdersTotal()==0) return (0);      // no open trades means no correlation...
   
   for (int i=0;i<OrdersTotal();i++)      // loop through all open orders
   {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==true)    // we successfully selected an open order
      {
         double correlation=CalcCorrelation(fx1, OrderSymbol(), Period(), 50);
         if (correlation>0 && correlation>HighCorrelation)
         {
            //Alert("Correlation between ",fx1," and ",OrderSymbol()," is: ", DoubleToStr(correlation,2));
            return (true);
         }
         else if (correlation<0 && MathAbs(correlation)>HighCorrelation) 
         {
            //Alert("Negative correlation between ",fx1," and ",OrderSymbol()," is: ", DoubleToStr(correlation,2));
            return (true);
         }
         else 
         {
            //Alert ("Correlation between ",fx1," and ",OrderSymbol(), " is: ", DoubleToStr(correlation,2));
         }
      }
   }
   return (false);
}

//---------------------------------------------------------------------
// CalcCorrelation()
// @desc    Calculates the correlation between two currency pairs
// @param   string   fx1      first fx pair       
// @param   string   fx2      second fx pair
// @param   int      tf       timeframe (in minutes)
// @param   int      periods  period to calc correlation for (e.g. last 20 bars for given tf)
// @return  double         returns the correlation
double CalcCorrelation(string fx1, string fx2, int tf, int periods)
  {
   double fx1.close[];   // get close value for first pair
   double fx2.close[];   // get close value for second pair
   double corr.avg1=0.0,
          corr.avg2=0.0,
          corr.sum=0.0,
          corr.dev1=0.0,
          corr.dev2=0.0,
          corr.ro1=0.0,
          corr.ro2=0.0,
          corr=0.0;
   
   ArrayResize(fx1.close, periods);  // adjust array size
   ArrayResize(fx2.close, periods);
   
   ArrayInitialize(fx1.close,0);    // initialize array with zero's
   ArrayInitialize(fx2.close,0);
   
   for (int i=0;i<periods;i++)
     {
      while(fx1.close[i]==0)  // force mt4 to load history
        {
         fx1.close[i]=iClose(fx1,tf,i);
        }
      while(fx2.close[i]==0)
        {
         fx2.close[i]=iClose(fx2,tf,i);
        }
      
      // sum close values for calculating average
      corr.avg1 +=fx1.close[i];
      corr.avg2 +=fx2.close[i];

     } // end for
   
   corr.avg1 /= periods; // calc average close
   corr.avg2 /= periods; 
   
   for (i=0;i<periods;i++)
     {
      corr.dev1=fx1.close[i]-corr.avg1;
      corr.dev2=fx2.close[i]-corr.avg2;
      corr.sum += corr.dev1*corr.dev2;
      corr.ro1 +=corr.dev1*corr.dev1;
      corr.ro2 +=corr.dev2*corr.dev2;
     }
     
   corr = MathSqrt(corr.ro1)*MathSqrt(corr.ro2);
   if (corr==0) return(0); // no correlation
   
   return ((corr.sum/corr)*100);
  } //end CalcCorrelation


//---------------------------------------------------------------------
// GenMagic
// @desc    Generates a unique magic number (hash)
// @param   string   suffix   additional suffix to create different magics for different style trades       
// @return  int               returns the unique magic number
int GenMagic(string suffix="")
{	int m;
   string s=Symbol()+"_"+suffix;
	for(int c=0;c<StringLen(s);c++)
	{
	  m+=StringGetChar(s,c);
	  m+=(m<<10);
	  m^=(m>>6);
	}
	m+=(m<<3);
	m^=(m>>11);
	m+=(m<<15);
	m=MathAbs(m);
	return(m);
}

//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
{
//----

   
   
   /*
   People get twitchy when reading the code being removed from the ex4 file warning, so here is a neat method of
   turning off a function without deleting it, just in case you change your mind and want it later. I actually call
   CalculateTradeProfitInPips() from within CountOpenTrades() and include it here merely as an example.
   */
   if (TurnOff == 1) CalculateTradeProfitInPips();//TurnOff is never 1, so the function is not called
   
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

   //Read the indi's once a minute
   static datetime OldM1BarTime;
   if (EveryTickMode) OldM1BarTime = 0;
   if (OldM1BarTime != iTime(NULL, IndiReadTimeFrame, 0) )
   {
      OldM1BarTime = iTime(NULL, IndiReadTimeFrame, 0);
      ReadIndicatorValues();
   }//if (OldM1BarTime != iTime(NULL, PERIOD_M1, 0)
   
   
   
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
   
      
   ///////////////////////////////////////////////////////////////////////////////////////////////
   //Find open trades.
   CountOpenTrades();

   //Reset various bools
   if (OpenTrades == 0)
   {
      //NB sometimes enforces Brekeven and JumpingStop, so reset these to the user's choice when there are
      //no trades open
      AdaptedBreakEven = BreakEven;
      AdaptedJumpingStop = JumpingStop;
      ObjectDelete(stacktradeline);
   }//if (OpenTrades > 0)


   /////////////////////////////////////////////////////////////////////////////////////////////////////////////////
   //Trading times
   bool TradeTimeOk = CheckTradingTimes();
   if (!TradeTimeOk)
   {
      Comment("Outside trading hours\nstart_hourm-end_hourm: ", start_hourm, "-",end_hourm, "\nstart_houre-end_houre: ", start_houre, "-",end_houre);
      return;
   }//if (!TradeTimeOk)
   /////////////////////////////////////////////////////////////////////////////////////////////////////////////////

   /////////////////////////////////////////////////////////////////////////////////////////////////////////////////

   //Available margin filters
   EnoughMargin = true;//For user display
   MarginMessage = "";
   if (UseScoobsMarginCheck && OpenTrades > 0)
   {
      if(AccountMargin() > (AccountFreeMargin()/100)) 
      {
         MarginMessage = "There is insufficient margin to allow trading. You might want to turn off the UseScoobsMarginCheck input.";
         DisplayUserFeedback();
         return;
      }//if(AccountMargin() > (AccountFreeMargin()/100)) 
      
   }//if (UseScoobsMarginCheck)


   if (UseForexKiwi && AccountMargin() > 0)
   {
      
      double ml = NormalizeDouble(AccountEquity() / AccountMargin() * 100, 2);
      if (ml < FkMinimumMarginPercent)
      {
         MarginMessage = StringConcatenate("There is insufficient margin percent to allow trading. ", DoubleToStr(ml, 2), "%");
         DisplayUserFeedback();
         return;
      }//if (ml < FkMinimumMarginPercent)
      
   }//if (UseForexKiwi && AccountMargin() > 0)

   ///////////////////////////////////////////////////////////////////////////////////////////////         

   ///////////////////////////////////////////////////////////////////////////////////////////////         
   //Trading
      
   if (!StopTrading && !CheckIfBadTrade())
   {      
      LookForTradingOpportunities();
   }//if (!StopTrading)
   ///////////////////////////////////////////////////////////////////////////////////////////////      

   DisplayUserFeedback();
   
//----
   return(0);
}
//+------------------------------------------------------------------+

/*
This little gem saved from http://www.forexfactory.com/showthread.php?p=5661628#post5661628

I found this out. The best time to TP was 2-3 hours into the jpy session. 1-2 hours before the usd session, 
3-4 hours into the usd session and then if there is anything left a couple of hours before the jpy session. 
These seem to be the peak times for price movement and then afterwards a holding pattern or retracement.

http://www.stevehopwoodforex.com/phpBB3/viewtopic.php?p=13188#p13188
Range trades will be SRFs and crossing main pivot lines as range prices go back and forth. In other words price just 
keeps ranging between S1/R1 on non volatile pairs and S2/R2 on more volatile pairs. This causes it to cross the 
pivot line and you get to use tight SL there if you want or try a 2nd level recovery at S/R 1 lines.  I got to see 
these in  April while I was testing and the system worked very well. May was great for trending. You will love 
the system because it does work both ways. You just havent been able to see it yet.

The slope stays inside the 8 lines showing that there is only one real trade available so go the other way when price 
crosses the pivot line. You wont believe how many times it will work. The buy/sell bias of the slope will tell you which 
way you have a better chance of getting to the next S/R line for  your TP. It is a thing of beauty.

*/