;@region Setup
;@region Description
/************************************************************************
 * @description This is a template as a starting point for your AutoHotKey projects.
 * @author Melo (melo@meloprofessional.com)
 * @date 2026/05/21
 * @releasedate 2026/04/24
 * @version 2.4.0.0
 ***********************************************************************/

AppName := "Template"
;@Ahk2Exe-Let U_LineAppName = %A_PriorLine%

AppVersion := "2.4.0.0"
;@Ahk2Exe-Let U_LineVersion = %A_PriorLine%

AppDescription := "This is a template as a starting point for your AutoHotKey projects."
;@endregion

;@region Directives
#Requires AutoHotkey v2.0
#SingleInstance Force
Persistent()
SetWorkingDir(A_ScriptDir)
A_IconHidden := true
; --- Optimization Settings ---
;ProcessSetPriority("High")
ListLines(False)
KeyHistory(0)
A_MaxHotkeysPerInterval := 5000
A_HotkeyInterval := 1000
;@endregion

;@region Includes
#Include <CompilerDirectives>
#Include <Config&Vars>
#Include <SaveSettings>
#Include <Theme>
#Include <MsgBoxCustom>
#Include <SplashScreen>
#Include <SplashIcon>
#Include <About>
#Include <Help>
#Include <Menu>
;@endregion

;@region Startup
; SPLASHSCREEN
switch Settings.SplashScreen {
    case "Icon": SplashIcon.Show()
    case "Banner": Splash.Show()
}

; TRAY ICON + MENU
StartMenu()

switch Settings.SplashScreen {
    case "Icon": SplashIcon.Destroy()
    case "Banner": Splash.Destroy()
}
;@endregion
;@endregion

;@region Main
;@endregion

;@region Hotkeys
^+p::Reload()
;@endregion

;@region Helpers Functions
;@endregion



