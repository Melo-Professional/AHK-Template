;@region Setup
;@region Description
/************************************************************************
 * @description This is a template as a starting point for your AutoHotKey projects.
 * @author Melo (melo@meloprofessional.com)
 * @date 2026/05/27
 * @releasedate 2026/04/24
 * @version 2.8.2.0
 ***********************************************************************/

AppName := "Template"
AppVersion := "2.8.2.0"
AppDescription := "This is a template as a starting point for your AutoHotKey projects."

;@endregion

;@region Directives
#Requires AutoHotkey v2.0
#SingleInstance Force
Persistent()
SetWorkingDir(A_ScriptDir)
A_AllowMainWindow := 0
A_IconHidden := true
; --- Optimization Settings ---
;ProcessSetPriority("High")
;ListLines(False)
;KeyHistory(0)
;A_MaxHotkeysPerInterval := 5000
;A_HotkeyInterval := 1000
;@endregion

;@region Includes
#Include <_CompilerDirectives>
#Include <_Config&Vars>
#Include <_SaveSettings>
#Include <_Theme>
#Include <_MsgBoxCustom>
#Include <_OSDCustom>
;#Include <_Color_Picker_Dialog>
#Include <_SplashScreen>
#Include <_About>
#Include <_Help>
#Include <_Menu>
;@endregion

;@region Startup
; SPLASHSCREEN
;SplashScreen(false)
SplashScreen()
; TRAY ICON + MENU
StartMenu()
;@endregion
;@endregion