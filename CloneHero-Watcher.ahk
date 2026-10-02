#Requires AutoHotkey v2.0
#SingleInstance Force
#NoTrayIcon

; Starts CloneHero-DrumKeys.ahk when Clone Hero opens and closes it when the game exits.
; Runs from the Windows Startup folder.

drumScript := A_ScriptDir "\CloneHero-DrumKeys.ahk"
DetectHiddenWindows(true)
SetTitleMatchMode(2)

Loop {
    while !ProcessExist("Clone Hero.exe")
        Sleep(2000)
    Run('"' A_AhkPath '" "' drumScript '"')
    while ProcessExist("Clone Hero.exe")
        Sleep(2000)
    ; Close by script name so a reloaded drum script is closed too.
    while WinExist("CloneHero-DrumKeys.ahk ahk_class AutoHotkey")
        WinClose()
}
