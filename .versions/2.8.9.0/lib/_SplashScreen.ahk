/************************************************************************
 * @description Splash Screen
 * @author Melo (melo@meloprofessional.com)
 * @date 2026/06/02
 * @version 1.5.0
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
SplashScreen(type := Settings.SplashScreen, timeauto := true) {
    static running := false
    static desiredsplash := type

    splashMap := Map(
        "Icon",   SplashIcon,
        "Banner", SplashBanner
    )

    if splashMap.Has(desiredsplash) {
        ;tooltip(desiredsplash)
        splashObj := splashMap[desiredsplash]
        destroySplash := () => (splashObj.Destroy(), running := false)
        if !running {
            splashObj.Show()
            running := true
            if (timeauto == true) {
                SetTimer(destroySplash, -Settings.GuiSplashTimer)
            }
        } else {
            splashObj.Destroy()
            running := false
            ;if (time == "auto") {
                SetTimer(destroySplash, 0) 
            ;}
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

        ; 1. Prevent Windows DPI scaling conflicts with WinSetRegion
        MyGuiTitle := "SplahScreen"
        ;MyGuiOptions := "-Caption +LastFound +AlwaysOnTop +ToolWindow +E0x20 -DPIScale"
        MyGuiOptions := "-Caption +AlwaysOnTop +ToolWindow +E0x20 -DPIScale"
        this.GuiObj := Gui(MyGuiOptions, MyGuiTitle)
        
        ; 2. Calculate the OS scaling factor
        Scale := A_ScreenDPI / 96

        ; 3. Scale structural window dimensions
        SplashWidth := Round(400 * Scale)
        SplashRoundCorners := Round(40 * Scale)
        IconSize := Round(50 * Scale)
        
        ; APP NAME - Drop manual font size multiplying to keep rendering clean
        this.GuiObj.SetFont("s" Settings.GuiFontSizeExtraBig " w1000", Settings.GuiFontName)
        if App.Name = App.NameCutted
            this.GuiObj.Add("Text", "Center vStrong_Title w" SplashWidth " x0 y" Round(70 * Scale), App.Name)
        else
            this.GuiObj.Add("Text", "Center vStrong_Title w" SplashWidth " x0 y" Round(62 * Scale), App.NameCutted)

        ; APP VERSION
        this.GuiObj.SetFont("s" Settings.GuiFontSizeSmall " w400")
        this.GuiObj.Add("Text", "Center vSmooth_Version y+2 w" SplashWidth, "Version " App.Version)

        ; ICON
        try this.GuiObj.Add("Picture", "x" Round(35 * Scale) " y" Round(63 * Scale) " w" IconSize " h" IconSize, App.Icon)

        ; LOADING - Fixed coordinate base for standard fonts
        this.GuiObj.SetFont("s8 w300", Settings.GuiFontName)
        
        ; Using a predictable X start point (70% across the banner) avoids alignment math mismatches
        TextStartX := Round(SplashWidth * 0.72) 
        DotsWidth := Round(24 * Scale)
        
        ; The word stays locked in place
        this.GuiObj.Add("Text", "Left x" TextStartX " y+" Round(50 * Scale), "Loading")
        ; The dots snap right up against it without any layout drifting
        DotsTxt := this.GuiObj.Add("Text", "Left x+0 w" DotsWidth, "")

        this.GuiObj.Show("w" SplashWidth " xCenter yCenter Hide NoActivate")
        
        ; 4. Set final window bounds and mask the rounded edge
        this.GuiObj.GetPos(, , &w, &h)
        WinSetRegion("0-0 w" w " h" h " r" SplashRoundCorners "-" SplashRoundCorners, this.GuiObj.Hwnd)
        WinSetTransparent(248, this.GuiObj.Hwnd)

        if IsFunctionDefined("ApplyThemeToGui") {
            %"ApplyThemeToGui"%(this.GuiObj)
        }
        this.GuiObj.Show("NoActivate")

        ; Dot Animation Loop updates only the dots control
        DotCount := 0
        this.DotTimer := (*) => (
            DotCount := Mod(DotCount + 1, 4),
            DotsTxt.Value := (DotCount = 1 ? "." : DotCount = 2 ? ".." : DotCount = 3 ? "..." : "")
        )
        SetTimer(this.DotTimer, 700)

        IsFunctionDefined(Name) {
            try return HasMethod(%Name%)
            return false
        }
    }

    static Destroy() {
        Elapsed := A_TickCount - this.StartTime

        if (Elapsed < Settings.GuiSplashTimer) {
            SetTimer(() => this.Destroy(), -(Settings.GuiSplashTimer - Elapsed))
            return 
        }

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
        this.GuiObj := Gui("-Caption +AlwaysOnTop +ToolWindow +E0x20")
        this.GuiObj.BackColor := "000000" 
        this.GuiObj.Add("Picture", "x0 y0 w" IconSize " h" IconSize, App.Icon)
        this.GuiObj.Show("w" IconSize " h" IconSize " Hide")
        WinSetTransColor("000000 255", this.GuiObj.Hwnd)
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