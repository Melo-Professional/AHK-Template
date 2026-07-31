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
    TrayMenu.Add("Start on Boot", MenuBootHandler)
    TrayMenu.Add("Restart", (*) => Reload())
    TrayMenu.Add()
    TrayMenu.Add("Exit", (*) => ExitApp())

    ThemeMenu := Menu()
    TrayMenu.Insert("Exit", "Theme", ThemeMenu)
    ThemeMenu.Add("Light", ThemeHandler)
    ThemeMenu.Add("Dark", ThemeHandler)
    ThemeMenu.Add("Auto", ThemeHandler)

    InfoMenu := Menu()
    TrayMenu.Insert("Exit", "Info", InfoMenu)
    InfoMenu.Add("Help", (*) => ShowHelpGUI())
    InfoMenu.Add("Explore", (*) => Run('explorer.exe /select,"' . A_ScriptFullPath . '"'))
    InfoMenu.Add("Edit", (*) => Run('explorer.exe /edit,"' . A_ScriptFullPath . '"'))
    InfoMenu.Add("About", (*) => ShowAboutGUI())

    SettingsLoadStartOnBoot() ? TrayMenu.Check("Start on Boot") : ""

    switch Settings.DesiredTheme {
        case "Light":
            {
                ThemeMenu.Check("Light")
                ThemeMenu.Disable("Light")
            }
        case "Dark":
            {
                ThemeMenu.Check("Dark")
                ThemeMenu.Disable("Dark")
            }
        case "Auto":
            {
                ThemeMenu.Check("Auto")
                ThemeMenu.Disable("Auto")
            }
    }
}

MenuBootHandler(ItemName, ItemPos, MyMenu) {
    newstate := !SettingsLoadStartOnBoot()
    SettingsSaveStartOnBoot(newstate)
    newstate ? MyMenu.Check(ItemName) : MyMenu.Uncheck(ItemName)
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