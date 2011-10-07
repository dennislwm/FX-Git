//|-----------------------------------------------------------------------------------------|
//|                                                                           plusgridx.mqh |
//|                                                            Copyright © 2011, Dennis Lee |
//| Assert History                                                                          |
//| 1.01    Fixed return values in Gridx(), I_Trade() and II_Trade().                       |
//| 1.00    Copied from PlusLinex.mqh to PlusGridx.mqh.                                     |
//|         Added dynamic arrays to allow maximum of 100 upper and lower trendlines each.   |
//|-----------------------------------------------------------------------------------------|
#property   copyright "Copyright © 2011, Dennis Lee"
#include    <stdlib.mqh>

//|-----------------------------------------------------------------------------------------|
//|                 P L U S L I N E X   E X T E R N A L   V A R I A B L E S                 |
//|-----------------------------------------------------------------------------------------|
extern   string   GridxUpper         = "Upper";
extern   int      GridxUpperPrefix   = 100;
extern   int      GridxUpperNo       = 1;
extern   bool     GridxUpperNoBuy    = false;
extern   bool     GridxUpperNoSell   = false;
extern   bool     GridxUpperNoMove   = false;
extern   string   GridxLower         = "Lower";
extern   int      GridxLowerPrefix   = 200;
extern   int      GridxLowerNo       = 1;
extern   bool     GridxLowerNoBuy    = false;
extern   bool     GridxLowerNoSell   = false;
extern   bool     GridxLowerNoMove   = false;
extern   double   GridxPipLimit  = 3;
extern   double   GridxPipWide   = 3;
extern   double   GridxPipMove   = 6;
extern   int      GridxUpperMagic    = 10000;
extern   int      GridxLowerMagic    = 20000;
extern   bool     GridxOneTrade= false;
extern   int      GridxDebug     = 0;

//|-----------------------------------------------------------------------------------------|
//|                           I N T E R N A L   V A R I A B L E S                           |
//|-----------------------------------------------------------------------------------------|
double   I_LineLevel[], I_Hlimit[], I_Llimit[], I_Hlimit1[], I_Llimit1[];
double   II_LineLevel[], II_Hlimit[], II_Llimit[], II_Hlimit1[], II_Llimit1[];
//-- Assert new concept trailing trendline
//       0 - not crossed yet; 1 - crossed once; 2 - crossed second
double   I_Mlimit[], II_Mlimit[];
double   I_LineLevelStart[], II_LineLevelStart[];
int      I_Status[], II_Status[], I_Magic[], II_Magic[];
string   I_Name[], II_Name[];
string   GridxName="PlusGridx";
string   GridxVer="1.01";

//|-----------------------------------------------------------------------------------------|
//|                             I N I T I A L I Z A T I O N                                 |
//|-----------------------------------------------------------------------------------------|
void GridxInit()
{
//---- Automatically adjust to Full-Pip or Sub-Pip Accounts
   if (!GridxUpperNoBuy && !GridxUpperNoSell && !GridxUpperNoMove)
   {
      GridxUpperNoMove=true;
      Alert("GridxUpper can move uni-directional only (User has to set Buy or Sell to False). GridxUpperNoMove has been set to True.");
   }
   if (!GridxLowerNoBuy && !GridxLowerNoSell && !GridxLowerNoMove)
   {
      GridxLowerNoMove=true;
      Alert("GridxLower can move uni-directional only (User has to set Buy or Sell to False). GridxLowerNoMove has been set to True.");
   }
   
//--- Assert maximum UpperNo and LowerNo
   if (GridxUpperNo>100)
   {
      GridxUpperNo=100;
      Alert("GridxUpperNo has exceeded the limit. GridxUpperNo has been set to 100.");
   }
   if (GridxLowerNo>100)
   {
      GridxLowerNo=100;
      Alert("GridxLowerNo has exceeded the limit. GridxLowerNo has been set to 100.");
   }
   
//--- Assert Init and Resize arrays
   int nonzero=1;
   
   ArrayResize(I_LineLevel,GridxUpperNo+nonzero);
   ArrayResize(I_Hlimit,GridxUpperNo+nonzero);
   ArrayResize(I_Llimit,GridxUpperNo+nonzero);
   ArrayResize(I_Hlimit1,GridxUpperNo+nonzero);
   ArrayResize(I_Llimit1,GridxUpperNo+nonzero);
   ArrayResize(I_Mlimit,GridxUpperNo+nonzero);
   ArrayResize(I_LineLevelStart,GridxUpperNo+nonzero);
   ArrayResize(I_Status,GridxUpperNo+nonzero);
   ArrayResize(I_Magic,GridxUpperNo+nonzero);
   ArrayResize(I_Name,GridxUpperNo+nonzero);

   ArrayResize(II_LineLevel,GridxLowerNo+nonzero);
   ArrayResize(II_Hlimit,GridxLowerNo+nonzero);
   ArrayResize(II_Llimit,GridxLowerNo+nonzero);
   ArrayResize(II_Hlimit1,GridxLowerNo+nonzero);
   ArrayResize(II_Llimit1,GridxLowerNo+nonzero);
   ArrayResize(II_Mlimit,GridxLowerNo+nonzero);
   ArrayResize(II_LineLevelStart,GridxLowerNo+nonzero);
   ArrayResize(II_Status,GridxLowerNo+nonzero);
   ArrayResize(II_Magic,GridxLowerNo+nonzero);
   ArrayResize(II_Name,GridxLowerNo+nonzero);

//--- Initialize Name and Magic
   for (int i=1; i<=GridxUpperNo; i++)
   {
      I_Magic[i]=GridxUpperMagic+GridxUpperPrefix+i;
      I_Name[i]=StringConcatenate(GridxUpper,GridxUpperPrefix+i);
   }

   for (i=1; i<=GridxLowerNo; i++)
   {
      II_Magic[i]=GridxLowerMagic+GridxLowerPrefix+i;
      II_Name[i]=StringConcatenate(GridxLower,GridxLowerPrefix+i);
   }
}

//|-----------------------------------------------------------------------------------------|
//|                               C H E C K   T R E N D L I N E                             |
//|-----------------------------------------------------------------------------------------|
int I_Check(int gridno)
{
   if (ObjectFind(I_Name[gridno])<0) I_LineLevel[gridno] = -1;
   else
   {
      I_LineLevel[gridno] = ObjectGetValueByShift(I_Name[gridno],0);
      if (""==ObjectDescription(I_Name[gridno])) ObjectSetText(I_Name[gridno], StringConcatenate(I_Name[gridno]," Price=",I_LineLevel[gridno]," Magic=",I_Magic[gridno]), 10, "Arial");
   }
   I_Hlimit[gridno]=0; I_Llimit[gridno]=0;
   if (I_LineLevel[gridno]>0)
   {
//-- Assert new concept moving trendline - Stage 1 of 5: Record price of original line.
      if (I_Status[gridno]==0 && !GridxUpperNoMove) I_LineLevelStart[gridno]=I_LineLevel[gridno];
//-- Assert new concept moving trendline - Stage 4 of 5: Move trendline to narrow the gap with closing price.
      if (I_Status[gridno]==1 && !GridxUpperNoMove)
      {
         double I_LinePrice1=ObjectGet(I_Name[gridno],OBJPROP_PRICE1);
         double I_LinePrice2=ObjectGet(I_Name[gridno],OBJPROP_PRICE2);
         if (!GridxUpperNoSell)
         {
            I_Mlimit[gridno]=I_LineLevel[gridno]+(GridxPipLimit+GridxPipMove)*Pts;
            if (Close[0]>I_Mlimit[gridno])
            {
               ObjectSet(I_Name[gridno],OBJPROP_PRICE1,I_LinePrice1+(Close[0]-I_Mlimit[gridno]));
               ObjectSet(I_Name[gridno],OBJPROP_PRICE2,I_LinePrice2+(Close[0]-I_Mlimit[gridno]));
               if (GridxDebug>=2) Print("PlusGridx: ",Symbol()," I_Check",DoubleToStr(gridno,0),": Close[0]=",DoubleToStr(Close[0],5),">I_Mlimit=",DoubleToStr(I_Mlimit[gridno],5)," I_LinePrice1=",DoubleToStr(I_LinePrice1,5)," I_LinePrice2=",DoubleToStr(I_LinePrice2,5)," Delta=",DoubleToStr(Close[0]-I_Mlimit[gridno],5));
            }
         }
         if (!GridxUpperNoBuy)
         {
            I_Mlimit[gridno]=I_LineLevel[gridno]-(GridxPipLimit+GridxPipMove)*Pts;
            if (Close[0]<I_Mlimit[gridno])
            {
               ObjectSet(I_Name[gridno],OBJPROP_PRICE1,I_LinePrice1-(I_Mlimit[gridno]-Close[0]));
               ObjectSet(I_Name[gridno],OBJPROP_PRICE2,I_LinePrice2-(I_Mlimit[gridno]-Close[0]));
               if (GridxDebug>=2) Print("PlusGridx: ",Symbol()," I_Check",DoubleToStr(gridno,0),": Close[0]=",DoubleToStr(Close[0],5),"<I_Mlimit=",DoubleToStr(I_Mlimit[gridno],5)," I_LinePrice1=",DoubleToStr(I_LinePrice1,5)," I_LinePrice2=",DoubleToStr(I_LinePrice2,5)," Delta=",DoubleToStr(Close[0]-I_Mlimit[gridno],5));
            }
         }
      }   
      I_Hlimit[gridno]  = I_LineLevel[gridno] + (GridxPipLimit*Pts);
      I_Hlimit1[gridno] = I_Hlimit[gridno]    + (GridxPipWide *Pts);
      I_Llimit[gridno]  = I_LineLevel[gridno] - (GridxPipLimit*Pts);
      I_Llimit1[gridno] = I_Llimit[gridno]    - (GridxPipWide *Pts);
   }
}

int II_Check(int gridno)
{
   if (ObjectFind(II_Name[gridno])<0)   II_LineLevel[gridno] = -1;
   else
   {
      II_LineLevel[gridno] = ObjectGetValueByShift(II_Name[gridno],0);
      if (""==ObjectDescription(II_Name[gridno])) ObjectSetText(II_Name[gridno], II_Name[gridno], 10, "Arial");
   }
   II_Hlimit[gridno]=0; II_Llimit[gridno]=0;
   if (II_LineLevel[gridno]>0)
   {
//-- Assert new concept moving trendline - Stage 1 of 5: Record price of original line.
      if (II_Status[gridno]==0 && !GridxLowerNoMove) II_LineLevelStart[gridno]=II_LineLevel[gridno];
//-- Assert new concept moving trendline - Stage 4 of 5: Move trendline to narrow the gap with closing price.
      if (II_Status[gridno]==1 && !GridxLowerNoMove)
      {
         double II_LinePrice1=ObjectGet(II_Name[gridno],OBJPROP_PRICE1);
         double II_LinePrice2=ObjectGet(II_Name[gridno],OBJPROP_PRICE2);
         if (!GridxLowerNoSell)
         {
            II_Mlimit[gridno]=II_LineLevel[gridno]+(GridxPipLimit+GridxPipMove)*Pts;
            if (Close[0]>II_Mlimit[gridno])
            {
               ObjectSet(II_Name[gridno],OBJPROP_PRICE1,II_LinePrice1+(Close[0]-II_Mlimit[gridno]));
               ObjectSet(II_Name[gridno],OBJPROP_PRICE2,II_LinePrice2+(Close[0]-II_Mlimit[gridno]));
               if (GridxDebug>=2) Print("PlusGridx: ",Symbol()," II_Check",DoubleToStr(gridno,0),": Close[0]=",DoubleToStr(Close[0],5),">II_Mlimit=",DoubleToStr(II_Mlimit[gridno],5)," II_LinePrice1=",DoubleToStr(II_LinePrice1,5)," II_LinePrice2=",DoubleToStr(II_LinePrice2,5)," Delta=",DoubleToStr(Close[0]-II_Mlimit[gridno],5));
            }
         }
         if (!GridxLowerNoBuy)
         {
            II_Mlimit[gridno]=II_LineLevel[gridno]-(GridxPipLimit+GridxPipMove)*Pts;
            if (Close[0]<II_Mlimit[gridno])
            {
               ObjectSet(II_Name[gridno],OBJPROP_PRICE1,II_LinePrice1-(II_Mlimit[gridno]-Close[0]));
               ObjectSet(II_Name[gridno],OBJPROP_PRICE2,II_LinePrice2-(II_Mlimit[gridno]-Close[0]));
               if (GridxDebug>=2) Print("PlusGridx: ",Symbol()," II_Check",DoubleToStr(gridno,0),": Close[0]=",DoubleToStr(Close[0],5),">II_Mlimit=",DoubleToStr(II_Mlimit[gridno],5)," II_LinePrice1=",DoubleToStr(II_LinePrice1,5)," II_LinePrice2=",DoubleToStr(II_LinePrice2,5)," Delta=",DoubleToStr(Close[0]-II_Mlimit[gridno],5));
            }
         }
      }
      II_Hlimit[gridno]  = II_LineLevel[gridno] + (GridxPipLimit*Pts);
      II_Hlimit1[gridno] = II_Hlimit[gridno]    + (GridxPipWide *Pts);
      II_Llimit[gridno]  = II_LineLevel[gridno] - (GridxPipLimit*Pts);
      II_Llimit1[gridno] = II_Llimit[gridno]    - (GridxPipWide *Pts);
   }
}

//|-----------------------------------------------------------------------------------------|
//|                               T R A D E   D E C I S I O N                               |
//|-----------------------------------------------------------------------------------------|
int I_Trade(int gridno)
{
   // Trade Decision
   // ==============
   if (I_LineLevel[gridno]>0)
   {
      // Buy Zone
      // ========
      if (Close[0]>I_Hlimit[gridno] && Close[0]<I_Hlimit1[gridno])
      {
      //-- Assert new concept moving trendline - Stage 2 of 5: Set Status from 0 (or 2) to 1.      
         if (!GridxUpperNoSell && I_Status[gridno]!=1 && !GridxUpperNoMove) I_Status[gridno]=1;
      //-- Assert Added option to turn off buy or sell
      //-- Assert new concept moving trendline - Stage 5 of 5: Open pending order and no need to reset Status.
         if (!GridxUpperNoBuy)
         {
            if (I_Status[gridno]!=1 && !GridxUpperNoMove)   {}   // do nothing
            else
            //--  Assert Open orders are removed
               if (GridxOpenOrd(I_Magic[gridno])==0)   return(-(GridxUpperPrefix+gridno));
               else
                  if (GridxOpenLast(I_Magic[gridno])==OP_SELL)
                  {   
                     GridxCloseOrders(I_Magic[gridno]);
                     if (GridxOneTrade && GridxOpenOrd(II_Magic[gridno])>0)    GridxCloseOrders(II_Magic[gridno]);
                     //Sleep(300);
                  //--  Assert Open orders are removed
                      return(-(GridxUpperPrefix+gridno));
                  }
               //-- Assert new concept moving trendline - Stage 6 of 5: Reset Status from 1 to 0.
                  if (GridxOpenLast(I_Magic[gridno])==OP_BUY) I_Status[gridno]=0;
         }
      }
      // Sell Zone
      // =========
   //--  Assert Added option to turn off buy or sell
      if (Close[0]<I_Llimit[gridno] && Close[0]>I_Llimit1[gridno])
      {
      //-- Assert new concept moving trendline - Stage 2 of 5: Set Status from 0 (or 2) to 1.
         if (!GridxUpperNoBuy && I_Status[gridno]!=1 && !GridxUpperNoMove) I_Status[gridno]=1;
      //-- Assert Added option to turn off buy or sell
      //-- Assert new concept moving trendline - Stage 5 of 5: Open pending order.
         if (!GridxUpperNoSell)
         {
            if (I_Status[gridno]!=1 && !GridxUpperNoMove)   {}   // do nothing
            else
            //--  Assert Open orders are removed
               if (GridxOpenOrd(I_Magic[gridno])==0)   return(GridxUpperPrefix+gridno);
               else
                  if (GridxOpenLast(I_Magic[gridno])==OP_BUY)
                  {   
                     GridxCloseOrders(I_Magic[gridno]); 
                     if (GridxOneTrade && GridxOpenOrd(II_Magic[gridno])>0)    GridxCloseOrders(II_Magic[gridno]);
                     //Sleep(300);
                  //--  Assert Open orders are removed
                     return(GridxUpperPrefix+gridno);
                  }
               //-- Assert new concept moving trendline - Stage 6 of 5: Reset Status from 1 to 0.
                  if (GridxOpenLast(I_Magic[gridno])==OP_SELL) I_Status[gridno]=0;
         }
      }
   }
}

int II_Trade(int gridno)
{
   if (II_LineLevel[gridno]>0)
   {
      // Buy Zone
      // ========
      if (Close[0]>II_Hlimit[gridno] && Close[0]<II_Hlimit1[gridno])
      {
      //-- Assert new concept moving trendline - Stage 2 of 5: Set Status from 0 (or 2) to 1.
         if (!GridxLowerNoSell && II_Status[gridno]!=1 && !GridxLowerNoMove) II_Status[gridno]=1;
      //-- Assert Added option to turn off buy or sell
      //-- Assert new concept moving trendline - Stage 5 of 5: Open pending order and no need to reset Status.
         if (!GridxLowerNoBuy)
         {
            if (II_Status[gridno]!=1 && !GridxLowerNoMove)  {}    // do nothing
            else
            //--  Assert Open orders are removed
               if (GridxOpenOrd(II_Magic[gridno])==0)   return(-(GridxLowerPrefix+gridno));
               else
                  if (GridxOpenLast(II_Magic[gridno])==OP_SELL)
                  {   
                     GridxCloseOrders(II_Magic[gridno]); 
                     if (GridxOneTrade && GridxOpenOrd(I_Magic[gridno])>0)    GridxCloseOrders(I_Magic[gridno]);
                     //Sleep(300); 
                  //--  Assert Open orders are removed
                     return(-(GridxLowerPrefix+gridno));
                  }
               //-- Assert new concept moving trendline - Stage 6 of 5: Reset Status from 1 to 0.
                  if (GridxOpenLast(II_Magic[gridno])==OP_BUY) II_Status[gridno]=0;
         }
      }
      // Sell Zone
      // =========
   //--  Assert Added option to turn off buy or sell
      if (Close[0]<II_Llimit[gridno] && Close[0]>II_Llimit1[gridno])
      {
      //-- Assert new concept moving trendline - Stage 2 of 5: Set Status from 0 (or 2) to 1.
         if (!GridxLowerNoBuy && II_Status[gridno]!=1 && !GridxLowerNoMove) II_Status[gridno]=1;
      //-- Assert Added option to turn off buy or sell
      //-- Assert new concept moving trendline - Stage 5 of 5: Open pending order.
         if (!GridxLowerNoSell)
         {
            if (II_Status[gridno]!=1 && !GridxLowerNoMove)  {}    // do nothing
            else
            //-- Assert Open orders are removed
               if (GridxOpenOrd(II_Magic[gridno])==0)   return(GridxLowerPrefix+gridno);
               else
                  if (GridxOpenLast(II_Magic[gridno])==OP_BUY)
                  {   
                     GridxCloseOrders(II_Magic[gridno]); 
                     if (GridxOneTrade && GridxOpenOrd(I_Magic[gridno])>0)    GridxCloseOrders(I_Magic[gridno]);
                     //Sleep(300); 
                  //--  Assert Open orders are removed
                     return(GridxLowerPrefix+gridno);
                  }
               //-- Assert new concept moving trendline - Stage 6 of 5: Reset Status from 1 to 0.
                  if (GridxOpenLast(II_Magic[gridno])==OP_SELL) II_Status[gridno]=0;
         }
      }
   }
}

//|-----------------------------------------------------------------------------------------|
//|                               M A I N   P R O C E D U R E                               |
//|-----------------------------------------------------------------------------------------|
int Gridx(double Pts)
{
   int wave;
   
   // Check for Trendline and Determine the Limits
   // ============================================
   for (int i=1; i<=GridxUpperNo; i++)
   {
      I_Check(i);
   }
   for (i=1; i<=GridxLowerNo; i++)
   {
      II_Check(i);
   }


   // Trade Decision
   // ==============
   for (i=1; i<=GridxUpperNo; i++)
   {
      wave=I_Trade(i);
      if (wave!=0)
      {
         if (GridxDebug>=2) Print("PlusGridx: ",Symbol()," I_Trade: wave=",DoubleToStr(wave,0));
         return(wave);
      }
   }
   for (i=1; i<=GridxLowerNo; i++)
   {
      wave=II_Trade(i);
      if (wave!=0) 
      {
         if (GridxDebug>=2) Print("PlusGridx: ",Symbol()," II_Trade: wave=",DoubleToStr(wave,0));
         return(wave);
      }
   }
   
   return(0);
}

//|-----------------------------------------------------------------------------------------|
//|                                     C O M M E N T                                       |
//|-----------------------------------------------------------------------------------------|
string I_Comment(int gridno, string cmt="")
{
   if (I_LineLevel[gridno]>0)
   {
         string strtmp = StringConcatenate("\n    ",I_Name[gridno]," : ",DoubleToStr(I_LineLevel[gridno],Digits));
         if (!GridxUpperNoMove)
            switch (I_Status[gridno])
            {
               case 0:
                  strtmp = StringConcatenate(strtmp," Waiting:");
                  break;
               case 1:
                  strtmp = StringConcatenate(strtmp," Move ",DoubleToStr(MathAbs((I_LineLevel[gridno]-I_LineLevelStart[gridno])/Pts),1)," Pending:");
                  break;
            }
         else
            strtmp = StringConcatenate(strtmp," Pending:");
         if (!GridxUpperNoBuy)    strtmp = StringConcatenate(strtmp," (Buy >",DoubleToStr(I_Hlimit[gridno],Digits)," && <",DoubleToStr(I_Hlimit1[gridno],Digits),")");
         if (!GridxUpperNoSell)   strtmp = StringConcatenate(strtmp," (Sell >",DoubleToStr(I_Llimit1[gridno],Digits)," && <",DoubleToStr(I_Llimit[gridno],Digits),")");

         strtmp = StringConcatenate(strtmp," Last Order: ");  
         switch (GridxOpenLast(I_Magic[gridno]))
         {
            case 0:  strtmp = StringConcatenate(strtmp,"BUY");    break;
            case 1:  strtmp = StringConcatenate(strtmp,"SELL");   break;
            default: strtmp = StringConcatenate(strtmp,"NIL");
         }
   }
   return(StringConcatenate(cmt,strtmp));
}

string II_Comment(int gridno, string cmt="")
{
   if (II_LineLevel[gridno]>0)
   {
         string strtmp = StringConcatenate("\n    ",II_Name[gridno]," : ",DoubleToStr(II_LineLevel[gridno],Digits));
         if (!GridxLowerNoMove)
            switch (II_Status[gridno])
            {
               case 0:
                  strtmp = StringConcatenate(strtmp," Waiting:");
                  break;
               case 1:
                  strtmp = StringConcatenate(strtmp," Move ",DoubleToStr(MathAbs((II_LineLevel[gridno]-II_LineLevelStart[gridno])/Pts),1)," Pending:");
                  break;
            }
         else
            strtmp = StringConcatenate(strtmp," Pending:");
         if (!GridxLowerNoBuy)    strtmp = StringConcatenate(strtmp," (Buy >",DoubleToStr(II_Hlimit[gridno],Digits)," && <",DoubleToStr(II_Hlimit1[gridno],Digits),")");
         if (!GridxLowerNoSell)   strtmp = StringConcatenate(strtmp," (Sell >",DoubleToStr(II_Llimit1[gridno],Digits)," && <",DoubleToStr(II_Llimit[gridno],Digits),")");

         strtmp = StringConcatenate(strtmp," Last Order: ");
         switch (GridxOpenLast(II_Magic[gridno]))
         {
            case 0:  strtmp = StringConcatenate(strtmp,"BUY");    break;
            case 1:  strtmp = StringConcatenate(strtmp,"SELL");   break;
            default: strtmp = StringConcatenate(strtmp,"NIL");
         }
   }
   return(StringConcatenate(cmt,strtmp));
}

string GridxComment(string cmt="")
{
   string strtmp = StringConcatenate(cmt,"  -->",GridxName," ",GridxVer,"<--");

   strtmp = StringConcatenate(strtmp,"\n    PipLimit=",DoubleToStr(GridxPipLimit,0)," PipWide=",DoubleToStr(GridxPipWide,0));
   if (!GridxUpperNoMove || !GridxLowerNoMove) 
      strtmp = StringConcatenate(strtmp," PipMove=",DoubleToStr(GridxPipMove,0));

//-- Check for active trendlines.
   bool active=false;
   for (int i=1; i<=GridxUpperNo; i++)
   {
      if (I_LineLevel[i]>0) active=true;
   }
   for (i=1; i<=GridxLowerNo; i++)
   {
      if (II_LineLevel[i]>0) active=true;
   }
   if (!active) strtmp = StringConcatenate(strtmp,"\n    No Active Trendlines.");
   
   for (i=1; i<=GridxUpperNo; i++)
   {
      if (I_LineLevel[i]>0) strtmp = I_Comment(i,strtmp);
   }
   for (i=1; i<=GridxLowerNo; i++)
   {
      if (II_LineLevel[i]>0) strtmp = II_Comment(i,strtmp);
   }
   
   strtmp = strtmp+"\n";
   return(strtmp);
}

//|-----------------------------------------------------------------------------------------|
//|                                O R D E R S   S T A T U S                                |
//|-----------------------------------------------------------------------------------------|
int GridxOpenLast(int mgc)
{
   int   last=-1;
      
   for (int i = 0; i < OrdersTotal(); i++)
   {
      OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      if (OrderMagicNumber() == mgc && OrderSymbol()==Symbol() && OrderType()<=1)
          last = OrderType();
   }      
   return(last);
}

int GridxOpenOrd(int mgc)
{
   int      ord=0;
   
   for (int i = 0; i < OrdersTotal(); i++)
   {
      OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      if (OrderMagicNumber() == mgc && OrderSymbol()==Symbol() && OrderType()<=1)
          ord++;
   }      
   return(ord);
}

//|-----------------------------------------------------------------------------------------|
//|                                  C L O S E  O R D E R S                                 |
//|-----------------------------------------------------------------------------------------|

void GridxCloseOrders(int mgc)
{
      int cnt,c,total=0,ticket=0,err=0;
      
      if (IsTradeAllowed() == true)
      { 
       total = OrdersTotal();
       for(cnt=total-1;cnt>=0;cnt--)
       {
          OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);

          if(OrderMagicNumber()==mgc && OrderSymbol()==Symbol())
          {
             switch(OrderType())
             {
                case OP_BUY      :
                   for(c=0;c<5;c++)
                   {
                      RefreshRates();
                      OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),3,Yellow);
                      err = GetLastError();
                      if (err==0)   break;
                      else
                      {
                         Print("Errors Closing BUY order");
                         Print(ErrorDescription(err),", error ",err);
                         if(err==0 || err==4 || err==136 || err==137 || err==138 || err==146)
                         { Sleep(5000); continue; }                            // Busy errors
                      }
                   }   
                   break;
               
                case OP_SELL     :
                   for(c=0;c<5;c++)
                   {
                      RefreshRates();
                      OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),3,Yellow);
                      err = GetLastError();
                      if (err==0) break;
                      else
                      {
                         Print("Errors Closing SELL order");
                         Print(ErrorDescription(err),", error ",err);
                         if(err==0 || err==4 || err==136 || err==137 || err==138 || err==146)
                         { Sleep(5000); continue; }                            // Busy errors
                      }
                   }   
                   break;
             } // end of switch
          } // end of if
       } // end of for
      }       
      return(0);
}

//|-----------------------------------------------------------------------------------------|
//|                       E N D   O F   E X P E R T   A D V I S O R                         |
//|-----------------------------------------------------------------------------------------|

