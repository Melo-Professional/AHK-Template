/************************************************************************
 * @description Config&Vars
 * @author Melo (melo@meloprofessional.com)
 * @date 2026/05/22
 * @version 1.0.0
 ***********************************************************************/

;@region Configuration
NameNoSpace := StrReplace(AppName, " ")
Global App := {
    Name:                       AppName,
    NameNoSpace:                NameNoSpace,
    NameCutted:                 AppName,
    Description:                AppDescription,
    Icon:                       A_IsCompiled ? A_ScriptFullPath : A_ScriptDir "\" NameNoSpace ".ico",
    IconPaused:                 A_IsCompiled ? A_ScriptFullPath : A_ScriptDir "\" NameNoSpace "_Pause.ico",
    Copyright:                  "Developed by Melo`nmelo@meloprofessional.com`n©Melo. All rights reserved.",
    Version:                    AppVersion
}

Global Settings := {
    ; General GUI
    SplashScreen:               "Banner",                            ; "Icon" / "Banner" / "Disabled"
    SplashSreenList:           ["Disabled", "Icon", "Banner"],      ; "Icon" / "Banner" / "Disabled"
    DesiredTheme:               "Auto",                              ; "Auto" / "Light" / "Dark"
    ThemeList:                  ["Light", "Dark", "Auto"],           ; "Auto" / "Light" / "Dark"
    GuiFontSizeSmall:           8,
    GuiFontSizeMedium:          9,
    GuiFontSizeBig:             10,
    GuiFontSizeExtraBig:        14,
    GuiFontName:                "Segoe UI",
    GuiSplashTimer:             1800,

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

Global OSDSettings := {
    UseOSD:                     true,
    Width:                      200,        ; valor correto
    FontSize:                   9,
    TimeOut:                    1800,       ; duration of OSD in milliseconds
    Speed:                      4,          ; Pixels moved per tick (Increase for faster animations)
    Position:                   "Bottom",   ; Bottom / Top
    EdgeDistance:               60,         ; OSD distance from screen edge
    SlideDistance:              23,          ; Set your preferred slide distance here
    FontName:                   "Segoe UI",
    FontWeight:                 1000,
    MarginX:                    16,
    MarginY:                    12,
    Opacity:                    255,
    ColoredBorder:              true,
    RoundedCorners:             18,
    ProgressMaxValue:           100,

    ; Theme
    Theme:                      "Auto", ; "Light" / "Dark" / "Auto"

    ; lightmode
    TextDefaultLight:           "5a5555",
    BgColorLight:               "F5F9FB",
    BorderColorLight:           "ffffff",
    ProgressFgColorLight:       "0067C0",
    ProgressBgColorLight:       "EDF1F2", ; HEX or "transparent"
    ProgressOver100Light:       "FF5555",

    ; darkmode
    TextDefaultDark:            "d8d8d8",
    BgColorDark:                "272525",
    BorderColorDark:            "272525",
    ProgressFgColorDark:        "4CC2FF",
    ProgressBgColorDark:        "333333", ; HEX or "transparent"
    ProgressOver100Dark:        "FF5555",

}


;SaveToINI := [""] ; what to save to INI file
;SaveToINI := ["Settings.DesiredTheme"] ; what to save to INI file
SaveToINI := ["Settings.DesiredTheme", "Settings.SplashScreen"] ; what to save to INI file
CurrentActualTheme := "Dark"
ResetOSDSettings    := OSDSettings.Clone()
ResetSettings       := Settings.Clone()
;@endregion