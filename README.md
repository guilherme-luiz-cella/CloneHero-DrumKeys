# Clone Hero Drum Keys

AutoHotkey v2 scripts that let drums use the same left-to-right keyboard layout as the guitar in Clone Hero.

Clone Hero shares one key map across instruments, so each drum pad uses the guitar fret key of the same color. With the default keys (A S J K L) the green drum pad, on the far right of the highway, ends up on A, the leftmost key. These scripts fix that.

## Files

- `CloneHero-DrumKeys.ahk`: while drum mode is on, remaps A S J K so they hit drum lanes 1 to 4 from left to right. L (kick/orange) is unchanged. Drum mode is detected automatically from the strikers at the bottom of the screen (green right of red means drums). F1 toggles auto-detect.
- `CloneHero-Watcher.ahk`: runs at Windows startup, starts the drum keys script when `Clone Hero.exe` opens and closes it when the game exits.

## Setup

1. Install AutoHotkey v2: `winget install AutoHotkey.AutoHotkey`
2. Put a shortcut to `CloneHero-Watcher.ahk` in the Startup folder (`shell:startup`).
