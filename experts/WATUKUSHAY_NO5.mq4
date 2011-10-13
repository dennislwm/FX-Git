//+-----------------------------------------------------------------------------------+
//| Watukushay No.5 - Atipaq :o)                                                      |
//| Copyright © 2010, Daniel Fernandez, fxreviews.blogspot.com , Asirikuy.com         |
//|                                                      Copyright © 2011, Dennis Lee |
//| Assert History                                                                    |
//| 1.22    Once trendlines are established do not open actual pending orders.        |
//| 1.21    Delete pending orders once trendlines are established.                    |
//|         Delete both trendlines once either pending order is opened.               |
//| 1.20    Added PlusSwiss.mqh.                                                      |
//| 1.10    Revert the fade code as box functions depend on actual pending orders.    |
//|             Hard-coded fade code to use 0.01 lot, but Linex uses g_tradeSize.     |
//| 1.00    Added PlusLinex.mqh                                                       |
//|         Added PlusEasy.mqh                                                        |
//|                                                                                   |
//+-----------------------------------------------------------------------------------+

#property copyright "Copyright © 2010-2011, Daniel Fernandez"
#property link      "asirikuy.com"

// this is our Asirikuy Delphi NTP implementation
#import "clocklibrary_NTP.dll"
void  GetAlpariOffset(double& time[7]);
#import

#include <stdlib.mqh>
#include <stderror.mqh>

// For double comparisons
#define EPSILON 0.0000001

#define COMPONENT_NAME    "Atipaq"
#define COMPONENT_VERSION "F3.68a"

#define OP_DEPOSITORWITHDRAWAL         6

#define SECONDS_IN_DAY                 86400

#define NO_TIME_VALUE_SAVED           -100

#define ALERT_STATUS_NEW               0
#define ALERT_STATUS_DISPLAYED         1


//--------------------------------------------------------- Equity track begin -------------------------
#define EQUITY_TRACK_NONE  0
#define EQUITY_TRACK_FILE  1
//--------------------------------------------------------- Equity track end -------------------------


#define OPERATIONAL_MODE_TRADING       0
#define OPERATIONAL_MODE_MONITORING    1
#define OPERATIONAL_MODE_TESTING       2

#define PREFERED_ORDER_TYPE_STOP       0
#define PREFERED_ORDER_TYPE_LIMIT      1

#define STATUS_NONE                   -1
#define STATUS_INVALID_BARS_COUNT      0
#define STATUS_INVALID_TIMEFRAME       1
#define STATUS_DIVIDE_BY_ZERO          2
#define STATUS_LAST_ERROR              3
#define STATUS_ATR_INIT_PROBLEM        4
#define STATUS_TRADE_CONTEXT_BUSY      5
#define STATUS_TRADING_NOT_ALLOWED     6
#define STATUS_TIME_DETECTION_FAILED   7
#define STATUS_DUPLICATE_ID            8
#define STATUS_RUNNING_ON_DEFAULTS     9
#define STATUS_BELOW_MIN_LOT_SIZE      10
#define STATUS_LIBS_NOT_ALLOWED        11
#define STATUS_DLLS_NOT_ALLOWED        12
#define STATUS_TIMEARRAY_MISMATCH      13

#define FAILED_OFFSET               -1
#define NOUPDATE_OFFSET              0
#define NEW_OFFSET                   1

#define QUERY_NONE                   0
#define QUERY_LONGS_COUNT            1
#define QUERY_SHORTS_COUNT           2
#define QUERY_BUY_STOP_COUNT         3
#define QUERY_SELL_STOP_COUNT        4
#define QUERY_BUY_LIMIT_COUNT        5
#define QUERY_SELL_LIMIT_COUNT       6
#define QUERY_ALL                    7

#define SITUATION_NONE             -1
#define CREATE_UPPER_BOX_SECTION    0
#define CREATE_LOWER_BOX_SECTION    1
#define SITUATION_BOX_ACTIVE        2

#define SIGNAL_NONE                   -1

#define SIGNAL_CREATE_PEND_ORDER_BUY  0
#define SIGNAL_CREATE_PEND_ORDER_SELL 1

#define BREAKEVEN_COLOR  DarkOrange
#define BUY_COLOR        DodgerBlue
#define BUY_CLOSE_COLOR  Blue
#define SELL_COLOR       DeepPink
#define SELL_CLOSE_COLOR Red
#define TRAILING_COLOR   LightGreen

// Status management
#define SEVERITY_INFO  0
#define SEVERITY_ERROR 1

extern string AsirikuyID_Atipaq_="Global ID Tag";
extern string s1 = "---  General settings  ---";
extern string s1_2 = "Always use total account balance";
extern string s1_22 = "(takes into account profit/losses from other systems)";
extern bool UseGlobalBalance = false ;
extern string s1_21 = "Internal Balance Reset (days)";
extern string s1_31 = "(after this period internal balance will be" ;
extern string s1_32 = " reset to your account global balance)";
extern int ResetPeriod = 365;
extern string s_13 = "Enables Time Autodetection, needs" ;
extern string s_14 = "the clocklibrary_NTP dll" ;
extern bool UseAutoTimeDetection = true ;
extern string s2 = "---  Operational mode  ---";
extern string s2_1 = "0-Trading, 1-Monitoring, 2-Testing";
extern int OperationalMode = OPERATIONAL_MODE_TRADING;

//--------------------------------------------------------- Equity track begin -------------------------
extern string s2_2 = "---  Equity tracking  ---";
extern string s2_2_1 = "0-None, 1-Log into file";
extern int EquityTrackMode = EQUITY_TRACK_NONE;
extern string s2_2_2 = "Name of logfile - without extension";
extern string EquityTrackFileName = "EquityLog";
//--------------------------------------------------------- Equity track end -------------------------

extern string s3 = "---  Money management  ---";
extern string s3_3 = "Multiplier of the lot sizing equation, proportional " ;
extern string s3_4 = "to the percentage of the account risked per trade";
extern double AccountRiskUnit = 1;
extern string s3_31 = "Record maximum value of adaptive criteria " ;
extern string s3_32 = "saves value to the MaxAdaptive Global Variable " ;
extern bool recordMaxAdaptive = false;
extern string s3_5 = "Maximal acceptable slippage";
extern int Slippage = 3;
extern string s5 = "ATR settings";
extern int ATRAveragingPeriod   = 14 ;
extern string s13 = "time after which pending orders are cancelled when they happen";
extern int Cancel_hour = 10;
extern string s341 = "Hour at which the box is generated and pending orders are set";
extern int Entry_Hour_Set = 0 ;
extern string s17 = "number of hours to count back to form the box";
extern int Entry_Hour_Breakout = 8 ;
extern string s18 = "distance as box multiple to move SL";
extern double Move_SL_Box_Multiple = 0 ;
extern string s19 = "maximum size of the box to set pending orders (ATR%)";
extern double max_box_size_ATR = 30 ;
extern string s110 = "minimum size of the box to set pending orders (ATR%)";
extern double min_box_size_ATR = 0 ;
extern string s111 = "set FIFO = true for only one trade opened at a time";
extern bool NFACompliant = false ;
extern string s123 = "This variable controls the type of orders opened" ;
extern string s112 = "Set to 0 to set stop orders (trade breakouts)";
extern string s122 = "Set to 1 to set limit orders (fade breakouts)";
extern int preferred_order = PREFERED_ORDER_TYPE_STOP  ;
extern string s114 = "distance as box multiple from high/low to set pending orders";
extern double Buffer_Box_Multiple = 1.0;
extern string s115 = "profit of the pending orders as a box multiple";
extern double Profit_Box_Multiple = 3.1 ;
//---- Assert PlusEasy externs
extern string s51="-->PlusEasy Settings<--";
#include <pluseasy.mqh>
//extern double EasyLot=0.1;
//---- Assert PlusSwiss externs
extern string s52="-->PlusSwiss Settings<--";
#include <plusswiss.mqh>
//---- Assert PlusLinex externs
extern string s53="-->PlusLinex Settings<--";
#include <pluslinex.mqh>
extern string s6_1 = "The identifier of trades, opened by this instance";
extern int InstanceID = -1;
extern string s6_2 = "Trade description";
extern string TradeDescription = "Atipaq F3";
extern string s7 = "UI settings";
extern color InformationColor = LightBlue;
extern string s7_1 = "Show High/Low Box Lines";
extern bool ShowLines = true ;
extern int LineWidth = 3 ;
extern color OnChartInformation = White ;
extern int OnChartInformationFontSize =12 ;
extern color ErrorColor = Red;
extern int FontSize = 14;
extern string s8_1 = "Capture trade screenshots";
extern bool saveTradeScreenshots = false ;

// EA global variables
string g_symbol;
double g_pipValue;
double g_ATR;
bool g_sundayCandleExists ;
int g_offsetstatus ;
int g_offset ;
double g_adaptiveValue ;
double g_generatedInstanceID ;
double g_instancePL_UI ;

//Initial balance and balance reset variables
string g_balanceTimeLabel ;
string g_initialBalanceLabel ;
string g_initBalBackupFile ;
int g_balanceBackupTime = 0 ;
double g_initialBalance ;
int g_instanceStartTime ;
int g_savedTimeArrayValue;
int g_savedHourForComparison;

double g_maxTradeSize,
       g_minTradeSize,
		 g_tradeSize,
		 g_boxhigh,
		 g_boxlow,
		 g_instanceBalance,
		 g_BoxSize,
		 g_adjustedSlippage,
		 g_tradeSize2 ; // this variable is later used to determine the last trade's lot size

int g_alertStatus ;
string g_lastError ;


int g_minimalStopPIPs;
int g_contractSize,
	 g_brokerDigits,
	 g_stopLossPIPs,
	 g_takeProfitPIPs,
	 g_tradingSignal;
	 
int Entry_Hour_Set_Used ;

//--------------------------------------------------------- Equity track begin -------------------------
int g_fileEquityLog;
string g_currentDay="",
       g_timeOfEquityMin; 
double g_dailyEquityMin,
       g_prevDailyEquityMin;
//--------------------------------------------------------- Equity track end -------------------------

//-------------------   UI staff   ------------------

// Graphical entities names
string g_objTradeSize        = "labelTradeSize",
		 g_objStopLoss         = "labelStopLoss",
		 g_objTakeProfit       = "labelTakeProfit",
		 g_objATR              = "labelATR",
		 g_objPL               = "labelPL",
		 g_objStatusPane       = "labelStatusPane",
		 g_objGeneralInfo      = "labelgeneralinfo",
		 g_objSundayCandlesInfo   = "labelSundayCandle",
		 g_objBoxHigh            = "labelboxhigh",
		 g_objBoxLow             = "labelboxlow",
		 g_objIsHour             = "labelIsHour",
		 g_objBalance               = "labelBalance",
		 g_objautotime           = "labelautotime" ;
string g_fontName = "Times New Roman";

// The value at index 'i' returns the string
// to be displayed for the error/warning, having ID equal to i.
string g_statusMessages[];

// The value at index 'i' returns the string
// to be displayed for pattern, having ID equal to i.
string g_detectedSituationNames[];

// UI state management
int g_severityStatus,
	 g_lastStatusID          = STATUS_NONE,
	 g_lastDetectedSituationID = SITUATION_NONE;

// The offset, in pixels, of the first information line from the top-left corner.
int g_baseXOffset = 15,
	 g_baseYOffset = 20;
	 
color HighLineColor = Blue ,
      LowLineColor = Red   ;

// Controls how far or near are text lines on Y axis
double g_textDensingFactor = 1.5;

// The EA initialization funtion
int init() 
{
//--- Assert PlusLinex.mqh
   EasyInit();
   SwissInit();
   LinexInit();

   displayWelcomeMessage() ;
   
   updateResetBalanceTime() ;
   
   if (UseGlobalBalance)
   {
   g_initialBalance = AccountBalance() ;
   }
   
   if (recordMaxAdaptive)
   {
   GlobalVariableSet("MaxAdaptive", 0) ;
   GlobalVariableSet("MinAdaptive", 100);
   }
   
   g_savedTimeArrayValue = NO_TIME_VALUE_SAVED ;
   g_savedHourForComparison = NO_TIME_VALUE_SAVED ;

	g_symbol = Symbol();
	g_pipValue = Point;
	
	
	generateInstanceID() ;
	
	// set previous update time so that we update as soon as the platform starts
	GlobalVariableSet("lastUpdateTime", TimeCurrent()-600) ;

	// Retrieve the minimum stop loss in PIPs
	g_minimalStopPIPs = MarketInfo( g_symbol, MODE_STOPLEVEL );
	g_maxTradeSize    = MarketInfo( g_symbol, MODE_MAXLOT    );
	g_minTradeSize    = MarketInfo( g_symbol, MODE_MINLOT    );

	g_brokerDigits  = Digits;
	g_tradingSignal = SIGNAL_NONE;
   
   if(OperationalMode != OPERATIONAL_MODE_TESTING )
	initUI();
	
	//--------------------------------------------------------- Equity track begin -------------------------	
	if( EQUITY_TRACK_FILE == EquityTrackMode && IsTesting())
	  initEquityLog();
   //--------------------------------------------------------- Equity track end -------------------------


	// Success
	return (0);
}

//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
{
   if(OperationalMode != OPERATIONAL_MODE_TESTING )
	deinitUI();
	
	//--------------------------------------------------------- Equity track begin -------------------------
	if( EQUITY_TRACK_FILE == EquityTrackMode && IsTesting())
	  deinitEquityLog();
   //--------------------------------------------------------- Equity track end ---------------------------
	
	
	return (0);
}

//+------------------------------------------------------------------+
//| Tick handling function                                           |
//+------------------------------------------------------------------+
int start()
{

   g_lastStatusID = STATUS_NONE ;

	g_severityStatus = SEVERITY_INFO;
	if( Bars < Entry_Hour_Breakout )
	{
		g_severityStatus = SEVERITY_ERROR;
		g_lastStatusID   = STATUS_INVALID_BARS_COUNT;
		if(OperationalMode != OPERATIONAL_MODE_TESTING )
		{
		updateStatusUI( true );
      }
      
		return (0);
	}
	
	checkLibraryUsageAllowed();
	
	if(  STATUS_LIBS_NOT_ALLOWED  == g_lastStatusID ||
	     STATUS_DLLS_NOT_ALLOWED        == g_lastStatusID )
	{
	     g_severityStatus = SEVERITY_ERROR;
		if( OPERATIONAL_MODE_TESTING != OperationalMode )
			updateStatusUI( true );

		return (0);
	}
	
	//--------------------------------------------------------- Equity track begin -------------------------
	if( EQUITY_TRACK_FILE == EquityTrackMode && IsTesting())
	  updateEquityLog();
   //--------------------------------------------------------- Equity track end ---------------------------
   
   // check if we are running on defaults
	isInstanceIDDefault(InstanceID);
	
	if(  STATUS_RUNNING_ON_DEFAULTS  == g_lastStatusID )
	{
	     g_severityStatus = SEVERITY_ERROR;
		if( OPERATIONAL_MODE_TESTING != OperationalMode )
			updateStatusUI( true );

		return (0);
	}
	
	verifyInstanceIDUniquiness();
	
	if(  STATUS_DUPLICATE_ID == g_lastStatusID )
	{
	     g_severityStatus = SEVERITY_ERROR;
		if( OPERATIONAL_MODE_TESTING != OperationalMode )
			updateStatusUI( true );

		return (0);
	}
	
	if( OPERATIONAL_MODE_TESTING != OperationalMode && !UseGlobalBalance )
	{
	getInstanceBalanceInformation() ;
	checkBalanceResetTime() ;
	}
	
	if( OPERATIONAL_MODE_TESTING != OperationalMode && UseAutoTimeDetection )
	{
	makeNTPQuery() ;
	LoadAlpariOffset() ;
	} else {
	Entry_Hour_Set_Used = Entry_Hour_Set ;
	}
	
	
	if( STATUS_TIME_DETECTION_FAILED == g_lastStatusID )
	{  
	   g_severityStatus = SEVERITY_ERROR;
	   if(OperationalMode != OPERATIONAL_MODE_TESTING )
		updateStatusUI( true );
		return (0);
	}
	
	detectTimeArrayMismatch();
	
	if( STATUS_TIMEARRAY_MISMATCH      == g_lastStatusID )
	{
		g_severityStatus = SEVERITY_ERROR;
		if( OperationalMode != OPERATIONAL_MODE_TESTING )
			updateStatusUI( true );

		return (0);
	}
	
	if( OPERATIONAL_MODE_TESTING != OperationalMode )
	detectSundayCandles() ;

	calculateATR();
	if( STATUS_DIVIDE_BY_ZERO == g_lastStatusID )
	{  
	   g_severityStatus = SEVERITY_ERROR;
	   if(OperationalMode != OPERATIONAL_MODE_TESTING )
		updateStatusUI( true );
		return (0);
	}
	if( STATUS_ATR_INIT_PROBLEM == g_lastStatusID )
	{
	   g_severityStatus = SEVERITY_ERROR;
	   if(OperationalMode != OPERATIONAL_MODE_TESTING )
		updateStatusUI( true );
		return (0);
	}
	
	if(OperationalMode != OPERATIONAL_MODE_TESTING)
	{
	calculateInstanceBalance();
	}

   calculateBoxSize() ;
   g_stopLossPIPs = calculateStopLossInPIPS() ;
   g_takeProfitPIPs = calculateTakeProfitInPIPS() ;
   g_tradeSize2 = calculateActiveTradesSize() ;
   adjustSlippage();
	calculateContractSize();
	calculateTradeSize();

	int chartTimeFrame = Period();
	if( chartTimeFrame != PERIOD_H1 )
	{
		g_severityStatus = SEVERITY_ERROR;
		g_lastStatusID   = STATUS_INVALID_TIMEFRAME;
		
	
	// Handle already opened trades
      if(OperationalMode != OPERATIONAL_MODE_TESTING )
		updateUI();
	}

	g_tradingSignal = checkTradingSignal();
  
   if(OperationalMode != OPERATIONAL_MODE_TESTING )
	updateUI();


	if( OPERATIONAL_MODE_MONITORING == OperationalMode )
	{
		// Just handle existing trade
		return (0);
	}

	g_tradingSignal = checkTradingSignal();
	switch( g_tradingSignal ) {
	case SIGNAL_CREATE_PEND_ORDER_BUY:
		openBuyOrder();
	break;	
   case SIGNAL_CREATE_PEND_ORDER_SELL:
		openSellOrder();
	break;
	
	if( ( STATUS_TRADE_CONTEXT_BUSY  == g_lastStatusID ) ||
		 ( STATUS_TRADING_NOT_ALLOWED == g_lastStatusID ) ||
		 ( STATUS_BELOW_MIN_LOT_SIZE == g_lastStatusID ) 
	  )
	{
		g_severityStatus = SEVERITY_ERROR;
		if( OperationalMode != OPERATIONAL_MODE_TESTING )
			updateStatusUI( true );
	}							
									  } // switch( g_tradingSignal )
//--- Assert PlusSwiss.mqh
   if (EasyOrdersMagic(Linex1Magic)>0)
   {
      SwissManager(Linex1Magic,Symbol(),Pts);
   }
   if (EasyOrdersMagic(Linex2Magic)>0)
   {
      SwissManager(Linex2Magic,Symbol(),Pts);
   }
//--- Assert Delete pending orders once trendlines are established.
   int count_pending_longs = queryOrdersCount(OP_BUYSTOP)+queryOrdersCount(OP_BUYLIMIT), // calculate pending buy orders
      count_pending_shorts = queryOrdersCount(OP_SELLSTOP)+queryOrdersCount(OP_SELLLIMIT); // calculate pending buy orders
   if (ObjectFind(Linex1)>=0 && ObjectFind(Linex2)>=0 && (count_pending_longs+count_pending_shorts)>=2)
   {
      deleteOrderType(OP_BUYSTOP);
      deleteOrderType(OP_BUYLIMIT);
      deleteOrderType(OP_SELLSTOP);
      deleteOrderType(OP_SELLLIMIT);
   }
//--- Assert Added PlusLinex.mqh
   string strtmp;
   int ticket;
   int wave=Linex(Pts);
   switch(wave)
   {
      case 1:  
         ticket=EasySell(Linex1Magic,g_tradeSize);
         if(ticket>0) 
         {
            if (ObjectFind(Linex1)>=0) ObjectDelete(Linex1);
            if (ObjectFind(Linex2)>=0) ObjectDelete(Linex2);
            strtmp = "EasySell: "+Linex1+" "+Linex1Magic+" "+Symbol()+" "+ticket+" sell at " + DoubleToStr(Close[0],Digits);   
         }
         break;
      case -1: 
         ticket=EasyBuy(Linex1Magic,g_tradeSize); 
         if(ticket>0) 
         {
            if (ObjectFind(Linex1)>=0) ObjectDelete(Linex1);
            if (ObjectFind(Linex2)>=0) ObjectDelete(Linex2);
            strtmp = "EasyBuy: "+Linex1+" "+Linex1Magic+" "+Symbol()+" "+ticket+" buy at " + DoubleToStr(Close[0],Digits);   
         }
         break;
      case 2:  
         ticket=EasySell(Linex2Magic,g_tradeSize);
         if(ticket>0) 
         {
            if (ObjectFind(Linex1)>=0) ObjectDelete(Linex1);
            if (ObjectFind(Linex2)>=0) ObjectDelete(Linex2);
            strtmp = "EasySell: "+Linex2+" "+Linex2Magic+" "+Symbol()+" "+ticket+" sell at " + DoubleToStr(Close[0],Digits);   
         }
         break;
      case -2:  
         ticket=EasyBuy(Linex2Magic,g_tradeSize);
         if(ticket>0) 
         {
            if (ObjectFind(Linex1)>=0) ObjectDelete(Linex1);
            if (ObjectFind(Linex2)>=0) ObjectDelete(Linex2);
            strtmp = "EasyBuy: "+Linex2+" "+Linex2Magic+" "+Symbol()+" "+ticket+" buy at " + DoubleToStr(Close[0],Digits);   
         }
         break;
   }
   if (wave!=0) Print(strtmp);
                                      
	return (0);
}



////////////////------------ FUNCTIONS START -----------///////////////////////////////

//+-----------------------------------------------------------------------------------+
//|                           D E L E T E   O R D E R S                               |
//+-----------------------------------------------------------------------------------+
int deleteOrderType( int orderType ) 
{
	int ordersCount = 0;

	int total = OrdersTotal() ;
	for ( int i = 0 ; i < total+1; i++) 
	{
		OrderSelect( i, SELECT_BY_POS, MODE_TRADES );
		
		if( (        OrderType() ==  orderType ) &&
			 ( OrderMagicNumber() == InstanceID ) )
	   {
			 OrderDelete(OrderTicket());
			 ordersCount++;
		}
	}

	return(ordersCount);
}

void displayWelcomeMessage()
{
	string welcomeMessage = StringConcatenate("You are running ", COMPONENT_NAME, " v.", COMPONENT_VERSION) ;
	Alert( welcomeMessage );
}

void checkLibraryUsageAllowed()
{

if (IsDllsAllowed() == false) {
      //DLL calls must be allowed
      g_lastStatusID = STATUS_DLLS_NOT_ALLOWED ;
   }
   
if (IsLibrariesAllowed() == false) {
      //Library calls must be allowed
      g_lastStatusID = STATUS_LIBS_NOT_ALLOWED ;
   }

}

// This function verifies that we are not running on default settings. 
// If we are then an error is generated which stops trading.
// This is an important feature since several reasons can cause a platform 
// to "reset" back to the EA defaults, something which may be very detrimental
// depending on the systems. 

void isInstanceIDDefault(int ID)
{

   if (ID == -1)
   {
   g_lastStatusID = STATUS_RUNNING_ON_DEFAULTS ;
		return;
   }

}

void saveAdaptiveCriteria() 

{

   if( ! IsTesting() )
	{
		return;
	}


   double currentMax = GlobalVariableGet("MaxAdaptive");
   double currentMin = GlobalVariableGet("MinAdaptive");

   if (g_adaptiveValue > currentMax)
   
   {
   GlobalVariableSet("MaxAdaptive", g_adaptiveValue);
   }
   
   if (g_adaptiveValue < currentMin)
   
   {
   GlobalVariableSet("MinAdaptive", g_adaptiveValue);
   }

}

void makeNTPQuery()
{

// assign global variables which will be used for later calculations
 double alpariTime[7] ;
 bool update = false ;
 int updateTime =  GlobalVariableGet("lastUpdateTime");
 int AlpariHour,
     AlpariYear,
     AlpariMonth,
     AlpariDay ;
     
 ArrayInitialize(alpariTime, -1);
 
 // if a new minute happens and this instance is the first to see it then 
 // reassign global variables 
 if (MathAbs(TimeCurrent() - updateTime) > 300 )
 {
 
 GlobalVariableSet("lastUpdateTime", TimeCurrent());
 
 if (  Minute() < 55 && Minute() > 5)
 { 
 GlobalVariableSet("syncInstance", InstanceID) ;
 update = true ;
 }
 
 }
 
 //get instance ID - will update if chosen
 int syncInstance = GlobalVariableGet("syncInstance");
 
  // this sleep makes sure we don't run into
 // another system doing the same thing
  Sleep(100);
 
 // double check if the the permission is still there, 
 // this is to prevent hijacking from other systems
 // if someone hijacked then let that instance update (we quit)
 
 syncInstance = GlobalVariableGet("syncInstance");
 
 //if this instance is supposed to update then carry out
 //the NTP request and set the g_update variable to false
 //so that no further updates are done for this minute
 if( syncInstance == InstanceID && update ) 
 {
 
  // this function retrieves the time setting from the NTP server 
  // by calling the dll
  GetAlpariOffset(alpariTime);
  
  AlpariYear = alpariTime[0] ;
  AlpariMonth = alpariTime[1] ;
  AlpariDay = alpariTime[2] ;
  AlpariHour =  alpariTime[3] ;
  
  // printing of the relevant values
  if(AlpariHour != -1)
  {

  //calculate current offset between broker's hour and Alpari
  int offset = AlpariHour - Hour() ;
  
  // the if statements below correct the offset when there are day or Month
  // differences between instances.
  if (AlpariMonth == Month())
  {
  
      if (AlpariDay < Day())
      {
      offset = offset - 24 ;
      }
      
      if (AlpariDay > Day())
      {
      offset = offset + 24 ;
      }
  
  }
  
      if (AlpariMonth < Month())
      {
      offset = offset - 24 ;
      }
      
      if (AlpariMonth > Month())
      {
      offset = offset + 24 ;
      }
    
  GlobalVariableSet("lastSuccessUpdateTime", TimeCurrent());
  GlobalVariableSet("lastalparioffset", offset);
  
  }
 
  // set update to false, each EA only has one opportunity to update
  // when it gets chosen
  update = false ;
  
 }

}

// this function's purpose is to check whether the current
// time series array from the MT4 platform is actually in sync.
// when a candle is old (more than 60 second) the timestamp of the last
// candle is saved and then compared with the new one upon a change in Hour()
// if Time[2] mismatches then we know there is a problem
void detectTimeArrayMismatch()
{

   int currentBarOpenTime = iTime( Symbol(), Period(), 0) ;
   
   int hourAfterSaved = NO_TIME_VALUE_SAVED ;

   if (TimeCurrent()-currentBarOpenTime > 60 && TimeCurrent()-currentBarOpenTime < 3540)
   {
   
   g_savedTimeArrayValue = Time[1] ;
   g_savedHourForComparison = Hour() ;
   
   }
   
   if ( g_savedHourForComparison != NO_TIME_VALUE_SAVED )
   {
   hourAfterSaved = g_savedHourForComparison + 1 ;
   
   if (hourAfterSaved  >= 24)
   hourAfterSaved  -= 24 ;
   
   }
   
   
   if ( (  ( Hour() == hourAfterSaved                  )  && 
           ( Time[2] != g_savedTimeArrayValue          )) ||
           ( TimeCurrent()-currentBarOpenTime > 3600   ) 
      )
   {
   g_lastStatusID = STATUS_TIMEARRAY_MISMATCH  ;
   }

}

void updateResetBalanceTime()
{

int    fileHandle;
double loadedInitialBalance ;
int    loadedInitialTime ;

g_initBalBackupFile = StringConcatenate("BB_", AccountNumber(), "_", InstanceID, ".txt") ;

g_balanceTimeLabel = StringConcatenate("startdate", InstanceID) ;
g_initialBalanceLabel = StringConcatenate("startbalance",InstanceID) ;


  fileHandle = FileOpen( g_initBalBackupFile,FILE_CSV|FILE_READ, ',' );
  
  if( fileHandle > 0 )
    {
     
     loadedInitialBalance = FileReadNumber(fileHandle);
     loadedInitialTime    = FileReadNumber(fileHandle);
     
     FileClose(fileHandle); 
     
     GlobalVariableSet(g_balanceTimeLabel    , loadedInitialTime    );
     GlobalVariableSet(g_initialBalanceLabel , loadedInitialBalance );
     
    } else {

         if( !GlobalVariableCheck(g_balanceTimeLabel) && !UseGlobalBalance )
            {

            GlobalVariableSet(g_balanceTimeLabel    ,    TimeCurrent());
            GlobalVariableSet(g_initialBalanceLabel , AccountBalance());

            }

           }
           
}

void getInstanceBalanceInformation()
{

g_instanceStartTime = GlobalVariableGet(g_balanceTimeLabel);
g_initialBalance = GlobalVariableGet(g_initialBalanceLabel);

//reassignment to ensure that Global Variables are not deleted due to
// inactivity
GlobalVariableSet(g_balanceTimeLabel, g_instanceStartTime);
GlobalVariableSet(g_initialBalanceLabel, g_initialBalance);

if ( ( MathAbs(g_balanceBackupTime - TimeCurrent()) > SECONDS_IN_DAY ) &&
     ( g_initialBalance > EPSILON                             ) &&
     ( g_instanceStartTime > EPSILON                          )     
   )
   {

   backupBalanceInfo() ;
   
   }

}

void backupBalanceInfo() 
{

int fileHandle;

fileHandle = FileOpen( g_initBalBackupFile,FILE_CSV|FILE_WRITE, ',' );
  
  if( fileHandle > 0 )
    {
     
     FileWrite(fileHandle, g_initialBalance, g_instanceStartTime);
     
     FileClose(fileHandle); 
     
     g_balanceBackupTime = TimeCurrent() ;
     
    } 

}

void checkBalanceResetTime()
{

g_instanceStartTime = GlobalVariableGet(g_balanceTimeLabel);

if (MathAbs(g_instanceStartTime - TimeCurrent()) > ResetPeriod*SECONDS_IN_DAY)

{

GlobalVariableSet(g_balanceTimeLabel, TimeCurrent());

g_initialBalance = AccountBalance() ;

GlobalVariableSet(g_initialBalanceLabel, g_initialBalance);

}


}


// Declares the InstanceID global variable,
// marking it with a unique random number
void generateInstanceID()
{
	int count;

	// The following if statement creates or increases
	// the "count" variable which is then used as a part of the "seed"
	// for the random number generator, this count ensures that 
	// random numbers remain unique and duplicates identified even if the instances are started
	// at exactly the same time on the same instrument.
	if( GlobalVariableCheck( "rdn_gen_count" ) )
	{
		count = GlobalVariableGet( "rdn_gen_count" );
		if( count < 100 )
			GlobalVariableSet( "rdn_gen_count", count + 1 );

		if( count >= 100 )
			GlobalVariableSet( "rdn_gen_count", 1 );
	}
	else
	{
		GlobalVariableSet( "rdn_gen_count", 1 );
		count = 1 ;
	}

	// Random number generator seed, current time, Ask and counter are used
	MathSrand( TimeLocal() * Ask * count );
		
	// String for global variable
	string instanceIDTag = DoubleToStr( InstanceID, 0 );

	// generate the random number and place it within the tag
	GlobalVariableSet( instanceIDTag, MathRand() );

	// Assigns the random number to this instance specific global variable
	// this value will be used from now on to check if there are duplicate
	// Instance IDs
	g_generatedInstanceID = GlobalVariableGet( instanceIDTag );
}

// Verifies that the tag, generated during initialization, has changed.
// Generates a "duplicate ID" error if this is the case.
void verifyInstanceIDUniquiness()                          
{
	// Retrieve instance ID as string to search for global variable
	string instanceIDTag = DoubleToStr( InstanceID, 0 );

	// Assign the value of the global variable
	double retrievedInstanceID = GlobalVariableGet( instanceIDTag );
	
	// Check whether the tag has changed from what it had originally been assigned to
	if( MathAbs( g_generatedInstanceID - retrievedInstanceID ) >= EPSILON )
	{
		// Gnerates an error if a duplicate instance is found
		g_lastStatusID = STATUS_DUPLICATE_ID;
		return;
	}

	// Reassigning global variable, this does not change the variable's value,
	// however it needs to be done since unmodified variables are deleted
	// after 4 weeks. This "regeneration" avoids deletion.
	GlobalVariableSet( instanceIDTag, retrievedInstanceID );
}


void calculateBoxSize() // this function calculates the box size 
{
  
   g_boxhigh =High[iHighest(NULL, 0, MODE_HIGH , Entry_Hour_Breakout , 1)] ; //calculation of box's high
   g_boxlow =Low[iLowest(NULL, 0, MODE_LOW , Entry_Hour_Breakout, 1)] ; //calculation of box's low
   g_BoxSize = g_boxhigh-g_boxlow ; // calculates the box's Size which is the difference between the high and low of the box
   g_adaptiveValue = g_BoxSize ;
                 
}

double calculateExpirationTime()
{
  
   double expiration_time = Cancel_hour*3600 + TimeCurrent() ; // calculating expiration time to input on pending orders
          
          return(expiration_time) ;
}

// this function saves a screenshot
// whenever a trade is taken using the tradeticket
// instance ID and account number for the image's filename 

void saveWindowScreenshot(int tradeTicket)
{

   string screenShotName = StringConcatenate(AccountNumber(), "_", InstanceID, "_", tradeTicket, ".gif") ;

   if(!WindowScreenShot(screenShotName,1024,768))
   {
   int errorCode = GetLastError() ;
   Print("Saving of screenshot failed. Error info: ", errorCode , " description: ", ErrorDescription( errorCode ) );
   }

}

void openBuyOrder()
{

    if( ! IsTradeAllowed() )
	{
		g_lastStatusID = STATUS_TRADING_NOT_ALLOWED;
		Print( "openBuyOrder: Trading is not allowed." );
		return;
	}
	
	if( IsTradeContextBusy() )
	{
	   g_lastStatusID = STATUS_TRADE_CONTEXT_BUSY;
		Print( "openBuyOrder: trade context is busy." );
		return;
	}
	
	checkMinTradeSize() ;
	
	if( STATUS_BELOW_MIN_LOT_SIZE == g_lastStatusID )
	{
	   
		Print( "openBuyOrder: lot size below minimum broker size on entry signal." );
		return;
	}

	double tradeOpenPrice = NormalizeDouble( Ask, g_brokerDigits );

	// ECN brokers support pending orders by default so TP and SL are entered directly

    int tradeTicket ;
  
    double  tradeEntryPrice ,
            stopLossPrice   ,
            takeProfitPrice ,
            tradeexpirationtime  ; 

    if(preferred_order == PREFERED_ORDER_TYPE_STOP){ // use this if regular sell stops are being placed (this is done when you want to trade and NOT fade
	                     // the breakout.
	                     
            tradeEntryPrice = calculateEntryPrice( OP_BUYSTOP, g_BoxSize );
            stopLossPrice   = calculateStopLossPrice( OP_BUYSTOP, tradeEntryPrice );
            takeProfitPrice = calculateTakeProfitPrice( OP_BUYSTOP, tradeEntryPrice );
            tradeexpirationtime = calculateExpirationTime() ; 
			 
            tradeTicket = OrderSend(
									g_symbol,
									OP_BUYSTOP,
									g_tradeSize,
									tradeEntryPrice,
									g_adjustedSlippage,
									stopLossPrice,
									takeProfitPrice,
									TradeDescription,
									InstanceID,
									tradeexpirationtime,
									BUY_COLOR
							  		   );
							  		   
            if( -1 == tradeTicket )
            {
                    logOrderSendInfo(
                                    "openBuyOrder-OrderSend: ",
                                    g_tradeSize,
                                    tradeEntryPrice,
                                    g_adjustedSlippage,
                                    stopLossPrice,
                                    takeProfitPrice,
                                    GetLastError()
                                    );
                    return;
            }
    }
	                 
    if(preferred_order == PREFERED_ORDER_TYPE_LIMIT){ // use this if you want to fade breakouts, placing limits instead of stops
 
            tradeEntryPrice = calculateEntryPrice( OP_BUYLIMIT, g_BoxSize );
            stopLossPrice   = calculateStopLossPrice( OP_BUYLIMIT, tradeEntryPrice );
            takeProfitPrice = calculateTakeProfitPrice( OP_BUYLIMIT, tradeEntryPrice );
            tradeexpirationtime = calculateExpirationTime() ;
			 
      if ((ObjectFind(Linex1)<0) || (ObjectFind(Linex2)<0))
            tradeTicket = OrderSend(
									g_symbol,
									OP_BUYLIMIT,
									0.01,
									tradeEntryPrice,
									g_adjustedSlippage,
									stopLossPrice,
									takeProfitPrice,
									TradeDescription,
									InstanceID,
									tradeexpirationtime,
									BUY_COLOR
							  		   );
//            if( -1 == tradeTicket )
        //--- Assert Added PlusLinex.mqh
            string desc="BUY_LIMIT: Lot="+DoubleToStr(g_tradeSize,2)+" Price="+DoubleToStr(tradeEntryPrice,5)+" SL="+DoubleToStr(stopLossPrice,5)+" TP="+DoubleToStr(takeProfitPrice,5)+" Expiry="+tradeexpirationtime;
            if (ObjectFind(Linex2)<0)
            {
                //--- No previous object, so create a new object.
                ObjectCreate(Linex2,OBJ_TREND,0,iTime(NULL,0,50),tradeEntryPrice,iTime(NULL,0,0),tradeEntryPrice);
                ObjectSetText(Linex2,desc);
            }
            
            if (ObjectFind(Linex2)<0)
            {
                    logOrderSendInfo(
                                    "openBuyOrder-OrderSend: ",
                                    g_tradeSize,
                                    tradeEntryPrice,
                                    g_adjustedSlippage,
                                    takeProfitPrice,
                                    stopLossPrice,
                                    GetLastError()
                                    );
                    return;
            }
    }
	
	// if the recordAdaptiveMax value is set to true
	// then execute the saveAdaptiveCriteria function
	// which saves the value to a Global variable
	// if it is the highest known
      if (recordMaxAdaptive)
	   saveAdaptiveCriteria() ;
	
	// if the external variable to save screenshots is toggled
	// then save a pic of the current chart window   
	   if (saveTradeScreenshots)
	   saveWindowScreenshot(tradeTicket);

}

void openSellOrder()
{

		if( ! IsTradeAllowed() )
	{
		g_lastStatusID = STATUS_TRADING_NOT_ALLOWED;
		Print( "openSellOrder: Trading is not allowed." );
		return;
	}
	
	if( IsTradeContextBusy() )
	{
	   g_lastStatusID = STATUS_TRADE_CONTEXT_BUSY;
		Print( "openSellOrder: trade context is busy." );
		return;
	}
	
	checkMinTradeSize() ;
	
	if( STATUS_BELOW_MIN_LOT_SIZE == g_lastStatusID )
	{
	   
		Print( "openSellOrder: lot size below minimum broker size on entry signal." );
		return;
	}

	// Support ECN brokerage

	int tradeTicket ;

	
		double tradeEntryPrice , // assigns the entry price according to the buffer
		       stopLossPrice   , // assigns the SL
		    	 takeProfitPrice , // assigns the TP
		    	 tradeexpirationtime  ;  // assigns the expiration date time of the pending order placed
		    	 
			 
	// ECN brokers support pending orders by default so TP and SL are entered directly

	if(preferred_order == PREFERED_ORDER_TYPE_STOP){ // use this if regular sell stops are being placed (this is done when you want to trade and NOT fade
	                     // the breakout.

             tradeEntryPrice = calculateEntryPrice( OP_SELLSTOP, g_BoxSize ) ;
		       stopLossPrice   = calculateStopLossPrice( OP_SELLSTOP, tradeEntryPrice ) ;
		    	 takeProfitPrice = calculateTakeProfitPrice( OP_SELLSTOP, tradeEntryPrice ) ;
		    	 tradeexpirationtime = calculateExpirationTime() ;
			 
	tradeTicket = OrderSend(
									g_symbol,
									OP_SELLSTOP,
									g_tradeSize,
									tradeEntryPrice,
									g_adjustedSlippage,
									stopLossPrice,
									takeProfitPrice,
									TradeDescription,
									InstanceID,
									tradeexpirationtime,
									SELL_COLOR
							  		   );
	if( -1 == tradeTicket )
	{
		logOrderSendInfo(
						"openSellOrder-OrderSend: ",
						g_tradeSize,
						tradeEntryPrice,
						g_adjustedSlippage,
						stopLossPrice,
						takeProfitPrice,
						GetLastError()
							 );
		return;
	}
	                     }
	                     
	if(preferred_order == PREFERED_ORDER_TYPE_LIMIT){ // use this if you want to fade breakouts, placing limits instead of stops
	
	          tradeEntryPrice = calculateEntryPrice( OP_SELLLIMIT, g_BoxSize ) ;
		       stopLossPrice   = calculateStopLossPrice( OP_SELLLIMIT, tradeEntryPrice ) ;
		    	 takeProfitPrice = calculateTakeProfitPrice( OP_SELLLIMIT, tradeEntryPrice ) ;
		    	 tradeexpirationtime = calculateExpirationTime() ;

			 
      if ((ObjectFind(Linex1)<0) || (ObjectFind(Linex2)<0))
	           tradeTicket = OrderSend(
									g_symbol,
									OP_SELLLIMIT,
									0.01,
									tradeEntryPrice,
									g_adjustedSlippage,
									stopLossPrice,
									takeProfitPrice,
									TradeDescription,
									InstanceID,
									tradeexpirationtime,
									SELL_COLOR
							  		   );
//	if( -1 == tradeTicket )

        //--- Assert Added PlusLinex.mqh
            string desc="SELL_LIMIT: Lot="+DoubleToStr(g_tradeSize,2)+" Price="+DoubleToStr(tradeEntryPrice,5)+" SL="+DoubleToStr(stopLossPrice,5)+" TP="+DoubleToStr(takeProfitPrice,5)+" Expiry="+tradeexpirationtime;
            if (ObjectFind(Linex1)<0)
            {
                //--- No previous object, so create a new object.
                ObjectCreate(Linex1,OBJ_TREND,0,iTime(NULL,0,50),tradeEntryPrice,iTime(NULL,0,0),tradeEntryPrice);
                ObjectSetText(Linex1,desc);
            }
            
            if (ObjectFind(Linex1)<0)
	         {
		          logOrderSendInfo(
						"openSellOrder-OrderSend: ",
						g_tradeSize,
						tradeEntryPrice,
						g_adjustedSlippage,
						stopLossPrice,
						takeProfitPrice,
						GetLastError()
							 );
		          return;
	         }
	                     }

   // if the recordAdaptiveMax value is set to true
	// then execute the saveAdaptiveCriteria function
	// which saves the value to a Global variable
	// if it is the highest known
      if (recordMaxAdaptive)
	   saveAdaptiveCriteria() ;
	   
	// if the external variable to save screenshots is toggled
	// then save a pic of the current chart window 
	  	if (saveTradeScreenshots)
	   saveWindowScreenshot(tradeTicket);

}


int queryOrdersCount( int orderType ) 
{
// The query function is used for counting particular sets of orders
// for different purposes. It allows us to calculate amount of open longs,
// shorts or pending orders. It also allows to retrieve the amount of all
// the orders, opened by the expert by calling it with the QUERY_ALL argument.
	int query = QUERY_NONE,
		 ordersCount = 0;

	switch( orderType ) {
	case OP_BUY:
		query = QUERY_LONGS_COUNT;
	break;
	case OP_SELL:
		query = QUERY_SHORTS_COUNT;
	break;
	case OP_BUYSTOP:
		query = QUERY_BUY_STOP_COUNT;
	break;
	case OP_SELLSTOP:
		query = QUERY_SELL_STOP_COUNT;
	break;
	case OP_SELLLIMIT:
		query = QUERY_SELL_LIMIT_COUNT;
	break;
	case OP_BUYLIMIT:
		query = QUERY_BUY_LIMIT_COUNT;
	break;
	case QUERY_ALL:
		// A case to count all orders
		query = QUERY_ALL ;
	break;
							  } // switch( orderType )

	int total = OrdersTotal() ;
	for ( int i = 0 ; i < total+1; i++) 
	{
		OrderSelect( i, SELECT_BY_POS, MODE_TRADES );
		
		if( (        OrderType() ==  OP_SELL   ) &&
			 ( OrderMagicNumber() == InstanceID ) &&
			 ( ( QUERY_SHORTS_COUNT == query ) || ( query == QUERY_ALL ) )
		  )
		{
			ordersCount++;
		}

		if( (       OrderType() ==   OP_BUY   ) &&
			 ( OrderMagicNumber()== InstanceID ) &&
			 ( ( query == QUERY_LONGS_COUNT ) || ( query == QUERY_ALL ) )	
		  )
		{
			ordersCount++;
		}

		if( (       OrderType() == OP_SELLSTOP ) &&
			 ( OrderMagicNumber()==  InstanceID ) &&
			 ( ( query == QUERY_SELL_STOP_COUNT ) || ( query == QUERY_ALL ) )	
		  )
		{
			ordersCount++;
		}

		if( (       OrderType() == OP_BUYSTOP ) &&
			 ( OrderMagicNumber()== InstanceID ) &&
			 ( ( query == QUERY_BUY_STOP_COUNT ) || ( query == QUERY_ALL ) )	
		  )
		{
			ordersCount++;
		}

		if( (       OrderType() == OP_SELLLIMIT ) &&
			 ( OrderMagicNumber()== InstanceID   ) &&
			 ( ( query == QUERY_SELL_LIMIT_COUNT ) || ( query == QUERY_ALL ) )	
		  )
		{
			ordersCount++;
		}

		if( (       OrderType()  == OP_BUYLIMIT ) &&
			 ( OrderMagicNumber() == InstanceID  ) &&
			 ( ( query == QUERY_BUY_LIMIT_COUNT ) || ( query == QUERY_ALL ) )	
		  )
		{
      	ordersCount++;
		}
	}

	return(ordersCount);
}



int check_last_trade_same_bar()
{
	int total = OrdersTotal() ;
	int do_not_allow = 0 ;

for ( int i = 0 ; i < total+1; i++) 
      {
      OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
          if((OrderType() == OP_BUY || OrderType() == OP_SELL) && OrderMagicNumber()== InstanceID && MathAbs(TimeCurrent()-OrderOpenTime()) < 3600)	
            do_not_allow = 1 ;
      }
      
      return(do_not_allow) ;
}

int checkTradingSignal()
{
	int currentState = checkBoxStatus(),
		 signal = SIGNAL_NONE;

	switch( currentState ) {
	case SITUATION_NONE:
	break;
	case CREATE_UPPER_BOX_SECTION :
		signal = SIGNAL_CREATE_PEND_ORDER_BUY;
	break;
	case CREATE_LOWER_BOX_SECTION:
		signal = SIGNAL_CREATE_PEND_ORDER_SELL;
	break;
							} // switch( pattern )
	return (signal);
}

int checkBoxStatus()
{

	int situationID = box_formation_conditions();
	if( SITUATION_NONE != situationID )
		return (situationID);
		
	situationID = IsBoxActive();
	if( SITUATION_NONE != situationID )
		return (situationID);

	return (SITUATION_NONE);		
}


int box_formation_conditions() // checks if it is time to place pending orders
{

int count_pending_longs = queryOrdersCount(OP_BUYSTOP)+queryOrdersCount(OP_BUYLIMIT), // calculate pending buy orders
    count_pending_shorts = queryOrdersCount(OP_SELLSTOP)+queryOrdersCount(OP_SELLLIMIT), // calculate pending buy orders
    count_all_active = queryOrdersCount(OP_BUY)+queryOrdersCount(OP_SELL); // calculates active orders which are relevant when FIFO = true.
       
    int check_last_trade_same_bar = check_last_trade_same_bar() ;

	int situation = SITUATION_NONE;
	    g_lastDetectedSituationID = SITUATION_NONE;
	
	// the following "if" statement controls the timing for the placing of pending orders for the upper box region
		
	if( (Hour() == Entry_Hour_Set_Used)  && // given hour that needs to be reached
	    (g_BoxSize < g_ATR*max_box_size_ATR/100) &&  // maximum ATR multiplier measurement of the box size
       (g_BoxSize > g_ATR*min_box_size_ATR/100) && // minimum ATR multiplier measurement of the box size
       (g_BoxSize >  (MarketInfo(Symbol(), MODE_STOPLEVEL) + MarketInfo(Symbol(), MODE_SPREAD))*Point ) && // make sure the box size is larger than the minimal SL
       (check_last_trade_same_bar == 0) && // check that no trades were opened on this bar
       (count_pending_longs == 0 && NFACompliant == false) || // if FIFO = false the only requirement is that no pending orders are set
       (count_pending_longs == 0 && count_all_active == 0 && NFACompliant == true) // if FIFO = true we also need active orders to be 0  
	  )
	{
		if( SEVERITY_INFO == g_severityStatus )
			g_lastDetectedSituationID = CREATE_UPPER_BOX_SECTION ;

		situation = CREATE_UPPER_BOX_SECTION ;
	}
	
	// the following "if" statement controls the timing for the placing of pending orders for the lower box region
		
	if( (Hour() == Entry_Hour_Set_Used)  && // given hour that needs to be reached
	    (g_BoxSize < g_ATR*max_box_size_ATR/100) &&  // maximum ATR multiplier measurement of the box size
       (g_BoxSize > g_ATR*min_box_size_ATR/100) && // minimum ATR multiplier measurement of the box size
       (g_BoxSize >  (MarketInfo(Symbol(), MODE_STOPLEVEL) + MarketInfo(Symbol(), MODE_SPREAD))*Point ) && // make sure the box size is larger than the minimal SL
       (check_last_trade_same_bar == 0) && // check that no trades were opened on this bar
       (count_pending_shorts == 0 && NFACompliant == false) || // if FIFO = false the only requirement is that no pending orders are set
       (count_pending_shorts == 0 && count_all_active == 0 && NFACompliant == true) // if FIFO = true we also need active orders to be 0  
	  )
	{
		if( SEVERITY_INFO == g_severityStatus )
			g_lastDetectedSituationID = CREATE_LOWER_BOX_SECTION ;

		situation = CREATE_LOWER_BOX_SECTION ;
	}

	return (situation);
	
}
	


int IsBoxActive() // this checks if the box is active, if it is then a message is displayed indicating so. 
                      // this function does not have any further functionality although it could have it in the future
{

int count_pending = queryOrdersCount(OP_BUYSTOP)+queryOrdersCount(OP_SELLSTOP)
    + queryOrdersCount(OP_BUYLIMIT)+queryOrdersCount(OP_SELLLIMIT); // calculates pending orders
    
    int situation = SITUATION_NONE ;
	    g_lastDetectedSituationID = SITUATION_NONE;
	
	if( count_pending > 0 )
	{
		if( SEVERITY_INFO == g_severityStatus )
			g_lastDetectedSituationID = SITUATION_BOX_ACTIVE;

		situation = SITUATION_BOX_ACTIVE;
	}

	return (situation);
}

void calculateATR()
{
	// Use the current ATR value, taking
	// into account sunday candle existence.
	if( g_sundayCandleExists )
	{
		g_ATR = iATR_WithoutSunday(g_symbol, PERIOD_D1, ATRAveragingPeriod, 0);
	}
	
   if( !g_sundayCandleExists )
   {
	g_ATR = iATR( g_symbol, PERIOD_D1, ATRAveragingPeriod, 0 );
	}
	
	
	if( MathAbs( g_ATR ) < EPSILON )
	{
		g_lastStatusID = STATUS_DIVIDE_BY_ZERO;
		return;
	}

	// The ATR is 0.0001 when initialization failure occurs.
	// See the EA setup video (26.09.10) for more details.
	if( ( MathAbs( g_ATR ) - 0.0001 ) < EPSILON )
	{
		g_lastStatusID = STATUS_ATR_INIT_PROBLEM;
		return;
	}
}

void adjustSlippage() 
{
   g_adjustedSlippage = Slippage;
   
   // Support 5 digit brokers
   if( ( 3 == g_brokerDigits ) ||
       ( 5 == g_brokerDigits )
     )
   {
      g_adjustedSlippage *= 10;
   }

}


void calculateContractSize()
{

g_contractSize = MarketInfo(Symbol(),  MODE_LOTSIZE);	//contract size
	
								 
}

void calculateTradeSize()
{

	if( OPERATIONAL_MODE_TRADING == OperationalMode && UseGlobalBalance == false)
	{
		g_tradeSize = ( AccountRiskUnit * 0.01 * g_instanceBalance ) / ( g_contractSize * g_BoxSize );
   }
	else if( OPERATIONAL_MODE_TESTING == OperationalMode || UseGlobalBalance == true)
	{
		g_tradeSize = ( AccountRiskUnit * 0.01 * AccountBalance() ) / ( g_contractSize * g_BoxSize );
	}
	
	if(isInstrumentJPY())
	{
		g_tradeSize *= 100;
	}

	if( g_tradeSize > g_maxTradeSize )
		g_tradeSize = g_maxTradeSize;
	
	g_tradeSize = roundDouble(g_tradeSize);
	
}

void checkMinTradeSize()
{

	if (g_tradeSize < g_minTradeSize)
	{
	g_lastStatusID = STATUS_BELOW_MIN_LOT_SIZE ; 
	}

}

double calculateEntryPrice( int orderType, double BoxSizeerential )

 // entry price calculation according to the buffer multiple
 
{
	double price = 0;
	
	switch( orderType ) {
	case OP_BUYSTOP:
		price = High[iHighest(NULL, 0, MODE_HIGH , Entry_Hour_Breakout , 1)] + Buffer_Box_Multiple*g_BoxSize;
	break;
	case OP_SELLSTOP:
		price = Low[iLowest(NULL, 0, MODE_LOW , Entry_Hour_Breakout, 1)] -  Buffer_Box_Multiple*g_BoxSize ;
	break;
	case OP_SELLLIMIT:
		price = High[iHighest(NULL, 0, MODE_HIGH , Entry_Hour_Breakout , 1)] + Buffer_Box_Multiple*g_BoxSize;
	break;
	case OP_BUYLIMIT:
		price = Low[iLowest(NULL, 0, MODE_LOW , Entry_Hour_Breakout, 1)] -  Buffer_Box_Multiple*g_BoxSize ;
	break;
							  } // switch( orderType )

	price = NormalizeDouble( price, g_brokerDigits );

	return (price);
}

double calculateStopLossPrice( int orderType, double EntryPrice )

 // stoploss set at the box high/low modified by the MOVE_SL_BOX multiplier variable if necessary if reverse = false
 // when reverse = true the entry price plus a given box multiplier is used.
{
	double price = 0;
	
	switch( orderType ) {
	case OP_BUYSTOP:
		price = Low[iLowest(NULL, 0, MODE_LOW , Entry_Hour_Breakout, 1)]-Move_SL_Box_Multiple*g_BoxSize;
	break;
	case OP_SELLSTOP:
		price = High[iHighest(NULL, 0, MODE_HIGH , Entry_Hour_Breakout , 1)]+Move_SL_Box_Multiple*g_BoxSize;
	break;
	case OP_SELLLIMIT:
		price = EntryPrice+g_BoxSize*Profit_Box_Multiple ;
	break;
	case OP_BUYLIMIT:
		price = EntryPrice-g_BoxSize*Profit_Box_Multiple ;
	break;
	
							  } // switch( orderType )

	price = NormalizeDouble( price, g_brokerDigits );

	return (price);
}

double calculateTakeProfitPrice( int orderType, double EntryPrice ) // Take profit is set as a box multiplier or as the box high/low when using reverse = true
{
	double price = 0.0;

	switch( orderType ) {
	case OP_BUYSTOP:
		price = EntryPrice+g_BoxSize*Profit_Box_Multiple ;
	break;
	case OP_SELLSTOP:
		price = EntryPrice-g_BoxSize*Profit_Box_Multiple ;
	break;
	case OP_SELLLIMIT:
		price = Low[iLowest(NULL, 0, MODE_LOW , Entry_Hour_Breakout, 1)]-Move_SL_Box_Multiple*g_BoxSize;
	break;
	case OP_BUYLIMIT:
		price = High[iHighest(NULL, 0, MODE_HIGH , Entry_Hour_Breakout , 1)]+Move_SL_Box_Multiple*g_BoxSize;
	break;
							  } // switch( orderType )

	price = NormalizeDouble( price, g_brokerDigits );

	return (price);
}


bool isInstrumentJPY()
{
	int found = StringFind( Symbol(), "JPY", 0 );
	if( found == -1 )
		return (false);

	return (true);
}

double roundDouble( double value  )
{
	double roundedValue = 0.0;
	int roundingDigits = 0;

	double minimal_lot_step = MarketInfo(Symbol(), MODE_LOTSTEP) ;
	
	switch( minimal_lot_step ) {
	case 0.01:
		roundedValue = NormalizeDouble( value, 2 );
	break;
	case 0.05:
		roundedValue = NormalizeDouble( MathFloor(value * 20 + 0.5) / 20, 2 );
	break;
	case 0.1:
		roundedValue = NormalizeDouble( value, 1 );
	break;
									  } // switch( minimum lot size )
									 									  	
	return (roundedValue);
}

void calculateInstanceBalance()
{

   g_instanceBalance = g_initialBalance;
   g_instancePL_UI = 0 ;
	
	int closedOrdersCount =  OrdersHistoryTotal();
	
	for( int i = 0; i < closedOrdersCount; i++ )
	{
		OrderSelect( i, SELECT_BY_POS, MODE_HISTORY );
	
		if( (OrderMagicNumber() == InstanceID || OrderType() == OP_DEPOSITORWITHDRAWAL) && OrderOpenTime() > g_instanceStartTime)	
		{
			g_instanceBalance += OrderProfit() + OrderSwap() ;
		}
		
		if( OrderMagicNumber() == InstanceID )	
		{
			g_instancePL_UI += OrderProfit() + OrderSwap() ;
		}
   }
   
}



double calculateStopLossInPIPS() // this function is used to calculate SL  value for open orders 
{

int total = OrdersTotal() ;

double StopLossValue = 0 ;

for ( int i = 0 ; i < total ; i++) // we cycle through all orders to get the value, since all orders are symmetrical
                                     // it doesn't matter which one we get
      {
         OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
         if(OrderMagicNumber()== InstanceID )
         {
            int multi = 10000;
            if(isInstrumentJPY())
               multi = 100;
               
            StopLossValue = MathAbs(OrderOpenPrice()-OrderStopLoss())*multi ; 
            break;
         }
      }

return (StopLossValue) ;
}



double calculateTakeProfitInPIPS() // this function is used to calculate  TP value for open orders 
{

int total = OrdersTotal() ;
double TakeProfitValue = 0 ;

for ( int i = 0 ; i < total ; i++) // we cycle through all orders to get the value, since all orders are symmetrical
                                     // it doesn't matter which one we get
      {
         OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
         if(OrderMagicNumber()== InstanceID )	
         {
            int multi = 10000;
            if( isInstrumentJPY())
               multi = 100;
               
            TakeProfitValue = MathAbs(OrderOpenPrice()-OrderTakeProfit())*multi ;
            break;
         }
      }



return (TakeProfitValue) ;

}


double calculateActiveTradesSize() // this function is used to calculate  Lot Size value for open orders 
{

int total = OrdersTotal() ;
double LotSize = 0 ;


for ( int i = 0 ; i < total ; i++) // we cycle through all orders to get the value, since all orders are symmetrical
                                     // it doesn't matter which one we get
      {
         OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
         if(OrderMagicNumber()== InstanceID )
         {	
            LotSize = OrderLots() ;
            break;
         }
      }


return (LotSize) ;

}

double iATR_WithoutSunday(string symbol, int timeframe, int period, int shift) {

   double TempBuffer[];
   int i = 0;
   int skip = 0;
   double skipHigh = 0;
   double skipLow = 1000;

   if (iBars(symbol, timeframe) <= period + shift)
      return(0);
   
   // use Sunday skipping on daily timeframes only
   if (timeframe != PERIOD_D1)
      return(iATR(symbol, timeframe, period, shift));
      
   ArrayResize(TempBuffer, period);
      while (i < period) {
         if (TimeDayOfWeek(iTime(symbol, timeframe, i + shift + skip)) == 1) {      // skip Sundays
         skipHigh = iHigh(symbol, timeframe, i + shift + skip);
         skipLow = iLow(symbol, timeframe, i + shift + skip);
            skip++;
         }
         else {
            double high = MathMax(iHigh(symbol, timeframe, i + shift + skip), skipHigh);
            double low = MathMin(iLow(symbol, timeframe, i + shift + skip), skipLow);

            if((i + shift + skip) == iBars(symbol, timeframe) - 1) {
               TempBuffer[i] = high - low;
               break;
               }
            else {
               double prevclose = iClose(symbol, timeframe, i + shift + 1 + skip);
               TempBuffer[i] = MathMax(high, prevclose) - MathMin(low, prevclose);
              }
         skipHigh = 0;
         skipLow = 1000;
         i++;
         }
        }

   return(iMAOnArray(TempBuffer, period, period, 0, MODE_SMA, 0));
}

void detectSundayCandles()
{
	g_sundayCandleExists = false;
	for( int i = 0 ; i < 10; i++ )
	{
		if( TimeDayOfWeek( iTime( Symbol(), PERIOD_D1, i ) ) == 0 )
		{
			g_sundayCandleExists = true;
			return;
		}
	}
}

void LoadAlpariOffset()
{
  int handle;
  string str;
  string str2;
  string str3;
  double lastUpdateTime  ;
  
  Entry_Hour_Set_Used = 0 ;
	
  Entry_Hour_Set_Used = Entry_Hour_Set;
  
  string offsetfailcount = StringConcatenate(InstanceID, "failedcount") ;
  
  string lastalparioffset = "lastalparioffset" ;
  
  lastUpdateTime = GlobalVariableGet("lastSuccessUpdateTime");
 
    
   if( GlobalVariableCheck(lastalparioffset) )
   {
   
   g_offset = GlobalVariableGet(lastalparioffset) ;
   
   Entry_Hour_Set_Used -=  g_offset ;
 
   if(Entry_Hour_Set_Used >= 24)
   Entry_Hour_Set_Used -=  24 ;
 
   if(Entry_Hour_Set_Used < 0)
   Entry_Hour_Set_Used +=  24 ;
   
   g_offsetstatus = NEW_OFFSET ;
   
   
   }
   
     
   if( !GlobalVariableCheck(lastalparioffset) ){  
   g_offsetstatus = FAILED_OFFSET ;
   g_lastStatusID = STATUS_TIME_DETECTION_FAILED;
   return;
         }   
         
   if(MathAbs(lastUpdateTime - TimeCurrent()) > SECONDS_IN_DAY)
   g_offsetstatus = NOUPDATE_OFFSET ;
   
   
   return;
   
    }
   

int initUI()
{
	// Displayed in the main chart window
	ObjectCreate( g_objGeneralInfo,  OBJ_LABEL, 0, 0, 0 );
	ObjectCreate( g_objTradeSize,  OBJ_LABEL, 0, 0, 0 );
	ObjectCreate( g_objStopLoss,   OBJ_LABEL, 0, 0, 0 );
	ObjectCreate( g_objTakeProfit, OBJ_LABEL, 0, 0, 0 );
	ObjectCreate( g_objATR,        OBJ_LABEL, 0, 0, 0 );
	ObjectCreate( g_objPL,         OBJ_LABEL, 0, 0, 0 );
	ObjectCreate( g_objStatusPane, OBJ_LABEL, 0, 0, 0 );
	ObjectCreate( g_objautotime, OBJ_LABEL, 0, 0, 0 );
	ObjectCreate( g_objSundayCandlesInfo ,     OBJ_LABEL, 0, 0, 0 );
	
	ObjectCreate( g_objBoxHigh, OBJ_HLINE, 0, 0, 0 );
	ObjectCreate( g_objBoxLow, OBJ_HLINE, 0, 0, 0 );
   ObjectCreate( g_objIsHour, OBJ_TEXT, 0, 0, 0 );
   
   ObjectSet( g_objBoxHigh, OBJPROP_COLOR, HighLineColor );
   ObjectSet( g_objBoxLow, OBJPROP_COLOR, LowLineColor );
   
	// Bind to top left corner
	ObjectSet( g_objGeneralInfo,  OBJPROP_CORNER, 0 );
	ObjectSet( g_objTradeSize,  OBJPROP_CORNER, 0 );
	ObjectSet( g_objStopLoss,   OBJPROP_CORNER, 0 );
	ObjectSet( g_objTakeProfit, OBJPROP_CORNER, 0 );
	ObjectSet( g_objBalance,           OBJPROP_CORNER, 0 );
	ObjectSet( g_objATR,        OBJPROP_CORNER, 0 );
	ObjectSet( g_objPL,         OBJPROP_CORNER, 0 );
	ObjectCreate( g_objBalance,           OBJ_LABEL, 0, 0, 0 );
	ObjectSet( g_objautotime,         OBJPROP_CORNER, 0 );
	ObjectSet( g_objSundayCandlesInfo ,         OBJPROP_CORNER, 0 );
	
	// Bind to bottom left corner
	ObjectSet( g_objStatusPane, OBJPROP_CORNER, 2 );
	
	// Set X offset
	ObjectSet( g_objGeneralInfo,  OBJPROP_XDISTANCE, g_baseXOffset );
	ObjectSet( g_objTradeSize,  OBJPROP_XDISTANCE, g_baseXOffset );
	ObjectSet( g_objStopLoss,   OBJPROP_XDISTANCE, g_baseXOffset );
	ObjectSet( g_objTakeProfit, OBJPROP_XDISTANCE, g_baseXOffset );
	ObjectSet( g_objATR,        OBJPROP_XDISTANCE, g_baseXOffset );
	ObjectSet( g_objBalance,           OBJPROP_XDISTANCE, g_baseXOffset );
	ObjectSet( g_objPL,         OBJPROP_XDISTANCE, g_baseXOffset );
	ObjectSet( g_objStatusPane, OBJPROP_XDISTANCE, g_baseXOffset );
	ObjectSet( g_objSundayCandlesInfo , OBJPROP_XDISTANCE, g_baseXOffset );
	ObjectSet( g_objautotime , OBJPROP_XDISTANCE, g_baseXOffset );

	// Prepare patterns name table
	ArrayResize( g_detectedSituationNames, 3 );
	g_detectedSituationNames[ 0 ] = "Waiting for breakout box definition...";
	g_detectedSituationNames[ 1 ] = "Time to set pending orders for breakout";
	g_detectedSituationNames[ 2 ] = "Box is active :o) Waiting for Breakouts !!";

	ArrayResize( g_statusMessages, 14 );
	g_statusMessages[ STATUS_INVALID_BARS_COUNT ] = "Invalid bars count";
	g_statusMessages[ STATUS_INVALID_TIMEFRAME  ] = "Invalid timeframe, trading suspended";
	g_statusMessages[ STATUS_DIVIDE_BY_ZERO     ] = "ATR not initialized correctly (zero divide)";
	g_statusMessages[ STATUS_ATR_INIT_PROBLEM   ] = "ATR not initialized correctly" ;
	g_statusMessages[ STATUS_TRADE_CONTEXT_BUSY ] = "Trade context busy (server issue)";
   g_statusMessages[ STATUS_TRADING_NOT_ALLOWED] = "Trading not allowed (server issue)";
   g_statusMessages[ STATUS_TIME_DETECTION_FAILED] = "Global Var not set by NTP client yet";
   g_statusMessages[ STATUS_DUPLICATE_ID       ] = "Trading Stopped, Duplicate ID" ;
   g_statusMessages[ STATUS_RUNNING_ON_DEFAULTS] = "Change to defaults, Instance IDs cannot be -1" ;
   g_statusMessages[ STATUS_BELOW_MIN_LOT_SIZE ] = "Lot size is below minimum (capital too low)" ;
   g_statusMessages[ STATUS_DLLS_NOT_ALLOWED       ] = "Please allow DLL usage" ;
   g_statusMessages[ STATUS_LIBS_NOT_ALLOWED ] = "Please allow external lib usage" ;
   g_statusMessages[ STATUS_TIMEARRAY_MISMATCH      ] = "Temporary Candle Time Array Mismatch (broker issue)";
   
	// Set severity status to default
	g_severityStatus = SEVERITY_INFO;

	return (0);
}

void updateUI()
{
	updateStatusUI( false );
	
	string text ;

//--- Assert Added PlusLinex.mqh
   double profit=EasyProfitsMagic(Linex1Magic)+EasyProfitsMagic(Linex2Magic);
   string strtmp=EasyComment(profit,"\n\n\n\n\n\n\n\n\n\n\n\n");
//   strtmp=StringConcatenate(strtmp,"    Lot=",DoubleToStr(EasyLot,2),"\n");
   strtmp=SwissComment(strtmp);
   strtmp=LinexComment(strtmp);
   Comment(strtmp);
	
	// Line and text on screen indicating current box high/low values
	if(Hour() == Entry_Hour_Set_Used && ShowLines)
	{
	ObjectSet( g_objBoxHigh, OBJPROP_WIDTH, LineWidth);
   ObjectSet( g_objBoxLow, OBJPROP_WIDTH, LineWidth);
	ObjectSet( g_objBoxHigh, OBJPROP_STYLE, STYLE_DASH);
   ObjectSet( g_objBoxLow, OBJPROP_STYLE, STYLE_DASH);
   ObjectSet( g_objBoxHigh, OBJPROP_PRICE1, g_boxhigh);
   ObjectSet( g_objBoxLow, OBJPROP_PRICE1, g_boxlow);
  
   text = StringConcatenate("Hour for trade setup. Box size is ", NormalizeDouble(g_BoxSize*100/g_ATR, 1), "% of the ATR");
   
	ObjectSet( g_objIsHour, OBJPROP_TIME1, Time[5]);
   ObjectSet( g_objIsHour, OBJPROP_PRICE1, g_boxlow );
   ObjectSetText( g_objIsHour, text, OnChartInformationFontSize, g_fontName, OnChartInformation );
	
	}
	
	// From here the information displayed on the top left corner starts //
	
	// General Information
	text = "Atipaq made by Daniel Fernandez, Asirikuy (C) 2010" ;
	ObjectSet( g_objGeneralInfo, OBJPROP_YDISTANCE, g_baseYOffset );
   ObjectSetText( g_objGeneralInfo, text, FontSize, g_fontName, InformationColor );
   
   if( queryOrdersCount(QUERY_ALL) > 0 ) // display SL and TP only when there are opened orders
   {
   
   // Trade size
	 text = StringConcatenate( "Trade size: ", g_tradeSize2 );
	ObjectSet( g_objTradeSize, OBJPROP_YDISTANCE, g_baseYOffset + FontSize * g_textDensingFactor );
   ObjectSetText( g_objTradeSize, text, FontSize, g_fontName, InformationColor );
   
	// Stop loss
	text = StringConcatenate( "Stop loss of current orders: ", g_stopLossPIPs );
	ObjectSet( g_objStopLoss, OBJPROP_YDISTANCE, g_baseYOffset + FontSize * g_textDensingFactor * 2);
	ObjectSetText( g_objStopLoss, text, FontSize, g_fontName, InformationColor );

	// Take profit
	text = StringConcatenate( "Take profit of current orders: ", g_takeProfitPIPs );
	ObjectSet( g_objTakeProfit, OBJPROP_YDISTANCE, g_baseYOffset + FontSize * g_textDensingFactor * 3 );
	ObjectSetText( g_objTakeProfit, text, FontSize, g_fontName, InformationColor );
	}
	
	if( queryOrdersCount(QUERY_ALL) == 0 ) // display SL and TP only when there are opened orders
   {
   // Trade size
	text = "Lot Size will be determined by Box Size and Account Balance";
	ObjectSet( g_objTradeSize, OBJPROP_YDISTANCE, g_baseYOffset + FontSize * g_textDensingFactor);
   ObjectSetText( g_objTradeSize, text, FontSize, g_fontName, InformationColor );
	// Stop loss
	text =  "SL will be determined by Box Size " ;
	ObjectSet( g_objStopLoss, OBJPROP_YDISTANCE, g_baseYOffset + FontSize * g_textDensingFactor * 2);
	ObjectSetText( g_objStopLoss, text, FontSize, g_fontName, InformationColor );

	// Take profit
	text =  "TP will be determined by Box Size" ;
	ObjectSet( g_objTakeProfit, OBJPROP_YDISTANCE, g_baseYOffset + FontSize * g_textDensingFactor * 3 );
	ObjectSetText( g_objTakeProfit, text, FontSize, g_fontName, InformationColor );
	}
	
	// ATR
	text = StringConcatenate( "ATR: ", g_ATR );
	ObjectSet( g_objATR, OBJPROP_YDISTANCE, g_baseYOffset + FontSize * g_textDensingFactor * 4 );
	ObjectSetText( g_objATR, text, FontSize, g_fontName, InformationColor );
	
// Profit/loss
	text = StringConcatenate( "Profit up until now is: ", g_instancePL_UI);
	ObjectSet( g_objPL, OBJPROP_YDISTANCE, g_baseYOffset + FontSize * g_textDensingFactor * 5 );
	ObjectSetText( g_objPL, text, FontSize, g_fontName, InformationColor );
	
	if (UseGlobalBalance)
	{
	// internal balance used
	text = StringConcatenate( "Internal Balance Used is: ", AccountBalance());
	ObjectSet( g_objBalance, OBJPROP_YDISTANCE, g_baseYOffset + FontSize * g_textDensingFactor * 6 );
	ObjectSetText( g_objBalance, text, FontSize, g_fontName, InformationColor );
	
	} else {
	
	text = StringConcatenate( "Internal Balance Used is: ", g_instanceBalance);
	ObjectSet( g_objBalance, OBJPROP_YDISTANCE, g_baseYOffset + FontSize * g_textDensingFactor * 6 );
	ObjectSetText( g_objBalance, text, FontSize, g_fontName, InformationColor );
	
	}
	
	// Sunday Candles
	if(g_sundayCandleExists){
	text = "Sunday Candles detected, values adequately corrected :o)";
	ObjectSet( g_objSundayCandlesInfo, OBJPROP_YDISTANCE, g_baseYOffset + FontSize * g_textDensingFactor * 7 );
	ObjectSetText( g_objSundayCandlesInfo, text, FontSize, g_fontName, InformationColor );
	} else {
	text = "No Sunday candles found :o)";
	ObjectSet( g_objSundayCandlesInfo, OBJPROP_YDISTANCE, g_baseYOffset + FontSize * g_textDensingFactor * 7);
	ObjectSetText( g_objSundayCandlesInfo, text, FontSize, g_fontName, InformationColor );
	}
	
	// AutoOffset
	if(UseAutoTimeDetection){
	
	switch(g_offsetstatus){
	
	case FAILED_OFFSET :
	{
	text = "Offset retrieval failed :o(";
	ObjectSet( g_objautotime, OBJPROP_YDISTANCE, g_baseYOffset + FontSize * g_textDensingFactor * 8 );
	ObjectSetText( g_objautotime, text, FontSize, g_fontName, InformationColor );
	} 
	break;
	
	case NOUPDATE_OFFSET:
	{
	text =  "Offset has not updated for at least 1 day";
	ObjectSet( g_objautotime, OBJPROP_YDISTANCE, g_baseYOffset + FontSize * g_textDensingFactor * 8 );
	ObjectSetText( g_objautotime, text, FontSize, g_fontName, InformationColor );
	} 
	break;
	
		case NEW_OFFSET :
	{
	text =  StringConcatenate("Using Auto Offset, corrected Entry_Hour_Set is : ", Entry_Hour_Set_Used);
	ObjectSet( g_objautotime, OBJPROP_YDISTANCE, g_baseYOffset + FontSize * g_textDensingFactor * 8 );
	ObjectSetText( g_objautotime, text, FontSize, g_fontName, InformationColor );
	} 
	break;
	
	}
	
	} else {
	text = "Manual setup required, please compare timestamp with Alpari UK";
	ObjectSet( g_objautotime, OBJPROP_YDISTANCE, g_baseYOffset + FontSize * g_textDensingFactor * 8 );
	ObjectSetText( g_objautotime, text, FontSize, g_fontName, InformationColor );
	}
    
	// Update the window content
	WindowRedraw();
}

void updateStatusUI( bool doRedraw )
{
	// The purpose of setting message to empty string
	// is to clean the screen from irrelevant info.
	string statusMessage = "";
	color clr = CLR_NONE;
	switch( g_severityStatus ) {
	case SEVERITY_INFO:
		clr = InformationColor;
		statusMessage = g_detectedSituationNames[ g_lastDetectedSituationID + 1]; // added one so that the SITUATION_NONE case also triggers a message
	break;
	case SEVERITY_ERROR:
		switch( g_lastStatusID ) {
		case STATUS_INVALID_BARS_COUNT:
		case STATUS_INVALID_TIMEFRAME:
			statusMessage = g_statusMessages[ g_lastStatusID ];
		break;
		case STATUS_LAST_ERROR:
			statusMessage = ErrorDescription( g_lastStatusID );
		break;
		case STATUS_ATR_INIT_PROBLEM  :
			statusMessage = g_statusMessages[ g_lastStatusID ];
			break;
		case STATUS_TIME_DETECTION_FAILED  :
			statusMessage = g_statusMessages[ g_lastStatusID ];
			break;
		case STATUS_DUPLICATE_ID :
			statusMessage = g_statusMessages[ g_lastStatusID ];
			break;
		case STATUS_DIVIDE_BY_ZERO :
			statusMessage = g_statusMessages[ g_lastStatusID ];	
	    	break;
	   case STATUS_RUNNING_ON_DEFAULTS :
			statusMessage = g_statusMessages[ g_lastStatusID ];
			break;
		case STATUS_BELOW_MIN_LOT_SIZE :
			statusMessage = g_statusMessages[ g_lastStatusID ];
			break;
		case STATUS_DLLS_NOT_ALLOWED :
			statusMessage = g_statusMessages[ g_lastStatusID ];
			break;
		case STATUS_LIBS_NOT_ALLOWED :
			statusMessage = g_statusMessages[ g_lastStatusID ];
			break;
		case STATUS_TIMEARRAY_MISMATCH :
			statusMessage = g_statusMessages[ g_lastStatusID ];
			break;

	    	
										 } // switch( g_lastStatusID )
										 
		if( g_lastError != statusMessage)
		{
		g_alertStatus = ALERT_STATUS_NEW ;
		}
	
		if(ALERT_STATUS_NEW == g_alertStatus)
		{
		Alert("Error : ", statusMessage) ;
		g_alertStatus = ALERT_STATUS_DISPLAYED ;
		g_lastError = statusMessage ;
		}
	
		clr = ErrorColor;
	break;
										} // switch( g_severityStatus )

	ObjectSet( g_objStatusPane, OBJPROP_YDISTANCE, g_baseYOffset );
   ObjectSetText( g_objStatusPane, statusMessage, FontSize * 1.2, g_fontName, clr );
   
   if( doRedraw )
   {
  		// Update the window content
		WindowRedraw();
	}
}

void deinitUI()
{
   ObjectDelete( g_objBalance );
   ObjectDelete( g_objGeneralInfo );
	ObjectDelete( g_objTradeSize );
	ObjectDelete( g_objBoxHigh);
	ObjectDelete( g_objBoxLow);
	ObjectDelete( g_objIsHour);
	ObjectDelete( g_objStopLoss );
	ObjectDelete( g_objTakeProfit );
	ObjectDelete( g_objATR );
	ObjectDelete( g_objPL );
	ObjectDelete( g_objStatusPane );
	ObjectDelete( g_objSundayCandlesInfo );
	ObjectDelete( g_objautotime );
}

void logOrderSendInfo(
               string commonInfo,
               double orderSize,
               double openPrice,
                  int slippage,
               double stopLoss,
               double takeProfit,
                  int errorCode
                     )
{
   string info = StringConcatenate(
                      commonInfo,
                      "instrument: ",   g_symbol,
                      " order size: ",  orderSize,
                      " open price: ",  openPrice,
                      " slippage: ",    slippage,
                      " stop loss: ",   stopLoss,
                      " take profit: ", takeProfit
                                  );
   Print( info );
   if( ERR_NO_ERROR == errorCode )
      return;
    
   Print( "Error info: ", errorCode, " description: ", ErrorDescription( errorCode ) );
}

//--------------------------------------------------------- Equity track begin -------------------------

void initEquityLog()
{

   g_fileEquityLog=FileOpen(EquityTrackFileName+".csv", FILE_CSV | FILE_WRITE, ';' );
   g_prevDailyEquityMin = AccountEquity();
   FileWrite(g_fileEquityLog,
               "MaxAdaptiveCrit=000.00000", //place holder for AdaptiveCriteria. Actual value will be written in deinit function
               "MinAdaptiveCrit=000.00000",
               "Symbol="+Symbol(),
               "Period="+Period(),
               "Deposit="+DoubleToStr(AccountBalance(),0),
               "AccountRiskUnit="+DoubleToStr(AccountRiskUnit,2),
               "Spread="+DoubleToStr(MarketInfo(Symbol(),MODE_SPREAD),0),
               "Digits="+DoubleToStr(MarketInfo(Symbol(),MODE_DIGITS),0) 
             );
   FileWrite(g_fileEquityLog,"Time","DailyEquityMin","Profit/Loss");
   FileWrite(g_fileEquityLog,"-----------------------------------");

}

void deinitEquityLog()
{

   //write actual equity value as last log entry at backtest close 
   double closingEquityProfit = AccountEquity() - g_prevDailyEquityMin;
   FileWrite(g_fileEquityLog,TimeToStr( TimeCurrent(),TIME_DATE|TIME_MINUTES ) , AccountEquity(),closingEquityProfit);

   FileClose(g_fileEquityLog);


   if (recordMaxAdaptive) {
   
      double maxAdaptiveCrit= GlobalVariableGet("MaxAdaptive");
      string maxAdaptiveCritStr= "MaxAdaptiveCrit=" + leadingZeros(maxAdaptiveCrit,3) + DoubleToStr(maxAdaptiveCrit,5) + ";"; 
      

      double minAdaptiveCrit= GlobalVariableGet("MinAdaptive");
      string minAdaptiveCritStr= "MinAdaptiveCrit=" + leadingZeros(minAdaptiveCrit,3) + DoubleToStr(minAdaptiveCrit,5) + ";"; 
         
      //write to the csv equity header the Adaptive values
      g_fileEquityLog= FileOpen(EquityTrackFileName+".csv", FILE_BIN | FILE_READ | FILE_WRITE );
      
      FileSeek(g_fileEquityLog,0,SEEK_SET);
      FileWriteString(g_fileEquityLog, maxAdaptiveCritStr,26); 
      FileSeek(g_fileEquityLog,26,SEEK_SET);
      FileWriteString(g_fileEquityLog,minAdaptiveCritStr,26); 
      
      FileClose(g_fileEquityLog);
      
   }
   


}

void updateEquityLog()
{

   double dailyEquityProfit;

   if (  TimeToStr( TimeCurrent(),TIME_DATE ) != g_currentDay )
   {
      
      if ( g_currentDay != "" ) 
      {
         dailyEquityProfit = g_dailyEquityMin - g_prevDailyEquityMin;
         FileWrite(g_fileEquityLog, g_timeOfEquityMin, g_dailyEquityMin,dailyEquityProfit);
         g_prevDailyEquityMin = g_dailyEquityMin;
      }
      g_currentDay = TimeToStr( TimeCurrent(),TIME_DATE );
      g_dailyEquityMin = MathPow(10,12);
      
   }
   
   if ( AccountEquity() < g_dailyEquityMin ) {
      g_dailyEquityMin = AccountEquity();
      g_timeOfEquityMin = TimeToStr( TimeCurrent(),TIME_DATE|TIME_MINUTES );
   }
}

string leadingZeros(double doubleNumber, int integerPartWidth)
{     
      string leadingZeros = "";
      
      int noOfLeadingZeros = integerPartWidth - StringLen(DoubleToStr(doubleNumber,0));
      for(int i=1; i<=noOfLeadingZeros; i++)
         leadingZeros = leadingZeros + "0";
         
      return(leadingZeros);
         
   
}

//--------------------------------------------------------- Equity track end -------------------------
