//+------------------------------------------------------------------+
//|                                                      Yatugar.mq5 |
//|                                                             Vorn |
//|                                                  https://vorn.ir |
//+------------------------------------------------------------------+
#property library
#property copyright "Vorn"
#property link      "https://vorn.ir"
#property version   "1.00"
//+------------------------------------------------------------------+
#import "Vorn.Yatugar.Separ.Client.dll"
#import
//+------------------------------------------------------------------+
bool InitializeYatugar() export
  {
   bool connected = Vorn::Commands::CreateClient();
   if(connected)
      SetMarkets();

   return connected;
  }
//+------------------------------------------------------------------+
bool DeinitializeYatugar() export
  {
   return Vorn::Commands::DeleteClient();
  }
//+------------------------------------------------------------------+
void SetMarkets()
  {
   for(int i = 0; i < SymbolsTotal(true); i++)
     {
      Vorn::Commands::AddMarket(SymbolName(i, true));
     }
  }
//+------------------------------------------------------------------+
bool FindPointData(PointData & pds[], PointData & pd, int id = NULL, ulong state = NULL) export
  {
   for(int i = 0; i < ArraySize(pds); i++)
     {
      if(id != NULL ? pds[i].Id == id : true)
         if(state != NULL ? (pds[i].States & state) > 0 : true)
           {
            pd = pds[i];
            return true;
           }
     }
   return false;
  }
//+------------------------------------------------------------------+
void CopyRateData(Chart &chart, datetime from, datetime to, uchar &bytes[]) export
  {
   int st = iBarShift(SymbolName(chart.Market, true), (ENUM_TIMEFRAMES)chart.TimeFrame, to);
   int en = iBarShift(SymbolName(chart.Market, true), (ENUM_TIMEFRAMES)chart.TimeFrame, from);
   CopyRateData(chart, st, en - st, bytes);
  }
//+------------------------------------------------------------------+
void CopyRateData(Chart &chart, int start, int count, uchar &bytes[]) export
  {
   MqlRates rates[];
   ArraySetAsSeries(rates, true);
   int n = CopyRates(SymbolName(chart.Market, true), (ENUM_TIMEFRAMES)chart.TimeFrame, start, count, rates);
   double SARArray[];
   int hsar = iSAR(SymbolName(chart.Market, true), (ENUM_TIMEFRAMES)chart.TimeFrame, 0.02, 0.2);
   ArraySetAsSeries(SARArray, true);
   CopyBuffer(hsar, 0, start, count, SARArray);
   for(int i = 0; i < n; ++i)
     {
      RateData dst;
      dst.Index = i;
      dst.Market = chart.Market;
      dst.TimeFrame = chart.TimeFrame;
      dst.Time = (int)rates[i].time;
      dst.Open = rates[i].open;
      dst.Close = rates[i].close;
      dst.High = rates[i].high;
      dst.Low = rates[i].low;
      dst.Volume = rates[i].tick_volume;
      dst.ParabolicSar = SARArray[i];
      uchar b[];
      StructToCharArray(dst, b);
      ArrayInsert(bytes, b, ArraySize(bytes));
     }
  }
//+------------------------------------------------------------------+
int CalendarValueHistoryByCountry(string country, datetime from, datetime to, MqlCalendarValue &values[]) export
  {
   MqlCalendarEvent events[];
   int events_count = CalendarEventByCountry(country, events);
   for(int e = 0; e < events_count; e++)
     {
      MqlCalendarValue v[];
      CalendarValueHistoryByEvent(events[e].id, v, from, to);
      ArrayInsert(values, v, ArraySize(values));
     }
   return ArraySize(values);
  }
//+------------------------------------------------------------------+
void CopyCalendarValueData(MqlCalendarValue &value[], uchar &bytes[])
  {
   int n = ArraySize(value);
   for(int i = 0; i < n; i++)
     {
      CalendarValueData vd;
      vd.Id = value[i].id;
      vd.EventId = value[i].event_id;
      vd.Time = (int)value[i].time;
      vd.Period = (int)value[i].period;
      vd.Revision = value[i].revision;
      vd.ActualValue = value[i].actual_value;
      vd.PrevValue = value[i].prev_value;
      vd.RevisedPrevValue = value[i].revised_prev_value;
      vd.ForecastValue = value[i].forecast_value;
      vd.ImpactType = value[i].impact_type;
      uchar b[];
      StructToCharArray(vd, b);
      ArrayInsert(bytes, b, ArraySize(bytes));
     }
  }
//+------------------------------------------------------------------+
int SendChartData(Chart &chart, datetime from, datetime to) export
  {
   int st = iBarShift(SymbolName(chart.Market, true), (ENUM_TIMEFRAMES)chart.TimeFrame, to);
   int en = iBarShift(SymbolName(chart.Market, true), (ENUM_TIMEFRAMES)chart.TimeFrame, from);
   return SendChartData(chart, st, en - st);
  }
//+------------------------------------------------------------------+
int SendChartData(Chart &chart, int start, int cnt) export
  {
   int count = cnt + 200;
   uchar rd[];
   CopyRateData(chart, start, count, rd);
   uchar mdb[];
   int key = Vorn::Commands::SendChartData(rd);
   return key;
  }
//+------------------------------------------------------------------+
void ReadPointData(int key,  PointData &md[]) export
  {
   uchar mdb[];
   Vorn::Commands::ReadPointData(key, mdb, 60000);

   int m = ArraySize(mdb) / sizeof(PointData);
   ArrayResize(md, m);
   for(int i = 0; i < m; i++)
     {
      CharArrayToStruct(md[i], mdb, i * sizeof(PointData));
     }

  }
//+------------------------------------------------------------------+
void CalendarUpdate(datetime from, datetime to) export
  {
   uchar vd[];
   MqlCalendarValue values[];
   CalendarValueHistoryByCountry("US", from, to, values);
   CalendarValueHistoryByCountry("EU", from, to, values);
   CalendarValueHistoryByCountry("GB", from, to, values);
   CalendarValueHistoryByCountry("JP", from, to, values);
   CopyCalendarValueData(values, vd);
   Vorn::Commands::CreateClient();
   Vorn::Commands::CalendarUpdate(vd);
   Vorn::Commands::DeleteClient();
  }
//+------------------------------------------------------------------+
bool CopyMarketData(int market, int & timeframes[], int start, int count, uchar & bytes[])
  {
   for(int tf = 0; tf < ArraySize(timeframes); tf++)
     {
      MqlRates rates[];
      ArraySetAsSeries(rates, true);
      int n = CopyRates(SymbolName(market, true), (ENUM_TIMEFRAMES)timeframes[tf], start, count, rates);
      if(n != count)
         return false;
      double SARArray[];
      int hsar = iSAR(SymbolName(market, true), (ENUM_TIMEFRAMES)timeframes[tf], 0.02, 0.2);
      ArraySetAsSeries(SARArray, true);
      int sarcnt = CopyBuffer(hsar, 0, start, count, SARArray);
      if(sarcnt != count)
         return false;
      for(int i = 0; i < n; ++i)
        {
         RateData dst;
         dst.Index = i;
         dst.Market = market;
         dst.TimeFrame = timeframes[tf];
         dst.Time = (int)rates[i].time;
         dst.Open = rates[i].open;
         dst.Close = rates[i].close;
         dst.High = rates[i].high;
         dst.Low = rates[i].low;
         dst.Volume = rates[i].tick_volume;
         dst.ParabolicSar = SARArray[i];
         uchar b[];
         StructToCharArray(dst, b);
         ArrayInsert(bytes, b, ArraySize(bytes));
        }
     }
   return true;
  }
//+------------------------------------------------------------------+
int SendMarketData(int market, int & timeframes[], int start, int count) export
  {
   int cnt = count + 200;
   uchar rd[];
   CopyMarketData(market, timeframes, start, cnt, rd);
   uchar mdb[];
   int key = Vorn::Commands::SendMarketData(rd, cnt);
   return key;
  }
//+------------------------------------------------------------------+
