//+------------------------------------------------------------------+
//|                                    Vorn.Yatugar.Notification.mq5 |
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
int SendMarketData(int market, int & timeframes[], datetime From, int count);
void ReadPointData(int key,  PointData &md[]);
bool FindPointData(PointData & pds[], PointData & pd, int id = NULL, ulong state = NULL);
#import
//+------------------------------------------------------------------+
sinput int Candles = 500;
//+------------------------------------------------------------------+
string previous = "";
//+------------------------------------------------------------------+
int OnInit()
  {
   InitializeYatugar();
   Print(Search());
   EventSetTimer(5 * 60);
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
void OnTimer()
  {
   string report = Search();
   if(previous != report)
      if(StringLen(report) > 0)
        {
         Print(report);
         SendMail(MQLInfoString(MQL_PROGRAM_NAME), report);
         SendNotification(report);
        }
   previous = report;
  }
//+------------------------------------------------------------------+
string Search(int key)
  {
   int timeframes[] = {PERIOD_D1, PERIOD_H4, PERIOD_M30};
   PointData pd[];
   string report = "";
   ReadPointData(key, pd);
   report += StateReport(pd, StateValues::SignalB1(), timeframes, " HasSignalB1 ");
   report += StateReport(pd, StateValues::SignalB2(), timeframes, " HasSignalB2 ");
   report += StateReport(pd, StateValues::SignalA1(), timeframes, " HasSignalA1 ");
   report += StateReport(pd, StateValues::SignalA2(), timeframes, " HasSignalA2 ");
   return report;
  }
//+------------------------------------------------------------------+
string Search()
  {
   string report = "";
   int timeframes[] = {PERIOD_D1, PERIOD_H4, PERIOD_M30, PERIOD_M5};
   for(int i = 0; i < Vorn::Commands::MarketCount(); i++)
     {
      int k = SendMarketData(i, timeframes, TimeCurrent(), Candles);
      Vorn::Commands::AddKey(i, k);
     }
   for(int i = 0; i < Vorn::Commands::MarketCount(); i++)
     {
      int k = Vorn::Commands::GetKey(i);
      report += Search(k);
     }
   return report;
  }
//+------------------------------------------------------------------+
string StateReport(PointData & pd[], ulong state, int & timeframes[], string message)
  {
   for(int i = 0; i < ArraySize(pd); i++)
     {
      if(pd[i].Index > 2)
         continue;
      if(Vorn::Array::IndexOf(timeframes, pd[i].TimeFrame) < 0)
         continue;
      if((pd[i].States & state) > 0)
         return SymbolName(pd[i].Market, true) + message + (string)pd[i].TimeFrame + "\t\n";
     }
   return "";
  }
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   DeinitializeYatugar();
  }
//+------------------------------------------------------------------+
