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
string PointDataName(PointData &pd) export
  {
   string name = StringFormat("+%I64uS%dT%d", pd.States, pd.Id, pd.TimeFrame);
   return name;
  }
//+------------------------------------------------------------------+
bool FindPointData(PointData & pds[], PointData & pd, int timeframe, int id = NULL, ulong state = NULL, int startIndex = 0) export
  {
   for(int i = startIndex; i < ArraySize(pds); i++)
     {
      if(pds[i].TimeFrame == timeframe)
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
void CopyRateData(int market, int timeframe, int start, int count, uchar &bytes[]) export
  {
   MqlRates rates[];
   ArraySetAsSeries(rates, true);
   int n = CopyRates(SymbolName(market, true), (ENUM_TIMEFRAMES)timeframe, start, count, rates);
   double SARArray[];
   int hsar = iSAR(SymbolName(market, true), (ENUM_TIMEFRAMES)timeframe, 0.02, 0.2);
   ArraySetAsSeries(SARArray, true);
   CopyBuffer(hsar, 0, start, count, SARArray);
   for(int i = 0; i < n; ++i)
     {
      RateData dst;
      dst.Index = i;
      dst.Market = market;
      dst.TimeFrame = timeframe;
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
bool CopyMarketData(int market, int & timeframes[], datetime from, int count, uchar & bytes[])
  {
   for(int tf = 0; tf < ArraySize(timeframes); tf++)
     {
      int start = iBarShift(SymbolName(market, true), (ENUM_TIMEFRAMES)timeframes[tf], from);
      CopyRateData(market, timeframes[tf], start, count, bytes);
     }
   return true;
  }
//+------------------------------------------------------------------+
int SendMarketData(int market, int & timeframes[], datetime from, int count) export
  {
   int cnt = count + 200;
   uchar rd[];
   CopyMarketData(market, timeframes, from, cnt, rd);
   uchar mdb[];
   int key = Vorn::Commands::SendMarketData(rd, cnt);
   return key;
  }
//+------------------------------------------------------------------+
