;@region Setup
;@region Description
/************************************************************************
 * @description This is a template as a starting point for your AutoHotKey projects.
 * @author Melo (melo@meloprofessional.com)
 * @date 2026/05/14
 * @releasedate 2026/04/24
 * @version 2.1.0
 ***********************************************************************/
;@endregion

;@region Compilation
;@Ahk2Exe-SetName Template
;@Ahk2Exe-SetFileVersion 2.1.0
;@Ahk2Exe-SetCopyright © Melo. All rights reserved.
;@Ahk2Exe-SetProductName Template
;@Ahk2Exe-SetInternalName Template
;@Ahk2Exe-SetCompanyName Melo Professional
;@Ahk2Exe-ExeName Template
;@Ahk2Exe-SetMainIcon Template.ico
;@endregion

;@region Directives
#Requires AutoHotkey v2.0
#SingleInstance Force
Persistent()
SetWorkingDir(A_ScriptDir)
A_IconHidden := true
;@endregion

;@region Configuration
App := {
    Name:                   "Template",
    Description:            "This is a template as a starting point for your AutoHotKey projects.",
    Icon:                   A_IsCompiled ? A_ScriptFullPath : (A_ScriptDir "\Template.ico"),
    Copyright:              "Developed by Melo`nmelo@meloprofessional.com`n©Melo. All rights reserved.",
    Version:                "2.1.0"
}

Settings := {
    ; General GUI
    DesiredTheme:               "Auto",         ; "Auto" / "Light" / "Dark"
    GuiFontSizeSmall:           8,
    GuiFontSizeMedium:          9,
    GuiFontSizeBig:             10,
    GuiFontSizeExtraBig:        14,
    GuiFontName:                "Segoe UI",
    GuiSplashTimer:             1200,

; GUI Colors
    Theme: {
        Dark: {
            Bg:                 "202020", 
            TextDefault:        "CCCCCC",
            TextStrong:         "FFFFFF",
            TextSmooth:         "888888" 
        },
        Light: {
            Bg:                 "F0F0F0", 
            TextDefault:        "222222",
            TextStrong:         "000000",
            TextSmooth:         "666666" 
        }
    }
}
;@endregion

;@region Vars
; CUSTOM VARIABLES
Debug                       := false
A_ScriptName                := App.Name

global OSD := {
    ; Colors (Hex Format)
    Color: "FFFFFF",
    BgColor:                "121212",
    TextDefault:            "d8d8d8",
    TextSuccess:            "55FF55",
    TextWarning:            "FFFF55",
    TextAlert:              "FF5555",
    
    ; OSD Visuals
    OsdFontSize:            13,
    OsdFontWeight:          700,
    OsdMarginX:             40,
    OsdMarginY:             20,
    OsdWidth:               250,
    OsdOpacity:             210,
    OsdRounding:            40,
    OsdBottomGap:           120,
    
    ; General GUI
    GuiFontSize:            10,
    GuiFontName:            "Segoe UI"
}
;@endregion

;@region Includes
#Include <T-SettingsManager>
#Include <T-Theme>
#Include <T-GuiMsgBoxCustom>
#Include <T-GuiSplashScreen>
#Include <T-GuiSplashScreenIcon>
#Include <T-GuiAbout>
#Include <T-GuiHelp>
#Include <T-Menu>
;@endregion

;@region Startup
; SPLASHSCREEN
;SplashScreen.Show()
;SplashScreen.Destroy()
SplashIcon.Show()

;@region Settings File
INIManager.Register("Settings", "DesiredTheme") ; What settings to save to INI file
; INIManager.Register("Settings", "Theme.Dark.Bg")
; INIManager.RegisterMultiple("Settings", "DesiredTheme", "GuiFontName", "GuiSplashTimer")

LoadINI()   ; Load user settings from INI file
;SaveINI()  ; use this whenever you need to save Settings to INI file
;@endregion

; THEME
ApplyTheme()

; TRAY ICON + MENU
StartMenu()
;@endregion

SplashIcon.Destroy()
;@endregion

;@region Hotkeys
^+p::Reload()
;@endregion

;@region Helpers Functions
;@endregion

;@region Main
;@endregion

