# Neon Stack

A Guideline-style marathon in Godot 4.7. Dark neon playfield, SRS rotation, 7-bag, hold, ghost, next queue, T-spins, back-to-back, combos, perfect clears, and local high scores.

## Run

1. Install [Godot 4.7.2](https://godotengine.org/download) (standard, not .NET).
2. Open this folder as a project, press **F5**.

Double-click `play.bat`. If a window flashes and closes, use `debug-play.bat` so the error stays on screen.

From a terminal:

```
C:\Users\9am6s\tools\godot\Godot_v4.7.2-stable_win64.exe --path C:\Users\9am6s\neon-stack
```

## Controls

| Action | Keys |
|---|---|
| Move | Left / Right |
| Soft drop | Down |
| Hard drop | Space |
| Rotate CW | Up, X |
| Rotate CCW | Z, Ctrl |
| Rotate 180 | A |
| Hold | C, Shift |
| Pause | Esc |

## Your music

Settings → **Add music…** picks an `.ogg`, `.mp3`, or `.wav` and copies it into the game library.

You can also drop files into the library folder (Settings → **Open music folder**). That folder is created on first launch under Godot user data, typically:

`%APPDATA%\Godot\app_userdata\Neon Stack\music\`

Pick a track from the dropdown. Choose **None** for silence. Volume sliders are in Settings.

## Tests

```
godot --headless --path C:\Users\9am6s\neon-stack --script res://tests/test_runner.gd
```
