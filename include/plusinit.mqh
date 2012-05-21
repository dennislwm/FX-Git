//|-----------------------------------------------------------------------------------------|
//|                                                                            PlusInit.mqh |
//|                                                            Copyright © 2012, Dennis Lee |
//| Assert History                                                                          |
//| 1.00    This file contains only internal variables used by Plus mods.                   |
//|-----------------------------------------------------------------------------------------|
#property   copyright "Copyright © 2012, Dennis Lee"

//|-----------------------------------------------------------------------------------------|
//|                           I N T E R N A L   V A R I A B L E S                           |
//|-----------------------------------------------------------------------------------------|
string   InitName="PlusInit";
string   InitVer="1.00";
//--- Assert variables
double   InitPip;
double   InitPts;

//|-----------------------------------------------------------------------------------------|
//|                             I N I T I A L I Z A T I O N                                 |
//|-----------------------------------------------------------------------------------------|
void InitInit()
{
//---- Automatically adjust to Full-Pip or Sub-Pip Accounts
   if (Digits==4||Digits==2)
   {
      InitPip=1;
      InitPts=Point;
   }
   if (Digits==5||Digits==3)
   {
      InitPip=10;
      InitPts=Point*10;
   }
//---- Automatically adjust one decimal place left for Gold
   if (Symbol()=="XAUUSD") 
   {
      InitPip*=10;
      InitPts*=10;
   }
}

//|-----------------------------------------------------------------------------------------|
//|                             D E I N I T I A L I Z A T I O N                             |
//|-----------------------------------------------------------------------------------------|
void InitDeInit()
{
//--- Assert 
}

//|-----------------------------------------------------------------------------------------|
//|                       E N D   O F   E X P E R T   A D V I S O R                         |
//|-----------------------------------------------------------------------------------------|

