;@region Setup
;@region Description
/************************************************************************
 * @description This is a template as a starting point for your AutoHotKey projects.
 * @author Melo (melo@meloprofessional.com)
 * @date 2026/08/20
 * @releasedate 2026/04/24
 * @version 3.5.3.111
 ***********************************************************************/

AppName := "Template"
;@Ahk2Exe-Let U_AppName = %A_PriorLine%
AppVersion := "3.5.3.111"
;@Ahk2Exe-Let U_Version = %A_PriorLine%
AppDescription := "This is a template as a starting point for your AutoHotKey projects. This is a template as a starting point for your AutoHotKey projects."
;@endregion

_bkpMode := "AppVersionAndMinutes"
;_bkpMinutesThreshold := 1

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
ListLines(False)
KeyHistory(0)
;A_MaxHotkeysPerInterval := 5000
;A_HotkeyInterval := 1000
;@endregion

;@region Includes
#Include *i <_CompilerDirectives>
#Include *i <_Backup>
#Include *i <_SaveSettings>
#Include *i <_Config&Vars>
#Include *i <_HelperFuncs>
;#Include *i <_MessageManager>
;#Include *i <_TrayIconHandler>
#Include *i <_Theme>
;#Include *i <_FrostedTheme>
#Include *i <_TitleBar>
;#Include *i <_GuiTracker>
;#Include *i <_ModernSlider>
;#Include *i <_Color_Picker_Dialog>
;#Include *i <_HotkeysRecorder>
;#Include *i <_ODColors>
;#Include *i <_OSDCustom>
;#Include *i <_AutoUpdater>
#Include *i <_SplashScreen>
;#Include *i <_SplashOSD>
#Include *i <_About>
#Include *i <_Help>
#Include *i <_Menu>

#Include *i <Vars_Custom>
#Include *i <Menu_Custom>
;@endregion


;@region Startup
if !A_Args.Length {
	if IsSet(SplashScreen) {
	    SplashScreen()
	} else if isSet(SplashScreenOSD) {
		SplashScreenOSD()
	}
}

IsSet(StartMenu) ? StartMenu() : 0
IsSet(Menu_Custom) ? Menu_Custom() : 0
IsSet(StartAutoUpdater) ? StartAutoUpdater() : 0
;@endregion
;@endregion

;@region Main

;@region Hotkeys
#HotIf !A_IsCompiled
^p::IsSet(ReloadClean) ? ReloadClean() : Reload()
#HotIf
;@endregion



;@endregion
IsSet(CheckReloadArgs) ? CheckReloadArgs() : 0

;throw Error('Message', A_ThisFunc, )
;a := "test"
;OutputDebug(a) ; debug tab
/* 
MyTray := TrayIconHandler()

MyTray.OnMiddleClick := (*) => ToolTip("Middle Click!")
MyTray.OnMiddleDoubleClick := (*) => ToolTip("Double Middle Click!")
 */

/* 
OnMessage(0x209, TrayMiddleDoubleClick)

TrayMiddleDoubleClick(wParam, lParam, msg, hwnd) {
    ToolTip("Double Middle Click!")
}

 */

A_TrayMenu.Delete()
A_TrayMenu.ClickCount := 2


/* 
OnMessage(0x404, TrayMessage)
TrayMessage(wParam, lParam, msg, hwnd) {

;	if lParam == 512 {
;	    ToolTip("Tray event: Move " lParam)

	if lParam == 513 {
	    ToolTip("Tray event: Left Click Pressed " lParam)

	} else if lParam == 514 {
	    ToolTip("Tray event: Left Click Released " lParam)

	} else if lParam == 515 {
	    ToolTip("Tray event: Double Left Click " lParam)

	} else if lParam == 516 {
	    ToolTip("Tray event: Right Click Pressed " lParam)

	} else if lParam == 517 {
	    ToolTip("Tray event: Right Click Released " lParam)

	} else if lParam == 518 {
	    ToolTip("Tray event: Double Right Click " lParam)

	} else if lParam == 519 {
	    ToolTip("Tray event: Middle Click Pressed " lParam)

	} else if lParam == 520 {
	    ToolTip("Tray event: Middle Click Released " lParam)

	} else if lParam == 521 {
	    ToolTip("Tray event: Double Middle Click " lParam)

	} else if lParam == 523 {
	    ToolTip("Tray event: XButton Pressed " lParam)

	} else if lParam == 524 {
	    ToolTip("Tray event: XButton Released " lParam)
	}
}
 */



OnMessage(0x404, TrayMessage)

TrayMessage(wParam, lParam, msg, hwnd) {
    switch lParam {
        case 0x201:
            ToolTip("Left Down")

        case 0x202:
            ToolTip("Left Up")

        case 0x203:
            ToolTip("Left Double Click")

        case 0x204:
            ToolTip("Right Down")

        case 0x205:
            ToolTip("Right Up")

        case 0x206:
            ToolTip("Right Double Click")

        case 0x207:
            ToolTip("Middle Down")

        case 0x208:
            ToolTip("Middle Up")

        case 0x209:
            ToolTip("Middle Double Click")
    }
}

