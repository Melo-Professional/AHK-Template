;@region Description
/************************************************************************
 * @description To block / unblock network connections from programs using builtin Windows firewall
 * @author Melo (melo@meloprofessional.com)
 * @date 2026/05/06
 * @releasedate 2026/04/24
 * @version 1.00
 ***********************************************************************/
;@endregion

#Requires AutoHotkey v2.0
#SingleInstance Force
Persistent()
SetWorkingDir(A_ScriptDir)
A_IconHidden := true

#Include <T-Dark>
#Include <T-GuiMsgBoxCustom>
#Include <T-GuiSplashScreen>
#Include <T-GuiAbout>
#Include <T-GuiHelp>
#Include <T-Menu>
#Include <T-SettingsFuncs>


;@region Configuration
App := {
    Name:                   "Template",
    Description:            "A utility that programmatically creates and removes Windows Firewall rules to block or restore network access for selected applications.",
    Icon:                   (A_ScriptDir "\Template.ico"),
    Copyright:              "Developed by Melo`nmelo@meloprofessional.com`n©Melo. All rights reserved.",
    Version:                1.00
}

Settings := {
    ; General GUI
    GuiFontSizeSmall:       8,
    GuiFontSizeMedium:      9,
    GuiFontSizeBig:         10,
    GuiFontSizeExtraBig:    14,
    GuiFontName:            "Segoe UI"
}
;@endregion

;@region Vars
; CUSTOM VARIABLES
Debug                       := false
A_ScriptName                := App.Name

global OSDSettings := {
    ; Colors (Hex Format)
    BgColor:      "121212",
    TextDefault:  "d8d8d8",
    TextSuccess:  "55FF55",
    TextWarning:  "FFFF55",
    TextAlert:    "FF5555",
    
    ; OSD Visuals
    OsdFontSize:  13,
    OsdFontWeight: 700,
    OsdMarginX:   40,
    OsdMarginY:   20,
    OsdWidth:     250,
    OsdOpacity:   210,
    OsdRounding:  40,
    OsdBottomGap: 120,
    
    ; General GUI
    GuiFontSize:  10,
    GuiFontName:  "Segoe UI"
}
;@endregion

;@region Startup
; THEME
LightDarkColorMode()
; SPLASHSCREEN
SplashScreen()

; TRAY ICON + MENU
StartMenu()

;@endregion

;@region Helpers Functions
; 0=Default, 1=AllowDark, 2=ForceDark, 3=ForceLight, 4=Max
LightDarkColorMode(colorMode := 1) {
    try {
        static uxtheme := DllCall("GetModuleHandle", "str", "uxtheme", "ptr")
        static SetPreferredAppMode := DllCall("GetProcAddress", "ptr", uxtheme, "ptr", 135, "ptr")
        static FlushMenuThemes := DllCall("GetProcAddress", "ptr", uxtheme, "ptr", 136, "ptr")
        DllCall(SetPreferredAppMode, "int", colorMode)
        DllCall(FlushMenuThemes)
    }
}
;@endregion

;@region Main
;@endregion

;@region Hotkeys
;@endregion
