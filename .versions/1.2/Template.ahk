;@region Description
/************************************************************************
 * @description This is a template as a starting point for your AutoHotKey projects.
 * @author Melo (melo@meloprofessional.com)
 * @date 2026/05/09
 * @releasedate 2026/04/24
 * @version 1.2
 ***********************************************************************/
;@endregion

#Requires AutoHotkey v2.0
#SingleInstance Force
Persistent()
SetWorkingDir(A_ScriptDir)
A_IconHidden := true

;@region Includes
#Include <T-Dark>
#Include <T-GuiMsgBoxCustom>
#Include <T-GuiSplashScreen>
#Include <T-GuiSplashScreenIcon>
#Include <T-GuiAbout>
#Include <T-GuiHelp>
#Include <T-Menu>
#Include <T-SettingsFuncs>
;@endregion

;@region Configuration
App := {
    Name:                   "Template",
    Description:            "This is a template as a starting point for your AutoHotKey projects.",
    Icon:                   (A_ScriptDir "\Template.ico"),
    Copyright:              "Developed by Melo`nmelo@meloprofessional.com`n©Melo. All rights reserved.",
    Version:                "1.2"
}

Settings := {
    ; General GUI
    GuiFontSizeSmall:       8,
    GuiFontSizeMedium:      9,
    GuiFontSizeBig:         10,
    GuiFontSizeExtraBig:    14,
    GuiFontName:            "Segoe UI",
    GuiSplashTimer:         800
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
;SplashScreen()
SplashScreenIcon()

; TRAY ICON + MENU
StartMenu()
;@endregion

;@region Helpers Functions
;@endregion

;@region Hotkeys
^+p::Reload()
;@endregion

;@region Main
;@endregion

