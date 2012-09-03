//+------------------------------------------------------------------+
//|                                            TsaktuoDealClient.mq4 |
//|                                                          Tsaktuo |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Tsaktuo"
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
//--- input values
extern int     InpServerPort=2011;
extern string  InpServerIP="127.0.0.1";
extern int     InpVolumePrecision=2;
extern int     InpSlippage=3;
extern string _1="--- LOT MAPPING ---";
extern double  InpMinLocalLotSize=0.01;
extern double  InpMaxLocalLotSize=1.00; // Recomended bigger than
extern double  InpMinRemoteLotSize =      0.01;
extern double  InpMaxRemoteLotSize =      15.00;
//--- global values
int iSocketHandle=0;
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
//| Start function.                                                  |
//+------------------------------------------------------------------+
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

//==============  UTILS ==================================================
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

   if(cmd==OP_SELL)
      prc= MarketInfo(symbol,MODE_BID);
   else if(cmd==OP_BUY)
      prc=MarketInfo(symbol,MODE_ASK);

   string comment="IN."+Type2String(cmd);

   int iRetVal=OrderSend(symbol,cmd,volume,prc,InpSlippage,stoploss,takeprofit,comment,account);
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

         iRetVal=OrderSend(symbol,cmd,volume,prc,InpSlippage,stoploss,takeprofit,comment,account);

         if(iRetVal<0) retries++;
         else break;
        }

      if(iRetVal<0)
         Print("Failed to execute order! Error: ",GetLastError());
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
   for(i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS))
        {
         if(OrderMagicNumber()==account)
           {
            if(OrderSymbol()==symbol)
              {
               if(OrderType()==type)
                 {
                  if(OrderLots()==volume)
                    {
                     if(CloseOneOrder(OrderTicket(),symbol,type,volume))
                       {
                        Print("Order with exact volume found and executed.");
                        return;
                       }
                    }
                 }
              }
           }
        }
     }
   double volume_to_clear=volume;
//--- search for orders with smaller volume
   int limit=OrdersTotal();
   for(i=0;i<limit;i++)
     {
      if(OrderSelect(i,SELECT_BY_POS))
        {
         if(OrderMagicNumber()==account)
           {
            if(OrderSymbol()==symbol)
              {
               if(OrderType()==type)
                 {
                  if(OrderLots()<=volume_to_clear)
                    {
                     if(CloseOneOrder(OrderTicket(),symbol,type,OrderLots()))
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
                       }
                    }
                 }
              }
           }
        }
     }
//--- search for orders with higher volume
   for(i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS))
        {
         if(OrderMagicNumber()==account)
           {
            if(OrderSymbol()==symbol)
              {
               if(OrderType()==type)
                 {
                  if(OrderLots()>=volume_to_clear)
                    {
                     if(CloseOneOrder(OrderTicket(),symbol,type,OrderLots()))
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
                       }
                    }
                 }
              }
           }
        }
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

   int iRetVal=OrderClose(ticket,lots,prc,InpSlippage);
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

         iRetVal=OrderClose(ticket,lots,prc,InpSlippage);

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
   int limit= OrdersTotal();
   for(int i=0;i<limit;i++)
     {
      if(OrderSelect(i,SELECT_BY_POS))
        {
         if(OrderMagicNumber()==account)
           {
            if(OrderSymbol()==symbol)
              {
               if(OrderType()==type)
                 {
                  if(CloseOneOrder(OrderTicket(),symbol,type,OrderLots()))
                    {
                     Print("OUT_ALL: Order found and executed.");
                     limit=OrdersTotal();
                     //--- because it will be increased at end of cycle and will have value 0.
                     i=-1; 
                    }
                 }
              }
           }
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
//+------------------------------------------------------------------+

