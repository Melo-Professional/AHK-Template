;@region Configuration
NameNoSpace := StrReplace(AppName, " ")
Global App := {
    Name:                       AppName,
    NameNoSpace:                NameNoSpace,
    Description:                AppDescription,
    Icon:                       A_IsCompiled ? A_ScriptFullPath : A_ScriptDir "\" NameNoSpace ".ico",
    IconPaused:                 A_IsCompiled ? A_ScriptFullPath : A_ScriptDir "\" NameNoSpace "_Pause.ico",
    Copyright:                  "Developed by Melo`nmelo@meloprofessional.com`n©Melo. All rights reserved.",
    Version:                    AppVersion
}

Global Settings := {
    ; General GUI
    SplashScreen:               "Banner",       ; "Icon" / "Banner" / "Disabled"
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
;SaveToINI := [""] ; what to save to INI file
SaveToINI := ["Settings.DesiredTheme"] ; what to save to INI file
CurrentActualTheme := "Dark"

OSDSettings := {
    ; Colors (Hex Format)
    Color:                  "FFFFFF",
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

;SaveToINI := [""] ; what to save to INI file
SaveToINI := ["Settings.DesiredTheme", "Settings.SplashScreen"]

ResetOSDSettings    := OSDSettings.Clone()
ResetSettings       := Settings.Clone()
;@endregion