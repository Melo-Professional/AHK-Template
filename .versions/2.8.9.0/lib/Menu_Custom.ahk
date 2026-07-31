/************************************************************************
 * @description Robust, Modular Menu (No-Crash Dependency Checking)
 * @author Melo (melo@meloprofessional.com)
 * @date 2026/06/02
 * @version 1.1.0
 ***********************************************************************/

#Requires AutoHotkey v2.0

Menu_Custom(TrayMenu, MoreMenu) {

    ; Custom items
;    TrayMenu.Insert("3&", "Sound Control Panel", (*) => Run("control mmsys.cpl sounds"))
;    TrayMenu.Insert("4&", "Volume Mixer", (*) => Run("sndvol.exe"))
;    TrayMenu.Insert("5&")

    ; Clean up Suspend and Pause
;    try MoreMenu.Delete("Suspend")
;    try MoreMenu.Delete("Pause")

    ; --- FIRST RUN NOTIFICATION ---
    RegKeyPath := "HKCU\Software\" . appName
    try {
        RegRead(RegKeyPath, "FirstRun")
    } 
    catch {
        ShowTrayNotification(
            "Welcome!", 
            app.Name " is now active and running in your system tray."
            )
        RegWrite(1, "REG_DWORD", RegKeyPath, "FirstRun")
    }

    ShowTrayNotification(title, message) {
        MyGui := Gui("+LastFound -SysMenu +ToolWindow", "")
        MyGui.SetFont("s" Settings.GuiFontSizeBig, Settings.GuiFontName)
        TitleCtrl1 := MyGui.Add("Text", "w300 y0", title)
        TitleCtrl1.OnEvent("Click", CleanDestroy)
        MyGui.SetFont("s" Settings.GuiFontSizeMedium, Settings.GuiFontName)
        MessageCtrl := MyGui.Add("Text", "w300 y+15", message)
        MessageCtrl.OnEvent("Click", CleanDestroy)
        MyGui.SetFont("s" Settings.GuiFontSizeSmall, Settings.GuiFontName)
        DismissCtrl := MyGui.Add("Text", "w300 y+5", "*click here to dismiss`n`n")
        DismissCtrl.OnEvent("Click", CleanDestroy)

        padding := 0
        ApplyThemeToGui(MyGui)
        MonitorGet(, &MonLeft, &MonTop, &MonRight, &MonBottom)
        MonitorGetWorkArea(, &WLeft, &WTop, &WRight, &WBottom)
        MyGui.Show("Hide")
        MyGui.GetPos(, , &actualWidth, &actualHeight)
        taskbarThicknessLeft := WLeft - MonLeft
        taskbarThicknessTop := WTop - MonTop
        taskbarThicknessRight := MonRight - WRight
        taskbarThicknessBottom := MonBottom - WBottom

        if (taskbarThicknessLeft > 0) {
            ; Taskbar Left: Stay near bottom-left edge of work area
            xPos := WLeft + padding
            yPos := WBottom - actualHeight - padding
        }
        else if (taskbarThicknessTop > 0) {
            ; Taskbar Top: Hover below the top-right tray area
            xPos := WRight - actualWidth - padding
            yPos := WTop + padding
        }
        else if (taskbarThicknessRight > 0) {
            ; Taskbar Right: Hover to the left of the vertical tray area
            xPos := WRight - actualWidth - padding
            yPos := WBottom - actualHeight - padding
        }
        else {
            ; Taskbar Bottom / Hidden: Hover right above the clock/tray
            xPos := WRight - actualWidth - padding
            yPos := WBottom - actualHeight - padding
        }

        MyGui.Show("X" xPos " Y" yPos " NoActivate")

        SetTimer(() => CleanDestroy(), -7000)

        MyGui.OnEvent("Close", CleanDestroy)
        MyGui.OnEvent("Escape", CleanDestroy)

        CleanDestroy(*) {
            try {
                MyGui.Destroy()
                MyGui := ""
            }
        }

    }
}

;A_TrayMenu.Delete()

