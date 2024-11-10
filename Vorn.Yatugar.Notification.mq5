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
int SendMarketData(string sym, int & timeframes[], datetime From, int count);
void ReadPointData(int key,  PointData &md[]);
string UlongToString(ulong ulongVar);
#import
//+------------------------------------------------------------------+
sinput int Candles = 500;
//+------------------------------------------------------------------+
string previous = "";
//+------------------------------------------------------------------+
int OnInit()
  {
   if(!InitializeYatugar())
      return(INIT_FAILED);
   previous = Search();
   Print(previous);
   EventSetTimer(10 * 60);
//ExpertRemove();
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
string Search()
  {
   string report = "";
   int timeframes[] = {PERIOD_H4, PERIOD_M30, PERIOD_M5};
   for(int i = 0; i < SymbolsTotal(false); i++)
     {
      if(StringLen(SymbolName(i, false)) < 6)
         continue;
      int k = SendMarketData(SymbolName(i, false), timeframes, TimeCurrent(), Candles);
      Vorn::Commands::AddKey(i, k);
     }
   for(int i = 0; i < SymbolsTotal(false); i++)
     {
      if(StringLen(SymbolName(i, false)) < 6)
         continue;
      int k = Vorn::Commands::GetKey(i);
      report += Search(k, timeframes);
     }
   return report;
  }
//+------------------------------------------------------------------+
string Search(int key, int & timeframes[])
  {
   PointData pd[] = {};
   string report = "";
   ReadPointData(key, pd);
   report += StateReport(pd, StateValues::SignalBb1(), timeframes, " HasSignalBb1 ");
   report += StateReport(pd, StateValues::SignalBb2(), timeframes, " HasSignalBb2 ");
   report += StateReport(pd, StateValues::SignalU(), timeframes, " HasSignalU ");
   return report;
  }
//+------------------------------------------------------------------+
string StateReport(PointData & pd[], ulong state, int & timeframes[], string message, int indexLimit = 1)
  {
   if(ArraySize(pd) == 0)
      return "";
   string sym = UlongToString(pd[0].MarketName);
   for(int i = 0; i < ArraySize(pd); i++)
     {
      if(pd[i].Index > indexLimit)
         continue;
      if(Vorn::Array::IndexOf(timeframes, pd[i].TimeFrame) < 0)
         continue;
      if((pd[i].States & state) > 0)
         return sym + message + (string)pd[i].TimeFrame + "\t\n";
     }
   return "";
  }
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   DeinitializeYatugar();
  }
//+------------------------------------------------------------------+
