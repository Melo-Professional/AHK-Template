#Requires AutoHotkey v2.0

ShowHelpGUI() {
    MyGuiTitle := "Help"
    MyGuiOptions := "+LastFound -SysMenu"

    if IsDarkModeEnabled() {
        try {
            MyGui := DarkGui(MyGuiOptions, MyGuiTitle)
        } catch {
            MyGui := Gui(MyGuiOptions, MyGuiTitle)
        }
    } else {
        MyGui := Gui(MyGuiOptions, MyGuiTitle)
    }

    MyGui.SetFont("s" Settings.GuiFontSizeMedium, Settings.GuiFontName)

    ; Define layout constants
    GuiWidth            := 640
    BtnWidth            := 80
    MyGui.MarginX       := 40
    MyGui.MarginY       := 30


    ; 1. Add the custom Icon from your script directory
    try {
        MyGui.Add("Picture", "w32 h32", App.Icon)
    } catch {
        MyGui.SetFont("s15 w500")
        MyGui.Add("Text", "w32 h32", "[ i ]")
    }

    ; 2. Title and Version (Positioned to the right of the icon)
    MyGui.SetFont("s" Settings.GuiFontSizeBig " w700")
    MyGui.Add("Text", "x+15 y28", App.Name) ; x+15 moves it right of the icon
    ;MyGui.Add("Text", "y30", App.Name) ; x+15 moves it right of the icon

    MyGui.SetFont("s" Settings.GuiFontSizeSmall " w400 ")
    MyGui.Add("Text", "y+2 cGray", "Version " Format("{:.2f}", App.Version))

    ; 3. Content
    MyGui.SetFont("s" Settings.GuiFontSizeBig " w400")
    ;MyGui.Add("Text", "y+60 w" . (GuiWidth - (MyGui.MarginX * 2)), "HotKey")
    MyGui.Add("Text", "x" MyGui.MarginX " y+30 w" . (GuiWidth - (MyGui.MarginX * 2)), "HotKey")

    MyGui.SetFont("s" Settings.GuiFontSizeMedium " w300")
    MyGui.Add("Text", "y+2 w" . (GuiWidth - (MyGui.MarginX * 2)), "Block/ unblock Internet access from any active program`nusing the shortkey defined in the tray menu.")

    MyGui.SetFont("s" Settings.GuiFontSizeBig " w400")
    MyGui.Add("Text", "w" . (GuiWidth - (MyGui.MarginX * 2)), "Select from Running Programs")

    MyGui.SetFont("s" Settings.GuiFontSizeMedium " w300")
    MyGui.Add("Text", "y+2 w" . (GuiWidth - (MyGui.MarginX * 2)), "Pick from curretly running process.")

    MyGui.SetFont("s" Settings.GuiFontSizeBig " w400")
    MyGui.Add("Text", "w" . (GuiWidth - (MyGui.MarginX * 2)), "Select Any Program File")

    MyGui.SetFont("s" Settings.GuiFontSizeMedium " w300")
    MyGui.Add("Text", "y+2 w" . (GuiWidth - (MyGui.MarginX * 2)), "Use file browser to select a program to block/unblock.")

    MyGui.SetFont("s" Settings.GuiFontSizeBig " w400")
    MyGui.Add("Text", "w" . (GuiWidth - (MyGui.MarginX * 2)), "Manage Active Block Rules")

    MyGui.SetFont("s" Settings.GuiFontSizeMedium " w300")
    MyGui.Add("Text", "y+2 w" . (GuiWidth - (MyGui.MarginX * 2)), "Find all currently blocked programs.")

    MyGui.SetFont("s" Settings.GuiFontSizeBig " w400")
    MyGui.Add("Text", "w" . (GuiWidth - (MyGui.MarginX * 2)), "Start on Boot")

    MyGui.SetFont("s" Settings.GuiFontSizeMedium " w300")
    MyGui.Add("Text", "y+2 w" . (GuiWidth - (MyGui.MarginX * 2)), "Launch this script when Windows user login.")

    MyGui.SetFont("s" Settings.GuiFontSizeSmall " w300")
    MyGui.Add("Text", "y+20 w" . (GuiWidth - (MyGui.MarginX * 2)), "It requires administrator rights.*")
    MyGui.SetFont("s" Settings.GuiFontSizeMedium " w300")


    ;btnX := GuiWidth - MyGui.MarginX - BtnWidth     ; Rigth aligned button
    btnX := (GuiWidth //2) - (BtnWidth // 2)        ; Center aligned button

    Btn := MyGui.AddButton("x" btnX " y+30 w" BtnWidth " h30 Default", "&OK")

    Btn.OnEvent("Click", (*) => MyGui.Destroy())
    MyGui.Show("w" GuiWidth)
}