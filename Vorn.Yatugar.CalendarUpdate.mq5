//+------------------------------------------------------------------+
//|                                  Vorn.Yatugar.CalendarUpdate.mq5 |
//|                                                             Vorn |
//|                                                  https://vorn.ir |
//+------------------------------------------------------------------+
#property copyright "Vorn"
#property link      "https://vorn.ir"
#property version   "1.00"
//+------------------------------------------------------------------+
#import "Vorn.Yatugar.ex5"
void CalendarUpdate(datetime from, datetime to);
#import
//+------------------------------------------------------------------+
sinput datetime From = D'2024.03.01';
sinput datetime To = D'2024.10.01';
//+------------------------------------------------------------------+
int OnInit()
  {
   CalendarUpdate(From, To);
   ExpertRemove();
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
