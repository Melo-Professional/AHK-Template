#Requires AutoHotkey v2.0
#SingleInstance Force

; HotZones - Main Entry Point
; An advanced window management tool inspired by FancyZones

; Define global constants
global AppName := "HotZones"
global Version := "1.0.0"
global ScriptDir := A_ScriptDir
global pToken := 0

; Set standard tray icon and menu
A_IconTip := AppName . " v" . Version
TraySetIcon("shell32.dll", 319) ; standard window icon

; Include core libraries
#Include lib\Gdip_Minimal.ahk

; Include internal modules
#Include Core\Config.ahk
#Include Core\Monitor.ahk
#Include Core\Window.ahk

#Include UI\Overlay.ahk
#Include UI\GridEditor.ahk
#Include UI\SettingsGUI.ahk

#Include Hooks\MouseDrag.ahk
#Include Hooks\Hotkeys.ahk

; Initialize application
Init()

Init() {
    ; Start GDI+
    global pToken
    pToken := Gdip_Startup()
    OnExit(ExitFunc)

    ; Load Configuration
    Config.Load()

    ; Setup tray menu
    A_TrayMenu.Delete()
    A_TrayMenu.Add("Settings", ShowSettings)
    A_TrayMenu.Add("Layout Editor", ShowEditor)
    A_TrayMenu.Add()
    A_TrayMenu.Add("Reload", (*) => Reload())
    A_TrayMenu.Add("Exit", AppExit)
    A_TrayMenu.Default := "Settings"

    ; Initialize Hooks
    MouseDragHook.Start()
    HotkeysHook.Start()
}

ShowSettings(*) {
    SettingsGUI.Show()
}

ShowEditor(*) {
    GridEditor.Show()
}

AppExit(*) {
    ExitApp()
}

ExitFunc(ExitReason, ExitCode) {
    global pToken
    if (pToken)
        Gdip_Shutdown(pToken)
    return 0
}