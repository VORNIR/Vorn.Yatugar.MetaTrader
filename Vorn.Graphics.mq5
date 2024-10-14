//+------------------------------------------------------------------+
//|                                                     Graphics.mq5 |
//|                                                             Vorn |
//|                                                  https://vorn.ir |
//+------------------------------------------------------------------+
#property library
#property copyright "Vorn"
#property link      "https://vorn.ir"
#property version   "1.00"
//+------------------------------------------------------------------+
void DrawVerticalLine(string name, datetime time, color clr = clrAqua, long width = 0, bool ray = false, ENUM_LINE_STYLE style = STYLE_DOT) export
  {
   if(ObjectFind(0, name) < 0)
     {
      ObjectCreate(0, name, OBJ_VLINE, 0, time, 0);
      ObjectSetInteger(0, name, OBJPROP_STYLE, style);
     }
   ObjectSetInteger(0, name, OBJPROP_WIDTH, width);
   ObjectSetInteger(0, name, OBJPROP_RAY, ray);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_TIME, time);
   ChartRedraw(0);
  }
//+------------------------------------------------------------------+
void DrawHorizontalLine(string name, double p, color clr = clrAqua, long width = 0, ENUM_LINE_STYLE style = STYLE_DOT) export
  {
   if(ObjectFind(0, name) < 0)
     {
      ObjectCreate(0, name, OBJ_HLINE, 0, 0, p);
      ObjectSetInteger(0, name, OBJPROP_STYLE, style);
     }
   ObjectSetInteger(0, name, OBJPROP_WIDTH, width);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_TIME, 0);
   ObjectSetDouble(0, name, OBJPROP_PRICE, p);
   ChartRedraw(0);
  }
//+------------------------------------------------------------------+
void DrawFibonacci(string name, datetime d1, double p1, datetime d2, double p2,  color &colors[], double &values[], string &labels[], long width = 0, bool rayRight = false,  ENUM_LINE_STYLE style = STYLE_SOLID) export
  {
   if(ObjectFind(0, name) < 0)
     {
      ObjectDelete(0, name);
     }
   ObjectCreate(0, name, OBJ_FIBO, 0, d1, p1, d2, p2);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_DOT);
   ObjectSetInteger(0, name, OBJPROP_WIDTH, 1);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clrNONE);
   ObjectSetInteger(0, name, OBJPROP_RAY_RIGHT, rayRight);
   ObjectSetInteger(0, name, OBJPROP_LEVELS, ArraySize(values));
   for(int i = 0; i < ArraySize(values); i++)
     {
      ObjectSetDouble(0, name, OBJPROP_LEVELVALUE, i, values[i]);
      ObjectSetInteger(0, name, OBJPROP_LEVELCOLOR, i, colors[i]);
      ObjectSetInteger(0, name, OBJPROP_LEVELSTYLE, i, style);
      ObjectSetInteger(0, name, OBJPROP_LEVELWIDTH, i, 0);
      ObjectSetString(0, name, OBJPROP_LEVELTEXT, i, labels[i]);
     }
   ChartRedraw(0);
  }
//+------------------------------------------------------------------+
void DrawFibonacci(string name, datetime d1, double p1, datetime d2, double p2,  color clr, long width = 0, bool rayRight = false,  ENUM_LINE_STYLE style = STYLE_DOT) export
  {
   double values[] = {0, .618, 1, 1.61,  2.23, 2.38, 2, 2.61, 3.62, 3.86, 4, 4.23, 5.85, 6.25, 6, 6.81, 9.48, 10.11, 10, 11.07, 15.33, 16.36, 17, 17.92, 27, 29, 45, 47, 76.2, 123.6};
   string labels[] = {"0", "61", "100", "161",  "38", "23", "200", "261", "38", "23", "400", "423", "38", "23", "600", "681", "38", "23", "1000", "1107", "38", "23", "1700", "1792", "2700", "2900", "4500", "4700", "7620", "12360"};
   color colors[] = {   clr,  clr,  clr,  clr,   clrRosyBrown, clrRosyBrown, clr,  clr, clrRosyBrown, clrRosyBrown, clr,  clr, clrRosyBrown, clrRosyBrown, clr,  clr, clrRosyBrown, clrRosyBrown, clr,  clr, clrRosyBrown, clrRosyBrown, clr,  clr, clr,  clr, clr,  clr, clr,  clr, clr};
   DrawFibonacci(name, d1, p1, d2, p2, colors, values, labels, width, rayRight, style);
  }
//+------------------------------------------------------------------+
void AddShape(int window, string name, double level, datetime time, uchar code, color clr,  int size = 1, ENUM_ARROW_ANCHOR anchor = ANCHOR_TOP) export
  {
   ObjectCreate(0, name, OBJ_ARROW, window, time, level);
   ObjectSetInteger(0, name, OBJPROP_ARROWCODE, code);
   ObjectSetInteger(0, name, OBJPROP_ANCHOR, anchor);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_SOLID);
   ObjectSetInteger(0, name, OBJPROP_WIDTH, size);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, true);
   ObjectSetInteger(0, name, OBJPROP_BACK, true);
  }
//+------------------------------------------------------------------+
void DrawTrendline(string name, datetime time1, double price1, datetime time2, double price2,  color clr, long width = 0, bool rayRight = false, bool rayLeft = false, ENUM_LINE_STYLE style = STYLE_DOT) export
  {
   if(ObjectFind(0, name) < 0)
     {
      ObjectDelete(0, name);
     }
   ObjectCreate(0, name, OBJ_TREND, 0, time1, price1, time2, price2);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_STYLE, style);
   ObjectSetInteger(0, name, OBJPROP_WIDTH, width);
   ObjectSetInteger(0, name, OBJPROP_RAY_LEFT, rayLeft);
   ObjectSetInteger(0, name, OBJPROP_RAY_RIGHT, rayRight);
   ChartRedraw(0);
  }
//+------------------------------------------------------------------+
void DrawRectangle(const string name, datetime time1, double price1, datetime time2, double price2, const color clr = clrAqua, const int width = 0, const bool fill = true, const bool back = false, const ENUM_LINE_STYLE style = STYLE_SOLID, const long z_order = 1) export
  {
   ObjectCreate(0, name, OBJ_RECTANGLE, 0, time1, price1, time2, price2);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_STYLE, style);
   ObjectSetInteger(0, name, OBJPROP_WIDTH, width);
   ObjectSetInteger(0, name, OBJPROP_FILL, fill);
   ObjectSetInteger(0, name, OBJPROP_BACK, back);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, true);
   ObjectSetInteger(0, name, OBJPROP_SELECTED, false);
   ObjectSetInteger(0, name, OBJPROP_ZORDER, z_order);
  }
//+------------------------------------------------------------------+
void ChangeShape(string name, uchar code) export
  {
   ObjectSetInteger(0, name, OBJPROP_ARROWCODE, code);
  }
//+------------------------------------------------------------------+
void ClearChart() export
  {
   ObjectsDeleteAll(0, -1, OBJ_FIBO);
   ObjectsDeleteAll(0, -1, OBJ_VLINE);
   ObjectsDeleteAll(0, -1, OBJ_HLINE);
   ObjectsDeleteAll(0, -1, OBJ_ARROW);
   ObjectsDeleteAll(0, -1, OBJ_RECTANGLE);
   ObjectsDeleteAll(0, -1, OBJ_EDIT);
   ObjectsDeleteAll(0, -1, OBJ_TREND);
  }
//+------------------------------------------------------------------+
void DrawButton(string name, string text, int x, int y, int width, int height, color clr, color textclr = clrWhite) export
  {
   ObjectCreate(0, name, OBJ_EDIT, 0, 0, 0);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, name, OBJPROP_XSIZE, width);
   ObjectSetInteger(0, name, OBJPROP_YSIZE, height);
   ObjectSetString(0, name, OBJPROP_FONT, "Segoe UI Semilight");
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 5);
   ObjectSetInteger(0, name, OBJPROP_ALIGN, ALIGN_CENTER);
   ObjectSetInteger(0, name, OBJPROP_COLOR, textclr);
   ObjectSetInteger(0, name, OBJPROP_BGCOLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_BORDER_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_BORDER_TYPE, BORDER_FLAT);
   ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_SOLID);
   ObjectSetInteger(0, name, OBJPROP_WIDTH, 0);
   ObjectSetInteger(0, name, OBJPROP_BACK, false);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, true);
   ObjectSetInteger(0, name, OBJPROP_SELECTED, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, false);
   ObjectSetInteger(0, name, OBJPROP_ZORDER, 10000);
   ObjectSetString(0, name, OBJPROP_TEXT, text);
  }
//+------------------------------------------------------------------+
