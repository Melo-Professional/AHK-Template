/************************************************************************
 * @description This is a Splash Screen made of Custom OSD
 * @author Melo (melo@meloprofessional.com)
 * @date 2026/08/18
 * @version 1.2.0.100
 ***********************************************************************/

#Requires AutoHotkey v2.0

/* 
#Include ".\_OSDCustom.ahk"

If !IsSet(App) {
	App := {
		Name:                       "My App",
		Icon:                       A_ScriptDir "\..\resources\app.ico",
		Version:                    "1.0.0.0"
	}
}

SplashScreenOSD()
 */

SplashScreenOSD(timeout := 1800) {	; send 0 to permanent and -1 to destroy
	if !IsSet(OSDCustom) {
		throw Error("OSDCustom lib not found!")
	}

	Static Splash := OSDCustom()

	if (timeout < 0) {
		Splash.Destroy()
		Splash := 0
		return
	}

	Splash.MinWidth := 400
	Splash.RowGap := 1
	Splash.RowGap := 0
	Splash.FontSize := 14
	Splash.MarginX := 24
	Splash.MarginY := 34
	Splash.SlideDistance := 0
	Splash.FontWeight := 1000
	Splash.Opacity := 255
	Splash.RoundedCorners := 40
	Splash.TimeOut := timeout
    Splash.TextDefaultLight := "5a5555"
    Splash.BgColorLight := "F5F9FB"
    Splash.ProgressFgLight := "0067C0"
    Splash.ProgressBgLight := "transparent"
	Splash.TextDefaultDark := "FFFFFF"
	Splash.BgColorDark := "1B1B1B"
	Splash.ProgressFgDark := "0067C0"
	Splash.ProgressBgDark := "transparent"

	Splash.SetCellText( 1, 1, " ", {Fontsize: 1})
	Splash.SetCellImage( 1, 2, App.Icon, "Left", 50, 1, 3)
	Splash.SetCellText( 1, 3, App.Name, "Center", 4, 1)
	Splash.SetCellText( 1, 4, "Version " App.Version, "Center", {Fontsize: 8, FontColor: "888888", FontWeight: 100}, 4, 1)
	Splash.SetCellText( 1, 5, " ")
	Splash.SetCellProgress(1, 6,,,,, 1, {Marquee: true })
	Splash.Show()
}
