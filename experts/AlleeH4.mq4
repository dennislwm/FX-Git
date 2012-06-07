//+------------------------------------------------------------------+
//|                                                      AlleeH4.mq4 |
//|                      Copyright © 2011, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//|                                                                  |
//| Assert History                                                   |
//| 4.43    Use NVO to ensure do not signal during thin volumes      |
//|            Use LookBackPeriod to determine if at least ONE white |
//|            bar.                                                  |
//|            Affects both trend-following (SharpeWaveW 2.10) and   |
//|            countercyclical (SharpeWaveTD 2.11) strategies        |
//| 4.33    If BearBullRatio=0 (bullish), we can use the buy signal  |
//|            from the countercyclical indicator SharpeWaveTD in    |
//|            addition to the trend-following indicator ShareWaveW  |
//|            and vice-versa for BearBullRatio=2 (bearish)          |
//| 4.32    Control up to 3 extra Magic Numbers to minimize drawdown |
//|            However, it controls closing of trades only           |
//| 4.22    New indicator Choppy Market Index (CMI)                  |
//|            My first idea is to automate the SecureProfitOnHour   |
//|            variable using CMI (0-100). When the CMI falls, the   |
//|            SecureProfitOnHour drops (to a minimum of 0.01), and  |
//|            when CMI rises, there is no change to the value.      |
//|            This is to minimize drawdown.                         |
//|            SecureProfitOnHour is initialized as a fixed multiple |
//|            of Period().                                          |
//| 4.12    If BearBullRatio=0 (bullish) or 2 (bearish) use custom   |
//|            trend-following indicator SharpeWaveW (Widner),       |
//|            otherwise, use countercyclical indicator SharpeWaveTD |
//|            Fixed bug where in-between values should use latter   |
//| 4.11    Use SharpeWaveTD for countercyclical strategy            |
//|            Conservative open trade only when signal is +/-4      |
//|            Open trade when same wave is false                    |
//| 4.01    On trade open, reset securetime                          |
//|            No open trades, reset securetime and securenow        |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2011, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"
#import "WinUser32.mqh"
//---- Assert Basic externs
extern string s1="-->Basic Settings<--";
extern double StopLoss=120;
extern double MaxSpread=10;
double TakeProfit=0;
double SecureProfit=2;
double SecureProfitTrigger=0;
//---- Assert Money Management externs
extern string s2="-->Money Management<--";
extern double AutoMM=1.0;
extern double MaxLot=0.5;
extern double MinLot=0.05;
extern int MaxAccountTrades=4;
extern int MaxSamePairTrades=1;
double ContractSize=100000;
string s5_4="Assign value below (hour) to take profit.";
string s5_5="Each x hour, 40% of lots closed on profit.";
double SecureProfitOnMins=0;
double securetime;
double SecureProfitOnInit=0;
//---- Assert Trend externs
extern string s3="-->Trend Logic<--";
extern double BearBullRatio=1.0;
double BbrBTO=1.0;
double BbrSTO=1.0;
double BearBullMax=1.2;
//---- Assert Signal externs
extern string s4="-->Exit Signal Logic<--";
extern double MaFast=10;
extern double MaSlow=20;
//---- Assert SharpeWaveTD and W inputs
int EmaFast=12;
int EmaSlow=26;
int EmaSignal=9;
double RsiBTO=35;
double RsiSTO=65;
double RsiPeriod=14;
int WidnerFastPeriod=4;
int LookBackPeriod=9;
int LookBackBar=4;
bool NvoAssert=true;
int VolumePeriod=131;
//---- Assert User externs
extern string s5="-->User Semi-Automatic Open<--";
extern string s5_1="Assign both values to open a trade manually.";
extern string s5_2="This trade belongs to Allee after opened.";
extern string s5_3="UserOpenSignal (-1:Buy)/(1:Sell).";
extern double UserLot=0.0;
extern int UserOpenSignal=0;
//---- Assert Extra externs
extern string s6="-->Extra Settings<--";
extern double SlipPage=3;
extern double MagicNumber=7676;
extern double MagicNumber1=0;
extern double MagicNumber2=0;
extern double MagicNumber3=0;
extern string TradeComment="-->AlleeH4 v4.43<--";
extern int Debug=2;
//---- Assert global variables
double Pip;
double Pts;
double MinStop;
//---- Assert MaxWaveTrades global variables
int MaxWaveTrades=1;
int OpenWave=0;
//---- Assert Dampener global variables
int DampenerCount=5;

// function
int CreateBackground(string backName,string text,int Bfontsize,int LabelCorner,int xB,int yB)
{
   if(ObjectFind(backName) == -1)
      ObjectCreate(backName, OBJ_LABEL, 0, 0, 0, 0, 0);
   ObjectSetText(backName, text, Bfontsize, "Webdings");      
   ObjectSet(backName, OBJPROP_CORNER, LabelCorner);
   ObjectSet(backName, OBJPROP_BACK, false);
   ObjectSet(backName, OBJPROP_XDISTANCE, xB);
   ObjectSet(backName, OBJPROP_YDISTANCE, yB );    
   ObjectSet(backName, OBJPROP_COLOR, Gray);
}    
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
   securetime=TimeCurrent();
//----
   handle_digit();
   handle_broker();
   //handle_takeprofit();
   handle_bearbullratio();
   handle_secureprofitonhour(true);
   Print("init():Initialize SecureProfitOnInit=",DoubleToStr(SecureProfitOnInit,0)," in mins for Period=",Period());
   Print("LotSize=",MarketInfo(Symbol(),MODE_LOTSIZE));
//----
   for (int r=0;r<25;r++)
      CreateBackground("BgroundGG"+r,"ggggggggggggggggggg",8,0,3,9*r);
   return(0);
  }
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   for (int r=0;r<25;r++)
      ObjectDelete("BgroundGG"+r);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| 4 or 5 Digit (decimal) Broker Account Recognition function       |
//+------------------------------------------------------------------+
void handle_digit()
{
//---- Automatically adjust to Full-Pip or Sub-Pip Accounts
   if (Digits==4||Digits==2)
   {
      SlipPage=SlipPage;
      Pip=1;
      Pts=Point;
   }
   if (Digits==5||Digits==3)
   {
      SlipPage=SlipPage*10;
      Pip=10;
      Pts=Point*10;
   }
//---- Automatically adjust one decimal place left for Gold
   if (Symbol()=="XAUUSD") 
   {
      SlipPage*=10;
      Pip*=10;
      Pts*=10;
   }
}
//+------------------------------------------------------------------+
//| Handle broker limitations                                        |
//+------------------------------------------------------------------+
bool handle_broker()
{
   double LotStep, MaxBLot, MinBLot;

//---- Retrieve broker info on lots in Pips (either base 1 or base 10 depending on broker)
   LotStep=MarketInfo(Symbol(),MODE_LOTSTEP);
   MaxBLot=MarketInfo(Symbol(),MODE_MAXLOT);
   MinBLot=MarketInfo(Symbol(),MODE_MINLOT);
   MinStop=MarketInfo(Symbol(),MODE_STOPLEVEL);   
   
//---- Assert Lots > MinLot and Lots < MaxLot 
   if (MinLot>=MinBLot && MaxLot<=MaxBLot)
   { 
      if (Debug>=2) Print("handle_broker():Assert Lot size is within brokers limit.");
   }
   else
   {
      Print("Lot size is not within brokers allowable Min=",MinBLot," and Max=",MaxBLot," limits.");
      return(false);
   }
//---- Assert StopLoss > MinStop
   if (StopLoss>=MinStop)
   {
      if (Debug>=2) Print("handle_broker():Assert StopLoss is within brokers limit.");
   }
   else
   {
      Print("StopLoss=",StopLoss," is smaller than brokers allowable MinStop=",MinStop," limit.");
      return(false);
   }

//---- Assert Allow Live Trading is set in Tools-->Options-->Expert Advisors is checked.
   if (IsTradeAllowed())
   {
      if (Debug>=2) Print("handle_broker():Live Trading is allowed.");
   }
   else
   {
      Print("Check that Allow Live Trading under Tools-->Options-->Expert Advisor is checked.");
      return(false);
   }
   return(true);
}
/*
//+------------------------------------------------------------------+
//| Handle automatic TakeProfit levels                               |
//+------------------------------------------------------------------+
bool handle_takeprofit()
{
//---- Assert recommended TakeProfit for different Time periodicity.
// M1,   TakeProfit=7
// M5,   TakeProfit=14
// M15,  TakeProfit=14
// M30,  TakeProfit=21
//----
   if(TakeProfit>0 && TakeProfit<3)
   {
      Print("TakeProfit less than 3.");
      return(false);
   }
   if (TakeProfit>=3 && TakeProfit<100) 
   {
      SecureProfitTrigger=TakeProfit*10/14;
      Print("TakeProfit=",TakeProfit," is within limit. SecureProfitTrigger=",SecureProfitTrigger);
      return(true);
   }
   if (TakeProfit>=100)
   {
      Print("TakeProfit=",TakeProfit," is more than allowable limit.");
      return(false);
   }
   
   switch (Period())
   {
      case 1   : TakeProfit=14;  SecureProfitTrigger=10;  break;
      case 5   : TakeProfit=14;  SecureProfitTrigger=10;  break;
      case 15  : TakeProfit=14;  SecureProfitTrigger=10;  break;
      default  : TakeProfit=21;  SecureProfitTrigger=15;
   }
   Print("TakeProfit=",TakeProfit," has been auto set due to period=",Period(),". SecureProfitTrigger=",SecureProfitTrigger);
   return(true);
}
*/
//+------------------------------------------------------------------+
//| Handle Bull and Bear Factor                                      |
//+------------------------------------------------------------------+
bool handle_bearbullratio()
{
//---- Assert variables for Signal
   double rsi_max;
   double rsi_off;
   
//---- Assert BullBearRatio is between 0 and 2.
   if (BearBullRatio<0)
   {
      Print("BearBullRatio=",BearBullRatio," is less than 0. Set BearBullRatio=0.");
      BearBullRatio=0;
   }
   else if (BearBullRatio>2)
   {
      Print("BearBullRatio=",BearBullRatio," is more than 2. Set BearBullRatio=2.");
      BearBullRatio=2;
   }
   else
   {
      BearBullRatio=NormalizeDouble(BearBullRatio,1);
      Print("BearBullRatio=",BearBullRatio,".");
   }
//---- Assert RSI factor is set proportionately to BBR
//---- BBR=1, RSISTO=65, RSIBTO=35
//---- BBR=2, RSIBTO=20
//---- BBR=0, RSISTO=80
//---- Assert recommended TakeProfit for different Time periodicity.
// M1,   RSISTO=70,RSIBTO=30
// M5,   RSISTO=70,RSIBTO=30
// M15,  RSISTO=65,RSIBTO=35
// M30,  RSISTO=65,RSIBTO=35
//----
   switch (Period())
   {
      case 1   : RsiSTO=70;RsiBTO=30;  break;
      case 5   : RsiSTO=65;RsiBTO=35;  break;
      case 15  : RsiSTO=65;RsiBTO=35;  break;
      default  : RsiSTO=65;RsiBTO=35;
   }
//---- Automatically signal factor for Gold and Silver
   if (Symbol()=="XAUUSD" || Symbol()=="XAGUSD") 
   {
      switch (Period())
      {
         case 1   : RsiSTO=65;RsiBTO=35;  break;
         case 5   : RsiSTO=65;RsiBTO=35;  break;
         case 15  : RsiSTO=65;RsiBTO=35;  break;
         default  : RsiSTO=65;RsiBTO=35;
      }
   }
   rsi_max=80-RsiSTO;
   rsi_off=MathMin(1,MathAbs(BearBullRatio-1))*rsi_max*(2-1);
   if (BearBullRatio<1) RsiSTO=RsiSTO+rsi_off;
   if (BearBullRatio>1) RsiBTO=RsiBTO-rsi_off;
//---- Assert Money Management is set proportionately to BBR
//---- BBR=1, Lots=L, TP=T
//---- BBR=2, Sell Lots=L*2, TP=T*2, Buy Lots=L/2, TP=T/2
//---- BBR=0, Buy Lots=L*2, TP=T*2, Sell Lots=L/2, TP=T/2
   if (BearBullRatio<1) 
      {
         BbrBTO=MathMin(1,MathAbs(BearBullRatio-1))*(BearBullMax-1)+1;
         BbrSTO=NormalizeDouble(1/BbrBTO,1);
         BbrBTO=NormalizeDouble(BbrBTO,1);
      }
   if (BearBullRatio>1)
      { 
         BbrSTO=MathMin(1,MathAbs(BearBullRatio-1))*(BearBullMax-1)+1;
         BbrBTO=NormalizeDouble(1/BbrSTO,1);
         BbrSTO=NormalizeDouble(BbrSTO,1);
      }
   
   //if (BearBullRatio==0) Print("BearBullRatio=",BearBullRatio,". SELL to Open has been disabled.");
   //if (BearBullRatio==2) Print("BearBullRatio=",BearBullRatio,". BUY to Open has been disabled.");
}
//+------------------------------------------------------------------+
//| Handle initialization of SecureProfitOnHour                      |
//+------------------------------------------------------------------+
bool handle_secureprofitonhour(bool init)
{
   double calcmins,cmi,countdown;
//---- Assert we use a fixed multiple of 32 for every period (trial and error).
//       If required, we can customize this fixed multiple per period.
//       E.g. PERIOD_M15: SecureProfitOnInit=15*32/60 (or 8 in hours)
//       Initialize once only.
   if (init)
   {
      SecureProfitOnInit=Period()*32;
      SecureProfitOnMins=SecureProfitOnInit;
      return(false);
   }
//---- Calculate automatically the SecureProfitOnHour using the CMI
//       We use 131 period for all time frame charts (trial and error).
   HideTestIndicators(true);
   cmi=iCustom(NULL,0,"cmi",VolumePeriod,0,0);
   HideTestIndicators(false);
   calcmins=SecureProfitOnInit*cmi/100;
//---- Check upper and lower bounds   
   if (calcmins<1) calcmins=1;
   else if (calcmins>SecureProfitOnInit) calcmins=SecureProfitOnInit;
//---- Minimized drawdown when calchour is less than the countdown in seconds
//       Do not interrupt countdown unless calchour is less than countdown
   countdown=(SecureProfitOnMins*60)-(TimeCurrent()-securetime);
   if (calcmins*60<countdown)
   {
      if (Debug>=2) Print("handle_secureprofitonhour():New SecureProfitOnMins=",DoubleToStr(calcmins,0)," is less than countdown=",DoubleToStr((SecureProfitOnMins)-(TimeCurrent()-securetime)/60,0));
      SecureProfitOnMins=calcmins;
      return(true);
   }
   else return(false);
}
/*
//+------------------------------------------------------------------+
//| Calculate the difference in pips                                 |
//+------------------------------------------------------------------+
double handle_pip(int order_type, double open, double close)
{
   if (order_type==OP_BUY)
   {
      if (Debug>=3) Print("handle_pip():OrderType=OP_BUY,pips=",(close-open)/Pts);
      return((close-open)/Pts);
   }
   if (order_type==OP_SELL) 
   {
      if (Debug>=3) Print("handle_pip():OrderType=OP_SELL,pips=",(open-close)/Pts);
      return((open-close)/Pts);
   }
   
   return(0.0);
}
*/
//+------------------------------------------------------------------+
//| Lots Sizes and Automatic Money Management                        |
//+------------------------------------------------------------------+
double get_lots()
{
   double LotStep, MaxBLot, MinBLot;
//---- Assert variables for AutoMM
   double CalcLot, Atr;

//---- Assert AutoMM>0
   if (AutoMM<0.1) AutoMM=0.1;

//---- Retrieve broker info on lots in Pips (either base 1 or base 10 depending on broker)
   LotStep=MarketInfo(Symbol(),MODE_LOTSTEP);
   MaxBLot=MarketInfo(Symbol(),MODE_MAXLOT);
   MinBLot=MarketInfo(Symbol(),MODE_MINLOT);



//---- Assert maximum risk in lots is calculated as % of equity divided by maximum stop loss
   if (UserLot!=0 && UserOpenSignal!=0) CalcLot=UserLot;
   else
   {
      Atr=iATR(NULL,0,14,0);
      CalcLot=AutoMM*0.01*AccountEquity()/(Atr*MarketInfo(Symbol(),MODE_LOTSIZE));
   }
   
//---- Assert user's MinLot and MaxLot
   if (MaxLot!=0 && CalcLot>MaxLot) CalcLot=MaxLot;
   else if (MinLot!=0 && CalcLot<MinLot) CalcLot=MinLot;

//---- Assert broker's MinLot and MaxLot
   if (CalcLot>MaxBLot) return(MaxBLot);
   else if (CalcLot<MinBLot) return(MinBLot);
   else return(CalcLot);
}
//+------------------------------------------------------------------+
//| Dampener function inputs a BearBullMagnifier and returns a dampen|
//| BearBullMagnifier                                                |
//+------------------------------------------------------------------+
double dampener(double amp)
{
   static int step;
//---- Assert BbrSTO>1 or BbrBTO>1
   //if (amp<=1) return(amp);
   
//---- Assert step-down dampening of the BbrSTO or BbrBTO.
   double stepdown_amp=amp-(amp-1)*MathMin(DampenerCount,step)/DampenerCount;
   
   if (Debug>=2) Print("dampener():StepDown=",step);
   
//---- Assert step is incremented and persist until deinit()
//---- If step exceeds DampenerCount, then BbrSTO=1 or BbrBTO=1
   step++;
   
   return(stepdown_amp);
}
//+------------------------------------------------------------------+
//| Get Maximum Wave Trades                                          |
//+------------------------------------------------------------------+
bool AssertWaveSameOpen(double wave)
{
//---- Assert Sell wave is same as Open
   if (wave>0 && OpenWave>0) return(true);

//---- Assert Buy wave is same as Open
   if (wave<0 && OpenWave<0) return(true);

   return(false);
}
//+------------------------------------------------------------------+
//| signal close function                                            |
//+------------------------------------------------------------------+
int close_signal()
{
   double MaFast0, MaSlow0, MaFast1, MaSlow1;
   int retval;

//---- To simplify the coding and speed up access, data are put into internal variables
//---- MaFast MUST be above 8 (anything lower creates whipsaw) and uses either EMA or LWMA
//---- MaFast MUST be below 15 (anything higher denies cut loss) and uses either EMA or LWMA
//---- MaSlow MUST be above 15 (anything lower creates whipsaw) and uses LWMA
//---- MaSlow MUST be below 25 (anything higher denies cut loss) and uses LWMA
   MaFast0=iMA(NULL,0,MaFast,0,MODE_EMA,PRICE_CLOSE,0);
   MaSlow0=iMA(NULL,0,MaSlow,0,MODE_LWMA,PRICE_CLOSE,0);
   MaFast1=iMA(NULL,0,MaFast,0,MODE_EMA,PRICE_CLOSE,1);
   MaSlow1=iMA(NULL,0,MaSlow,0,MODE_LWMA,PRICE_CLOSE,1);

   // check for crossover MaFast > MaSlow (buy to close)
   if (MaFast1<=MaSlow1 && MaFast0>MaSlow0) return(-1);

   // check for crossover MaFast < MaSlow (sell to close)
   if (MaFast1>=MaSlow1 && MaFast0<MaSlow0) return(1);

   return(0);
}  

//+------------------------------------------------------------------+
//| signal open function                                             |
//+------------------------------------------------------------------+
int open_signal()
{
   double wave;
   int retval;
//---- Assert variables for countercyclical strategy
   double MaFast0, MaSlow0, MaFast1, MaSlow1, MaSpreadMax;
   int wavef;
   int j, sign;

//---- Assert UserLot is not assigned
   if (UserLot!=0 && UserOpenSignal!=0)
   {
      string msg;
      msg="Open "+DoubleToStr(UserLot,2)+" (lots) ";
      if (UserOpenSignal==-1) msg=msg+" in BUY order ";
      if (UserOpenSignal==1) msg=msg+" in SELL order ";
      msg=msg+" for "+Symbol()+"?";
      int ret=MessageBox(msg,"User Order",4|20); // Message box
      if (ret!=6) //IDYES=6
      {
         UserOpenSignal=0;
         return(0);
      }
      if (UserOpenSignal==-1) return(-1);
      else if (UserOpenSignal==1) return(1);
   }

//---- Assert Bullish or Bearish logic signal
   if (BearBullRatio==0 || BearBullRatio==2)
   {
   //---- To simplify the coding and speed up access, data are put into internal variables
      wave=iCustom(NULL,0,"SharpeWaveW",EmaFast,EmaSlow,EmaSignal,WidnerFastPeriod,LookBackPeriod,NvoAssert,VolumePeriod,0,0);
      if (Debug>=3) Print("Checking for wave=",wave);
   //---- Assert MaxWaveTrades is not exceeded.
      if (AssertWaveSameOpen(wave)) return(0);
      else 
      {
         OpenWave=0;
         if (Debug>=3) Print("Wave has ended.");
      }
      // check for long position (BUY) possibility
      if(wave==-4) return(-1);
      if(BearBullRatio==0 && wave==-2) return(-1);
      if(BearBullRatio==0 && wave==-3) return(-1);

      // check for short position (SELL) possibility
      if(wave==4) return(1);
      if(BearBullRatio==2 && wave==2) return(1);
      if(BearBullRatio==2 && wave==3) return(1);

   //---- To simplify the coding and speed up access, data are put into internal variables
      wave=iCustom(NULL,0,"SharpeWaveTD",EmaFast,EmaSlow,EmaSignal,WidnerFastPeriod,MaFast,MaSlow,LookBackPeriod,LookBackBar,NvoAssert,VolumePeriod,0,0);
   //---- check for long position (BUY) possibility
      if(BearBullRatio==0 && wave==-4) return(-1);
   //---- check for short position (SELL) possibility
      if(BearBullRatio==2 && wave==4) return(1);
   }
//---- Assert Countercyclical logic signal
   else
   {
   //---- To simplify the coding and speed up access, data are put into internal variables
      wave=iCustom(NULL,0,"SharpeWaveTD",EmaFast,EmaSlow,EmaSignal,WidnerFastPeriod,MaFast,MaSlow,LookBackPeriod,LookBackBar,NvoAssert,VolumePeriod,0,0);
      if (Debug>=3) Print("Checking for countercyclical wave=",wave);
   //---- Assert MaxWaveTrades is not exceeded.
      if (AssertWaveSameOpen(wave)) return(0);
      else 
      {
         OpenWave=0;
         if (Debug>=3) Print("Wave has ended.");
      }
      // check for long position (BUY) possibility
      if(wave==-4) return(-1);

      // check for short position (SELL) possibility
      if(wave==4) return(1);
   }
   return(0);
}  
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
//+------------------------------------------------------------------+
//| count all profits from the same pair trades                      |
//+------------------------------------------------------------------+
double count_magic_profit()
{
   double profit=0.0;

//---- Assert determine count of all trades done with this MagicNumber
   for(int j=0;j<OrdersTotal();j++)
   {
      OrderSelect(j,SELECT_BY_POS,MODE_TRADES);

   //---- Assert MagicNumber and Symbol is same as Order
      if (OrderMagicNumber()==MagicNumber && OrderSymbol()==Symbol())
         profit+=OrderProfit();
   }
   return(profit);
}
//+------------------------------------------------------------------+
//| count all the same pair trades                                   |
//+------------------------------------------------------------------+
int count_magic_total()
{
   int count=0;

//---- Assert determine count of all trades done with this MagicNumber
   for(int j=0;j<OrdersTotal();j++)
   {
      OrderSelect(j,SELECT_BY_POS,MODE_TRADES);

   //---- Assert MagicNumber and Symbol is same as Order
      if (OrderMagicNumber()==MagicNumber && OrderSymbol()==Symbol())
         count++;
   }
   return(count);
}
//+------------------------------------------------------------------+
//| count all trades controlled (i.e. MagicNumber 1,2 and 3 only     |
//| if index is 1, count only that MagicNumber, e.g. 1 only          |
//+------------------------------------------------------------------+
int count_magic_number_total(int index)
{
   int count=0,magic=0;

//---- Assert determine count of all trades done with this MagicNumber
   for(int j=0;j<OrdersTotal();j++)
   {
      OrderSelect(j,SELECT_BY_POS,MODE_TRADES);
   //---- Assert MagicNumber and Symbol is same as Order
      if (OrderSymbol()==Symbol())
      {
         if (MagicNumber1>0 && OrderMagicNumber()==MagicNumber1) 
         {
            if (index==1) magic++;
            count++;
         }
         if (MagicNumber2>0 && OrderMagicNumber()==MagicNumber2)
         {
            if (index==2) magic++;
            count++;
         }
         if (MagicNumber3>0 && OrderMagicNumber()==MagicNumber3) 
         {
            if (index==3) magic++;
            count++;
         }
      }
   }
   if (index==0) return(count);
   else return(magic);
}
/*
//+------------------------------------------------------------------+
//| count buy trades of the same magic number                        |
//+------------------------------------------------------------------+
int count_buy_magic_total()
{
   int count=0;

//---- Assert determine count of all trades done with this MagicNumber
   for(int j=0;j<OrdersTotal();j++)
   {
      OrderSelect(j,SELECT_BY_POS,MODE_TRADES);

   //---- Assert MagicNumber and Symbol is same as Order
      if (OrderMagicNumber()==MagicNumber && OrderSymbol()==Symbol() && OrderType()==OP_BUY)
         count++;
   }
   return(count);
}
//+------------------------------------------------------------------+
//| count sell trades of the same magic number                       |
//+------------------------------------------------------------------+
int count_sell_magic_total()
{
   int count=0;

//---- Assert determine count of all trades done with this MagicNumber
   for(int j=0;j<OrdersTotal();j++)
   {
      OrderSelect(j,SELECT_BY_POS,MODE_TRADES);

   //---- Assert MagicNumber and Symbol is same as Order
      if (OrderMagicNumber()==MagicNumber && OrderSymbol()==Symbol() && OrderType()==OP_SELL)
         count++;
   }
   return(count);
}
//+------------------------------------------------------------------+
//| Display comment on chart                                         |
//+------------------------------------------------------------------+
bool secure_profitrun(int ticket)
{
   bool Changed;
   double TP, OldTP, NewTP;
//---- Assert ticket is valid.
   if (ticket<=0)
   {
      Print("secure_profitrun():ticket=",ticket," number is invalid.");
      return(false);
   }
   OrderSelect(ticket, SELECT_BY_TICKET);

   if (OrderType()==OP_BUY)
   {
   //---- Assert Set TP in Pips
      OldTP=MathAbs(OrderTakeProfit()-OrderOpenPrice())/Pts;
      NewTP=OldTP*(MathMin(1,MathAbs((TimeCurrent()-OrderOpenTime())/60*30-1))*(2-1)+1);
      TP=NormalizeDouble(OrderOpenPrice()+NewTP*Pts,Digits);
      Changed=OrderModify(ticket,OrderOpenPrice(),OrderStopLoss(),TP,0,Thistle);
      if (!Changed)
      {
         Print("Error modifying BUY order : ",GetLastError());
         if (Debug>=2) Print("secure_profitrun():Symbol()=",Symbol(),",Bid=",MarketInfo(Symbol(),MODE_BID),",SlipPage=",SlipPage);
      }
   }
   else if (OrderType()==OP_SELL)
   {
   //---- Assert Set TP=2*TP in Pips
      OldTP=MathAbs(OrderOpenPrice()-OrderTakeProfit())/Pts;
      NewTP=OldTP*(MathMin(1,MathAbs((TimeCurrent()-OrderOpenTime())/60*30-1))*(2-1)+1);
      TP=NormalizeDouble(OrderOpenPrice()-NewTP*Pts,Digits);
      Changed=OrderModify(ticket,OrderOpenPrice(),OrderStopLoss(),TP,0,Red);
      if (!Changed)
      {
         Print("Error modifying SELL order : ",GetLastError());
         if (Debug>=2) Print("secure_profitrun():Symbol()=",Symbol(),",Ask=",MarketInfo(Symbol(),MODE_ASK),",SlipPage=",SlipPage);
      }
   }
}
bool secure_cutloss(int ticket)
{
   bool Changed;
   double TP, OldTP;
   double SL;
//---- Assert ticket is valid.
   if (ticket<=0)
   {
      Print("secure_cutloss():ticket=",ticket," number is invalid.");
      return(false);
   }
   OrderSelect(ticket, SELECT_BY_TICKET);

   if (OrderType()==OP_BUY)
   {
   //---- Assert Set TP and SL in Pips
      OldTP=MathAbs(OrderTakeProfit()-OrderOpenPrice())/Pts;
      TP=NormalizeDouble(MarketInfo(Symbol(),MODE_BID)+OldTP*Pts,Digits);
      SL=NormalizeDouble(MarketInfo(Symbol(),MODE_BID)-OldTP*Pts,Digits);
      Changed=OrderModify(ticket,OrderOpenPrice(),SL,TP,0,Thistle);
      if (!Changed)
      {
         Print("Error modifying BUY order : ",GetLastError());
         if (Debug>=2) Print("secure_cutloss():Symbol()=",Symbol(),",Bid=",MarketInfo(Symbol(),MODE_BID),",SlipPage=",SlipPage);
      }
   }
   else if (OrderType()==OP_SELL)
   {
   //---- Assert Set TP and SL in Pips
      OldTP=MathAbs(OrderTakeProfit()-OrderOpenPrice())/Pts;
      TP=NormalizeDouble(MarketInfo(Symbol(),MODE_ASK)-OldTP*Pts,Digits);
      SL=NormalizeDouble(MarketInfo(Symbol(),MODE_ASK)+OldTP*Pts,Digits);
      Changed=OrderModify(ticket,OrderOpenPrice(),SL,TP,0,Red);
      if (!Changed)
      {
         Print("Error modifying SELL order : ",GetLastError());
         if (Debug>=2) Print("secure_cutloss():Symbol()=",Symbol(),",Ask=",MarketInfo(Symbol(),MODE_ASK),",SlipPage=",SlipPage);
      }
   }
}
*/
//+------------------------------------------------------------------+
//| Secure breakeven                                                 |
//+------------------------------------------------------------------+
bool secure_breakeven(int ticket)
{
   bool Closed;
   double CalcLot;
//---- Assert ticket is valid.
   if (ticket<=0)
   {
      Print("secure_breakeven():ticket=",ticket," number is invalid.");
      return(false);
   }
   OrderSelect(ticket, SELECT_BY_TICKET);
//---- Assert OrderLot - CalcLot > MinLot
   CalcLot=NormalizeDouble(OrderLots()*0.4,2);
   if ((OrderLots()-CalcLot)<MinLot)
   {
      CalcLot=OrderLots()-MinLot;
   }
   if (CalcLot<=0) return(false);

   if (OrderType()==OP_BUY)
   {
   //---- Assert close partial lots
      Closed=OrderClose(ticket,CalcLot,MarketInfo(Symbol(),MODE_BID),SlipPage,Red);
      
      if (!Closed)
      {
         Print("Error closing BUY order : ",GetLastError());
         if (Debug>=2) Print("secure_breakeven():Symbol()=",Symbol(),",Bid=",MarketInfo(Symbol(),MODE_BID),",SlipPage=",SlipPage);
      }
   }
   else if (OrderType()==OP_SELL)
   {
   //---- Assert Set SL=SecureProfit
      Closed=OrderClose(ticket,CalcLot,MarketInfo(Symbol(),MODE_ASK),SlipPage,Thistle);
      
      if (!Closed)
      {
         Print("Error closing SELL order : ",GetLastError());
         if (Debug>=2) Print("secure_breakeven():Symbol()=",Symbol(),",Ask=",MarketInfo(Symbol(),MODE_ASK),",SlipPage=",SlipPage);
      }
   }
   return(Closed);
}
//+------------------------------------------------------------------+
//| Trigger a signal depending on the condition                      |
//+------------------------------------------------------------------+
int trigger_signal(int ticket)
{
//---- Assert ticket is valid.
   if (ticket<=0)
   {
      Print("trigger_signal():ticket=",ticket," number is invalid.");
      return(false);
   }
   OrderSelect(ticket,SELECT_BY_TICKET);

//---- Assert ticket is open 
   if (OrderCloseTime()!=0) return(0);

//---- Assert Secure Profit Breakeven / Let the losses recover (maximum risk is +SL, maximum reward is 40% of TP)
   if (OrderType()==OP_BUY && SecureProfitOnMins>0 && OrderProfit()>0) return(1);
//---- Assert Secure Profit Breakeven / Let the losses recover (maximum risk is +SL, maximum reward is 40% of TP)
   if (OrderType()==OP_SELL && SecureProfitOnMins>0 && OrderProfit()>0) return(-1);
   
//---- Assert ticket order time is <=30 minutes and Secure Profit Run / Cut Loss
   if (TimeCurrent()-OrderOpenTime()<=60*30)
   {
   //---- Assert OrderType=Buy and MaFast1>MaSlow1 and MaFast0<MaSlow0 (maximum risk is INFINITY, maximum reward is Profit Run)
   //---- Assert the Stop Loss is below the Open Price and OrderType=Sell (maximum risk is +SL, maximum reward is Profit Run)
      //if (OrderType()==OP_SELL && OrderStopLoss()<=OrderOpenPrice() && MathAbs(OrderOpenPrice()-OrderTakeProfit())<=TakeProfit*Pts) return(-5);

   //---- Assert the StopLoss is default and OrderType=Buy and OrderProfit>40Pips (maximum risk -SL, maximum reward Cut Loss)
      if (OrderType()==OP_BUY && OrderStopLoss()<OrderOpenPrice() && MathAbs(OrderOpenPrice()-OrderStopLoss())>=StopLoss*Pts && OrderOpenPrice()>MarketInfo(Symbol(),MODE_BID) && MathAbs(OrderOpenPrice()-MarketInfo(Symbol(),MODE_BID))>StopLoss*Pts/2)
      {
         if (Debug>=2) Print("trigger_signal():Symbol()=",Symbol(),",Bid=",MarketInfo(Symbol(),MODE_BID),",trigger_signal=4 CUT LOSS on BUY position");
         return(4);
      }
   //---- Assert the StopLoss is default and OrderType=Sell and OrderProfit>40Pips (maximum risk -SL, maximum reward Cut Loss)
      if (OrderType()==OP_SELL && OrderStopLoss()>OrderOpenPrice() && MathAbs(OrderOpenPrice()-OrderStopLoss())>=StopLoss*Pts && OrderOpenPrice()<MarketInfo(Symbol(),MODE_ASK) && MathAbs(OrderOpenPrice()-MarketInfo(Symbol(),MODE_ASK))>StopLoss*Pts/2) 
      {
         if (Debug>=2) Print("trigger_signal():Symbol()=",Symbol(),",Ask=",MarketInfo(Symbol(),MODE_ASK),",trigger_signal=4 CUT LOSS on SELL position");
         return(-4);
      }
   }
}
void show_comment(int total, double profit)
{
   string cmt;
   
//---- Assert Basic settings in comment
   cmt=TradeComment+"\n  TP="+DoubleToStr(TakeProfit,0)+"  SL="+DoubleToStr(StopLoss,0)+"\n";
//---- Assert Money management in comment
   if (AutoMM>0)
      cmt=cmt+s2+"\n  AutoMM="+DoubleToStr(AutoMM,1)+"%-ENABLED\n";
   cmt=cmt+"  Lots="+DoubleToStr(get_lots(),2)+"  (Min="+DoubleToStr(MinLot,2)+"; Max="+DoubleToStr(MaxLot,2)+")\n";
   cmt=cmt+"  MAT="+MaxAccountTrades+"  MSPT="+MaxSamePairTrades+"\n";
   if (SecureProfitOnMins>0)
      cmt=cmt+"  SECURE Profit in "+DoubleToStr((SecureProfitOnMins)-(TimeCurrent()-securetime)/60,0)+" mins\n";
   cmt=cmt+"  ATR="+DoubleToStr(iATR(NULL,0,14,0),4)+"\n";
//---- Assert Trend Logic in comment
   cmt=cmt+s3+"\n  BBR="+DoubleToStr(BearBullRatio,1);
   if (BearBullRatio==1)
      cmt=cmt+"-COUNTERCYCLE\n";
   else if (BearBullRatio<1)
      cmt=cmt+"-BULLISH\n";
   else
      cmt=cmt+"-BEARISH\n";
   cmt=cmt+"  MaFast="+DoubleToStr(MaFast,1)+"  MaSlow="+DoubleToStr(MaSlow,1)+"\n";
   if (BearBullRatio!=1)
      cmt=cmt+"  BbrBTO="+DoubleToStr(BbrBTO,1)+"  BbrSTO="+DoubleToStr(BbrSTO,1)+"\n";
//---- Assert Broker info in comment
   cmt=cmt+"-->Broker Account<--\n";
   double spread=MarketInfo(Symbol(),MODE_SPREAD)/Pip;
   cmt=cmt+"  Spread="+DoubleToStr(spread,1);
   if (spread<1)
      cmt=cmt+"-LOW";
   else if (spread>3)
      cmt=cmt+"-HIGH";
   else
      cmt=cmt+"-NORMAL";
   cmt=cmt+"  (Max="+DoubleToStr(MaxSpread,1)+")\n";
//---- Assert Account info in comment
   cmt=cmt+"  ActBal="+DoubleToStr(AccountBalance(),2)+"  Equity="+DoubleToStr(AccountEquity(),2)+"\n";
   if (UserLot!=0 || UserOpenSignal!=0)
      cmt=cmt+"  User Has Pending Order-WARNING\n";
//---- Assert Trade info in comment
   if (total>0)
      cmt=cmt+"  Trades="+total+"  Profit="+DoubleToStr(profit,2)+"\n";
   else
      cmt=cmt+"  No Active Trades\n";
//---- Assert Controlling Magic numbers in Comment
   if (MagicNumber1>0 || MagicNumber2>0 || MagicNumber3>0)
   {
      cmt=cmt+"-->Controlled Magic Number<--\n";
      if (count_magic_number_total(0)==0)
         cmt=cmt+"  No Active Trades\n";
      else
      {
         if (count_magic_number_total(1)>0)
            cmt=cmt+"  MagicNumber1="+DoubleToStr(MagicNumber1,0)+"  Trades="+count_magic_number_total(1)+"\n";
         if (count_magic_number_total(2)>0)
            cmt=cmt+"  MagicNumber2="+DoubleToStr(MagicNumber2,0)+"  Trades="+count_magic_number_total(2)+"\n";
         if (count_magic_number_total(3)>0)
            cmt=cmt+"  MagicNumber3="+DoubleToStr(MagicNumber3,0)+"  Trades="+count_magic_number_total(3)+"\n";
      }
   }
   Comment(cmt);
}

//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
{
   int cnt;
   bool securenow=false;
//---- initial data checks
   if(Bars<100)
   {
      Print("bars less than 100");
      return(0);  
   }

//---- Assert Trigger Secure Profit / Cut Loss

   if (count_magic_total()>0 || count_magic_number_total(0)>0)
   {
      if (SecureProfitOnMins>0 && (TimeCurrent()-securetime)>SecureProfitOnMins*60)
      {
         securetime=TimeCurrent();
         securenow=true;
      }
      else
      {
         handle_secureprofitonhour(false);
      }

   //---- Assert modify trades depending on trigger signal
      for(cnt=0;cnt<OrdersTotal();cnt++)
      {
         OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES);
      //---- Assert Symbol is same as Order
         if (OrderSymbol()!=Symbol()) continue;
      //---- Assert control over additional MagicNumbers         
         if ((MagicNumber1>0 && OrderMagicNumber()==MagicNumber1) || (MagicNumber2>0 && OrderMagicNumber()==MagicNumber2) || (MagicNumber3>0 && OrderMagicNumber()==MagicNumber3))
         {
         }
      //---- Assert MagicNumber is same as Order
         else if (OrderMagicNumber()!=MagicNumber) continue;
      //---- Check for STC signal
         if (OrderType()==OP_BUY && close_signal()==1)
         {
            if (sell_to_close(OrderTicket())) 
            {
               cnt--;
               continue;
            }
         }
      //---- Check for BTC signal
         if (OrderType()==OP_SELL && close_signal()==-1)
         {
            if (buy_to_close(OrderTicket()))
            {
               cnt--;
               continue;
            }
         }
      //---- Check for secure trigger signal
         switch (trigger_signal(OrderTicket()))
         {
            case -4: buy_to_close(OrderTicket());        break;
            case 4:  sell_to_close(OrderTicket());       break;
            default:                                     break;   //do nothing
         }
      //---- Check for secure trigger signal
         if (securenow)
         {
            switch (trigger_signal(OrderTicket()))
            {
               case -1: secure_breakeven(OrderTicket());    break;
               case 1:  secure_breakeven(OrderTicket());    break;
               default:                                     break;   //do nothing
            }
            securenow=false;
         }
      }
   }
   else
   {
      if (SecureProfitOnMins>0)
      {
         handle_secureprofitonhour(true);
         securetime=TimeCurrent();
         securenow=false;
      }
   }

//---- Assert Trigger Secure Profit 
   
   // check for BTO signal
   if(open_signal()==-1)
   {
      buy_to_open(OrdersTotal());
   }
   // check for STO signal
   if(open_signal()==1)
   {
      sell_to_open(OrdersTotal());
   }
   
//---- Assert display comments
   if (!IsTesting() && !IsOptimization()) show_comment(count_magic_total(),count_magic_profit());

   return(0);
}
//+------------------------------------------------------------------+