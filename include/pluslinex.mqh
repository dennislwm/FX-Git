//|-----------------------------------------------------------------------------------------|
//|                                                                           pluslinex.mqh |
//|                                                            Copyright © 2011, Dennis Lee |
//| Assert History                                                                          |
//| 1.32    Fixed main to use Points as argument.                                           |
//| 1.31    Fixed bug in LinexComment().                                                    |
//| 1.30    Default Trend logic is to buy and sell. Added option to turn off buy or sell:   |
//|             Linex1NoBuy                                                                 |
//|             Linex1NoSell                                                                |
//|             Linex2NoBuy                                                                 |
//|             Linex2NoSell                                                                |
//| 1.20    Comment has been changed to show:                                               |
//|             Basic settings                                                              |
//|             Trend logic                                                                 |
//| 1.10    Open orders are removed; replaced by return signals:                            |
//|             -1 Buy to open Magic 1                                                      |
//|             1 Sell to open Magic 1                                                      |
//|             -2 Buy to close Magic 1                                                     |
//|             2 Sell to close Magic 1                                                     |
//| 1.00    Copied from Linexcutor, functions that relate to trading trendlines:            |
//|             CloseOrders()   --> LinexCloseOrders()                                      |
//|             OpenLast()      --> LinexOpenLast()                                         |
//|             OpenOrd()       --> LinexOpenOrd()                                          |
//|             start()         --> Linex()                                                 |
//|                             --> LinexComment()                                          |
//|-----------------------------------------------------------------------------------------|
#property   copyright "Copyright © 2011, Dennis Lee"
#include    <stdlib.mqh>

//|-----------------------------------------------------------------------------------------|
//|                 P L U S L I N E X   E X T E R N A L   V A R I A B L E S                 |
//|-----------------------------------------------------------------------------------------|
extern   string   Linex1      = "linex1";
extern   bool     Linex1NoBuy = false;
extern   bool     Linex1NoSell= false;
extern   string   Linex2      = "linex2";
extern   bool     Linex2NoBuy = false;
extern   bool     Linex2NoSell= false;
extern   double   LinexPipLimit= 3;
extern   double   LinexPipWide = 3;
extern   int      Linex1Magic = 20090206;
extern   int      Linex2Magic = 20090207;
extern   bool     LinexOneTrade= false;

//|-----------------------------------------------------------------------------------------|
//|                           I N T E R N A L   V A R I A B L E S                           |
//|-----------------------------------------------------------------------------------------|
double   I_LineLevel, I_Hlimit, I_Llimit, I_Hlimit1, I_Llimit1;
double   II_LineLevel, II_Hlimit, II_Llimit, II_Hlimit1, II_Llimit1;
string   LinexName="PlusLinex";
string   LinexVer="1.32";

//|-----------------------------------------------------------------------------------------|
//|                               M A I N   P R O C E D U R E                               |
//|-----------------------------------------------------------------------------------------|
int Linex(double Pts)
{
   // Check for Trendline and Determine the Limits
   // ============================================
   
   if (ObjectFind(Linex1)<0) I_LineLevel = -1;
   else
   {
                               I_LineLevel = ObjectGetValueByShift(Linex1,0);
      ObjectSetText(Linex1, Linex1, 10, "Arial", Green);
   }
   I_Hlimit=0; I_Llimit=0;
   if (I_LineLevel>0)
   {
      I_Hlimit  = I_LineLevel + (LinexPipLimit*Pts);
      I_Hlimit1 = I_Hlimit    + (LinexPipWide *Pts);
      I_Llimit  = I_LineLevel - (LinexPipLimit*Pts);
      I_Llimit1 = I_Llimit    - (LinexPipWide *Pts);
   }

   if (ObjectFind(Linex2)<0)   II_LineLevel = -1;
   else                             II_LineLevel = ObjectGetValueByShift(Linex2,0);
   II_Hlimit=0; II_Llimit=0;
   if (II_LineLevel>0)
   {
      II_Hlimit  = II_LineLevel + (LinexPipLimit*Pts);
      II_Hlimit1 = II_Hlimit    + (LinexPipWide *Pts);
      II_Llimit  = II_LineLevel - (LinexPipLimit*Pts);
      II_Llimit1 = II_Llimit    - (LinexPipWide *Pts);
   }

   // Trade Decision
   // ==============
   
   if (I_LineLevel>0)
   {
   //--  Assert Added option to turn off buy or sell
      if (!Linex1NoBuy && Close[0]>I_Hlimit && Close[0]<I_Hlimit1)
      {
      //--  Assert Open orders are removed
         if (LinexOpenOrd(Linex1Magic)==0)   return(-1);
         else
            if (LinexOpenLast(Linex1Magic)==OP_SELL)
            {   
                LinexCloseOrders(Linex1Magic);
                if (LinexOneTrade && LinexOpenOrd(Linex2Magic)>0)    LinexCloseOrders(Linex2Magic);
                Sleep(3000);
            //--  Assert Open orders are removed
                return(-1);
            }
      }
   //--  Assert Added option to turn off buy or sell
      if (!Linex1NoSell && Close[0]<I_Llimit && Close[0]>I_Llimit1)
      {
      //--  Assert Open orders are removed
         if (LinexOpenOrd(Linex1Magic)==0)   return(1);
         else
            if (LinexOpenLast(Linex1Magic)==OP_BUY)
            {   
                LinexCloseOrders(Linex1Magic); 
                if (LinexOneTrade && LinexOpenOrd(Linex2Magic)>0)    LinexCloseOrders(Linex2Magic);
                Sleep(3000); 
            //--  Assert Open orders are removed
                return(1);
            }
      }
   }

   if (II_LineLevel>0)
   {
   //--  Assert Added option to turn off buy or sell
      if (!Linex2NoBuy && Close[0]>II_Hlimit && Close[0]<II_Hlimit1)
      {
      //--  Assert Open orders are removed
         if (LinexOpenOrd(Linex2Magic)==0)   return(-2);
         else
            if (LinexOpenLast(Linex2Magic)==OP_SELL)
            {   
                LinexCloseOrders(Linex2Magic); 
                if (LinexOneTrade && LinexOpenOrd(Linex1Magic)>0)    LinexCloseOrders(Linex1Magic);
                Sleep(3000); 
            //--  Assert Open orders are removed
                return(-2);
            }
      }
   //--  Assert Added option to turn off buy or sell
      if (!Linex2NoSell && Close[0]<II_Llimit && Close[0]>II_Llimit1)
      {
      //--  Assert Open orders are removed
         if (LinexOpenOrd(Linex2Magic)==0)   return(2);
         else
            if (LinexOpenLast(Linex2Magic)==OP_BUY)
            {   
                LinexCloseOrders(Linex2Magic); 
                if (LinexOneTrade && LinexOpenOrd(Linex1Magic)>0)    LinexCloseOrders(Linex1Magic);
                Sleep(3000); 
            //--  Assert Open orders are removed
                return(2);
            }
      }
   }
      
   return(0);
}

//|-----------------------------------------------------------------------------------------|
//|                                     C O M M E N T                                       |
//|-----------------------------------------------------------------------------------------|
string LinexComment(string cmt="")
{
   string strtmp = cmt+"  -->"+LinexName+" "+LinexVer+"<--";

   if (I_LineLevel<0 && II_LineLevel<0)
         strtmp = strtmp + " is not available.";
   if (I_LineLevel>=0)
   {
         strtmp = strtmp + "\n    " +Linex1+ " : " + DoubleToStr(I_LineLevel,Digits)
                         + " Pending:";
         if (!Linex1NoBuy)    strtmp = strtmp + " (Buy >" + DoubleToStr(I_Hlimit,Digits) + " && <" + DoubleToStr(I_Hlimit1,Digits) + ")";
         if (!Linex1NoSell)   strtmp = strtmp + " (Sell >" + DoubleToStr(I_Llimit1,Digits) + " && <" + DoubleToStr(I_Llimit,Digits) + ")";

         strtmp = strtmp + " Last Order: ";  
         switch (LinexOpenLast(Linex2Magic))
         {
            case 0:  strtmp = strtmp + "BUY";    break;
            case 1:  strtmp = strtmp + "SELL";   break;
            default: strtmp = strtmp + "NIL";
         }
   }
   if (II_LineLevel>=0)
   {
         strtmp = strtmp + "\n    " +Linex2+ " : " + DoubleToStr(II_LineLevel,Digits)
                         + " Pending:";
         if (!Linex2NoBuy)    strtmp = strtmp + " (Buy >" + DoubleToStr(II_Hlimit,Digits) + " && <" + DoubleToStr(II_Hlimit1,Digits) + ")";
         if (!Linex2NoSell)   strtmp = strtmp + " (Sell >" + DoubleToStr(II_Llimit1,Digits) + " && <" + DoubleToStr(II_Llimit,Digits) + ")";

         strtmp = strtmp + " Last Order: ";
         switch (LinexOpenLast(Linex2Magic))
         {
            case 0:  strtmp = strtmp + "BUY";    break;
            case 1:  strtmp = strtmp + "SELL";   break;
            default: strtmp = strtmp + "NIL";
         }
   }
                         
   strtmp = strtmp+"\n";
   return(strtmp);
}

//|-----------------------------------------------------------------------------------------|
//|                                O R D E R S   S T A T U S                                |
//|-----------------------------------------------------------------------------------------|
int LinexOpenLast(int mgc)
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

int LinexOpenOrd(int mgc)
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

void LinexCloseOrders(int mgc)
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

