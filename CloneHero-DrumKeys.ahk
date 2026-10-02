#Requires AutoHotkey v2.0
#SingleInstance Force

; Clone Hero drum key layout.
; Drum mode makes A S J K hit lanes 1-4 left to right, like the guitar frets.
; L (kick / orange) is unchanged.
;
; Auto-detect: looks at the bottom of the game window for the green and red strikers.
; Guitar has green left of red, drums have green right of red. Without a visible
; highway (menus) it falls back to guitar mode so menu keys stay normal.
; F1 turns auto-detect off/on (off = always guitar keys).

drumMode := false
autoDetect := true
game := "ahk_exe Clone Hero.exe"

CoordMode("Pixel", "Client")
SetTimer(DetectInstrument, 500)

DetectInstrument() {
    global drumMode
    if !autoDetect || !WinActive(game) {
        drumMode := false
        return
    }
    WinGetClientPos(, , &w, &h, game)
    ; Highway area only: bottom 30%, middle half, so song backgrounds don't interfere.
    x1 := Round(w * 0.25), x2 := Round(w * 0.75), top := Round(h * 0.70)
    greenFound := PixelSearch(&gx, &gy, x1, top, x2, h - 1, 0x00FF00, 40)
    redFound := PixelSearch(&rx, &ry, x1, top, x2, h - 1, 0xFF0000, 40)
    newMode := greenFound && redFound && gx > rx
    if (newMode != drumMode) {
        drumMode := newMode
        ToolTip(drumMode ? "Drum keys ON" : "Guitar keys")
        SetTimer(() => ToolTip(), -1500)
    }
}

#HotIf WinActive(game)
F1:: {
    global autoDetect
    autoDetect := !autoDetect
    ToolTip(autoDetect ? "Auto-detect ON" : "Auto-detect OFF (guitar keys)")
    SetTimer(() => ToolTip(), -1500)
}

#HotIf drumMode && WinActive(game)
a::s
s::j
j::k
k::a
#HotIf
