//+------------------------------------------------------------------+
//|                                                             Vorn |
//|                                                  https://vorn.ir |
//+------------------------------------------------------------------+
#property copyright "Vorn"
#property link      "https://vorn.ir"
#property version   "1.00"
//+------------------------------------------------------------------+
#include <Trade\Trade.mqh>
//+------------------------------------------------------------------+
CTrade            Trade;
//+------------------------------------------------------------------+
#import
enum SarType
  {
   None,
   Rising,
   Falling
  };
struct Sar
  {
   double            Value;
   SarType           Type;
   bool              Reversal;
  };
#import
//+------------------------------------------------------------------+
sinput ENUM_TIMEFRAMES TrailerPeriod = PERIOD_M5;
//+------------------------------------------------------------------+
int OnInit()
  {
   EventSetTimer(PeriodSeconds(TrailerPeriod));
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
void OnTimer()
  {
   for(int i = 0; i < PositionsTotal(); i++)
     {
      string symbol = PositionGetSymbol(i); //selects
      ulong ticket = PositionGetTicket(i);
      double tp = PositionGetDouble(POSITION_TP);
      double profit = PositionGetDouble(POSITION_PROFIT);
      long type = PositionGetInteger(POSITION_TYPE);
      if(profit > 0)
        {
         Trade.PositionModify(ticket, GetLastSar(symbol, TrailerPeriod, type), tp);
        }
     }
  }
//+------------------------------------------------------------------+
double GetLastSar(string sym, ENUM_TIMEFRAMES tf, long type)
  {
   int count = 20;
   int hsar = iSAR(sym, tf, .02, .2);
   double s[];
   ArraySetAsSeries(s, true);
   CopyBuffer(hsar, 0, 0, count, s);
   IndicatorRelease(hsar);
//////////
   Sar sar[];
   ArrayResize(sar, count);
   for(int i = 0; i < count; i++)
     {
      sar[i].Value = s[i];
     }
   for(int i = 0; i < count - 1; i++)
     {
      sar[i].Type = GetSarTypeAt(sar, i);
     }
   for(int i = 0; i < count; i++)
     {
      sar[i].Reversal = GetReversalAt(sar, i);
     }
//////////
   for(int i = 0; i < count - 1; i++)
     {
      if(type == POSITION_TYPE_BUY)
        {
         if(sar[i].Type == Rising)
            return sar[i].Value;
        }
      if(type == POSITION_TYPE_SELL)
        {
         if(sar[i].Type == Falling)
            return sar[i].Value;
        }
     }
   return -1;
  }
//+------------------------------------------------------------------+
bool GetReversalAt(Sar & sar[], int index)
  {
   SarType p = sar[index].Type;
   if(p != None) // all reversals have type
     {
      SarType n = None;
      int i = 1;
      while(n == None && index - i >= 0)
        {
         n = sar[index - i].Type;
         if(p != n && n != None)
            return true;
         i++;
        }
     }
   return false;
  }
//+------------------------------------------------------------------+
SarType GetSarTypeAt(Sar & sar[], int index)
  {
   if(sar[index + 1].Value > sar[index].Value)
      return  Falling;
   if(sar[index + 1].Value < sar[index].Value)
      return Rising;
   return None;
  }
//+------------------------------------------------------------------+
