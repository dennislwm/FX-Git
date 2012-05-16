//|-----------------------------------------------------------------------------------------|
//|                                                                            VRSetka2.mqh |
//|                                                            Copyright © 2012, Dennis Lee |
//| Assert History                                                                          |
//| 1.10    Added PlusGhost.mqh and PlusTurtle.mqh.                                         |
//|            Added MaxExpertTrades to allow user to limit account trades.                 |
//|            Added StopLoss to allow a fixed stoploss for each trade.                     |
//| 1.00    Originated from MQL4 CodeBase by Voldemar227.                                   |
//|-----------------------------------------------------------------------------------------|
#property copyright "Copyright © 2012, Dennis Lee"
#property link      ""

//|-----------------------------------------------------------------------------------------|
//|                           E X T E R N A L   V A R I A B L E S                           |
//|-----------------------------------------------------------------------------------------|
extern int     Correlyciya       = 50;
extern int     StopLoss          = 1200;
extern int     TakeProfit        = 300;
extern double  Lot               = 0.1;
extern double  Procent           = 1.3;
extern bool    Martin            = true;
extern int     MaxExpertTrades   = 4;
extern int     Slip=2;
extern int     Magic=227;

//|-----------------------------------------------------------------------------------------|
//|                                 P L U S   A D D O N                                     |
//|-----------------------------------------------------------------------------------------|
#include <PlusGhost.mqh>
#include <PlusTurtle.mqh>

//|-----------------------------------------------------------------------------------------|
//|                           I N T E R N A L   V A R I A B L E S                           |
//|-----------------------------------------------------------------------------------------|
string   EaName="VRSetka2";
string   EaVer="1.10";

//|-----------------------------------------------------------------------------------------|
//|                              I N I T I A L I Z A T I O N                                |
//|-----------------------------------------------------------------------------------------|
int init()
  {
   TurtleInit();
   GhostInit();
  }

//|-----------------------------------------------------------------------------------------|
//|                             D E I N I T I A L I Z A T I O N                             |
//|-----------------------------------------------------------------------------------------|
int deinit()
  {
   GhostDeInit();
  }

//|-----------------------------------------------------------------------------------------|
//|                               M A I N   P R O C E D U R E                               |
//|-----------------------------------------------------------------------------------------|
int start() 
  {
   GhostRefresh();
  
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
   ObjectCreate("R",OBJ_LABEL,0,0,0);
   ObjectSet("R",OBJPROP_CORNER,2);
   ObjectSet("R",OBJPROP_XDISTANCE,10);
   ObjectSet("R",OBJPROP_YDISTANCE,10);
   ObjectSetText("R","WWW.TRADING-GO.RU",10,"Arial",Red);
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
   double opB=2000; double opS=0; double orderProfitbuy=0; double Sum_Profitbuy=0; double orderProfitsel;  double Sum_Profitsel; int orderType;
   double LotB=Lot;
   double LotS=Lot;
   
   int total=GhostOrdersTotal();
   int b=0,s=0,n=0;
//--- Set minimum OpenPrice for buy trades (opB)
//--- Set maximum OpenPrice for sell trades (opS)
   double StopLossS, StopLossB;

   StopLossS=0.0; StopLossB=0.0;
   GhostInitSelect(false,0,SELECT_BY_POS,MODE_TRADES);
   for(int i=total-1; i>=0; i--)
     {
      if(GhostOrderSelect(i, SELECT_BY_POS))
        {
         if(GhostOrderSymbol()==Symbol()      )
           {
            n++;
            if(GhostOrderType()==OP_BUY && GhostOrderMagicNumber()==Magic)
              {
               b++;
               LotB=GhostOrderLots();
               StopLossB=GhostOrderStopLoss();
               int tikketB=GhostOrderTicket(); double ProfitB=GhostOrderTakeProfit(); double openB=GhostOrderOpenPrice();
               if(openB<opB)
                 {opB=openB;}
              }
            //---------------------------------      
            if(GhostOrderType()==OP_SELL && GhostOrderMagicNumber()==Magic)
              {
               s++;
               LotS=GhostOrderLots();
               StopLossS=GhostOrderStopLoss();
               int tikketS=GhostOrderTicket(); double ProfitS=GhostOrderTakeProfit(); double openS=GhostOrderOpenPrice();
               if(openS>opS)
                 {opS=openS;}
              }
           }
        }
     }
   GhostFreeSelect(false);
     
//--- Set daily high (max), low (min), open (opp), and close (cl) prices
   double max = NormalizeDouble(iHigh(Symbol(),1440,0),Digits);
   double min = NormalizeDouble(iLow (Symbol(),1440,0),Digits);
   double opp=NormalizeDouble(iOpen(Symbol(),1440,0),Digits);
   double cl=NormalizeDouble(iClose(Symbol(),1440,0),Digits);
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//--- Set ratio of close/min price as percentage gain (x)
   if(cl>min)
     {
      double x=NormalizeDouble(cl*100/min-100,2);
     }
//--------------
//--- Set ratio of close/max price as percentage loss (y)
   if(cl<max)
     {
      double y=NormalizeDouble(cl*100/max-100,2);
     }
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//

   double dis   =NormalizeDouble(TakeProfit*Point,Digits);
   double spred =NormalizeDouble(MarketInfo(Symbol(),MODE_SPREAD)*Point,Digits);
   double  CORR=NormalizeDouble(Correlyciya            *Point,Digits);
   if(Martin==true)
     {
      if(n>=1){for(int P=100; P>=0; P--)
        {
         if(n==P&&n>=1) {LotB=LotB*P;}
         if(n==P&&n>=1) {LotS=LotS*P;}
        }
     }
  }
if(Martin==false)
  {
   if(b==1||s==1) {LotB=LotS*1;LotS=LotB*1;}
   if(b==2||s==2) {LotS=LotS*1;LotB=LotB*1;}
   if(b==3||s==3) {LotS=LotS*1;LotB=LotB*1;}

   if(b==4||s==4) {LotB=LotS*3;LotS=LotB*3;}
   if(b==5||s==5) {LotS=LotS*3;LotB=LotB*3;}
   if(b==6||s==6) {LotS=LotS*3;LotB=LotB*3;}

   if(b==7||s==7) {LotB=LotS*6;LotS=LotB*6;}
   if(b==8||s==8) {LotS=LotS*6;LotB=LotB*6;}
   if(b==9||s==9) {LotS=LotS*6;LotB=LotB*6;}
  }
if(expertOrdersTotal()<MaxExpertTrades)
{
   if((b==0&&Procent*(-1)<=y&&s==0&&Close[1]>Open[1])||(Ask<opB-dis-spred&&b>=1&&s==0)) { GhostOrderSend(Symbol(),OP_BUY ,LotB,Ask,Slip,0,0,"???????? ??? ?2",Magic,0,Green); }
   if((s==0&&Procent     >=x&&b==0&&Close[1]<Open[1])||(Bid>opS+dis-spred&&s>=1&&b==0)) { GhostOrderSend(Symbol(),OP_SELL,LotS,Bid,Slip,0,0,"???????? ??? ?2",Magic,0,Green); }
}
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
double TPB= NormalizeDouble (openB+spred+TakeProfit*Point,Digits);
double TPS= NormalizeDouble (openS+spred-TakeProfit*Point,Digits);
double SLB= NormalizeDouble (openB+spred-StopLoss*Point,Digits);
double SLS= NormalizeDouble (openS-spred+StopLoss*Point,Digits);
if( (ProfitB==0 || StopLossB==0) &&b>=1) { GhostOrderModify(tikketB,openB,  SLB,TPB, 0,Blue); }
if( (ProfitS==0 || StopLossS==0) &&s>=1) { GhostOrderModify(tikketS,openS,  SLS,TPS, 0,Blue); }
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//

double nn=0,bb=0;
GhostInitSelect(false,0,SELECT_BY_POS,MODE_TRADES);
for(int ui=total-1; ui>=0; ui--)
  {
   if(GhostOrderSelect(ui,SELECT_BY_POS))
     {
      if(GhostOrderSymbol()==Symbol())
        {
         if(GhostOrderType()==OP_BUY && GhostOrderMagicNumber()==Magic)
           {
            double op=GhostOrderOpenPrice();
            double llot=GhostOrderLots();
            double itog=op*llot;
            bb=bb+itog;
            nn=nn+llot;
            double factb=bb/nn;
           }
        }
     }
  }
GhostFreeSelect(false);

double nnn=0,bbb=0;
GhostInitSelect(false,0,SELECT_BY_POS,MODE_TRADES);
for(int usi=total-1; usi>=0; usi--)
  {
   if(GhostOrderSelect(usi,SELECT_BY_POS))
     {
      if(GhostOrderSymbol()==Symbol())
        {
         if(GhostOrderType()==OP_SELL && GhostOrderMagicNumber()==Magic)
           {
            double ops=GhostOrderOpenPrice();
            double llots=GhostOrderLots();
            double itogs=ops*llots;
            bbb=bbb+itogs;
            nnn=nnn+llots;
            double facts=bbb/nnn;
           }
        }
     }
  }
GhostFreeSelect(false);

int      aTicket[];
int      aType[];
double   aOpenPrice[];
double   aStopLoss[];
double   aTakeProfit[];
int      aCount         =0;
bool     aOk            =false;

ArrayResize(aTicket,MaxExpertTrades);
ArrayResize(aType,MaxExpertTrades);
ArrayResize(aOpenPrice,MaxExpertTrades);
ArrayResize(aStopLoss,MaxExpertTrades);
ArrayResize(aTakeProfit,MaxExpertTrades);
GhostInitSelect(false,0,SELECT_BY_POS,MODE_TRADES);
for(int uui=total-1; uui>=0; uui--)
  {
   if(GhostOrderSelect(uui,SELECT_BY_POS))
     {
      if(GhostOrderSymbol()==Symbol())
        {
         if(b>=2 && GhostOrderType()==OP_BUY && GhostOrderMagicNumber()==Magic)
           {
            if( GhostOrderTakeProfit() != factb+CORR || GhostOrderStopLoss() == 0.0 )
            {
               if ( GhostOrderStopLoss() == 0.0 )
                  aStopLoss[aCount] = NormalizeDouble(GhostOrderOpenPrice()+spred-StopLoss*Point,Digits);
               else
                  aStopLoss[aCount] = GhostOrderStopLoss();
               aType[aCount]        = GhostOrderType();
               aTakeProfit[aCount]  = factb+CORR;
               aTicket[aCount]      = GhostOrderTicket();
               aOpenPrice[aCount]   = GhostOrderOpenPrice();

               aCount               ++;
               aOk                  = true;
               if( aCount >= MaxExpertTrades ) break;
            }
           }
         if(s>=2 && GhostOrderType()==OP_SELL && GhostOrderMagicNumber()==Magic)
           {
            if( GhostOrderTakeProfit() != facts-CORR || GhostOrderStopLoss() == 0.0 )
            {
               if ( GhostOrderStopLoss() == 0.0 )
                  aStopLoss[aCount] = NormalizeDouble(GhostOrderOpenPrice()-spred+StopLoss*Point,Digits);
               else
                  aStopLoss[aCount] = GhostOrderStopLoss();
               aType[aCount]        = GhostOrderType();
               aTakeProfit[aCount]  = facts-CORR;
               aTicket[aCount]      = GhostOrderTicket();
               aOpenPrice[aCount]   = GhostOrderOpenPrice();
               
               aCount               ++;
               aOk                  = true;
               if( aCount >= MaxExpertTrades ) break;
            }
           }
        }
     }
  }
GhostFreeSelect(true);

if( aOk )
   for(i=0; i<aCount; i++)
   {
      GhostOrderModify(aTicket[i],aOpenPrice[i],aStopLoss[i],aTakeProfit[i],0,Blue);
      GhostDebugPrint( 2,"start",
         GhostDebugInt("i",i)+
         GhostDebugInt("aTicket",aTicket[i])+
         GhostDebugInt("aType",aType[i])+
         GhostDebugDbl("aOpenPrice",aOpenPrice[i])+
         GhostDebugDbl("aStopLoss",aStopLoss[i])+
         GhostDebugDbl("aTakeProfit",aTakeProfit[i])+
         " OK Order Modified.",
         false, 1 );
   }
PrintComment( total, LotB, LotS );

}

//|-----------------------------------------------------------------------------------------|
//|                                     C O M M E N T                                       |
//|-----------------------------------------------------------------------------------------|
void PrintComment( int tot, double bLot, double sLot)
{
   string expr="  -->"+EaName+" "+EaVer+"<--";
   
   expr=expr+"\n  MaxExpertTrades="+MaxExpertTrades;
   if( tot >= MaxExpertTrades )
      expr=expr+" (reached)";
   expr=expr+"\n  Next Calc Sell Lots="+DoubleToStr(sLot,2);
   expr=expr+"\n  Next Calc Buy Lots="+DoubleToStr(bLot,2);
   expr=expr+"\n";
   
   Comment(GhostComment(TurtleComment(expr)));
}

//|-----------------------------------------------------------------------------------------|
//|                           I N T E R N A L   F U N C T I O N S                           |
//|-----------------------------------------------------------------------------------------|
int expertOrdersTotal()
{
   int total=GhostOrdersTotal();
   int orders;

//--- Assert total > 0
   if(total<=0) return(0);
   
   GhostInitSelect(false,0,SELECT_BY_POS,MODE_TRADES);
   for(int i=total-1; i>=0; i--)
   {
      if(GhostOrderSelect(i, SELECT_BY_POS))
      {
         if( GhostOrderSymbol() == Symbol() && GhostOrderMagicNumber() == Magic )
         {
            orders ++;
         }
      }
   }
   GhostFreeSelect(false);
   
   return( orders );
}

//|-----------------------------------------------------------------------------------------|
//|                       E N D   O F   E X P E R T   A D V I S O R                         |
//|-----------------------------------------------------------------------------------------|