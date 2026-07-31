#Requires AutoHotkey v2.0

class Splash {
    static GuiObj := 0
    static DotTimer := 0
    static StartTime := 0

    static Show() {
        this.StartTime := A_TickCount
        
        SplashWidth := 400
        SplashRoundCorners := 40
        IconSize := 50
        
        this.GuiObj := Gui("-Caption +LastFound +AlwaysOnTop +ToolWindow +E0x20")
        this.GuiObj.BackColor := "222325"
        
        ; APP NAME
        this.GuiObj.SetFont("s" Settings.GuiFontSizeExtraBig " w1000 ce7e7e7", Settings.GuiFontName)
        this.GuiObj.Add("Text", "Center w" SplashWidth " x0 y70", App.Name)

        ; APP VERSION
        this.GuiObj.SetFont("s" Settings.GuiFontSizeSmall " w400 cGray")
        this.GuiObj.Add("Text", "Center y+2 w" SplashWidth, "Version " App.Version)

        ; ICON
        try this.GuiObj.Add("Picture", "x35 y63 w" IconSize " h" IconSize, App.Icon)

        ; LOADING
        this.GuiObj.SetFont("s9 w300 cAAAAAA", Settings.GuiFontName)
        LoadingTxt := this.GuiObj.Add("Text", "Left x" (SplashWidth - 80) " y+50 w" SplashWidth, "Loading")

        this.GuiObj.Show("w" SplashWidth " xCenter yCenter Hide NoActivate")
        this.GuiObj.GetPos(, , &SplashWidth, &SplashHeight)
        WinSetRegion("0-0 w" SplashWidth " h" SplashHeight " R" SplashRoundCorners "-" SplashRoundCorners, this.GuiObj.Hwnd)
        WinSetTransparent(248, this.GuiObj.Hwnd)

        this.GuiObj.Show("NoActivate")

        DotCount := 0
        this.DotTimer := (*) => (
            DotCount := Mod(DotCount + 1, 4),
            LoadingTxt.Value := "Loading" . (DotCount = 1 ? "." : DotCount = 2 ? ".." : DotCount = 3 ? "..." : "")
        )
        SetTimer(this.DotTimer, 700)
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

        ; If we reached this point, the time is up. Clean up everything.
        if (this.DotTimer !== 0) {
            SetTimer(this.DotTimer, 0)
            this.DotTimer := 0
        }
        
        if (this.GuiObj !== 0) {
            this.GuiObj.Destroy()
            this.GuiObj := 0
        }
    }
}