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
int SendMarketData(int market, int & timeframes[], int start, int count);
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
   EventSetTimer(2 * 60);
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
   PointData pd[];
   string report = "";
   ReadPointData(key, pd);
   report += HasSignalB1(pd);
   report += HasSignalB2(pd);
   report += HasLeftTarget(pd);
   report += HasMacdSignChange(pd);
   return report;
  }
//+------------------------------------------------------------------+
string Search()
  {
   string report = "";
   int timeframes[] = {PERIOD_H4, PERIOD_M30};
   for(int i = 0; i < Vorn::Commands::MarketCount(); i++)
     {
      int k = SendMarketData(i, timeframes, 0, Candles);
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
string HasSignalB1(PointData & pd[])
  {
   for(int i = 0; i < ArraySize(pd); i++)
     {
      if(pd[i].Index > 2)
         continue;
      if((pd[i].States & StateValues::SignalB1()) > 0)
         return SymbolName(pd[i].Market, true) + " Has SignalB1 in " + (string)pd[i].TimeFrame + "\t\n";
     }
   return "";
  }
//+------------------------------------------------------------------+
string HasSignalB2(PointData & pd[])
  {
   for(int i = 0; i < ArraySize(pd); i++)
     {
      if(pd[i].Index > 2)
         continue;
      if((pd[i].States & StateValues::SignalB2()) > 0)
         return SymbolName(pd[i].Market, true) + " Has SignalB2 in " + (string)pd[i].TimeFrame + "\t\n";
     }
   return "";
  }
//+------------------------------------------------------------------+
string HasLeftTarget(PointData & pd[])
  {
   for(int i = 0; i < ArraySize(pd); i++)
     {
      if(pd[i].Index > 2)
         continue;
      if((pd[i].States & StateValues::LeftTarget()) > 0)
         return SymbolName(pd[i].Market, true) + " Has LeftTarget in " + (string)pd[i].TimeFrame + "\t\n";
     }
   return "";
  }
//+------------------------------------------------------------------+
string HasMacdSignChange(PointData & pd[])
  {
   for(int i = 0; i < ArraySize(pd); i++)
     {
      if(pd[i].Index > 2)
         continue;
      if((pd[i].States & StateValues::PositiveMacdSignChange()) > 0)
         return SymbolName(pd[i].Market, true) + " Has PositiveMacdSignChange in " + (string)pd[i].TimeFrame + "\t\n";
      if((pd[i].States & StateValues::NegativeMacdSignChange()) > 0)
         return SymbolName(pd[i].Market, true) + " Has NegativeMacdSignChange in " + (string)pd[i].TimeFrame + "\t\n";
     }
   return "";
  }
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   DeinitializeYatugar();
  }
//+------------------------------------------------------------------+
