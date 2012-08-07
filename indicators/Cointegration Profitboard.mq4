//+------------------------------------------------------------------+
//|                                  Cointegration - Profitboard.mq4 |
//|                                    Copyright © 2011, Mediator    |
//|                                               mediator@online.de |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2011, Mediator"
#property link      "mediator@online.de"

#property indicator_chart_window

extern int Rows = 40;
extern double DD1 = 100;
extern double DD2 = 200;
extern double DD3 = 300;
double AccProfit;
int PairCount;
color profit;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
ObjectsDeleteAll();
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   ObjectsDeleteAll();
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int    counted_bars=IndicatorCounted();
   string globals;
   int countx = 0;
   int county = 0;
   
//----
   DeleteObject("Set");
   DeleteObject("PC");
   DeleteObject("Pro");
   for(int i=0;i<=GlobalVariablesTotal()-1;i++)
   {
      if(county==Rows)
      {
          countx++;
          county=0;
      }
      globals = GlobalVariableName(i);
      ObjectCreate("Set"+i, OBJ_LABEL,0,0,0);
         ObjectSetText("Set"+i, globals,9,"Arial",Yellow);
         ObjectSet("Set"+i, OBJPROP_XDISTANCE,countx*170);
         ObjectSet("Set"+i, OBJPROP_YDISTANCE,county*12+2);
         
      
         AccProfit = 0;
      GetProfit(globals);
      ObjectCreate("PC"+i, OBJ_LABEL,0,0,0);
         ObjectSetText("PC"+i, DoubleToStr(PairCount,0),9,"Arial",White);
         ObjectSet("PC"+i, OBJPROP_XDISTANCE,((countx+1)*120)+(countx*49));
         ObjectSet("PC"+i, OBJPROP_YDISTANCE,county*12+2);
      profit = Red;
      if(AccProfit >=0) 
      {
         profit = Lime;
      } else 
      {
         profit = Red;
      }
      if(AccProfit == 0.00) profit = Black;
      if(AccProfit <=-DD1) 
      {
         profit = DodgerBlue;
      } 
      if(AccProfit <=-DD2) 
      {
         profit = Aqua;
      } 
      if(AccProfit <=-DD3) 
      {
         profit = White;
      }
      ObjectCreate("Prof"+i, OBJ_LABEL,0,0,0);
      
         ObjectSetText("Prof"+i, DoubleToStr(AccProfit,2),9,"Arial",profit);
         ObjectSet("Prof"+i, OBJPROP_XDISTANCE,((countx+1)*135)+(countx*34));
         ObjectSet("Prof"+i, OBJPROP_YDISTANCE,county*12+2);
         county++;
   }
         ObjectCreate("Total", OBJ_LABEL,0,0,0);
         if(AccountProfit() >=0) profit = Lime; else profit = Red;
         ObjectSetText("Total", DoubleToStr(AccountProfit(),2),10,"Arial",profit);
         ObjectSet("Total", OBJPROP_XDISTANCE,250);
         ObjectSet("Total", OBJPROP_YDISTANCE,Rows*12+2);
//----
   DeleteObject("Orph");
   
   int cnt;
   int y=0;
   int total=OrdersTotal();
   for(cnt=0; cnt<=total; cnt++)
   {
      OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
      if(!GetGlobal(OrderComment()))
      {
         if(!ObjectExist("Orph"+OrderComment()))
         {
            ObjectCreate("Orph"+OrderComment(), OBJ_LABEL,0,0,0);
            ObjectSetText("Orph"+OrderComment(), OrderComment(),9,"Arial",Aqua);
            ObjectSet("Orph"+OrderComment(), OBJPROP_XDISTANCE,0);
            ObjectSet("Orph"+OrderComment(), OBJPROP_YDISTANCE,(y*7)+(Rows*12)+10);
            y++;
         }
      }
   }
      
  }
  return(0);
//+------------------------------------------------------------------+
bool ObjectExist(string OName)
{
   string name;      
      int obj = ObjectsTotal();
      for ( int n=obj;n >= 0 ;n--)
         {
            name = ObjectName(n);
            if(name == OName) return(true); else return(false);
         }
}
bool GetGlobal(string com)
{
    for(int i=0;i<=GlobalVariablesTotal()-1;i++)
    {
      if(GlobalVariableCheck(com)) return(true); else return(false);
    }
}
void DeleteObject(string char4)
   {
      string name;      
      int obj = ObjectsTotal();
      for ( int n=obj;n >= 0 ;n--)
         {
            name = ObjectName(n);
            char4 = StringSubstr(name,0,2);
            if ( char4 == "Corr" )
               ObjectDelete(name);   
         }
      return;
   }           


void GetProfit(string cmd)
{
   int cnt;
   PairCount=0;
   int total=OrdersTotal();
   for(cnt=0; cnt<=total; cnt++){
      OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
      if(OrderComment() == cmd)
      {
         AccProfit = AccProfit + OrderProfit();
         PairCount++;
        
      }
   }
}