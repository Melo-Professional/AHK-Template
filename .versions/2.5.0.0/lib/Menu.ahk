/************************************************************************
 * @description Menu
 * @author Melo (melo@meloprofessional.com)
 * @date 2026/05/22
 * @version 1.4.0
 ***********************************************************************/

#Requires AutoHotkey v2.0

StartMenu() {
    A_IconHidden := true
    A_TrayMenu.Delete()
    A_IconTip               := App.Name
    TrayMenu                := A_TrayMenu
;    TrayMenu.ClickCount     := 1
    try TraySetIcon(App.Icon,, true)
    A_IconHidden := false
    OnMessage(0x404, TrayIconClick)  ; WM_TRAYICON = 0x404

    TrayMenu.Add(App.Name, (*) => TrayMenu.Show())
;    TrayMenu.Default            := App.Name
    TrayMenu.Disable(App.Name)
    TrayMenu.Add()

    MoreMenu := Menu()
    for theme in Settings.ThemeList {
        MoreMenu.Add( theme, ThemeHandler)
    }
;    MoreMenu.Add("Light", ThemeHandler)
;    MoreMenu.Add("Dark", ThemeHandler)
;    MoreMenu.Add("Auto", ThemeHandler)
    MoreMenu.Add()
    MoreMenu.Add("Start on Boot", MenuBootHandler)
    MoreMenu.Add()
    MoreMenu.Add("Explore", (*) => Run('explorer.exe /select,"' . A_ScriptFullPath . '"'))
    if !A_IsCompiled
        MoreMenu.Add("Edit", (*) => Run('explorer.exe /edit,"' . A_ScriptFullPath . '"'))
    MoreMenu.Add("Help", (*) => ShowHelpGUI())
    MoreMenu.Add("About", (*) => ShowAboutGUI())

    TrayMenu.Add("More", MoreMenu)
    TrayMenu.Add("Suspend", MenuToggleSuspendHandler)
    TrayMenu.Add("Pause", MenuTogglePauseHandler)
    TrayMenu.Add("Restart", (*) => Reload())
    TrayMenu.Add()
    TrayMenu.Add("Exit", (*) => ExitApp())


    SettingsLoadStartOnBoot() ? MoreMenu.Check("Start on Boot") : ""

    MoreMenu.Check(Settings.DesiredTheme)
    MoreMenu.Disable(Settings.DesiredTheme)
}

ThemeHandler(ItemName, ItemPos, MyMenu) {
    global Settings
    Settings.DesiredTheme := ItemName
    ApplyTheme(Settings.DesiredTheme)
    SaveINI()
    for item in Settings.ThemeList {
        isCurrent := (item == ItemName)
        MyMenu.% isCurrent ? "Check" : "Uncheck" %(item)
        MyMenu.% isCurrent ? "Disable" : "Enable" %(item)
    }
}

MenuBootHandler(ItemName, ItemPos, MyMenu) {
    newstate := !SettingsLoadStartOnBoot()
    SettingsSaveStartOnBoot(newstate)
    newstate ? MyMenu.Check(ItemName) : MyMenu.Uncheck(ItemName)
}

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

TrayIconClick(wParam, lParam, msg, hwnd) {
    if (lParam = 0x203 || lParam = 0x201) {  ; 1 click / 2 clicks
;        Send("{Escape}")
;        Sleep(50)
;        if WinExist("About") {
;            WinActivate("About")
;        } else {
;            ShowAboutGUI()
;        }
        A_TrayMenu.Show()
    }
}

MenuToggleSuspendHandler(ItemName, ItemPos, MyMenu) {
    Suspend(-1)
    MyMenu.ToggleCheck(ItemName)
    if A_IsSuspended {
        if A_IsCompiled {
            TraySetIcon(App.IconPaused, -207, true)
        } else {
            TraySetIcon(App.IconPaused,,True)
        }
    } else if (!A_IsPaused) {
        TraySetIcon(App.Icon,, true)
    }
}

MenuTogglePauseHandler(ItemName, ItemPos, MyMenu) {
    if (!A_IsPaused) {
        if A_IsCompiled {
            TraySetIcon(App.IconPaused, -207, true)
        } else {
            TraySetIcon(App.IconPaused,, true)
        }
    } else if (!A_IsSuspended){
        TraySetIcon(App.Icon,, true)
    }
    MyMenu.ToggleCheck(ItemName)
    Pause(-1)
}
