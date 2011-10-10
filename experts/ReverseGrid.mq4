//|------------------------------------------------------------------------------------------| 
//|                                                                          ReverseGrid.mq4 |
//|                                                             Copyright © 2011, Dennis Lee |
//| Assert History                                                                           |
//| 1.11    Changed order of comments.                                                       |
//| 1.10    Added PlusSwiss.mqh.                                                             |
//| 1.00    Copied from TrendAuto.mq4 to ReverseGrid.mq4.                                    |
//|------------------------------------------------------------------------------------------|
#property   copyright "Copyright © 2011, Dennis Lee"
#import "WinUser32.mqh"

//---- Assert Basic externs
extern string  s1="-->PlusEasy Settings<--";
#include <pluseasy.mqh>
//---- Assert PlusSwiss externs
extern string  s2="-->PlusSwiss Settings<--";
#include <plusswiss.mqh>
//---- Assert PlusGridx externs
extern string  s3="-->PlusGridx Settings<--";
#include <plusgridx.mqh>
//---- Assert Extra externs
extern string  s4="-->Extra Settings<--";
extern int     ReverseDebug=2;
extern double  ReverseLot=0.1;

//|------------------------------------------------------------------------------------------|
//|                           I N T E R N A L   V A R I A B L E S                            |
//|------------------------------------------------------------------------------------------|
string   ReverseName="ReverseGrid";
string   ReverseVer="1.11";

// ------------------------------------------------------------------------------------------|
//                             I N I T I A L I S A T I O N                                   |
// ------------------------------------------------------------------------------------------|

int init()
{
   EasyInit();
   GridxInit();
   return(0);    
}


//|------------------------------------------------------------------------------------------|
//|                            D E - I N I T I A L I S A T I O N                             |
//|------------------------------------------------------------------------------------------|

int deinit()
{
   return(0);
}


//|------------------------------------------------------------------------------------------|
//|                               M A I N   P R O C E D U R E                                |
//|------------------------------------------------------------------------------------------|

int start()
{
   double profit;
   string strtmp;
   int waveprefix;
   int i,m;

//--- Assert PlusSwiss.mqh
   for (i=1; i<=GridxUpperNo; i++)
   {
      m=GridxUpperMagic+GridxUpperPrefix+i;
      if (EasyOrdersMagic(m)>0)
      {
         SwissEvenManager(m,Symbol(),SwissEvenAt+i,SwissEvenSlide,Pts);
         SwissTrailingStopManager(m,Symbol(),SwissTrailingStop+i,SwissOnlyTrailProfits,Pts);
      }
   }
   for (i=1; i<=GridxLowerNo; i++)
   {
      m=GridxLowerMagic+GridxLowerPrefix+i;
      if (EasyOrdersMagic(m)>0)
      {
         SwissEvenManager(m,Symbol(),SwissEvenAt+i,SwissEvenSlide,Pts);
         SwissTrailingStopManager(m,Symbol(),SwissTrailingStop+i,SwissOnlyTrailProfits,Pts);
      }
   }

   waveprefix=Gridx(Pts);
   if (waveprefix!=0 && ReverseDebug>=1) Print(ReverseName," ",ReverseVer,": ", Symbol(),": waveprefix=",waveprefix);
   if (MathAbs(waveprefix)>GridxLowerPrefix)
   {
      if (waveprefix>0)
      {
         if (EasySell(GridxLowerMagic+waveprefix,ReverseLot)>0)
         {
            ObjectDelete(StringConcatenate(GridxLower,waveprefix));
            strtmp = DoubleToStr(GridxLowerMagic+waveprefix,0) + ": " + Symbol() + " Open Sell " + DoubleToStr(Close[0],Digits);   
         }
      }
      else
      {
         if (EasyBuy(GridxLowerMagic+MathAbs(waveprefix),ReverseLot)>0)
         {
            ObjectDelete(StringConcatenate(GridxLower,MathAbs(waveprefix)));
            strtmp = DoubleToStr(GridxLowerMagic+MathAbs(waveprefix),0) + ": " + Symbol() + " Open Buy " + DoubleToStr(Close[0],Digits);
         }
      }
      
   }
   else if (MathAbs(waveprefix)>GridxUpperPrefix && MathAbs(waveprefix)<=GridxLowerPrefix)
   {
      if (waveprefix>0)
      {
         if (EasySell(GridxUpperMagic+waveprefix,ReverseLot)>0)
         {
            ObjectDelete(StringConcatenate(GridxUpper,waveprefix));
            strtmp = DoubleToStr(GridxUpperMagic+waveprefix,0) + ": " + Symbol() + " Open Sell " + DoubleToStr(Close[0],Digits);
         }
      }
      else
      {
         if (EasyBuy(GridxUpperMagic+MathAbs(waveprefix),ReverseLot)>0)
         {
            ObjectDelete(StringConcatenate(GridxUpper,MathAbs(waveprefix)));
            strtmp = DoubleToStr(GridxUpperMagic+MathAbs(waveprefix),0) + ": " + Symbol() + " Open Buy " + DoubleToStr(Close[0],Digits);
         }
      }
   }
   if (waveprefix!=0 && ReverseDebug>=1) Print(ReverseName," ",ReverseVer,": ",strtmp);

   strtmp=ReverseComment();
   for (i=1; i<=GridxUpperNo; i++)
   {
      m=GridxUpperMagic+GridxUpperPrefix+i;
      profit=profit+EasyProfitsMagic(m);
   }
   for (i=1; i<=GridxLowerNo; i++)
   {
      m=GridxLowerMagic+GridxLowerPrefix+i;
      profit=profit+EasyProfitsMagic(m);
   }
   strtmp=EasyComment(profit,strtmp);
   strtmp=SwissComment(strtmp);
   strtmp=GridxComment(strtmp);
   Comment(strtmp);
   return(0);
}

//|-----------------------------------------------------------------------------------------|
//|                                     C O M M E N T                                       |
//|-----------------------------------------------------------------------------------------|
string ReverseComment(string cmt="")
{
   string strtmp = cmt+"-->"+ReverseName+" "+ReverseVer+"<--";

//--- Assert additional comments here
   strtmp = strtmp+"\n  Lot="+DoubleToStr(ReverseLot,2);
   
   strtmp = strtmp+"\n";
   return(strtmp);
}

//|------------------------------------------------------------------------------------------|
//|                       E N D   O F   E X P E R T   A D V I S O R                          |
//|------------------------------------------------------------------------------------------|

