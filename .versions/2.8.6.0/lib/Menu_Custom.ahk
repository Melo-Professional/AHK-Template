#Requires AutoHotkey v2.0

Menu_Custom(TrayMenu, MoreMenu) {

    ; Custom items
    TrayMenu.Insert("More", "Sound Control Panel", (*) => Run("control mmsys.cpl sounds"))
    TrayMenu.Insert("More", "Volume Mixer", (*) => Run("sndvol.exe"))
    TrayMenu.Insert("More")

    ; Clean up Suspend and Pause
    try MoreMenu.Delete("Suspend")
    try MoreMenu.Delete("Pause")
}

;A_TrayMenu.Delete()