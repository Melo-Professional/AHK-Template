#Requires AutoHotkey v2.0

ShowRulesGUI() {
    if !A_IsAdmin
        CheckAdmin("ShowRulesGUI")
    MyGuiTitle := App.Name " - Currently Blocking"
    MyGuiOptions := "+LastFound -MinimizeBox"

    if IsDarkModeEnabled() {
        try {
            RulesGui := DarkGui(MyGuiOptions, MyGuiTitle)
        } catch {
            RulesGui := Gui(MyGuiOptions, MyGuiTitle)
        }
    } else {
        RulesGui := Gui(MyGuiOptions, MyGuiTitle)
    }

    RulesGui.SetFont("s" Settings.GuiFontSizeMedium, Settings.GuiFontName)
    RulesGui.MarginX := 20
    RulesGui.MarginY := 20

    RulesGui.Add("Text", "y+20 ", "Currently blocked programs:")

    LB := RulesGui.AddListBox("r12 w350 +Multi Sort")
    LB.OnEvent("Change", (ctrl, *) => Btn.Enabled := (ctrl.Value.Length > 0))

    OSD.Show("Reading Current Rules...")

    PSCmd := 'powershell -NoProfile -Command "Get-NetFirewallRule -DisplayName AHK_Block_* | Group-Object DisplayName | Select-Object Name | ConvertTo-Csv -NoTypeInformation"'

    try {
        TempFile := A_Temp "\ahk_rules.csv"
        RunWait(A_ComSpec ' /c ' PSCmd ' > "' TempFile '"', , "Hide")
        if FileExist(TempFile) {
            Out := FileRead(TempFile)
            FileDelete(TempFile)
            
            Loop Parse, Out, "`n", "`r" {
                if (A_Index > 1 && Trim(A_LoopField) != "") {
                    CleanName := StrReplace(A_LoopField, '"', '')
                    CleanName := StrReplace(CleanName, "AHK_Block_", "")
                    LB.Add([CleanName])
                }
            }
        }
    }

    totalwidth := (RulesGui.MarginX * 2) + 350
    BtX := (totalwidth //2) - (150 //2)

    Btn := RulesGui.AddButton("x" BtX " Default w150 h35", "Unblock Selected")
    Btn.OnEvent("Click", (*) => RemoveSelectedRules(LB, RulesGui))
    Btn.Enabled := false

    RulesGui.Show()
}

RemoveSelectedRules(LB, RulesGui) {
    SelectedNames := []

    if !LB.Value || LB.Value.Length = 0 {
        return
    }

    for index in LB.Value {
        Items := ControlGetItems(LB.Hwnd)
        SelectedNames.Push(Items[index])
    }
    
    RulesGui.Destroy()

    if SelectedNames.Length = 0 {
        OSD.Show("No items selected", "Alert")
        return
    }

    OSD.Show("Processing...", "Warning")
    
    for FileName in SelectedNames {
        ;RunWait('powershell -NoProfile -Command "Remove-NetFirewallRule -DisplayName AHK_Block_' FileName '"', , "Hide")
        RulesRemove(FileName)
    }
    
    OSD.Show("Access Restored", "Success")
    Sleep(2000)
    ShowRulesGUI()

}