//+------------------------------------------------------------------+
//|                               Vorn.Yatugar.MarketRecognition.mq5 |
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
void MarketRecognition(Chart &chart, datetime from, datetime to, PointData &md30[], PointData &md4[]);
void ChartRecognition(Chart &chart, datetime from, datetime to, PointData &md[]);
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
#import
//+------------------------------------------------------------------+
input group           "Date"
sinput datetime From = D'2024.03.01';
sinput datetime To = D'2024.10.01';
input group           "Colors"
sinput color D1Positive = C'22,66,60';
sinput color H4Positive = C'36,89,83';
sinput color M30Positive = C'64,142,145';
sinput color D1Negative = C'128, 0, 0';
sinput color H4Negative = C'219,22,47';
sinput color M30Negative = C'199, 91, 122';
sinput color H4Warning = C'235, 91, 0';
sinput color M30Warning = C'255, 178, 0';
sinput color H4Fundamental = C'244, 206, 20';
input group           "D1 "
sinput bool D1 = true; // D1 Enabled
sinput bool D1Master = true; // D1 Master Fibonacci Retracement
sinput bool D1Switch = true; // D1 Switch Fibonacci Retracement
input group           "H4 "
sinput bool H4 = true; // H4 Enabled
sinput bool H4Master = true; // H4 Master Fibonacci Retracement
sinput bool H4Switch = true; // H4 Switch Fibonacci Retracement
sinput bool H4ExtremeAreas = true; //H4 Extreme Areas
sinput bool H4FundamentalMaster = true; //H4 Fundamental Trends
sinput bool H4Signals = true; //H4 Signals
input group           "M30"
sinput bool M30 = true; // M30 Enabled
sinput bool M30Master = true; // M30 Master Fibonacci Retracement
sinput bool M30Switch = false; // M30 Switch Fibonacci Retracement
sinput bool M30ExtremeAreas = true; //M30 Extreme Areas
sinput bool M30Signals = true; //M30 Signals
//+------------------------------------------------------------------+
PointData pointData30[];
PointData pointData4[];
PointData pointData1[];
//+------------------------------------------------------------------+
struct DrawPointConfig
  {
   ulong             WantedStates[];
   ulong             UnwantedStates[];
   color             Color;
   uchar             Code;
   int               Size;
   ENUM_APPLIED_PRICE PricePosition;
  };
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
      ChartRecognition(chart, From, To, pointData1);
     }
   if(H4)
     {
      chart.TimeFrame = PERIOD_H4;
      ChartRecognition(chart, From, To, pointData4);
     }
   if(M30)
     {
      chart.TimeFrame = PERIOD_M30;
      ChartRecognition(chart, From, To, pointData30);
     }
   if(D1)
      if(D1Master)
        {
         DrawPointConfig conf;
         ArrayResize(conf.WantedStates, 1);
         conf.WantedStates[0] = StateValues::PositiveMaster();
         ArrayResize(conf.UnwantedStates, 1);
         conf.UnwantedStates[0] = StateValues::ReversedMaster();
         conf.Color = D1Positive;
         conf.Code = 116;
         conf.Size = 7;
         conf.PricePosition = PRICE_LOW;
         DrawPoint(pointData1, conf);
         conf.WantedStates[0] = StateValues::NegativeMaster();
         conf.Color = D1Negative;
         conf.PricePosition = PRICE_HIGH;
         DrawPoint(pointData1, conf);
        }
   if(D1)
      if(D1Switch)
        {
         DrawPointConfig conf;
         ArrayResize(conf.WantedStates, 1);
         conf.WantedStates[0] = StateValues::PositiveMainSwitch();
         ArrayResize(conf.UnwantedStates, 0);
         conf.Color = D1Positive;
         conf.Code = 111;
         conf.Size = 7;
         conf.PricePosition = PRICE_LOW;
         DrawPoint(pointData1, conf);
         conf.WantedStates[0] = StateValues::NegativeMainSwitch();
         conf.Color = D1Negative;
         conf.PricePosition = PRICE_HIGH;
         DrawPoint(pointData1, conf);
        }
   if(D1)
      if(D1Switch)
        {
         DrawPointConfig conf;
         ArrayResize(conf.WantedStates, 1);
         conf.WantedStates[0] = StateValues::PositiveBaseSwitch();
         ArrayResize(conf.UnwantedStates, 1);
         conf.UnwantedStates[0] = StateValues::PositiveMainSwitch();
         conf.Color = D1Positive;
         conf.Code = 161;
         conf.Size = 5;
         conf.PricePosition = PRICE_LOW;
         DrawPoint(pointData1, conf);
         ArrayResize(conf.WantedStates, 1);
         conf.WantedStates[0] = StateValues::NegativeBaseSwitch();
         ArrayResize(conf.UnwantedStates, 1);
         conf.UnwantedStates[0] = StateValues::NegativeMainSwitch();
         conf.Color = D1Negative;
         conf.PricePosition = PRICE_HIGH;
         DrawPoint(pointData1, conf);
        }
   if(H4)
      if(H4Master)
        {
         DrawPointConfig conf;
         ArrayResize(conf.WantedStates, 1);
         conf.WantedStates[0] = StateValues::PositiveMaster();
         ArrayResize(conf.UnwantedStates, 1);
         conf.UnwantedStates[0] = StateValues::ReversedMaster();
         conf.Color = H4Positive;
         conf.Code = 116;
         conf.Size = 4;
         conf.PricePosition = PRICE_LOW;
         DrawPoint(pointData4, conf);
         conf.WantedStates[0] = StateValues::NegativeMaster();
         conf.Color = H4Negative;
         conf.PricePosition = PRICE_HIGH;
         DrawPoint(pointData4, conf);
        }
   if(H4)
      if(H4Switch)
        {
         DrawPointConfig conf;
         ArrayResize(conf.WantedStates, 1);
         conf.WantedStates[0] = StateValues::PositiveMainSwitch();
         ArrayResize(conf.UnwantedStates, 0);
         conf.Color = H4Positive;
         conf.Code = 111;
         conf.Size = 4;
         conf.PricePosition = PRICE_LOW;
         DrawPoint(pointData4, conf);
         conf.WantedStates[0] = StateValues::NegativeMainSwitch();
         conf.Color = H4Negative;
         conf.PricePosition = PRICE_HIGH;
         DrawPoint(pointData4, conf);
        }
   if(H4)
      if(H4Switch)
        {
         DrawPointConfig conf;
         ArrayResize(conf.WantedStates, 1);
         conf.WantedStates[0] = StateValues::PositiveBaseSwitch();
         ArrayResize(conf.UnwantedStates, 1);
         conf.UnwantedStates[0] = StateValues::PositiveMainSwitch();
         conf.Color = H4Positive;
         conf.Code = 161;
         conf.Size = 2;
         conf.PricePosition = PRICE_LOW;
         DrawPoint(pointData4, conf);
         ArrayResize(conf.WantedStates, 1);
         conf.WantedStates[0] = StateValues::NegativeBaseSwitch();
         ArrayResize(conf.UnwantedStates, 1);
         conf.UnwantedStates[0] = StateValues::NegativeMainSwitch();
         conf.Color = H4Negative;
         conf.PricePosition = PRICE_HIGH;
         DrawPoint(pointData4, conf);
        }
   if(H4)
      if(H4ExtremeAreas)
        {
         DrawPointConfig conf;
         ArrayResize(conf.WantedStates, 1);
         conf.WantedStates[0] = StateValues::EquilibriumExtreme();
         ArrayResize(conf.UnwantedStates, 0);
         conf.Color = H4Warning;
         conf.Code = 110;
         conf.Size = 3;
         conf.PricePosition = PRICE_LOW;
         DrawPoint(pointData4, conf);
        }
   if(H4)
      if(H4FundamentalMaster)
        {
         DrawPointConfig conf;
         ArrayResize(conf.WantedStates, 1);
         conf.WantedStates[0] = StateValues::Fundamental();
         ArrayResize(conf.UnwantedStates, 0);
         conf.Color = H4Fundamental;
         conf.Code = 181;
         conf.Size = 4;
         conf.PricePosition = PRICE_LOW;
         DrawPoint(pointData4, conf);
        }
   if(H4)
      if(H4Signals)
        {
         DrawPointConfig conf;
         ArrayResize(conf.WantedStates, 1);
         conf.WantedStates[0] = StateValues::SignalA1();
         ArrayResize(conf.UnwantedStates, 0);
         conf.Color = H4Positive;
         conf.Code = 140;
         conf.Size = 4;
         conf.PricePosition = PRICE_LOW;
         DrawPoint(pointData4, conf);
         conf.WantedStates[0] = StateValues::SignalB1();
         conf.Code = 142;
         DrawPoint(pointData4, conf);
         conf.WantedStates[0] = StateValues::SignalA2();
         conf.Color = H4Negative;
         conf.PricePosition = PRICE_HIGH;
         conf.Code = 141;
         DrawPoint(pointData4, conf);
         conf.WantedStates[0] = StateValues::SignalB2();
         conf.Code = 143;
         DrawPoint(pointData4, conf);
        }
   if(M30)
      if(M30Master)
        {
         DrawPointConfig conf;
         ArrayResize(conf.WantedStates, 1);
         conf.WantedStates[0] = StateValues::PositiveMaster();
         ArrayResize(conf.UnwantedStates, 1);
         conf.UnwantedStates[0] = StateValues::ReversedMaster();
         conf.Color = M30Positive;
         conf.Code = 116;
         conf.Size = 2;
         conf.PricePosition = PRICE_LOW;
         DrawPoint(pointData30, conf);
         conf.WantedStates[0] = StateValues::NegativeMaster();
         conf.Color = M30Negative;
         conf.PricePosition = PRICE_HIGH;
         DrawPoint(pointData30, conf);
        }
   if(M30)
      if(M30Switch)
        {
         DrawPointConfig conf;
         ArrayResize(conf.WantedStates, 1);
         conf.WantedStates[0] = StateValues::PositiveMainSwitch();
         ArrayResize(conf.UnwantedStates, 0);
         conf.Color = M30Positive;
         conf.Code = 161;
         conf.Size = 1;
         conf.PricePosition = PRICE_LOW;
         DrawPoint(pointData30, conf);
         conf.WantedStates[0] = StateValues::NegativeMainSwitch();
         conf.Color = M30Negative;
         conf.PricePosition = PRICE_HIGH;
         DrawPoint(pointData30, conf);
        }
   if(M30)
      if(M30ExtremeAreas)
        {
         DrawPointConfig conf;
         ArrayResize(conf.WantedStates, 1);
         conf.WantedStates[0] = StateValues::EquilibriumExtreme();
         ArrayResize(conf.UnwantedStates, 0);
         conf.Color = M30Warning;
         conf.Code = 110;
         conf.Size = 1;
         conf.PricePosition = PRICE_LOW;
         DrawPoint(pointData30, conf);
        }
   if(M30)
      if(M30Signals)
        {
         DrawPointConfig conf;
         ArrayResize(conf.WantedStates, 1);
         conf.WantedStates[0] = StateValues::SignalA1();
         ArrayResize(conf.UnwantedStates, 0);
         conf.Color = M30Positive;
         conf.Code = 140;
         conf.Size = 2;
         conf.PricePosition = PRICE_LOW;
         DrawPoint(pointData30, conf);
         conf.WantedStates[0] = StateValues::SignalB1();
         conf.Code = 142;
         DrawPoint(pointData30, conf);
         conf.WantedStates[0] = StateValues::SignalA2();
         conf.Color = M30Negative;
         conf.PricePosition = PRICE_HIGH;
         conf.Code = 141;
         DrawPoint(pointData30, conf);
         conf.WantedStates[0] = StateValues::SignalB2();
         conf.Code = 143;
         DrawPoint(pointData30, conf);
        }
   Print("Recognition Complete");
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
string PointDataName(PointData &pd, color clr)
  {
   return StringFormat("%uS%dT%dC%s", pd.States, pd.Id, pd.TimeFrame, ColorToString(clr));
  }
//+------------------------------------------------------------------+
void DrawPoint(PointData &pd[], DrawPointConfig &config)
  {
   for(int i = 0; i < ArraySize(pd); i++)
     {
      bool next = false;
      for(int c = 0; c < ArraySize(config.WantedStates); c++)
         if((pd[i].States & config.WantedStates[c]) == false)
            next = true;
      for(int c = 0; c < ArraySize(config.UnwantedStates); c++)
         if((pd[i].States & config.UnwantedStates[c]) == true)
            next = true;
      if(next)
         continue;
      AddShape(0,
               PointDataName(pd[i], config.Color),
               config.PricePosition == PRICE_HIGH ? iHigh(_Symbol, _Period, iBarShift(_Symbol, _Period, pd[i].Time)) : iLow(_Symbol, _Period, iBarShift(_Symbol, _Period, pd[i].Time)),
               pd[i].Time,
               config.Code,
               config.Color,
               config.Size,
               config.PricePosition == PRICE_HIGH ? ANCHOR_BOTTOM : ANCHOR_TOP);
     }
  }
//+------------------------------------------------------------------+
void ToggleArea(PointData & pd, string name, color clr)
  {
   if(!(pd.AreaHigh > 0))
      return;
   string areaHighName = "-Eh" + name;
   string areaLowName = "-El" + name;
   if(ObjectFind(0, areaHighName) < 0)
     {
      ChangeShape(name, 120);
      DrawHorizontalLine(areaHighName, pd.AreaHigh, clr, 0, STYLE_SOLID);
      DrawHorizontalLine(areaLowName, pd.AreaLow, clr, 0, STYLE_SOLID);
     }
   else
     {
      ChangeShape(name, 110);
      ObjectDelete(0, areaHighName);
      ObjectDelete(0, areaLowName);
     }
  }
//+------------------------------------------------------------------+
void FindPointData(PointData & pds[], PointData & pd, int id)
  {
   for(int i = 0; i < ArraySize(pds); i++)
     {
      if(pds[i].Id == id)
        {
         pd = pds[i];
         return;
        }
     }
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
   int s = StringFind(name, "S");
   ulong state = (ulong)StringToInteger(StringSubstr(name, 0, s));
   int i = (int)StringToInteger(StringSubstr(name, s + 1));
   int t = StringFind(name, "T");
   int timeframe = (int)StringToInteger(StringSubstr(name, t + 1));
   int c = StringFind(name, "C");
   color clr = StringToColor(StringSubstr(name, c + 1));
   PointData pd;
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
      default:
         break;
     }
   ToggleFiboUnba(pd, name, clr);
   ToggleArea(pd, name, clr);
   ChartRedraw(0);
  }
//+------------------------------------------------------------------+
void ToggleFiboUnba(PointData & pd, string name, color clr)
  {
   string fiboName = "-Fibo" + name;
   string fiboUnbalacingName = "-Ub" + name;
   string vertical = "-V" + fiboUnbalacingName;
   string horizontal = "-H" + fiboUnbalacingName;
   bool drawFibo = false;
   bool drawUnba = false;
   if(ObjectFind(0, fiboName) < 0)
     {
      if(pd.Unbalancing > 0)
        {
         if(ObjectFind(0, vertical) < 0)
           {
            drawFibo = true;
            drawUnba = true;
           }
         else
           {
            ObjectDelete(0, vertical);
            ObjectDelete(0, horizontal);
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
         clr,
         0,
         true);
     }
   if(drawUnba)
     {
      DrawTrendline(vertical,
                    pd.Time,
                    pd.F0,
                    pd.Time,
                    pd.Unbalancing,
                    clr,
                    0);
      DrawTrendline(horizontal,
                    pd.Time,
                    pd.Unbalancing,
                    TimeCurrent(),
                    pd.Unbalancing,
                    clr,
                    0,
                    true,
                    false,
                    STYLE_SOLID);
     }
  }
//+------------------------------------------------------------------+
