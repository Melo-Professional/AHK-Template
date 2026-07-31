;@region Setup
;@region Description
/************************************************************************
 * @description This is a template as a starting point for your AutoHotKey projects.
 * @author Melo (melo@meloprofessional.com)
 * @date 2026/05/23
 * @releasedate 2026/04/24
 * @version 2.6.0.0
 ***********************************************************************/

AppName := "Template"
;@Ahk2Exe-Let U_LineAppName = %A_PriorLine%
AppVersion := "2.5.0.0"
;@Ahk2Exe-Let U_LineVersion = %A_PriorLine%
AppDescription := "This is a template as a starting point for your AutoHotKey projects."
;@endregion

;@region Directives
#Requires AutoHotkey v2.0
#SingleInstance Force
Persistent()
SetWorkingDir(A_ScriptDir)
A_AllowMainWindow := 0
A_IconHidden := true
;OnError(OnErrorCustom)
; --- Optimization Settings ---
;ProcessSetPriority("High")
;ListLines(False)
;KeyHistory(0)
;A_MaxHotkeysPerInterval := 5000
;A_HotkeyInterval := 1000
;@endregion

;@region Includes
#Include <CompilerDirectives>
#Include <Config&Vars>
#Include <SaveSettings>
#Include <Theme>
#Include <MsgBoxCustom>
#Include <SplashScreen>
#Include <About>
#Include <Help>
#Include <Menu>
;@endregion

;@region Startup
; SPLASHSCREEN
SplashScreen(false)
; TRAY ICON + MENU
StartMenu()
SplashScreen()
;@endregion
;@endregion

;@region Main
throw Error('Message', A_ThisFunc, "ExtraInfo")

;MsgBoxCustom(A_LineFile)
;@endregion

;@region Hotkeys
^+p::Reload()
;@endregion

;@region Helpers Functions
;@endregion