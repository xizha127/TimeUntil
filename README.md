# Time Until

[DankMaterialShell](https://danklinux.com/) plugin that displays a customizable countdown timer in the Dank Bar.
Perfect for tracking important deadlines, goals, or any time-sensitive events.

Inspired by GNOME extension [No Time For Caution](https://github.com/ans-ibrahim/no-time-for-caution).

## Screenshots

| Settings | Horizontal | Vertical |
|---|---|---|
| ![Plugin settings](img/settings.png) | ![Horizontal pill](img/horizontal-pill.png) | ![Vertical pill](img/vertical-pill.png) |

## Features

- Remaining time is displayed on the Dank Bar (horizontal).
- Remaining time is recalculated:
  - On shell start.
  - When changing settings.
  - When enough time passes for each unit to tick down by 0.1 or once a day, whichever is first.
  - Every minute for custom formats, or every second if the custom format includes seconds.
- Time is shown with up to 1 decimal value for built-in units.
- Time can be shown with a custom duration format for exact days/hours/minutes/seconds output.
- Time is calculated against your OS time.
- When the target date time passes, the widget shows the time overdue instead.

## Installation

### From Plugin Registry (recommended)

1. Install from **DMS Settings > Plugins > Browse**.
   Make sure you've selected **Show 3rd Party**.
   If it doesn't appear, select the round arrow to refresh the list.
1. Enable **Time Until**.
1. In DMS settings go to **Dank Bar > Widgets**.
1. Add **Time Until** to your Dank Bar widget list.

Alternatively, run:

```bash
dms plugins install timeUntil
```

### Manual

1. Copy this directory to `~/.config/DankMaterialShell/plugins/`
1. Open **DMS Settings > Plugins**
1. Enable **Time Until**
   If it doesn't appear in the list, select **Scan** to detect it.
1. In DMS settings go to **Dank Bar > Widgets**.
1. Add **Time Until** to your Dank Bar widget list.

## Settings

To get to the plugin settings:

1. Open **DMS Settings > Plugins**.
1. Select the down chevron next to **Time Until**.

These settings are available:

- **Target Date** - Date to count down to, in the format `<YYYY>-<MM>-<DD> <hh>:<mm>`, for example `2026-04-10 21:37`.
  Time component is optional and defaults to midnight if omitted.
- **Unit** - Whether to use hours, days, custom format, weeks, or months. Default: days.
- **Custom Format** - Used when **Unit** is **Custom Format**. Default: `d 'days' H 'hours' m 'minutes' L`.
- **Custom Short Format** - Used for vertical bar display when **Unit** is **Custom Format**. Default: `d'd' H'h' m'm'`.
- **Label** - Text to show after the units for built-in units, or via the `L` token for custom formats. Default: "remaining". Changes to "overdue" when the target date is in the past.

### Custom format tokens

Custom format strings use a small date-fns-style tokenizer for countdown durations. Quote literal text with single quotes.

| Token | Meaning |
|---|---|
| `d`, `dd` | Total days, unpadded / 2-digit padded |
| `H`, `HH` | Remaining hours after days, unpadded / padded |
| `m`, `mm` | Remaining minutes after hours, unpadded / padded |
| `s`, `ss` | Remaining seconds after minutes, unpadded / padded |
| `w`, `ww` | Total weeks, unpadded / padded |
| `M`, `MM` | Approximate total months, unpadded / padded |
| `h`, `hh` | Total hours, unpadded / padded |
| `t`, `tt` | Total minutes, unpadded / padded |
| `L` | Effective label: your label, `remaining`, or `overdue` |
| `X` | `-` when overdue, empty otherwise |
| `x` | `!` when overdue, empty otherwise |

Examples:

- `d'd' H'h' m'm'` -> `7d 3h 42m`
- `dd':'HH':'mm` -> `07:03:42`
- `Xh'h' m'm'` -> `-171h 42m` when overdue
- `d 'days until exam'` -> `7 days until exam`
- `d 'days' H 'hours' m 'minutes' L` -> `7 days 3 hours 42 minutes Exam`

## Usage

- **In the bar**: Observe time counting down to your set date (or up from it if overdue).
- **Click the widget**: See a popout with your target date.
