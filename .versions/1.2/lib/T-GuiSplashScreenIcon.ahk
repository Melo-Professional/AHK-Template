#Requires AutoHotkey v2.0

SplashScreenIcon() {

IconSize := 128
TransColor := "ABCDEF"

SplashGuiIcon := Gui("-Caption +AlwaysOnTop +ToolWindow +E0x20")
SplashGuiIcon.BackColor := TransColor
SplashGuiIcon.Add("Picture", "x0 y0 w" IconSize " h" IconSize, App.Icon)
WinSetTransColor(TransColor, SplashGuiIcon)
/* Real screen center
    absX := (A_ScreenWidth / 2) - (IconSize / 2)
    absY := (A_ScreenHeight / 2) - (IconSize / 2)
;SplashGuiIcon.Show("xCenter yCenter NoActivate")
 */

SplashGuiIcon.Show("AutoSize Center NoActivate")
SetTimer(() => SplashGuiIcon.Destroy(), Settings.GuiSplashTimer)
}