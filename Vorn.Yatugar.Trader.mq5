//+------------------------------------------------------------------+
//|                                          Vorn.Yatugar.Trader.mq5 |
//|                                                             Vorn |
//|                                                  https://vorn.ir |
//+------------------------------------------------------------------+
#property copyright "Vorn"
#property link      "https://vorn.ir"
#property version   "1.00"
//+------------------------------------------------------------------+
#import "Vorn.Yatugar.Separ.Client.dll"
#import
//+------------------------------------------------------------------+
#import "Vorn.Yatugar.ex5"
bool InitializeYatugar();
bool DeinitializeYatugar();
int SendMarketData(string sym, int & timeframes[], datetime From, int count);
void ReadPointData(int key,  PointData &md[]);
string UlongToString(ulong ulong_var);
#import
//+------------------------------------------------------------------+
#include <Trade\Trade.mqh>
#include <Trade\PositionInfo.mqh>
//+------------------------------------------------------------------+
#import
class PositionManager
  {
public:

   CTrade            BuyTrade;
   CTrade            SellTrade;
   CPositionInfo     Position;
   int               SellTradeId(string Market)
     {
      return GetHashCode(Market + "Sell");
     };
   int               BuyTradeId(string Market)
     {
      return GetHashCode(Market + "Buy");
     };
   bool              HasBuyPosition(string Market)
     {
      return Position.SelectByMagic(Market, BuyTradeId(Market));
     };
   bool              HasSellPosition(string Market)
     {
      return Position.SelectByMagic(Market, SellTradeId(Market));
     };
   void              OpenBuyPosition(string Market, double volume, double sl, double tp, string comment = "")
     {
      BuyTrade.SetExpertMagicNumber(BuyTradeId(Market));
      BuyTrade.Buy(volume,
                   Market,
                   0,
                   sl,
                   tp,
                   "BuyTrade" + comment);
     };
   void              OpenSellPosition(string Market, double volume, double sl, double tp, string comment = "")
     {
      SellTrade.SetExpertMagicNumber(SellTradeId(Market));
      SellTrade.Sell(volume,
                     Market,
                     0,
                     sl,
                     tp,
                     "SellTrade" + comment);
     };
   void              CloseBuyPosition(string Market, int points = 1000)
     {
      if(Position.SelectByMagic(Market, BuyTradeId(Market)))
         BuyTrade.PositionClose(Position.Ticket(), 1000);
     };
   void              CloseSellPosition(string Market, int points = 1000)
     {
      if(Position.SelectByMagic(Market, SellTradeId(Market)))
         SellTrade.PositionClose(Position.Ticket(), 1000);
     };
   int               GetHashCode(const string value)
     {
      int len = StringLen(value);
      int hash = 0;
      if(len > 0)
        {
         for(int i = 0; i < len; i++)
            hash = 31 * hash + value[i];
        }
      return(hash);
     };
                    ~PositionManager()
     {
      delete &SellTrade;
      delete &BuyTrade;
      delete &Position;
     };
  };
#import
//+------------------------------------------------------------------+
sinput int Candles = 1000;
sinput double CashVolatility = 100;
//+------------------------------------------------------------------+
PositionManager pm;
int Timeframes[] = {PERIOD_H4, PERIOD_M30};
int MaxShareTimeframe[] = {15, 10};
//+------------------------------------------------------------------+
int OnInit()
  {
   InitializeYatugar();
   ApplyTemplateToAllCharts("Vorn.Yatugar.Macd.Ma.Adx.So.tpl");
   EventSetTimer(PeriodSeconds(_Period) / 2);
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
void OnTimer()
  {
   Search(Timeframes);
  }
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   delete &pm;
   DeinitializeYatugar();
  }
//+------------------------------------------------------------------+
bool StateReport(PointData & pd, ulong state)
  {
   if((pd.States & state) > 0)
      return true;
   return false;
  }
//+------------------------------------------------------------------+
bool MarketIsSelected(int i)
  {
   string markets[] = {"EURCAD", "EURCHF", "EURUSD", "EURAUD", "EURGBP", "USDCAD", "USDCHF", "GBPUSD", "GBPCAD", "GBPAUD", "CADCHF"};
   bool marketSelected = false;
   for(int m = 0; m < ArraySize(markets); m++)
      if(markets[m] == SymbolName(i, false))
        {
         marketSelected = true;
         break;
        }
   return marketSelected;
  }
//+------------------------------------------------------------------+
void Search(int & timeframes[])
  {
   for(int i = 0; i < SymbolsTotal(false); i++)
     {
      if(!MarketIsSelected(i))
         continue;
      int k = SendMarketData(SymbolName(i, false), timeframes, TimeCurrent(), Candles);
      Vorn::Commands::AddKey(i, k);
     }
   for(int i = 0; i < SymbolsTotal(false); i++)
     {
      if(!MarketIsSelected(i))
         continue;
      int k = Vorn::Commands::GetKey(i);
      Search(k, timeframes);
     }
  }
//+------------------------------------------------------------------+
void Search(int key, int & timeframes[])
  {
   PointData pd[];
   ReadPointData(key, pd);
     {
      for(int p = 0; p < ArraySize(pd); p++)
        {
         if(pd[p].Index > 1)
            continue;
         for(int tf = 0; tf < ArraySize(timeframes); tf++)
           {
            if(timeframes[tf] != pd[p].TimeFrame)
               continue;
            if(StateReport(pd[p], StateValues::SignalU1))
               BuyState(pd[p], pd[p].AreaStart, pd[p].AreaEnd, MaxShareTimeframe[tf]);
            if(StateReport(pd[p], StateValues::SignalU2))
               SellState(pd[p], pd[p].F0, pd[p].F100, MaxShareTimeframe[tf]);
           }
        }
     }
  }
//+------------------------------------------------------------------+
void SellState(PointData & pd, double sl, double tp, int maxShares)
  {
   string sym = UlongToString(pd.MarketName);
   if(pm.HasBuyPosition(sym))
     {
      pm.CloseBuyPosition(sym);
     }
   else
      if(!pm.HasSellPosition(sym))
        {
         double vol = MathFloor(MathMin((CashVolatility / pd.Volatility), maxShares)) * .01;
         if(sl > 0)
            pm.OpenSellPosition(
               sym,
               vol,
               sl,
               tp);
        }
  }
//+------------------------------------------------------------------+
void BuyState(PointData & pd, double sl, double tp, int maxShares)
  {
   string sym = UlongToString(pd.MarketName);
   if(pm.HasSellPosition(sym))
     {
      pm.CloseSellPosition(sym);
     }
   else
      if(!pm.HasBuyPosition(sym))
        {
         double vol = MathFloor(MathMin((CashVolatility / pd.Volatility), maxShares)) * .01;
         if(sl > 0)
            pm.OpenBuyPosition(
               sym,
               vol,
               sl,
               tp);
        }
  }
//+------------------------------------------------------------------+
void ApplyTemplateToAllCharts(string templateName)
  {
   long chartID = ChartFirst();
   while(chartID >= 0)
     {
      bool result = ChartApplyTemplate(chartID, templateName);
      if(!result)
        {
         Print("Failed to apply template to chart ID ", chartID, ": ", GetLastError());
        }
      chartID = ChartNext(chartID);
     }
  }
//+------------------------------------------------------------------+
