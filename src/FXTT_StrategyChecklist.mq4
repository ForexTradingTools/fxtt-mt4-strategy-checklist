//+------------------------------------------------------------------+
//| FXTT_StrategyChecklist.mq4                                       |
//| Copyright 2016, Carlos Oliveira                                  |
//| https://www.forextradingtools.eu                                 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Carlos Oliveira"
#property link      "https://www.forextradingtools.eu/"
#property version   "3.0"
#property strict
#property indicator_chart_window
#property indicator_buffers 0

#define NUM_CHECKS 20
#define TITLE_HEIGHT 22
#define PANEL_MIN_WIDTH 160
#define PANEL_MIN_ROW_HEIGHT 16
#define PANEL_MIN_FONT_SIZE 6
#define PANEL_MARGIN 1
#define DATA_DIR "SChecklist"


//--- Instance and layout
input string TAG = "FxTT_SC_";
input ENUM_BASE_CORNER Location = CORNER_RIGHT_LOWER;
input int DialogWidth = 280;
input int MarginFromEdge = 20;
input int InnerPaddingX = 8;
input int InnerPaddingY = 6;
input int RowHeight = 24;
input int RowSpacing = 2;

//--- Appearance
input string FontName = "Segoe UI";
input int FontSize = 9;
input color CheckedColor = clrLimeGreen;
input color UncheckedColor = clrBlack;
input color SectionColor = clrGold;
input color TitleColor = clrBlack;
input bool ShowTooltips = true;

//--- Persistence
input bool SavePerSymbol = true;
input bool SavePerTimeframe = false;

//--- Checklist items: a leading '>' creates a section header.
input string Check01 = ">--- Setup ---";
input string Check02 = "Trend confirmed";
input string Check03 = "Structure respected";
input string Check04 = ">--- Entry ---";
input string Check05 = "Signal candle closed";
input string Check06 = "Risk/Reward >= 1:2";
input string Check07 = "";
input string Check08 = "";
input string Check09 = "";
input string Check10 = "";
input string Check11 = "";
input string Check12 = "";
input string Check13 = "";
input string Check14 = "";
input string Check15 = "";
input string Check16 = "";
input string Check17 = "";
input string Check18 = "";
input string Check19 = "";
input string Check20 = "";

string g_panel_name;
string g_title_name;
string g_row_names[NUM_CHECKS];
bool   g_active[NUM_CHECKS];
bool   g_is_section[NUM_CHECKS];
bool   g_state[NUM_CHECKS];
int    g_visible_count = 0;
int    g_panel_x = 0;
int    g_panel_y = 0;
int    g_panel_width = PANEL_MIN_WIDTH;
int    g_panel_height = TITLE_HEIGHT;
int    g_row_height = PANEL_MIN_ROW_HEIGHT;
int    g_row_spacing = 0;
int    g_inner_padding_x = 0;
int    g_inner_padding_y = 0;
int    g_font_size = PANEL_MIN_FONT_SIZE;

//+------------------------------------------------------------------+
void GetChecklistStrings(string &items[])
{
   ArrayResize(items, NUM_CHECKS);
   items[0]  = Check01;
   items[1]  = Check02;
   items[2]  = Check03;
   items[3]  = Check04;
   items[4]  = Check05;
   items[5]  = Check06;
   items[6]  = Check07;
   items[7]  = Check08;
   items[8]  = Check09;
   items[9]  = Check10;
   items[10] = Check11;
   items[11] = Check12;
   items[12] = Check13;
   items[13] = Check14;
   items[14] = Check15;
   items[15] = Check16;
   items[16] = Check17;
   items[17] = Check18;
   items[18] = Check19;
   items[19] = Check20;
}

//+------------------------------------------------------------------+
bool IsSectionHeader(const string text)
{
   return StringLen(text) > 0 && StringGetChar(text, 0) == '>';
}

//+------------------------------------------------------------------+
int CountVisible()
{
   string items[];
   GetChecklistStrings(items);
   int count = 0;
   for(int i = 0; i < NUM_CHECKS; i++)
      if(StringLen(items[i]) > 0)
         count++;
   return count;
}

//+------------------------------------------------------------------+
string BuildSaveKey()
{
   string key = DATA_DIR + "\\" + TAG;
   if(SavePerSymbol)
      key += "_" + Symbol();
   if(SavePerTimeframe)
      key += "_" + IntegerToString(Period());
   return key + "_state.bin";
}

//+------------------------------------------------------------------+
void ConfigureObject(const string name)
{
   ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_SELECTED, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
   ObjectSetInteger(0, name, OBJPROP_BACK, false);
}

//+------------------------------------------------------------------+
void SetObjectPosition(const string name, const int x, const int y)
{
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
}

//+------------------------------------------------------------------+
void PositionObjects()
{
   int chart_width = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS, 0);
   int chart_height = (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS, 0);
   int margin = MathMax(PANEL_MARGIN, MarginFromEdge);

   g_panel_x = margin;
   g_panel_y = margin;
   if(Location == CORNER_RIGHT_UPPER || Location == CORNER_RIGHT_LOWER)
      g_panel_x = MathMax(0, chart_width - g_panel_width - margin);
   if(Location == CORNER_LEFT_LOWER || Location == CORNER_RIGHT_LOWER)
      g_panel_y = MathMax(0, chart_height - g_panel_height - margin);

   if(ObjectFind(0, g_panel_name) >= 0)
   {
      SetObjectPosition(g_panel_name, g_panel_x, g_panel_y);
      ObjectSetInteger(0, g_panel_name, OBJPROP_XSIZE, g_panel_width);
      ObjectSetInteger(0, g_panel_name, OBJPROP_YSIZE, g_panel_height);
   }
   if(ObjectFind(0, g_title_name) >= 0)
      SetObjectPosition(g_title_name, g_panel_x + g_inner_padding_x, g_panel_y + g_inner_padding_y);

   int visible_slot = 0;
   for(int i = 0; i < NUM_CHECKS; i++)
   {
      if(!g_active[i])
         continue;
      int row_y = g_panel_y + g_inner_padding_y + TITLE_HEIGHT +
                  visible_slot * (g_row_height + g_row_spacing);
      SetObjectPosition(g_row_names[i], g_panel_x + g_inner_padding_x, row_y);
      visible_slot++;
   }
}

//+------------------------------------------------------------------+
void DeleteObjects()
{
   if(StringLen(g_panel_name) > 0 && ObjectFind(0, g_panel_name) >= 0)
      ObjectDelete(0, g_panel_name);
   if(StringLen(g_title_name) > 0 && ObjectFind(0, g_title_name) >= 0)
      ObjectDelete(0, g_title_name);
   for(int i = 0; i < NUM_CHECKS; i++)
   {
      string row_name = TAG + "Row_" + IntegerToString(i);
      if(ObjectFind(0, row_name) >= 0)
         ObjectDelete(0, row_name);
   }
}

//+------------------------------------------------------------------+
bool CreatePanel()
{
   g_panel_name = TAG + "Panel";
   g_title_name = TAG + "Title";

   if(!ObjectCreate(0, g_panel_name, OBJ_RECTANGLE_LABEL, 0, 0, 0))
   {
      Print("Strategy Checklist: failed to create panel, error ", GetLastError());
      return false;
   }
   ConfigureObject(g_panel_name);
   ObjectSetInteger(0, g_panel_name, OBJPROP_COLOR, clrSilver);
   ObjectSetInteger(0, g_panel_name, OBJPROP_BGCOLOR, clrWhiteSmoke);
   ObjectSetInteger(0, g_panel_name, OBJPROP_BORDER_TYPE, BORDER_FLAT);
   ObjectSetInteger(0, g_panel_name, OBJPROP_ZORDER, 1);

   if(!ObjectCreate(0, g_title_name, OBJ_LABEL, 0, 0, 0))
   {
      Print("Strategy Checklist: failed to create title, error ", GetLastError());
      return false;
   }
   ConfigureObject(g_title_name);
   ObjectSetText(g_title_name, "Strategy Checklist (MT4)", g_font_size, FontName, TitleColor);
   ObjectSetString(0, g_title_name, OBJPROP_TOOLTIP, "FxTT Strategy Checklist");
   ObjectSetInteger(0, g_title_name, OBJPROP_ZORDER, 2);

   PositionObjects();
   return true;
}

//+------------------------------------------------------------------+
void UpdateRow(const int index, const string text)
{
   if(!g_active[index] || g_is_section[index])
      return;
   string marker = g_state[index] ? "[x] " : "[ ] ";
   color row_color = g_state[index] ? CheckedColor : UncheckedColor;
   ObjectSetText(g_row_names[index], marker + text, g_font_size, FontName, row_color);
   ObjectSetInteger(0, g_row_names[index], OBJPROP_COLOR, row_color);
   ObjectSetInteger(0, g_row_names[index], OBJPROP_BGCOLOR, clrWhite);
   ObjectSetInteger(0, g_row_names[index], OBJPROP_ZORDER, 3);
   if(ShowTooltips)
      ObjectSetString(0, g_row_names[index], OBJPROP_TOOLTIP, "Toggle: " + text);
   else
      ObjectSetString(0, g_row_names[index], OBJPROP_TOOLTIP, "");
}

//+------------------------------------------------------------------+
bool BuildRows()
{
   string items[];
   GetChecklistStrings(items);
   g_visible_count = 0;
   ArrayInitialize(g_active, false);
   ArrayInitialize(g_is_section, false);
   for(int i = 0; i < NUM_CHECKS; i++)
   {
      g_row_names[i] = TAG + "Row_" + IntegerToString(i);
      if(StringLen(items[i]) == 0)
         continue;

      g_active[i] = true;
      g_is_section[i] = IsSectionHeader(items[i]);
      if(g_is_section[i])
      {
         if(!ObjectCreate(0, g_row_names[i], OBJ_LABEL, 0, 0, 0))
         {
            Print("Strategy Checklist: failed to create section row ", i, ", error ", GetLastError());
            return false;
         }
         ConfigureObject(g_row_names[i]);
         ObjectSetText(g_row_names[i], items[i], g_font_size, FontName, SectionColor);
         ObjectSetString(0, g_row_names[i], OBJPROP_TOOLTIP, "");
         ObjectSetInteger(0, g_row_names[i], OBJPROP_ZORDER, 2);
      }
      else
      {
         if(!ObjectCreate(0, g_row_names[i], OBJ_BUTTON, 0, 0, 0))
         {
            Print("Strategy Checklist: failed to create checklist row ", i, ", error ", GetLastError());
            return false;
         }
         ConfigureObject(g_row_names[i]);
         ObjectSetInteger(0, g_row_names[i], OBJPROP_XSIZE,
                          MathMax(40, g_panel_width - g_inner_padding_x * 2));
         ObjectSetInteger(0, g_row_names[i], OBJPROP_YSIZE, g_row_height);
         UpdateRow(i, items[i]);
      }
      g_visible_count++;
   }
   PositionObjects();
   return true;
}

//+------------------------------------------------------------------+
void SaveState()
{
   FolderCreate(DATA_DIR);
   ResetLastError();
   int handle = FileOpen(BuildSaveKey(), FILE_READ | FILE_WRITE | FILE_BIN);
   if(handle == INVALID_HANDLE)
   {
      Print("Strategy Checklist: unable to save state, error ", GetLastError());
      return;
   }
   FileSeek(handle, 0, SEEK_SET);
   for(int i = 0; i < NUM_CHECKS; i++)
      FileWriteInteger(handle, g_state[i] ? 1 : 0, LONG_VALUE);
   FileFlush(handle);
   FileClose(handle);
}

//+------------------------------------------------------------------+
void LoadState()
{
   ResetLastError();
   int handle = FileOpen(BuildSaveKey(), FILE_READ | FILE_BIN);
   if(handle == INVALID_HANDLE)
      return;

   for(int i = 0; i < NUM_CHECKS; i++)
   {
      if(FileIsEnding(handle))
         break;
      g_state[i] = FileReadInteger(handle, LONG_VALUE) != 0;
   }
   FileClose(handle);

   string items[];
   GetChecklistStrings(items);
   for(int i = 0; i < NUM_CHECKS; i++)
      if(g_active[i] && !g_is_section[i])
         UpdateRow(i, items[i]);
}

//+------------------------------------------------------------------+
int OnInit()
{
   g_panel_width = MathMax(PANEL_MIN_WIDTH, DialogWidth);
   g_row_height = MathMax(PANEL_MIN_ROW_HEIGHT, RowHeight);
   g_row_spacing = MathMax(0, RowSpacing);
   g_inner_padding_x = MathMax(0, InnerPaddingX);
   g_inner_padding_y = MathMax(0, InnerPaddingY);
   g_font_size = MathMax(PANEL_MIN_FONT_SIZE, FontSize);
   g_visible_count = CountVisible();
   g_panel_height = g_inner_padding_y * 2 + TITLE_HEIGHT +
                    g_visible_count * (g_row_height + g_row_spacing);

   ArrayInitialize(g_state, false);
   ArrayInitialize(g_active, false);
   ArrayInitialize(g_is_section, false);
   g_panel_name = TAG + "Panel";
   g_title_name = TAG + "Title";
   DeleteObjects();
   if(!CreatePanel() || !BuildRows())
   {
      DeleteObjects();
      return INIT_FAILED;
   }
   LoadState();
   ChartRedraw();
   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   SaveState();
   DeleteObjects();
   ChartRedraw();
}

//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   return rates_total;
}

//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
   if(id == CHARTEVENT_CHART_CHANGE)
   {
      PositionObjects();
      ChartRedraw();
      return;
   }
   if(id != CHARTEVENT_OBJECT_CLICK)
      return;

   string items[];
   GetChecklistStrings(items);
   for(int i = 0; i < NUM_CHECKS; i++)
   {
      if(!g_active[i] || g_is_section[i] || sparam != g_row_names[i])
         continue;
      g_state[i] = !g_state[i];
      UpdateRow(i, items[i]);
      SaveState();
      ChartRedraw();
      return;
   }
}
//+------------------------------------------------------------------+
