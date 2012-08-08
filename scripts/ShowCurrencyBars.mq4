//+------------------------------------------------------------------+
//|                                             ShowCurrencyBars.mq4 |
//|                                 Copyright © 2011, George Heitman |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2011, George Heitman"
#property link      "http://www.metaquotes.net"

//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+

string m="";
string s[50];
string PairArray[8] ;

int start()
  {
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

  string res="";
  for (i=0;i<x;i++)
     res = res + s[i] + "\t" + iBars(s[i],Period()) + "\n";
  MessageBox(res);
   return(0);
  }
//+------------------------------------------------------------------+