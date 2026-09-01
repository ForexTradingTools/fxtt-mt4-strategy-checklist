# FxTT Strategy Checklist — Free MT4 Indicator

![MQL4](https://img.shields.io/badge/MQL4-Indicator-blue?style=flat-square)
![MT4](https://img.shields.io/badge/Platform-MetaTrader%204-informational?style=flat-square)
![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)
![Free](https://img.shields.io/badge/Price-Free-brightgreen?style=flat-square)

> An interactive, on-chart checklist for confirming your trading process before you enter a trade.

![Strategy Checklist on MT4](https://raw.githubusercontent.com/ForexTradingTools/fxtt-mt4-strategy-checklist/main/screenshots/strategy-checklist-mt4-featured.png)

## Overview

FxTT Strategy Checklist is a free MetaTrader 4 (MT4) indicator that puts your trading rules beside the price chart. Tick each rule as you work through a setup so your execution process stays visible, repeatable, and independent of memory or emotion.

You can define up to 20 checklist lines in the indicator inputs. A line beginning with `>` is displayed as a section header, which lets you organize a workflow into groups such as setup, entry, and risk management. Non-empty lines become interactive rows; empty lines are omitted.

The indicator is a discipline and workflow tool only. It does not place orders, modify orders, move stops, send broker requests, or automate trading.

**Product page:** [forextradingtools.eu/en/marketplace/strategy-checklist](https://forextradingtools.eu/en/marketplace/strategy-checklist)

## Features

- Interactive checklist panel directly on an MT4 chart.
- Up to 20 custom checklist items.
- Section headers using a leading `>` character.
- State saved in the terminal's `MQL4/Files/SChecklist/` folder.
- State saved per symbol by default, with optional timeframe separation.
- Configurable chart corner, panel width, margins, row height, and row spacing.
- Configurable font, font size, checked and unchecked colors, section color, and title color.
- Optional tooltips for checklist rows.
- Multiple instances on one chart when each instance uses a unique `TAG` value.
- No trading automation or broker interaction.

## Installation

1. Download the source file from [`src/FXTT_StrategyChecklist.mq4`](src/FXTT_StrategyChecklist.mq4), or download a compiled file from [Releases](https://github.com/ForexTradingTools/fxtt-mt4-strategy-checklist/releases) when one is published.
2. In MT4, choose **File → Open Data Folder**.
3. Open `MQL4/Indicators/`.
4. Copy `FXTT_StrategyChecklist.mq4` into that folder.
5. Open the file in MetaEditor and press **Compile**. This creates `FXTT_StrategyChecklist.ex4` beside the source.
6. Restart MT4, or right-click the Navigator and choose **Refresh**.
7. Find **FXTT_StrategyChecklist** under **Navigator → Indicators**, drag it onto a chart, and configure the checklist inputs.

The repository's `releases/` directory is reserved for compiled distribution files. No binary is included in this source-ready repository until it has passed the MT4 compilation gate.

## Settings Reference

### Instance and layout

| Parameter | Default | Description |
|---|---:|---|
| `TAG` | `FxTT_SC_` | Prefix for chart objects and saved state. Use a unique value for multiple checklist instances on one chart. |
| `Location` | `CORNER_RIGHT_LOWER` | Chart corner used to place the panel. |
| `DialogWidth` | `280` | Panel width in pixels. |
| `MarginFromEdge` | `20` | Distance from the selected chart edges in pixels. |
| `InnerPaddingX` | `8` | Horizontal panel padding in pixels. |
| `InnerPaddingY` | `6` | Vertical panel padding in pixels. |
| `RowHeight` | `24` | Height of each checklist row in pixels. |
| `RowSpacing` | `2` | Additional gap between rows in pixels. |

### Appearance

| Parameter | Default | Description |
|---|---:|---|
| `FontName` | `Segoe UI` | Font used by the title and rows. |
| `FontSize` | `9` | Font size used by the title and rows. |
| `CheckedColor` | `clrLimeGreen` | Text color for a checked row. |
| `UncheckedColor` | `clrBlack` | Text color for an unchecked row. |
| `SectionColor` | `clrGold` | Text color for a section header. |
| `TitleColor` | `clrBlack` | Text color for the panel title. |
| `ShowTooltips` | `true` | Shows a row tooltip explaining that the row can be toggled. |

### Persistence

| Parameter | Default | Description |
|---|---:|---|
| `SavePerSymbol` | `true` | Keeps separate checklist state for each chart symbol. |
| `SavePerTimeframe` | `false` | Adds the chart timeframe to the saved-state key when enabled. |

State is written when a row changes and when the indicator is removed. The `TAG`, symbol, and optional timeframe keep independent configurations separate. If both scope options are disabled, the instance shares one state across symbols and timeframes.

### Checklist items

`Check01` through `Check20` accept one line of text each. A non-empty line beginning with `>` is a non-clickable section header. Any other non-empty line is a clickable checklist row. Empty lines do not take space in the panel.

The default example is:

```text
>--- Setup ---
Trend confirmed
Structure respected
>--- Entry ---
Signal candle closed
Risk/Reward >= 1:2
```

## Usage

1. Add your setup, entry, and risk rules to `Check01` through `Check20`.
2. Attach the indicator to the chart where you are evaluating a trade.
3. Click each rule after it has been confirmed.
4. Proceed only when your own process is complete. The indicator does not make that decision for you.

## Compatibility

- **Platform:** MetaTrader 4 only.
- **Compiler:** Modern MQL4 compiler (MT4 build 600 or later).
- **File type:** `.mq4` source; `.ex4` after compiling with MetaEditor.
- **Charts:** Any symbol and timeframe supported by MT4.
- **Install folder:** `MQL4/Indicators/`.
- **Permissions:** The indicator uses chart objects and the terminal's local `MQL4/Files/` storage. It does not require DLL imports, WebRequest permissions, or trading permissions.

This repository's MT4 source is a native MQL4 implementation of the documented Strategy Checklist behavior. It is not the Forex Scanner and does not include scanner calculations or trading logic.

## Repository Layout

```text
fxtt-mt4-strategy-checklist/
├── src/
│   └── FXTT_StrategyChecklist.mq4       # Complete self-contained MQL4 source
├── releases/                             # Compiled .ex4 files after release packaging
├── screenshots/
│   ├── strategy-checklist-mt4-featured.png
│   └── strategy-checklist-mt4-panel.png
├── LICENSE
└── README.md
```

## Version and Changelog

### v3.0.0

- Initial public MT4 release of the Strategy Checklist indicator.
- Added a self-contained chart-object panel with up to 20 configurable rows.
- Added `>` section headers, persistent state, per-symbol and optional per-timeframe storage.
- Added configurable layout, appearance, tooltips, and multi-instance `TAG` support.
- Trading automation and broker interaction are intentionally not included.

The MT4 port follows the documented v3.0 Strategy Checklist behavior from the reference implementation.

## Related FxTT Repositories

- [FxTT MTF Bollinger Bands MT4](https://github.com/ForexTradingTools/fxtt-mt4-mtf-bollinger-bands)
- [FxTT MTF Bollinger Bands MT5](https://github.com/ForexTradingTools/fxtt-mt5-mtf-bollinger-bands)
- [FxTT MTF Triple Moving Averages MT4](https://github.com/ForexTradingTools/fxtt-mt4-mtf-triple-moving-averages)
- [FxTT Strategy Checklist MT5](https://github.com/ForexTradingTools/fxtt-mt5-strategy-checklist)
- [FxTT Forex Scanner MT4](https://github.com/ForexTradingTools/fxtt-mt4-forex-scanner)
- [FxTT Forex Scanner MT5](https://github.com/ForexTradingTools/fxtt-mt5-forex-scanner)
- [FxTT MTF Triple Moving Averages MT5](https://github.com/ForexTradingTools/fxtt-mt5-mtf-triple-moving-averages)
- [FxTT Pivot Points MT5](https://github.com/ForexTradingTools/fxtt-mt5-pivot-points)
- [FxTT Session High/Low MT5](https://github.com/ForexTradingTools/fxtt-mt5-session-high-low)
- [FxTT News Calendar MT5](https://github.com/ForexTradingTools/fxtt-mt5-news-calendar)
- [FxTT ZigZag Zones MT5](https://github.com/ForexTradingTools/fxtt-mt5-zig-zag-zones)

## License

This project is released under the [MIT License](LICENSE). You may use, modify, and distribute the source provided that the copyright and license notices are retained.
