//+------------------------------------------------------------------+
//|                                                             Vorn |
//|                                                  https://vorn.ir |
//+------------------------------------------------------------------+
#property library
#property copyright "Vorn"
#property link      "https://vorn.ir"
#property version   "1.00"
//+------------------------------------------------------------------+
#import "Vorn.Yatugar.Separ.Common.dll"
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
string actions[] = {"F", "U", "X", "T", "M", "O"};
//+------------------------------------------------------------------+
string PointDataName(PointData &pd) export
  {
   string name = StringFormat("+%I64uS%dT%d", pd.States, pd.Id, pd.TimeFrame);
   return name;
  }
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
void DrawPointData(PointData & pd, Settings & settings, color pcolor, color ncolor, color wcolor, int size, int offset)
  {
   pd.Size = size;
   pd.Offset = offset;
   if((pd.States & StateValues::PositiveMaster()) > 0)
     {
      pd.Color = pcolor;
      pd.Icon = (pd.States & StateValues::StraightMaster()) > 0 ? 118 : 116;
      pd.Anchor = ANCHOR_TOP;
      if(settings.Master)
         DrawPointData(pd, pd.F0);
     }
   if((pd.States & StateValues::NegativeMaster()) > 0)
     {
      pd.Color = ncolor;
      pd.Icon = (pd.States & StateValues::StraightMaster()) > 0 ? 118 : 116;
      pd.Anchor = ANCHOR_BOTTOM;
      if(settings.Master)
         DrawPointData(pd, pd.F0);
     }
   if((pd.States & StateValues::PositiveBaseSwitch()) > 0)
     {
      pd.Color = pcolor;
      pd.Icon = 161;
      pd.Anchor = ANCHOR_TOP;
      if(settings.Switch)
         DrawPointData(pd, pd.Low);
     }
   if((pd.States & StateValues::NegativeBaseSwitch()) > 0)
     {
      pd.Color = ncolor;
      pd.Icon = 161;
      pd.Anchor = ANCHOR_BOTTOM;
      if(settings.Switch)
         DrawPointData(pd, pd.High);
     }
   if((pd.States & StateValues::SignalA1()) > 0)
     {
      pd.Color = pcolor;
      DrawText(PointDataName(pd) + "L", "A1", pd.Time, pd.Low - 4 * (pd.High - pd.Low), 7 + size, pd.Color);
     }
   if((pd.States & StateValues::SignalA2()) > 0)
     {
      pd.Color = ncolor;
      DrawText(PointDataName(pd) + "L", "A2", pd.Time, pd.High + 4 * (pd.High - pd.Low),  7 + size, pd.Color);
     }
   if((pd.States & StateValues::SignalBb1()) > 0)
     {
      pd.Color = pcolor;
      DrawText(PointDataName(pd) + "LBb1", "Bb1", pd.Time, pd.Low - 5 * (pd.High - pd.Low), 7 + size, pd.Color);
     }
   if((pd.States & StateValues::SignalBb2()) > 0)
     {
      pd.Color = ncolor;
      DrawText(PointDataName(pd) + "LBb2", "Bb2", pd.Time, pd.High + 5 * (pd.High - pd.Low),  7 + size, pd.Color);
     }
   if((pd.States & StateValues::SignalB1()) > 0)
     {
      pd.Color = pcolor;
      DrawText(PointDataName(pd) + "LB1", "B1", pd.Time, pd.Low - 5 * (pd.High - pd.Low), 7 + size, pd.Color);
     }
   if((pd.States & StateValues::SignalB2()) > 0)
     {
      pd.Color = ncolor;
      DrawText(PointDataName(pd) + "LB2", "B2", pd.Time, pd.High + 5 * (pd.High - pd.Low),  7 + size, pd.Color);
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
      DrawText(PointDataName(pd) + "LT1", "T1", pd.Time, labelPrice, 7 + size, pd.Color);
     }
   if((pd.States & StateValues::SignalT2()) > 0)
     {
      pd.Color = wcolor;
      double labelPrice = pd.High + 4 * (pd.High - pd.Low);
      DrawText(PointDataName(pd) + "LT2", "T2", pd.Time, labelPrice, 7 + size, pd.Color);
     }
   if((pd.States & StateValues::SignalU1()) > 0)
     {
      pd.Color = wcolor;
      double labelPrice = pd.Low - 4 * (pd.High - pd.Low);
      DrawText(PointDataName(pd) + "LU1", "U1", pd.Time, labelPrice, 7 + size, pd.Color);
     }
   if((pd.States & StateValues::SignalU2()) > 0)
     {
      pd.Color = wcolor;
      double labelPrice = pd.High + 4 * (pd.High - pd.Low);
      DrawText(PointDataName(pd) + "LU2", "U2", pd.Time, labelPrice, 7 + size, pd.Color);
     }
   if((pd.States & StateValues::NegativeMacdDivergence()) > 0)
     {
      pd.Color = pcolor;
     }
   if((pd.States & StateValues::PositiveMacdDivergence()) > 0)
     {
      pd.Color = ncolor;
     }
   if((pd.States & StateValues::Buy()) > 0)
     {
      pd.Color = pcolor;
     }
   if((pd.States & StateValues::Sell()) > 0)
     {
      pd.Color = ncolor;
     }
   if((pd.States & StateValues::PositiveSar()) > 0)
     {
      pd.Color = pcolor;
      pd.Icon = 159;
      pd.Size = pd.Size - 1;
      pd.Anchor = ANCHOR_TOP;
      DrawPointData(pd, pd.Value);
     }
   if((pd.States & StateValues::NegativeSar()) > 0)
     {
      pd.Color = ncolor;
      pd.Icon = 159;
      pd.Size = pd.Size - 1;
      pd.Anchor = ANCHOR_BOTTOM;
      DrawPointData(pd, pd.Value);
     }
   if((pd.States & StateValues::EquilibriumExtreme()) > 0)
     {
      pd.Offset = 0;
      pd.Color = wcolor;
      pd.Icon = 159;
      pd.Anchor = ANCHOR_TOP;
      if(settings.ExtremeAreas)
         DrawPointData(pd, pd.AreaStart);
     }
   if((pd.States & StateValues::MaResonance()) > 0)
     {
      pd.Offset = 0;
      pd.Size = pd.Size - 1;
      pd.Icon = 159;
      int handle = iMA(_Symbol, _Period, 70, 0, MODE_LWMA, PRICE_CLOSE);
      int index = iBarShift(_Symbol, _Period, pd.Time);
      double m[];
      CopyBuffer(handle, 0, index, 1,  m);
      double ma = m[0];
      if(pd.Macd > 0)
        {
         pd.Color = pcolor;
         pd.Anchor = ANCHOR_TOP;
        }
      if(pd.Macd < 0)
        {
         pd.Color = ncolor;
         pd.Anchor = ANCHOR_BOTTOM;
        }
      pd.States = StateValues::MaResonance();
      DrawPointData(pd, ma);
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
      pd.States = StateValues::MacdResonance();
      DrawPointData(pd,  macd * pd.Macd > 0 ? macd : 0);
     }
  }
//+------------------------------------------------------------------+
void  DrawButtons(int & timeframes[])
  {
   ClearButtons();
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
         DrawButton(actions[a] + (string)timeframes[t], GetTimeFrameName(timeframes[t]), x, y, w, h, clr);
        }
     }
   x = 10;
   y += (h + g);
   DrawButton("Clear", "Clear", x, y, ww, h, clr);
   ChartRedraw();
  }
//+------------------------------------------------------------------+
string GetTimeFrameName(int timeframe)
  {
   switch(timeframe)
     {
      case(int)PERIOD_M1:
         return "M1";
      case(int)PERIOD_M5:
         return "M5";
      case(int)PERIOD_M30:
         return "M30";
      case(int)PERIOD_H4:
         return "H4";
      case(int)PERIOD_D1:
         return "D1";
      case(int)PERIOD_W1:
         return "W1";
      case(int)PERIOD_MN1:
         return "MN1";
      default:
         return "";
     }
  }
void CopyArray(PointData &dest[], const PointData &src[]) { ArrayResize(dest, ArraySize(src)); for(int i = 0; i < ArraySize(src); i++) { dest[i] = src[i]; } }
//+------------------------------------------------------------------+
void DrawRecognition(PointData & pointData[], Settings & settings, int & timeframes[]) export
  {
   for(int p = 0; p < ArraySize(pointData); p++)
     {
      if(pointData[p].TimeFrame == PERIOD_MN1)
        {
         DrawPointData(pointData[p], settings, settings.MN1Positive, settings.MN1Negative, settings.MN1Warning, settings.MN1Size, settings.MN1Offset);
        }
      if(pointData[p].TimeFrame == PERIOD_W1)
        {
         DrawPointData(pointData[p], settings, settings.W1Positive, settings.W1Negative, settings.W1Warning, settings.W1Size, settings.W1Offset);
        }
      if(pointData[p].TimeFrame == PERIOD_D1)
        {
         DrawPointData(pointData[p], settings, settings.D1Positive, settings.D1Negative, settings.D1Warning, settings.D1Size, settings.D1Offset);
        }
      if(pointData[p].TimeFrame == PERIOD_H4)
        {
         DrawPointData(pointData[p], settings, settings.H4Positive, settings.H4Negative, settings.H4Warning, settings.H4Size, settings.H4Offset);
        }
      if(pointData[p].TimeFrame == PERIOD_M30)
        {
         DrawPointData(pointData[p], settings, settings.M30Positive, settings.M30Negative, settings.M30Warning, settings.M30Size, settings.M30Offset);
        }
      if(pointData[p].TimeFrame == PERIOD_M5)
        {
         DrawPointData(pointData[p], settings, settings.M5Positive, settings.M5Negative, settings.M5Warning, settings.M5Size, settings.M5Offset);
        }
      if(pointData[p].TimeFrame == PERIOD_M1)
        {
         DrawPointData(pointData[p], settings, settings.M1Positive, settings.M1Negative, settings.M1Warning, settings.M1Size, settings.M1Offset);
        }
     }
   DrawButtons(timeframes);
   ChartRedraw();
  }
//+------------------------------------------------------------------+
void ChartEvent(PointData & pointData[], int & timeframes[], const int id,
                const long & lparam, const double & dparam, const string & sparam) export
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
         if((pointData[i].States & StateValues::MacdDivergence()) > 0)
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
                  if((pointData[i].States & StateValues::MacdDivergence()) > 0)
                     ToggleVerticalLine(pointData[i]);
              }
         return;
        }
   if(name == "O")
     {
      for(int i = 0; i < ArraySize(pointData); i++)
        {
         if((pointData[i].States & StateValues::Trade()) > 0)
            ToggleVerticalLine(pointData[i]);
        }
      return;
     }
   else
      if(StringSubstr(name, 0, 1) == "O")
        {
         int tf = (int)StringSubstr(name, 1);
         if(name == "O" + (string)tf)
            for(int i = 0; i < ArraySize(pointData); i++)
              {
               if(pointData[i].TimeFrame == tf)
                  if((pointData[i].States & StateValues::Trade()) > 0)
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
void ClearObjects() export
  {
   ObjectsDeleteAll(0, "-");
   ChartRedraw();
  }
//+------------------------------------------------------------------+
void ClearIcons() export
  {
   ObjectsDeleteAll(0, "+");
   ChartRedraw();
  }
//+------------------------------------------------------------------+
void ClearButtons() export
  {
   for(int a = 0; a < ArraySize(actions); a++)
     {
      ObjectsDeleteAll(0, actions[a], 0);
     }
   ObjectDelete(0, "Clear");
   ObjectDelete(0, "Remove");
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
