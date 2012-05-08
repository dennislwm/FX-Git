//|-----------------------------------------------------------------------------------------|
//|                                                                         GhostBroker.mqh |
//|                                                            Copyright © 2012, Dennis Lee |
//| Assert History                                                                          |
//| 1.00    Originated from PlusGhost 1.64 and requires GhostSqLite 1.14+.                  |
//|-----------------------------------------------------------------------------------------|

//|-----------------------------------------------------------------------------------------|
//|                           I N T E R N A L   V A R I A B L E S                           |
//|-----------------------------------------------------------------------------------------|
//---- Assert internal variables for Broker
string   BrokerName        = "";
string   BrokerVer         = "1.00";

//|-----------------------------------------------------------------------------------------|
//|                             I N I T I A L I Z A T I O N                                 |
//|-----------------------------------------------------------------------------------------|
bool BrokerCreate(int acctNo, string symbol, int period, string eaName)
{
//--- Assert broker dependency on SqLite collect data
   if( GhostStatistics ) return( SqLiteCreate(acctNo,symbol,period,eaName ) );
   else return(true);
}

//|-----------------------------------------------------------------------------------------|
//|                               M A I N   P R O C E D U R E                               |
//|-----------------------------------------------------------------------------------------|

//|-----------------------------------------------------------------------------------------|
//|                             T E R M I N A L   B U F F E R S                             |
//|-----------------------------------------------------------------------------------------|
void BrokerLoadBuffers()
{
	int lastErr, ordersTotal = OrdersTotal(), digits;
   
//--- Assert statistics gathering
   string expr;
   double calcProfitPip;
   double closePrice;
   double mgn;
   double maxLots; 
   double maxProfit; 
   double maxProfitPip;
   double maxDrawdown;
   double maxDrawdownPip;
   double maxMargin;
   int    totalTrades;
   double totalLots;
   double totalProfitPip;
   double totalMargin;

   GhostCurOpenPositions=0; GhostCurPendingOrders=0;
	for ( int z = ordersTotal - 1; z >= 0; z -- )
	{
		if ( !OrderSelect( z, SELECT_BY_POS, MODE_TRADES ) )
		{
			lastErr = GetLastError();
			Print( "OrderSelect( ", z, ", SELECT_BY_POS, MODE_TRADES ) - Error #", lastErr );
			continue;
		}

		digits = MarketInfo( OrderSymbol(), MODE_DIGITS );

		if ( OrderType() < 2 )
		{
			GhostOpenPositions[GhostCurOpenPositions][TwTicket]     = OrderTicket();
			GhostOpenPositions[GhostCurOpenPositions][TwOpenTime]   = TimeToStr( OrderOpenTime() );
			GhostOpenPositions[GhostCurOpenPositions][TwType]       = OrderTypeToStr( OrderType() );
			GhostOpenPositions[GhostCurOpenPositions][TwLots]       = DoubleToStr( OrderLots(), 1 );
			GhostOpenPositions[GhostCurOpenPositions][TwOpenPrice]  = DoubleToStr( OrderOpenPrice(), digits );
			GhostOpenPositions[GhostCurOpenPositions][TwStopLoss]   = DoubleToStr( OrderStopLoss(), digits );
			GhostOpenPositions[GhostCurOpenPositions][TwTakeProfit] = DoubleToStr( OrderTakeProfit(), digits );

      //--- Assert get close price
         mgn = MarketInfo( OrderSymbol(), MODE_MARGINREQUIRED ) * OrderLots();
         calcProfitPip = 0.0;
			if ( OrderType() == OP_BUY )
			{ 
            closePrice     = MarketInfo( OrderSymbol(), MODE_BID );
         //--- Assert calculate profit
            calcProfitPip  = ( closePrice-OrderOpenPrice() )/GhostPts;
         }
			else
			{ 
            closePrice = MarketInfo( OrderSymbol(), MODE_ASK );
         //--- Assert calculate profit
            calcProfitPip  = ( OrderOpenPrice()-closePrice )/GhostPts;
         }
         GhostOpenPositions[GhostCurOpenPositions][TwCurPrice]   = DoubleToStr( closePrice, digits ); 
			GhostOpenPositions[GhostCurOpenPositions][TwSwap]       = DoubleToStr( OrderSwap(), 2 );
			GhostOpenPositions[GhostCurOpenPositions][TwProfit]     = DoubleToStr( OrderProfit(), 2 );
			GhostOpenPositions[GhostCurOpenPositions][TwComment]    = OrderComment();

      //--- Assert record statistics for SINGLE trade
         if( OrderLots()>0 &&    OrderLots() > maxLots )          maxLots = OrderLots();
         if( OrderProfit()>0 &&  OrderProfit() > maxProfit )      maxProfit = OrderProfit();
         if( calcProfitPip>0 &&  calcProfitPip > maxProfitPip )   maxProfitPip = calcProfitPip;
         if( OrderProfit()<0 &&  OrderProfit() < maxDrawdown )    maxDrawdown = OrderProfit();
         if( calcProfitPip<0 &&  calcProfitPip < maxDrawdownPip ) maxDrawdownPip = calcProfitPip;
         if( mgn>0 &&            mgn > maxMargin )                maxMargin = mgn;
         
      //--- Increment row
         totalLots         += OrderLots();
         totalMargin       += mgn;
			GhostSummProfit   += OrderProfit();
         totalProfitPip    += calcProfitPip;
			GhostCurOpenPositions ++;
			if ( GhostCurOpenPositions >= GhostRows ) { break; }
		}
		else
		{
			GhostPendingOrders[GhostCurPendingOrders][TwTicket]     = OrderTicket();
			GhostPendingOrders[GhostCurPendingOrders][TwOpenTime]   = TimeToStr( OrderOpenTime() );
			GhostPendingOrders[GhostCurPendingOrders][TwType]       = OrderTypeToStr( OrderType() );
			GhostPendingOrders[GhostCurPendingOrders][TwLots]       = DoubleToStr( OrderLots(), 1 );
			GhostPendingOrders[GhostCurPendingOrders][TwOpenPrice]  = DoubleToStr( OrderOpenPrice(), digits );
			GhostPendingOrders[GhostCurPendingOrders][TwStopLoss]   = DoubleToStr( OrderStopLoss(), digits );
			GhostPendingOrders[GhostCurPendingOrders][TwTakeProfit] = DoubleToStr( OrderTakeProfit(), digits );

			if ( OrderType() == OP_SELLSTOP || OrderType() == OP_SELLLIMIT )
			{ GhostPendingOrders[GhostCurPendingOrders][TwCurPrice] = DoubleToStr( MarketInfo( OrderSymbol(), MODE_BID ), digits ); }
			else
			{ GhostPendingOrders[GhostCurPendingOrders][TwCurPrice] = DoubleToStr( MarketInfo( OrderSymbol(), MODE_ASK ), digits ); }

			GhostPendingOrders[GhostCurPendingOrders][TwSwap]       = DoubleToStr( OrderSwap(), 2 );
			GhostPendingOrders[GhostCurPendingOrders][TwProfit]     = DoubleToStr( OrderProfit(), 2 );
			GhostPendingOrders[GhostCurPendingOrders][TwComment]    = OrderComment();

			GhostCurPendingOrders ++;
			if ( GhostCurOpenPositions + GhostCurPendingOrders >= GhostRows ) { break; }
		}
	}
   
//--- Assert statistics keeping enabled
   if(GhostStatistics)
   {
      SqLiteRecordStatistics( GhostCurOpenPositions, totalLots, GhostSummProfit, totalProfitPip, totalMargin,
                              maxLots, maxProfit, maxProfitPip, maxDrawdown, maxDrawdownPip, maxMargin );
   }
   
   GhostReorderBuffers();
}

//|-----------------------------------------------------------------------------------------|
//|                             D E I N I T I A L I Z A T I O N                             |
//|-----------------------------------------------------------------------------------------|
void BrokerDeInit()
{
//--- Assert broker dependency on SqLite collect data
   if( GhostStatistics ) SqLiteDeInit();
}

//|-----------------------------------------------------------------------------------------|
//|                              B R O K E R   F U N C T I O N S                            |
//|-----------------------------------------------------------------------------------------|
