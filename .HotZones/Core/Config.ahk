#Requires AutoHotkey v2.0

; Core\Config.ahk
; Handles reading and writing user settings and layout profiles to an INI file

class Config {
    static IniFile := A_ScriptDir . "\HotZones.ini"

    static Settings := Map(
        "SnapOnShift", 1,
        "OverrideSnap", 1,
        "Theme", "Auto"
    )

    static Profiles := Map()
    static CurrentProfile := "Default"

    static Load() {
        ; Load main settings
        if !FileExist(this.IniFile) {
            this.CreateDefaultIni()
        }

        try {
            this.Settings["SnapOnShift"] := IniRead(this.IniFile, "Settings", "SnapOnShift", 1)
            this.Settings["OverrideSnap"] := IniRead(this.IniFile, "Settings", "OverrideSnap", 1)
            this.Settings["Theme"] := IniRead(this.IniFile, "Settings", "Theme", "Auto")
            this.CurrentProfile := IniRead(this.IniFile, "Settings", "CurrentProfile", "Default")
        } catch {
            ; Defaults applied if missing
        }

        this.LoadProfiles()
    }

    static LoadProfiles() {
        this.Profiles.Clear()

        ; Find all profile sections
        try {
            sections := IniRead(this.IniFile)
            loop parse, sections, "`n", "`r" {
                if (InStr(A_LoopField, "Profile_") = 1) {
                    name := SubStr(A_LoopField, 9)
                    zonesRaw := IniRead(this.IniFile, A_LoopField, "Zones", "")

                    ; Parse the zones string back into an array of objects
                    ; Format: X:Y:W:H|X:Y:W:H...
                    zones := []
                    if (zonesRaw != "") {
                        loop parse, zonesRaw, "|" {
                            parts := StrSplit(A_LoopField, ":")
                            if (parts.Length == 4) {
                                zones.Push({ X: Number(parts[1]), Y: Number(parts[2]), W: Number(parts[3]), H: Number(parts[4]) })
                            }
                        }
                    }

                    this.Profiles[name] := { Zones: zones }
                }
            }
        }

        if !this.Profiles.Has("Default") {
            ; Default fallback to a 3x2 grid (6 zones) if the INI completely fails to load it
            this.Profiles["Default"] := { Zones: [
                ; Row 1 (Top Half - Y: 0.0, H: 0.5)
                { X: 0.0, Y: 0.0, W: 0.333, H: 0.5 }, { X: 0.333, Y: 0.0, W: 0.334, H: 0.5 }, { X: 0.667, Y: 0.0, W: 0.333, H: 0.5 },
                ; Row 2 (Bottom Half - Y: 0.5, H: 0.5)
                { X: 0.0, Y: 0.5, W: 0.333, H: 0.5 }, { X: 0.333, Y: 0.5, W: 0.334, H: 0.5 }, { X: 0.667, Y: 0.5, W: 0.333, H: 0.5 }
            ] }
        }
    }

    static Save() {
        IniWrite(this.Settings["SnapOnShift"], this.IniFile, "Settings", "SnapOnShift")
        IniWrite(this.Settings["OverrideSnap"], this.IniFile, "Settings", "OverrideSnap")
        IniWrite(this.Settings["Theme"], this.IniFile, "Settings", "Theme")
        IniWrite(this.CurrentProfile, this.IniFile, "Settings", "CurrentProfile")

        for name, profile in this.Profiles {
            sec := "Profile_" . name

            ; Serialize array to string
            zonesRaw := ""
            for i, z in profile.Zones {
                zonesRaw .= z.X ":" z.Y ":" z.W ":" z.H
                if (i < profile.Zones.Length)
                    zonesRaw .= "|"
            }

            IniWrite(zonesRaw, this.IniFile, sec, "Zones")
        }
    }

    static CreateDefaultIni() {
        IniWrite(1, this.IniFile, "Settings", "SnapOnShift")
        IniWrite(1, this.IniFile, "Settings", "OverrideSnap")
        IniWrite("Auto", this.IniFile, "Settings", "Theme")
        IniWrite("Default", this.IniFile, "Settings", "CurrentProfile")

        ; FIXED: Updated the default serialized string to represent the 6-zone 3x2 layout
        serialized3x2 := "0.0:0.0:0.333:0.5|0.333:0.0:0.334:0.5|0.667:0.0:0.333:0.5|"
            . "0.0:0.5:0.333:0.5|0.333:0.5:0.334:0.5|0.667:0.5:0.333:0.5"

        IniWrite(serialized3x2, this.IniFile, "Profile_Default", "Zones")
    }
}