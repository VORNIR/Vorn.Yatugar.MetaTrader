//+------------------------------------------------------------------+
//|                                             ChartRecognition.mq5 |
//|                                                             Vorn |
//|                                                  https://vorn.ir |
//+------------------------------------------------------------------+
#property copyright "Vorn"
#property link      "https://vorn.ir"
#property version   "1.00"
//+------------------------------------------------------------------+
#import "Vorn.Yatugar.Client.dll"
//+------------------------------------------------------------------+
#import "Vorn.Yatugar.ex5"
void ChartRecognition(Chart &chart, int start, int count, MasterData &md[], StateData &sd[], SwitchData &sw[], ExtremeAreaData &ex[]);
#import
//+------------------------------------------------------------------+
#import "Vorn.Graphics.ex5"
void DrawVerticalLine(string name, datetime time, color clr = clrAqua, long width = 0, bool ray = false,  ENUM_LINE_STYLE style = STYLE_DOT);
void DrawHorizontalLine(string name, double p, color clr = clrAqua, long width = 0, ENUM_LINE_STYLE style = STYLE_DOT);
void DrawFibonacci(string name, datetime d1, double p1, datetime d2, double p2,  color clr, long width = 0, bool rayRight = false,  ENUM_LINE_STYLE style = STYLE_DOT);
void AddShape(int window, string name, double level, datetime time, uchar code, color clr,  int size = 1, ENUM_ANCHOR_POINT anchor = ANCHOR_CENTER);
void ChangeShape(string name, uchar code);
void DrawRectangle(const string name, datetime time1, double price1, datetime time2, double price2, const color clr = clrAqua, const int width = 0, const bool fill = false, const bool back = false, const ENUM_LINE_STYLE style = STYLE_SOLID, const long z_order = 1);
void ClearChart();
#import
//+------------------------------------------------------------------+
sinput int Candles = 1000;
input group           "Colors"
sinput color PositiveMaster = clrGreenYellow;
sinput color NegativeMaster = clrCrimson;
sinput color PositiveSwitch = C'134, 187, 216';
sinput color NegativeSwitch = C'218, 102, 123';
sinput color PositiveFundamental = C'114, 169, 143';
sinput color NegativeFundamental = C'170, 68, 101';
sinput color ExtremeArea = clrTeal;
//+------------------------------------------------------------------+
SwitchData switchData[];
MasterData masterData[];
ExtremeAreaData exData[];
Chart chart;
//+------------------------------------------------------------------+
int OnInit()
  {
   //ClearChart();;
   SetMarkets();
   Vorn::Commands::StartConnection();
   Print("Connected");
   chart.Market = GetMarketIndex(_Symbol);
   chart.TimeFrame = (int)_Period;
   StateData sd[];
   ChartRecognition(chart, 0, Candles, masterData, sd, switchData, exData);
   DrawMasters(chart, masterData);
   DrawSwitches(chart, switchData);
   DrawStates(chart, sd);
   DrawExtremes(chart, exData);
   Print("Recognition Complete");
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
void DrawMasters(Chart &chart, MasterData &md[])
  {
   if(ArraySize(md) > 0)
      for(int i = 0; i < ArraySize(md); i++)
         AddShape(0, StringFormat("Md%d", i),
                  md[i].F0,
                  md[i].Time + 1,
                  md[i].State & StateValues::Master() ? (md[i].F100 > md[i].F0 ? 246 : 248) : 178,
                  md[i].State & StateValues::Master() ? (md[i].F100 > md[i].F0 ? PositiveMaster : NegativeMaster) : (md[i].F100 > md[i].F0 ? PositiveFundamental : NegativeFundamental),
                  4);
  }
//+------------------------------------------------------------------+
void DrawSwitches(Chart &chart, SwitchData &sw[])
  {
   if(ArraySize(sw) > 0)
      for(int i = 0; i < ArraySize(sw); i++)
         AddShape(0, StringFormat("Sw%d", i),
                  sw[i].F100,
                  sw[i].Time,
                  111,
                  sw[i].F100 > sw[i].F0 ? PositiveSwitch : NegativeSwitch,
                  sw[i].State & StateValues::MainSwitch() ? 4 : 1);
  }
//+------------------------------------------------------------------+
void DrawStates(Chart &chart, StateData &sd[])
  {
   for(int i = 0; i < ArraySize(sd); i++)
     {
      if(sd[i].State & StateValues::Resonance())
         MacdGraphics(chart, sd[i].Index);
      //DrawVerticalLine(StringFormat("V%d", i), sd[i].Time, 0, clrAqua);
     }
  }
//+------------------------------------------------------------------+
void DrawExtremes(Chart &chart, ExtremeAreaData &ex[])
  {
   if(ArraySize(ex) > 0)
      for(int i = 0; i < ArraySize(ex); i++)
         DrawRectangle(StringFormat("Ex%d", i),  ex[i].HighTime, ex[i].High,  ex[i].LowTime, ex[i].Low, ExtremeArea);
  }
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam, const double &dparam, const string &sparam)
  {
   ENUM_CHART_EVENT evt = (ENUM_CHART_EVENT)id;
   if(evt != CHARTEVENT_OBJECT_CLICK)
      return;
   string name = sparam;
   string type = StringSubstr(name, 0, 2);
   long i = StringToInteger(StringSubstr(name, 2));
   if(type == "Md")
     {
      string fiboName = "FiboMd" + i;
      string fiboUnbalacingName = "FiboUbMd" + i;
      color clr =  masterData[i].State & StateValues::Master() ? (masterData[i].F100 > masterData[i].F0 ? PositiveMaster : NegativeMaster) : (masterData[i].F100 > masterData[i].F0 ? PositiveFundamental : NegativeFundamental);
      if(ObjectFind(0, fiboName) >= 0)
        {
         ChangeShape(name, masterData[i].State & StateValues::Master() ? (masterData[i].F100 > masterData[i].F0 ? 246 : 248) : 178);
         ObjectDelete(0, fiboName);
         ObjectDelete(0, fiboUnbalacingName);
        }
      else
        {
         ChangeShape(name, masterData[i].State & StateValues::Master() ? (masterData[i].F100 > masterData[i].F0 ? 236 : 238) : 170);
         DrawFibonacci(
            fiboName,
            masterData[i].Time,
            masterData[i].F100,
            TimeCurrent(),
            masterData[i].F0,
            clr,
            0,
            true);
         if(masterData[i].Unbalancing > 0)
            DrawHorizontalLine(fiboUnbalacingName, masterData[i].Unbalancing, clr, 1, STYLE_SOLID);
        }
     }
   if(type == "Sw")
     {
      string fiboName = "FiboSw" + i;
      if(ObjectFind(0, fiboName) >= 0)
        {
         ChangeShape(name, 111);
         ObjectDelete(0, fiboName);
        }
      else
        {
         ChangeShape(name, 110);
         DrawFibonacci(
            fiboName,
            switchData[i].Time,
            switchData[i].F100,
            TimeCurrent(),
            switchData[i].F0,
            switchData[i].F100 > switchData[i].F0 ? PositiveSwitch : NegativeSwitch,
            0,
            true);
        }
     }
   if(type == "Ex")
     {
      string rayHighName = "Eh" + i;
      string rayLowName = "El" + i;
      if(ObjectFind(0, rayHighName) < 0)
        {
         DrawHorizontalLine(rayHighName, exData[i].High, ExtremeArea, 0, STYLE_SOLID);
         DrawHorizontalLine(rayLowName, exData[i].Low, ExtremeArea, 0, STYLE_SOLID);
        }
      else
        {
         ObjectDelete(0, rayHighName);
         ObjectDelete(0, rayLowName);
        }
     }
   ChartRedraw(0);
  }
//+------------------------------------------------------------------+
string markets[];
void SetMarkets()
  {
   string list = "";
   for(int i = 0; i < SymbolsTotal(true); i++)
     {
      string symbol[] = {SymbolName(i, true)};
      ArrayInsert(markets, symbol, ArraySize(markets));
     }
  }
//+------------------------------------------------------------------+
int GetMarketIndex(string sym)
  {
   for(int i = 0; i < ArraySize(markets); i++)
     {
      if(markets[i] == sym)
         return i;
     }
   return -1;
  }
//+------------------------------------------------------------------+
void MacdGraphics(Chart &chart, int shift = 0)
  {
   int fast_ema_period = 48, slow_ema_period = 104,  signal_period = 36;
   int h = iMACD(SymbolName(chart.Market, true), (ENUM_TIMEFRAMES)chart.TimeFrame, fast_ema_period, slow_ema_period, signal_period, PRICE_CLOSE);
   double m[];
   CopyBuffer(h, 1, shift, 1, m);
   double M0 = m[0];
   datetime t = iTime(SymbolName(chart.Market, true), (ENUM_TIMEFRAMES)chart.TimeFrame, shift);
   int window = ChartWindowFind(0, "MACD(" + fast_ema_period + "," + slow_ema_period + "," + signal_period + ")");
   string name = "MacdAnomaly" + shift;
   if(M0 > 0)
      AddShape(window, name, M0, t, 217, clrAqua);
   else
      AddShape(window, name, M0 * 1.3, t, 218, clrRed, 1, ANCHOR_LOWER);
   ChartRedraw(0);
  }
//+------------------------------------------------------------------+
