//|-----------------------------------------------------------------------------------------|
//|                                                                     NewsTrader_v5.3.mq4 |
//|                                                            Copyright © 2012, Dennis Lee |
//| Assert History                                                                          |
//| 1.00    Originated from Forex-TSD Elite member section NewsTrader_v5.3_eurusd nfp.      |
//|-----------------------------------------------------------------------------------------|
#property copyright "Copyright © 2012, Dennis Lee"
#property link      "http://finance.groups.yahoo.com/group/TrendLaboratory"

#include <WebGet.mqh>
#include <stdlib.mqh>

//---- input parameters
extern string     ExpertName       = "NewsTrader_v5.3";

extern int        Magic            =   11111;
extern int        Slippage         =       6;

extern string     Main_Parameters  = " Trade Volume & Trade Method";
extern int        CalendarID       =       4; // Calendar's ID on calendar.forex-tsd.com  
extern double     Lots             =     0.1; // Lot size
extern int        TimeGap          =       2; // Time Gap between News Time and Order Open Time in min 
extern int        OrderDuration    =      10; // Order Duratiton Time in min
extern int        ProcessTime      =       2; // Order processing Time in min
extern int        SessionEnd       =      23; // Session End Time
extern int        FridayEnd        =      22; // Session End Time in Friday
extern int        OrdersNum        =       3; // Number of pending orders from one side
extern double     PendOrdGap       =      25; // Gap for Pending Orders from current price in pips
extern double     OrdersStep       =      15; // Step between orders in pips
extern int        DelOpposite      =       0; // Switch of orders deleting: 0-off,1-on
extern int        TrailOpposite    =       1; // Trailing of Opposite Orders: 0-off,1-on
extern double     TakeProfit       =     100; // Take Profit in pips       	
extern double     TrailingStop     =       30; // Trailing Stop in pips      
extern double     InitialStop      =      50; // Initial Stop in pips 
extern double     BreakEven        =       15; // Breakeven in pips  
extern bool       DisplayLine      =   false; // Display Line Option (Visualization mode) 
extern bool       DisplayText      =   false; // Display Text Option (Visualization mode)

extern string     cFilter          = " Currency Filter ";
extern bool       USD              =    true;
extern bool       EUR              =    true;
extern bool       GBP              =    false;
extern bool       JPY              =    false;
extern bool       AUD              =    false;
extern bool       CAD              =    false;
extern bool       CHF              =    false;
extern bool       NZD              =    false;

extern string     rFilter          = " Rating Filter ";
extern int        MaxRating        =       3;
extern int        MinRating        =       3;  

extern string     MM_Parameters    = " MoneyManagement by L.Williams ";
extern bool       MM               =   true; // ÌÌ Switch
extern double     MaxRisk          =    0.04; // Risk Factor
extern double     LossMax          =       0; // Maximum Loss by 1 Lot


datetime FinTime=0;
string   sDate[1000];          // Date
string   sTime[1000];          // Time
string   sCurrency[1000];      // Currency
string   sDescription[1000];   // Description
string   sRating[1000];        // Rating
string   sActual[1000];        // Actual value
string   sForecast[1000];      // Forecast value
string   sPrevious[1000];      // Previous value
string   sImpact[1000];
datetime dt[1000];
int      BEvent=0, NewsNum, TriesNum=5;
string   CalendarName;
bool     fTime;
datetime prevTime,OpenTime=0;
int      totalPips=0, TimeZone = 0;
double   totalProfits=0;

//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
{
//---- 
   fTime = true;
   
//----
return(0);
}
  
// ---- Money Management
//---- Calculation of Position Volume
double MoneyManagement()
{
   double lot_min =MarketInfo(Symbol(),MODE_MINLOT);
   double lot_max =MarketInfo(Symbol(),MODE_MAXLOT);
   double lot_step=MarketInfo(Symbol(),MODE_LOTSTEP);
   double contract=MarketInfo(Symbol(),MODE_LOTSIZE);
   double vol;
//--- check data
   if(lot_min<0 || lot_max<=0.0 || lot_step<=0.0) 
   {
   Print("CalculateVolume: invalid MarketInfo() results [",lot_min,",",lot_max,",",lot_step,"]");
   return(0);
   }
   if(AccountLeverage()<=0)
   {
   Print("CalculateVolume: invalid AccountLeverage() [",AccountLeverage(),"]");
   return(0);
   }
//--- basic formula
   if ( MM )
   vol=NormalizeDouble(AccountFreeMargin()*MaxRisk*AccountLeverage()/contract,2);
   else
   vol=Lots;
//--- check min, max and step
   vol=NormalizeDouble(vol/lot_step,0)*lot_step;
   if(vol<lot_min) vol=lot_min;
   if(vol>lot_max) vol=lot_max;
//---
   return(vol);
}   

// ---- Trailing Stops
void TrailStop()
{
   int    error;  
   bool   result=false;
   double Gain = 0;
    
   for (int cnt=0;cnt<OrdersTotal();cnt++)
   { 
   OrderSelect(cnt, SELECT_BY_POS);   
   int mode=OrderType();    
      if ( OrderSymbol()==Symbol() && OrderMagicNumber()==Magic) 
      {
         if (mode==OP_BUY) 
         {
			   if ( BreakEven > TrailingStop && BEvent==0 )
			   {
			   Gain = (MarketInfo(Symbol(),MODE_BID) - OrderOpenPrice())/Point;
			      if( Gain >= BreakEven && OrderStopLoss()<=OrderOpenPrice()+1*Point) 
			      {
			      double BuyStop = NormalizeDouble(OrderOpenPrice()+1*Point,Digits);
			      BEvent=1;
			      }
			   }
			   else 			   
			   if( TrailingStop > 0) BuyStop = NormalizeDouble(Bid - TrailingStop*Point,Digits);
			   
			   if( NormalizeDouble(OrderOpenPrice(),Digits)<= BuyStop || OrderStopLoss() == 0) 
            {   
			      if ( BuyStop > NormalizeDouble(OrderStopLoss(),Digits)) 
			      {
			         for(int k = 0 ; k < TriesNum; k++)
                  {
                  result = OrderModify(OrderTicket(),OrderOpenPrice(),
			                              BuyStop,
			                              OrderTakeProfit(),0,Lime);
                  error=GetLastError();
                     if(error==0) break;
                     else {Sleep(5000); RefreshRates(); continue;}
                  }   		 
               }            
            }
         }   
// - SELL Orders          
         if (mode==OP_SELL)
         {
            if ( BreakEven > TrailingStop && BEvent==0)
			   {
			   Gain = (OrderOpenPrice()-MarketInfo(Symbol(),MODE_ASK))/Point;
			      if( Gain >= BreakEven && OrderStopLoss()>=OrderOpenPrice()-1*Point) 
			      {
			      double SellStop = NormalizeDouble(OrderOpenPrice()-1*Point,Digits);
			      BEvent=-1;
			      }
			   }
			   else 
			   if( TrailingStop > 0) SellStop = NormalizeDouble(MarketInfo(Symbol(),MODE_ASK) + TrailingStop*Point,Digits);   
            
            if((NormalizeDouble(OrderOpenPrice(),Digits) >= SellStop && SellStop>0) || OrderStopLoss() == 0) 
            {
               if( SellStop < NormalizeDouble(OrderStopLoss(),Digits)) 
               {
                  for( k = 0 ; k < TriesNum; k++)
                  {
                  result = OrderModify(OrderTicket(),OrderOpenPrice(),
			                              SellStop,
			                              OrderTakeProfit(),0,Orange);
                  error=GetLastError();
                     if(error==0) break;
                     else {Sleep(5000); RefreshRates(); continue;}
                  }
               }   
   			}	    
         }
      }
   }     
}

// ---- Open Sell Orders
int SellOrdOpen(double price,double sl,double tp,int num) 
{		     
   int ticket = 0;
   int tr = 1;
      
   while ( ticket <= 0 && tr <= TriesNum)
   {
   ticket = OrderSend( Symbol(),OP_SELLSTOP,MoneyManagement(),
	                    NormalizeDouble(price , Digits),
	                    Slippage,
	                    NormalizeDouble(sl, Digits),
	                    NormalizeDouble(tp, Digits),
	                    ExpertName+" SELL:"+num,Magic,0,Red);
      
      if(ticket > 0) 
      {
      BEvent=0;   
         if (OrderSelect(ticket, SELECT_BY_TICKET, MODE_TRADES)) 
         Print("SELLSTOP order opened : ", OrderOpenPrice());
      }
	   else 	
      if(ticket < 0)
	   { 	
      Sleep(5000);
      RefreshRates();
      tr += 1;
      if(GetLastError()>0)
      Print("SELLSTOP: OrderSend failed with error #",ErrorDescription(GetLastError()));
      }
   }   
   return(ticket);
}

// ---- Open Buy Orders
int BuyOrdOpen(double price,double sl,double tp,int num)
{		     
   int ticket = 0;
   int tr = 1;
      
   while ( ticket <= 0 && tr <= TriesNum)
   {
   ticket = OrderSend(Symbol(),OP_BUYSTOP,MoneyManagement(),
	                   NormalizeDouble(price , Digits),
	                   Slippage,
	                   NormalizeDouble(sl, Digits), 
	                   NormalizeDouble(tp, Digits),
	                   ExpertName+" BUY:"+num,Magic,0,Blue);
      
      if(ticket > 0) 
      {
      BEvent=0;
         if (OrderSelect(ticket, SELECT_BY_TICKET, MODE_TRADES)) 
         Print("BUYSTOP order opened : ", OrderOpenPrice());
      
      }
      else 
	   if(ticket < 0)
	   { 	
      Sleep(5000);
      RefreshRates();
      tr += 1;
      if(GetLastError()>0)      
      Print("BUYSTOP : OrderSend failed with error #",ErrorDescription(GetLastError()));
      }
   }   
   return(ticket);
} 

// ---- Scan Trades

int ScanTrades(int ord,int mode)
{   
   int total = OrdersTotal();
   int numords = 0;
   bool type = false; 
   int trd = 0;
   
   for(int cnt=0; cnt<total; cnt++) 
   {        
   OrderSelect(cnt, SELECT_BY_POS);            
   if ( ord != 0 )
   {
   if ( OrderType()==0 || OrderType()==2 || OrderType()==4 ) trd =  1;
   if ( OrderType()==1 || OrderType()==3 || OrderType()==5 ) trd =  2;      
   } else trd=0;
   
   if (mode == 0) type = OrderType()<=OP_SELLSTOP;
   if (mode == 1) type = OrderType()<=OP_SELL;   
   if (mode == 2) type = OrderType()>OP_SELL && OrderType()<=OP_SELLSTOP; 
   
   if(OrderSymbol() == Symbol() && type && trd==ord && OrderMagicNumber() == Magic)  
   numords++;
   }
   return(numords);
}  

datetime FinishTime(int Duration)
{   
   int total = OrdersTotal();
   datetime ftime=0;
         
   for(int i=0; i<total; i++) 
   {        
   OrderSelect(i, SELECT_BY_POS);            
   if(OrderSymbol() == Symbol() && OrderType()<=OP_SELLSTOP && OrderMagicNumber() == Magic) 
   ftime=OrderOpenTime()+ Duration*60;
   }
   return(ftime);
}

// Closing of Pending Orders      
void PendOrdDel(int mode)
{
   bool result = false;
   
   for (int i=0; i<OrdersTotal(); i++)  
   {
   OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      if ( Symbol()==OrderSymbol() && OrderMagicNumber()==Magic)     
      {
         if((mode==0 || mode==1) && OrderType()==OP_BUYSTOP)
         {     
         result = OrderDelete(OrderTicket());
         if(!result) Print("BUYSTOP: OrderDelete failed with error #",GetLastError());
         }
         else
         if((mode==0 || mode==2) && OrderType()==OP_SELLSTOP)
         {     
         result = OrderDelete( OrderTicket() );  
         if(!result) Print("SELLSTOP: OrderDelete failed with error #",GetLastError());
         }
      }
   }
}    

//-----
void ReadnPlotCalendar(string fName)
{    
   int i, handle;
   bool rates=false;
   
   handle=FileOpen(fName,FILE_CSV|FILE_READ,';');
      if(handle<1)
      {
      Print("File not found ", GetLastError());
      return(false);
      }
   
   i=0;
   while(!FileIsEnding(handle))
   {
   sDate[i]=FileReadString(handle);          // Date
   sTime[i]=FileReadString(handle);          // Time
   sCurrency[i]=FileReadString(handle);      // Currency
   sDescription[i]=FileReadString(handle);   // Description
   sRating[i]=FileReadString(handle);        // Rating
   sActual[i]=FileReadString(handle);       
   sForecast[i]=FileReadString(handle);      
   sPrevious[i]=FileReadString(handle);      
           
   int rating = StrToInteger(sRating[i]);
   rates = rating <= MaxRating && rating >= MinRating;
   
   if(!rates) continue;
   
   if ((sCurrency[i] == "USD") && (!USD) ) continue;            
   if ((sCurrency[i] == "EUR") && (!EUR) ) continue;            
   if ((sCurrency[i] == "GBP") && (!GBP) ) continue;                      
   if ((sCurrency[i] == "JPY") && (!JPY) ) continue;
   if ((sCurrency[i] == "AUD") && (!AUD) ) continue;
   if ((sCurrency[i] == "CAD") && (!CAD) ) continue;                     
   if ((sCurrency[i] == "CHF") && (!CHF) ) continue;  
   if ((sCurrency[i] == "NZD") && (!NZD) ) continue;   
   
   
     
   dt[i] = StrToTime(sDate[i]+" "+sTime[i])+TimeZone*3600;
   
   if(rating == 3) sImpact[i] = "High";
   if(rating == 2) sImpact[i] = "Medium";
   if(rating == 1) sImpact[i] = "Low";
   
   string info = i+"_"+TimeToStr(dt[i])+" "+sCurrency[i]+" "+" "+sDescription[i]+" "+sImpact[i];
   Print( info );
      
   color c=Yellow ;
   
   if (sCurrency[i] == "USD") c = Blue;  
   if (sCurrency[i] == "EUR") c = Pink; 
   if (sCurrency[i] == "GBP") c = Red;
   if (sCurrency[i] == "JPY") c = Orange;            
   if (sCurrency[i] == "AUD") c = Green;       
   if (sCurrency[i] == "CAD") c = Gray;
   if (sCurrency[i] == "CHF") c = Green;
   if (sCurrency[i] == "NZD") c = Lime;  
      
      if (DisplayText)
      {
      ObjectCreate("NTT"+i, OBJ_TEXT, 0, dt[i], Close[0]);
      ObjectSet("NTT"+i, OBJPROP_COLOR, c);          
      ObjectSetText("NTT"+i,sCurrency[i] + " " + sDescription[i] + " ",8);          
      ObjectSet("NTT"+i, OBJPROP_ANGLE, 90);          
      }
          
      if (DisplayLine)
      {         
      ObjectCreate("NTL"+i, OBJ_VLINE, 0, dt[i], Close[0]);
      ObjectSet("NTL"+i, OBJPROP_COLOR, c);                    
      ObjectSet("NTL"+i, OBJPROP_STYLE, STYLE_DOT);                    
      ObjectSet("NTL"+i, OBJPROP_BACK, true);          
      ObjectSetText("NTL"+i,sCurrency[i] + " " + sDescription[i],8);          
      }
  
   i++;
   }

   NewsNum = i;

return(0);
}

//----
void ObjDel()
{
   int _GetLastError;
   if(DisplayLine && DisplayText) int obtotal = 0.5*ObjectsTotal(); else obtotal = ObjectsTotal();
   for ( int i = 0; i < obtotal; i ++ )
   {
      if (DisplayLine)
      if ( !ObjectDelete( StringConcatenate( "NTL", i ) ) )
      {
      _GetLastError = GetLastError();
      //Print( "ObjectDelete( \"", StringConcatenate( "NTL", i ),"\" ) - Error #", _GetLastError );
      }
      
      if (DisplayText)
      if( !ObjectDelete( StringConcatenate( "NTT", i ) ) )
      {
      _GetLastError = GetLastError();
      //Print( "ObjectDelete( \"", StringConcatenate( "NTT", i ),"\" ) - Error #", _GetLastError );
      }
   }
}

//---- Close of Orders

void CloseOrder(int mode)  
{
   bool result=false; 
   int  total=OrdersTotal();
   
   for (int i=0; i<=total; i++)  
   {
   OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      if (OrderMagicNumber() == Magic && OrderSymbol() == Symbol()) 
      {
      if ((mode == 0 || mode ==1) && OrderType()==OP_BUY ) result=CloseAtMarket(OrderTicket(),OrderLots(),Aqua);
      if ((mode == 0 || mode ==2) && OrderType()==OP_SELL) result=CloseAtMarket(OrderTicket(),OrderLots(),Pink);
      }
   }
}


bool CloseAtMarket(int ticket,double lot,color clr) 
{
   bool result = false; 
   int  ntr;
      
   int tries=0;
   while (!result && tries < TriesNum) 
   {
      ntr=0; 
      while (ntr<5 && !IsTradeAllowed()) { ntr++; Sleep(5000); }
      RefreshRates();
      result=OrderClose(ticket,lot,OrderClosePrice(),Slippage,clr);
      tries++;
   }
   if (!result) Print("Error closing order : ",ErrorDescription(GetLastError()));
   return(result);
}

bool TimeToOpen()
{
   bool result = false;
   for (int i=0; i<=NewsNum; i++)
   { 
   datetime OpenTime = dt[i] - TimeGap*60;
   
      if((TimeCurrent()>= OpenTime && TimeCurrent() <= OpenTime+ProcessTime*60))
      {result=true; break;}
   }
   return(result);
}
         
void TrailOppositeOrder(int mode)
{
   int    error;  
   bool   result=false;
   double Gain = 0;
    
   for (int cnt=0;cnt<OrdersTotal();cnt++)
   { 
   OrderSelect(cnt, SELECT_BY_POS);   
      if ( OrderSymbol()==Symbol() && OrderMagicNumber()==Magic) 
      {
         if (mode == 1 && OrderType() == OP_BUYSTOP) 
         {
			   for( int nt=1; nt<=OrdersNum; nt++)
            {
			      if (VerifyComment(1,nt))
			      {
			      //Print(OrderComment(),"=",ExpertName+" BUY:"+nt);
			      double BuyPrice = NormalizeDouble(MarketInfo(Symbol(),MODE_ASK) + (2*PendOrdGap+OrdersStep*(nt-1))*Point,Digits);
		         if (InitialStop > 0) double BuyStop =  BuyPrice - InitialStop*Point; else BuyStop=0;
               if (TakeProfit  > 0) double BuyProfit= BuyPrice +  TakeProfit*Point; else BuyProfit=0; 
			   			     
			         if( NormalizeDouble(OrderOpenPrice(),Digits) > BuyPrice) 
                  {   
			            Print("bPrice=",BuyPrice,"bStop=",BuyStop,"bProfit=",BuyProfit);
			            for(int k = 0 ; k < TriesNum; k++)
                     {
                     result = OrderModify(OrderTicket(),NormalizeDouble(BuyPrice,Digits),
			                                 NormalizeDouble(BuyStop,Digits),
			                                 NormalizeDouble(BuyProfit,Digits),0,Aqua);
                     error=GetLastError();
                        if(error==0) break;
                        else {Sleep(5000); RefreshRates(); continue;}
                     }
                  }      		 
               }            
            }
         }   
// - SELL Orders          
         if (mode==2 && OrderType() == OP_SELLSTOP)
         {
            for( nt=1; nt<=OrdersNum; nt++)
            {
               if (VerifyComment(2,nt))
			      {
               //Print(OrderComment(),"=",ExpertName+" SELL:"+nt);
               double SellPrice= NormalizeDouble(MarketInfo(Symbol(),MODE_BID) - (2*PendOrdGap+OrdersStep*(nt-1))*Point,Digits);
		         if (InitialStop > 0) double SellStop  = SellPrice + InitialStop*Point; else SellStop=0;
               if (TakeProfit  > 0) double SellProfit= SellPrice -  TakeProfit*Point; else SellProfit=0;  	   
         
                  if(NormalizeDouble(OrderOpenPrice(),Digits) < SellPrice) 
                  {
                     Print("sPrice=",SellPrice,"sStop=",SellStop,"sProfit=",SellProfit);
                     for( k = 0 ; k < TriesNum; k++)
                     {
                     result = OrderModify(OrderTicket(),NormalizeDouble(SellPrice,Digits),
			                                 NormalizeDouble(SellStop,Digits),
			                                 NormalizeDouble(SellProfit,Digits),0,Magenta);
                     error=GetLastError();
                        if(error==0) break;
                        else {Sleep(5000); RefreshRates(); continue;}
                     }
                  }   
               }   
   			}	    
         }
      }
   }     
}

bool VerifyComment(int mode, int num)
{
   int total = OrdersTotal();
   bool result = false; 
      
   for(int cnt=0; cnt<total; cnt++) 
   {        
   OrderSelect(cnt, SELECT_BY_POS);            
      if (mode==1 && OrderComment() == ExpertName+" BUY:"+num)  
      {
      result=true;
      break;
      }
      
      if (mode==2 && OrderComment() == ExpertName+" SELL:"+num) 
      {
      result=true;
      break;
      }
   }
  
   return(result);
}                                   

string ForexTSD_Calendar()
{
   datetime StartWeek = iTime(NULL,PERIOD_W1,0);
   string StartYear  = TimeYear (StartWeek);
   if (TimeMonth(StartWeek)>9) string StartMonth = TimeMonth(StartWeek);
   else StartMonth = "0" + TimeMonth(StartWeek);
   if (TimeDay(StartWeek)>9) string StartDay   = TimeDay(StartWeek);
   else StartDay = "0" + TimeDay(StartWeek);
   
   string StartTime = StartYear + StartMonth + StartDay;  
      
   string WebAdress = "http://calendar.forex-tsd.com/calendar.php?csv=1&date="+StartTime+"&calendar[]="+CalendarID;
   string result = forextsd_com_webget(WebAdress);
      
   if(result != "") 
   {
   string CalName = "Calendar_"+StartYear+"-"+StartMonth+"-"+StartDay+".csv";
   
   Print(CalName," is OK");
   
   int handle=FileOpen(CalName,FILE_CSV|FILE_WRITE,';');
         
      if(handle>0)
      {
      FileWrite(handle, result);
      FileClose(handle);
      }
   }
   else CalName = "";
  
   return(CalName);   
}

void ChartComment()
{
   
   string sComment   = "";
   string sp         = "---------------------------------------------------\n";
   string NL         = "\n";
   
   TotalProfit();    
   
   for (int i=0; i<=NewsNum-1; i++)
   { 
      if(TimeCurrent()> dt[i-1] && TimeCurrent() <= dt[i])
      {
      OpenTime = dt[i];
      string upcomNews = sCurrency[i]+" "+sDescription[i]+" Impact=" + sImpact[i]; 
      string upcomTime = TimeToStr(dt[i]);  
         
         if (i-1 >= 0)
         {
         string prevNews = sCurrency[i-1]+" "+sDescription[i-1]+" Impact=" + sImpact[i]; 
         string prevTime = TimeToStr(dt[i-1]);
         }
      }
      
      if(OpenTime > 0 && OpenTime < dt[i])
      {
      string nextNews = sCurrency[i]+" "+sDescription[i]+" Impact=" + sImpact[i];
      string nextTime = TimeToStr(dt[i]);
      break;
      }
   }
   
   
   sComment = sp;
   sComment = sComment+"ExpertName : "+ExpertName+NL;
   
   if(TimeZone >= 0)
   sComment = sComment+"Broker\'s Time Zone : GMT + " + TimeZone + NL;
   else
   sComment = sComment+"Broker\'s Time Zone : GMT - " + MathAbs(TimeZone) + NL;
   
   sComment = sComment+"Orders: Open= "+ScanTrades(0,1)+" Pending= "+ScanTrades(0,2)+" All= "+ScanTrades(0,0)+NL;
   sComment = sComment+"Current Profit(pips)= " + totalPips + NL;
   sComment = sComment+"Current Profit(USD) = " + DoubleToStr(totalProfits,2) + NL; 
   sComment = sComment+"NEWS :" + NL;
   sComment = sComment+"Previous = " + prevTime  +" "+prevNews  + NL;
   sComment = sComment+"Upcoming = " + upcomTime +" "+upcomNews + NL;
   sComment = sComment+"Next = " + nextTime +" "+nextNews + NL;
   sComment = sComment+sp;
  
   Comment(sComment);
}      

void TotalProfit()
{
   int total=OrdersTotal();
   totalPips = 0;
   totalProfits = 0;
   for (int cnt=0;cnt<total;cnt++)
   { 
   OrderSelect(cnt, SELECT_BY_POS);   
   int mode=OrderType();
   bool condition = false;
   if ( Magic>0 && OrderMagicNumber()==Magic ) condition = true;
   else if ( Magic==0 ) condition = true;   
      if (condition)
      {      
         switch (mode)
         {
         case OP_BUY:
            totalPips += MathRound((MarketInfo(OrderSymbol(),MODE_BID)-OrderOpenPrice())/MarketInfo(OrderSymbol(),MODE_POINT));
            totalProfits += OrderProfit();
            break;
            
         case OP_SELL:
            totalPips += MathRound((OrderOpenPrice()-MarketInfo(OrderSymbol(),MODE_ASK))/MarketInfo(OrderSymbol(),MODE_POINT));
            totalProfits += OrderProfit();
            break;
         }
      }            
	}
}               
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
  {
//---- 
   ObjDel();
 
//----
   
   return(0);
  }
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
{
   if(Bars < 1) {Print("Not enough bars for this strategy");return(0);}
   
   if(AccountFreeMargin()<(1000*Lots)){
   Print("We have no money. Free Margin = ", AccountFreeMargin());
   return(0);}
//---- 
   datetime cTime = iTime(NULL,PERIOD_W1,0);
   
   if (fTime || (TimeCurrent() > cTime && cTime > prevTime))
   {
   string gmt = forextsd_com_webget("http://calendar.forex-tsd.com/gmt.php");
   if(gmt!="") datetime gmtime = StrToTime(gmt);
   else return(0);
   
   int tz = NormalizeDouble((TimeCurrent() - gmtime)/3600.0,0);
   if ( tz < 24) TimeZone = tz;
   
   
   CalendarName = ForexTSD_Calendar();  
      
      if(CalendarName != "")
      {   
      ReadnPlotCalendar(CalendarName);
      fTime = false;
      prevTime = cTime;
      }
      else 
      {
      //Print("Attention! Wrong Calendar:",CalendarName,"time=",TimeToStr(TimeCurrent())); 
      return(0);
      }
   }
   
   ChartComment();
   
   if (ScanTrades(0,0) > 0)
   {
      if (DelOpposite > 0)
      {
         if (ScanTrades(1,1) > 0 && ScanTrades(2,2) > 0) PendOrdDel(2);
         if (ScanTrades(2,1) > 0 && ScanTrades(1,2) > 0) PendOrdDel(1);
          
         if (ScanTrades(0,1) == 0 && (ScanTrades(1,2) == 0 || ScanTrades(2,2)==0)) PendOrdDel(0);
      }      
      
      datetime FinTime = FinishTime(OrderDuration); 
      if (TimeCurrent()>=FinTime && ScanTrades(0,2) > 0) PendOrdDel(0); 
      
      if(DayOfWeek()!=5) datetime EndTime = StrToTime(SessionEnd+":00")-Period()*60; 
      else EndTime = StrToTime(FridayEnd+":00")-Period()*60;
      
      bool EOD = false;
      EOD = TimeCurrent()>= EndTime;
      
      if ((TimeToOpen() && TimeCurrent()>=FinishTime(TimeGap+ProcessTime)) || EOD)
      {
         if(ScanTrades(0,1) > 0) CloseOrder(0);
         if(ScanTrades(0,2) > 0) PendOrdDel(0);
      }
     
      if (ScanTrades(0,1) > 0 && (TrailingStop>0 || BreakEven>0)) TrailStop();
   
      if (TrailOpposite > 0 && DelOpposite == 0)
      {
      if (ScanTrades(1,1) > 0 && ScanTrades(2,2) > 0) TrailOppositeOrder(2); 
      if (ScanTrades(2,1) > 0 && ScanTrades(1,2) > 0) TrailOppositeOrder(1);
      }   
   }
   
   if (ScanTrades(0,0)<1)
   { 
      if(TimeToOpen())
      {
         for(int cnt=1; cnt<=OrdersNum; cnt++)
         {
         double BuyPrice = MarketInfo(Symbol(),MODE_ASK) + (PendOrdGap+OrdersStep*(cnt-1))*Point;
		   if (InitialStop > 0) double BuyStop =  BuyPrice - InitialStop*Point; else BuyStop=0;
         if (TakeProfit  > 0) double BuyProfit= BuyPrice +  TakeProfit*Point; else BuyProfit=0;   
         BuyOrdOpen(BuyPrice,BuyStop,BuyProfit,cnt); 
         
         double SellPrice= MarketInfo(Symbol(),MODE_BID) - (PendOrdGap+OrdersStep*(cnt-1))*Point;
		   if (InitialStop > 0) double SellStop  = SellPrice + InitialStop*Point; else SellStop=0;
         if (TakeProfit  > 0) double SellProfit= SellPrice -  TakeProfit*Point; else SellProfit=0;
         SellOrdOpen(SellPrice,SellStop,SellProfit,cnt);
         }
      }
   }
      
 return(0);
}//int start
//+------------------------------------------------------------------+





