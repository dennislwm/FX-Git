//+------------------------------------------------------------------+
//|                                  Cointegration Search Engine.mq4 |
//|                                                   © Mediator     |
//+------------------------------------------------------------------+

/** @file
* This code is released under Gnu General Public License (GPL) V3
* You know what this means. Otherwise don't use it or buy a license.
*/

#property copyright "Copyright © 2011 Mediator"
#property link      "mediator@online.de"

//#define RPATH "E:/Appz/R/R-2.12.0/bin/i386/Rterm.exe --no-save"
#define RDEBUG 1

#include <mt4R.mqh>                // <-- its on forexfactory. need version 1.3
//#include <common_functions.mqh> 
#include <stderror.mqh>  
#include <stdlib.mqh> 

extern int MaxAccountTrades = 4;
extern int back_bars = 576;
extern int base_units = 1000;
extern double Lots = 0.1;
extern bool UseCoefficient = true;
extern double CoefThresh = 2;
extern bool UseADF = false;
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
extern bool UseTradeLimiter = false;
extern bool StopOpenNewOrders = false;
extern bool ReentryInsteadExit = true;
extern string info0 = "Set Spread to 0(zero) for no limiting";
extern double SpreadLimiter = 100;
 bool trend = false;
 bool Rplot = false;
 string Symbol1 = "";
 string Symbol2 = "";
 string Symbol3 = "";
 string Symbol4 = "";
 string Symbol5 = "";
 string Symbol6 = "";
 string Symbol7 = "";
 double pair1[];
double pair2[];
extern string RPATH = "I:/Programme/Appz/R-2.14.0/bin/i386/Rterm.exe --no-save";
extern color clr_spreadline = Yellow;
extern color clr_above = FireBrick;
extern color clr_below = DarkGreen;

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

int init(){
   int i;
   int x = 0;
   string Pair;
   PairArray[0]= "AUD";
   PairArray[1]= "CAD";
   PairArray[2]= "CHF";
   PairArray[3]= "EUR";
   PairArray[4]= "GBP";
   PairArray[5]= "JPY";
   PairArray[6]= "NZD";
   PairArray[7]= "USD";
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
               //Print(Pairs[x]);
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
}

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
               //Print(pairs);
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
            
            //Print(s[sp] + "|" + s[fp] + " Spread: " + pred[0]+ " StdDev: "+(2*stddev));
            }
         }
      }
   }
   time_last = Time[0];
   return(0);
}

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
   
   ArrayResize(coef, pairs);
   ArrayResize(prices, pairs);
   ArrayResize(regressors, back * pairs);
   ArrayResize(pred, back);
   Rx("rm(list=ls())");
   Ri("back", back);
   Ri("pairs", pairs);
   
   // fill the matrix of regressors
   // and then copy it over to R
   for (i=0; i<back; i++){
      for (j=0; j<pairs; j++){
         ishift = iBarShift(symb[j], 0, Time[i]);
         regressors[i * pairs + j] = iClose(symb[j], 0, ishift);
         //Print(regressors[i * pairs + j]);
      }
   }
   Rm("regressors", regressors, back, pairs);
   
      
   // do the regression
   // first we need a regressand
   if (trend){
      // we simply use a straight line that will be our ideal trend
      // note that it points downward since the history is ordered backwards
      Rd("trendslope", 0.01);
      Rx("regressand <- trendslope - trendslope * seq(1, back) / back"); 
   
   }else{
      Ri("cthis", this + 1);                       // counting starts with 1
      Rx("regressand <- regressors[, cthis]");     // use this column as regressand
      Rx("regressors[, cthis] <- rep(0, back)");   // set the column to zero in the matrix
   }
   Rx("y <- regressand");                          // stupid R will remember the variable names so we  
   Rx("x <- regressors");                          // have to be careful how we name them in the formula
   Rx("model <- lm(y ~ x)");                       // fit the model
   Rp("summary(model)");
   
   
   // get the coefficients
   //Rx("beta <- coef(model)[-1]");
   Rgv("coef(model)[-1]", coef);   // remove the first one (the constant term)
   Rx("stddev <- sd(resid(model))");
   stddev = Rgd("stddev");
   //Print(stddev);


   // convert the coefficients to usable hege ratios by multiplying
   // xxx/usd pairs with their quote. The results can then be
   // conveniently interpreted as multiples of needed Lots or Units.
   // also take care of the special case when fitting a spread 
   // instead a trend
   string s;
   for (i=0; i<pairs; i++){
      // if we fit a spread then all pairs except this one are on the other 
      // side (negative) and this one (the regressand) is 1 by definition
      if (!trend){
         if (i == this){
            coef[i] = 1;
         }else{
            coef[i] = -coef[i];
         }
      }
      
      // convert to units
     coef[i] = coef[i] * 1/ConvertCurrency(1,symb[i],"USD",iOpen(symb[i],0,0),s);
      
      
      
      // The following makes sure that if the first pair is an USD/XXX pair
      // it is normalized to 1 again and the lot sizes of the other ones 
      // instead made smaller by the same factor.
      if (!trend){
         
            coef[i] = coef[i] /ConvertCurrency(1,symb[i],"USD",iOpen(symb[i],0,0),s);
         
      }

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

   plot();   
}

void onTick(){
   int units, units1; 
   int i; 
   
   // update the last row
   if (!trend){
      prices[1] = iClose(symb[1], 0, 0);
      prices[0] = 0;
         
      
      Rv("current_others", prices);
      Rd("current_this", iClose(symb[0], 0, 0));
      Rx("regressors[1,] <- current_others");
      Rx("regressand[1] <- current_this");
   }else{
      for (i=0; i<pairs; i++){
         prices[i] = iClose(symb[i], 0, 0);
      }
      Rv("current_all", prices);
      Rx("regressors[1,] <- current_all");
   }
   
   plot();
   
   
   
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
               //Print("Close with neg. Level");
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
   
   for(int Lvl=StdDevEntryLevel+8;Lvl>=StdDevEntryLevel;Lvl--)
   {
      StddevOrders(Lvl);
      //Print("Entry check");
      
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
         //Print(s[fp]+s[sp] + " ratio: "+coefratio);
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
         double pval=ADF();
         
         if( (pred[1] > StdDevEntryLevel*stddev) && (pval<=pthresh) && (pval !=0))
         {
             GlobalVariableSet(s[fp]+s[sp],NormalizeDouble(StdDevEntryLevel-1,2));
             Print(s[fp]+s[sp] + " pval: "+pval);
         }
             
         if( (pred[1] < -StdDevEntryLevel*stddev)&& (pval<=pthresh) && (pval !=0))
         {
             GlobalVariableSet(s[fp]+s[sp],NormalizeDouble(-StdDevEntryLevel+1,2));
             Print(s[fp]+s[sp] + " pval: "+pval);
         }
      }  
   }
   if (pred[2] > ( Level * stddev) && pred[1] < ( Level * stddev)/*&& alert_time<Time[0]*/)
   {
      if( (GlobalVariableCheck(s[fp]+s[sp]) == false && GlobalVariableCheck(s[sp]+s[fp]) == false && StopOpenNewOrders == false && UseADF == false && tradecoef0 == true && tradecoef1 ==true) 
         || (Level > GlobalVariableGet(s[fp]+s[sp]) && GlobalVariableGet(s[fp]+s[sp]) > 0 && tradecoef0 == true && tradecoef1 == true) )
      {
            //Print(units0 + "-" + units1 + ":" + coef[0] + "-" + coef[1] +":"+ DoubleToStr(coefratio,2)+":"+s[fp]+s[sp]);
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
         //Print(units0 + "-" + units1 + ":" + coef[0] + "-" + coef[1] +":"+ DoubleToStr(coefratio,2)+":"+s[fp]+s[sp]);
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

int deinit(){
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
   //Checks to see if either of the currencies in the pair is already being traded twice.
   //If not, then return true to show that the pair can be traded, else return false
   
   string c1 = StringSubstr(sym, 0, 3);//First currency in the pair
   string c2 = StringSubstr(sym, 3, 3);//Second currency in the pair
   int c1open = 0, c2open = 0;
   //CanTradeThisPair = true;
   for (int cc = OrdersTotal() - 1; cc >= 0; cc--)
   {
      if (!OrderSelect(cc, SELECT_BY_POS) ) continue;
      if (OrderSymbol() != sym ) continue;
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
         return(false);   
      }//if (c1open == 1 && c2open == 1) 
   }//for (int cc = OrdersTotal() - 1; cc >= 0; cc--)

   //Got this far, so ok to trade
   return(true);
   
}//End bool IsThisPairTradable()   


double GetProfit(string cmd)
{
   int cnt;
   double AccProfit =0;
   int total=OrdersTotal();
   for(cnt=0; cnt<=total; cnt++){
      OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
      if(OrderComment() == cmd)
      {
         AccProfit = AccProfit + (OrderProfit()+OrderCommission()+OrderSwap());
         
        
      }
   }
   return(AccProfit);
}

bool closeOrders(string comment)
{
   int ticket=0;
   bool done=false;
   while (IsTradeContextBusy())
   {
      Print("closeOpenOrders(): waiting for trade context.");
      Sleep(MathRand()/10);
   }
   RefreshRates();
   
      for(int cnt=OrdersTotal(); cnt>=0; cnt--)
      {
         OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
         if(OrderComment() == comment || comment == "")
         {
            //Print(comment);
            
            if(OrderType()==OP_BUY)
            {
               double price = MarketInfo(OrderSymbol(), MODE_BID);
            } else
            {
               price = MarketInfo(OrderSymbol(), MODE_ASK);
            }
           OrderClose(OrderTicket(), OrderLots(),price,999,CLR_NONE);
            
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



void plot(){
   static int last_back;
   // predict and plot from the model
   Rx("pred <- as.vector(predict(model, newdata=data.frame(x=I(regressors))))");
   
   if (!trend){
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
   }   
   
   // make the R plot (optional)
   if (Rplot){   
      Rs("descr1", Period() + " minute close prices");
      Rs("descr2", "begin: " + TimeToStr(Time[back-1]) + " -- end: " + TimeToStr(Time[0]));
      Rs("ratios", ratios);
      
      Rx("options(device='windows')");
      if(trend){
         Rx("curve <- rev(pred)");  // it is still ordered backwards, so we reverse it now
         Rs("lbly", "combined returns");
         Rx("linea <- trendslope/back");
      }else{
         Rx("curve <- rev(regressand - pred)");
         Rs("lbly", "spread");
         Rx("linea <- 0");
      }
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
//--- DL: Works with extern MaxAccountTrades
//       When total account trades >= MaxAccountTrades
//       No new trades can be opened
   int total = OrdersTotal();
   int aCount;
   for(int cnt=0; cnt<total; cnt++){
      if( OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES) ) aCount ++;
   }
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
         ticket = OrderSend(
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
      success = OrderModify(
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