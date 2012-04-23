//+-------------------------------------------------------------------------------+ 
//|                                                      mandarine martingale.mq4 |
//|                                                     http://www.forex-tsd.com  |
//|                                                                               |
//|  this ea mod is the work of many talented people but first and foremost       |
//|  it was all started by Alejandro Galindo and his 10                           |
//|  point 3, Mandarine strategy was born                                         |
//|  at Tsd Forum and this is a Martingale version of that                        |
//|                                                                               |
//|                                                                               |
//+-------------------------------------------------------------------------------+
#property copyright "Copyright © 2005, Alejandro Galindo"
#property link      ""


#define EAName      "Mandarine Martingale"

#import "wininet.dll"
   int InternetOpenA(string param1, int param2, string param3, string param4, int param5);
   int InternetOpenUrlA(int param1, string param2, string param3, int param4, int param5, int param6);
   int InternetReadFile(int param1, string paramp, int param3, int &param4[]);
   int InternetCloseHandle(int param1);
#import

#include <stderror.mqh>
#include <stdlib.mqh>

extern string       INFO45                          = "Mandarine Martingale";
extern string       Info1                           = "GMT inputs, which must be set correctly";

extern string       s00                             = "--Set your broker GMT offset below--";
extern bool         UseAutoGMToffset                = true;      // If true, attempt to connect to public time source to detect GMT offset.
extern bool         AutoFallbackOnFail              = true;      // If true, will use the ManualGMToffset value if the EA cannot read from the public time source.
extern int          ManualGMToffset                 = 1;         // Set your broker's GMT Offset here in case AutoGMT fails

extern bool         NoHedge                         = true;
extern bool         StrictNoHedge                   = true;  

extern string       __                              = "Indicators settings";
extern int          FastPeriod                      = 5;  
extern int          SlowPeriod                      = 20;
extern int          mamode                          = MODE_LWMA;
extern int          T3_Period                       = 5;
extern int          t3mamode                        = MODE_EMA;
extern double       b                               = 1.00;  

extern string       FiboPivotSetting                = "FiboPivotLineSettings";
extern color        Resistance_3                    = Magenta;
extern color        Resistance_2                    = Red;
extern color        Resistance_1                    = Red;
extern color        Pivot                           = Gold;
extern color        Support_1                       = LimeGreen;
extern color        Support_2                       = LimeGreen;
extern color        Support_3                       = Aqua;
extern int          Pivottimeframe                  = PERIOD_D1;


extern int          Strategy                        = 1;           // #1=pivots2=MTF Ichimoku Cross3=Schaff and Kama with filter
extern double       Lots                            = 0.01;        // We start with this number of lots
extern int          TakeProfit                      = 110;         // Profit Goal in PIPs for the latest order opened
extern double       multiply                        = 1.7; 
extern int          MaxTrades                       = 15;           // Maximum number of orders to open
extern int          Pips                            = 20;          // Distance in Pips from one order to another
extern int          StopLoss                        = 600;         // StopLoss
extern int          TrailingStop                    = 20;          // Pips to trail the StopLoss
extern int          TrailingStep                    = 0;           // Pip interval to increment Trailing StopLoss by each time
extern bool         RecoveryMode                    = false;        // If non-trading hours blocks opening more than 1 market order to maintain
                                                                    // PIP spacing, then open up 2+ orders as needed if true, only 1 if false.
extern string       s05                             = "--MONEY MANAGEMENT--";       
extern string       MM_0                            = "mm=0, risk is ignored, just use Lots parameter";
extern string       MM_1                            = "mm=1, risk is basic multiplier based on account balance";
extern string       MM_2                            = "mm=2, risk is % of account balance to risk per sequence";

extern int          mm                              = 0;
extern string       MyRisk                          = "set risk to use when calculating lot size";
extern double       risk                            = 15;        // risk to calculate the lots size (only if mm is enabled)
extern bool         TradeMicroLots                  = false;        // will auto-detect account types, but override available here

extern string       s06                             = "--MAGIC NUMBERS--";
extern int          MagicNumber                     = 190722;        // Primary Magic number for all orders placed

extern string       s07                             = "--CUTLOSS SETTING--";
extern bool         MyMoneyProfitTarget             = false;
extern double       My_Money_Profit_Target          = 5000;
extern bool         SecureProfitProtection          = false;
extern string       SP45                            = "If profit made is bigger than SecureProfit we close the orders";
extern int          SecureProfit                    =  15;        // If profit made is bigger than SecureProfit we close the orders
extern string       OTP45                           = "Number of orders to trigger SP Protection";
extern int          OrderstoProtect                 = 3;         // Number of orders to enable the account protection

extern string       s08                             = "--TRADING TIME MANAGEMENT--";
extern string       TTM1                            = "Set time frames when new trades can open.";
extern string       TTM2                            = "If Starthour = Stophour, then trade 24/5.";
extern string       TTM3                            = "If TTMGoFlat=true, close all open trades";
extern string       TTM4                            = "when outside trading hours or days.";
extern int          GMTStartHour                    = 0;            // Start trading at 0:00/GMT
extern int          GMTStopHour                     = 0;            // Stop trading at 23:59/GMT
extern bool         TradeOnFriday                   = true;
extern int          FridayGMTStopHour               =  -1;          // If set to 0 or higher, will prevent new trades from opening on Friday starting at that hour GMT.                                                                   // If used in conjunction with TTMGoFlat, will close all trades at the end of the trading week. 
extern bool         TTMGoFlat                       =  false;

extern string       s09                             = "--DRAWDOWN CONTROL TOOL--";
extern string       DDC1                            = "Max DD in money allowed?";
extern bool         MaxDDControl                    = false;
extern double       MaxAllowedDD                    = -1000.0;
extern string       DDC2                            = "Max DD in percentage allowed?";
extern bool         MaxPercentDDControl             = false;
extern double       MaxAllowedPercentDD             = -30.0;

extern string       s10                             = "--DRAWDOWN REPORTING==";
extern bool         ShowDDinfoOnChart               = true;

extern string       s11                             = "--OTHER SETTINGS--";
extern string       reverse45                       = "If true, the decision to go long/short will be reversed";
extern bool         ReverseCondition                = false;       // if one the decision to go long/short will be reversed
color               ArrowsColor                     = Yellow;      // color for the orders arrows

extern string       s12                             = "-- Use this section to exclude trading days";
extern bool         EnableBlackout                  = True;
extern int          StartBlackoutDay                = 20;
extern int          StartBlackoutMonth              = 12;

extern int          StopBlackoutDay                 = 15;
extern int          StopBlackoutMonth               = 01;

  int                 StartBlackout = 0;
  int                 StopBlackout = 0;


// Program Variables for Time Management
  int                 InternetHandle;
  string              GMTOffsetStatusInfo;
  bool                AutoGMTfailure=false;
  bool                OneTimeInitialize=true;
  bool                EADisabled=false;
  bool                TradingDisabled=false;
  datetime            dtBuyAllowed=0, dtSellAllowed=0; // This is used to control the manual confirmation dialog 

// Program Variables for Order Management
  bool                exitBuy = false, exitSell = false;
  int                 CurrentOpenOrders[2]={0,0};
  int                 MarketOpenOrders[2]={0,0};
  int                 PreviousOpenOrders[2]={0,0};
  datetime            LastOrderOpenTime[2]={0,0};
  double              LastOrderOpenPrice[2]={0,0};
  double              MMProfit[2]={0,0}; // Track MyMoney Profit Target Info
  double              SPProfit[2]={0,0}; // Track Secure Profit Protection Info
  double              sl=0, tp=0, BuyPrice=0, SellPrice=0;
  double              BaseLot=0, myBaseLot=0;
  double              LotSizeArray[100,2]; // Element 99,0 and 99,1 used to hold account balance at start of sequence
                                         // Second dimension *,0 or *,1 is OP_BUY, OP_SELL specification
  double              t3;
  int                 mode=0, myOrderTypetmp=0, slippage=50;

// Program Variables for Order Opening
   double Var1,Var2,Var3,Var4;
   double R;      //range
   double p;       // Standard Pivot
   double r3;
   double r2;
   double r1;
   double s1;
   double s2;
   double s3;
   double day_high=0;
   double day_low=0;
   double nQ=0;
   double nD=0;
   double D=0;
   double Q=0;
   
   double fb,fs,fe,tp1,tp2,tp3;
   double ri,re1,re2,re3,ra1,ra2,ra3;
  
// Program Variables for Statistical Tracking
  double              MaxDD,MaxPercentDD; 

// General Program Variables
  string              text="", TTstatus = "False", MMPTstatus = "False", SPPstatus = "False", LBOT, LSOT;
  double              ActualRiskPercentS, ActualRiskPercentB;
  bool                result;   
  int                 cnt=0, myDigits;

//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
  int init()
{
//---- 
  OneTimeInitialize=true;
  EADisabled=false;
  if (EADisabled) return(0); 
  
  if (false) LogPerformance();
  if (!IsDllsAllowed() && UseAutoGMToffset && !IsTesting())
  {
    Comment("Error: Parameter \"AllowDLL Imports\" must be ON.");
    Print("Error: Parameter \"AllowDLL Imports\" must be ON.");
    EADisabled=true;
    Print("EA Disabled due to DLL setting conflict with UseAutoGMTOffset.");
    Sleep(10000);
    return(0);
  }

  while (!IsConnected())
  {
    Comment("Waiting for connection...");
    Sleep(10000);
  }

  myDigits=MarketInfo(Symbol(),MODE_DIGITS);
  int x;

  if(myDigits==2) x= 1;
  if(myDigits==3) x=10;
  if(myDigits==4) x= 1;
  if(myDigits==5) x=10;

  TakeProfit   *= x;
  StopLoss     *= x;
  Pips         *= x;
  TrailingStop *= x;
  TrailingStep *= x;

  UpdateOrderStatus(true);

  if (MyMoneyProfitTarget) MMPTstatus = "True";
  if (SecureProfitProtection) SPPstatus = "True";

  if (IsTesting())
  {
    CalculateLotArray(OP_BUY,0);
    CalculateLotArray(OP_SELL,0);
  }
  else
  {
    ReadLotArray(); 
  }
  

  MaxTrades = MathMin(MaxTrades, MathCeil(StopLoss / Pips));

StartBlackout = DayNumber(StartBlackoutMonth, StartBlackoutDay);
StopBlackout =  DayNumber(StopBlackoutMonth, StopBlackoutDay);

   return(0);
}


//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
{
//---- 
    if (!IsTesting()) WriteLotArray();
    Print("MaxDD: ",MaxDD);
    Print("MaxPercDD: ",MaxPercentDD); 
    ObjectDelete("S1");
    ObjectDelete("S2");
    ObjectDelete("S3");
    ObjectDelete("SS");   
    ObjectDelete("R1");
    ObjectDelete("R2");
    ObjectDelete("R3");
    ObjectDelete("SR");    
    ObjectDelete("PIVOT");
    ObjectDelete("Support 1");
    ObjectDelete("Support 2");
    ObjectDelete("Support 3");
    ObjectDelete("Pivot level");
    ObjectDelete("Resistance 1");
    ObjectDelete("Resistance 2");
    ObjectDelete("Resistance 3");  
    ObjectDelete("TDR2");
    ObjectDelete("TDR2 Line"); 
    ObjectDelete("BDR2");
    ObjectDelete("BDR2 Line");
    ObjectsDeleteAll(0,OBJ_HLINE);
    ObjectsDeleteAll(0,OBJ_VLINE);
    ObjectsDeleteAll(0,OBJ_LABEL);
    ObjectsDeleteAll(0,OBJ_RECTANGLE);
    ObjectsDeleteAll(0,OBJ_TEXT);
    ObjectsDeleteAll(1,OBJ_LABEL); 
    Comment(" ");
    DeleteAllObjects();    
    Comment(" ");
   return(0);
}




//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
{  
  if (EADisabled)
  {
    if (IsTesting()) Comment("EA Disabled! Check Journal Log for details.\n"+text);
    else Comment("EA Disabled! Check Experts Log for details.\n"+text);
    return(0);
  }
  
  if (OneTimeInitialize)
  {
    while (InitializeTimeVariables() < 0) Sleep(1000);
    return(0);
  }
  
  text="";
  TrackDrawDown();
  exitBuy = false; exitSell = false;
  int CloseOutStatus = CloseOutTradesCheck(); 
  if (CloseOutStatus > 0)                                 
  {
    if (exitBuy)  CloseAllOrders(OP_BUY);
    if (exitSell) CloseAllOrders(OP_SELL);
    if (CloseOutStatus == 2)
    {
      EADisabled = true;
      text="My Money Profit Target Achieved!";
      Print(text);
      return(0);
    }
    if (CloseOutStatus == 3)
    {
      EADisabled = true;
      text="DrawDown Threshold Breached!";
      Print(text);
      return(0);
    }
    
  }
  else 
  {
    bool TT = false;
    if (IsTradingTime() && !TradingDisabled)
    {
      TT = true;
      PrepareIndicators(); 
      
      myOrderTypetmp=CheckEntrySignal();

      if (ReverseCondition)
      {
        if (myOrderTypetmp==1) myOrderTypetmp=2;
        else if (myOrderTypetmp==2) myOrderTypetmp=1;
      }

      if (myOrderTypetmp==1 && CurrentOpenOrders[OP_SELL]==0 && IsTradeAllowed() && dtSellAllowed < TimeCurrent())
      {
        Print("Starting New SELL Sequence");
        OpenMarketOrders(myOrderTypetmp); 
      }

      if (myOrderTypetmp==2 && CurrentOpenOrders[OP_BUY]==0 && IsTradeAllowed() && dtBuyAllowed < TimeCurrent())
      {
        Print("Starting New BUY Sequence");
        OpenMarketOrders(myOrderTypetmp); 
      }

      if (IsTradeAllowed()) OpenMarketOrders(3); 
    }
  }

  TSManager(); 
  
  

  TTstatus = "False";
  if (TT) TTstatus = "True";
  if (SecureProfitProtection && MarketOpenOrders[OP_BUY]>=OrderstoProtect) text=StringConcatenate(text, "\nSecure Profit Protection Active on BUY sequence.");
  if (SecureProfitProtection && MarketOpenOrders[OP_SELL]>=OrderstoProtect) text=StringConcatenate(text, "\nSecure Profit Protection Active on SELL sequence.");
  if (MyMoneyProfitTarget) text=StringConcatenate(text, "\nMy Money Profit Target Progress: ", DoubleToStr(MMProfit[OP_BUY]+MMProfit[OP_SELL],2), " of ", DoubleToStr(My_Money_Profit_Target,2));
  if (!BlackoutTime() && myOrderTypetmp!=2 && CurrentOpenOrders[OP_BUY]==0 && MaxTrades>0) text=StringConcatenate(text, "\nWAITING FOR BUY SIGNAL...");
  if (!BlackoutTime() && myOrderTypetmp!=1 && CurrentOpenOrders[OP_SELL]==0 && MaxTrades>0) text=StringConcatenate(text, "\nWAITING FOR SELL SIGNAL...");
  if (BlackoutTime()) text=StringConcatenate(text, "\n*** Black out Trading Day. If you want the EA to trade, Change the dates set Blackout to False ***");
  if (LastOrderOpenTime[OP_BUY]==0) LBOT="............................";
  else LBOT=TimeToStr(LastOrderOpenTime[OP_BUY],TIME_DATE|TIME_SECONDS);
  if (LastOrderOpenTime[OP_SELL]==0) LSOT="............................";
  else LSOT=TimeToStr(LastOrderOpenTime[OP_SELL],TIME_DATE|TIME_SECONDS);
  string myComment=StringConcatenate(GMTOffsetStatusInfo,ShowLotSizeSequence(),
  "\nIsTradeTime=",TTstatus,", myOrderTypetmp=",myOrderTypetmp,", SPP Enabled=",SPPstatus,", MMPT Enabled=",MMPTstatus,
  "\nBuy: Last Price=",DoubleToStr(LastOrderOpenPrice[OP_BUY],Digits),", Last Time=",LBOT,", Open Mkt Orders=",MarketOpenOrders[OP_BUY],"/",MaxTrades,", Open Profit=",DoubleToStr(SPProfit[OP_BUY],2),
  "\nSell:  Last Price=",DoubleToStr(LastOrderOpenPrice[OP_SELL],Digits),", Last Time=",LSOT,", Open Mkt Orders=",MarketOpenOrders[OP_SELL],"/",MaxTrades,", Open Profit=",DoubleToStr(SPProfit[OP_SELL],2),
  "\nDay of the Year = ",DayOfYear(),", StartBlackout=", StartBlackout, ", StopBlackout=", StopBlackout, ", Blackout= ", BlackoutTime(),
  text);
  Comment(myComment);

  return(0);
}
//+------------------------------------------------------------------+


int CheckEntrySignal()
{
  int myOrderType = 3;
  
    if (Strategy == 1) 
  {
    if (Var1 < Var2 && Var3 >= Var4 && Var1 > t3 && t3 >= r1 && t3 <= r3) 
      myOrderType = 1; // signal a sell
    if (Var1 > Var2 && Var3 <= Var4 && Var1 < t3 && t3 <= s1 && t3 >= s3) 
      myOrderType = 2; // signal a buy
  }
  

  return(myOrderType);
}


void PrepareIndicators()
{
   t3    = iT3(T3_Period);
   Var1  = iMA(Symbol(),0,FastPeriod,0,mamode,PRICE_CLOSE,1);
   Var2  = iMA(Symbol(),0,FastPeriod,0,mamode,PRICE_CLOSE,2);
   Var3  = iMA(Symbol(),0,SlowPeriod,0,mamode,PRICE_OPEN,1);
   Var4  = iMA(Symbol(),0,SlowPeriod,0,mamode,PRICE_OPEN,2);
   
   
   
   double rates[1][6],yesterday_close,yesterday_high,yesterday_low;
   ArrayCopyRates(rates, Symbol(), Pivottimeframe);
   if(DayOfWeek() == 1)
   {
   if(TimeDayOfWeek(iTime(Symbol(),Pivottimeframe,1)) == 5)
   {
   yesterday_close = rates[1][4];
   yesterday_high = rates[1][3];
   yesterday_low = rates[1][2];
   }
   else
   {
   for(int d = 5;d>=0;d--)
   {
   if(TimeDayOfWeek(iTime(Symbol(),Pivottimeframe,d)) == 5)
   {
   yesterday_close = rates[d][4];
   yesterday_high = rates[d][3];
   yesterday_low = rates[d][2];
   }     
   }    
   }
   }
   else
   {
   yesterday_close = rates[1][4];
   yesterday_high = rates[1][3];
   yesterday_low = rates[1][2];
   }
   R = yesterday_high - yesterday_low;//range
   p = (yesterday_high + yesterday_low + yesterday_close)/3;// Standard Pivot
   r3 = p + (R * 1.000);
   r2 = p + (R * 0.618);
   r1 = p + (R * 0.382);
   s1 = p - (R * 0.382);
   s2 = p - (R * 0.618);
   s3 = p - (R * 1.000);
   day_high=0;
   day_low=0;
   nQ=0;
   nD=0;
   D=0;
   Q=0;
   day_high = rates[0][3];
   day_low = rates[0][2];
   D = (day_high - day_low);
   Q = (yesterday_high - yesterday_low);
   double fb,fs,fe,tp1,tp2,tp3;
   double ri,re1,re2,re3,ra1,ra2,ra3;
   if (Q > 5) 
   {
	nQ = Q;
   }
   else
   {
	nQ = Q*10000;
   }

   if (D > 5)
   {
	nD = D;
   }
   else
   {
	nD = D*10000;
   }
   if (StringSubstr(Symbol(),3,3)=="JPY") {
   nQ=nQ/100;
   nD=nD/100;     
   }
   drawLine(r3,"R3", Resistance_3,1);
   drawLabel("Resistance 3",r3,Resistance_3);
   drawLine(r2,"R2", Resistance_2,2);
   drawLabel("Resistance 2",r2,Resistance_2);
   drawLine(r1,"R1", Resistance_1,0);
   drawLabel("Resistance 1",r1,Resistance_1);

   drawLine(p,"PIVOT",Pivot,1);
   drawLabel("Pivot level",p,Pivot);

   drawLine(s1,"S1",Support_1,0);
   drawLabel("Support 1",s1,Support_1);
   drawLine(s2,"S2",Support_2,2);
   drawLabel("Support 2",s2,Support_2);
   drawLine(s3,"S3",Support_3,1);
   drawLabel("Support 3",s3,Support_3); 
 }
   
void TSManager()
{
  if (TrailingStop>0)
  {
    cnt=OrdersTotal()-1;
    while(cnt>=0)
    {
      if(OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES)==false)        break;
      if (IsMyOrder())
      {
        if (OrderType()==OP_SELL) 
        {		
          if ((OrderOpenPrice()-MarketInfo(OrderSymbol(),MODE_ASK))>=(TrailingStop*Point+Pips*Point)) 
          {						
            if (OrderStopLoss()-TrailingStep*Point>(MarketInfo(OrderSymbol(),MODE_ASK)+TrailingStop*Point))
            {										    
              if(GetTradeContext()) RefreshRates();
              result=OrderModify(OrderTicket(),OrderOpenPrice(),MarketInfo(OrderSymbol(),MODE_ASK)+TrailingStop*Point,OrderTakeProfit(),0,Purple);
              if(result!=true) Print("Trailing Stop Error = ", GetLastError());
              else OrderPrint();					
            }
          }
        }
        if (OrderType()==OP_BUY)
        {
          if ((MarketInfo(OrderSymbol(),MODE_BID)-OrderOpenPrice())>=(TrailingStop*Point+Pips*Point)) 
          {
            if (OrderStopLoss()+TrailingStep*Point<(MarketInfo(OrderSymbol(),MODE_BID)-TrailingStop*Point)) 
            {					   
              if(GetTradeContext()) RefreshRates();
              result=OrderModify(OrderTicket(),OrderOpenPrice(),MarketInfo(OrderSymbol(),MODE_BID)-TrailingStop*Point,OrderTakeProfit(),0,ArrowsColor);		
              if(result!=true) Print("Trailing Stop Error = ", GetLastError());                  
              else OrderPrint();
              return(0);
            }
          }
        }
      }
      cnt--;
    }
  }
}


void OpenMarketOrders(int mySignal)
// mySignal = 1 for sell, 2 for buy, 3 for no signal.
{         
  int cnt=0, gle=0, ticket, attempts, myCount;
  bool ModifySucceeded;
  
  if ((mySignal==1 || mySignal==3) 
  && (dtSellAllowed < TimeCurrent())
  && ((CurrentOpenOrders[OP_SELL]>0 && CurrentOpenOrders[OP_SELL]<MaxTrades && (Bid-LastOrderOpenPrice[OP_SELL]>=Pips*Point) && (LastOrderOpenPrice[OP_SELL]>0))
  || (CurrentOpenOrders[OP_SELL]==0 && mySignal==1 && canOpen(OP_SELL))))
  {	     		
    myCount=1;
    if (RecoveryMode && CurrentOpenOrders[OP_SELL]>0 && CurrentOpenOrders[OP_SELL]<MaxTrades && Bid-LastOrderOpenPrice[OP_SELL]>=Pips*Point*2 && canOpen(OP_SELL))
     myCount = MathFloor((Bid-LastOrderOpenPrice[OP_SELL])/(Pips*Point));
    CalculateLotArray(OP_SELL,CurrentOpenOrders[OP_SELL]);
    
    for(cnt=0;cnt<myCount;cnt++)
    {
      ticket=-1;
      attempts=0;
      SellPrice=Bid;				
      if (TakeProfit==0) tp=0;
      else tp=SellPrice-TakeProfit*Point;	
      if (StopLoss==0) sl=0;
      else sl=CalcStopLoss(OP_SELL);
      myBaseLot=LotSizeArray[CurrentOpenOrders[OP_SELL],OP_SELL];

      while( ticket < 0)
      {
        if(GetTradeContext()) RefreshRates();
        if(AccountFreeMarginCheck(Symbol(),OP_SELL,myBaseLot)<=0 || GetLastError()==134)
        {
          Print("NOT ENOUGH MONEY TO OPEN SELL ORDER! No further attempts to open new trades will occur.  Monitoring existing orders.");
          Alert("NOT ENOUGH MONEY TO OPEN SELL ORDER! No further attempts to open new trades will occur.  Monitoring existing orders.");
          TradingDisabled=true;
          return;
        }
  
        ticket=OrderSend(Symbol(),OP_SELL,myBaseLot,NormalizeDouble(SellPrice,myDigits),slippage,0,0,EAName+" EA "+MagicNumber,MagicNumber,0,ArrowsColor);
        if(ticket>0)
        {
          if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES))
          {
            Print("SELL order opened : ",OrderOpenPrice());
            LastOrderOpenPrice[OP_SELL]=OrderOpenPrice();
            LastOrderOpenTime[OP_SELL]=OrderOpenTime();
            UpdateOrderStatus(true);
            break;
          }
        }         			
        else
        {
          gle=GetLastError();
          if (gle==2 || gle==144)
          {
            dtSellAllowed = TimeCurrent() + 3600;
            Print("Manual Trade Confirmation Dialog aborted. No Sell Positions will be attempted for the next 1 hour.");
            return;
          }
          Print("Error opening SELL order : ",gle);
          attempts++;
          Sleep(5000);
          RefreshRates();
        }
        if(attempts >= 20)
        {
          Print("20 attempts to open SELL position have failed");
          break;
        }
      }	
      ModifySucceeded=false;
      attempts=0;
      while(!ModifySucceeded && attempts<100)
      {
        if(GetTradeContext()) RefreshRates();
        ModifySucceeded=OrderModify(ticket,OrderOpenPrice(),sl,tp,0,GreenYellow);
        if(!ModifySucceeded)
        {
          gle=GetLastError();
          if (gle==2 || gle==144 || gle==4051)
          {
            Print("Manual Trade Confirmation Dialog aborted or invalid ticket. No Sell Positions will be attempted for the next 1 hour.");
            dtSellAllowed = TimeCurrent() + 3600;
            return;
          }
          Print("Error modifying SELL order : ",gle);
          attempts++;
          Sleep(2000);
          RefreshRates();
        }
      }
      if(attempts >= 50)
      {
        Print("A Critical Error Occurred! The expert could not modify SELL position!");
      }
      if (tp > 0)
      {
        ModifyTakeProfits(tp, MagicNumber, OP_SELL);
      }
    }
  }

  if ((mySignal==2 || mySignal==3) 
  && (dtBuyAllowed < TimeCurrent())
  && ((CurrentOpenOrders[OP_BUY]>0 && CurrentOpenOrders[OP_BUY]<MaxTrades && (LastOrderOpenPrice[OP_BUY]-Ask>=Pips*Point) && (LastOrderOpenPrice[OP_BUY]>0))
  || (CurrentOpenOrders[OP_BUY]==0 && mySignal==2 && canOpen(OP_BUY))))
  {			      
    myCount=1;
    if (RecoveryMode && CurrentOpenOrders[OP_BUY]>0 && CurrentOpenOrders[OP_BUY]<MaxTrades && LastOrderOpenPrice[OP_BUY]-Ask>=Pips*Point*2 && canOpen(OP_BUY))
    myCount = MathFloor((LastOrderOpenPrice[OP_BUY]-Ask)/(Pips*Point));
    CalculateLotArray(OP_BUY,CurrentOpenOrders[OP_BUY]);

    for(cnt=0;cnt<myCount;cnt++)
    {
      ticket=-1;
      attempts=0;
      BuyPrice=Ask;
      if (TakeProfit==0) tp=0;
      else tp=BuyPrice+TakeProfit*Point;
      if (StopLoss==0) sl=0;
      else sl=CalcStopLoss(OP_BUY);
      myBaseLot=LotSizeArray[CurrentOpenOrders[OP_BUY],OP_BUY];
      
      while( ticket < 0)
      {
        if(GetTradeContext()) RefreshRates();
        if(AccountFreeMarginCheck(Symbol(),OP_BUY,myBaseLot)<=0 || GetLastError()==134)
        {
          Print("NOT ENOUGH MONEY TO OPEN BUY ORDER! No further attempts to open new trades will occur.  Monitoring existing orders.");
          Alert("NOT ENOUGH MONEY TO OPEN BUY ORDER! No further attempts to open new trades will occur.  Monitoring existing orders.");
          TradingDisabled=true;
          return;
        }

        ticket=OrderSend(Symbol(),OP_BUY,myBaseLot,NormalizeDouble(BuyPrice,myDigits),slippage,0,0,EAName+" EA "+MagicNumber,MagicNumber,0,ArrowsColor);
        if(ticket>0)
        {
          if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES))
          {
            Print("BUY order opened : ",OrderOpenPrice());
            LastOrderOpenPrice[OP_BUY]=OrderOpenPrice();
            LastOrderOpenTime[OP_BUY]=OrderOpenTime();
            UpdateOrderStatus(true);
            break;
          }
        }         			
        else
        {
          gle=GetLastError();
          if (gle==2 || gle==144)
          {
            Print("Manual Trade Confirmation Dialog aborted. No Buy Positions will be attempted for the next 1 hour.");
            dtBuyAllowed = TimeCurrent() + 3600;
            return;
          }
          Print("Error opening BUY order : ",gle);
          attempts++;
          Sleep(5000);
          RefreshRates();
        }
        if(attempts >= 20)
        {
          Print("20 attempts to open BUY position have failed");
          break;
        }
      }
      ModifySucceeded=false;
      attempts=0;
      while(!ModifySucceeded && attempts<100)
      {
        if(GetTradeContext()) RefreshRates();
        ModifySucceeded=OrderModify(ticket,OrderOpenPrice(),sl,tp,0,GreenYellow);
        if(!ModifySucceeded)
        {
          gle=GetLastError();
          if (gle==2 || gle==144 || gle==4051)
          {
            Print("Manual Trade Confirmation Dialog aborted or invalid ticket. No Buy Positions will be attempted for the next 1 hour.");
            dtBuyAllowed = TimeCurrent() + 3600;
            return;
          }
          Print("Error modifying BUY order : ",gle);
          Print("cnt=",cnt,", myBaseLot=",myBaseLot,", BuyPrice=",BuyPrice,", ticket=",ticket);
          attempts++;
          Sleep(2000);
          RefreshRates();
        }
      }
      if(attempts >= 50)
      {
        Print("A Critical Error Occurred! The expert could not modify BUY position!");
      }
      if (tp > 0)
      {
        ModifyTakeProfits(tp, MagicNumber, OP_BUY);
      }
    }
  }
}   


bool GetTradeContext()
{
  bool hadToWait=false;
  
  while(!IsTradeAllowed())
  {
    Sleep(5000);
    hadToWait=true;
  }
  
  while(IsTradeContextBusy())
  {
    Sleep(200);
    hadToWait=true;
  }
  
  return(hadToWait);
}


void DeleteAllObjects()
{
  ObjectDelete("MaxDD");
  ObjectDelete("B/E");
  int    obj_total=ObjectsTotal();
  string name;
  for(int i=0;i<=obj_total;i++)
  {
    name=ObjectName(i);
    if (name!="") ObjectDelete(name);
  }
}


bool IsTradingTime()
{
   if (BlackoutTime()) return(false);  // Added for blackout dates
   int currentDay = TimeDayOfWeek(TimeCurrent() - 3600 * ManualGMToffset);
   int currentHour = TimeHour(TimeCurrent() - 3600 * ManualGMToffset);
   if (!TradeOnFriday && currentDay >= 5) return(false); // GMT Adjusted Day of Week
   if (currentDay >= 5 && currentHour >= FridayGMTStopHour && FridayGMTStopHour >= 0) return(false);
   if (GMTStartHour == GMTStopHour) return(true);
   return(IsTradingTimeSub(GMTStartHour, GMTStopHour));
}


bool IsTradingTimeSub(int myStartHour, int myEndHour)
{
   int currentHour = TimeHour(TimeCurrent() - 3600 * ManualGMToffset);
   int adjustedEndHour = NormalizedHourParam(myEndHour - 1);

   if (myStartHour == adjustedEndHour) if (currentHour != myStartHour) return(false);
   if (myStartHour > adjustedEndHour)  if (currentHour < myStartHour && currentHour > adjustedEndHour) return(false);
   if (myStartHour < adjustedEndHour)  if (currentHour < myStartHour || currentHour > adjustedEndHour) return(false);

   return(true);
}


string GMTSourceURL = "http://wwp.greenwichmeantime.com/time/scripts/clock-8/x.php";
string GMTUserAgent = "Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.0; Trident/4.0)";
int AutoGMTOffset()
{
  string gvName1 = StringConcatenate(AccountNumber(),"_GMTOffset_Value");
  string gvName2 = StringConcatenate(AccountNumber(),"_GMTOffset_Timestamp");
  double gvValue1 = GlobalVariableGet(gvName1);
  double gvValue2 = GlobalVariableGet(gvName2);

  if ((GlobalVariableCheck(gvName1) && GlobalVariableCheck(gvName2))
  && !((DayOfWeek() < TimeDayOfWeek(gvValue2)) ||
       (DayOfWeek()== TimeDayOfWeek(gvValue2) && TimeCurrent()-gvValue2 > 86400) ||
       (DayOfWeek() > TimeDayOfWeek(gvValue2) && TimeCurrent()-gvValue2 > 604800)))
      
  {
    return (gvValue1);
  }
  else
  {
    Comment("Connecting to public GMT time source...");
    string status;
    int result, offsetTmp;
    InternetHandle = InternetOpenA(GMTUserAgent, 0, "0", "0", 0);
    string myBuffer = "ABCDEFGHIJ";
    if (!RetrieveURLData(GMTSourceURL, myBuffer))
    {
      if (InternetHandle == 0) status = "Error connecting to AutoGMT time source.";
      result = -999999999;
      Comment(status);
      Print(status);
      Sleep(3000);
    }
    else
    {
      offsetTmp = TimeCurrent() - StrToInteger(myBuffer);
      result = MathFloor((offsetTmp + 1800) / 3600);
      if (result <= 24 && result >= -24)
      {
        GlobalVariableSet(gvName1,result);
        GlobalVariableSet(gvName2,TimeCurrent());
        //Print ("Successfully stored GMT Offset in globals");
      }
    }
    InternetCloseHandle(InternetHandle);
    return(result);
  }
}


bool RetrieveURLData(string URL, string &datum)
{
  int thisHandle = InternetOpenUrlA(InternetHandle, URL, "0", 0, -2080374528, 0);
  if (thisHandle == 0) return (false); //failure
  int a[] = {1};
  string anotherBuffer = "abcdefghij";
  int myStatus = InternetReadFile(thisHandle, anotherBuffer, 10, a);
  if (thisHandle != 0) InternetCloseHandle(thisHandle);
  datum = anotherBuffer;
  return(true); 
}

int NormalizedHourParam(int myParam)
{
  while (true)
  {
    if (myParam >= 24)
    {
       myParam -= 24;
       continue;
    }
    if (myParam >= 0) break;
    myParam += 24;
  }
  return(myParam);
}

void TrackDrawDown()
{
  double OpenProfit = SPProfit[0]+SPProfit[1];
  if (OpenProfit < MaxDD) MaxDD = OpenProfit;
  if ((OpenProfit/AccountBalance())*100 < MaxPercentDD) MaxPercentDD = (OpenProfit/AccountBalance())*100;

  if (ShowDDinfoOnChart)
  {
    ObjectCreate( "B/E", OBJ_LABEL,0,0,0,0,0,0);
    ObjectSet(    "B/E", OBJPROP_CORNER,3);
    ObjectSet(    "B/E", OBJPROP_XDISTANCE, 3);
    ObjectSet(    "B/E", OBJPROP_YDISTANCE, 30);
    ObjectSetText("B/E", "B/E: $"+DoubleToStr(NormalizeDouble(AccountBalance(),2),2)+"/"+DoubleToStr(NormalizeDouble(AccountEquity(),2),2),12,"Impact",White);

    ObjectCreate( "MaxDD", OBJ_LABEL,0,0,0,0,0,0);
    ObjectSet(    "MaxDD", OBJPROP_CORNER,3);
    ObjectSet(    "MaxDD", OBJPROP_XDISTANCE, 3);
    ObjectSet(    "MaxDD", OBJPROP_YDISTANCE, 2);
    ObjectSetText("MaxDD", "RDD Max: $"+DoubleToStr(NormalizeDouble(MaxDD,2),2)+"/"+DoubleToStr(NormalizeDouble(MaxPercentDD,2),1)+"%",12,"Impact",White);
  }
  return;
}

int CloseOutTradesCheck()
{
  int result = 0;
  
  if (MyMoneyProfitTarget)
  {
    MMProfit[0]=0;
    MMProfit[1]=0;
    for(cnt=0;cnt<OrdersTotal();cnt++)
    {
      if (OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES))
      {
        if (IsMyOrder()) MMProfit[OrderType()] += OrderProfit() + OrderSwap() + OrderCommission();
      }
    }
    
    for(cnt=0;cnt<OrdersHistoryTotal();cnt++)
    {
      if (OrderSelect(cnt, SELECT_BY_POS, MODE_HISTORY))
      {
        if (IsMyOrder()) MMProfit[OrderType()] += OrderProfit() + OrderSwap() + OrderCommission();
      }
    }

    if ((MMProfit[OP_BUY]+MMProfit[OP_SELL]) >= My_Money_Profit_Target)
    {
      text = text + "\nClosing all orders and stop trading because My_Money_Profit_Target reached for this symbol.";
      Print("Closing all orders and stop trading because My_Money_Profit_Target reached for this symbol.");
      Print("Profit: ",NormalizeDouble(MMProfit[OP_BUY]+MMProfit[OP_SELL],2)," Equity: ",NormalizeDouble(AccountEquity(),2));
      result = 2;
      exitBuy = true;
      exitSell = true;
    }
  }

  SPProfit[0]=0;
  SPProfit[1]=0;
  for(cnt=0;cnt<OrdersTotal();cnt++)
  {
    if (OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES))
    {
      if (IsMyOrder()) SPProfit[OrderType()] += OrderProfit() + OrderSwap() + OrderCommission();
    }
  }

  if (SecureProfitProtection && SPProfit[OP_BUY]>=SecureProfit && MarketOpenOrders[OP_BUY]>=OrderstoProtect) 
  {
    text = text + "\nClosing BUY orders because account protection with SecureProfit was triggered.";
    Print("Closing BUY orders because account protection with SecureProfit was triggered.");
    Print("Balance: ",NormalizeDouble(AccountBalance(),2)," Equity: ", NormalizeDouble(AccountEquity(),2)," Profit: ",NormalizeDouble(SPProfit[OP_BUY],2));
    result = 1;
    exitBuy = true;
  }

  if (SecureProfitProtection && SPProfit[OP_SELL]>=SecureProfit && MarketOpenOrders[OP_SELL]>=OrderstoProtect) 
  {
    text = text + "\nClosing SELL orders because account protection with SecureProfit was triggered.";
    Print("Closing SELL orders because account protection with SecureProfit was triggered.");
    Print("Balance: ",NormalizeDouble(AccountBalance(),2)," Equity: ", NormalizeDouble(AccountEquity(),2)," Profit: ",NormalizeDouble(SPProfit[OP_SELL],2));
    result = 1;
    exitSell = true;
  }

  UpdateOrderStatus(true);
  if (PreviousOpenOrders[OP_BUY] > CurrentOpenOrders[OP_BUY])
  {
    exitBuy = true;
    result = 1;
  }

  if (PreviousOpenOrders[OP_SELL] > CurrentOpenOrders[OP_SELL])
  {
    exitSell = true;
    result = 1;
  }

  if (!IsTradingTime() && TTMGoFlat && CurrentOpenOrders[0]+CurrentOpenOrders[1]>0)
  {
    text = text + "\nClosing orders because outside of trading window.";
    Print("Closing orders because outside of trading window.");
    Print("Balance: ",NormalizeDouble(AccountBalance(),2)," Equity: ", NormalizeDouble(AccountEquity(),2)," Profit: ",NormalizeDouble(SPProfit[OP_BUY]+SPProfit[OP_SELL],2));
    exitBuy = true;
    exitSell = true;
    result = 1;
  }

  if ((MaxDDControl && MathAbs(MaxDD)>=MathAbs(MaxAllowedDD)) || (MaxPercentDDControl && MathAbs(MaxPercentDD)>=MathAbs(MaxAllowedPercentDD)))
  {
    exitBuy = true;
    exitSell = true;
    result = 3;
  }

  return(result);   
}

void CalculateLotArray(int myDirection,int openTradeCount)
{
  double MaxLossAmount;
  if (mm <= 0 || mm > 2 )
  {
    LotSizeArray[0,myDirection]=NormalizedLots(Lots,true);
    for (cnt=1;cnt<MaxTrades;cnt++) LotSizeArray[cnt,myDirection]=LotSizeArray[cnt-1,myDirection]*multiply;
    for (cnt=1;cnt<MaxTrades;cnt++) LotSizeArray[cnt,myDirection]=NormalizedLots(LotSizeArray[cnt,myDirection],true);
    if (openTradeCount==0) LotSizeArray[99,myDirection]=AccountBalance();
  }

  if (mm == 1)
  {
    if (openTradeCount==0 || (openTradeCount>0 && AccountBalance() > LotSizeArray[99,myDirection]))
    {
      double myLotStep = MarketInfo(Symbol(), MODE_LOTSTEP);
      if (TradeMicroLots) myLotStep = 0.01;
      BaseLot=MathCeil(AccountBalance()*risk/10000)/100; 
      BaseLot=BaseLot * 100000 / MarketInfo(Symbol(), MODE_LOTSIZE); 
      LotSizeArray[0,myDirection]=NormalizedLots(BaseLot,true);
      for (cnt=1;cnt<MaxTrades;cnt++) LotSizeArray[cnt,myDirection]=LotSizeArray[cnt-1,myDirection]*multiply;
      for (cnt=1;cnt<MaxTrades;cnt++) LotSizeArray[cnt,myDirection]=NormalizedLots(LotSizeArray[cnt,myDirection],true);
      if (openTradeCount==0) LotSizeArray[99,myDirection]=AccountBalance();
    }
  }

  if (mm == 2)
  {
    /* Example with 600 PIP SL, 90 PIP spacing, 1.7x Lot Size multiplier:
    600 + 510*1.7^1 + 420*1.7^2 + 330*1.7^3 + 240*1.7^4 + 150*1.7^5 = XAdjPips
    Total = MarketInfo(Symbol(), MODE_TICKVALUE) * XAdjPips;
    Risk = Total / AccountBalance();

    Therefore, if: 
    1 lot = 0.33 from the tick_value, which is based on 1 standard lot suppose it results in 33% risk
    X lot = 0.10 but we want the lot size equivalent of just 10% of account risk
    X = 0.1/0.33 converts to: risk% * accountbalance() / total

    Finally:
    BaseLot = risk% * accountbalance() / total;
    
    This risk model is not like mm=1, which steps up risk in abrupt steps, especially on smaller account sizes.

    This special MM system uses the Outside In Risk Approach... or balanced risk approach:
    Note that using this method, the risk is first stepped up from the trades that come later in the sequence
    since it is less risky to add 0.01 lot to the 6th trade than it is to add 0.01 lot to the first trade.
    This results in a higher Profit Factor with a slightly lower draw down.
    
    Thank you, Tom Bradbury, for the idea to add in risk from the "outside in!"
    */
    
    if (MaxTrades>0 && (openTradeCount==0 || (openTradeCount>0 && AccountBalance() > LotSizeArray[99,myDirection])))
    {
      MaxLossAmount = 0;
      for (cnt=0;cnt<MaxTrades;cnt++) MaxLossAmount += MathMax((StopLoss - cnt*Pips),0) * MathPow(multiply,cnt); 
      BaseLot = (risk/100) * AccountBalance() / (MarketInfo(Symbol(), MODE_TICKVALUE) * MaxLossAmount);
      double MaxTradeLotSize1 = NormalizedLots(NormalizedLots(BaseLot,false) * MathPow(multiply,MaxTrades-1),true);
      double MaxTradeLotSize2 = NormalizedLots(BaseLot * MathPow(multiply,MaxTrades-1),true);
      if (MaxTradeLotSize2>=MaxTradeLotSize1)
      { 
        LotSizeArray[MaxTrades-1,myDirection]=MaxTradeLotSize2;
        for (cnt=MaxTrades-2;cnt>=0;cnt--) LotSizeArray[cnt,myDirection]=LotSizeArray[cnt+1,myDirection]/multiply;
        for (cnt=MaxTrades-2;cnt>=0;cnt--) LotSizeArray[cnt,myDirection]=NormalizedLots(LotSizeArray[cnt,myDirection],false);
      }
      else
      { 
        LotSizeArray[0,myDirection]=NormalizedLots(BaseLot,false);
        for (cnt=1;cnt<MaxTrades;cnt++) LotSizeArray[cnt,myDirection]=LotSizeArray[cnt-1,myDirection]*multiply;
        for (cnt=1;cnt<MaxTrades;cnt++) LotSizeArray[cnt,myDirection]=NormalizedLots(LotSizeArray[cnt,myDirection],true);
      }
      if (openTradeCount==0) LotSizeArray[99,myDirection]=AccountBalance();
    }
  }

  MaxLossAmount = 0;
  for (cnt=0;cnt<MaxTrades;cnt++) MaxLossAmount += (StopLoss - cnt*Pips) * LotSizeArray[cnt,myDirection];
  if (myDirection == OP_SELL)
    ActualRiskPercentS = (MarketInfo(Symbol(), MODE_TICKVALUE) * MaxLossAmount * 100) / AccountBalance();
  if (myDirection == OP_BUY)
    ActualRiskPercentB = (MarketInfo(Symbol(), MODE_TICKVALUE) * MaxLossAmount * 100) / AccountBalance();
  
  if (!IsTesting()) WriteLotArray(); 
}

double NormalizedLots(double myLotSize, bool myMethod)
{
  double myLotStep = MarketInfo(Symbol(), MODE_LOTSTEP);
  if (TradeMicroLots) myLotStep = 0.01;
  if (myMethod) myLotSize = MathCeil(myLotSize / myLotStep) * myLotStep; // Conform to broker-required lot step requirment
  else myLotSize = MathFloor(myLotSize / myLotStep) * myLotStep; // For calculating "outside in" lot requirements
  if (myLotSize<MarketInfo(Symbol(), MODE_MINLOT)) myLotSize=MarketInfo(Symbol(), MODE_MINLOT);
  if (myLotSize>MarketInfo(Symbol(), MODE_MAXLOT)) myLotSize=MarketInfo(Symbol(), MODE_MAXLOT); 
  return(myLotSize);
}

int InitializeTimeVariables()
{
  int tmpGMToffset;
  string GMTMode;
  if (UseAutoGMToffset)
  {
    if (!IsTesting())
    {
      tmpGMToffset = AutoGMTOffset();
      if (tmpGMToffset > 24 || tmpGMToffset < -24)
      {
        if (AutoFallbackOnFail)
        {
          GMTMode = " (auto-fallback)";
        }  
        else
        {
          text="Failure getting AutoGMToffset, cannot open time-based trades until condition clears.";
          Comment(text);
          Print(text);
          Sleep(120000); // After 2 minutes, we will try again.
          return(-1);
        }
      }
      else
      {
        ManualGMToffset = tmpGMToffset;
        GMTMode = " (auto)";
      }
    }
    else
    {
      text="WARNING: When backtesting, only ManualGMTOffset value can be used, ensure it is set correctly!";
      Print(text);
      GMTMode = " (manual)";
    }    
  }
  else
  {
    GMTMode = " (manual)";
  }
  GMTOffsetStatusInfo = StringConcatenate("GMT Offset: ", DoubleToStr(ManualGMToffset, 1), GMTMode);
  GMTStartHour =  NormalizedHourParam(GMTStartHour);
  GMTStopHour  =  NormalizedHourParam(GMTStopHour);
  
  OneTimeInitialize = false; // clear the flag so this code base runs only one time
  return(0);
}

bool IsMyOrder()
{
  if (OrderSymbol() == Symbol() && (OrderMagicNumber() == MagicNumber)) return(true);
  return(false);
}


void CloseAllOrders(int orderMode)
{
  int OrderCount=0;
  int TicketArray[100];

  for(cnt=OrdersTotal()-1;cnt>=0;cnt--)
  {
    if (OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES))
    {
      mode=OrderType();
      if (IsMyOrder())
	   {
        if ((mode==orderMode) || (mode==(orderMode+2)) || (mode==(orderMode+4)))
        { 
          TicketArray[OrderCount]=OrderTicket();
          OrderCount++;
	 	  }
      }
	 }
  }

  for(cnt=0;cnt<OrderCount;cnt++)
  {
    if (OrderSelect(TicketArray[cnt], SELECT_BY_TICKET, MODE_TRADES))
    {
      if(GetTradeContext()) RefreshRates();
      if (orderMode==OP_BUY)
      {
        OrderClose(OrderTicket(),OrderLots(),NormalizeDouble(Bid,myDigits),slippage,ArrowsColor);
      }
      if (orderMode==OP_SELL)
      {
        OrderClose(OrderTicket(),OrderLots(),NormalizeDouble(Ask,myDigits),slippage,ArrowsColor);
      }
      if (mode == (orderMode+2) || mode == (orderMode+4))
      {
        OrderDelete(OrderTicket());
      }
	 }
  }

  PreviousOpenOrders[orderMode] = 0;
  CurrentOpenOrders[orderMode]  = 0;
  LastOrderOpenPrice[orderMode] = 0;
  CalculateLotArray(orderMode,0); 
}


void UpdateOrderStatus(bool init)
{
  CurrentOpenOrders[OP_BUY]=0;
  CurrentOpenOrders[OP_SELL]=0;
  MarketOpenOrders[OP_BUY]=0;
  MarketOpenOrders[OP_SELL]=0;
  int myOrderType;
  for(cnt=0;cnt<OrdersTotal();cnt++)   
  {
    if (OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES))
    {
      if (IsMyOrder())
      {				
        myOrderType = OrderType();
        if (myOrderType<=1) MarketOpenOrders[myOrderType]++;
        while (myOrderType > 1) myOrderType-=2; 
        CurrentOpenOrders[myOrderType]++;
        if(LastOrderOpenTime[myOrderType]<OrderOpenTime())
        {
          LastOrderOpenTime[myOrderType]=OrderOpenTime();
          LastOrderOpenPrice[myOrderType]=OrderOpenPrice();
        }
      }
    }
  }
  if (init)
  {
    PreviousOpenOrders[OP_BUY]=CurrentOpenOrders[OP_BUY];
    PreviousOpenOrders[OP_SELL]=CurrentOpenOrders[OP_SELL];
  }
}


string ShowLotSizeSequence()
{
  // Determine Precision of LotSize
  int x=0;
  string result;
  if (MarketInfo(Symbol(), MODE_LOTSTEP)==0.1) x=1;
  if (MarketInfo(Symbol(), MODE_LOTSTEP)==0.01) x=2;
  if (TradeMicroLots) x=2;

  if (MaxTrades>0)
  {
    // iterate array
    result=StringConcatenate("\nBuy LotSizing: ",DoubleToStr(LotSizeArray[0,OP_BUY],x));
    for (int myCount=1;myCount<MaxTrades;myCount++) result = StringConcatenate(result, ", ", DoubleToStr(LotSizeArray[myCount,OP_BUY],x));
    result = StringConcatenate(result," @",DoubleToStr(ActualRiskPercentB,1),"% Max Potential DD");
    result=StringConcatenate(result,"\nSell  LotSizing: ",DoubleToStr(LotSizeArray[0,OP_SELL],x));
    for (myCount=1;myCount<MaxTrades;myCount++) result = StringConcatenate(result, ", ", DoubleToStr(LotSizeArray[myCount,OP_SELL],x));
    result = StringConcatenate(result," @",DoubleToStr(ActualRiskPercentS,1),"% Max Potential DD");
  }
  else
  {
    result=("\nEA will not open new orders since MaxTrades=0\nMonitoring existing trades until they can be closed out");
  }
  
  return(result);
}

void ReadLotArray()
{
  bool BuyReadSuccess=true, SellReadSuccess=true;
  string gvBase = StringConcatenate("gvSPH_",Symbol(),DoubleToStr(MagicNumber,0),"_");
  string gvName;
  int gv_total = GlobalVariablesTotal(), StoredPos, a, b;

  UpdateOrderStatus(false);
  
  for (cnt=0;cnt<100;cnt++)
  {
    if (CurrentOpenOrders[OP_BUY]==0)  LotSizeArray[cnt,OP_BUY]=0;
    if (CurrentOpenOrders[OP_SELL]==0) LotSizeArray[cnt,OP_SELL]=0;
  }

  if (CurrentOpenOrders[OP_BUY]>0 || CurrentOpenOrders[OP_SELL]>0)
  {
    for (int count=0;count<gv_total;count++)
    {
      gvName = GlobalVariableName(count);
      if (StringFind(gvName, gvBase, 0) == 0) 
      {
        if (StringFind(gvName, "B_", StringLen(gvBase)-1) > 0 && CurrentOpenOrders[OP_BUY]>0) 
        {
          a = StringFind(gvName, "_", StringLen(gvBase) + 1);
          b = StringFind(gvName, "_", a + 1);
          a += 1;
          StoredPos = StrToInteger(StringSubstr(gvName,a,b-a));
          LotSizeArray[StoredPos,OP_BUY] = GlobalVariableGet(gvName);
        } 
        if (StringFind(gvName, "S_", StringLen(gvBase)-1) > 0 && CurrentOpenOrders[OP_SELL]>0) // SELL Lot Array Entry
        {
          a = StringFind(gvName, "_", StringLen(gvBase) + 1);
          b = StringFind(gvName, "_", a + 1);
          a += 1;
          StoredPos = StrToInteger(StringSubstr(gvName,a,b-a));
          LotSizeArray[StoredPos,OP_SELL] = GlobalVariableGet(gvName);
        } 
      }
    }

    for (count=0;count<MaxTrades;count++)
    {
      if (!(LotSizeArray[count,OP_BUY]>0)) BuyReadSuccess=false;
      if (!(LotSizeArray[count,OP_SELL]>0)) SellReadSuccess=false;
    }
    if (!(LotSizeArray[99,OP_BUY]>0)) BuyReadSuccess=false;
    if (!(LotSizeArray[99,OP_SELL]>0)) SellReadSuccess=false;
    
    if (!BuyReadSuccess) CalculateLotArray(OP_BUY,0);
    if (!SellReadSuccess) CalculateLotArray(OP_SELL,0);
  }
  else 
  {
    CalculateLotArray(OP_BUY,0);
    CalculateLotArray(OP_SELL,0);
  }

  double MaxLossAmount = 0;
  for (cnt=0;cnt<MaxTrades;cnt++) MaxLossAmount += (StopLoss - cnt*Pips) * LotSizeArray[cnt,OP_BUY];
  ActualRiskPercentB = (MarketInfo(Symbol(), MODE_TICKVALUE) * MaxLossAmount * 100) / AccountBalance();
  MaxLossAmount = 0;
  for (cnt=0;cnt<MaxTrades;cnt++) MaxLossAmount += (StopLoss - cnt*Pips) * LotSizeArray[cnt,OP_SELL];
  ActualRiskPercentS = (MarketInfo(Symbol(), MODE_TICKVALUE) * MaxLossAmount * 100) / AccountBalance();
}


void WriteLotArray()
{
  string gvB = StringConcatenate("gvSPH_",Symbol(),DoubleToStr(MagicNumber,0),"_B_");
  string gvS = StringConcatenate("gvSPH_",Symbol(),DoubleToStr(MagicNumber,0),"_S_");
  string gvName;
  for (int count=0;count<MaxTrades;count++)
  {
    gvName = StringConcatenate(gvB,DoubleToStr(count,0),"_");
    GlobalVariableSet(gvName, LotSizeArray[count,OP_BUY]);
    gvName = StringConcatenate(gvS,DoubleToStr(count,0),"_");
    GlobalVariableSet(gvName, LotSizeArray[count,OP_SELL]);
  }
  gvName = StringConcatenate(gvB,DoubleToStr(99,0),"_");
  GlobalVariableSet(gvName, LotSizeArray[99,OP_BUY]);
  gvName = StringConcatenate(gvS,DoubleToStr(99,0),"_");
  GlobalVariableSet(gvName, LotSizeArray[99,OP_SELL]);
}

void ModifyTakeProfits(double newTP, int MagicNumber, int op)
{
   int cnt=0, err=0;
   bool result;
   int OrderCount=0;
   int TicketArray[100];

   for(cnt = 0; cnt < OrdersTotal(); cnt++)
   {
      if (OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES))
      {
         mode=OrderType();
         if (IsMyOrder() && mode==op)
	      {
            TicketArray[OrderCount]=OrderTicket();
            OrderCount++;
         }
	   }
   }

   if (OrderCount>1)
   for(cnt=0;cnt<OrderCount;cnt++)
   {
      if (OrderSelect(TicketArray[cnt], SELECT_BY_TICKET, MODE_TRADES))
      {
         if(GetTradeContext()) RefreshRates();
         if(NormalizeDouble(OrderTakeProfit(),myDigits) != NormalizeDouble(newTP,myDigits))
		   {
  	         result=OrderModify(OrderTicket(), OrderOpenPrice(), OrderStopLoss(), newTP, 0, Purple);
				if (result != TRUE) err = GetLastError();
			   if (err > 1) Print("LastError = (", err, "): ", ErrorDescription(err));
            else OrderPrint();
	  		}
      }
   }
}

double CalcStopLoss(int op)
  {
   int ticket;
   double HighestBuy, LowestSell;
   double HighestBuySL, LowestSellSL;
   double newSL;
//----
   HighestBuy = 0;
   LowestSell = 9999;
   HighestBuySL = 0;
   LowestSellSL = 0;
   newSL = 0;
 
   for(int i=0;i<OrdersTotal();i++)
     {
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) == false) break;
      if (OrderSymbol() != Symbol()) continue;
      if (OrderMagicNumber() != MagicNumber) continue;
      
      if (op == OP_BUY && OrderType() == OP_BUY)
         {
            if (OrderOpenPrice() > HighestBuy)
            {
               HighestBuy = OrderOpenPrice();
               HighestBuySL = OrderStopLoss();
            }
         }
         
      if (op == OP_SELL && OrderType() == OP_SELL)
         {
            if (OrderOpenPrice() < LowestSell)
            {
               LowestSell = OrderOpenPrice();
               LowestSellSL = OrderStopLoss();
            }
         }
     }
     
  switch (op)
  {  
    case OP_BUY:
      if (HighestBuySL==0)
         newSL = BuyPrice-StopLoss*Point;
      else
         newSL = HighestBuySL;
      break; 	
    case OP_SELL:
      if (LowestSellSL==0)
         newSL = SellPrice+StopLoss*Point;
      else
         newSL = LowestSellSL;
      break; 	
    default: 
      break;
  }
     
 return (newSL);
}


void LogPerformance()
{
  int handle;
  handle=FileOpen(StringConcatenate(EAName, " Log ", Symbol(), ".txt"), FILE_CSV|FILE_READ|FILE_WRITE, ';');
  if(handle > 0)
    {
     FileSeek(handle, 0, SEEK_END);
     FileWrite(handle, Symbol(), TimeToStr(TimeCurrent()), AccountBalance(), AccountEquity());
     FileClose(handle);
    }
}

bool BlackoutTime()
{
   if (EnableBlackout)
   {
      StartBlackout = DayNumber(StartBlackoutMonth, StartBlackoutDay);
      StopBlackout = DayNumber(StopBlackoutMonth, StopBlackoutDay);
      
      if (StartBlackout <= StopBlackout && DayOfYear() >= StartBlackout && DayOfYear() < StopBlackout)
      {
         return (true);
      }
      
      if ((StartBlackout > StopBlackout && DayOfYear() >= StartBlackout) || (StartBlackout > StopBlackout && DayOfYear() < StopBlackout))
      {
         return (true);
      }
      
      
      else return (false);
      
   }      
   
   return (false);
}

int DayNumber(int month, int day) {
   
   int days = 0;
   switch(month)
   {
      case 1 : days = 0; break;    
      case 2 : days = 31; break;
      case 3 : days = 59; break;
      case 4 : days = 90; break;
      case 5 : days = 120; break;
      case 6 : days = 151; break;
      case 7 : days = 181; break;
      case 8 : days = 212; break;
      case 9 : days = 243; break;
      case 10: days = 273; break;
      case 11: days = 304; break;
      case 12: days = 334; break;
   }
   
   days = days + day;
   
   bool leapYear = false;
   
   if (MathMod(Year(), 4) == 0)
   {
      leapYear = true;
   }
   else if (MathMod(Year(), 400) == 0)
   {
      leapYear = true;
   }
   else if (MathMod(Year(), 100) == 0)
   {
      leapYear = false;
   }
   
   if (leapYear == true && month > 2) days++;
   
   return (days);
}

double iT3(int Periods) {
	int i,limit=Periods*5;
	double e1[1],e2[1],e3[1],e4[1],e5[1],e6[1],e7[1];
	ArrayResize(e1,limit*4);
	ArrayResize(e2,limit*4);
	ArrayResize(e3,limit*4);
	ArrayResize(e4,limit*4);
	ArrayResize(e5,limit*4);
	ArrayResize(e6,limit*4);
	ArrayResize(e7,limit*4);
	ArraySetAsSeries(e1,true);
	ArraySetAsSeries(e2,true);
	ArraySetAsSeries(e3,true);
	ArraySetAsSeries(e4,true);
	ArraySetAsSeries(e5,true);
	ArraySetAsSeries(e6,true);
	ArraySetAsSeries(e7,true);
   for(i=limit+Periods*5; i>=0; i--) {
   	e1[i]=iMA(NULL,0,Periods,0,t3mamode,PRICE_CLOSE,i);
   }
   for(i=limit+Periods*4; i>=0; i--) {
   	e2[i]=iMAOnArray(e1,0,Periods,0,t3mamode,i);
   }
   for(i=limit+Periods*3; i>=0; i--) {
   	e3[i]=iMAOnArray(e2,0,Periods,0,t3mamode,i);
   }
   for(i=limit+Periods*2; i>=0; i--) {
   	e4[i]=iMAOnArray(e3,0,Periods,0,t3mamode,i);
   }
   for(i=limit+Periods; i>=0; i--) {
   	e5[i]=iMAOnArray(e4,0,Periods,0,t3mamode,i);
   }
	double a=b;
	double c1=-a*a*a;
	double c2=3*a*a+3*a*a*a;
	double c3=-6*a*a-3*a-3*a*a*a;
	double c4=1+3*a+a*a*a+3*a*a;
   for(i=limit; i>=0; i--) {
   e6[i]=iMAOnArray(e5,0,Periods,0,t3mamode,i);
   e7[i]=c1*e6[i]+c2*e5[i]+c3*e4[i]+c4*e3[i];
   }
   return(e7[0]);
}

void drawLabel(string name,double lvl,color Color)
{
    if(ObjectFind(name) != 0)
    {
        ObjectCreate(name, OBJ_TEXT, 0, Time[10], lvl);
        ObjectSetText(name, name, 8, "Arial", EMPTY);
        ObjectSet(name, OBJPROP_COLOR, Color);
    }
    else
    {
        ObjectMove(name, 0, Time[10], lvl);
    }
}
void drawLine(double lvl,string name, color Col,int type)
{
         if(ObjectFind(name) != 0)
         {
            ObjectCreate(name, OBJ_HLINE, 0, Time[0], lvl,Time[0],lvl);
            
            if(type == 1)
            ObjectSet(name, OBJPROP_STYLE, STYLE_SOLID);
            else if(type == 2)
            ObjectSet(name, OBJPROP_STYLE, STYLE_DASHDOTDOT);
            else
            ObjectSet(name, OBJPROP_STYLE, STYLE_DOT);
            
            ObjectSet(name, OBJPROP_COLOR, Col);
            ObjectSet(name,OBJPROP_WIDTH,1);
            
         }
         else
         {
            ObjectDelete(name);
            ObjectCreate(name, OBJ_HLINE, 0, Time[0], lvl,Time[0],lvl);
            
            if(type == 1)
            ObjectSet(name, OBJPROP_STYLE, STYLE_SOLID);
            else if(type == 2)
            ObjectSet(name, OBJPROP_STYLE, STYLE_DASHDOTDOT);
            else
            ObjectSet(name, OBJPROP_STYLE, STYLE_DOT);
            
            ObjectSet(name, OBJPROP_COLOR, Col);        
            ObjectSet(name,OBJPROP_WIDTH,1);
          
         }
}

bool canOpen(int openWhat)
{
   if (!NoHedge) return(true);

      
      for(int i=0; i < OrdersTotal(); i++)
      {
         if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES) == false) break;
         if (OrderSymbol() != Symbol())                     continue;
         if (!StrictNoHedge && OrderMagicNumber() != MagicNumber) continue;
      
         if (OrderType() == OP_BUY  && openWhat == OP_SELL) return(false); 
         if (OrderType() == OP_SELL && openWhat == OP_BUY)  return(false); 
   }      
   return(true);
}


