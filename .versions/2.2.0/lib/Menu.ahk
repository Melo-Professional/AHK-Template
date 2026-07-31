/************************************************************************
 * @description Menu
 * @author Melo (melo@meloprofessional.com)
 * @date 2026/05/14
 * @version 1.2.0
 ***********************************************************************/

#Requires AutoHotkey v2.0

StartMenu() {
    A_IconHidden := true
    A_TrayMenu.Delete()
    A_IconTip               := App.Name
    TrayMenu                := A_TrayMenu
    TrayMenu.ClickCount     := 1
    try TraySetIcon(App.Icon, , true)
    A_IconHidden := false

    TrayMenu.Add(App.Name, (*) => TrayMenu.Show())
    TrayMenu.Default            := App.Name
    TrayMenu.Disable(App.Name)

    TrayMenu.Add()
    TrayMenu.Add("Restart", (*) => Reload())
    TrayMenu.Add()
    TrayMenu.Add("Exit", (*) => ExitApp())


    MoreMenu := Menu()
    TrayMenu.Insert("Restart", "More", MoreMenu)
    MoreMenu.Add("Light", ThemeHandler)
    MoreMenu.Add("Dark", ThemeHandler)
    MoreMenu.Add("Auto", ThemeHandler)
    MoreMenu.Add()
    MoreMenu.Add("Start on Boot", MenuBootHandler)
    MoreMenu.Add()
    MoreMenu.Add("Explore", (*) => Run('explorer.exe /select,"' . A_ScriptFullPath . '"'))
    MoreMenu.Add("Edit", (*) => Run('explorer.exe /edit,"' . A_ScriptFullPath . '"'))
    MoreMenu.Add("Help", (*) => ShowHelpGUI())
    MoreMenu.Add("About", (*) => ShowAboutGUI())

    SettingsLoadStartOnBoot() ? MoreMenu.Check("Start on Boot") : ""

    switch Settings.DesiredTheme {
        case "Light":
            {
                MoreMenu.Check("Light")
                MoreMenu.Disable("Light")
            }
        case "Dark":
            {
                MoreMenu.Check("Dark")
                MoreMenu.Disable("Dark")
            }
        case "Auto":
            {
                MoreMenu.Check("Auto")
                MoreMenu.Disable("Auto")
            }
    }
}

ThemeHandler(ItemName, ItemPos, MyMenu) {
    global Settings

    Settings.DesiredTheme := ItemName
    ApplyTheme(Settings.DesiredTheme)
    SaveINI()
    MyMenu.Uncheck("Light")
    MyMenu.Uncheck("Dark")
    MyMenu.Uncheck("Auto")
    MyMenu.Enable("Light")
    MyMenu.Enable("Dark")
    MyMenu.Enable("Auto")
    MyMenu.Check(ItemName)
    MyMenu.Disable(ItemName)
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