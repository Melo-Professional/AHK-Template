;@region Setup
;@region Description
/************************************************************************
 * @description This is a template as a starting point for your AutoHotKey projects.
 * @author Melo (melo@meloprofessional.com)
 * @date 2026/08/10
 * @releasedate 2026/04/24
 * @version 3.2.0.0
 ***********************************************************************/

AppName := "Template"
;@Ahk2Exe-Let U_AppName = %A_PriorLine%
AppVersion := "3.2.0.0"
;@Ahk2Exe-Let U_Version = %A_PriorLine%
AppDescription := "This is a template as a starting point for your AutoHotKey projects. This is a template as a starting point for your AutoHotKey projects."
;@endregion

_bkpMode := "AppVersionAndMinutes"

;@region Directives
#Requires AutoHotkey v2.0
#SingleInstance Force
Persistent()
SetWorkingDir(A_ScriptDir)
OnError(OnErrorCustom)
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
#Include *i <_HelperFuncs>
#Include *i <_Config&Vars>
;#Include *i <_MsgBoxCustom>
#Include *i <_SaveSettings>
;#Include *i <_MessageManager>
;#Include *i <_TrayIconHandler>
#Include *i <_Theme>
#Include *i <_FrostedTheme>
#Include *i <_TitleBar>
;#Include *i <_ModernSlider>
;#Include *i <_Color_Picker_Dialog>


;#Include *i <_ReloadWithArgs>

;#Include *i <_HotkeysRecorder>
;#Include *i <_ODColors>
#Include *i <_OSDCustom>
#Include *i <_AutoUpdater>
#Include *i <_SplashScreen>
#Include *i <_About>
#Include *i <_Help>
#Include *i <_Menu>

#Include *i <Vars_Custom>
#Include *i <Menu_Custom>
;@endregion

;@region Startup
; SPLASHSCREEN
if !A_Args.Length && IsSet(SplashScreen){
    SplashScreen()
}

; TRAY ICON + MENU
StartMenu()
Menu_Custom()
if IsSet(StartAutoUpdater) {
	%"StartAutoUpdater"%()
}

;@endregion
;@endregion

;@region Main

;@endregion
;throw Error('Message', A_ThisFunc, )
;a := "test"
;OutputDebug(a) ; debug tab

#HotIf !A_IsCompiled
^p::ReloadClean()
#HotIf



abc(par1 := 0, par2 := 0, par3 := 0) {
	MsgBox(par1 par2 par3)
}

abcd(par1 := 0, par2 := 0, par3 := 0) {
	MsgBox(par1 par2 par3)
}




; CHECK RELOAD ARGUMENTS
; CHECK RELOAD ARGUMENTS
/* if A_Args.Length && !RegExMatch(A_Args[1], "i)^--signal-update-success=") {
    targetFuncName := A_Args[1]
    try {
        fnParams := A_Args.Clone()
        fnParams.RemoveAt(1)
        for index, param in fnParams {
            if (param = "<unset>") {
                fnParams.Delete(index)
            }
        }
        %targetFuncName%(fnParams*)
    } catch Any as e {
		throw e
    }
}
 */

CheckReloadArgs()

MsgBox(1)
ReloadWithArgs("abcdd")

MyGui := Gui("AlwaysOnTop", A_ScriptName)
MyGui.SetFont("s" DPIScale(10))
MyGui.Add("Text", "w" DPIScale(2000), "This is a text")
MyGui.Show("w" DPIScale(600) " h" DPIScale(200))