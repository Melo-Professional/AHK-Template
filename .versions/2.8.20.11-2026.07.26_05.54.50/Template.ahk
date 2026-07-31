;@region Setup
;@region Description
/************************************************************************
 * @description This is a template as a starting point for your AutoHotKey projects.
 * @author Melo (melo@meloprofessional.com)
 * @date 2026/07/22
 * @releasedate 2026/04/24
 * @version 2.8.20.11
 ***********************************************************************/

AppName := "Template"
;@Ahk2Exe-Let U_AppName = %A_PriorLine%
AppVersion := "2.8.20.11"
;@Ahk2Exe-Let U_Version = %A_PriorLine%
AppDescription := "This is a template as a starting point for your AutoHotKey projects. This is a template as a starting point for your AutoHotKey projects."
;@endregion

backupMode := "AppVersionAndMinutes"

;@region Directives
#Requires AutoHotkey v2.0
#SingleInstance Force
Persistent()
SetWorkingDir(A_ScriptDir)
A_AllowMainWindow := 0
A_IconHidden := true
A_MenuMaskKey := "vkFF"
; --- Optimization Settings ---
;ProcessSetPriority("High")
;ListLines(False)
;KeyHistory(0)
;A_MaxHotkeysPerInterval := 5000
;A_HotkeyInterval := 1000
;@endregion

;@region Includes
#Include *i <_CompilerDirectives>
#Include *i <_Backup>
#Include *i <_Config&Vars>
#Include *i <_MsgBoxCustom>
#Include *i <_SaveSettings>
;#Include *i <_MessageManager>
#Include *i <_Theme>
#Include *i <_FrostedTheme>
#Include *i <_TitleBar>
;#Include *i <_ModernSlider>
;#Include *i <_Color_Picker_Dialog>
;#Include *i <_ReloadWithArgs>
;#Include *i <_HotkeysRecorder>
;#Include *i <_ODColors>
#Include *i <_OSDCustom>
#Include *i <_SplashScreen>
#Include *i <_About>
#Include *i <_Help>
#Include *i <_Menu>

#Include *i <Vars_Custom>
#Include *i <Menu_Custom>
;@endregion

;@region Startup
; SPLASHSCREEN
if (A_Args.Length == 0) && IsSet(SplashScreen){
    SplashScreen()
}

; TRAY ICON + MENU
StartMenu()
Menu_Custom()

;@endregion
;@endregion

;@region Main

;@endregion
;throw Error('Message', A_ThisFunc, )
;a := "test"
;OutputDebug(a) ; debug tab

#HotIf !A_ComputerName
^p::ReloadClean()
#HotIf

