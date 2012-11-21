//|-----------------------------------------------------------------------------------------|
//|                                                                          PlusExpect.mqh |
//|                                                            Copyright © 2012, Dennis Lee |
//| Assert History                                                                          |
//| 1.0.0    Created PlusTest and PlusExpect to perform unit tests of MQ4 functions.        |
//|-----------------------------------------------------------------------------------------|
#property   copyright "Copyright © 2012, Dennis Lee"

//|-----------------------------------------------------------------------------------------|
//|                           E X T E R N A L   V A R I A B L E S                           |
//|-----------------------------------------------------------------------------------------|

//|-----------------------------------------------------------------------------------------|
//|                           I N T E R N A L   V A R I A B L E S                           |
//|-----------------------------------------------------------------------------------------|
string   ExpectName  ="PlusExpect";
string   ExpectVer   ="1.0.0";

//|-----------------------------------------------------------------------------------------|
//|                           E X T E R N A L   F U N C T I O N S                           |
//|-----------------------------------------------------------------------------------------|
bool ExpectTrueBln(bool x)
{
   return(x);
}
bool ExpectFalseBln(bool x)
{
   return(!x);
}
bool ExpectEqualInt(int x, int y)
{
   return(x==y);
}
bool ExpectEqualDbl(int x, int y)
{
   return(x==y);
}
bool ExpectEqualStr(string x, string y)
{
   return(x==y);
}
bool ExpectGreaterInt(int x, int y)
{
   return(x>y);
}
bool ExpectGreaterDbl(double x, double y)
{
   return(x>y);
}
bool ExpectGreaterEqualInt(int x, int y)
{
   return(x>=y);
}
bool ExpectGreaterEqualDbl(double x, double y)
{  
   return(x>=y);
}
bool ExpectLesserInt(int x, int y)
{
   return(x<y);
}
bool ExpectLesserDbl(double x, double y)
{
   return(x<y);
}
bool ExpectLesserEqualInt(int x, int y)
{
   return(x<=y);
}
bool ExpectLesserEqualDbl(double x, double y)
{
   return(x<=y);
}

//|-----------------------------------------------------------------------------------------|
//|                                     C O M M E N T                                       |
//|-----------------------------------------------------------------------------------------|

//|-----------------------------------------------------------------------------------------|
//|                       E N D   O F   E X P E R T   A D V I S O R                         |
//|-----------------------------------------------------------------------------------------|