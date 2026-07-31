#Requires AutoHotkey v2.0

ShowAboutGUI() {
    MyGuiTitle := "About"
    MyGuiOptions := "+LastFound -SysMenu"

    if IsDarkModeEnabled() {
        try {
            AboutGui := DarkGui(MyGuiOptions, MyGuiTitle)
        } catch {
            AboutGui := Gui(MyGuiOptions, MyGuiTitle)
        }
    } else {
        AboutGui := Gui(MyGuiOptions, MyGuiTitle)
    }

    AboutGui.SetFont("s" Settings.GuiFontSizeMedium, Settings.GuiFontName)

    ; Define layout constants
    GuiWidth                := 460
    BtnWidth                := 80
    AboutGui.MarginX        := 50
    AboutGui.MarginY        := 20

    ; 1. Add the custom Icon from your script directory
    try {
        AboutGui.Add("Picture", "w64 h64", App.Icon)
    } catch {
        AboutGui.SetFont("s30 w500")
        AboutGui.Add("Text", "w64 h64", "[ i ]")
    }

    ; 2. Title and Version (Positioned to the right of the icon)
    AboutGui.SetFont("s" Settings.GuiFontSizeExtraBig " w700")
    AboutGui.Add("Text", "x+15 y30", App.Name)

    AboutGui.SetFont("s" Settings.GuiFontSizeSmall " w400")
    AboutGui.Add("Text", "y+2 cGray", "Version " Format("{:.2f}", App.Version))

    ; 3. Description
    AboutGui.SetFont("s" Settings.GuiFontSizeMedium " w400")
    AboutGui.Add("Text", "x" AboutGui.MarginX " y+50 w" . (GuiWidth - (AboutGui.MarginX *2)), App.Description)

    ; 4. Credits / Copyright
    AboutGui.SetFont("s" Settings.GuiFontSizeSmall " w400")
    AboutGui.Add("Text", "y+20 cGray", App.Copyright)

    ; 5. Right-Aligned OK Button
    btnX := GuiWidth - AboutGui.MarginY - BtnWidth
    Btn := AboutGui.AddButton("x" btnX " y+25 w" BtnWidth " h30 Default", "&OK")
    
    Btn.OnEvent("Click", (*) => AboutGui.Destroy())
    AboutGui.Show("w" GuiWidth)
}