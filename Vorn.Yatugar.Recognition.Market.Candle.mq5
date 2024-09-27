//+------------------------------------------------------------------+
//|                                                             Vorn |
//|                                                  https://vorn.ir |
//+------------------------------------------------------------------+
#property copyright "Vorn"
#property link      "https://vorn.ir"
#property version   "1.00"
//+------------------------------------------------------------------+
#import "Vorn.Yatugar.Client.dll"
#import
//+------------------------------------------------------------------+
#import "Vorn.Yatugar.ex5"
void InitializeYatugar();
void ChartRecognition(Chart &chart, int start, int count, PointData &md[]);
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
sinput int Candles = 1500;
input group           "Colors"
sinput color D1Positive = C'54, 69, 79';
sinput color H4Positive = C'10, 117, 143';
sinput color M30Positive = C'0,255,240';
sinput color D1Negative = C'128, 0, 0';
sinput color H4Negative = C'219,22,47';
sinput color M30Negative = C'199, 91, 122';
sinput color D1Warning = C'235, 91, 0';
sinput color H4Warning = C'235, 91, 0';
sinput color M30Warning = C'255, 178, 0';
sinput color H4Fundamental = C'244, 206, 20';
sinput color M5Positive = clrGreenYellow;
sinput color M5Negative = clrCrimson;
sinput color M5Warning = clrGold;
input group           "D1 "
sinput bool D1 = true; // D1 Enabled
sinput bool D1Master = true; // D1 Master Fibonacci Retracement
sinput bool D1Switch = true; // D1 Switch Fibonacci Retracement
sinput int D1Size = 10; // D1 Icon Size
input group           "H4 "
sinput bool H4 = true; // H4 Enabled
sinput bool H4Master = true; // H4 Master Fibonacci Retracement
sinput bool H4Switch = true; // H4 Switch Fibonacci Retracement
sinput bool H4ExtremeAreas = true; //H4 Extreme Areas
sinput bool H4FundamentalMaster = true; //H4 Fundamental Trends
sinput bool H4Signals = true; //H4 Signals
sinput int H4Size = 7; // H4 Icon Size
input group           "M30"
sinput bool M30 = true; // M30 Enabled
sinput bool M30Master = true; // M30 Master Fibonacci Retracement
sinput bool M30Switch = true; // M30 Switch Fibonacci Retracement
sinput bool M30ExtremeAreas = true; //M30 Extreme Areas
sinput bool M30Signals = true; //M30 Signals
sinput int M30Size = 3; // M30 Icon Size
input group           "M5"
sinput bool M5 = true; // M5 Enabled
sinput bool M5Master = true; // M5 Master Fibonacci Retracement
sinput bool M5Switch = true; // M5 Switch Fibonacci Retracement
sinput bool M5ExtremeAreas = true; //M5 Extreme Areas
sinput bool M5Signals = true; //M5 Signals
sinput int M5Size = 1; // M5 Icon Size
//+------------------------------------------------------------------+
PointData pointData30[];
PointData pointData4[];
PointData pointData1[];
PointData pointData5[];
//+------------------------------------------------------------------+
struct DrawPointConfig
  {
   ulong             WantedStates;
   ulong             UnwantedStates;
   color             Color;
   uchar             Code;
   int               Size;
   ENUM_APPLIED_PRICE Position;
   int               Window;
  };
//+------------------------------------------------------------------+
void DrawMasters(PointData &pd[], int size, color pcolor, color ncolor)
  {
   DrawPointConfig conf;
   conf.WantedStates = StateValues::PositiveMaster();
   conf.UnwantedStates = 0;
   conf.Color = pcolor;
   conf.Code = 116;
   conf.Size = size;
   conf.Position = PRICE_LOW;
   DrawPoint(pd, conf);
   conf.WantedStates = StateValues::NegativeMaster();
   conf.Color = ncolor;
   conf.Position = PRICE_HIGH;
   DrawPoint(pd, conf);
  }
//+------------------------------------------------------------------+
void DrawSwitch(PointData &pd[], int size, color pcolor, color ncolor)
  {
   DrawPointConfig conf;
   conf.WantedStates = StateValues::PositiveBaseSwitch();
   conf.UnwantedStates = 0;
   conf.Color = pcolor;
   conf.Code = 111;
   conf.Size = size;
   conf.Position = PRICE_LOW;
   DrawPoint(pd, conf);
   conf.WantedStates = StateValues::NegativeBaseSwitch();
   conf.Color = ncolor;
   conf.Position = PRICE_HIGH;
   DrawPoint(pd, conf);
  }
//+------------------------------------------------------------------+
void DrawExtremeArea(PointData &pd[], int size, color wcolor)
  {
   DrawPointConfig conf;
   conf.WantedStates = StateValues::EquilibriumExtreme();
   conf.UnwantedStates = 0;
   conf.Color = wcolor;
   conf.Code = 110;
   conf.Size = size;
   conf.Position = PRICE_LOW;
   DrawPoint(pd, conf);
  }
//+------------------------------------------------------------------+
void DrawFundamental(PointData &pd[], int size, color wcolor)
  {
   DrawPointConfig conf;
   conf.WantedStates = StateValues::Fundamental();
   conf.UnwantedStates = 0;
   conf.Color = wcolor;
   conf.Code = 181;
   conf.Size = size;
   conf.Position = PRICE_LOW;
   DrawPoint(pd, conf);
  }
//+------------------------------------------------------------------+
void DrawSignal(PointData &pd[], int size, color pcolor, color ncolor)
  {
   DrawPointConfig conf;
   conf.WantedStates = StateValues::SignalA1();
   conf.UnwantedStates = 0;
   conf.Color = pcolor;
   conf.Code = 140;
   conf.Size = size;
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
   string actions[] = {"F", "U", "X"};
   string timeframes[] = {"D1", "H4", "M30",  "M5"};
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
   DrawButton("AllOff", "Clear All", x, y, 5 * w + 8, h, clr);
  }
//+------------------------------------------------------------------+
int OnInit()
  {
   ClearChart();
   InitializeYatugar();
   Print("Connected");
   Chart chart;
   chart.Market = Vorn::Markets::GetIndex(_Symbol);
   if(D1)
     {
      chart.TimeFrame = PERIOD_D1;
      ChartRecognition(chart, 0, Candles, pointData1);
     }
   if(H4)
     {
      chart.TimeFrame = PERIOD_H4;
      ChartRecognition(chart, 0, Candles, pointData4);
     }
   if(M30)
     {
      chart.TimeFrame = PERIOD_M30;
      ChartRecognition(chart, 0, Candles, pointData30);
     }
   if(M5)
     {
      chart.TimeFrame = PERIOD_M5;
      ChartRecognition(chart, 0, Candles, pointData5);
     }
   DrawButtons();
   if(D1)
      if(D1Master)
         DrawMasters(pointData1, D1Size, D1Positive, D1Negative);
   if(D1)
      if(D1Switch)
         DrawSwitch(pointData1, D1Size, D1Positive, D1Negative);
   if(D1)
      DrawMacdResonance(pointData1, D1Size, D1Positive, D1Negative);
   if(D1)
      DrawExtremeArea(pointData1, D1Size, D1Warning);
   if(H4)
      if(H4Master)
         DrawMasters(pointData4, H4Size, H4Positive, H4Negative);
   if(H4)
      if(H4Switch)
         DrawSwitch(pointData4, H4Size, H4Positive, H4Negative);
   if(H4)
      if(H4ExtremeAreas)
         DrawExtremeArea(pointData4, H4Size, H4Warning);
   if(H4)
      if(H4FundamentalMaster)
         DrawFundamental(pointData4, H4Size, H4Warning);
   if(H4)
      if(H4Signals)
         DrawSignal(pointData4, H4Size, H4Positive, H4Negative);
   if(H4)
      DrawMacdResonance(pointData4, H4Size, H4Positive, H4Negative);
   if(M30)
      if(M30Master)
         DrawMasters(pointData30, M30Size, M30Positive, M30Negative);
   if(M30)
      if(M30Switch)
         DrawSwitch(pointData30, M30Size, M30Positive, M30Negative);
   if(M30)
      if(M30ExtremeAreas)
         DrawExtremeArea(pointData30, M30Size, M30Warning);
   if(M30)
      if(M30Signals)
         DrawSignal(pointData30, M30Size, M30Positive, M30Negative);
   if(M30)
      DrawMacdResonance(pointData30,  M30Size, M30Positive, M30Negative);
   if(M5)
      if(M5Master)
         DrawMasters(pointData5, M5Size, M5Positive, M5Negative);
   if(M5)
      if(M5Switch)
         DrawSwitch(pointData5, M5Size, M5Positive, M5Negative);
   if(M5)
      if(M5ExtremeAreas)
         DrawExtremeArea(pointData5, M5Size, M5Warning);
   if(M5)
      if(M5Signals)
         DrawSignal(pointData5, M5Size, M5Positive, M5Negative);
   if(M5)
      DrawMacdResonance(pointData5, M5Size, M5Positive, M5Negative);
   Print("Recognition Complete");
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
string PointDataName(PointData &pd)
  {
   string name = StringFormat("%dT%d", pd.Id, pd.TimeFrame);
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
               config.Position == PRICE_HIGH ? high + hl * (config.Size / 4) : low - hl * (config.Size / 4),
               pd[i].Time,
               config.Code,
               config.Color,
               config.Size,
               config.Position == PRICE_HIGH ? ANCHOR_BOTTOM : ANCHOR_TOP);
     }
  }
//+------------------------------------------------------------------+
bool FindPointData(PointData & pds[], PointData & pd, int id = NULL, ulong state = NULL)
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
      if(FindPointData(pointData1, pd, NULL, StateValues::Master()))
         ToggleFiboUnba(pd);
      if(FindPointData(pointData4, pd, NULL, StateValues::Master()))
         ToggleFiboUnba(pd);
      if(FindPointData(pointData30, pd, NULL, StateValues::Master()))
         ToggleFiboUnba(pd);
      if(FindPointData(pointData5, pd, NULL, StateValues::Master()))
         ToggleFiboUnba(pd);
      return;
     }
   if(name == "FD1")
     {
      if(FindPointData(pointData1, pd, NULL, StateValues::Master()))
         ToggleFiboUnba(pd);
      return;
     }
   if(name == "FH4")
     {
      if(FindPointData(pointData4, pd, NULL, StateValues::Master()))
         ToggleFiboUnba(pd);
      return;
     }
   if(name == "FM30")
     {
      if(FindPointData(pointData30, pd, NULL, StateValues::Master()))
         ToggleFiboUnba(pd);
      return;
     }
   if(name == "FM5")
     {
      if(FindPointData(pointData5, pd, NULL, StateValues::Master()))
         ToggleFiboUnba(pd);
      return;
     }
   if(name == "U")
     {
      for(int i = 0; i < ArraySize(pointData1); i++)
        {
         ToggleUnbalancings(pointData1[i]);
        }
      for(int i = 0; i < ArraySize(pointData4); i++)
        {
         ToggleUnbalancings(pointData4[i]);
        }
      for(int i = 0; i < ArraySize(pointData30); i++)
        {
         ToggleUnbalancings(pointData30[i]);
        }
      for(int i = 0; i < ArraySize(pointData5); i++)
        {
         ToggleUnbalancings(pointData5[i]);
        }
      return;
     }
   if(name == "UD1")
     {
      for(int i = 0; i < ArraySize(pointData1); i++)
        {
         ToggleUnbalancings(pointData1[i]);
        }
      return;
     }
   if(name == "UH4")
     {
      for(int i = 0; i < ArraySize(pointData4); i++)
        {
         ToggleUnbalancings(pointData4[i]);
        }
      return;
     }
   if(name == "UM30")
     {
      for(int i = 0; i < ArraySize(pointData30); i++)
        {
         ToggleUnbalancings(pointData30[i]);
        }
      return;
     }
   if(name == "UM5")
     {
      for(int i = 0; i < ArraySize(pointData5); i++)
        {
         ToggleUnbalancings(pointData5[i]);
        }
      return;
     }
   if(name == "X")
     {
      for(int i = 0; i < ArraySize(pointData1); i++)
        {
         ToggleArea(pointData1[i]);
        }
      for(int i = 0; i < ArraySize(pointData4); i++)
        {
         ToggleArea(pointData4[i]);
        }
      for(int i = 0; i < ArraySize(pointData30); i++)
        {
         ToggleArea(pointData30[i]);
        }
      for(int i = 0; i < ArraySize(pointData5); i++)
        {
         ToggleArea(pointData5[i]);
        }
      return;
     }
   if(name == "XD1")
     {
      for(int i = 0; i < ArraySize(pointData1); i++)
        {
         ToggleArea(pointData1[i]);
        }
      return;
     }
   if(name == "XH4")
     {
      for(int i = 0; i < ArraySize(pointData4); i++)
        {
         ToggleArea(pointData4[i]);
        }
      return;
     }
   if(name == "XM30")
     {
      for(int i = 0; i < ArraySize(pointData30); i++)
        {
         ToggleArea(pointData30[i]);
        }
      return;
     }
   if(name == "XM5")
     {
      for(int i = 0; i < ArraySize(pointData5); i++)
        {
         ToggleArea(pointData5[i]);
        }
      return;
     }
   if(name == "AllOff")
     {
      ToggleAllOff();
      return;
     }
   int t = StringFind(name, "T");
   if(t > 0)
     {
      int i = (int)StringToInteger(StringSubstr(name, 0, t));
      int timeframe = (int)StringToInteger(StringSubstr(name, t + 1));
      switch((ENUM_TIMEFRAMES)timeframe)
        {
         case  PERIOD_D1:
            FindPointData(pointData1, pd, i);
            break;
         case  PERIOD_H4:
            FindPointData(pointData4, pd, i);
            break;
         case  PERIOD_M30:
            FindPointData(pointData30, pd, i);
            break;
         case  PERIOD_M5:
            FindPointData(pointData5, pd, i);
            break;
         default:
            break;
        }
      ToggleFiboUnba(pd);
      ToggleArea(pd);
      ChartRedraw(0);
      return;
     }
  }
//+------------------------------------------------------------------+
bool ToggleFiboUnba(PointData & pd)
  {
   string name = PointDataName(pd);
   string fiboName = "-Fibo" + name;
   bool drawFibo = false;
   if(ObjectFind(0, fiboName) < 0)
     {
      if(pd.Unbalancing > 0)
        {
         if(ToggleUnbalancings(pd))
           {
            drawFibo = true;
           }
        }
      else
        {
         drawFibo = true;
        }
     }
   else
     {
      ObjectDelete(0, fiboName);
     }
   if(drawFibo)
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
     }
   return drawFibo;
  }
//+------------------------------------------------------------------+
bool ToggleUnbalancings(PointData & pd)
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
      return true;
     }
   else
     {
      ObjectDelete(0, vertical);
      ObjectDelete(0, horizontal);
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
   if(ObjectFind(0, areaHighName) < 0)
     {
      ChangeShape(name, 120);
      DrawHorizontalLine(areaHighName, pd.AreaHigh, pd.Color, 0, STYLE_SOLID);
      DrawHorizontalLine(areaLowName, pd.AreaLow, pd.Color, 0, STYLE_SOLID);
      return true;
     }
   else
     {
      ChangeShape(name, 110);
      ObjectDelete(0, areaHighName);
      ObjectDelete(0, areaLowName);
      return false;
     }
  }
//+------------------------------------------------------------------+
void ToggleAllOff()
  {
   ObjectsDeleteAll(0, "-");
  }
//+------------------------------------------------------------------+
