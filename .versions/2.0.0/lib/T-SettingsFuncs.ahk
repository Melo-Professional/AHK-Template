#Requires AutoHotkey v2.0

SettingsLoadStartOnBoot() {
    try {
        currentvalue := RegRead("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run", App.Name)
        return (currentvalue = '"' A_AhkPath '"')
    } catch {
        return false
    }
}

SettingsSaveStartOnBoot(enable) {
    if enable {
        RegWrite('"' A_AhkPath '"', "REG_SZ", "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run", App.Name)
    } else {
        RegDelete("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run", App.Name)
    }
}