;@region Setup
;@region Description
/************************************************************************
 * @description This is a template as a starting point for your AutoHotKey projects.
 * @author Melo (melo@meloprofessional.com)
 * @date 2026/07/26
 * @releasedate 2026/04/24
 * @version 2.8.21.1
 ***********************************************************************/

AppName := "Template"
;@Ahk2Exe-Let U_AppName = %A_PriorLine%
AppVersion := "2.8.21.3"
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
#Include *i <more\_CompilerDirectives>
#Include *i <more\_Backup>
#Include *i <more\_Config&Vars>
#Include *i <more\_MsgBoxCustom>
#Include *i <more\_SaveSettings>
;#Include *more\i <_MessageManager>
#Include *i <more\_Theme>
#Include *i <more\_FrostedTheme>
#Include *i <more\_TitleBar>
;#Include *more\i <_ModernSlider>
;#Include *more\i <_Color_Picker_Dialog>
;#Include *more\i <_ReloadWithArgs>
;#Include *more\i <_HotkeysRecorder>
;#Include *more\i <_ODColors>
#Include *i <more\_OSDCustom>
#Include *i <more\_SplashScreen>
#Include *i <more\_About>
#Include *i <more\_Help>
#Include *i <more\_Menu>

#Include *i <more\Vars_Custom>
#Include *i <more\Menu_Custom>
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

