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

    InfoMenu := Menu()
    TrayMenu.Insert("Exit", "Info", InfoMenu)
    InfoMenu.Add("Help", (*) => ShowHelpGUI())
    InfoMenu.Add("Explore", (*) => Run('explorer.exe /select,"' . A_ScriptFullPath . '"'))
    InfoMenu.Add("Edit", (*) => Run('explorer.exe /edit,"' . A_ScriptFullPath . '"'))
    InfoMenu.Add("About", (*) => ShowAboutGUI())

    SettingsLoadStartOnBoot() ? TrayMenu.Check("Start on Boot") : ""
}

MenuBootHandler(ItemName, ItemPos, MyMenu) {
    newstate := !SettingsLoadStartOnBoot()
    SettingsSaveStartOnBoot(newstate)
    newstate ? MyMenu.Check(ItemName) : MyMenu.Uncheck(ItemName)
}
