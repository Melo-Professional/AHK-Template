; CUSTOM VARIABLES

Global General := {
    BTDetect:                   true,
    WheelSpeed:                 10,
    gainStepsMin:               2,
    gainStepsMax:               20
}

Global OSDSettings := {
    DWMMinVer:                  "10.0.22000",
    DWMCompatible:              false,
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
    RoundedCorners:             10,
    ProgressMaxValue:           100,

    ; Theme
    Theme:                      "Light", ; "Light" / "Dark" / "Auto"

    ; lightmode
    TextDefaultLight:           "5a5555",
    BgColorLight:               "F5F9FB",
    BgColorLight:               "F3F3F3",
    BorderColorLight:           "ffffff",
    ProgressFgColorLight:       "0067C0",
    ProgressFgColorLight:       "0078D7",
    ProgressFgColorLight:       "005A9E",
    ProgressBgColorLight:       "EDF1F2", ; HEX or "transparent"
    ProgressBgColorLight:       "E5E5E5", ; HEX or "transparent"
    ProgressOver100Light:       "FF5555",

    ; darkmode
    TextDefaultDark:            "d8d8d8",
    BgColorDark:                "272525",
    BgColorDark:                "1E1E1E",
    BorderColorDark:            "272525",
    ProgressFgColorDark:        "4CC2FF",
    ProgressFgColorDark:        "0078D7",
    ProgressBgColorDark:        "333333", ; HEX or "transparent"
    ProgressOver100Dark:        "FF5555",

}


;SaveToINI := [""] ; what to save to INI file
;SaveToINI := ["Settings.DesiredTheme", "Settings.SplashScreen"] ; what to save to INI file
;ResetSettings       := Settings.Clone()
;ResetGeneral        := General.Clone()
;ResetOSDSettings    := OSDSettings.Clone()
RegisterArrayItems(SaveToINI)
LoadINI()

;App.NameCutted := "Template`nBigName"
;Debug := true