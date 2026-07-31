/**
 * Custom MsgBox replacement for AHK v2
 * Syntax: MsgBoxCustom(Text, Title, Options)
 * Returns: The text of the button pressed (e.g., "Retry", "Cancel", "OK")
 */

/**
 * @description {@link MsgBoxCustom|RN-GuiMsgBoxCustom.ahk}  
 * Displays a Custom Message Box. Useful for keeping your custom icon and better control of your GUIs.
 * @param {(String)} [Text]
 * @param {(String)} [Title]
 * @param {"OKCancel"|"RetryCancel"|"YesNo"|"OK"} [Options]
 * @returns {(String)}
 * Returns the button pressed by the user.
 * @example <caption>Show a Message Box with "This is a message" with a OK button.</caption>  
 * MsgBoxCustom("This is a message")
 * @example <caption>Show a Message Box asking "Continue?", a title "Question" with buttons Yes and No.</caption>  
 * MsgBoxCustom("Continue?", "Question", "YesNo")
 */
MsgBoxCustom(Text := "Message", Title := "Warning", Options := "OK") {
    MyGuiTitle := Title
    MyGuiOptions := "+LastFound -MinimizeBox"

    if IsDarkModeEnabled() {
        try {
            myGui := DarkGui(MyGuiOptions, MyGuiTitle)
        } catch {
            myGui := Gui(MyGuiOptions, MyGuiTitle)
        }
    } else {
        myGui := Gui(MyGuiOptions, MyGuiTitle)
    }

    static Result := ""
    Result := "Cancel" 
    ;Result := false
    
    ; Settings for look and feel
    MinW := 400
    MinH := 180 ; Adjusted slightly for better proportions

    ;myGui := Gui("+LastFound -MinimizeBox", Title)
    myGui.SetFont("s10 w500", "Segoe UI")
    
    myGui.MarginX := 50
    myGui.MarginY := 20
    
    ; Add the text - centered within its own control
    txt := myGui.AddText("Left y+25 w300", Text)
    
    BtnStrings := (InStr(Options, "OKCancel"))    ? ["&OK", "&Cancel"] :
                  (InStr(Options, "RetryCancel")) ? ["&Retry", "&Cancel"] :
                  (InStr(Options, "ContinueExit")) ? ["&Continue", "&Exit"] :
                  (InStr(Options, "YesNo"))       ? ["&Yes", "&No"] : ["&OK"]

    btnW := 80
    btnGap := 10
    BtnObjects := []

    ;myGui.SetFont()
    myGui.SetFont("s9 w200", "Segoe UI")
    
    for index, btnName in BtnStrings {
        xPos := (index = 1) ? "xm" : "x+" btnGap
        yPos := (index = 1) ? "y+40" : "yp"
        btn := myGui.AddButton("w" btnW " h30 " xPos " " yPos, btnName)
        btn.OnEvent("Click", (GuiBtn, *) => (Result := StrReplace(GuiBtn.Text, "&"), myGui.Destroy()))
        if (index = 1)
            btn.Opt("+Default")
        BtnObjects.Push(btn)
    }

    ; Calculate dimensions
    myGui.Show("Hide") 
    myGui.GetClientPos(,, &guiW, &guiH)
    
    finalW := Max(guiW, MinW)
    finalH := Max(guiH, MinH)
    
    ; Re-center the buttons horizontally AND vertically relative to bottom
    totalBtnW := (BtnStrings.Length * btnW) + ((BtnStrings.Length - 1) * btnGap)
    startX := (finalW - totalBtnW) / 2
    
    for index, btnObj in BtnObjects {
        newX := startX + ((index - 1) * (btnW + btnGap))
        ; Place buttons exactly MarginY away from the bottom edge
        newY := finalH - myGui.MarginY - 30 
        btnObj.Move(newX, newY)
    }

    myGui.OnEvent("Close", (*) => myGui.Destroy())
    myGui.OnEvent("Escape", (*) => myGui.Destroy())

    ; 'Center' ensures it pops up in the middle of the screen
    myGui.Show("w" finalW " h" finalH " Center")
    
    WinWaitClose(myGui)
    return Result
}

/*
 --- Usage Example ---

if (MsgBoxCustom("Access Denied", App.Name, "RetryCancel") = "Cancel") {
    ToolTip "User bailed out!"
    Sleep 2000
    ExitApp
}

if (MsgBoxCustom("Reload?", App.Name, "YesNo") = "Yes")
    Reload

MsgBoxCustom("AccessStatus Denied", , "RetryCancel") = "Cancel" ? ExitApp() : Reload()

MsgBoxCustom("Reload?", , "YesNo") = "Yes" ? Reload() : ""


try {
    reg := RegRead(DNDRegistryKeyName, DNDRegistryValueName)
    return reg
} catch as err {
    MsgBoxCustom(
        "Could not read value from:`n`n" DNDRegistryKeyName "\" DNDRegistryValueName "`n`n"
        "Error: " err.Message "`n"
        "File: " err.File "`n"
        "Line: " err.Line "`n"
        "Extra: " err.Extra
    )
    return false
}


*/