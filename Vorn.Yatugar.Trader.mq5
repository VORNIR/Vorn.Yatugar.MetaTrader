//+------------------------------------------------------------------+
//|                                          Vorn.Yatugar.Trader.mq5 |
//|                                                             Vorn |
//|                                                  https://vorn.ir |
//+------------------------------------------------------------------+
#property copyright "Vorn"
#property link      "https://vorn.ir"
#property version   "1.00"
//+------------------------------------------------------------------+
#import "Vorn.Yatugar.Separ.Common.dll"
#import
//+------------------------------------------------------------------+
#import "Vorn.Yatugar.Separ.OfflineClient.dll"
#import
//+------------------------------------------------------------------+
#import "Vorn.Yatugar.Offline.ex5"
bool InitializeYatugar();
bool DeinitializeYatugar();
bool FindPointData(PointData & pds[], PointData & pd, int timeframe, int id = NULL, ulong state = NULL, int startIndex = 0);
void DoMarketRecognition(string sym, int & timeframes[], datetime from, int count, PointData &md[]);
int SendMarketData(string sym, int & timeframes[], datetime from, int count);
bool ReadPointData(int key,  PointData &md[]);
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
   int               SellTradeId(string Market, string timeframe)
     {
      return GetHashCode("Sell" + Market + timeframe);
     };
   int               BuyTradeId(string Market, string timeframe)
     {
      return GetHashCode("Buy" + Market + timeframe);
     };
   bool              HasBuyPosition(string Market, string timeframe)
     {
      return Position.SelectByMagic(Market, BuyTradeId(Market, timeframe));
     };
   bool              HasSellPosition(string Market, string timeframe)
     {
      return Position.SelectByMagic(Market, SellTradeId(Market, timeframe));
     };
   void              OpenBuyPosition(string Market, double volume, double sl, double tp, string timeframe)
     {
      BuyTrade.SetExpertMagicNumber(BuyTradeId(Market, timeframe));
      BuyTrade.Buy(volume,
                   Market,
                   0,
                   sl,
                   tp,
                   timeframe);
     };
   void              OpenSellPosition(string Market, double volume, double sl, double tp, string timeframe)
     {
      SellTrade.SetExpertMagicNumber(SellTradeId(Market, timeframe));
      SellTrade.Sell(volume,
                     Market,
                     0,
                     sl,
                     tp,
                     timeframe);
     };
   void              CloseBuyPosition(string Market, string timeframe, int points = 1000)
     {
      if(Position.SelectByMagic(Market, BuyTradeId(Market, timeframe)))
         BuyTrade.PositionClose(Position.Ticket(), 1000);
     };
   void              CloseSellPosition(string Market, string timeframe, int points = 1000)
     {
      if(Position.SelectByMagic(Market, SellTradeId(Market, timeframe)))
         SellTrade.PositionClose(Position.Ticket(), 1000);
     };
   void              ModifyBuyPositionStopLoss(string Market, string timeframe, double sl)
     {
      if(Position.SelectByMagic(Market, BuyTradeId(Market, timeframe)))
         BuyTrade.PositionModify(Position.Ticket(), sl, Position.TakeProfit());
     };
   void              ModifySellPositionStopLoss(string Market, string timeframe, double sl)
     {
      if(Position.SelectByMagic(Market, SellTradeId(Market, timeframe)))
         SellTrade.PositionModify(Position.Ticket(), sl, Position.TakeProfit());
     };
   void              ModifyBuyPositionTakeProfit(string Market, string timeframe, double tp)
     {
      if(Position.SelectByMagic(Market, BuyTradeId(Market, timeframe)))
         BuyTrade.PositionModify(Position.Ticket(), Position.StopLoss(), tp);
     };
   void              ModifySellPositionTakeProfit(string Market, string timeframe, double tp)
     {
      if(Position.SelectByMagic(Market, SellTradeId(Market, timeframe)))
         SellTrade.PositionModify(Position.Ticket(), Position.StopLoss(), tp);
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
//sinput double CashVolatility = 100;
//+------------------------------------------------------------------+
PositionManager pm;
string markets[] = {"XAUUSD", "EURCAD", "EURCHF", "EURUSD", "EURAUD", "EURGBP", "USDCAD", "USDCHF", "GBPUSD", "GBPCAD", "GBPAUD", "CADCHF"}; //
int Timeframes[] = {PERIOD_H4, PERIOD_M30, PERIOD_M5};
int MaxShareTimeframe[] = {15, 10, 5};
//+------------------------------------------------------------------+
int OnInit()
  {
   if(InitializeYatugar())
     {
      EventSetTimer(PeriodSeconds(_Period));
      return(INIT_SUCCEEDED);
     }
   else
     {
      return(INIT_FAILED);
     }
  }
//+------------------------------------------------------------------+
void OnTimer()
  {
   MqlDateTime time;
   TimeToStruct(TimeCurrent(), time);
   if(time.hour < 22 && time.hour > 1)
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
   OpenPositions(pd, timeframes);
   AdjustPositions(pd);
  }
//+------------------------------------------------------------------+
void SellState(PointData & pd, int maxShares)
  {
   string sym = UlongToString(pd.MarketName);
   string tf = (string)pd.TimeFrame;
   if(pm.HasBuyPosition(sym, tf))
     {
      pm.CloseBuyPosition(sym, tf);
     }
   else
      if(!pm.HasSellPosition(sym, tf))
        {
         double vol = maxShares * .01;
         if(pd.ReverseRate > 0)
            pm.OpenSellPosition(sym, vol, pd.ReverseRate, pd.Unbalancing, tf);
        }
  }
//+------------------------------------------------------------------+
void BuyState(PointData & pd, int maxShares)
  {
   string sym = UlongToString(pd.MarketName);
   string tf = (string)pd.TimeFrame;
   if(pm.HasSellPosition(sym, tf))
     {
      pm.CloseSellPosition(sym, tf);
     }
   else
      if(!pm.HasBuyPosition(sym, tf))
        {
         double vol = maxShares * .01; //MathFloor(MathMin((CashVolatility / pd.Volatility), maxShares)) * .01;
         if(pd.ReverseRate > 0)
            pm.OpenBuyPosition(sym, vol, pd.ReverseRate, pd.Unbalancing, tf);
        }
  }
//+------------------------------------------------------------------+
void OpenPositions(PointData & pd[], int & timeframes[])
  {
   for(int p = 0; p < ArraySize(pd); p++)
     {
      for(int tf = 0; tf < ArraySize(timeframes); tf++)
        {
         if(timeframes[tf] != pd[p].TimeFrame)
            continue;
         //if(StateReport(pd[p], StateValues::Signal()))
         //   if(pd[p].Index < 3)
         //     {
         //      TimeFrame timeFrame = (TimeFrame)pd[p].TimeFrame;
         //      TimeFrame upper = Vorn::TimeFrameExtensions::Above(timeFrame);
         //      PointData m;
         //      FindPointData(pd, m, (int)upper, NULL, StateValues::StraightMaster());
         //      if(m.F0 < m.F100)
         //         if(StateReport(pd[p], StateValues::BuySignal()))
         //            BuyState(pd[p], 0, 0, MaxShareTimeframe[tf]);
         //      if(m.F0 > m.F100)
         //         if(StateReport(pd[p], StateValues::SellSignal()))
         //            SellState(pd[p], 0, 0, MaxShareTimeframe[tf]);
         //      Print((string)pd[p].Index + " " + (string)pd[p].TimeFrame + " " + (m.F0 < m.F100 ? "+" : "-"));
         //     }
         if(StateReport(pd[p], StateValues::Buy()))
            if(pd[p].Index < 3)
               BuyState(pd[p], MaxShareTimeframe[tf]);
         if(StateReport(pd[p], StateValues::Sell()))
            if(pd[p].Index < 3)
               SellState(pd[p], MaxShareTimeframe[tf]);
        }
     }
  }
//+------------------------------------------------------------------+
void AdjustPositions(PointData & pd[])
  {
   if(ArraySize(pd) == 0)
      return;
   string sym = UlongToString(pd[0].MarketName);
   TimeFrame timeFrame = (TimeFrame)pd[0].TimeFrame;
   TimeFrame upper = Vorn::TimeFrameExtensions::Above(timeFrame);
   string tf = (string)timeFrame;
   if(pm.HasSellPosition(sym, tf))
     {
      PointData p;
      FindPointData(pd, p, (int)upper, NULL, StateValues::NegativeSar());
      pm.ModifySellPositionStopLoss(sym, tf, p.Value);
      //PointData m;
      //FindPointData(pd, m, (int)timeFrame, NULL, StateValues::NegativeMaster());
      //pm.ModifySellPositionTakeProfit(sym, tf, m.Unbalancing);
     }
   if(pm.HasBuyPosition(sym, tf))
     {
      PointData p;
      FindPointData(pd, p, (int)upper, NULL, StateValues::PositiveSar());
      pm.ModifyBuyPositionStopLoss(sym, tf, p.Value);
      //PointData m;
      //FindPointData(pd, m, (int)timeFrame, NULL, StateValues::PositiveMaster());
      //pm.ModifyBuyPositionTakeProfit(sym, tf, m.Unbalancing);
     }
  }
//+------------------------------------------------------------------+
