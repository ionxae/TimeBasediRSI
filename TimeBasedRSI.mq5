//+------------------------------------------------------------------+
//|                                                 TimeBasedRSI.mq5 |
//|                                 Copyright 2018, Ricardo de Jong. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, Ricardo de Jong."
#property link      "https://www.mql5.com"
#property version   "1.3"
#property description "This EA makes use of the iRSI() function, and runs the function using the EventSetTimer() to check the values of the iRSi at a certain time interval." 

#include <Trade/Trade.mqh>

CTrade m_trade;

input int      ValueCheck     =3600;   // Seconds
input int      iRSIPeriod     =14;     // RSI Period
input int      iRSIPosValue   =70;     // RSI Upper Value
input int      iRSINegValue   =30;     // RSI Lower Value
input int      tpPoints       =100;    // Take Profit in Points
input double   Volume         =0.01;   // Lotsize
input int      inpMaxPos      =5;      // Max open positions
input bool     boolMail       =false;  // Send status via e-mail
input bool     InpProfit      =false;  // Close at profit 
input double   InpProfitTot   =1.0;    // Profit in Base Currency
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
/*
TODO

Create a function to replace ValueCheck(), instead of seconds the new function uses minutes, hours, days.
Function name TBD.


*/

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   EventSetTimer(ValueCheck);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   EventKillTimer();
  }
//+------------------------------------------------------------------+
//| Expert timer function                                             |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
   double Ask=NormalizeDouble(SymbolInfoDouble(Symbol(),SYMBOL_ASK),_Digits);
   double Bid=NormalizeDouble(SymbolInfoDouble(Symbol(),SYMBOL_BID),_Digits);
   double PriceArray[];

   int IRSIDefinition=iRSI(_Symbol,_Period,iRSIPeriod,PRICE_CLOSE);

   ArraySetAsSeries(PriceArray,true);

   CopyBuffer(IRSIDefinition,0,0,3,PriceArray);

   float IRSIValue=PriceArray[0];

   if(PositionsTotal()<inpMaxPos)
     {
      if(IRSIValue>iRSIPosValue)
        {
         m_trade.Buy(Volume,Symbol(),SymbolInfoDouble(Symbol(),SYMBOL_ASK),NULL,(Ask+tpPoints*_Point),NULL);
         //  m_trade.Buy(Volume,Symbol(),SymbolInfoDouble(Symbol(),SYMBOL_ASK),(Bid-slPoints*_Point),(Ask+tpPoints*_Point),NULL);
         if(boolMail==true)
           {
            boolMail();
           }
        }
      if(IRSIValue<iRSINegValue)
        {
         m_trade.Sell(Volume,Symbol(),SymbolInfoDouble(Symbol(),SYMBOL_BID),NULL,(Bid-tpPoints*_Point),NULL);
         // m_trade.Sell(Volume,Symbol(),SymbolInfoDouble(Symbol(),SYMBOL_BID),(Ask-slPoints*_Point),(Bid-tpPoints*_Point),NULL);
         if(boolMail==true)
           {
            boolMail();
           }
        }
     }
  }
//+------------------------------------------------------------------+
void OnTick()
  {
   if(InpProfit==true)
     {
      if(InpProfitTot<=AccountInfoDouble(ACCOUNT_PROFIT))
        {
         ClosePositions();
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ClosePositions()
  {
   int x=PositionsTotal()-1;
   while(x>=0)
     {
      if(m_trade.PositionClose(PositionGetSymbol(x)))x--;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void boolMail()
  {
   string   header;
   string   msg;
   string   status_Balance;
   string   status_Equity;
   string   status_UsedMargin;
   string   status_Profit;
//---
   status_Balance    =  AccountInfoDouble(ACCOUNT_BALANCE);
   status_Equity     =  AccountInfoDouble(ACCOUNT_EQUITY);
   status_UsedMargin =  AccountInfoDouble(ACCOUNT_MARGIN);
   status_Profit     =  AccountInfoDouble(ACCOUNT_PROFIT);
//==
   header   =  "Account Status "+ AccountInfoInteger(ACCOUNT_LOGIN);
   msg      =  "Balance: "+status_Balance+"\n""Equity: "+status_Equity+"\n""Used Margin: "+status_UsedMargin+"\n""Profit: "+status_Profit;
//==
   SendMail(header,msg);
  }
//+------------------------------------------------------------------+
