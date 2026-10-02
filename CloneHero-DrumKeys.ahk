#Requires AutoHotkey v2.0
#SingleInstance Force

; Clone Hero drum key layout.
; Drum mode makes A S J K hit lanes 1-4 left to right, like the guitar frets.
; L (kick / orange) is unchanged.
;
; Auto-detect: captures the strip of highway just above the bottom of the game
; window and finds the green striker. Guitar has green on the left of the highway,
; drums have it on the right. With no green striker visible (menus) it falls back
; to guitar keys so menu controls stay normal.
; F1 turns auto-detect off/on (off = always guitar keys).
; F2 shows what the detector sees, for troubleshooting.

drumMode := false
autoDetect := true
lastInfo := ""
game := "ahk_exe Clone Hero.exe"

SetTimer(DetectInstrument, 500)

DetectInstrument() {
    global drumMode, lastInfo
    if !autoDetect || !WinActive(game) {
        drumMode := false
        return
    }
    newMode := GreenIsOnRight()
    if (newMode = "")
        return
    if (newMode != drumMode) {
        drumMode := newMode
        ToolTip(drumMode ? "Drum keys ON" : "Guitar keys")
        SetTimer(() => ToolTip(), -1500)
    }
}

; Returns true (drums), false (guitar or no highway), or "" (unsure, keep current mode).
GreenIsOnRight() {
    global lastInfo
    WinGetClientPos(&cx, &cy, &w, &h, game)
    ; Highway strip: bottom 18% of the window, middle half of its width.
    rx := cx + Round(w * 0.25), rw := Round(w * 0.5)
    ry := cy + Round(h * 0.80), rh := Round(h * 0.18)
    pixels := CaptureScreen(rx, ry, rw, rh)

    count := 0, sumX := 0
    step := 4
    y := 0
    while (y < rh) {
        x := 0
        while (x < rw) {
            v := NumGet(pixels, (y * rw + x) * 4, "UInt")
            b := v & 0xFF, g := (v >> 8) & 0xFF, r := (v >> 16) & 0xFF
            if (g >= 25 && g > 2 * r + 5 && g > 2 * b + 5) {
                count++
                sumX += x
            }
            x += step
        }
        y += step
    }

    if (count < 15) {
        lastInfo := "green pixels: " count " (no highway, guitar keys)"
        return false
    }
    avg := sumX / count / rw   ; 0 = left edge of strip, 1 = right edge
    lastInfo := "green pixels: " count ", position: " Round(avg * 100) "% from left"
    if (avg > 0.58)
        return true
    if (avg < 0.42)
        return false
    return ""
}

; Copies a screen rectangle into a 32-bit top-down pixel buffer (BGRA).
CaptureScreen(x, y, w, h) {
    hdcScreen := DllCall("GetDC", "ptr", 0, "ptr")
    hdcMem := DllCall("CreateCompatibleDC", "ptr", hdcScreen, "ptr")
    hbm := DllCall("CreateCompatibleBitmap", "ptr", hdcScreen, "int", w, "int", h, "ptr")
    old := DllCall("SelectObject", "ptr", hdcMem, "ptr", hbm, "ptr")
    DllCall("BitBlt", "ptr", hdcMem, "int", 0, "int", 0, "int", w, "int", h
        , "ptr", hdcScreen, "int", x, "int", y, "uint", 0x00CC0020)
    DllCall("SelectObject", "ptr", hdcMem, "ptr", old, "ptr")

    bi := Buffer(40, 0)
    NumPut("UInt", 40, bi, 0)
    NumPut("Int", w, bi, 4)
    NumPut("Int", -h, bi, 8)      ; negative height = top-down rows
    NumPut("UShort", 1, bi, 12)
    NumPut("UShort", 32, bi, 14)
    pixels := Buffer(w * h * 4)
    DllCall("GetDIBits", "ptr", hdcMem, "ptr", hbm, "uint", 0, "uint", h
        , "ptr", pixels, "ptr", bi, "uint", 0)

    DllCall("DeleteObject", "ptr", hbm)
    DllCall("DeleteDC", "ptr", hdcMem)
    DllCall("ReleaseDC", "ptr", 0, "ptr", hdcScreen)
    return pixels
}

#HotIf WinActive(game)
F1:: {
    global autoDetect
    autoDetect := !autoDetect
    ToolTip(autoDetect ? "Auto-detect ON" : "Auto-detect OFF (guitar keys)")
    SetTimer(() => ToolTip(), -1500)
}
F2:: {
    ToolTip((drumMode ? "Drum keys" : "Guitar keys") "`n" lastInfo)
    SetTimer(() => ToolTip(), -4000)
}

#HotIf drumMode && WinActive(game)
a::s
s::j
j::k
k::a
#HotIf
