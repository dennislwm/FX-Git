//+-----------------------------------------------------------------------------------------+
//|                                                                          plusturtle.mqh |
//|                                                            Copyright © 2011, Dennis Lee |
//| Assert History                                                                          |
//| 1.01    Fixed BigValue for case 4 (Base to Counter) where return value should be the    |
//|            inverse of the value. Also, if CounterCurrency is JPY, then multiply by 100, |
//|            because one pip value is two decimal (0.01) instead of four decimal (0.0001).|
//| 1.00    Calculate Big Value, i.e. tick value in deposit currency.                       |
//|         E.g. For symbol=AUDUSD and AccountCurrency=SGD, tick value is USDSGD=1.30       |
//+-----------------------------------------------------------------------------------------+
#property copyright "Copyright © 2011, Dennis Lee"
#include <stderror.mqh>
#include <stdlib.mqh>

//|-----------------------------------------------------------------------------------------|
//|                 P L U S T U R T L E   E X T E R N A L   V A R I A B L E S               |
//|-----------------------------------------------------------------------------------------|
extern bool     TurtleCustomAccount=false;
extern string   TurtleCustomAccountCurrency="USD";
extern int      TurtleDebug=0;

//|-----------------------------------------------------------------------------------------|
//|                           I N T E R N A L   V A R I A B L E S                           |
//|-----------------------------------------------------------------------------------------|
string   TurtleName="PlusTurtle";
string   TurtleVer="1.01";
string   TurtleSymbolBase;
string   TurtleSymbolCounter;
string   TurtlePostFix;

//|-----------------------------------------------------------------------------------------|
//|                             I N I T I A L I Z A T I O N                                 |
//|-----------------------------------------------------------------------------------------|
void TurtleInit()
{
// Check user values
   if(TurtleCustomAccount==true) if(TurtleCustomAccountCurrency=="")
   {
      TurtleCustomAccountCurrency=AccountCurrency();
      Alert("TurtleCustomAccount has not been set (User has to set to a single currency, e.g. USD). TurtleCustomAccount has been set to default account currency.");
   }
   SymbolInfoVerbose(Symbol());
   return(0);
}

//|-----------------------------------------------------------------------------------------|
//|                          P U B L I C   F U N C T I O N S                                |
//|-----------------------------------------------------------------------------------------|
double TurtleBigValue(string sym)
{
   switch(CalcSymbolType(sym)) // Determine the tickvalue for the financial instrument based on the instrument's SymbolType (major, cross, etc)
      {
      case 1   :  return(MarketInfo(sym,MODE_POINT)*MarketInfo(sym,MODE_LOTSIZE)/MarketInfo(sym,MODE_BID));
                  break;
      case 2   :  return(MarketInfo(sym,MODE_POINT)*MarketInfo(sym,MODE_LOTSIZE)*10);
                  break;
      case 3   :  return(MarketInfo(BasePairForCross(sym),MODE_BID));
                  break;
      case 4   :  if( TurtleSymbolCounter=="JPY" )
                     return( 100/MarketInfo(CounterPairForCross(sym),MODE_BID) );
                  else
                     return( 1/MarketInfo(CounterPairForCross(sym),MODE_BID) );
                  break;
      case 5   :  return(MarketInfo(CounterPairForCross(sym),MODE_BID));
                  break;
      case 6   :  return(MarketInfo(BasePairForCross(sym),MODE_BID));
                  break;
      default  :  return(-1);
      }
}

//|-----------------------------------------------------------------------------------------|
//|                                     C O M M E N T                                       |
//|-----------------------------------------------------------------------------------------|

string TurtleComment(string cmt="")
{
   string strtmp = cmt+"  -->"+TurtleName+" "+TurtleVer+"<--";

   strtmp = strtmp + "\n    AccountCurrency=" + AcctCurcy();
   strtmp = strtmp + "\n    BigValue=" + DoubleToStr(TurtleBigValue(Symbol()),6);

   switch(CalcSymbolType(Symbol())) // Determine the tickvalue for the financial instrument based on the instrument's SymbolType (major, cross, etc)
   {
      case 1   :  strtmp = strtmp + " (Tick value in the deposit currency - base)"; 
                  break;
      case 2   :  strtmp = strtmp + " (Tick value in the deposit currency - counter)"; 
                  break;
      case 3   :  strtmp = strtmp + " (Tick value in the deposit currency - " + BasePairForCross(Symbol()) + " is Base to Base)"; 
                  break;
      case 4   :  strtmp = strtmp + " (Tick value in the deposit currency - " + CounterPairForCross(Symbol()) + " is Base to Counter)"; 
                  break;
      case 5   :  strtmp = strtmp + " (Tick value in the deposit currency - " + CounterPairForCross(Symbol()) + " is Counter to Counter)"; 
                  break;
      case 6   :  strtmp = strtmp + " (Tick value in the deposit currency - " + BasePairForCross(Symbol()) + " is Counter to Base)"; 
                  break;
      default  :  strtmp = strtmp + " (Error encountered in calculating big value of pair " + Symbol() + ")"; // The expression did not generate a case value
   }

      strtmp = strtmp+"\n";
   return(strtmp);
}


//|-----------------------------------------------------------------------------------------|
//|                         P R I V A T E   F U N C T I O N S                               |
//|-----------------------------------------------------------------------------------------|
string AcctCurcy()
{
    if(TurtleCustomAccount==true) return(TurtleCustomAccountCurrency);
    else return(AccountCurrency());
}

int CalcSymbolType(string sym)
{  
   int   CalculatedSymbolType=-1;
   string   SymbolBase="",SymbolCounter="",postfix="";
   
   SymbolBase=StringSubstr(sym,0,3);
   SymbolCounter=StringSubstr(sym,3,3);
   postfix=StringSubstr(sym,6);
   
   if(SymbolBase==AcctCurcy()) return(1);
   if(SymbolCounter==AcctCurcy()) return(2);
   
// Determine if AcctCurcy() is the COUNTER currency or the BASE currency for the COUNTER currency forming sym
   if(MarketInfo(StringConcatenate(AcctCurcy(),SymbolCounter,postfix),MODE_LOTSIZE)>0)
   {
      CalculatedSymbolType=4; // SymbolType can also be 3 but this will be determined later when the Base pair is identified
   }
   else if(MarketInfo(StringConcatenate(SymbolCounter,AcctCurcy(),postfix),MODE_LOTSIZE)>0)
   {
      CalculatedSymbolType=5;
   }
      
// Determine if AcctCurcy() is the COUNTER currency or the BASE currency for the BASE currency forming sym
   if(CalculatedSymbolType==-1)
      if(MarketInfo(StringConcatenate(AcctCurcy(),SymbolBase,postfix),MODE_LOTSIZE)>0)
      {
         CalculatedSymbolType=3;
      }
      else if(MarketInfo(StringConcatenate(SymbolBase,AcctCurcy(),postfix),MODE_LOTSIZE)>0)
      {
         CalculatedSymbolType=6;
      }
   
   return(CalculatedSymbolType);
}

string BasePairForCross(string sym)
{
   string   SymbolBase="",SymbolCounter="",postfix="",CalculatedBasePairForCross="";
   
   SymbolBase=StringSubstr(sym,0,3);
   SymbolCounter=StringSubstr(sym,3,3);
   postfix=StringSubstr(sym,6);
   
   switch(CalcSymbolType(sym)) // Determine if AcctCurcy() is the COUNTER currency or the BASE currency for the BASE currency forming sym
   {
      case 1   :  break;
      case 2   :  break;
      case 3   :  CalculatedBasePairForCross=StringConcatenate(AcctCurcy(),SymbolBase,postfix); break;
      case 4   :  CalculatedBasePairForCross=StringConcatenate(SymbolBase,AcctCurcy(),postfix); break;
      case 5   :  CalculatedBasePairForCross=StringConcatenate(SymbolBase,AcctCurcy(),postfix); break;
      case 6   :  CalculatedBasePairForCross=StringConcatenate(SymbolBase,AcctCurcy(),postfix); break;
      default  :  break;
   }
   
   return(CalculatedBasePairForCross);
   
}

string CounterPairForCross(string sym)
{
   string   SymbolBase="",SymbolCounter="",postfix="",CalculatedCounterPairForCross="";
   
   SymbolBase=StringSubstr(sym,0,3);
   SymbolCounter=StringSubstr(sym,3,3);
   postfix=StringSubstr(sym,6);
   
   switch(CalcSymbolType(sym)) // Determine if AcctCurcy() is the COUNTER currency or the BASE currency for the COUNTER currency forming sym
      {
      case 1   :  break;
      case 2   :  break;
      case 3   :  CalculatedCounterPairForCross=StringConcatenate(AcctCurcy(),SymbolCounter,postfix); break;
      case 4   :  CalculatedCounterPairForCross=StringConcatenate(AcctCurcy(),SymbolCounter,postfix); break;
      case 5   :  CalculatedCounterPairForCross=StringConcatenate(SymbolCounter,AcctCurcy(),postfix); break;
      case 6   :  CalculatedCounterPairForCross=StringConcatenate(SymbolCounter,AcctCurcy(),postfix); break;
      default  :  break;
      }
   
   return(CalculatedCounterPairForCross);
   
}

int CalcSymbolLeverage(string sym)
{
   int      CalculatedLeverage=-1;
   double   MarginReq=-1;
   string   CalculatedBasePairForCross="";
   
   if(MarketInfo(sym,MODE_MARGINREQUIRED)!=0) MarginReq=MarketInfo(sym,MODE_MARGINREQUIRED);
   
   switch(CalcSymbolType(sym)) // Determine the leverage for the financial instrument based on the instrument's SymbolType (major, cross, etc)
      {
      case 1   :  CalculatedLeverage=NormalizeDouble(MarketInfo(sym,MODE_LOTSIZE)/MarginReq,2); 
                  break;
      case 2   :  CalculatedLeverage=NormalizeDouble(MarketInfo(sym,MODE_ASK)*MarketInfo(sym,MODE_LOTSIZE)/MarginReq,2); 
                  break;
      case 3   :  CalculatedLeverage=NormalizeDouble(2*MarketInfo(sym,MODE_LOTSIZE)/
                     ((MarketInfo(BasePairForCross(sym),MODE_BID)+MarketInfo(BasePairForCross(sym),MODE_ASK))*MarginReq),2); 
                  break;
      case 4   :  CalculatedLeverage=NormalizeDouble(MarketInfo(sym,MODE_LOTSIZE)*
                     (MarketInfo(CounterPairForCross(sym),MODE_BID)+MarketInfo(CounterPairForCross(sym),MODE_ASK))/(2*MarginReq),2); 
                  break;
      case 5   :  CalculatedLeverage=NormalizeDouble(MarketInfo(sym,MODE_LOTSIZE)*
                     (MarketInfo(CounterPairForCross(sym),MODE_BID)+MarketInfo(CounterPairForCross(sym),MODE_ASK))/(2*MarginReq),2); 
                  break;
      case 6   :  CalculatedLeverage=NormalizeDouble(2*MarketInfo(sym,MODE_LOTSIZE)/
                     ((MarketInfo(BasePairForCross(sym),MODE_BID)+MarketInfo(BasePairForCross(sym),MODE_ASK))*MarginReq),2); 
                  break;
      default  :  break;
      }
   
   return(CalculatedLeverage);
}

//|-----------------------------------------------------------------------------------------|
//|                         V E R B O S E   F U N C T I O N S                               |
//|-----------------------------------------------------------------------------------------|

void SymbolInfoVerbose(string sym)
{
   double   CalculatedLeverage=0;
   int      CalculatedSymbolType=0,ticket=0,LotSizeDigits=0,CurrentOrderType=0;

   CalculatedSymbolType=CalcSymbolType(sym);
      
   TurtleSymbolBase=StringSubstr(sym,0,3);
   TurtleSymbolCounter=StringSubstr(sym,3,3);
   TurtlePostFix=StringSubstr(sym,6);
   
   Print("Current Symbol = ",sym,", Bid = ",DoubleToStr(MarketInfo(sym,MODE_BID),MarketInfo(sym,MODE_DIGITS))," and Ask = ",DoubleToStr(MarketInfo(sym,MODE_ASK),MarketInfo(sym,MODE_DIGITS)));
   CalcSymbolTypeVerbose(sym, CalculatedSymbolType);
   Print("Max allowed account leverage is ",AccountLeverage(),":1");

   BrokerInfoVerbose(sym ,CalculatedSymbolType);
   
   LotSizeDigits=-MathRound(MathLog(MarketInfo(sym,MODE_LOTSTEP))/MathLog(10.)); // Number of digits after decimal point for the Lot for the current broker, like Digits for symbol prices
   Print("Digits for lotsize = ",LotSizeDigits);
   
}

void BrokerInfoVerbose(string sym, int CalculatedSymbolType)
{
   Print("MODE_POINT = ",DoubleToStr(MarketInfo(sym,MODE_POINT),MarketInfo(sym,MODE_DIGITS))," (Point size in the quote currency)");
   Print("MODE_TICKSIZE = ",DoubleToStr(MarketInfo(sym,MODE_TICKSIZE),MarketInfo(sym,MODE_DIGITS))," (Tick size in the quote currency)");
   Print("MODE_TICKVALUE = ",DoubleToStr(MarketInfo(sym,MODE_TICKVALUE),6)," (Tick value in the deposit currency)");
   Print("MODE_DIGITS = ",MarketInfo(sym,MODE_DIGITS)," (Count of digits after decimal point in the symbol prices)");
   Print("MODE_SPREAD = ",MarketInfo(sym,MODE_SPREAD)," (Spread value in points)");
   Print("MODE_STOPLEVEL = ",MarketInfo(sym,MODE_STOPLEVEL)," (Stop level in points)");
   Print("MODE_LOTSIZE = ",MarketInfo(sym,MODE_LOTSIZE)," (Lot size in the Base currency)");
   Print("MODE_MINLOT = ",MarketInfo(sym,MODE_MINLOT)," (Minimum permitted amount of a lot)");
   Print("MODE_LOTSTEP = ",MarketInfo(sym,MODE_LOTSTEP)," (Step for changing lots)");
   Print("MODE_MARGINREQUIRED = ",MarketInfo(sym,MODE_MARGINREQUIRED)," (Free margin required to open 1 lot for buying)");
}

void CalcSymbolTypeVerbose(string sym, int CalculatedSymbolType)
{
   string SymbolBase="",SymbolCounter="",postfix="";
   
   Print("Account currency is ", AcctCurcy()," and Current Symbol = ",sym);

   if(CalculatedSymbolType==-1) 
   {
      Print("Error occurred while within SymbolTypeVerbose(), calculated SymbolType = ",CalculatedSymbolType);
      return;
   }
   
   SymbolBase=StringSubstr(sym,0,3);
   SymbolCounter=StringSubstr(sym,3,3);
   postfix=StringSubstr(sym,6);

   if(CalculatedSymbolType==1 || CalculatedSymbolType==2) 
      Print("Base currency is ",SymbolBase," and the Counter currency is ",SymbolCounter," (this pair is a major)");
   else
   {
      Print("Base currency is ",SymbolBase," and the Counter currency is ",SymbolCounter," (this pair is a cross)");

   // Determine if AcctCurcy() is the COUNTER currency or the BASE currency for the COUNTER currency forming sym
      if(CalculatedSymbolType==4)
      {
         Print(AcctCurcy()," is the Base currency to the Counter currency for this cross, the CounterPair is ",CounterPairForCross(sym),
         ", Bid = ",DoubleToStr(MarketInfo(CounterPairForCross(sym),MODE_BID),MarketInfo(CounterPairForCross(sym),MODE_DIGITS)),
         " and Ask = ",DoubleToStr(MarketInfo(CounterPairForCross(sym),MODE_ASK),MarketInfo(CounterPairForCross(sym),MODE_DIGITS)));
      }
      else if(CalculatedSymbolType==5)
      {
         Print(AcctCurcy()," is the Counter currency to the Counter currency for this cross, the CounterPair is ",CounterPairForCross(sym),
         ", Bid = ",DoubleToStr(MarketInfo(CounterPairForCross(sym),MODE_BID),MarketInfo(CounterPairForCross(sym),MODE_DIGITS)),
         " and Ask = ",DoubleToStr(MarketInfo(CounterPairForCross(sym),MODE_ASK),MarketInfo(CounterPairForCross(sym),MODE_DIGITS)));
      }
      
   // Determine if AcctCurcy() is the COUNTER currency or the BASE currency for the BASE currency forming sym
      if(CalculatedSymbolType==3)
      {
         Print(AcctCurcy()," is the Base currency to the Base currency for this cross, the BasePair is ",BasePairForCross(sym),
         ", Bid = ",DoubleToStr(MarketInfo(BasePairForCross(sym),MODE_BID),MarketInfo(BasePairForCross(sym),MODE_DIGITS)),
         " and Ask = ",DoubleToStr(MarketInfo(BasePairForCross(sym),MODE_ASK),MarketInfo(BasePairForCross(sym),MODE_DIGITS)));
      }
      else if(CalculatedSymbolType==6)
      {
         Print(AcctCurcy()," is the Counter currency to the Base currency for this cross, the BasePair is ",BasePairForCross(sym),
         ", Bid = ",DoubleToStr(MarketInfo(BasePairForCross(sym),MODE_BID),MarketInfo(BasePairForCross(sym),MODE_DIGITS)),
         " and Ask = ",DoubleToStr(MarketInfo(BasePairForCross(sym),MODE_ASK),MarketInfo(BasePairForCross(sym),MODE_DIGITS)));
      }
   }
   Print("CalcSymbolType() = ",CalculatedSymbolType);
   
}

void CalcSymbolLeverageVerbose(string sym, int CalculatedLeverage)
{
   double CalculatedMarginRequiredLong=0,CalculatedMarginRequiredShort=0;
   
   if(CalculatedLeverage>0) switch(CalcSymbolType(sym)) // Determine the margin required to open 1 lot position for the financial instrument based on the instrument's SymbolType (major, cross, etc)
      {
      case 1   :  CalculatedMarginRequiredLong=NormalizeDouble(MarketInfo(sym,MODE_LOTSIZE)/CalculatedLeverage,2);
                  Print("Calculated MARGINREQUIRED = ",CalculatedMarginRequiredLong," (Free margin required to open 1 lot for buying)");
                  Print("Calculated Leverage = ",CalculatedLeverage,":1 for this specific financial instrument (",sym,")"); 
                  break;
      case 2   :  CalculatedMarginRequiredLong=NormalizeDouble(MarketInfo(sym,MODE_ASK)*MarketInfo(sym,MODE_LOTSIZE)/CalculatedLeverage,2);
                  CalculatedMarginRequiredShort=NormalizeDouble(MarketInfo(sym,MODE_BID)*MarketInfo(sym,MODE_LOTSIZE)/CalculatedLeverage,2);
                  Print("Calculated MARGINREQUIRED = ",CalculatedMarginRequiredLong," for Buy (free margin required to open 1 lot position as long), and Calculated MARGINREQUIRED = ",CalculatedMarginRequiredShort," for Sell (free margin required to open 1 lot position as short)");
                  Print("Calculated Leverage = ",CalculatedLeverage,":1 for this specific financial instrument (",sym,")"); 
                  break;
      case 3   :  CalculatedMarginRequiredLong=NormalizeDouble(2*MarketInfo(sym,MODE_LOTSIZE)/
                     ((MarketInfo(BasePairForCross(sym),MODE_BID)+MarketInfo(BasePairForCross(sym),MODE_ASK))*CalculatedLeverage),2);
                  Print("Calculated MARGINREQUIRED = ",CalculatedMarginRequiredLong," (Free margin required to open 1 lot for buying)");
                  Print("Calculated Leverage = ",CalculatedLeverage,":1 for this specific financial instrument (",sym,")"); 
                  break;
      case 4   :  CalculatedMarginRequiredLong=NormalizeDouble(MarketInfo(sym,MODE_LOTSIZE)*
                     (MarketInfo(CounterPairForCross(sym),MODE_BID)+MarketInfo(CounterPairForCross(sym),MODE_ASK))/(2*CalculatedLeverage),2);
                  Print("Calculated MARGINREQUIRED = ",CalculatedMarginRequiredLong," (Free margin required to open 1 lot for buying)");
                  Print("Calculated Leverage = ",CalculatedLeverage,":1 for this specific financial instrument (",sym,")"); 
                  break;
      case 5   :  CalculatedMarginRequiredLong=NormalizeDouble(MarketInfo(sym,MODE_LOTSIZE)*
                     (MarketInfo(CounterPairForCross(sym),MODE_BID)+MarketInfo(CounterPairForCross(sym),MODE_ASK))/(2*CalculatedLeverage),2);
                  Print("Calculated MARGINREQUIRED = ",CalculatedMarginRequiredLong," (Free margin required to open 1 lot for buying)");
                  Print("Calculated Leverage = ",CalculatedLeverage,":1 for this specific financial instrument (",sym,")"); 
                  break;
      case 6   :  CalculatedMarginRequiredLong=NormalizeDouble(2*MarketInfo(sym,MODE_LOTSIZE)/
                     ((MarketInfo(BasePairForCross(sym),MODE_BID)+MarketInfo(BasePairForCross(sym),MODE_ASK))*CalculatedLeverage),2);
                  Print("Calculated MARGINREQUIRED = ",CalculatedMarginRequiredLong," (Free margin required to open 1 lot for buying)");
                  Print("Calculated Leverage = ",CalculatedLeverage,":1 for this specific financial instrument (",sym,")"); 
                  break;
                  
      default  :  Print("Error encountered in the SWITCH routine for calculating required margin for financial instrument ",sym); // The expression did not generate a case value
      }
}
   
//|-----------------------------------------------------------------------------------------|
//|                     E N D   O F   E X P E R T   A D V I S O R                           |
//|-----------------------------------------------------------------------------------------|