/************************************************************************
 * @description This is a Splash Screen made of Custom OSD
 * @author Melo (melo@meloprofessional.com)
 * @date 2026/08/16
 * @version 1.1.1.0
 ***********************************************************************/

#Requires AutoHotkey v2.0

/* 
#Include ".\_OSDCustom.ahk"

If !IsSet(App) {
	App := {
		Name:                       "My App",
		Icon:                       A_ScriptDir "\app.png",
		Version:                    "1.0.0.0"
	}
}

SplashScreenOSD()
 */
SplashScreenOSD() {
	if !IsSet(OSDCustom)
		return
	Splash := OSDCustom()
	Splash.MinWidth := 400
	Splash.RowGap := 1
	Splash.FontSize := 14
	Splash.MarginX := 24
	Splash.MarginY := 34
	Splash.SlideDistance := 1
	Splash.FontWeight := 1000
	Splash.Opacity := 255
	Splash.TimeOut := 50
    Splash.TextDefaultLight := "5a5555"
    Splash.BgColorLight := "F5F9FB"
    Splash.ProgressFgLight := "0067C0"
    Splash.ProgressBgLight := "F5F9FB"
	Splash.TextDefaultDark := "FFFFFF"
	Splash.BgColorDark := "202020"
	Splash.ProgressFgDark := "0067C0"
	Splash.ProgressBgDark := "202020"

	Splash.SetCellText( 1, 1, " ", {Fontsize: 1})
	Splash.SetCellImage( 1, 2, App.Icon, "Left", 50, 1, 3)
	Splash.SetCellText( 1, 3, App.Name, "Center", 4, 1)
	Splash.SetCellText( 1, 4, "Version " App.Version, "Center", {Fontsize: 8, FontColor: "888888", FontWeight: 100}, 4, 1)
	Splash.SetCellText( 1, 5, " ")
	SplashProgress := Splash.SetCellProgress( 1, 6)

	Splash.Show()

	SetTimer(addProgress, 15)

	addProgress() {
		static value := 0
		value += 1
		
		Splash.UpdateProgressObject(SplashProgress, value)
		
		if (value >= 100) {
			SetTimer(addProgress, 0)
			Splash.ClearCells()
			Splash := ""
		}
	}
}
