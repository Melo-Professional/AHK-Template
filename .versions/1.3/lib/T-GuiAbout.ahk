#Requires AutoHotkey v2.0

ShowAboutGUI() {
    MyGuiTitle := "About"
    MyGuiOptions := "+LastFound -SysMenu"

    ; Check DarkMode
    if IsSet(IsDarkModeEnabled) && IsSet(DarkGui) && IsDarkModeEnabled() {
        MyGui := DarkGui(MyGuiOptions, MyGuiTitle)
    } else {
        MyGui := Gui(MyGuiOptions, MyGuiTitle)
    }

    MyGui.SetFont("s" Settings.GuiFontSizeMedium, Settings.GuiFontName)

    ; Define layout constants
    GuiWidth            := 460
    BtnWidth            := 80
    MyGui.MarginX       := 50
    MyGui.MarginY       := 30

    ; 1. Icon
    try {
        MyGui.Add("Picture", "w64 h64", App.Icon)
    } catch {
        MyGui.SetFont("s22 w500")
        MyGui.Add("Text", "w64 h64", "[ i ]")
    }

    ; 2. Title and Version
    MyGui.SetFont("s" Settings.GuiFontSizeExtraBig " w700")
    MyGui.Add("Text", "x+15 y40", App.Name)

    MyGui.SetFont("s" Settings.GuiFontSizeSmall " w400")
    MyGui.Add("Text", "y+2 cGray", "Version " App.Version)

    ; 3. Description
    MyGui.SetFont("s" Settings.GuiFontSizeMedium " w400")
    MyGui.Add("Text", "x" MyGui.MarginX " y+50 w" . (GuiWidth - (MyGui.MarginX *2)), App.Description)

    ; 4. Credits / Copyright
    MyGui.SetFont("s" Settings.GuiFontSizeSmall " w400")
    MyGui.Add("Text", "x" MyGui.MarginX " y+20 cGray", App.Copyright)

    ; 5. Button
    MyGui.SetFont("s" Settings.GuiFontSizeMedium " w300", Settings.GuiFontName)
    ; 5.1 align
;        btnX := MyGui.MarginX ; left
;        btnX := (GuiWidth - BtnWidth) // 2 ; center
        btnX := GuiWidth - MyGui.MarginX - BtnWidth ; right
    MyGui.AddButton("x" btnX " y+25 w" BtnWidth " h30 Default", "&OK").OnEvent("Click", (*) => myGui.Destroy())

    MyGui.Show("w" GuiWidth)
}