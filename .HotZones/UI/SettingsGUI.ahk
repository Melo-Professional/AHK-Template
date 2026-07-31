#Requires AutoHotkey v2.0

; UI\SettingsGUI.ahk
; Main configuration window for HotZones

class SettingsGUI {
    static hGui := 0

    static Show() {
        if this.hGui {
            WinActivate("ahk_id " this.hGui)
            return
        }

        guiObj := Gui("+Resize -MaximizeBox", "HotZones Settings")
        this.hGui := guiObj.Hwnd
        guiObj.OnEvent("Close", ObjBindMethod(this, "OnClose"))

        ; Apply Dark Mode if system is using it (Simple Implementation)
        this.ApplyDarkMode(this.hGui)

        guiObj.SetFont("s10", "Segoe UI")

        guiObj.Add("GroupBox", "w300 h120", "General Settings")
        
        chkSnap := guiObj.Add("CheckBox", "xp+15 yp+25", "Hold Shift to activate zones while dragging")
        chkSnap.Value := Config.Settings["SnapOnShift"]
        chkSnap.OnEvent("Click", (*) => this.UpdateConfig("SnapOnShift", chkSnap.Value))

        chkOverride := guiObj.Add("CheckBox", "xp y+10", "Override Windows Snap hotkeys (Win+Arrows)")
        chkOverride.Value := Config.Settings["OverrideSnap"]
        chkOverride.OnEvent("Click", (*) => this.UpdateConfig("OverrideSnap", chkOverride.Value))

        btnEditor := guiObj.Add("Button", "x15 y+40 w280 h35", "Open Grid Layout Editor")
        btnEditor.OnEvent("Click", (*) => GridEditor.Show())

        guiObj.Show("AutoSize Center")
    }

    static UpdateConfig(key, value) {
        Config.Settings[key] := value
        Config.Save()
    }

    static OnClose(*) {
        this.hGui := 0
    }

    static ApplyDarkMode(hwnd) {
        ; Check Windows registry for AppsUseLightTheme
        try {
            lightTheme := RegRead("HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize", "AppsUseLightTheme")
            isDarkMode := (lightTheme == 0)
        } catch {
            isDarkMode := false
        }
        
        if (isDarkMode) {
            ; 20 = DWMWA_USE_IMMERSIVE_DARK_MODE in Win 11
            ; 19 = DWMWA_USE_IMMERSIVE_DARK_MODE in older Win 10
            DllCall("dwmapi\DwmSetWindowAttribute", "Ptr", hwnd, "Int", 20, "Int*", true, "Int", 4)
            DllCall("dwmapi\DwmSetWindowAttribute", "Ptr", hwnd, "Int", 19, "Int*", true, "Int", 4)
            
            ; We can also change background color
            GuiFromHwnd(hwnd).BackColor := "1E1E1E"
        }
    }
}
