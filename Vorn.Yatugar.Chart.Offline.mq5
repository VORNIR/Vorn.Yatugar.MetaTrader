//+------------------------------------------------------------------+
//|                                                             Vorn |
//|                                                  https://vorn.ir |
//+------------------------------------------------------------------+
#property copyright "Vorn"
#property link      "https://vorn.ir"
#property version   "1.00"
//+------------------------------------------------------------------+
#import "Vorn.Yatugar.Separ.Common.dll"
#import
//+------------------------------------------------------------------+
#import "Vorn.Yatugar.Offline.ex5"
bool InitializeYatugar();
void DoMarketRecognition(string sym, int & timeframes[], datetime from, int count, PointData &md[]);
string PointDataName(PointData &pd);
bool FindPointData(PointData & pds[], PointData & pd, int timeframe, int id = NULL, ulong state = NULL, int startIndex = 0);
bool DeinitializeYatugar();
#import
//+------------------------------------------------------------------+
#import "Vorn.Yatugar.Recognition.ex5"
void DrawRecognition(PointData & pd[], Settings & st, int & tf[]);
void ClearObjects();
void ClearIcons();
void ClearButtons();
void ChartEvent(PointData & pointData[], int & timeframes[], const int id, const long & lparam, const double & dparam, const string & sparam);
#import
//+------------------------------------------------------------------+
sinput int Candles = 1000;
sinput datetime From = NULL;
input group           "Colors"
sinput color MN1Positive = C'14, 29, 39';
sinput color W1Positive = C'34, 49, 59';
sinput color D1Positive = C'54, 69, 79';
sinput color H4Positive = C'10, 117, 143';
sinput color M30Positive = C'0,255,240';
sinput color M5Positive = clrGreenYellow;
sinput color M1Positive = C'162,240,162';
sinput color MN1Negative = C'70, 0, 0';
sinput color W1Negative = C'90, 0, 0';
sinput color D1Negative = C'128, 0, 0';
sinput color H4Negative = C'219,22,47';
sinput color M30Negative = C'199, 91, 122';
sinput color M5Negative = clrMediumVioletRed;
sinput color M1Negative = C'255,166,215';
sinput color MN1Warning = C'109,5,5';
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
input group           "MN1 "
sinput bool MN1 = false; // MN1 Enabled
sinput int MN1Size = 7; // MN1 Icon Size
sinput int MN1Offset = 7; // MN1 Icon Size
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
sinput bool M5 = true; // M5 Enabled
sinput int M5Size = 2; // M5 Icon Size
sinput int M5Offset = 2; // M5 Icon Size
input group           "M1"
sinput bool M1 = true; // M1 Enabled
sinput int M1Size = 1; // M1 Icon Size
sinput int M1Offset = 1; // M1 Icon Size
//+------------------------------------------------------------------+
void FillSettings(Settings &settings)
  {
   settings.MN1Positive = MN1Positive;
   settings.W1Positive = W1Positive;
   settings.D1Positive = D1Positive;
   settings.H4Positive = H4Positive;
   settings.M30Positive = M30Positive;
   settings.M5Positive = M5Positive;
   settings.M1Positive = M1Positive;
   settings.MN1Negative = MN1Negative;
   settings.W1Negative = W1Negative;
   settings.D1Negative = D1Negative;
   settings.H4Negative = H4Negative;
   settings.M30Negative = M30Negative;
   settings.M5Negative = M5Negative;
   settings.M1Negative = M1Negative;
   settings.MN1Warning = MN1Warning;
   settings.W1Warning = W1Warning;
   settings.D1Warning = D1Warning;
   settings.H4Warning = H4Warning;
   settings.M30Warning = M30Warning;
   settings.M5Warning = M5Warning;
   settings.M1Warning = M1Warning;
   settings.H4Fundamental = H4Fundamental;
   settings.Master = Master;
   settings.Switch = Switch;
   settings.ExtremeAreas = ExtremeAreas;
   settings.Fundamental = Fundamental;
   settings.Signals = Signals;
   settings.MN1 = MN1;
   settings.MN1Size = MN1Size;
   settings.MN1Offset = MN1Offset;
   settings.W1 = W1;
   settings.W1Size = W1Size;
   settings.W1Offset = W1Offset;
   settings.D1 = D1;
   settings.D1Size = D1Size;
   settings.D1Offset = D1Offset;
   settings.H4 = H4;
   settings.H4Size = H4Size;
   settings.H4Offset = H4Offset;
   settings.M30 = M30;
   settings.M30Size = M30Size;
   settings.M30Offset = M30Offset;
   settings.M5 = M5;
   settings.M5Size = M5Size;
   settings.M5Offset = M5Offset;
   settings.M1 = M1;
   settings.M1Size = M1Size;
   settings.M1Offset = M1Offset;
  }
//+------------------------------------------------------------------+
Settings st;
PointData pointData[];
int timeframes[];
void AddTimeFrame(ENUM_TIMEFRAMES tf)
  {
   int tfa[] = {tf};
   ArrayInsert(timeframes, tfa, ArraySize(timeframes));
  }
//+------------------------------------------------------------------+
int OnInit()
  {
   FillSettings(st);
   ClearObjects();
   ClearIcons();
   ArrayFree(timeframes);
   ArrayFree(pointData);
   if(!InitializeYatugar())
     {
      DeinitializeYatugar();
      return(INIT_FAILED);
     }
   int count = Candles + 300;
   if(MN1)
      if(_Period <= PERIOD_MN1)
        {
         count = Bars(_Symbol, PERIOD_MN1);
         AddTimeFrame(PERIOD_MN1);
        }
   if(W1)
      if(_Period <= PERIOD_W1)
        {
         if(!MN1)
            count = Bars(_Symbol, PERIOD_W1);
         AddTimeFrame(PERIOD_W1);
        }
   if(D1)
      if(_Period <= PERIOD_D1)
         AddTimeFrame(PERIOD_D1);
   if(H4)
      if(_Period <= PERIOD_H4)
         AddTimeFrame(PERIOD_H4);
   if(M30)
      if(_Period <= PERIOD_M30)
         AddTimeFrame(PERIOD_M30);
   if(M5)
      if(_Period <= PERIOD_M5)
         AddTimeFrame(PERIOD_M5);
   if(M1)
      if(_Period <= PERIOD_M1)
         AddTimeFrame(PERIOD_M1);
   bool result = false;
   if(From == NULL)
      DoMarketRecognition(_Symbol, timeframes, TimeCurrent(), count, pointData);
   else
      DoMarketRecognition(_Symbol, timeframes, From, count, pointData);
   if(ArraySize(pointData) == 0)
      ExpertRemove();
   DrawRecognition(pointData, st, timeframes);
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ClearButtons();
   DeinitializeYatugar();
  }
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long& lparam, const double& dparam, const string& sparam)
  {
   ChartEvent(pointData, timeframes, id, lparam, dparam, sparam);
  }
//+------------------------------------------------------------------+
