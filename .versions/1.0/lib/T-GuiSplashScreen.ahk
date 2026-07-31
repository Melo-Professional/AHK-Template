#Requires AutoHotkey v2.0

SplashScreen() {
    SplashWidth         := 400
    SplashRoundCorners  := 40 

    SplashGui := Gui("-Caption +AlwaysOnTop +ToolWindow +E0x20")
    ;SplashGui := Gui("-Caption +LastFound +ToolWindow +E0x20")

    SplashGui.BackColor := "222325"
    
    SplashGui.SetFont("s" Settings.GuiFontSizeExtraBig " w700 ce7e7e7", Settings.GuiFontName)
    SplashGui.Add("Text", "Center w" SplashWidth " x0 y70", App.Name)

    SplashGui.SetFont("s" Settings.GuiFontSizeSmall " w400 cGray")
    SplashGui.Add("Text", "Center y+2 w" SplashWidth, "Version " Format("{:.2f}", App.Version))

    try SplashGui.Add("Picture", "x35 y63 w50 h50", App.Icon)

    SplashGui.SetFont("s9 w300 cAAAAAA", Settings.GuiFontName)
    LoadingTxt := SplashGui.Add("Text", "Left x" (SplashWidth - 80) " y+50 w" SplashWidth, "Loading      `n")

    SplashGui.Show("w" SplashWidth " xCenter yCenter Hide NoActivate")
    SplashGui.GetPos(, , &SplashWidth, &SplashHeight)
    WinSetRegion("0-0 w" SplashWidth " h" SplashHeight " R" SplashRoundCorners "-" SplashRoundCorners, SplashGui.Hwnd)
    WinSetTransparent(248, SplashGui.Hwnd)

    SplashGui.Show("NoActivate")
    ;SplashGui.Show()
    ;WinActivate(SplashGui.Hwnd)

    DotCount := 0
    
    AnimateDots := (*) => (
        DotCount := Mod(DotCount + 1, 4),
        LoadingTxt.Value := "Loading" . (DotCount = 1 ? "." : DotCount = 2 ? ".." : DotCount = 3 ? "..." : "") . "      `n"
    )

    SetTimer(AnimateDots, 700)
    SetTimer(ObjBindMethod(SplashGui, "Destroy"), -2500)
    SetTimer(() => SetTimer(AnimateDots, 0), -2400)
}