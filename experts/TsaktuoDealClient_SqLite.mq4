//|-----------------------------------------------------------------------------------------|
//|                                                            TsaktuoDealClient_SqLite.mq4 |
//|                                                            Copyright © 2012, Dennis Lee |
//| Assert History                                                                          |
//| 1.0.2   Added PlusTD to provide support functions for TDSetup indicator.                |
//| 1.0.1   Added PlusInit, PlusTurtle, and PlusGhost.                                      |
//|            a) Functions that have non-Nested non-Select Ghost calls:                    |
//|                  DealIN()                                                               |
//|                  CloseOneOrder()                                                        |
//|            b) Functions that have non-Nested Select Ghost calls:                        |
//|                  DealOUT()                                                              |
//|                  DealOUT_ALL()                                                          |
//|            c) Functions that have Nested Select Ghost calls: NIL                        |
//| 1.00    Originated from MQL5 Article ( see http://www.mql5.com/en/articles/344 ), and   |
//|            authored by Karlis Balcers ( Tsaktuo ).                                      |
//|-----------------------------------------------------------------------------------------|
#property copyright "Copyright © 2012, Dennis Lee"
#property link      "http://www.metaquotes.net"

#include <winsock.mqh>  // Downloaded from MQ4 homepage
                        // DOWNLOAD:   http://codebase.mql4.com/download/18644
                        // ARTICLE:    http://codebase.mql4.com/6122

#property show_inputs   // Show input values

//--- definitions
#define OP_IN 0
#define OP_OUT 1
#define OP_INOUT 2
#define OP_OUTALL 3 // Custom DEAL ENTRY type.
//--- Assert 5: Plus include files
#include <PlusInit.mqh>
extern string     s1             = "-->PlusTD Settings<--";
#include <PlusTD.mqh>
extern   string   s2             ="-->PlusTurtle Settings<--";
#include <PlusTurtle.mqh>
extern   string   s3             ="-->PlusGhost Settings<--";
#include <PlusGhost.mqh>
//|-----------------------------------------------------------------------------------------|
//|                           E X T E R N A L   V A R I A B L E S                           |
//|-----------------------------------------------------------------------------------------|
extern int     EaMaxAccountTrades      = 2;
extern bool    EaViewDebugNotify       = false;
extern int     EaViewDebug             = 0;
extern int     EaViewDebugNoStack      = 1000;
extern int     EaViewDebugNoStackEnd   = 10;
extern int     InpServerPort=2011;
extern string  InpServerIP="127.0.0.1";
extern int     InpVolumePrecision=2;
extern int     InpSlippage=3;
extern string _1="--- LOT MAPPING ---";
extern double  InpMinLocalLotSize=0.01;
extern double  InpMaxLocalLotSize=1.00; // Recomended bigger than
extern double  InpMinRemoteLotSize =      0.01;
extern double  InpMaxRemoteLotSize =      15.00;
//|-----------------------------------------------------------------------------------------|
//|                           I N T E R N A L   V A R I A B L E S                           |
//|-----------------------------------------------------------------------------------------|
string   EaName         = "TsaktuoDealClient_SqLite";
string   EaVer          = "1.0.2";
int      iSocketHandle  =0;
//|-----------------------------------------------------------------------------------------|
//|                              I N I T I A L I S A T I O N                                |
//|-----------------------------------------------------------------------------------------|
int init() {
//--- Assert 3: Init Plus   
   InitInit();
   TDInit();
   TurtleInit();
   GhostInit();
   return(0);
}
//|-----------------------------------------------------------------------------------------|
//|                            D E - I N I T I A L I S A T I O N                            |
//|-----------------------------------------------------------------------------------------|
int deinit() {
//--- Assert 1: DeInit Plus
   GhostDeInit();
   return (0);
}
//|-----------------------------------------------------------------------------------------|
//|                               M A I N   P R O C E D U R E                               |
//|-----------------------------------------------------------------------------------------|
int start()
  {
   int iBuffer[100];
   int iRetVal;
   int iAddr[1];
   int iServer[sockaddr_in];
   int hp;
   int wsaData[WSADATA];
   string sLeftOver="";

   Print("Client version: 1.0, Author:Tsaktuo, Year 2011");

//--- prepare for socket connection
   iRetVal=WSAStartup(0x202,wsaData);
   if(iRetVal!=0)
     {
      Print("Client: WSAStartup() failed with error "+iRetVal);
      return(-1);
     }
   else
     {
      Print("Client: WSAStartup() is OK.");
     }
   iAddr[0]=inet_addr(InpServerIP);
   hp=gethostbyaddr(iAddr[0],4,AF_INET);
   Print("Client: Server addr:"+iAddr[0]+" hp"+hp);
   int2struct(iServer,sin_addr,iAddr[0]);
   int2struct(iServer,sin_family,AF_INET);
   int2struct(iServer,sin_port,htons(InpServerPort));

//--- create socket
   iSocketHandle=socket(AF_INET,SOCK_STREAM,0);
   if(iSocketHandle<0)
     {
      Print("Client: Error Opening socket: Error "+WSAGetLastError());
      return(-1);
     }
   else
     {
      Print("Client: socket() is OK.");
     }

//--- connect socket to server
   Print("Client: Client connecting to: "+InpServerIP);
   iRetVal=connect(iSocketHandle,iServer,ArraySize(iServer)<<2);
   if(iRetVal==SOCKET_ERROR)
     {
      if(WSAGetLastError()==WSAECONNREFUSED)
        {
         Print("Client: connect() failed. Server is not running.");
        }
      else
        {
         Print("Client: connect() failed: ",WSAGetLastError());
        }
      return(-1);
     }
   else
      Print("Client: connect() is OK.");

//--- server up and running. Start data collection and processing
   while(!IsStopped())
     {
      Print("Client: Waiting for DEAL...");
   //--- Assert 2: Refresh Plus   
      GhostRefresh();
      Comment(EaComment());
      ArrayInitialize(iBuffer,0);
      iRetVal=recv(iSocketHandle,iBuffer,ArraySize(iBuffer)<<2,0);
      if(iRetVal>0)
        {
         string sRawData=struct2str(iBuffer,iRetVal<<18);
         Print("Received("+iRetVal+"): "+sRawData);
         //--- check if there is nothing to add from previously received packages
         if(StringLen(sLeftOver)>0)
           {
            sRawData = StringConcatenate(sLeftOver,sRawData);
            iRetVal += StringLen(sLeftOver);
            Print("Leftover from previous package added:("+iRetVal+"): "+sRawData);
            sLeftOver=""; // Clear leftover.
           }
         //--- split records
         string arrDeals[];
         //--- split raw data in multiple deals (in case if more than one is received).
         int iDealsReceived=Split(sRawData,"<",10,arrDeals);
         Print("Found ",iDealsReceived," deal orders.");
         //--- process each record
         //--- go through all DEALs received
         for(int j=0;j<iDealsReceived;j++) 
           {
            //--- split each record to values
            string arrValues[];
            //--- split each DEAL in to values
            int iValuesInDeal=Split(arrDeals[j],";",10,arrValues);
            //--- verify if DEAL request received in correct format (with correct count of values)
            if(iValuesInDeal==6)
              {
               if(ProcessOrderRaw(arrValues[0],arrValues[1],arrValues[2],arrValues[3],arrValues[4],StringSubstr(arrValues[5],0,StringLen(arrValues[5])-1)))
                 {
                  Print("Processing of order done sucessfully.");
                 }
               else
                 {
                  Print("Processing of order failed:\"",arrDeals[j],"\"");
                 }
              }
            else
              {
               Print("Invalid order received:\"",arrDeals[j],"\"");
               //--- this was last one in array
               if(j==iDealsReceived-1)
                 {
                  //--- it might be incompleate beginning of next deal.
                  sLeftOver=arrDeals[j];
                 }
              }
           }
        }
      else if(iRetVal<=0)
        {
         Print("Client: recv() failed: error ",WSAGetLastError());
         break;
        }
      //--- sleep is not necessary because recv() function is blocking 
      //--- and will not return before something is received.
     }
//--- close socket is it's still opened
   if(iSocketHandle>0)
     {
      Print("Closing connection...");
      closesocket(iSocketHandle);
     }
   WSACleanup();
   Print("Client stopped.");
   return(0);
  }
//|-----------------------------------------------------------------------------------------|
//|                           I N T E R N A L   F U N C T I O N S                           |
//|-----------------------------------------------------------------------------------------|
//=======================================  UTILS ==================================================
//+------------------------------------------------------------------+
//| Function to split text in multiple strings.                      |
//+------------------------------------------------------------------+
int Split(string text,string splitter,int max,string &array[])
  {
   int iStart = 0;
   int iCount = 0;
   int iPreviousStart=0;

   if(ArrayResize(array,0)!=0)
      Print("Failed to resize array to 0.");

   while(iStart>=0)
     {
      iStart=StringFind(text,splitter,iPreviousStart);
      if(iStart>=0)
        {
         iStart++;
         if(iStart-iPreviousStart-1>0)
           {
            ArrayResize(array,iCount+1);
            array[iCount]=StringSubstr(text,iPreviousStart,iStart-iPreviousStart-1);
            iCount++;
           }
         iPreviousStart=iStart;
         if(iCount>=max)
           {
            return(iCount);
           }
        }
      else
        {
         ArrayResize(array,iCount+1);
         array[iCount]=StringSubstr(text,iPreviousStart,EMPTY);
         iCount++;
        }
     }
   return(iCount);
  }
//+------------------------------------------------------------------+
//| Trim                                                             |
//+------------------------------------------------------------------+
string Trim(string text)
  {
   return(StringTrimRight(StringTrimLeft(text)));
  }
//+------------------------------------------------------------------+
//| Validate format of account number                                |
//+------------------------------------------------------------------+
bool ValidateAccountNumber(string account)
  {
   if(StringLen(account)==0)
      return(false);
   if(StrToInteger(account)>0)
      return(true);
   return(false);
  }
//+------------------------------------------------------------------+
//| Validate format of received symbol                               |
//+------------------------------------------------------------------+
bool ValidateSymbol(string symbol)
  {
   if(StringLen(symbol)==0)
      return(false);
   if(MarketInfo(symbol,MODE_DIGITS)>0)
      return(true);
   return(false);
  }
//+------------------------------------------------------------------+
//| Valudate DEAL type                                               |
//+------------------------------------------------------------------+
bool ValidateType(string type)
  {
   if(StringLen(type)==0)
      return(false);
   if(type=="BUY")
      return(true);
   if(type=="SELL")
      return(true);
   return(false);
  }
//+------------------------------------------------------------------+
//| Validate DEAL ENTRY type                                         |
//+------------------------------------------------------------------+
bool ValidateEntry(string entry)
  {
   if(StringLen(entry)==0)
      return(false);
   if(entry=="IN")
      return(true);
   if(entry=="OUT")
      return(true);
   if(entry=="INOUT")
      return(true);
  //--- support for custom format too. (more info in MQL5 TsaktuoDealServer source code)
   if(entry=="OUTALL") 
      return(true);
   return(false);
  }
//+------------------------------------------------------------------+
//| Validate format of volume                                        |
//+------------------------------------------------------------------+
bool ValidateVolume(string volume)
  {
   if(StringLen(volume)==0)
      return(false);
   if(StrToDouble(volume)>0)
      return(true);
   return(false);
  }
//+------------------------------------------------------------------+
//| Validate format of price                                         |
//+------------------------------------------------------------------+
bool ValidatePrice(string price)
  {
   if(StringLen(price)==0)
      return(false);
   if(StrToDouble(price)>0)
      return(true);
   return(false);
  }
//+------------------------------------------------------------------+
//| Convert text to DEAL TYPE                                        |
//+------------------------------------------------------------------+
int String2Type(string type)
  {
   if(type=="BUY")
      return(OP_BUY);
   if(type=="SELL")
      return(OP_SELL);
   return(-1);
  }
//+------------------------------------------------------------------+
//| Convert DEAL TYPE to text                                        |
//+------------------------------------------------------------------+
string Type2String(int type)
  {
   if(type==OP_BUY)
      return("BUY");
   if(type==OP_SELL)
      return("SELL");
   return("?");
  }
//+------------------------------------------------------------------+
//| Convert text to DEAL ENTRY                                       |
//+------------------------------------------------------------------+
int String2Entry(string entry)
  {
   if(entry=="IN")
      return(OP_IN);
   if(entry=="OUT")
      return(OP_OUT);
   if(entry=="INOUT")
      return(OP_INOUT);
   if(entry=="OUTALL")
      return(OP_OUTALL);
   return(-1);
  }
//+------------------------------------------------------------------+
//| Convert DEAL ENTRY to text                                       |
//+------------------------------------------------------------------+
string Entry2String(int entry)
  {
   if(entry==OP_IN)
      return("IN");
   if(entry==OP_OUT)
      return("OUT");
   if(entry==OP_INOUT)
      return("INOUT");
   if(entry==OP_OUTALL)
      return("OUTALL");
   return("?");
  }
//======================================= TRADING ==================================================

//+------------------------------------------------------------------+
//| Processing received raw data (text format)                       |
//+------------------------------------------------------------------+
bool ProcessOrderRaw(string saccount,string ssymbol,string stype,string sentry,string svolume,string sprice)
  {
//--- clearing
   saccount= Trim(saccount);
   ssymbol = Trim(ssymbol);
   stype=Trim(stype);
   sentry=Trim(sentry);
   svolume= Trim(svolume);
   sprice = Trim(sprice);
//--- validations
   if(!ValidateAccountNumber(saccount)){Print("Invalid account:",saccount);return(false);}
   if(!ValidateSymbol(ssymbol)){Print("Invalid symbol:",ssymbol);return(false);}
   if(!ValidateType(stype)){Print("Invalid type:",stype);return(false);}
   if(!ValidateEntry(sentry)){Print("Invalid entry:",sentry);return(false);}
   if(!ValidateVolume(svolume)){Print("Invalid volume:",svolume);return(false);}
   if(!ValidatePrice(sprice)){Print("Invalid price:",sprice);return(false);}
//--- convertations
   int account=StrToInteger(saccount);
   string symbol=ssymbol;
   int type=String2Type(stype);
   int entry=String2Entry(sentry);
   double volume= GetLotSize(StrToDouble(svolume),symbol);
   double price = NormalizeDouble(StrToDouble(sprice),(int)MarketInfo(ssymbol,MODE_DIGITS));
   Print("DEAL[",account,"|",symbol,"|",Type2String(type),"|",Entry2String(entry),"|",volume,"|",price,"]");
//--- execution
   ProcessOrder(account,symbol,type,entry,volume,price);
   return(true);
  }
//+------------------------------------------------------------------+
//| Process order with converted and verified values                 |
//+------------------------------------------------------------------+
void ProcessOrder(int account,string symbol,int type,int entry,double volume,double price)
  {
   if(entry==OP_IN)
     {
      DealIN(symbol,type,volume,price,0,0,account);
     }
   else if(entry==OP_OUT)
     {
      DealOUT(symbol,type,volume,price,0,0,account);
     }
   else if(entry==OP_INOUT)
     {
      DealOUT_ALL(symbol,type,account);
      DealIN(symbol,type,volume,price,0,0,account);
     }
   else if(entry==OP_OUTALL)
     {
      DealOUT_ALL(symbol,type,account);
     }
  }
//+------------------------------------------------------------------+
//| Process DEAL ENTRY IN                                            |
//+------------------------------------------------------------------+
void DealIN(string symbol,int cmd,double volume,double price,double stoploss,double takeprofit,int account)
  {
   double prc=0;

//--- Assert TDWave1
   bool  isWave1Ok;
   
   if(cmd==OP_SELL)
   {
      isWave1Ok = TDWave1Sell();
      prc= MarketInfo(symbol,MODE_BID);
   }
   else if(cmd==OP_BUY)
   {
      isWave1Ok = TDWave1Buy();
      prc=MarketInfo(symbol,MODE_ASK);
   }
//--- Assert exit do not open a new trade
   if( !isWave1Ok ) return(0);
   
   string comment="IN."+Type2String(cmd);

   int iRetVal=GhostOrderSend(symbol,cmd,volume,prc,InpSlippage,stoploss,takeprofit,comment,account);
   if(iRetVal<0)
     {
      int retries=0;
      int error=0;

      while(iRetVal<0 && retries<10)
        {
         error=GetLastError();
         Print("DealIN error code: ",error);
         //--- no reason for retry
         if(error!=146 && error!=4 && error!=6)
            break;

         Sleep(500);

         if(cmd==OP_SELL)
            prc= MarketInfo(symbol,MODE_BID);
         else if(cmd==OP_BUY)
            prc=MarketInfo(symbol,MODE_ASK);

         iRetVal=GhostOrderSend(symbol,cmd,volume,prc,InpSlippage,stoploss,takeprofit,comment,account);

         if(iRetVal<0) retries++;
         else break;
        }
     }
   if(iRetVal<=0)
      Print("Failed to execute order! Error: ",GetLastError());
   else
     {
      EaDebugPrint( 0, "DealIN",
         EaDebugStr("EaName", EaName)+
         EaDebugStr("EaVer", EaVer)+
         EaDebugStr("sym", Symbol())+
         EaDebugInt("mgc", account)+
         EaDebugInt("port", InpServerPort)+
         EaDebugInt("ticket", iRetVal)+
         EaDebugInt("type", cmd)+
         EaDebugDbl("lot", volume)+
         EaDebugDbl("openPrice", prc)+
         TDDebugGlobal()+
         EaDebugBln("TDWave1", true) );
     }
  }
//+------------------------------------------------------------------+
//| Process DEAL ENTRY OUT                                           |
//+------------------------------------------------------------------+
void DealOUT(string symbol,int cmd,double volume,double price,double stoploss,double takeprofit,int account)
  {
   int type=-1;
   int i=0;

   if(cmd==OP_SELL)
      type=OP_BUY;
   else if(cmd==OP_BUY)
      type=OP_SELL;

   string comment="OUT."+Type2String(cmd);

//--- search for orders with equal VOLUME size
//--- Assert 4: Declare variables for OrderSelect #1
//       1-CloseOneOrder()
   int      aCommand[];    
   int      aTicket[];
   bool     aOk;
   int      aCount;
//--- Assert 2: Dynamically resize arrays
   ArrayResize(aCommand,EaMaxAccountTrades);
   ArrayResize(aTicket,EaMaxAccountTrades);
//--- Assert 2: Init OrderSelect #1
   int total = GhostOrdersTotal();
   GhostInitSelect(true,0,SELECT_BY_POS,MODE_TRADES);
   for(i=0;i<total;i++)
     {
      if(GhostOrderSelect(i,SELECT_BY_POS))
        {
      //--- Assert 2: Populate selected #1
         aCommand[aCount]     = 0;
         aTicket[aCount]      = GhostOrderTicket();
         if(GhostOrderMagicNumber()==account)
           {
            if(GhostOrderSymbol()==symbol)
              {
               if(GhostOrderType()==type)
                 {
                  if(GhostOrderLots()==volume)
                    {
                  //--- Assert 3: Populate selected #1
                     aCommand[aCount]  = 1;
                     aCount ++;
                     break;
                     /*if(CloseOneOrder(OrderTicket(),symbol,type,volume))
                       {
                        Print("Order with exact volume found and executed.");
                        return;
                       }*/
                    }
                 }
              }
           }
        }
     }
//--- Assert 1: Free OrderSelect #1
   GhostFreeSelect(false);
//--- Assert for: process array of commands
   for(i=0; i<aCount; i++)
   {
      switch( aCommand[i] )
      {
         case 1:
            aOk = CloseOneOrder( aTicket[i], symbol, type, volume );
            break;
      }
   }
   if(aOk)
   {
      Print("Order with exact volume found and executed.");
      return;
   }
   
   double volume_to_clear=volume;
//--- search for orders with smaller volume
//--- Assert 5: Declare variables for OrderSelect #2
//       2-CloseOneOrder() with smaller volume
   int      bCommand[];    
   int      bTicket[];
   double   bLots[];
   bool     bOk;
   int      bCount;
//--- Assert 3: Dynamically resize arrays
   ArrayResize(bCommand,EaMaxAccountTrades);
   ArrayResize(bTicket,EaMaxAccountTrades);
   ArrayResize(bLots,EaMaxAccountTrades);
//--- Assert 2: Init OrderSelect #2
   int limit = GhostOrdersTotal();
   GhostInitSelect(true,0,SELECT_BY_POS,MODE_TRADES);
   for(i=0;i<limit;i++)
     {
      if(GhostOrderSelect(i,SELECT_BY_POS))
        {
      //--- Assert 3: Populate selected #2
         bCommand[bCount]     = 0;
         bTicket[bCount]      = GhostOrderTicket();
         bLots[bCount]        = GhostOrderLots();
         if(GhostOrderMagicNumber()==account)
           {
            if(GhostOrderSymbol()==symbol)
              {
               if(GhostOrderType()==type)
                 {
                  if(GhostOrderLots()<=volume_to_clear)
                    {
                  //--- Assert 3: Populate selected #2
                     bCommand[bCount]  = 2;
                     bCount ++;
                     if( bCount >= EaMaxAccountTrades ) break;
                     volume_to_clear-=GhostOrderLots();
                     if( volume_to_clear==0 ) break;
                     /*if(CloseOneOrder(OrderTicket(),symbol,type,OrderLots()))
                       {
                        Print("Order with smaller volume found and executed.");
                        volume_to_clear-=OrderLots();
                        if(volume_to_clear==0)
                          {
                           Print("All necessary volume is closed.");
                           return;
                          }
                        limit=OrdersTotal();
                        //--- because it will be increased at end of cycle and will have value 0.
                        i=-1; 
                       }*/
                    }
                 }
              }
           }
        }
     }
//--- Assert 1: Free OrderSelect #2
   GhostFreeSelect(false);
//--- Assert for: process array of commands
   for(i=0; i<bCount; i++)
   {
      switch( bCommand[i] )
      {
         case 2:
            bOk = CloseOneOrder( bTicket[i], symbol, type, bLots[i] );
            if( bOk ) Print("Order with smaller volume found and executed.");
            break;
      }
   }
   if(bOk && volume_to_clear==0)
   {
      Print("All necessary volume is closed.");
      return;
   }

//--- search for orders with higher volume
//--- Assert 7: Declare variables for OrderSelect #3
//       3-CloseOneOrder() with smaller volume  4- DealIN()
   int      cCommand[];    
   int      cTicket[];
   double   cLots[];
   double   cStopLoss[];
   double   cTakeProfit[];
   bool     cOk;
   int      cCount;
//--- Assert 3: Dynamically resize arrays
   ArrayResize(cCommand,EaMaxAccountTrades);
   ArrayResize(cTicket,EaMaxAccountTrades);
   ArrayResize(cLots,EaMaxAccountTrades);
   ArrayResize(cStopLoss,EaMaxAccountTrades);
   ArrayResize(cTakeProfit,EaMaxAccountTrades);
//--- Assert 2: Init OrderSelect #3
   limit = GhostOrdersTotal();
   GhostInitSelect(true,0,SELECT_BY_POS,MODE_TRADES);
   for(i=0;i<limit;i++)
     {
      if(GhostOrderSelect(i,SELECT_BY_POS))
        {
      //--- Assert 5: Populate selected #3
         cCommand[cCount]     = 0;
         cTicket[cCount]      = GhostOrderTicket();
         cLots[cCount]        = GhostOrderLots();
         cStopLoss[cCount]    = GhostOrderStopLoss();
         cTakeProfit[cCount]  = GhostOrderTakeProfit();
         if(GhostOrderMagicNumber()==account)
           {
            if(GhostOrderSymbol()==symbol)
              {
               if(GhostOrderType()==type)
                 {
                  if(GhostOrderLots()>=volume_to_clear)
                    {
                  //--- Assert 3: Populate selected #3
                     cCommand[cCount]  = 3;
                     cCount ++;
                     if( cCount >= EaMaxAccountTrades ) break;
                     volume_to_clear-=GhostOrderLots();
                     if( volume_to_clear<0 )
                       {
                        //--- open new to compensate lose
                     //--- Assert 3: Populate selected #3
                        cCommand[cCount]  = 4;
                        cCount ++;
                        break;
                       }
                     else if( volume_to_clear==0 )
                       {
                        Print("All necessary volume is closed.");
                        break;
                       }
                     /*if(CloseOneOrder(OrderTicket(),symbol,type,OrderLots()))
                       {
                        Print("Order with smaller volume found and executed.");
                        volume_to_clear-=OrderLots();
                        //--- closed too much
                        if(volume_to_clear<0)
                          {
                           //--- open new to compensate lose
                           DealIN(symbol,type,volume_to_clear,price,OrderStopLoss(),OrderTakeProfit(),account);
                          }
                        else if(volume_to_clear==0)
                          {
                           Print("All necessary volume is closed.");
                           return;
                          }
                       }*/
                    }
                 }
              }
           }
        }
     }
//--- Assert 1: Free OrderSelect #3
   GhostFreeSelect(false);
//--- Assert for: process array of commands
   for(i=0; i<cCount; i++)
   {
      switch( cCommand[i] )
      {
         case 3:
            cOk = CloseOneOrder( cTicket[i], symbol, type, cLots[i] );
            if( cOk ) Print("Order with smaller volume found and executed.");
            break;
         case 4:
            DealIN( symbol, type, MathAbs(volume_to_clear), price, cStopLoss[i], cTakeProfit[i], account );
            break;
      }
   }
   if(cOk && volume_to_clear==0)
   {
      Print("All necessary volume is closed.");
      return;
   }
   
   if(volume_to_clear!=0)
     {
      Print("Some volume left unclosed: ",volume_to_clear);
     }
  }
//+------------------------------------------------------------------+
//| Close one specific order                                         |
//+------------------------------------------------------------------+
bool CloseOneOrder(int ticket,string symbol,int cmd,double lots)
  {
   double prc=0;
   if(cmd==OP_SELL)
      prc= MarketInfo(symbol,MODE_ASK);
   else if(cmd==OP_BUY)
      prc=MarketInfo(symbol,MODE_BID);

   int iRetVal=GhostOrderClose(ticket,lots,prc,InpSlippage);
   if(iRetVal<0)
     {
      int retries=0;
      int error=0;

      while(iRetVal<0 && retries<10)
        {
         error=GetLastError();
         Print("DealOUT error code: ",error);
         //--- no reason for retry
         if(error!=146 && error!=4 && error!=6)
            break;

         Sleep(500);

         if(cmd==OP_SELL)
            prc= MarketInfo(symbol,MODE_ASK);
         else if(cmd==OP_BUY)
            prc=MarketInfo(symbol,MODE_BID);

         iRetVal=GhostOrderClose(ticket,lots,prc,InpSlippage);

         if(iRetVal<0) retries++;
         else break;
        }

      if(iRetVal<0)
        {
         Print("Failed to execute order! Error: ",GetLastError());
         return(false);
        }
     }
   return(true);
  }
//+------------------------------------------------------------------+
//| Close ALL orders with specified symbol                           |
//+------------------------------------------------------------------+
void DealOUT_ALL(string symbol,int cmd,int account)
  {
   int type=-1;

   if(cmd==OP_SELL)
      type=OP_BUY;
   else if(cmd==OP_BUY)
      type=OP_SELL;

//--- Search all orders
//--- Assert 5: Declare variables for OrderSelect #4
//       1-CloseOneOrder()
   int      aCommand[];    
   int      aTicket[];
   double   aLots[];
   bool     aOk;
   int      aCount;
//--- Assert 3: Dynamically resize arrays
   ArrayResize(aCommand,EaMaxAccountTrades);
   ArrayResize(aTicket,EaMaxAccountTrades);
   ArrayResize(aLots,EaMaxAccountTrades);
//--- Assert 2: Init OrderSelect #4
   int limit = GhostOrdersTotal();
   GhostInitSelect(true,0,SELECT_BY_POS,MODE_TRADES);
   for(int i=0;i<limit;i++)
     {
      if(GhostOrderSelect(i,SELECT_BY_POS))
        {
      //--- Assert 2: Populate selected
         aCommand[aCount]     = 0;
         aTicket[aCount]      = GhostOrderTicket();
         aLots[aCount]        = GhostOrderLots();
         if(GhostOrderMagicNumber()==account)
           {
            if(GhostOrderSymbol()==symbol)
              {
               if(GhostOrderType()==type)
                 {
                  //--- Assert 3: Populate selected
                     aCommand[aCount]  = 1;
                     aCount ++;
                     if( aCount >= EaMaxAccountTrades ) break;
                  /*if(CloseOneOrder(OrderTicket(),symbol,type,OrderLots()))
                    {
                     Print("OUT_ALL: Order found and executed.");
                     limit=OrdersTotal();
                     //--- because it will be increased at end of cycle and will have value 0.
                     i=-1; 
                    }*/
                 }
              }
           }
        }
     }
//--- Assert 1: Free OrderSelect #4
   GhostFreeSelect(false);
//--- Assert for: process array of commands
   for(i=0; i<aCount; i++)
   {
      switch( aCommand[i] )
      {
         case 1:
            aOk = CloseOneOrder( aTicket[i], symbol, type, aLots[i] );
            if(aOk) Print("OUT_ALL: Order found and executed.");
            break;
      }
   }
  }
//+------------------------------------------------------------------+
//| Calculate lot size                                               |
//+------------------------------------------------------------------+
double GetLotSize(string remote_lots,string symbol)
  {
   double dRemoteLots=StrToDouble(remote_lots);
   double dLocalLotDifference=InpMaxLocalLotSize-InpMinLocalLotSize;
   double dRemoteLotDifference=InpMaxRemoteLotSize-InpMinRemoteLotSize;
   double dLots=dLocalLotDifference *(dRemoteLots/dRemoteLotDifference);
   double dMinLotSize=MarketInfo(symbol,MODE_MINLOT);
   if(dLots<dMinLotSize)
      dLots=dMinLotSize;
   return(NormalizeDouble(dLots,InpVolumePrecision));
  }
//|-----------------------------------------------------------------------------------------|
//|                                     C O M M E N T                                       |
//|-----------------------------------------------------------------------------------------|
string EaComment(string cmt="")
{
   string strtmp = cmt+"-->"+EaName+" "+EaVer+"<--";
//--- Assert Basic info in comment
   strtmp=strtmp+"\n";
   
//--- Assert additional comments here
   strtmp=TDComment(strtmp);
   strtmp=TurtleComment(strtmp);
   strtmp=GhostComment(strtmp);
   
   strtmp = strtmp+"\n";
   return(strtmp);
}
void EaDebugPrint(int dbg, string fn, string msg)
{
   static int noStackCount;
   if(EaViewDebug>=dbg)
   {
      if(dbg>=2 && EaViewDebugNoStack>0)
      {
         if( MathMod(noStackCount,EaViewDebugNoStack) <= EaViewDebugNoStackEnd )
            Print(EaViewDebug,"-",noStackCount,":",fn,"(): ",msg);
            
         noStackCount ++;
      }
      else
      {
         if(EaViewDebugNotify)   SendNotification( EaViewDebug + ":" + fn + "(): " + msg );
         Print(EaViewDebug,":",fn,"(): ",msg);
      }
   }
}
string EaDebugInt(string key, int val)
{
   return( StringConcatenate(";",key,"=",val) );
}
string EaDebugDbl(string key, double val, int dgt=5)
{
   return( StringConcatenate(";",key,"=",NormalizeDouble(val,dgt)) );
}
string EaDebugStr(string key, string val)
{
   return( StringConcatenate(";",key,"=\"",val,"\"") );
}
string EaDebugBln(string key, bool val)
{
   string valType;
   if( val )   valType="true";
   else        valType="false";
   return( StringConcatenate(";",key,"=",valType) );
}
//|-----------------------------------------------------------------------------------------|
//|                       E N D   O F   E X P E R T   A D V I S O R                         |
//|-----------------------------------------------------------------------------------------|