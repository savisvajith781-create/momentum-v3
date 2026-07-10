# Momentum — Minimal Study Tracker

A beautiful Windows desktop study tracker built for CA Final students. Inspired by Apple Fitness, Things 3, Linear, and Raycast — dark, glassy, fast.

## Features

- **Dashboard** — daily goal ring, live timer, subject breakdown, quotes, tasks
- **Single-timer session tracking** — Play / Pause / Resume / Stop, auto-saved
- **History** — calendar view, per-day session log, inline edit/delete
- **Statistics** — daily/weekly/monthly/yearly views, bar chart, subject pie chart, activity heatmap
- **Tasks** — simple checklist with subject tags and due dates
- **Checkpoints** — milestone tracker (e.g. "AFM R1", "FR R2") with progress and status
- **Settings** — daily goal, accent color, subject management, JSON/CSV export, PDF weekly report

## Tech Stack

- Flutter (stable) + Riverpod for state management
- SQLite (`sqflite_common_ffi`) for sessions/tasks/subjects/checkpoints
- `window_manager` for native window sizing/position persistence
- `fl_chart` for bar/pie charts
- `google_fonts` (Inter) for typography
- `pdf` + `csv` for exports

## Getting Started

```bash
flutter pub get
flutter run -d windows
```

To build a release executable:

```bash
flutter build windows
```

The output binary will be at `build/windows/x64/runner/Release/momentum.exe`.

## Project Structure

```
lib/
  main.dart              # Entry point, window + service init
  app.dart                # MaterialApp + theme wiring
  app_shell.dart           # Navigation rail + page switching
  theme/                   # Colors and ThemeData
  constants/               # App-wide constants
  models/                  # Plain data models
  database/                # SQLite helper + repositories
  services/                # Settings, quotes, export (PDF/CSV/JSON)
  providers/                # Riverpod providers/notifiers
  pages/                   # Dashboard, History, Statistics, Tasks, Checkpoints, Settings
  widgets/                 # Reusable UI components
assets/
  quotes.json              # Local quote bank, rotates hourly
```

## Data Storage

- SQLite DB: `%LOCALAPPDATA%\Momentum\momentum.db`
- Exports: `Documents\Momentum\exports\`
- Preferences: via `shared_preferences` (window size/position, daily goal, accent color)
