/************************************************************************
 * @description Splash Screen
 * @author Melo (melo@meloprofessional.com)
 * @date 2026/05/22
 * @version 1.1.0
 ***********************************************************************/

#Requires AutoHotkey v2.0

/**
 * @description {@link SplashScreen|SplashScreen.ahk}
 * Displays a Splashscreen with current App.Icon, App.Name and App.Description
 * @returns {(String)}
 * An empty string is always returned.
 * @example <caption>Display SplashScreen with auto destroy</caption>  
 * SplashScreen()
 * @example <caption>Display SplashScreen and later destroys</caption>  
 * SplashScreen(false)
 * <Your script goes here>
 * SplashScreen()
 */
SplashScreen(auto := true) {
    static running := false
    static desiredsplash := Settings.SplashScreen

    static splashMap := Map(
        "Icon",   SplashIcon,
        "Banner", SplashBanner
    )

    if splashMap.Has(desiredsplash) {
        splashObj := splashMap[desiredsplash]
        destroySplash := () => (splashObj.Destroy(), running := false)
        if !running {
            splashObj.Show()
            running := true
            if auto {
                SetTimer(destroySplash, -Settings.GuiSplashTimer)
            }
        } else {
            splashObj.Destroy()
            running := false
            if auto {
                SetTimer(destroySplash, 0) 
            }
        }
    }
}



/**
 * @description {@link SplashBanner|SplashBanner.ahk}
 * Displays a Splashscreen with current App.Icon, App.Name and App.Description
 * @returns {(String)}
 * An empty string is always returned.
 * @example <caption>Display the GUI</caption>  
 * SplashBanner.Show()
 * @example <caption>Destroy the GUI</caption>  
 * SplashBanner.Destroy()
 */
class SplashBanner {
    static GuiObj := 0
    static DotTimer := 0
    static StartTime := 0

    static Show() {

        this.StartTime := A_TickCount

    MyGuiTitle := "SplahScreen"
    MyGuiOptions := "-Caption +LastFound +AlwaysOnTop +ToolWindow +E0x20"

    ; Check DarkMode
    if (IsSet(CurrentActualTheme) && CurrentActualTheme == "Dark") {
        this.GuiObj := DarkGui(MyGuiOptions, MyGuiTitle)
    } else {
        this.GuiObj := Gui(MyGuiOptions, MyGuiTitle)
    }
        
        SplashWidth := 400
        SplashRoundCorners := 40
        IconSize := 50
        
;        this.GuiObj.BackColor := "222325"

        ; APP NAME
        this.GuiObj.SetFont("s" Settings.GuiFontSizeExtraBig " w1000", Settings.GuiFontName)
        if App.Name = App.NameCutted
            this.GuiObj.Add("Text", "Center vStrong_Title w" SplashWidth " x0 y70", App.Name)
        else
            this.GuiObj.Add("Text", "Center vStrong_Title w" SplashWidth " x0 y62", App.NameCutted)

        ; APP VERSION
        this.GuiObj.SetFont("s" Settings.GuiFontSizeSmall " w400")
        this.GuiObj.Add("Text", "Center vSmooth_Version y+2 w" SplashWidth, "Version " App.Version)

        ; ICON
        try this.GuiObj.Add("Picture", "x35 y63 w" IconSize " h" IconSize, App.Icon)

        ; LOADING
        this.GuiObj.SetFont("s9 w300", Settings.GuiFontName)
        LoadingTxt := this.GuiObj.Add("Text", "Left x" (SplashWidth - 80) " y+50 w" SplashWidth, "Loading")

        this.GuiObj.Show("w" SplashWidth " xCenter yCenter Hide NoActivate")
        this.GuiObj.GetPos(, , &SplashWidth, &SplashHeight)
        WinSetRegion("0-0 w" SplashWidth " h" SplashHeight " R" SplashRoundCorners "-" SplashRoundCorners, this.GuiObj.Hwnd)
        WinSetTransparent(248, this.GuiObj.Hwnd)

       ApplyThemeToGui(this.GuiObj)

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

/**
 * @description {@link SplashIcon|SplashIcon.ahk}
 * Displays a Splashscreen with current App.Icon
 * @returns {(String)}
 * An empty string is always returned.
 * @example <caption>Display the GUI</caption>  
 * SplashIcon.Show()
 * @example <caption>Destroy the GUI</caption>  
 * SplashIcon.Destroy()
 */
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
        
        if (Elapsed < Settings.GuiSplashTimer) {
            SetTimer(() => this.Destroy(), -(Settings.GuiSplashTimer - Elapsed))
            return
        }

        if (this.GuiObj !== 0) {
            this.GuiObj.Destroy()
            this.GuiObj := 0
        }
    }
}