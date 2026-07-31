#Requires AutoHotkey v2.0

class SplashIcon {
    static GuiObj := 0
    static StartTime := 0

    static Show() {
        this.StartTime := A_TickCount
            
    IconSize := 128
    TransColor := "ABCDEF"

    this.GuiObj := Gui("-Caption +AlwaysOnTop +ToolWindow +E0x20")
    this.GuiObj.BackColor := TransColor
    this.GuiObj.Add("Picture", "x0 y0 w" IconSize " h" IconSize, App.Icon)
    WinSetTransColor(TransColor, this.GuiObj)

    this.GuiObj.Show("NoActivate")

}

    static Destroy() {
        Elapsed := A_TickCount - this.StartTime
        
        ; If we haven't reached the minimum time yet...
        if (Elapsed < Settings.GuiSplashTimer) {
            ; Schedule Destroy to run again after the remaining time
            ; We use a negative number for a one-time timer
            SetTimer(() => this.Destroy(), -(Settings.GuiSplashTimer - Elapsed))
            return ; Exit now so the main script continues immediately!
        }

        if (this.GuiObj !== 0) {
            this.GuiObj.Destroy()
            this.GuiObj := 0
        }
    }
}