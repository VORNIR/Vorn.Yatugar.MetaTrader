//+------------------------------------------------------------------+
//|                                                             Vorn |
//|                                                  https://vorn.ir |
//+------------------------------------------------------------------+
#property library
#property copyright "Vorn"
#property link      "https://vorn.ir"
#property version   "1.00"
//+------------------------------------------------------------------+
#import "Vorn.Yatugar.Separ.OfflineClient.dll"
#import
//+------------------------------------------------------------------+
#import "Vorn.Yatugar.Separ.Common.dll"
#import
//+------------------------------------------------------------------+
bool InitializeYatugar() export
  {
   bool connected = Vorn::Commands::CreateClient();
   return connected;
  }
//+------------------------------------------------------------------+
bool DeinitializeYatugar() export
  {
   return Vorn::Commands::DeleteClient();
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
void CopyRateData(string sym, int timeframe, int start, int count, uchar &bytes[]) export
  {
   MqlRates rates[];
   ArraySetAsSeries(rates, true);
   int n = CopyRates(sym, (ENUM_TIMEFRAMES)timeframe, start, count, rates);
   double SARArray[];
   int hsar = iSAR(sym, (ENUM_TIMEFRAMES)timeframe, 0.02, 0.2);
   ArraySetAsSeries(SARArray, true);
   int sarCount = CopyBuffer(hsar, 0, start, count, SARArray);
   ulong ulong_var = 0;
   for(int i = 0; i < StringLen(sym); i++)
     {
      ulong_var <<= 8;
      ulong_var |= uchar(sym[i]);
     }
   double pointValue = SymbolInfoDouble(sym, SYMBOL_POINT);
   double tickValue = SymbolInfoDouble(sym, SYMBOL_TRADE_TICK_VALUE);
   double pv = CalculatePriceVolatility(rates);
   for(int i = 0; i < n; ++i)
     {
      double price = rates[i].high;
      double priceChange = price * 0.01;
      double pointsChanged = priceChange / pointValue;
      double monetaryValue = pointsChanged * tickValue;
      RateData dst;
      dst.Index = i;
      dst.MarketName = ulong_var;
      //dst.Market = market;
      dst.Volatility = pv * monetaryValue;
      dst.TimeFrame = timeframe;
      dst.Time = (int)rates[i].time;
      dst.Open = rates[i].open;
      dst.Close = rates[i].close;
      dst.High = rates[i].high;
      dst.Low = rates[i].low;
      dst.Volume = rates[i].tick_volume;
      if(i < sarCount)
         dst.ParabolicSar = SARArray[i];
      uchar b[];
      StructToCharArray(dst, b);
      ArrayInsert(bytes, b, ArraySize(bytes));
     }
  }
//+------------------------------------------------------------------+
double CalculatePriceVolatility(MqlRates & rates[])
  {
   double sum = 0.0;
   double sumSquared = 0.0;
   for(int i = 0; i < ArraySize(rates); i++)
     {
      double rangeHighLow = (rates[i].high - rates[i].low) / rates[i].high;
      sum += rangeHighLow;
      sumSquared += rangeHighLow * rangeHighLow;
     }
   double mean = sum / ArraySize(rates);
   double variance = (sumSquared / ArraySize(rates)) - (mean * mean);
   return MathSqrt(variance);
  }
//+------------------------------------------------------------------+
bool CopyMarketData(string sym, int & timeframes[], datetime from, int count, uchar & bytes[])
  {
   for(int tf = 0; tf < ArraySize(timeframes); tf++)
     {
      int start = iBarShift(sym, (ENUM_TIMEFRAMES)timeframes[tf], from);
      CopyRateData(sym, timeframes[tf], start, count, bytes);
     }
   return true;
  }
//+------------------------------------------------------------------+
void DoMarketRecognition(string sym, int & timeframes[], datetime from, int count, PointData &md[]) export
  {
   uchar rd[];
   uchar mdb[];
   CopyMarketData(sym, timeframes, from, count, rd);
   Vorn::Commands::DoMarketRecognition(rd, count, mdb);
   int m = ArraySize(mdb) / sizeof(PointData);
   ArrayResize(md, m);
   for(int i = 0; i < m; i++)
     {
      CharArrayToStruct(md[i], mdb, i * sizeof(PointData));
     }
  }
//+------------------------------------------------------------------+
int SendMarketData(string sym, int & timeframes[], datetime from, int count) export
  {
   uchar rd[];
   CopyMarketData(sym, timeframes, from, count, rd);
   int key = Vorn::Commands::SendMarketData(rd, count);
   return key;
  }
//+------------------------------------------------------------------+
bool ReadPointData(int key,  PointData &md[]) export
  {
   uchar mdb[];
   bool result = Vorn::Commands::ReadPointData(key, mdb, 15000);
   if(result)
     {
      int m = ArraySize(mdb) / sizeof(PointData);
      ArrayResize(md, m);
      for(int i = 0; i < m; i++)
        {
         CharArrayToStruct(md[i], mdb, i * sizeof(PointData));
        }
     }
   return result;
  }
//+------------------------------------------------------------------+
string UlongToString(ulong ulong_var) export
  {
   string result = "";
   for(int i = 0; i < 8; i++)
     {
      uchar byte = (uchar)(ulong_var >> (56 - i * 8)) & 0xFF;
      if(byte != 0)
         result += CharToString(byte);
     }
   return result;
  }
//+------------------------------------------------------------------+
