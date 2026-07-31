#Requires AutoHotkey v2.0

SplashScreen() {
    SplashWidth         := 400
    SplashRoundCorners  := 40
    IconSize            := 50
    GuiSplashTimerLoading   := Settings.GuiSplashTimer -100

    SplashGui := Gui("-Caption +LastFound +AlwaysOnTop +ToolWindow +E0x20")

    SplashGui.BackColor := "222325"
    
    ; APP NAME
    SplashGui.SetFont("s" Settings.GuiFontSizeExtraBig " w1000 ce7e7e7", Settings.GuiFontName)
    SplashGui.Add("Text", "Center w" SplashWidth " x0 y70", App.Name)

    ; APP VERSION
    SplashGui.SetFont("s" Settings.GuiFontSizeSmall " w400 cGray")
    SplashGui.Add("Text", "Center y+2 w" SplashWidth, "Version " App.Version)

    ; ICON
    try SplashGui.Add("Picture", "x35 y63 w" IconSize " h" IconSize, App.Icon)

    ; LOADING
    SplashGui.SetFont("s9 w300 cAAAAAA", Settings.GuiFontName)
    LoadingTxt := SplashGui.Add("Text", "Left x" (SplashWidth - 80) " y+50 w" SplashWidth, "Loading      `n")

    SplashGui.Show("w" SplashWidth " xCenter yCenter Hide NoActivate")
    SplashGui.GetPos(, , &SplashWidth, &SplashHeight)
    WinSetRegion("0-0 w" SplashWidth " h" SplashHeight " R" SplashRoundCorners "-" SplashRoundCorners, SplashGui.Hwnd)
    WinSetTransparent(248, SplashGui.Hwnd)

    SplashGui.Show("NoActivate")

    DotCount := 0
    
    AnimateDots := (*) => (
        DotCount := Mod(DotCount + 1, 4),
        LoadingTxt.Value := "Loading" . (DotCount = 1 ? "." : DotCount = 2 ? ".." : DotCount = 3 ? "..." : "") . "      `n"
    )

    SetTimer(AnimateDots, 700)
    SetTimer(ObjBindMethod(SplashGui, "Destroy"), -Settings.GuiSplashTimer)
    SetTimer(() => SetTimer(AnimateDots, 0), -GuiSplashTimerLoading)
}