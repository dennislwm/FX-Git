//|-----------------------------------------------------------------------------------------|
//|                                                  Cointegration Search Engine_SqLite.mq4 |
//|                                                            Copyright © 2012, Dennis Lee |
//| Assert History                                                                          |
//| 1.1.4   Added debug info for first time run, and to view a specific arb pair.           |
//| 1.1.3   Added PlusRDev.mqh R console for debugging. There are several findings:         |
//|            (1) regressand is a numeric vector containing the actual price of the first  |
//|               currency (arb1) of TWO (2) symbols (arbpair); regressand[1] contains the  |
//|               current price (this is also true for regressors and pred);                |
//|            (2) regressors is a matrix containing the actual price of the second         |
//|               currency (arb2); the matrix contains TWO (2) columns, but the first       |
//|               column is NOT used, the actual prices are in the second column;           |
//|            (3) pred is a numeric vector containing the hat error, i.e. the actual price |
//|               of arb1 less the hat (predicted) price of arb1; the original author calls |
//|               this spread; pred is computed in plot() function, and is a result of R    |
//|               predict() of a linear regression model (arb1 ~ arb2), where arb1 is the   |
//|               outcome and arb2 is the predictor. After the model is generated, a new    |
//|               arb2 (old arb2 plus one new price) is passed as argument to R predict();  |
//|            (4) A global MT4 variable pred is an array containing the hat error, and is  |
//|               different from the R variable pred.                                       |
//| 1.1.2   Added a function ConditionalGlobalVariableSet() to replace a portion of code.   |
//|         This is to facilitate unit testing. Variable Rplot is now an extern, to show    |
//|         the Arb-O-Mat plot. In addition, there are FIVE (5) diagnostic plots:           |
//|         (1) y vs x; (2) residuals vs fitted; (3) Normal Q-Q; (4) residuals; and         |
//|         (5) predicted model. There are THREE (3) data frames written to CSV files in    |
//|         folder "C:/Users/user/My Documents/" are used to recreate the model in RStudio. |
//|         TODO: There appears to be a MAJOR bug where the newdata is reversed when passed |
//|         as input to the function predict(), which causes a prediction price based on    |
//|         the oldest price, instead of the newest price (see plot (5) predicted model).   |
//| 1.11    Added externs symbol 1-8, and debug functions.                                  |
//| 1.10    Added PlusGhost. (Note: EA does not use MagicNumber.)                           |
//| 1.00    Originated from Steve Hopwood Co-Integration System downloaded on 11 July 2012. |
//|-----------------------------------------------------------------------------------------|
#property copyright "Copyright © 2012, Dennis Lee"
#property link      ""

//#define RPATH "E:/Appz/R/R-2.12.0/bin/i386/Rterm.exe --no-save"
#define RDEBUG 1

//--- Assert 2: Plus include files
#include <PlusTurtle.mqh>
#include <PlusGhost.mqh>
#include <mt4R.mqh>                // <-- its on forexfactory. need version 1.3
//#include <common_functions.mqh> 
#include <stderror.mqh>  
#include <stdlib.mqh>
//--- DL: PlusRDev unit test
#include <PlusRDev.mqh>

//|-----------------------------------------------------------------------------------------|
//|                           E X T E R N A L   V A R I A B L E S                           |
//|-----------------------------------------------------------------------------------------|
extern int MaxAccountTrades = 4;
extern string e1 = "Set symbol to empty to exclude currency.";
extern string Symbol1 = "AUD";
extern string Symbol2 = "CAD";
extern string Symbol3 = "EUR";
extern string Symbol4 = "GBP";
extern string Symbol5 = "USD";
extern string Symbol6 = "JPY";
extern string Symbol7 = "CHF";
extern string Symbol8 = "NZD";
extern int back_bars = 576;
//--- Lots are calculated using the following formula:
//       arb1: lot = base_units * coeffR1 / 100
//       arb2: lot = base_units * coeffR2 / 100
extern int base_units = 1000;
extern double Lots = 0.1;
extern bool UseCoefficient = true;
extern double CoefThresh = 2;
extern bool UseADF = false;
//--- Augmented Dickey-Fuller (ADF) test 
//       The null-hypothesis for an ADF test is that the data is non-stationary 
//       Therefore, usually p<0.05 is stationary (default: 0.10 is unusually high)
extern double pthresh = 0.10;
extern bool UseCorrelation = false;
extern double PositivCorr = 75;
extern int CorrelationTimeFrame = 1440;
extern int CorrelationPeriods = 50;
extern double StdDevEntryLevel = 2;
extern double StdDevReentry = 1;
extern bool UseAbsolutExit = true;
extern double StdDevExit = 1;
extern bool UseAlert = false;
extern bool UseExitAlert = true;
//--- Set UseTradeLimiter=true to prevent the same currency from being traded TWICE.
//       Checks to see if either of the currencies in the pair is already being traded twice.
extern bool UseTradeLimiter = false;
//--- Set StopOpenNewOrders=true to prevent new orders, however it does NOT close opened orders.
extern bool StopOpenNewOrders = false;
extern bool ReentryInsteadExit = true;
extern string info0 = "Set Spread to 0(zero) for no limiting";
extern double SpreadLimiter = 100;
extern string RPATH = "C:/Program Files/R/R-2.15.1/bin/i386/Rterm.exe --no-save";
extern color clr_spreadline = Yellow;
extern color clr_above = FireBrick;
extern color clr_below = DarkGreen;
extern int EaViewDebug = 0;
extern int EaViewDebugNoStack = 1000;
extern int EaViewDebugNoStackEnd = 0;

//|-----------------------------------------------------------------------------------------|
//|                           I N T E R N A L   V A R I A B L E S                           |
//|-----------------------------------------------------------------------------------------|
string EaName = "Cointegration Search Engine_SqLite";
string EaVer = "1.1.4";
//--- Set Trend to true, to use actual price instead of (actual price - price_hat)
//       Note: this is NOT recommended, so I have commented out the relevant code
//bool trend = false;
//--- Set Rplot=true to view the Rplot of ALL arb pairs
//       To view the Rplot of a certain arb pair, set the RArb_01_DebugStr and RArb_02_DebugStr, 
//       e.g. "EURUSDm" and "EURCADm"
//    Set Rdebug=true to create a separate R device for output from R commands
extern bool Rplot = false;
extern string RArb_01_DebugStr = "";
extern string RArb_02_DebugStr = "";
extern bool Rdebug = false;
double pair1[];
double pair2[];
int RhDebug;
int RhPlot;

#define GLOBALNAME "arb-o-mat" // prefix for global variable names
static color CLR_BUY_ARROW = Blue;
static color CLR_SELL_ARROW = Red;
static color CLR_CROSSLINE_ACTIVE = Magenta;
static color CLR_CROSSLINE_TRIGGERED = Aqua;
static bool IS_ECN_BROKER = false;

string symb[0];
double coef[];
double regressors[]; // this flat array is actually representing a matrix
double prices[];
double pred[];
double stddev;
int pairs;
int back;
int this;
string ratios;
int time_last;  // time of last bar
int alert_time;
string m="";
string s[50];
string PairArray[8] ;
int fp, sp;
double GlobalPipsMultiplier;
string datum = "2011.12.05 07:30";
string AllPairs[];
double LevelEntry[];
double LevelReentry[];

//|-----------------------------------------------------------------------------------------|
//|                            I N I T I A L I S A T I O N                                  |
//|-----------------------------------------------------------------------------------------|
int init(){
   int i;
   int x = 0;
   string Pair;
   PairArray[0]= Symbol1;
   PairArray[1]= Symbol2;
   PairArray[2]= Symbol3;
   PairArray[3]= Symbol4;
   PairArray[4]= Symbol5;
   PairArray[5]= Symbol6;
   PairArray[6]= Symbol7;
   PairArray[7]= Symbol8;
   /*PairArray[0]= "AUD";
   PairArray[1]= "CAD";
   PairArray[2]= "CHF";
   PairArray[3]= "EUR";
   PairArray[4]= "GBP";
   PairArray[5]= "JPY";
   PairArray[6]= "NZD";
   PairArray[7]= "USD";*/
   for( i=0;i<=8;i++)
      {
         for(int j=0;j<=8;j++)
         {
            Pair=StringConcatenate(PairArray[i],PairArray[j]);
            m = StringSubstr(Symbol(),6,StringLen(Symbol())-6);
            Pair = Pair + m;
            if(MarketInfo(Pair, MODE_TRADEALLOWED) == true)
            {
               s[x] = Pair;//FileWrite(handle, Pair);
               x++;
            }
         }
      }
      ArrayResize(s,x);
   m = StringSubstr(Symbol(),6,StringLen(Symbol())-6);
   
   pairs = 0;
   /*if (Symbol1 != "") append(Symbol1);
   if (Symbol2 != "") append(Symbol2);
   if (Symbol3 != "") append(Symbol3);
   if (Symbol4 != "") append(Symbol4);
   if (Symbol5 != "") append(Symbol5);
   if (Symbol6 != "") append(Symbol6);
   if (Symbol7 != "") append(Symbol7);
   this = -1;
   for(i=0; i<pairs; i++){
      if(symb[i] == Symbol()){
         this = i;
         break;
      }
   }
   if (this == -1){
      append(Symbol());
      this = pairs-1;
   }*/
   
   if (UninitializeReason() != REASON_CHARTCHANGE){
      StartR(RPATH, RDEBUG);
      Rx("options(device='windows')");
   }
   Rx("library(zoo)");
   Rx("library(tseries)");
//--- DL: PlusRDev unit test
//       (1) create new dev for debug
//       (2) create new dev for plot   
   if( Rdebug )
   {
      RDevInit();
      RhDebug = RDevConsoleNewInt();
      RDevConsoleTextPlot(RhDebug, Rqs("Initialized RhDebug..."), 0.9);
      if( RIsStopped() || RhDebug==0 )
         EaDebugPrint( 1, "init:RDevConsoleNewInt", 
            EaDebugBln("RIsStopped", RIsStopped() )+
            EaDebugInt("RhDebug", RhDebug)+
            "Ensure the package(s) and file(s) are installed: (1) package gplots; (2) file PlusDev.R" );
      RhPlot = RDevConsoleNewInt();
   }
   
   time_last = 0; // force new bar
   alert_time = 0;
   
   /*s[0]="AUDCAD"+m;  s[1]="AUDCHF"+m;  s[2]="AUDJPY"+m;  s[3]="AUDNZD"+m;  s[4]="AUDUSD"+m;
      s[5]="CADJPY"+m;  s[6]="CHFJPY"+m;  s[7]="EURAUD"+m;  s[8]="EURCAD"+m;  s[9]="EURCHF"+m;
      s[10]="EURGBP"+m; s[11]="EURJPY"+m; s[12]="EURNZD"+m; s[13]="EURUSD"+m; s[14]="GBPAUD"+m; 
      s[15]="GBPCAD"+m; s[16]="GBPCHF"+m; s[17]="GBPJPY"+m; s[18]="GBPNZD"+m; s[19]="GBPUSD"+m;
      s[20]="NZDCHF"+m; s[21]="NZDJPY"+m; s[22]="NZDUSD"+m; s[23]="USDCAD"+m; s[24]="USDCHF"+m;
      s[25]="USDJPY"+m;*/
      
   if(Digits == 2 || Digits == 4) GlobalPipsMultiplier = 1;
   if(Digits == 3 || Digits == 5) GlobalPipsMultiplier = 10;
   if(Digits == 6) GlobalPipsMultiplier = 100;   
   if(Digits == 7) GlobalPipsMultiplier = 1000;
   SpreadLimiter *= GlobalPipsMultiplier;
//--- Assert 2: Init Plus   
   TurtleInit();
   GhostInit();
}

//|-----------------------------------------------------------------------------------------|
//|                               M A I N   P R O C E D U R E                               |
//|-----------------------------------------------------------------------------------------|
int start()
{
   string cmd="";
   string Sym="";
   int handle = FileOpen("CISEBook.txt", FILE_READ | FILE_CSV, ",");
   if (handle !=-1)
   {
      cmd = FileReadString(handle,0);
      Sym = FileReadString(handle,0);
      FileClose(handle);
      FileDelete("CISEBook.txt");
      Print(cmd + ":" + Sym);
      
      if(cmd=="CLOSEPartial")
      {
         closeOrders(Sym);
         GlobalVariableDel(Sym);
      }
   }
   int count = ArraySize(s);
   if(Time[0] < StrToTime(datum)) return(0);
   
   if (Time[0] == time_last){
      //onTick();
      return(0);
   }else
   {
      for( sp=0;sp<count;sp++)
      {
         for( fp=0;fp<count;fp++)
         {
            if(fp != sp)
            {
               pairs = 0;
               this = 0;
               append(s[fp]);
               append(s[sp]);
               if( ( (MarketInfo(s[sp], MODE_SPREAD) + MarketInfo(s[fp], MODE_SPREAD)) <= SpreadLimiter) || (SpreadLimiter == 0) )
               {
                  if(UseCorrelation)
                  {
                     double corr = 100*cp(s[fp],s[sp],CorrelationTimeFrame,CorrelationPeriods);
                     if(corr >= PositivCorr)
                     {
                        onOpen();
                        onTick();
                     }
                  } else
                  {
                     onOpen();
                     onTick();
                  }
               }
            }
         }
      }
   }
   time_last = Time[0];
//--- Assert 2: Refresh Plus   
   GhostRefresh();
   Comment(GhostComment(""));
   
   return(0);
}

//|-----------------------------------------------------------------------------------------|
//|                           I N T E R N A L   F U N C T I O N S                           |
//|-----------------------------------------------------------------------------------------|
void append(string symbol){
   pairs++;
   ArrayResize(symb, pairs);
   symb[pairs-1] = symbol;
}

void onOpen(){
   int i, ii, j;
   int ishift;
   
   // if any pair has less than back bars in the history
   // then adjust back accordingly.
   back = back_bars;
   for (i=0; i<pairs; i++){
      if (iBars(symb[i], 0) < back){
         back = iBars(symb[i], 0) - 2; // use the third last bar.
      }
   }
   
//--- DL: PlusRDev unit test
//       If the pair does NOT have sufficient history,
//       the ArraySize will fail due to negative back
   ArrayResize(coef, pairs);
   ArrayResize(prices, pairs);
   ArrayResize(regressors, back * pairs);
   ArrayResize(pred, back);
   Rx("rm(list=ls()[ls()!='debugChr'])");
   Ri("back", back);
   Ri("pairs", pairs);
   
//--- DL: PlusRDev unit test
//       Ensure rm() R function does NOT delete debugChr
//       Create a debugChr as an R character vector
//          As OnOpen() is called many times, we want debugChr to persist
//       fill the matrix of regressors
//       and then copy it over to R
   bool isDup;
   
   //if( !ReBln("debugChr") )   Rx( "debugChr <- c()" );   
   for (i=0; i<back; i++){
      for (j=0; j<pairs; j++){
         ishift = iBarShift(symb[j], 0, Time[i]);
         regressors[i * pairs + j] = iClose(symb[j], 0, ishift);
         /*isDup = RxBln( "length(which(debugChr=="+Rqs(symb[j])+"))!=0" );         
         if( !isDup ) 
         {
            Rx( "debugChr <- c"+Rbr("debugChr, "+Rqs(symb[j])) );
         }*/
      }
   }
   //RDevConsoleTextPlot(RhDebug, "debugChr", 0.9, FALSE);
//--- Filling a R matrix is tricky, as it requires an MT4 array with alternating values
//       Example of a NxM R matrix, where N=back and M=pairs
//       Fill an MT4 array=regressors with values such that 
//          (1) [0] is the bar[0] price of pair 1
//          (2) [1] is the bar[0] price of pair 2
//          (3) [2] is the bar[1] price of pair 1
//          (4) [3] is the bar[1] price of pair 2, and so on.
//       Call function Rm() to create a NxM R matrix with parameters
//          (1) array:  an MT4 array with alternating values
//          (2) rows:   an MT4 integer with number of rows, i.e. back
//          (3) cols:   an MT4 integer with number of columns, i.e. pairs
   Rm("regressors", regressors, back, pairs);
      
   // do the regression
   // first we need a regressand
   /*if (trend){
      // we simply use a straight line that will be our ideal trend
      // note that it points downward since the history is ordered backwards
      Rd("trendslope", 0.01);
      Rx("regressand <- trendslope - trendslope * seq(1, back) / back"); 
   
   }else{*/
      Ri("cthis", this + 1);                       // counting starts with 1
      Rx("regressand <- regressors[, cthis]");     // use this column as regressand
      Rx("regressors[, cthis] <- rep(0, back)");   // set the column to zero in the matrix
   /*}*/
   Rx("y <- regressand");                          // stupid R will remember the variable names so we  
   Rx("x <- regressors");                          // have to be careful how we name them in the formula
   Rx("model <- lm(y ~ x)");                       // fit the model
   Rp("summary(model)");
   Rx("nonsource.wd <- 'C:/Users/user/My Documents/'");
   Rx("write.table( regressand, file=paste0( nonsource.wd, 'regressand.csv' ), sep=',', quote=FALSE, row.names=FALSE )");
   Rx("write.table( regressors, file=paste0( nonsource.wd, 'regressors.csv' ), sep=',', quote=FALSE, row.names=FALSE )");
   
   // get the coefficients
   //Rx("beta <- coef(model)[-1]");
   Rgv("coef(model)[-1]", coef);   // remove the first one (the constant term)
   Rx("stddev <- sd(resid(model))");
   stddev = Rgd("stddev");

   // convert the coefficients to usable hege ratios by multiplying
   // xxx/usd pairs with their quote. The results can then be
   // conveniently interpreted as multiples of needed Lots or Units.
   // also take care of the special case when fitting a spread 
   // instead a trend
   string s;
   double cc;
   for (i=0; i<pairs; i++){
      // if we fit a spread then all pairs except this one are on the other 
      // side (negative) and this one (the regressand) is 1 by definition
      /*if (!trend){*/
         if (i == this){
            coef[i] = 1;
         }else{
            coef[i] = -coef[i];
         }
      /*}*/
      
      if( coef[i]==0 )
         EaDebugPrint( 1, "start:onOpen", 
            EaDebugDbl("coef["+i+"]", coef[i])+
            "coef[]==0 is typically a result of previous R command gone wrong!" );
      // convert to units
      cc = ConvertCurrency(1,symb[i],"USD",iOpen(symb[i],0,0),s);
      if( cc != 0 ) coef[i] = coef[i] * 1/cc;
      
      // The following makes sure that if the first pair is an USD/XXX pair
      // it is normalized to 1 again and the lot sizes of the other ones 
      // instead made smaller by the same factor.
      /*if (!trend){*/
         cc = ConvertCurrency(1,symb[i],"USD",iOpen(symb[i],0,0),s);
         if( cc!= 0 ) coef[i] = coef[i] / cc;
      /*}*/
   }
   
   // format a string that presents the hedge ratios
   // to the user and that will be displayed in the plot
   // it will also multiply them with base_units so you
   // have some reasonable numbers for your oanda account 
   ratios = "hedge ratios [multiples of Lots]\n";
   for (i=0; i<pairs; i++){
      if(MarketInfo(symb[i],MODE_DIGITS) == 3)
      {
          double units = base_units * coef[i] /100;
      } else
      {
         units = base_units * coef[i];
      }
      ratios = ratios + symb[i] 
      
      + " " + DoubleToStr(MathRound(units), 0) 
      + " (" +  DoubleToStr(GlobalVariableGet(GLOBALNAME+Symbol()+Period()+"_"+symb[i]),0) + ")\n";
   }
   //Comment(ratios);

   if( RArb_01_DebugStr=="" || RArb_02_DebugStr=="" )
      plot();   
   else
      plot(symb[0], symb[1]);
}

void onTick(){
   int units, units1; 
   int i; 
   
   // update the last row
   /*if (!trend){*/
      prices[1] = iClose(symb[1], 0, 0);
      prices[0] = 0;
         
      
      Rv("current_others", prices);
      Rd("current_this", iClose(symb[0], 0, 0));
      Rx("regressors[1,] <- current_others");
      Rx("regressand[1] <- current_this");
   /*}else{
      for (i=0; i<pairs; i++){
         prices[i] = iClose(symb[i], 0, 0);
      }
      Rv("current_all", prices);
      Rx("regressors[1,] <- current_all");
   }*/
   if( RArb_01_DebugStr=="" || RArb_02_DebugStr=="" )
      plot();   
   else
      plot(symb[0], symb[1]);
   
   if (ObjectGet("back", OBJPROP_TIME1) != 0){
      if (iBarShift(NULL, 0, ObjectGet("back", OBJPROP_TIME1)) != back){
         time_last = 0;
      }
   }
   double ActLevel = 0;
   string symset = "";
   if(GlobalVariableCheck(s[fp]+s[sp]) == true )
   {
      ActLevel = GlobalVariableGet(s[fp]+s[sp]);
      symset = s[fp]+s[sp];
      
      if(ActLevel<0)
      {
         if(UseAbsolutExit)
         {
            double absexit = -StdDevExit;
         } else
         {
            absexit = ActLevel+StdDevExit;
         }
         if((pred[1]) > ( (absexit) * stddev))
         {
            
            if((GetProfit(symset)>0.00))
            {
               closeOrders(symset);
               if (UseExitAlert) Alert(symset + " " + Period() + " exit "+(absexit));
               GlobalVariableDel(symset);
            }
         }
         // Reentry or Exit Section with negativ Level
         if((pred[1]) < ( (ActLevel-StdDevReentry) * stddev))
         {
            if(!ReentryInsteadExit)
            {
               closeOrders(symset);
               if (UseExitAlert) Alert(symset + " " + Period() + " exit "+(ActLevel-StdDevReentry));
               GlobalVariableDel(symset);               
            } 
         }
      }
      if(ActLevel>0)
      {
         if(UseAbsolutExit)
         {
            absexit = StdDevExit;
         } else
         {
            absexit = ActLevel-StdDevExit;
         }
         if( (pred[1]) < ((absexit) * stddev) )
         {
            
            if((GetProfit(symset)>0.00))
            {
               
               closeOrders(symset);
               if (UseExitAlert) Alert(symset + " " + Period() + " exit "+(absexit));
               GlobalVariableDel(symset);
            }
         }
         
         //Reentry or exit Section with positiv Level
         if( (pred[1]) > ((ActLevel+StdDevReentry) * stddev) )
         {
            
            if(!ReentryInsteadExit)
            {
               closeOrders(symset);
               if (UseExitAlert) Alert(symset + " " + Period() + " exit "+(ActLevel+StdDevReentry));
               GlobalVariableDel(symset);
            }
         }
      }
   }

//--- Debug code to study the behaviour of regressand, regressors, and pred   
   if( Rdebug && RhDebug > 0 )
   {
      RDevConsoleSinkOn(RhDebug);
      Rx( "head(regressand)" );
      Rx( "head(pred)" );
      Rx( "tail(pred)" );
      Rx( "head(regressand-pred)" );
      Rx( "head(regressors)" );
      Rx( "tail(regressors)" );
      Rx( "length(pred)" );
      Rx( "length(regressand)" );
      Rx( "class(regressors)" );
      RDevConsoleSinkOff(RhDebug);
      /*RDevConsoleTextPlot(RhDebug, Rqs(pred[1]+">|"+StdDevEntryLevel+"*"+stddev+"|"+Rbr(""+StdDevEntryLevel*stddev)), 
      0.9, TRUE);*/
   }
   for(int Lvl=StdDevEntryLevel+8;Lvl>=StdDevEntryLevel;Lvl--)
   {
      StddevOrders(Lvl);
   }   
}

double ADF()
{
   ArrayResize(pair1,back_bars);
      ArrayResize(pair2,back_bars);
      for(int i=back_bars; i>=0; i--)
      {
      
         pair1[i] = iClose(s[fp],0,i);
         pair2[i] = iClose(s[sp],0,i);
      }
      Rv("pair1",pair1);
      Rv("pair2",pair2);
      Rx("m <- lm(pair2 ~ pair1 + 0)");
      Rx("beta <- coef(m)[1]");
      Rx("sprd <- pair1 - beta*pair2");
      Rx("ht <- adf.test(sprd, alternative='stationary', k=0)");
      Rx("pval <- as.numeric(ht$p.value)");
      double result = Rgd("pval");
      return(result);
}
void StddevOrders(double Level)
{
      if(UseTradeLimiter)
      {
         if(IsThisPairTradable(s[fp]) && IsThisPairTradable(s[sp]))
         {
            TradeLevel(Level);
         }
      } else
      {
         TradeLevel(Level);
      }
}

void TradeLevel(double Level)
{
   bool tradecoef0 = true;
   bool tradecoef1 = true;
   double coef0, coef1,coefratio;
   
   double coefR0 = MathAbs(coef[0]);
      double coefR1 = MathAbs(coef[1]);
      if( MarketInfo(symb[0],MODE_DIGITS) == 3 || MarketInfo(symb[0],MODE_DIGITS) == 2 )
      {
          double units0 = base_units * coefR0 /100;
          
      } else
      {
         units0 = base_units * coefR0;
         
      }  
      if( MarketInfo(symb[1],MODE_DIGITS) == 3 || MarketInfo(symb[1],MODE_DIGITS) == 2)
      {
          
          double units1 = base_units * coefR1 /100;
      } else
      {
         
         units1 = base_units * coefR1;
      }   
   if(UseCoefficient)
   {
      
      double maxcoef = MathMax(units0, units1);
      double mincoef = MathMin(units0, units1);
      coefratio = maxcoef / mincoef;
      if(coefratio <= CoefThresh)
      {
         if(units0 > units1)
         {
            units0 = Lots;
            units1 = Lots / coefratio;
            units1 = NormalizeDouble(units1, 2);
            if(units1 < 0.01)
            {
               tradecoef1 = false;
               tradecoef0 = false;
            }
         } else
         {
            units1 = Lots;
            units0 = Lots / coefratio;
            units0 = NormalizeDouble(units0, 2);
            if(units0 < 0.01)
            {
               tradecoef0 = false;
               tradecoef1 = false;
            }
         }
      } else
      {
         tradecoef0 = false;
         tradecoef1 = false;
      }
   }  else
   {
      units1 = Lots;
      units0 = Lots;
   } 
   if(UseADF && ( (pred[1] > StdDevEntryLevel*stddev) || (pred[1] < -StdDevEntryLevel*stddev) ) && tradecoef0 == true && tradecoef1 ==true)
   {
      if( (GlobalVariableCheck(s[fp]+s[sp]) == false && GlobalVariableCheck(s[sp]+s[fp]) == false) ) 
      {
         if( ConditionalGlobalVariableSet( s[fp]+s[sp], ADF(), pthresh, pred[1], stddev, StdDevEntryLevel ) )
            EaDebugPrint( 1, "ConditionalGlobalVariableSet",
               EaDebugStr("gvar",s[fp]+s[sp])+
               EaDebugDbl("Get(gvar)",GlobalVariableGet(s[fp]+s[sp]))+
               " as THREE (3) conditions have been satisfied." );
               
         /*double pval=ADF();
         
         if( (pred[1] > StdDevEntryLevel*stddev) && (pval<=pthresh) && (pval !=0))
            GlobalVariableSet(s[fp]+s[sp],NormalizeDouble(StdDevEntryLevel-1,2));
             
         if( (pred[1] < -StdDevEntryLevel*stddev)&& (pval<=pthresh) && (pval !=0))
            GlobalVariableSet(s[fp]+s[sp],NormalizeDouble(-StdDevEntryLevel+1,2));*/
      }  
   }
   if (pred[2] > ( Level * stddev) && pred[1] < ( Level * stddev)/*&& alert_time<Time[0]*/)
   {
      if( (GlobalVariableCheck(s[fp]+s[sp]) == false && GlobalVariableCheck(s[sp]+s[fp]) == false && StopOpenNewOrders == false && UseADF == false && tradecoef0 == true && tradecoef1 ==true) 
         || (Level > GlobalVariableGet(s[fp]+s[sp]) && GlobalVariableGet(s[fp]+s[sp]) > 0 && tradecoef0 == true && tradecoef1 == true) )
      {
            if (Level > GlobalVariableGet(s[fp]+s[sp]) && GlobalVariableGet(s[fp]+s[sp]) > 0 && tradecoef0 == true && tradecoef1 == true)
            {
                if (UseExitAlert) Alert(s[fp]+"|"+s[sp] + " " + Period() + " reentry "+Level+" * stddev");
            }
            GlobalVariableSet(s[fp]+s[sp],NormalizeDouble(Level,0));
            if (UseAlert) Alert(s[fp]+"|"+s[sp] + " " + Period() + " crossed "+Level+" * stddev");
         
            if(coef[0] > 0)
            {
               if(tradecoef0 ) sell(s[fp],units0,0,0,0,s[fp]+s[sp]);//OrderSend(s[fp], OP_SELL,0.01,MarketInfo(s[fp],MODE_BID),100,0,0,s[sp]+s[fp],0,0,CLR_NONE);
            } else
            {
               if(tradecoef0 ) buy(s[fp],units0,0,0,0,s[fp]+s[sp]);//OrderSend(s[fp], OP_BUY,0.01,MarketInfo(s[fp],MODE_ASK),100,0,0,s[sp]+s[fp],0,0,CLR_NONE);
            }
            if(coef[1] > 0)
            {
               if(tradecoef1 ) sell(s[sp],units1,0,0,0,s[fp]+s[sp]);//OrderSend(s[sp], OP_SELL,0.01,MarketInfo(s[sp],MODE_BID),100,0,0,s[sp]+s[fp],0,0,CLR_NONE);
            } else
            {
               if(tradecoef1 ) buy(s[sp],units1,0,0,0,s[fp]+s[sp]);//OrderSend(s[sp], OP_BUY,0.01,MarketInfo(s[sp],MODE_ASK),100,0,0,s[sp]+s[fp],0,0,CLR_NONE);
            }
           
            
      }
   }
   
   if (pred[2] < (-Level * stddev) && pred[1] > (-Level * stddev)/*&& alert_time<Time[0]*/)
   {
      if( (GlobalVariableCheck(s[fp]+s[sp]) == false && GlobalVariableCheck(s[sp]+s[fp]) == false && StopOpenNewOrders == false && UseADF == false && tradecoef0 == true && tradecoef1 ==true) ||
         (-Level < GlobalVariableGet(s[fp]+s[sp]) && GlobalVariableGet(s[fp]+s[sp]) < 0 && tradecoef0 == true && tradecoef1 == true) )
      {
         if (-Level < GlobalVariableGet(s[fp]+s[sp]) && GlobalVariableGet(s[fp]+s[sp]) < 0 && tradecoef0 == true && tradecoef1 == true)
         {
             if (UseExitAlert) Alert(s[fp]+"|"+s[sp] + " " + Period() + " reentry -"+Level+" * stddev");
         }
         GlobalVariableSet(s[fp]+s[sp],NormalizeDouble(-Level,0));
         if (UseAlert)Alert(s[fp]+"|"+s[sp] + " " + Period() + " crossed -"+Level+" * stddev");
         if(coef[0] > 0)
            {
               if(tradecoef0) buy(s[fp],units0,0,0,0,s[fp]+s[sp]);//(OrderSend(s[fp], OP_BUY,0.01,MarketInfo(s[fp],MODE_ASK),100,0,0,s[sp]+s[fp],0,0,CLR_NONE);
            } else
            {
               if(tradecoef0) sell(s[fp],units0,0,0,0,s[fp]+s[sp]);//OrderSend(s[fp], OP_SELL,0.01,MarketInfo(s[fp],MODE_BID),100,0,0,s[sp]+s[fp],0,0,CLR_NONE);
            }
         if(coef[1] > 0)
            {
               if(tradecoef1) buy(s[sp],units1,0,0,0,s[fp]+s[sp]);//OrderSend(s[sp], OP_BUY,0.01,MarketInfo(s[sp],MODE_ASK),100,0,0,s[sp]+s[fp],0,0,CLR_NONE);
            } else
            {
               if(tradecoef1) sell(s[sp],units1,0,0,0,s[fp]+s[sp]);//OrderSend(s[sp], OP_SELL,0.01,MarketInfo(s[sp],MODE_BID),100,0,0,s[sp]+s[fp],0,0,CLR_NONE);
            }
      }
   }
}

//|-----------------------------------------------------------------------------------------|
//|                            D E - I N I T I A L I S A T I O N                            |
//|-----------------------------------------------------------------------------------------|
int deinit(){
//--- Assert 1: DeInit Plus
   GhostDeInit();
   //Rx("save.image('c:/Programme/BestDirectMT4/experts/files/arbomat.R')");
   plotRemove("others");
   plotRemove("spread");
   if (UninitializeReason() != REASON_CHARTCHANGE){
      StopR();
   }
}

//+------------------------------------------------------------------+
//******************************************************************************
double   cp(string Symbol1,string Symbol2,int TimeFrame, int periods)
{
	//Comment( Symbol1,"  ",Symbol2,"  ",TimeFrame,"  ",periods);
	datetime closeTime1	= iTime(Symbol1,TimeFrame,0),
				closeTime2	= iTime(Symbol2,TimeFrame,0),
				closeTime	= MathMin(closeTime1,closeTime2);
	int		shift1		= iBarShift(Symbol1,TimeFrame,closeTime),
				shift2		= iBarShift(Symbol2,TimeFrame,closeTime);
	double	Co,
	         close1[],
				close2[];

	ArrayCopySeries(close1,MODE_CLOSE,Symbol1,TimeFrame);
	ArrayCopySeries(close2,MODE_CLOSE,Symbol2,TimeFrame);

	int bars = MathMin(ArraySize(close1)-shift1,ArraySize(close2)-shift2);
	if ( periods > 0 )
	     bars = periods;
   Co = Correlation(close1,close2,shift1,shift2,bars);
   
   return(Co);
}

//+------------------------------------------------------------------+
//| Correlation Coefficient R														|
//+------------------------------------------------------------------+
double Correlation(double x[], double y[], int x_shift = 0, int y_shift = 0, int count = -1)
{
	int n = MathMin(ArraySize(x)-x_shift,ArraySize(y)-y_shift);
	if(n>count && count>0)
		n=count;
	if(n<2)
		return(-2);

	double	sum_sq_x,
				sum_sq_y,
				sum_coproduct,
				mean_x = x[x_shift],
				mean_y = y[y_shift];

	for(int i = 0; i < n; i++)
	{
		double	sweep = i / (i+1.0),
					delta_x = x[i+x_shift] - mean_x,
					delta_y = y[i+y_shift] - mean_y;

		sum_sq_x += delta_x*delta_x * sweep;
		sum_sq_y += delta_y*delta_y * sweep;
    	sum_coproduct += delta_x*delta_y * sweep;
    	mean_x += delta_x / (i+1.0);
    	mean_y += delta_y / (i+1.0);
	}

	double	pop_sd_x = MathSqrt(sum_sq_x/n),
				pop_sd_y = MathSqrt(sum_sq_y/n),
				cov_x_y = sum_coproduct / n;

	if(pop_sd_x*pop_sd_y != 0.0)
		return(cov_x_y / (pop_sd_x*pop_sd_y));

	return(-3);
}

bool IsThisPairTradable(string sym)
{
   bool cannotTrade;
   //Checks to see if either of the currencies in the pair is already being traded twice.
   //If not, then return true to show that the pair can be traded, else return false
   
   string c1 = StringSubstr(sym, 0, 3);//First currency in the pair
   string c2 = StringSubstr(sym, 3, 3);//Second currency in the pair
   int c1open = 0, c2open = 0;
   //CanTradeThisPair = true;
//--- Assert 2: Init OrderSelect #1
   int total = GhostOrdersTotal();
   GhostInitSelect(false,0,SELECT_BY_POS,MODE_TRADES);
   for (int cc = total - 1; cc >= 0; cc--)
   {
      if (!GhostOrderSelect(cc, SELECT_BY_POS) ) continue;
      if (GhostOrderSymbol() != sym ) continue;
      int index = StringFind(sym, c1);
      if (index > -1)
      {
         c1open++;         
      }//if (index > -1)
   
      index = StringFind(sym, c2);
      if (index > -1)
      {
         c2open++;         
      }//if (index > -1)
   
      if (c1open == 1 && c2open == 1) 
      {
         //CanTradeThisPair = false;
         cannotTrade = true;
         break;
         /*return(false);*/
      }//if (c1open == 1 && c2open == 1) 
   }//for (int cc = OrdersTotal() - 1; cc >= 0; cc--)
//--- Assert 1: Free OrderSelect #1   
   GhostFreeSelect(false);

   if( cannotTrade ) return(false);
   //Got this far, so ok to trade
   return(true);
   
}//End bool IsThisPairTradable()   

double GetProfit(string cmd)
{
   int cnt;
   double AccProfit =0;
//--- Assert 2: Init OrderSelect #2
   int total = GhostOrdersTotal();
   GhostInitSelect(true,0,SELECT_BY_POS,MODE_TRADES);
   for(cnt=0; cnt<=total; cnt++){
      GhostOrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
      if(GhostOrderComment() == cmd)
      {
         AccProfit = AccProfit + (GhostOrderProfit()+GhostOrderCommission()+GhostOrderSwap());
      }
   }
//--- Assert 1: Free OrderSelect #2
   GhostFreeSelect(false);
   
   return(AccProfit);
}

bool closeOrders(string comment)
{
   int ticket=0;
   bool done=false;
//--- Assert 5: Declare variables for OrderSelect #3
//       1-OrderDelete BUY; 2-OrderClose BUY; 3-OrderDelete SELL; 4-OrderClose SELL;
   int      aCommand[];    
   int      aTicket[];
   double   aLots[];
   bool     aOk;
   int      aCount;
   while (IsTradeContextBusy())
   {
      Print("closeOpenOrders(): waiting for trade context.");
      Sleep(MathRand()/10);
   }
   RefreshRates();
//--- Assert 3: Dynamically resize arrays
   ArrayResize(aCommand,MaxAccountTrades);
   ArrayResize(aTicket,MaxAccountTrades);
   ArrayResize(aLots,MaxAccountTrades);
//--- Assert 2: Init OrderSelect #3
   int total = GhostOrdersTotal();
   GhostInitSelect(false,0,SELECT_BY_POS,MODE_TRADES);
   for(int cnt=total-1; cnt>=0; cnt--)
   {
      GhostOrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
   //--- Assert 3: Populate selected #3
      aCommand[aCount]     = 0;
      aTicket[aCount]      = GhostOrderTicket();
      aLots[aCount]        = GhostOrderLots();
      if(GhostOrderComment() == comment || comment == "")
      {
         EaDebugPrint( 1, "closeOrders",
            EaDebugStr("comment",comment) );
         
         if(GhostOrderType()==OP_BUY)
         {
         //--- Assert 3: Populate selected #3
            aCommand[aCount]  = 2;
            double price = MarketInfo(GhostOrderSymbol(), MODE_BID);
         } else
         {
         //--- Assert 3: Populate selected #3
            aCommand[aCount]  = 4;
            price = MarketInfo(GhostOrderSymbol(), MODE_ASK);
         }
      //--- Assert 3: Populate selected #3
         aCount ++;
         if( aCount >= MaxAccountTrades ) break;
         /*OrderClose(OrderTicket(), OrderLots(),price,999,CLR_NONE);*/
      }
   }
//--- Assert 1: Free OrderSelect #3
   GhostFreeSelect(false);
//--- Assert for: process array of commands
   for(int i=0; i<aCount; i++)
   {
      switch( aCommand[i] )
      {
         case 1:  // OrderDelete 
            break;
         case 2:  // OrderClose Buy
            GhostOrderClose( aTicket[i], aLots[i], price, 10, Red );
            break;
         case 3:  // OrderDelete 
            break;
         case 4:  // OrderClose Sell
            GhostOrderClose( aTicket[i], aLots[i], price, 10, Green );
            break;
      }
   }
   return(true);
}

/*bool autoclose(){
   string name = "autoclose" + Symbol() + Period();
   double ac = StrToDouble(ObjectDescription(name)) * Point * 10;
   if (ac > 0){
      if (pred[0] > ac){
         ObjectSetText(name, "0");
         return(True);         
      }
   }
   if (ac < 0){
      if (pred[0] < ac){
         ObjectSetText(name, "0");
         return(True);         
      }
   }
   return(False);
}*/

void plot(string arb_01_debugStr="", string arb_02_debugStr=""){
   static int last_back;
   // predict and plot from the model
   Rx("pred <- as.vector(predict(model, newdata=data.frame(x=I(regressors))))");
   
   /*if (!trend){*/
      if (last_back != back){
         plotRemove("others");
         plotRemove("spread");
         last_back = back;
      }

      // plot into the chart
      Rgv("pred", pred);
      //plotPrice("others", pred, clr_below, clr_above);
      Rgv("regressand-pred", pred);
      //plotOsc("spread", pred, 1, 0, clr_spreadline, clr_spreadline);
      
      label("spread_cur", 10, 70, 1, DoubleToStr(pred[0] / Point / 10, 1), Lime);
   /*}*/   
   
   bool plotBln;
   if( arb_01_debugStr=="" || arb_02_debugStr=="" ) plotBln=Rplot;
   else
   {
   //--- Plot only the symbols are RArb_01_DebugStr and RArb_02_DebugStr
      plotBln=false;
      if( arb_01_debugStr==RArb_01_DebugStr && arb_02_debugStr==RArb_02_DebugStr) plotBln=Rplot;
      if( arb_01_debugStr==RArb_02_DebugStr && arb_02_debugStr==RArb_01_DebugStr) plotBln=Rplot; 
   }
      
   // make the R plot (optional)
   if (plotBln){   
      Rs("descr1", Period() + " minute close prices");
      Rs("descr2", "begin: " + TimeToStr(Time[back-1]) + " -- end: " + TimeToStr(Time[0]));
      Rs("ratios", ratios);
      
      Rx("options(device='windows')");
      /*if(trend){
         Rx("curve <- rev(pred)");  // it is still ordered backwards, so we reverse it now
         Rs("lbly", "combined returns");
         Rx("linea <- trendslope/back");
      }else{*/
         Rx("curve <- rev(regressand - pred)");
         Rs("lbly", "spread");
         Rx("linea <- 0");
      /*}*/
      //--- Six plots (selectable by which) are currently available for LM model
      //       (1) a plot of residuals against fitted values, 
      //       (2) a Normal Q-Q plot, 
      //       (3) a Scale-Location plot of sqrt{| residuals |} against fitted values, 
      //       (4) a plot of Cook's distances versus row labels, 
      //       (5) a plot of residuals against leverages, and 
      //       (6) a plot of Cook's distances against leverage/(1-leverage). 
      //    By default, the first three and 5 are provided.
      Rx("par(mfrow=c(3,2))");
      Rx("new <- data.frame(x=I(regressors))");
      Rx("write.table( new, file=paste0( nonsource.wd, 'new.csv' ), sep=',', quote=FALSE, row.names=FALSE )");
      Rx("plot(x[,2], y, main='y vs x')");
      //Rx("abline(model)");
      Rx("plot(model, which=c(1:2), caption=c('Residuals vs Fitted', 'Normal Q-Q'))");
      Rx("plot(resid(model), main='Residuals')");
      Rx("p.model <- predict(model, newdata=new)");
      Rx("lenNew <- length(p.model)");
      //Rx("plot(c(y[2:lenNew,1], p.model[lenNew]), p.model)");
      Rx("plot(rev(p.model), type='l', main='Predicted Model (blue) vs Actual Price', col='cornflowerblue')");
      Rx("lines(rev(regressand), col='gray')");
      Rx("points(lenNew, p.model[lenNew], col='blue', pch=18)");
      Rx("plot(curve, type='l', ylab=lbly, xlab=descr1, main='Arb-O-Mat', sub=descr2, col='cornflowerblue')");
      Rx("abline(0, linea, col='cornflowerblue', lty='dashed')");
      Rx("abline(stddev, linea, col='green', lty='dashed')");
      Rx("abline(2*stddev, linea, col='green', lty='dashed')");
      Rx("abline(3*stddev, linea, col='green', lty='dashed')");
      Rx("abline(-stddev, linea, col='green', lty='dashed')");
      Rx("abline(-2*stddev, linea, col='green', lty='dashed')");
      Rx("abline(-3*stddev, linea, col='green', lty='dashed')");
      Rx("text(0, range(curve)[2], ratios, adj=c(0,1), col='black', font=2, family='mono')");
   }
}

/*void createOandaTicket(string symbol, int units){
   string first = StringSubstr(symbol, 0, 3);
   string last = StringSubstr(symbol, 3, 3);
   string command = first + "/" + last + " " + units;
   string filename = "oanda_tickets/" + TimeCurrent() + "_" + symbol + "_" + units;
   int F = FileOpen(filename, FILE_WRITE);
   FileWrite(F, command);
   FileClose(F);
}*/

// plotting functions

/*void plotPrice(string name, double series[], int clra=Red, int clrb=Red){
   int i;
   int len;
   if(IsStopped()) return;
   len = ArraySize(series);
   for (i=1; i<len; i++){
      if(IsStopped()) return;
      ObjectCreate(name + i, OBJ_TREND, 0, 0, 0);
      
      ObjectSet(name + i, OBJPROP_TIME1, Time[i-1]);
      ObjectSet(name + i, OBJPROP_TIME2, Time[i]);
      ObjectSet(name + i, OBJPROP_PRICE1, series[i-1]);
      ObjectSet(name + i, OBJPROP_PRICE2, series[i]);
      
      ObjectSet(name + i, OBJPROP_TIME1, Time[i-1]);
      ObjectSet(name + i, OBJPROP_TIME2, Time[i-1]);
      ObjectSet(name + i, OBJPROP_PRICE1, Close[i-1]);
      ObjectSet(name + i, OBJPROP_PRICE2, series[i-1]);

      ObjectSet(name + i, OBJPROP_RAY, false); 
      ObjectSet(name + i, OBJPROP_BACK, true); 
      if (series[i-1] >= Close[i-1]){
         ObjectSet(name + i, OBJPROP_COLOR, clra);
      }else{
         ObjectSet(name + i, OBJPROP_COLOR, clrb);
      }
   }
}*/

/*void plotOsc(string name, double series[], double scale=1, double offset=0, int clra=Red, int clrb=Red){
   int i;
   int len;
   double zero;
   if(IsStopped()) return;
   len = ArraySize(series);
   zero = (WindowPriceMax() + WindowPriceMin())/2 + offset;
   i = 0;
   ObjectCreate(name + i, OBJ_TREND, 0, 0, 0);
   ObjectSet(name + i, OBJPROP_TIME1, Time[0]);
   ObjectSet(name + i, OBJPROP_TIME2, Time[len]);
   ObjectSet(name + i, OBJPROP_PRICE1, zero);
   ObjectSet(name + i, OBJPROP_PRICE2, zero);
   ObjectSet(name + i, OBJPROP_RAY, false); 
   ObjectSet(name + i, OBJPROP_COLOR, clra);
   ObjectSet(name + i, OBJPROP_STYLE, STYLE_DOT);
   
   for (i=1; i<len; i++){
      if(IsStopped()) return;
      ObjectCreate(name + i, OBJ_TREND, 0, 0, 0);
      ObjectSet(name + i, OBJPROP_TIME1, Time[i-1]);
      ObjectSet(name + i, OBJPROP_TIME2, Time[i]);
      ObjectSet(name + i, OBJPROP_PRICE1, scale * series[i-1] + zero);
      ObjectSet(name + i, OBJPROP_PRICE2, scale * series[i] + zero);
      ObjectSet(name + i, OBJPROP_RAY, false); 
      if (series[i-1]  >= 0){
         ObjectSet(name + i, OBJPROP_COLOR, clra);
      }else{
         ObjectSet(name + i, OBJPROP_COLOR, clrb);
      }
   }
   i=len+1;
   ObjectCreate(name + i, OBJ_TREND, 0, 0, 0);
   ObjectSet(name + i, OBJPROP_TIME1, Time[0]);
   ObjectSet(name + i, OBJPROP_TIME2, Time[len]);
   ObjectSet(name + i, OBJPROP_PRICE1, zero+stddev);
   ObjectSet(name + i, OBJPROP_PRICE2, zero+stddev);
   ObjectSet(name + i, OBJPROP_RAY, false); 
   ObjectSet(name + i, OBJPROP_COLOR, Red);
   ObjectSet(name + i, OBJPROP_STYLE, STYLE_SOLID);
   i=len+2;
   ObjectCreate(name + i, OBJ_TREND, 0, 0, 0);
   ObjectSet(name + i, OBJPROP_TIME1, Time[0]);
   ObjectSet(name + i, OBJPROP_TIME2, Time[len]);
   ObjectSet(name + i, OBJPROP_PRICE1, zero-stddev);
   ObjectSet(name + i, OBJPROP_PRICE2, zero-stddev);
   ObjectSet(name + i, OBJPROP_RAY, false); 
   ObjectSet(name + i, OBJPROP_COLOR, Red);
   ObjectSet(name + i, OBJPROP_STYLE, STYLE_SOLID);
   i=len+3;
   ObjectCreate(name + i, OBJ_TREND, 0, 0, 0);
   ObjectSet(name + i, OBJPROP_TIME1, Time[0]);
   ObjectSet(name + i, OBJPROP_TIME2, Time[len]);
   ObjectSet(name + i, OBJPROP_PRICE1, zero+(2*stddev));
   ObjectSet(name + i, OBJPROP_PRICE2, zero+(2*stddev));
   ObjectSet(name + i, OBJPROP_RAY, false); 
   ObjectSet(name + i, OBJPROP_COLOR, Red);
   ObjectSet(name + i, OBJPROP_STYLE, STYLE_SOLID);
   i=len+4;
   ObjectCreate(name + i, OBJ_TREND, 0, 0, 0);
   ObjectSet(name + i, OBJPROP_TIME1, Time[0]);
   ObjectSet(name + i, OBJPROP_TIME2, Time[len]);
   ObjectSet(name + i, OBJPROP_PRICE1, zero-(2*stddev));
   ObjectSet(name + i, OBJPROP_PRICE2, zero-(2*stddev));
   ObjectSet(name + i, OBJPROP_RAY, false); 
   ObjectSet(name + i, OBJPROP_COLOR, Red);
   ObjectSet(name + i, OBJPROP_STYLE, STYLE_SOLID);
   i=len+5;
   ObjectCreate(name + i, OBJ_TREND, 0, 0, 0);
   ObjectSet(name + i, OBJPROP_TIME1, Time[0]);
   ObjectSet(name + i, OBJPROP_TIME2, Time[len]);
   ObjectSet(name + i, OBJPROP_PRICE1, zero-(3*stddev));
   ObjectSet(name + i, OBJPROP_PRICE2, zero-(3*stddev));
   ObjectSet(name + i, OBJPROP_RAY, false); 
   ObjectSet(name + i, OBJPROP_COLOR, Red);
   ObjectSet(name + i, OBJPROP_STYLE, STYLE_SOLID);
   i=len+6;
   ObjectCreate(name + i, OBJ_TREND, 0, 0, 0);
   ObjectSet(name + i, OBJPROP_TIME1, Time[0]);
   ObjectSet(name + i, OBJPROP_TIME2, Time[len]);
   ObjectSet(name + i, OBJPROP_PRICE1, zero+(3*stddev));
   ObjectSet(name + i, OBJPROP_PRICE2, zero+(3*stddev));
   ObjectSet(name + i, OBJPROP_RAY, false); 
   ObjectSet(name + i, OBJPROP_COLOR, Red);
   ObjectSet(name + i, OBJPROP_STYLE, STYLE_SOLID);
}*/

void plotRemove(string name, int len=0){
   int i;
   if (len == 0){
      len = Bars;
   }
   for (i=0; i<len; i++){
      ObjectDelete(name + i);
   }
}

bool crossedValue(double value, double level){
   static double old_value = 0;
   bool res = false;
   if (old_value != 0){
      if (value >= level && old_value < level){
         res = true;
      }
      if (value <= level && old_value > level){
         res = true;
      }
   }
   old_value = value;
   return(res);
}

double PointValueFor1Lot(string symbol)
//+------------------------------------------------------------------+
{
  // PtVal = TickValue * Point / TickSize;
  double result = MarketInfo(symbol,MODE_TICKVALUE)*MarketInfo(symbol,MODE_POINT)/MarketInfo(symbol,MODE_TICKSIZE) ;
  if(Digits == 5 || Digits == 3)
  {   
      result = result /10;
  }
  return ( result );
}

string AlltrimSpacesOnly(string s)//normal Metatrader functions behaviour
   {
   string r;
   r=StringTrimLeft(StringTrimRight(s));
   return(r);
   }
   
double ConvertCurrency(double pips,string contract,string currency,double forceprice,string &errormsg)
  {
  errormsg="OK";
  double res=0;
  double initpoints;
  string woncrrcy,crrcytest,final,appendix;
  int poscr=1;
  double pr;
  contract=AlltrimSpacesOnly(contract);
  currency=AlltrimSpacesOnly(currency);
  bool ctex=ContractExists(contract);
  if (ctex==false)
     {
     errormsg="INVALID CONTRACT.";
     return(res);
     }
  woncrrcy=SubstrBetween(contract,3,5);
  appendix="";
  if (StringLen(contract)>6)
     {
     appendix=SubstrBetween(contract,6,StringLen(contract));    
     }
  if (woncrrcy==currency)
     {     
     res=pips;
     return(res);
     }
  crrcytest=currency+woncrrcy;
  poscr=1;  
  if (ContractExists(StringConcatenate(crrcytest,appendix))==true)     
     final=StringConcatenate(crrcytest,appendix);
  else
     {
     crrcytest=StringConcatenate(woncrrcy,currency);
     poscr=2;
     if (ContractExists(StringConcatenate(crrcytest,appendix))==true)
        final=StringConcatenate(crrcytest,appendix);
     else
        {
        errormsg="CONVERSION IMPOSSIBLE."; // still, could be tried cascade conversions...
        return(res);
        }
     } 
  if (forceprice==0)
     {
     if (poscr==1)
        res=MarketInfo(contract,MODE_POINT)/MarketInfo(final,MODE_POINT)*pips/MarketInfo(final,MODE_ASK);
     else
        res=MarketInfo(contract,MODE_POINT)/MarketInfo(final,MODE_POINT)*pips*MarketInfo(final,MODE_BID);
     }       
  else
     {
     if (poscr==1)
        res=MarketInfo(contract,MODE_POINT)/MarketInfo(final,MODE_POINT)*pips/forceprice;
     else
        res=MarketInfo(contract,MODE_POINT)/MarketInfo(final,MODE_POINT)*pips*forceprice;
     }  
  return(res);
  }
  
bool ContractExists(string symbol)
  {
  int Gle;
  double data;
  bool res;
  data=MarketInfo(symbol,MODE_POINT);
  Gle=GetLastError();
  if (Gle!=ERR_UNKNOWN_SYMBOL)
     res=true;
  return(res);
  }
  
string SubstrBetween(string stri,int p1,int p2)
   {
   string res="";
   if (p2<p1||p1>StringLen(stri))
      return(res);
   if (p2>StringLen(stri))
      p2=StringLen(stri);
   for (int k=p1;k<=p2;k++)
      {
      res=StringConcatenate(res,StringElement(stri,k));
      }
   return(res);
   }
   
string StringElement(string s,int pos)
   {
   int g=0;
   string empty="";
   string given="x";
   if (pos<0||pos>StringLen(s)-1)
      return(empty);
   else
      {
      g=StringGetChar(s,pos);
      given=StringSetChar(given,0,g);
      return(given);   
      }
   }

bool ConditionalGlobalVariableSet(string gvar, double pval, double alpha, double sdhat, double sd, double q)
{
   bool retBln=true;
   //--- There are THREE (3) conditions to fulfil
   //       (1) |sdhat| > sd * q    where sd <- sd(resid(model)) and model <- lm(y ~ x)
   //       (2) pval <= alpha       where pval <- adf.test(sprd, alternative='stationary', k=0)$p.value
   //       (3) pval != 0
   if( (sdhat > sd * q) && (pval <= alpha) && (pval != 0) )
      GlobalVariableSet( gvar, NormalizeDouble(q-1, 2) );
   else if( (sdhat < -sd * q) && (pval <= alpha) && (pval != 0) )
      GlobalVariableSet( gvar, NormalizeDouble(1-q, 2) );
   else
      retBln=false;
   return( retBln );
}
   
/**
* place a market sell with stop loss, target, magic and comment
* keeps trying in an infinite loop until the position is open.
*/
int sell(string symbol, double lots, double sl, double tp, int magic=42, string comment=""){
   int ticket;
   if (!IS_ECN_BROKER){
      return(orderSendReliable(symbol, OP_SELL, lots, MarketInfo(symbol,MODE_BID), 100, sl, tp, comment, magic, 0, CLR_SELL_ARROW));
   }else{
      ticket = orderSendReliable(symbol, OP_SELL, lots, MarketInfo(symbol,MODE_BID), 100, 0, 0, comment, magic, 0, CLR_SELL_ARROW);
      if (sl + tp > 0){
         orderModifyReliable(ticket, 0, sl, tp, 0);
      }
      return(ticket);
   }
}

/**
* place a market buy with stop loss, target, magic and Comment
* keeps trying in an infinite loop until the position is open.
*/
int buy(string symbol, double lots, double sl, double tp, int magic=42, string comment=""){
   int ticket;
   if (!IS_ECN_BROKER){
      return(orderSendReliable(symbol, OP_BUY, lots, MarketInfo(symbol,MODE_ASK), 100, sl, tp, comment, magic, 0, CLR_BUY_ARROW));
   }else{
      ticket = orderSendReliable(symbol, OP_BUY, lots, MarketInfo(symbol,MODE_ASK), 100, 0, 0, comment, magic, 0, CLR_BUY_ARROW);
      if (sl + tp > 0){
         orderModifyReliable(ticket, 0, sl, tp, 0);
      }
      return(ticket);
   }
}

string label(string name, int x, int y, int corner, string text, color clr=Gray){
   if (!IsOptimization()){
      if (name==""){
         name = "label_" + Time[0];
      }   
      if (ObjectFind(name) == -1){
         ObjectCreate(name, OBJ_LABEL, 0, 0, 0);
      }
      ObjectSet(name, OBJPROP_COLOR, clr);
      ObjectSet(name, OBJPROP_CORNER, corner);
      ObjectSet(name, OBJPROP_XDISTANCE, x);
      ObjectSet(name, OBJPROP_YDISTANCE, y);   
      ObjectSetText(name, text);
   }
   return(name);
}

int orderSendReliable(
   string symbol, 
   int cmd, 
   double volume, 
   double price, 
   int slippage, 
   double stoploss,
   double takeprofit,
   string comment="",
   int magic=0,
   datetime expiration=0,
   color arrow_color=CLR_NONE
){
   int ticket;
   int err;
//--- Assert 5: Init OrderSelect #4
   int total = GhostOrdersTotal();
   int aCount;
   GhostInitSelect(true,0,SELECT_BY_POS,MODE_TRADES);
   for(int cnt=0; cnt<total; cnt++){
      if( GhostOrderSelect(cnt, SELECT_BY_POS, MODE_TRADES) ) aCount ++;
   }
//--- Assert 1: Free OrderSelect #4
   GhostFreeSelect(false);
   if( aCount >= MaxAccountTrades ) return(-1);
   
   Print("orderSendReliable(" 
      + symbol + "," 
      + cmd + "," 
      + volume + "," 
      + price + "," 
      + slippage + "," 
      + stoploss + ","
      + takeprofit + ","
      + comment + ","
      + magic + ","
      + expiration + ","
      + arrow_color + ")");
      
   while(true){
      if (IsStopped()){
         Print("orderSendReliable(): Trading is stopped!");
         return(-1);
      }
      RefreshRates();
      if (cmd == OP_BUY){
         price = MarketInfo(symbol,MODE_ASK);
      }
      if (cmd == OP_SELL){
         price = MarketInfo(symbol,MODE_BID);
      }
      if (!IsTradeContextBusy()){
         ticket = GhostOrderSend(
            symbol,
            cmd,
            volume,
            NormalizeDouble(price, MarketInfo(symbol, MODE_DIGITS)), 
            slippage,
            NormalizeDouble(stoploss, MarketInfo(symbol, MODE_DIGITS)),
            NormalizeDouble(takeprofit, MarketInfo(symbol, MODE_DIGITS)),
            comment,
            magic,
            expiration,
            arrow_color
         );
         if (ticket > 0){
            Print("orderSendReliable(): Success! Ticket: " + ticket);
            return(ticket); // the normal exit
         }
      
         err = GetLastError();
         if (isTemporaryError(err)){
            Print("orderSendReliable(): Temporary Error: " + err + " " + ErrorDescription(err) + ". waiting.");
         }else{
            Print("orderSendReliable(): Permanent Error: " + err + " " + ErrorDescription(err) + ". giving up.");
            return(-1);
         }
      }else{
         Print("orderSendReliable(): Must wait for trade context");
      }
      Sleep(MathRand()/10);
   }
}

/**
* orderModifyReliable() improved OrderModify()
*/
bool orderModifyReliable(
   int ticket,
   double price,
   double stoploss,
   double takeprofit,
   datetime expiration,
   color arrow_color=CLR_NONE
){
   bool success;
   int err;
   Print("OrderModifyReliable(" + ticket + "," + price + "," + stoploss + "," + takeprofit + "," + expiration + "," + arrow_color + ")");
   while (True){
      while (IsTradeContextBusy()){
         Print("OrderModifyReliable(): Waiting for trade context.");
         Sleep(MathRand()/10);
      }
      success = GhostOrderModify(
          ticket,
          NormalizeDouble(price, Digits),
          NormalizeDouble(stoploss, Digits),
          NormalizeDouble(takeprofit, Digits),
          expiration,
          arrow_color);
      
      if (success){
         Print("OrderModifyReliable(): Success!");
         return(True);
      }
      
      err = GetLastError();
      if (isTemporaryError(err)){
         Print("orderModifyReliable(): Temporary Error: " + err + " " + ErrorDescription(err) + ". waiting.");
      }else{
         Print("orderModifyReliable(): Permanent Error: " + err + " " + ErrorDescription(err) + ". giving up.");
         return(false);
      }
      Sleep(MathRand()/10);
   }
}

bool isTemporaryError(int error){
   return(
      error == ERR_NO_ERROR ||
      error == ERR_COMMON_ERROR ||
      error == ERR_SERVER_BUSY ||
      error == ERR_NO_CONNECTION ||
      error == ERR_MARKET_CLOSED ||
      error == ERR_PRICE_CHANGED ||
      error == ERR_INVALID_PRICE ||  //happens sometimes
      error == ERR_OFF_QUOTES ||
      error == ERR_BROKER_BUSY ||
      error == ERR_REQUOTE ||
      error == ERR_TRADE_TIMEOUT ||
      error == ERR_TRADE_CONTEXT_BUSY
    );
}

//|-----------------------------------------------------------------------------------------|
//|                                     C O M M E N T                                       |
//|-----------------------------------------------------------------------------------------|
void EaDebugPrint(int dbg, string fn, string msg)
{
   static int noStackCount;
   if(EaViewDebug>=dbg)
   {
      if(dbg>=2 && EaViewDebugNoStack>0)
      {
         if( MathMod(noStackCount,EaViewDebugNoStack) <= EaViewDebugNoStackEnd )
            Print(EaViewDebug,"-",noStackCount,":",fn,"(): ",msg);
            
         noStackCount ++;
      }
      else
         Print(EaViewDebug,":",fn,"(): ",msg);
   }
}
string EaDebugInt(string key, int val)
{
   return( StringConcatenate(";",key,"=",val) );
}
string EaDebugDbl(string key, double val, int dgt=5)
{
   return( StringConcatenate(";",key,"=",NormalizeDouble(val,dgt)) );
}
string EaDebugStr(string key, string val)
{
   return( StringConcatenate(";",key,"=\"",val,"\"") );
}
string EaDebugBln(string key, bool val)
{
   string valType;
   if( val )   valType="true";
   else        valType="false";
   return( StringConcatenate(";",key,"=",valType) );
}

//|-----------------------------------------------------------------------------------------|
//|                       E N D   O F   E X P E R T   A D V I S O R                         |
//|-----------------------------------------------------------------------------------------|