;@region Setup
;@region Description
/************************************************************************
 * @description This is a template as a starting point for your AutoHotKey projects.
 * @author Melo (melo@meloprofessional.com)
 * @date 2026/06/05
 * @releasedate 2026/04/24
 * @version 2.8.10.0
 ***********************************************************************/

AppName := "Template"
;@Ahk2Exe-Let U_AppName = %A_PriorLine%
AppVersion := "2.8.10.0"
;@Ahk2Exe-Let U_Version = %A_PriorLine%
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
#Include *i <_CompilerDirectives>
#Include *i <_Config&Vars>
#Include *i <_MsgBoxCustom>
#Include *i <_SaveSettings>
#Include *i <_Theme>
;#Include *i <_OSDCustom>
;#Include *i <_Color_Picker_Dialog>
#Include *i <_SplashScreen>
#Include *i <_About>
;#Include *i <_Help>
#Include *i <_Menu>

#Include *i <Menu_Custom>
#Include *i <Vars_Custom>
;@endregion

;@region Startup
; SPLASHSCREEN
if IsSet(SplashScreen){
;    SplashScreen("Banner", false)       ; show banner and wait
;    sleep(5000)
;    SplashScreen()                      ; shows default / destroys
;    SplashScreen("Icon")                ; show icon and destroys
    SplashScreen("Banner")                ; show icon and destroys
}

; TRAY ICON + MENU
StartMenu()
;@endregion
;@endregion

;@region Main

^p::Reload()
;throw Error('Message', A_ThisFunc, )

;Menu_Custom()


;@endregion
;a := "test"
;OutputDebug(a) ; debug tab

;TrayTip("text", "titulo", "Mute " 36)
