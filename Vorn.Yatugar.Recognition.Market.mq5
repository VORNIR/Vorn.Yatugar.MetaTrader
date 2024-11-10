//+------------------------------------------------------------------+
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
int SendMarketData(string sym, int & timeframes[], datetime From, int count);
bool ReadPointData(int key,  PointData &md[]);
string PointDataName(PointData &pd);
bool FindPointData(PointData & pds[], PointData & pd, int timeframe, int id = NULL, ulong state = NULL, int startIndex = 0);
bool DeinitializeYatugar();
#import
//+------------------------------------------------------------------+
#import "Vorn.Graphics.ex5"
void DrawVerticalLine(string name, datetime time, color clr = clrAqua, long width = 0, bool ray = false,  ENUM_LINE_STYLE style = STYLE_DOT);
void DrawHorizontalLine(string name, double p, color clr = clrAqua, long width = 0, ENUM_LINE_STYLE style = STYLE_DOT);
void DrawTrendline(string name, datetime time1, double price1, datetime time2, double price2,  color clr, long width = 0, bool rayRight = false, bool rayLeft = false, ENUM_LINE_STYLE style = STYLE_DOT);
void DrawFibonacci(string name, datetime d1, double p1, datetime d2, double p2,  color clr, long width = 0, bool rayRight = false,  ENUM_LINE_STYLE style = STYLE_DOT);
void AddShape(int window, string name, double level, datetime time, uchar code, color clr,  int size = 1, ENUM_ARROW_ANCHOR anchor = ANCHOR_TOP);
void ChangeShape(string name, uchar code);
void DrawRectangle(const string name, datetime time1, double price1, datetime time2, double price2, const color clr = clrAqua, const int width = 0, const bool fill = false, const bool back = false, const ENUM_LINE_STYLE style = STYLE_SOLID, const long z_order = 1);
void ClearChart();
void DrawButton(string name, string text, int x, int y, int width, int height, color clr, color textclr = clrWhite);
void DrawText(string name, string text, datetime time, double price, int size = 5, color textclr = clrWhite);
#import
//+------------------------------------------------------------------+
sinput int Candles = 1000;
sinput datetime From = NULL;
input group           "Colors"
sinput color W1Positive = C'34, 49, 59';
sinput color D1Positive = C'54, 69, 79';
sinput color H4Positive = C'10, 117, 143';
sinput color M30Positive = C'0,255,240';
sinput color M5Positive = clrGreenYellow;
sinput color M1Positive = C'162,240,162';
sinput color W1Negative = C'90, 0, 0';
sinput color D1Negative = C'128, 0, 0';
sinput color H4Negative = C'219,22,47';
sinput color M30Negative = C'199, 91, 122';
sinput color M5Negative = clrMediumVioletRed;
sinput color M1Negative = C'255,166,215';
sinput color W1Warning = C'119,15,15';
sinput color D1Warning = C'139,35,35';
sinput color H4Warning = C'235, 91, 0';
sinput color M30Warning = C'255, 178, 0';
sinput color M5Warning = C'243,238,194';
sinput color M1Warning = C'249,245,221';
sinput color H4Fundamental = C'244, 206, 20';
input group           "Display"
sinput bool Master = true; // Master Fibonacci Retracement
sinput bool Switch = true; // Switch Fibonacci Retracement
sinput bool ExtremeAreas = true; //Extreme Areas
sinput bool Fundamental = true; //Fundamental Events
sinput bool Signals = true; //Signals
input group           "W1 "
sinput bool W1 = false; // W1 Enabled
sinput int W1Size = 6; // W1 Icon Size
sinput int W1Offset = 6; // W1 Icon Size
input group           "D1 "
sinput bool D1 = true; // D1 Enabled
sinput int D1Size = 5; // D1 Icon Size
sinput int D1Offset = 5; // D1 Icon Size
input group           "H4 "
sinput bool H4 = true; // H4 Enabled
sinput int H4Size = 4; // H4 Icon Size
sinput int H4Offset = 4; // H4 Icon Size
input group           "M30"
sinput bool M30 = true; // M30 Enabled
sinput int M30Size = 3; // M30 Icon Size
sinput int M30Offset = 3; // M30 Icon Size
input group           "M5"
sinput bool M5 = false; // M5 Enabled
sinput int M5Size = 2; // M5 Icon Size
sinput int M5Offset = 2; // M5 Icon Size
input group           "M1"
sinput bool M1 = false; // M1 Enabled
sinput int M1Size = 1; // M1 Icon Size
sinput int M1Offset = 1; // M1 Icon Size
//+------------------------------------------------------------------+
PointData pointData[];
PointData economicData[];
int timeframes[] = {};
string actions[] = {"F", "U", "X", "T", "M"};
//+------------------------------------------------------------------+
void DrawPointData(PointData & pd, double position)
  {
   AddShape(pd.Window,
            PointDataName(pd),
            position + 100 * SymbolInfoDouble(_Symbol, SYMBOL_POINT) * pd.Offset * (pd.Anchor == ANCHOR_TOP ? -1 : 1),
            pd.Time,
            pd.Icon,
            pd.Color,
            pd.Size,
            (ENUM_ARROW_ANCHOR)pd.Anchor);
  }
//+------------------------------------------------------------------+
void DrawPointData(PointData & pd, color pcolor, color ncolor, color wcolor, int size, int offset)
  {
   pd.Size = size;
   pd.Offset = offset;
   if((pd.States & StateValues::PositiveMaster()) > 0)
     {
      pd.Color = pcolor;
      pd.Icon = 116;
      pd.Anchor = ANCHOR_TOP;
      if(Master)
         DrawPointData(pd, pd.F0);
     }
   if((pd.States & StateValues::NegativeMaster()) > 0)
     {
      pd.Color = ncolor;
      pd.Icon = 116;
      pd.Anchor = ANCHOR_BOTTOM;
      if(Master)
         DrawPointData(pd, pd.F0);
     }
   if((pd.States & StateValues::PositiveBaseSwitch()) > 0)
     {
      pd.Color = pcolor;
      pd.Icon = 161;
      pd.Anchor = ANCHOR_TOP;
      if(Switch)
         DrawPointData(pd, pd.Low);
     }
   if((pd.States & StateValues::NegativeBaseSwitch()) > 0)
     {
      pd.Color = ncolor;
      pd.Icon = 161;
      pd.Anchor = ANCHOR_BOTTOM;
      if(Switch)
         DrawPointData(pd, pd.High);
     }
   if((pd.States & StateValues::SignalA1()) > 0)
     {
      pd.Color = pcolor;
      DrawText(PointDataName(pd) + "L", "A1", pd.Time, pd.Low - 5 * (pd.High - pd.Low), 7 + size, pd.Color);
     }
   if((pd.States & StateValues::SignalA2()) > 0)
     {
      pd.Color = ncolor;
      DrawText(PointDataName(pd) + "L", "A2", pd.Time, pd.High + 5 * (pd.High - pd.Low),  7 + size, pd.Color);
     }
//if((pd.States & StateValues::SignalBb1()) > 0)
//  {
//   pd.Color = pcolor;
//   DrawText(PointDataName(pd) + "L", "Bb1", pd.Time, pd.Low - 5 * (pd.High - pd.Low), 7 + size, pd.Color);
//  }
//if((pd.States & StateValues::SignalBb2()) > 0)
//  {
//   pd.Color = ncolor;
//   DrawText(PointDataName(pd) + "L", "Bb2", pd.Time, pd.High + 5 * (pd.High - pd.Low),  7 + size, pd.Color);
//  }
   if((pd.States & StateValues::SignalB1()) > 0)
     {
      pd.Color = pcolor;
      DrawText(PointDataName(pd) + "L", "B1", pd.Time, pd.Low - 5 * (pd.High - pd.Low), 7 + size, pd.Color);
     }
   if((pd.States & StateValues::SignalB2()) > 0)
     {
      pd.Color = ncolor;
      DrawText(PointDataName(pd) + "L", "B2", pd.Time, pd.High + 5 * (pd.High - pd.Low),  7 + size, pd.Color);
     }
//if((pd.States & StateValues::SignalP1()) > 0)
//  {
//   pd.Color = pcolor;
//   DrawText(PointDataName(pd) + "LP1", "P1", pd.Time, pd.High + 4 * (pd.High - pd.Low), 7 + size, pd.Color);
//  }
//if((pd.States & StateValues::SignalP2()) > 0)
//  {
//   pd.Color = ncolor;
//   DrawText(PointDataName(pd) + "LP2", "P2", pd.Time, pd.Low - 4 * (pd.High - pd.Low),  7 + size, pd.Color);
//}
//if((pd.States & StateValues::SignalO1()) > 0)
//  {
//   pd.Color = pcolor;
//   DrawText(PointDataName(pd) + "L", "O1", pd.Time, pd.Low - 3 * (pd.High - pd.Low), 7 + size, pd.Color);
//  }
//if((pd.States & StateValues::SignalO2()) > 0)
//  {
//   pd.Color = ncolor;
//   DrawText(PointDataName(pd) + "L", "O2", pd.Time, pd.High + 3 * (pd.High - pd.Low),  7 + size, pd.Color);
//  }
   if((pd.States & StateValues::SignalT1()) > 0)
     {
      pd.Color = wcolor;
      double labelPrice = pd.Low - 4 * (pd.High - pd.Low);
      DrawTrendline(PointDataName(pd) + "VT1", pd.Time, labelPrice, pd.Time, (pd.High + pd.Low) / 2, pd.Color);
      DrawText(PointDataName(pd) + "LT1", "T1", pd.Time, labelPrice, 7 + size, pd.Color);
     }
   if((pd.States & StateValues::SignalT2()) > 0)
     {
      pd.Color = wcolor;
      double labelPrice = pd.High + 4 * (pd.High - pd.Low);
      DrawTrendline(PointDataName(pd) + "VT2", pd.Time, labelPrice, pd.Time, (pd.High + pd.Low) / 2, pd.Color);
      DrawText(PointDataName(pd) + "LT2", "T2", pd.Time, labelPrice, 7 + size, pd.Color);
     }
   if((pd.States & StateValues::SignalU()) > 0)
     {
      pd.Color = wcolor;
     }
   if((pd.States & StateValues::MaPeak()) > 0)
     {
      pd.Color = ncolor;
     }
   if((pd.States & StateValues::MaTrough()) > 0)
     {
      pd.Color = pcolor;
     }
   if((pd.States & StateValues::EquilibriumExtreme()) > 0)
     {
      pd.Offset = 0;
      pd.Color = wcolor;
      pd.Icon = 159;
      pd.Anchor = ANCHOR_TOP;
      if(ExtremeAreas)
         DrawPointData(pd, pd.AreaStart);
     }
   if((pd.States & StateValues::MacdResonance()) > 0)
     {
      pd.Offset = 0;
      pd.Icon = 159;
      string indName = "MACD(48,104,36)";
      int window = ChartWindowFind(0, indName);
      pd.Window = window;
      int handle = ChartIndicatorGet(0, window, indName);
      int index = iBarShift(_Symbol, _Period, pd.Time);
      double m[];
      CopyBuffer(handle, 0, index, 1,  m);
      double macd = m[0];
      if(pd.Macd > 0)
        {
         pd.Anchor = ANCHOR_BOTTOM;
         pd.Color = pcolor;
        }
      if(pd.Macd < 0)
        {
         pd.Color = ncolor;
         pd.Anchor = ANCHOR_TOP;
        }
      DrawPointData(pd,  macd * pd.Macd > 0 ? macd : 0);
     }
  }
//+------------------------------------------------------------------+
void  DrawButtons()
  {
   color clr = C'73, 78, 101';
   int w = 25;
   int h = 25;
   int g = 1;
   int x = 10, y = 20;
   int ww = (ArraySize(timeframes) + 1) * w + ArraySize(timeframes) * g;
   DrawButton("Remove", "Close", x, y, ww, h, clr);
   for(int a = 0; a < ArraySize(actions); a++)
     {
      y += (h + g);
      DrawButton(actions[a], actions[a], x, y, w, h, clr);
      for(int t = 0, x = 10; t < ArraySize(timeframes); t++)
        {
         x += w + g;
         DrawButton(actions[a] + (string)timeframes[t], Vorn::Commands::GetTimeFrameName(timeframes[t]), x, y, w, h, clr);
        }
     }
   x = 10;
   y += (h + g);
   DrawButton("Clear", "Clear", x, y, ww, h, clr);
   ChartRedraw();
  }
//+------------------------------------------------------------------+
int OnInit()
  {
   ClearObjects();
   ClearIcons();
   if(!InitializeYatugar())
     {
      DeinitializeYatugar();
      return(INIT_FAILED);
     }
//int edkey = Vorn::Commands::GetEconomicData(_Symbol);
   int market = Vorn::Commands::GetMarket(_Symbol);
   if(W1)
      Vorn::Commands::AddTimeFrame(PERIOD_W1, "W1");
   if(D1)
      Vorn::Commands::AddTimeFrame(PERIOD_D1, "D1");
   if(H4)
      Vorn::Commands::AddTimeFrame(PERIOD_H4, "H4");
   if(M30)
      Vorn::Commands::AddTimeFrame(PERIOD_M30, "M30");
   if(M5)
      Vorn::Commands::AddTimeFrame(PERIOD_M5, "M5");
   if(M1)
      Vorn::Commands::AddTimeFrame(PERIOD_M1, "M1");
   Vorn::Commands::GetTimeFrames(timeframes);
   bool result = false;
   if(From == NULL)
      result = ReadPointData(SendMarketData(_Symbol, timeframes, TimeCurrent(), Candles), pointData);
   else
      result = ReadPointData(SendMarketData(_Symbol, timeframes, From, Candles), pointData);
   if(!result)
      ExpertRemove();
//ReadPointData(edkey, economicData);
//for(int p = 0; p < ArraySize(economicData); p++)
//   DrawVerticalLine(StringFormat("+E%d", p), economicData[p].Time, H4Fundamental);
   for(int p = 0; p < ArraySize(pointData); p++)
     {
      if(pointData[p].TimeFrame == PERIOD_W1)
        {
         DrawPointData(pointData[p], W1Positive, W1Negative, W1Warning, W1Size, W1Offset);
        }
      if(pointData[p].TimeFrame == PERIOD_D1)
        {
         DrawPointData(pointData[p], D1Positive, D1Negative, D1Warning, D1Size, D1Offset);
        }
      if(pointData[p].TimeFrame == PERIOD_H4)
        {
         DrawPointData(pointData[p], H4Positive, H4Negative, H4Warning, H4Size, H4Offset);
        }
      if(pointData[p].TimeFrame == PERIOD_M30)
        {
         DrawPointData(pointData[p], M30Positive, M30Negative, M30Warning, M30Size, M30Offset);
        }
      if(pointData[p].TimeFrame == PERIOD_M5)
        {
         DrawPointData(pointData[p], M5Positive, M5Negative, M5Warning, M5Size, M5Offset);
        }
      if(pointData[p].TimeFrame == PERIOD_M1)
        {
         DrawPointData(pointData[p], M1Positive, M1Negative, M1Warning, M1Size, M1Offset);
        }
     }
   DrawButtons();
   ChartRedraw();
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   DeinitializeYatugar();
   ClearButtons();
  }
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long & lparam, const double & dparam, const string & sparam)
  {
   ENUM_CHART_EVENT evt = (ENUM_CHART_EVENT)id;
   if(evt != CHARTEVENT_OBJECT_CLICK)
      return;
   string name = sparam;
   if(StringSubstr(name, 0, 1) == "-")
      return;
   if(name == "F")
     {
      for(int tf = 0; tf < ArraySize(timeframes); tf++)
        {
         ToggleLastMaster(pointData, timeframes[tf]);
        }
      return;
     }
   else
      if(StringSubstr(name, 0, 1) == "F")
        {
         int tf = (int)StringSubstr(name, 1);
         ToggleLastMaster(pointData, tf);
         return;
        }
   if(name == "U")
     {
      for(int i = 0; i < ArraySize(pointData); i++)
        {
         ToggleUnbalancing(pointData[i]);
        }
      return;
     }
   else
      if(StringSubstr(name, 0, 1) == "U")
        {
         int tf = (int)StringSubstr(name, 1);
         for(int i = 0; i < ArraySize(pointData); i++)
           {
            if(pointData[i].TimeFrame == tf)
               ToggleUnbalancing(pointData[i]);
           }
         return;
        }
   if(name == "X")
     {
      for(int i = 0; i < ArraySize(pointData); i++)
        {
         ToggleArea(pointData[i]);
        }
      return;
     }
   else
      if(StringSubstr(name, 0, 1) == "X")
        {
         int tf = (int)StringSubstr(name, 1);
         for(int i = 0; i < ArraySize(pointData); i++)
           {
            if(pointData[i].TimeFrame == tf)
               ToggleArea(pointData[i]);
           }
         return;
        }
   if(name == "T")
     {
      for(int i = 0; i < ArraySize(pointData); i++)
        {
         if((pointData[i].States & StateValues::SignalT()) > 0)
            ToggleArea(pointData[i]);
         if((pointData[i].States & StateValues::SignalU()) > 0)
            ToggleArea(pointData[i]);
        }
      return;
     }
   else
      if(StringSubstr(name, 0, 1) == "T")
        {
         int tf = (int)StringSubstr(name, 1);
         for(int i = 0; i < ArraySize(pointData); i++)
           {
            if(pointData[i].TimeFrame == tf)
              {
               if((pointData[i].States & StateValues::SignalT()) > 0)
                  ToggleArea(pointData[i]);
               if((pointData[i].States & StateValues::SignalU()) > 0)
                  ToggleVerticalLine(pointData[i]);
              }
           }
         return;
        }
   if(name == "M")
     {
      for(int i = 0; i < ArraySize(pointData); i++)
        {
         if((pointData[i].States & StateValues::MaExtreme()) > 0)
            ToggleVerticalLine(pointData[i]);
        }
      return;
     }
   else
      if(StringSubstr(name, 0, 1) == "M")
        {
         int tf = (int)StringSubstr(name, 1);
         if(name == "M" + (string)tf)
            for(int i = 0; i < ArraySize(pointData); i++)
              {
               if(pointData[i].TimeFrame == tf)
                  if((pointData[i].States & StateValues::MaExtreme()) > 0)
                     ToggleVerticalLine(pointData[i]);
              }
         return;
        }
   if(name == "Clear")
     {
      ClearObjects();
      return;
     }
   if(name == "Remove")
     {
      ClearObjects();
      ClearIcons();
      ClearButtons();
      ExpertRemove();
      return;
     }
   int t = StringFind(name, "T");
   if(t > 0)
     {
      int s = StringFind(name, "S");
      ulong state = (ulong)StringToInteger(StringSubstr(name, 1, s));
      int id = (int)StringToInteger(StringSubstr(name, s + 1, t));
      int timeframe = (int)StringToInteger(StringSubstr(name, t + 1));
      PointData pd;
      for(int i = 0; i < ArraySize(pointData); i++)
        {
         if(pointData[i].Id == id)
           {
            pd = pointData[i];
            break;
           }
        }
      ToggleFiboUnba(pd);
      //if((state & StateValues::EquilibriumExtreme()) > 0)
      ToggleArea(pd);
      ChartRedraw();
      return;
     }
  }
//+------------------------------------------------------------------+
void ToggleFiboUnba(PointData & pd)
  {
   if(pd.Unbalancing > 0)
     {
      if(ToggleFibo(pd))
         ToggleUnbalancing(pd);
     }
   else
      ToggleFibo(pd);
  }
//+------------------------------------------------------------------+
bool ToggleFibo(PointData & pd)
  {
   if(!(pd.F0 > 0))
      return false;
   string name = PointDataName(pd);
   string fiboName = "-Fibo" + name;
   string reverse = "-R" + name;
   if(ObjectFind(0, fiboName) < 0)
     {
      DrawFibonacci(
         fiboName,
         pd.Time,
         pd.F100,
         pd.Time,
         pd.F0,
         (color)pd.Color,
         0,
         true);
      DrawTrendline(reverse,
                    pd.Time,
                    pd.ReverseRate,
                    TimeCurrent(),
                    pd.ReverseRate,
                    (color)pd.Color,
                    0,
                    true,
                    false,
                    STYLE_SOLID);
      ChartRedraw();
      return true;
     }
   else
     {
      ObjectDelete(0, fiboName);
      ObjectDelete(0, reverse);
      ChartRedraw();
      return false;
     }
  }
//+------------------------------------------------------------------+
bool ToggleUnbalancing(PointData & pd)
  {
   if(!(pd.Unbalancing > 0))
      return false;
   string name = PointDataName(pd);
   string fiboUnbalacingName = "-Ub" + name;
   string vertical = "-V" + fiboUnbalacingName;
   string horizontal = "-H" + fiboUnbalacingName;
   if(ObjectFind(0, vertical) < 0)
     {
      DrawTrendline(vertical,
                    pd.Time,
                    pd.F0,
                    pd.Time,
                    pd.Unbalancing,
                    (color)pd.Color,
                    0);
      DrawTrendline(horizontal,
                    pd.Time,
                    pd.Unbalancing,
                    TimeCurrent(),
                    pd.Unbalancing,
                    (color)pd.Color,
                    0,
                    true,
                    false,
                    STYLE_SOLID);
      ChartRedraw();
      return true;
     }
   else
     {
      ObjectDelete(0, vertical);
      ObjectDelete(0, horizontal);
      ChartRedraw();
      return false;
     }
  }
//+------------------------------------------------------------------+
bool ToggleArea(PointData & pd)
  {
   string name = PointDataName(pd);
   if(!(pd.AreaStart > 0))
      return false;
   string areaHighName = "-Eh" + name;
   string areaLowName = "-El" + name;
   string areaVerticalName = "-Ev" + name;
   if(ObjectFind(0, areaHighName) < 0)
     {
      DrawTrendline(areaVerticalName,
                    pd.AreaStartTime,
                    pd.AreaStart,
                    pd.AreaEndTime,
                    pd.AreaEnd,
                    (color)pd.Color,
                    0);
      DrawHorizontalLine(areaHighName, pd.AreaStart, pd.Color, 0, STYLE_SOLID);
      DrawHorizontalLine(areaLowName, pd.AreaEnd, pd.Color, 0, STYLE_SOLID);
      return true;
     }
   else
     {
      ObjectDelete(0, areaVerticalName);
      ObjectDelete(0, areaHighName);
      ObjectDelete(0, areaLowName);
      return false;
     }
  }
//+------------------------------------------------------------------+
bool ToggleVerticalLine(PointData & pd)
  {
   string name = PointDataName(pd);
   string areaVerticalName = "-Vl" + name;
   if(ObjectFind(0, areaVerticalName) < 0)
     {
      DrawVerticalLine(areaVerticalName, pd.Time, pd.Color);
      return true;
     }
   else
     {
      ObjectDelete(0, areaVerticalName);
      return false;
     }
  }
//+------------------------------------------------------------------+
void ToggleLastMaster(PointData & pd[], int tf)
  {
   PointData pd1;
   if(FindPointData(pd, pd1, tf, NULL, StateValues::Master()))
     {
      if(ToggleFibo(pd1))
        {
         ToggleUnbalancing(pd1);
        }
      else
        {
         PointData pd2;
         if(FindPointData(pd, pd2, tf, NULL, StateValues::Master(), pd1.Id + 1))
           {
            ToggleFibo(pd2);
            ToggleUnbalancing(pd2);
           }
        }
     }
  }
//+------------------------------------------------------------------+
void ClearObjects()
  {
   ObjectsDeleteAll(0, "-");
   ChartRedraw();
  }
//+------------------------------------------------------------------+
void ClearIcons()
  {
   ObjectsDeleteAll(0, "+");
   ChartRedraw();
  }
//+------------------------------------------------------------------+
void ClearButtons()
  {
   for(int a = 0; a < ArraySize(actions); a++)
     {
      ObjectsDeleteAll(0, actions[a]);
     }
   ObjectDelete(0, "Clear");
   ObjectDelete(0, "Remove");
  }
//+------------------------------------------------------------------+
