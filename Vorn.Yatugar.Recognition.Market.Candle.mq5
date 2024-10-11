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
int SendMarketData(int market, int & timeframes[], int start, int count);
int SendChartData(Chart &chart, int start, int cnt);
void ReadPointData(int key,  PointData &md[]);
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
#import
//+------------------------------------------------------------------+
sinput int Candles = 1000;
input group           "Colors"
sinput color D1Positive = C'54, 69, 79';
sinput color H4Positive = C'10, 117, 143';
sinput color M30Positive = C'0,255,240';
sinput color D1Negative = C'128, 0, 0';
sinput color H4Negative = C'219,22,47';
sinput color M30Negative = C'199, 91, 122';
sinput color D1Warning = C'139,35,35';
sinput color H4Warning = C'235, 91, 0';
sinput color M30Warning = C'255, 178, 0';
sinput color H4Fundamental = C'244, 206, 20';
sinput color M5Positive = clrGreenYellow;
sinput color M5Negative = clrMediumVioletRed;
sinput color M5Warning = C'243,238,194';
sinput color M1Positive = C'162,240,162';
sinput color M1Negative = C'255,166,215';
sinput color M1Warning = C'249,245,221';
input group           "Display"
sinput bool Master = true; // Master Fibonacci Retracement
sinput bool Switch = true; // Switch Fibonacci Retracement
sinput bool ExtremeAreas = true; //Extreme Areas
sinput bool Fundamental = true; //Fundamental Events
sinput bool Signals = true; //Signals
sinput bool LeftTargets = true; //LeftTargets
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
sinput bool M5 = true; // M5 Enabled
sinput int M5Size = 2; // M5 Icon Size
sinput int M5Offset = 2; // M5 Icon Size
input group           "M1"
sinput bool M1 = true; // M1 Enabled
sinput int M1Size = 1; // M1 Icon Size
sinput int M1Offset = 1; // M1 Icon Size
//+------------------------------------------------------------------+
PointData pointDataM1[];
PointData pointDataM5[];
PointData pointDataM30[];
PointData pointDataH4[];
PointData pointDataD1[];
//+------------------------------------------------------------------+
struct DrawPointSetting
  {
   bool              Master;
   bool              Switch;
   bool              ExtremeAreas;
   bool              Signals;
  };
//+------------------------------------------------------------------+
struct DrawPointConfig
  {
   ulong             WantedStates;
   ulong             UnwantedStates;
   color             Color;
   uchar             Code;
   int               Size;
   int               Offset;
   ENUM_APPLIED_PRICE Position;
   int               Window;
  };
//+------------------------------------------------------------------+
void DrawMasters(PointData &pd[], int size, int offset, color pcolor, color ncolor)
  {
   DrawPointConfig conf;
   conf.WantedStates = StateValues::PositiveMaster();
   conf.UnwantedStates = 0;
   conf.Color = pcolor;
   conf.Code = 116;
   conf.Size = size;
   conf.Offset = offset;
   conf.Position = PRICE_LOW;
   DrawPoint(pd, conf);
   conf.WantedStates = StateValues::NegativeMaster();
   conf.Color = ncolor;
   conf.Position = PRICE_HIGH;
   DrawPoint(pd, conf);
  }
//+------------------------------------------------------------------+
void DrawSwitch(PointData &pd[], int size, int offset,  color pcolor, color ncolor)
  {
   DrawPointConfig conf;
   conf.WantedStates = StateValues::PositiveBaseSwitch();
   conf.UnwantedStates = 0;
   conf.Color = pcolor;
   conf.Code = 162;
   conf.Size = size;
   conf.Offset = offset;
   conf.Position = PRICE_LOW;
   DrawPoint(pd, conf);
   conf.WantedStates = StateValues::NegativeBaseSwitch();
   conf.Color = ncolor;
   conf.Position = PRICE_HIGH;
   DrawPoint(pd, conf);
  }
//+------------------------------------------------------------------+
void DrawExtremeArea(PointData &pd[], int size, int offset,  color wcolor)
  {
   DrawPointConfig conf;
   conf.WantedStates = StateValues::EquilibriumExtreme();
   conf.UnwantedStates = 0;
   conf.Color = wcolor;
   conf.Code = 108;
   conf.Size = size;
   conf.Offset = offset;
   conf.Position = PRICE_LOW;
   DrawPoint(pd, conf);
  }
//+------------------------------------------------------------------+
void DrawFundamental(PointData &pd[], int size, int offset, color pcolor, color ncolor, color wcolor)
  {
   DrawPointConfig conf;
   conf.WantedStates = StateValues::PositiveFundamental();
   conf.UnwantedStates = 0;
   conf.Color = pcolor;
   conf.Code = 181;
   conf.Size = size;
   conf.Offset = offset;
   conf.Position = PRICE_LOW;
   DrawPoint(pd, conf);
   conf.WantedStates = StateValues::NegativeFundamental();
   conf.Color = ncolor;
   conf.Position = PRICE_LOW;
   DrawPoint(pd, conf);
   conf.WantedStates = StateValues::NeutralFundamental();
   conf.Color = wcolor;
   conf.Position = PRICE_LOW;
   DrawPoint(pd, conf);
  }
//+------------------------------------------------------------------+
void DrawSignal(PointData &pd[], int size, int offset, color pcolor, color ncolor)
  {
   DrawPointConfig conf;
   conf.WantedStates = StateValues::SignalA1();
   conf.UnwantedStates = 0;
   conf.Color = pcolor;
   conf.Code = 140;
   conf.Size = size;
   conf.Offset = offset;
   conf.Position = PRICE_LOW;
   DrawPoint(pd, conf);
   conf.WantedStates = StateValues::SignalB1();
   conf.Code = 142;
   DrawPoint(pd, conf);
   conf.WantedStates = StateValues::SignalA2();
   conf.Color = ncolor;
   conf.Position = PRICE_HIGH;
   conf.Code = 141;
   DrawPoint(pd, conf);
   conf.WantedStates = StateValues::SignalB2();
   conf.Code = 143;
   DrawPoint(pd, conf);
  }
//+------------------------------------------------------------------+
void DrawLevelCrossing(PointData &pd[], int size, color wcolor)
  {
   DrawPointConfig conf;
   conf.WantedStates = StateValues::LevelCrossing();
   conf.UnwantedStates = 0;
   for(int i = 0; i < ArraySize(pd); i++)
     {
      if((pd[i].States & conf.WantedStates) == false)
         continue;
      if((pd[i].States & conf.UnwantedStates) == true)
         continue;
      DrawVerticalLine(PointDataName(pd[i]), pd[i].Time, wcolor, 0, true, STYLE_DOT);
     }
  }
//+------------------------------------------------------------------+
void ToggleLeftTarget(PointData &pd[], color pcolor, color ncolor)
  {
   DrawPointConfig conf;
   conf.WantedStates = StateValues::LeftTarget();
   conf.UnwantedStates = 0;
   for(int i = 0; i < ArraySize(pd); i++)
     {
      if((pd[i].States & conf.WantedStates) == false)
         continue;
      if((pd[i].States & conf.UnwantedStates) == true)
         continue;
      string name = "-" + PointDataName(pd[i]);
      if(ObjectFind(0, name) < 0)
        {
         color clr = clrNONE;
         ulong p = StateValues::LeftPositiveTarget();
         ulong n = StateValues::LeftNegativeTarget();
         if((pd[i].States & p) > 0)
            clr = ncolor;
         if((pd[i].States & n) > 0)
            clr = pcolor;
         DrawVerticalLine(name, pd[i].Time, clr);
        }
      else
        {
         ObjectDelete(0, name);
        }
     }
  }
//+------------------------------------------------------------------+
void DrawMaExtreme(PointData &pd[], int size, int offset, color wcolor)
  {
   DrawPointConfig conf;
   conf.WantedStates = StateValues::MaExtreme();
   conf.UnwantedStates = 0;
   for(int i = 0; i < ArraySize(pd); i++)
     {
      if((pd[i].States & conf.WantedStates) == false)
         continue;
      if((pd[i].States & conf.UnwantedStates) == true)
         continue;
      ENUM_ARROW_ANCHOR anch = ANCHOR_TOP;
      ulong p = StateValues::MaPeak();
      ulong n = StateValues::MaTrough();
      if((pd[i].States & p) > 0)
         anch = ANCHOR_BOTTOM;
      if((pd[i].States & n) > 0)
         anch = ANCHOR_TOP;
      AddShape(0,
               PointDataName(pd[i]),
               pd[i].F0,
               pd[i].Time,
               (uchar)158,
               wcolor,
               size,
               anch);
     }
  }
//+------------------------------------------------------------------+
void ToggleMacdSignChange(PointData &pd[], color pcolor, color ncolor)
  {
   DrawPointConfig conf;
   conf.WantedStates = StateValues::MacdSignChange();
   conf.UnwantedStates = 0;
   for(int i = 0; i < ArraySize(pd); i++)
     {
      if((pd[i].States & conf.WantedStates) == false)
         continue;
      if((pd[i].States & conf.UnwantedStates) == true)
         continue;
      string name = "-" + PointDataName(pd[i]);
      if(ObjectFind(0, name) < 0)
        {
         color clr = clrNONE;
         ulong p = StateValues::PositiveMacdSignChange();
         ulong n = StateValues::NegativeMacdSignChange();
         if((pd[i].States & p) > 0)
            clr = pcolor;
         if((pd[i].States & n) > 0)
            clr = ncolor;
         DrawVerticalLine(name, pd[i].Time, clr, 0, true, STYLE_DOT);
        }
      else
        {
         ObjectDelete(0, name);
        }
     }
  }
//+------------------------------------------------------------------+
void DrawMacdResonance(PointData &pd[], int size, color pcolor, color ncolor)
  {
   string indName = "MACD(48,104,36)";
   int window = ChartWindowFind(0, indName);
   int handle = ChartIndicatorGet(0, window, indName);
   for(int i = 0; i < ArraySize(pd); i++)
     {
      if((pd[i].States & StateValues::MacdResonance()) == false)
         continue;
      int index = iBarShift(_Symbol, _Period, pd[i].Time);
      double m[];
      CopyBuffer(handle, 0, index, 1,  m);
      double macd = m[0];
      color clr = pd[i].Macd > 0 ? pcolor : ncolor;
      pd[i].Color = (int)clr;
      AddShape(window,
               PointDataName(pd[i]),
               macd * pd[i].Macd > 0 ? macd : 0,
               pd[i].Time,
               (uchar)159,
               clr,
               size,
               pd[i].Macd > 0 ? ANCHOR_BOTTOM : ANCHOR_TOP);
     }
  }
//+------------------------------------------------------------------+
void  DrawButtons()
  {
   color clr = C'73, 78, 101';
   string actions[] = {"F", "U", "X", "SO", "LT"};
   string timeframes[] = {"D1", "H4", "M30", "M5", "M1"};
   int w = 30;
   int h = 30;
   int x = 10, y = 10;
   for(int a = 0; a < ArraySize(actions); a++)
     {
      y += (h + 2);
      DrawButton(actions[a], actions[a], x, y, w, h, clr);
      for(int t = 0, x = 10; t < ArraySize(timeframes); t++)
        {
         x += w + 2;
         DrawButton(actions[a] + timeframes[t], timeframes[t], x, y, w, h, clr);
        }
     }
   x = 10;
   y += (h + 2);
   int ww = 3 * w + 2 * 2;
   DrawButton("Clear", "Clear", x, y, ww, h, clr);
   x += ww + 2;
   DrawButton("Remove", "Remove", x, y, ww, h, clr);
  }
//+------------------------------------------------------------------+
int OnInit()
  {
   ClearObjects();
   ClearIcons();
   if(!InitializeYatugar())
      return(INIT_FAILED);
//else
//   Print("Connected");
   Chart chart;
   chart.Market = Vorn::Markets::GetIndex(_Symbol);
   int keyD1 = -1, keyH4 = -1, keyM30 = -1, keyM5 = -1, keyM1 = -1;
   chart.TimeFrame = PERIOD_D1;
   if(D1)
      keyD1 = SendChartData(chart, 0, Candles);
   chart.TimeFrame = PERIOD_H4;
   if(H4)
      keyH4 = SendChartData(chart, 0, Candles);
   chart.TimeFrame = PERIOD_M30;
   if(M30)
      keyM30 = SendChartData(chart, 0, Candles);
   chart.TimeFrame = PERIOD_M5;
   if(M5)
      keyM5 = SendChartData(chart, 0, Candles);
   chart.TimeFrame = PERIOD_M1;
   if(M1)
      keyM1 = SendChartData(chart, 0, Candles);
   if(D1)
      ReadPointData(keyD1, pointDataD1);
   if(H4)
      ReadPointData(keyH4, pointDataH4);
   if(M30)
      ReadPointData(keyM30, pointDataM30);
   if(M5)
      ReadPointData(keyM5, pointDataM5);
   if(M1)
      ReadPointData(keyM1, pointDataM1);
   DrawButtons();
   if(D1)
      if(Master)
         DrawMasters(pointDataD1, D1Size, D1Offset, D1Positive, D1Negative);
   if(D1)
      if(Switch)
         DrawSwitch(pointDataD1, D1Size, D1Offset, D1Positive, D1Negative);
   if(D1)
      DrawMacdResonance(pointDataD1, D1Size, D1Positive, D1Negative);
   if(D1)
      DrawExtremeArea(pointDataD1, D1Size, D1Offset, D1Warning);
   if(H4)
      if(Master)
         DrawMasters(pointDataH4, H4Size, H4Offset, H4Positive, H4Negative);
   if(H4)
      if(Switch)
         DrawSwitch(pointDataH4, H4Size, H4Offset, H4Positive, H4Negative);
   if(H4)
      if(ExtremeAreas)
         DrawExtremeArea(pointDataH4, H4Size, H4Offset, H4Warning);
   if(H4)
      if(Fundamental)
         DrawFundamental(pointDataH4, H4Size, H4Offset, H4Positive, H4Negative, H4Warning);
   if(H4)
      if(Signals)
         DrawSignal(pointDataH4, H4Size, H4Offset, H4Positive, H4Negative);
   if(H4)
      DrawMacdResonance(pointDataH4, H4Size, H4Positive, H4Negative);
   if(H4)
      DrawMaExtreme(pointDataH4, H4Size, H4Offset, H4Warning);
   if(M30)
      if(Master)
         DrawMasters(pointDataM30, M30Size, M30Offset, M30Positive, M30Negative);
   if(M30)
      if(Switch)
         DrawSwitch(pointDataM30, M30Size, M30Offset, M30Positive, M30Negative);
   if(M30)
      if(ExtremeAreas)
         DrawExtremeArea(pointDataM30, M30Size, M30Offset, M30Warning);
   if(M30)
      if(Signals)
         DrawSignal(pointDataM30, M30Size, M30Offset, M30Positive, M30Negative);
   if(M30)
      DrawMacdResonance(pointDataM30,  M30Size, M30Positive, M30Negative);
   if(M5)
      if(Master)
         DrawMasters(pointDataM5, M5Size, M5Offset, M5Positive, M5Negative);
   if(M5)
      if(Switch)
         DrawSwitch(pointDataM5, M5Size, M5Offset, M5Positive, M5Negative);
   if(M5)
      if(ExtremeAreas)
         DrawExtremeArea(pointDataM5, M5Size, M5Offset, M5Warning);
   if(M5)
      if(Signals)
         DrawSignal(pointDataM5, M5Size, M5Offset, M5Positive, M5Negative);
   if(M5)
      DrawMacdResonance(pointDataM5, M5Size, M5Positive, M5Negative);
   if(M1)
      if(Master)
         DrawMasters(pointDataM1, M1Size, M1Offset, M1Positive, M1Negative);
   if(M1)
      if(Switch)
         DrawSwitch(pointDataM1, M1Size, M1Offset, M1Positive, M1Negative);
   if(M1)
      if(ExtremeAreas)
         DrawExtremeArea(pointDataM1, M1Size, M1Offset, M1Warning);
   if(M1)
      if(Signals)
         DrawSignal(pointDataM1, M1Size, M1Offset, M1Positive, M1Negative);
//DrawLevelCrossing(pointDataH4, H4Size, H4Warning);
//Print("Recognition Complete");
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   DeinitializeYatugar();
  }
//+------------------------------------------------------------------+
string PointDataName(PointData &pd)
  {
   string name = StringFormat("+%I64uS%dT%d", pd.States, pd.Id, pd.TimeFrame);
   return name;
  }
//+------------------------------------------------------------------+
void DrawPoint(PointData &pd[], DrawPointConfig &config)
  {
   for(int i = 0; i < ArraySize(pd); i++)
     {
      if((pd[i].States & config.WantedStates) == false)
         continue;
      if((pd[i].States & config.UnwantedStates) == true)
         continue;
      double high = iHigh(_Symbol, _Period, iBarShift(_Symbol, _Period, pd[i].Time));
      double low = iLow(_Symbol, _Period, iBarShift(_Symbol, _Period, pd[i].Time));
      double hl = high - low;
      pd[i].Color = (int) config.Color;
      AddShape(0,
               PointDataName(pd[i]),
               config.Position == PRICE_HIGH ? high + 100 * SymbolInfoDouble(_Symbol, SYMBOL_POINT) * config.Offset : low - hl * config.Offset,
               pd[i].Time,
               config.Code,
               config.Color,
               config.Size,
               config.Position == PRICE_HIGH ? ANCHOR_BOTTOM : ANCHOR_TOP);
     }
  }
//+------------------------------------------------------------------+
bool FindPointData(PointData & pds[], PointData & pd, int id = NULL, ulong state = NULL, int startIndex = 0)
  {
   for(int i = startIndex; i < ArraySize(pds); i++)
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
void OnChartEvent(const int id,
                  const long & lparam, const double & dparam, const string & sparam)
  {
   ENUM_CHART_EVENT evt = (ENUM_CHART_EVENT)id;
   if(evt != CHARTEVENT_OBJECT_CLICK)
      return;
   string name = sparam;
   if(StringSubstr(name, 0, 1) == "-")
      return;
   PointData pd;
   if(name == "F")
     {
      ToggleLastMaster(pointDataD1);
      ToggleLastMaster(pointDataH4);
      ToggleLastMaster(pointDataM30);
      ToggleLastMaster(pointDataM5);
      ToggleLastMaster(pointDataM1);
      return;
     }
   if(name == "FD1")
     {
      ToggleLastMaster(pointDataD1);
      return;
     }
   if(name == "FH4")
     {
      ToggleLastMaster(pointDataH4);
      return;
     }
   if(name == "FM30")
     {
      ToggleLastMaster(pointDataM30);
      return;
     }
   if(name == "FM5")
     {
      ToggleLastMaster(pointDataM5);
      return;
     }
   if(name == "FM1")
     {
      ToggleLastMaster(pointDataM1);
      return;
     }
   if(name == "U")
     {
      for(int i = 0; i < ArraySize(pointDataD1); i++)
        {
         ToggleUnbalancing(pointDataD1[i]);
        }
      for(int i = 0; i < ArraySize(pointDataH4); i++)
        {
         ToggleUnbalancing(pointDataH4[i]);
        }
      for(int i = 0; i < ArraySize(pointDataM30); i++)
        {
         ToggleUnbalancing(pointDataM30[i]);
        }
      for(int i = 0; i < ArraySize(pointDataM5); i++)
        {
         ToggleUnbalancing(pointDataM5[i]);
        }
      for(int i = 0; i < ArraySize(pointDataM1); i++)
        {
         ToggleUnbalancing(pointDataM1[i]);
        }
      return;
     }
   if(name == "UD1")
     {
      for(int i = 0; i < ArraySize(pointDataD1); i++)
        {
         ToggleUnbalancing(pointDataD1[i]);
        }
      return;
     }
   if(name == "UH4")
     {
      for(int i = 0; i < ArraySize(pointDataH4); i++)
        {
         ToggleUnbalancing(pointDataH4[i]);
        }
      return;
     }
   if(name == "UM30")
     {
      for(int i = 0; i < ArraySize(pointDataM30); i++)
        {
         ToggleUnbalancing(pointDataM30[i]);
        }
      return;
     }
   if(name == "UM5")
     {
      for(int i = 0; i < ArraySize(pointDataM5); i++)
        {
         ToggleUnbalancing(pointDataM5[i]);
        }
      return;
     }
   if(name == "UM1")
     {
      for(int i = 0; i < ArraySize(pointDataM1); i++)
        {
         ToggleUnbalancing(pointDataM1[i]);
        }
      return;
     }
   if(name == "X")
     {
      for(int i = 0; i < ArraySize(pointDataD1); i++)
        {
         ToggleArea(pointDataD1[i]);
        }
      for(int i = 0; i < ArraySize(pointDataH4); i++)
        {
         ToggleArea(pointDataH4[i]);
        }
      for(int i = 0; i < ArraySize(pointDataM30); i++)
        {
         ToggleArea(pointDataM30[i]);
        }
      for(int i = 0; i < ArraySize(pointDataM5); i++)
        {
         ToggleArea(pointDataM5[i]);
        }
      for(int i = 0; i < ArraySize(pointDataM1); i++)
        {
         ToggleArea(pointDataM1[i]);
        }
      return;
     }
   if(name == "XD1")
     {
      for(int i = 0; i < ArraySize(pointDataD1); i++)
        {
         ToggleArea(pointDataD1[i]);
        }
      return;
     }
   if(name == "XH4")
     {
      for(int i = 0; i < ArraySize(pointDataH4); i++)
        {
         ToggleArea(pointDataH4[i]);
        }
      return;
     }
   if(name == "XM30")
     {
      for(int i = 0; i < ArraySize(pointDataM30); i++)
        {
         ToggleArea(pointDataM30[i]);
        }
      return;
     }
   if(name == "XM5")
     {
      for(int i = 0; i < ArraySize(pointDataM5); i++)
        {
         ToggleArea(pointDataM5[i]);
        }
      return;
     }
   if(name == "XM1")
     {
      for(int i = 0; i < ArraySize(pointDataM1); i++)
        {
         ToggleArea(pointDataM1[i]);
        }
      return;
     }
   if(name == "SOD1")
     {
      ToggleMacdSignChange(pointDataD1, D1Positive, D1Negative);
      return;
     }
   if(name == "SOH4")
     {
      ToggleMacdSignChange(pointDataH4, H4Positive, H4Negative);
      return;
     }
   if(name == "SOM30")
     {
      ToggleMacdSignChange(pointDataM30, M30Positive, M30Negative);
      return;
     }
   if(name == "SOM5")
     {
      ToggleMacdSignChange(pointDataM5, M5Positive, M5Negative);
      return;
     }
   if(name == "SOM1")
     {
      ToggleMacdSignChange(pointDataM1, M1Positive, M1Negative);
      return;
     }
   if(name == "LT")
     {
      ToggleLeftTarget(pointDataD1, D1Positive, D1Negative);
      ToggleLeftTarget(pointDataH4, H4Positive, H4Negative);
      ToggleLeftTarget(pointDataM30, M30Positive, M30Negative);
      ToggleLeftTarget(pointDataM5, M5Positive, M5Negative);
      ToggleLeftTarget(pointDataM1, M1Positive, M1Negative);
      return;
     }
   if(name == "LTD1")
     {
      ToggleLeftTarget(pointDataD1, D1Positive, D1Negative);
      return;
     }
   if(name == "LTH4")
     {
      ToggleLeftTarget(pointDataH4, H4Positive, H4Negative);
      return;
     }
   if(name == "LTM30")
     {
      ToggleLeftTarget(pointDataM30, M30Positive, M30Negative);
      return;
     }
   if(name == "LTM5")
     {
      ToggleLeftTarget(pointDataM5, M5Positive, M5Negative);
      return;
     }
   if(name == "LTM1")
     {
      ToggleLeftTarget(pointDataM1, M1Positive, M1Negative);
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
      int i = (int)StringToInteger(StringSubstr(name, s + 1, t));
      int timeframe = (int)StringToInteger(StringSubstr(name, t + 1));
      switch((ENUM_TIMEFRAMES)timeframe)
        {
         case  PERIOD_D1:
            FindPointData(pointDataD1, pd, i);
            break;
         case  PERIOD_H4:
            FindPointData(pointDataH4, pd, i);
            break;
         case  PERIOD_M30:
            FindPointData(pointDataM30, pd, i);
            break;
         case  PERIOD_M5:
            FindPointData(pointDataM5, pd, i);
            break;
         case  PERIOD_M1:
            FindPointData(pointDataM1, pd, i);
            break;
         default:
            break;
        }
      ToggleFiboUnba(pd);
      if((state & StateValues::EquilibriumExtreme()) > 0)
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
   string name = PointDataName(pd);
   if(!(pd.Unbalancing > 0))
      return false;
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
   if(!(pd.AreaHigh > 0))
      return false;
   string areaHighName = "-Eh" + name;
   string areaLowName = "-El" + name;
   string areaVerticalName = "-Ev" + name;
   if(ObjectFind(0, areaHighName) < 0)
     {
      DrawTrendline(areaVerticalName,
                    pd.AreaHighTime,
                    pd.AreaHigh,
                    pd.AreaLowTime,
                    pd.AreaLow,
                    (color)pd.Color,
                    0);
      DrawHorizontalLine(areaHighName, pd.AreaHigh, pd.Color, 0, STYLE_SOLID);
      DrawHorizontalLine(areaLowName, pd.AreaLow, pd.Color, 0, STYLE_SOLID);
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
void ToggleLastMaster(PointData & pd[])
  {
   PointData pd1;
   if(FindPointData(pd, pd1, NULL, StateValues::Master()))
     {
      if(ToggleFibo(pd1))
        {
         ToggleUnbalancing(pd1);
        }
      else
        {
         PointData pd2;
         if(FindPointData(pd, pd2, NULL, StateValues::Master(), pd1.Id + 1))
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
   string actions[] = {"F", "U", "X", "SO", "LT"};
   string timeframes[] = {"D1", "H4", "M30", "M5", "M1"};
   for(int a = 0; a < ArraySize(actions); a++)
     {
      ObjectDelete(0, actions[a]);
      for(int t = 0, x = 10; t < ArraySize(timeframes); t++)
        {
         ObjectDelete(0, actions[a] + timeframes[t]);
        }
     }
   ObjectDelete(0, "Clear");
   ObjectDelete(0, "Remove");
  }
//+------------------------------------------------------------------+
