/************************************************************************
 * @description Custom Title Bar
 * @author Melo (melo@meloprofessional.com)
 * @date 2026/07/18
 * @version 1.0.0
 ***********************************************************************/


/* HOW TO USE
#Include .\_TitleBar.ahk

; Create your GUI layout normally
MainGui := Gui("-Caption")
MainGui.BackColor := "000000"
; Attach the custom emulated title bar layout

CustomTitleBar.Attach(MainGui, {
    Title: "Volume Mixer",
    ShowIcon: true,
    Min: true,
    Max: true, ; Turn off maximize if you don't need it
    Close: true
})

; Add your standard window controls below the title bar region
MainGui.Add("Text", "X20 Y50 cWhite", "Your custom volume elements go here...")
MainGui.Show("W400 H300")
FrostedTheme.Apply(MainGui)
*/



class CustomTitleBar {
    static TitleBars := Map()

    /**
     * Attaches a custom emulated title bar layout to an existing GUI.
     * @param {Gui} guiObj The target GUI object.
     * @param {Object} options Configuration object.
     * @param {String} options.Title Optional text string to show.
     * @param {Boolean} options.ShowIcon True to display the script/app icon on the left.
     * @param {Boolean} options.Min True to show Minimize button.
     * @param {Boolean} options.Max True to show Maximize/Restore button.
     * @param {Boolean} options.Close True to show Close button.
     * @param {Number} options.Height Title bar height in pixels (Default: 32).
     */
    static Attach(guiObj, options := "") {
        ; Default configurations
        cfg := { Title: "", ShowIcon: true, Min: true, Max: true, Close: true, Height: 32 }
        if IsObject(options) {
            for k, v in options.OwnProps()
                cfg.%k% := v
        }

        ; Instantiate layout tracker
        tb := {
            Gui: guiObj,
            Hwnd: guiObj.Hwnd,
            Height: cfg.Height,
            Buttons: Map(),
            Cfg: cfg
        }
        
        this.TitleBars[guiObj.Hwnd] := tb

        guiObj.MarginX := 0
        guiObj.MarginY := 0

        ; 1. Draw Icon if enabled
        ; 1. FIX: Explicitly request an IMAGE_ICON handle from LoadPicture via localType
        currentX := 8
        if (cfg.ShowIcon) {
            iconOpts := "X" currentX " Y" (cfg.Height-16)/2 " W16 H16"
            try {
                iconTarget := HasProp(App, "Icon") ? App.Icon : "shell32.dll"
                iconFlags := (A_IsCompiled && iconTarget == A_ScriptFullPath) ? "Icon1 W16 H16" : "W16 H16"
                
                ; Declaring localType forces LoadPicture to return a valid HICON instead of an HBITMAP
                localType := 0
                hIcon := LoadPicture(iconTarget, iconFlags, &localType)
                
                if (hIcon)
                    tb.IconCtrl := guiObj.Add("Pic", iconOpts, "HICON:*" hIcon)
                else
                    cfg.ShowIcon := false
            } catch {
                cfg.ShowIcon := false 
            }
            if (cfg.ShowIcon)
                currentX += 24
        }

        ; 2. Draw Optional Title Text
        if (cfg.Title != "") {
            guiObj.SetFont("S10 cWhite", "Segoe UI")
            tb.TextCtrl := guiObj.Add("Text", "X" currentX " Y0 H" cfg.Height " +0x200 BackgroundTrans", cfg.Title)
        }

        ; 3. Set up Window Management Messages (Drag & Hovers)
        if (this.TitleBars.Count = 1) {
            OnMessage(0x0201, this.WM_LBUTTONDOWN.Bind(this)) ; Click-to-drag
            OnMessage(0x0200, this.WM_MOUSEMOVE.Bind(this))   ; Hover effects
        }

        guiObj.OnEvent("Size", this.OnGuiSize.Bind(this))
        
        this.RenderButtons(tb)
        return tb
    }

    static RenderButtons(tb) {
        cfg := tb.Cfg
        guiObj := tb.Gui
        
        ; Set fonts for clean UI symbols (Marlett font provides native window control glyphs)
        guiObj.SetFont("S10 cWhite", "Marlett")
        
        btnWidth := 46
        btnHeight := tb.Height
        
        ; Dynamically check if width is available, otherwise safe fallback
        w := guiObj.HasProp("Width") ? guiObj.Width : 400
        
        if (cfg.Close) {
            btnX := "X" . (w - btnWidth)
            tb.Buttons["Close"] := guiObj.Add("Text", btnX . " Y0 W" btnWidth " H" btnHeight " +Center +0x200 BackgroundTrans", "r")
            ; FIX: Changed .Delete() to .Destroy()
            tb.Buttons["Close"].OnEvent("Click", (*) => guiObj.Destroy())
        }
        if (cfg.Max) {
            offset := cfg.Close ? 2 : 1
            btnX := "X" . (w - (btnWidth * offset))
            tb.Buttons["Max"] := guiObj.Add("Text", btnX . " Y0 W" btnWidth " H" btnHeight " +Center +0x200 BackgroundTrans", "1")
            tb.Buttons["Max"].OnEvent("Click", (*) => WinGetMinMax(guiObj.Hwnd) ? guiObj.Restore() : guiObj.Maximize())
        }
        if (cfg.Min) {
            offset := (cfg.Close ? 1 : 0) + (cfg.Max ? 1 : 0) + 1
            btnX := "X" . (w - (btnWidth * offset))
            tb.Buttons["Min"] := guiObj.Add("Text", btnX . " Y0 W" btnWidth " H" btnHeight " +Center +0x200 BackgroundTrans", "0")
            tb.Buttons["Min"].OnEvent("Click", (*) => guiObj.Minimize())
        }

        ; --- FIX: Reset font back to standard system default so subsequent controls render normally ---
        guiObj.SetFont("S10 cWhite", "Segoe UI")
    }

    static OnGuiSize(guiObj, minMax, width, height) {
        if !this.TitleBars.Has(guiObj.Hwnd)
            return
        tb := this.TitleBars[guiObj.Hwnd]

        ; Re-align caption buttons to the right corner
        btnWidth := 46
        offset := 1
        
        if tb.Buttons.Has("Close") {
            tb.Buttons["Close"].Move(width - (btnWidth * offset))
            offset++
        }
        if tb.Buttons.Has("Max") {
            tb.Buttons["Max"].Move(width - (btnWidth * offset))
            tb.Buttons["Max"].Text := minMax == 1 ? "2" : "1"
            offset++
        }
        if tb.Buttons.Has("Min") {
            tb.Buttons["Min"].Move(width - (btnWidth * offset))
        }
    }

    static WM_LBUTTONDOWN(wp, lp, msg, hwnd) {
        if !this.TitleBars.Has(hwnd)
            return
        tb := this.TitleBars[hwnd]
        
        mouseY := lp >> 16
        
        if (mouseY <= tb.Height) {
            for name, ctrl in tb.Buttons {
                if (ControlGetFocus(hwnd) == ctrl.Hwnd)
                    return
            }
            PostMessage(0x00A1, 2,,, "ahk_id " hwnd) ; WM_NCLBUTTONDOWN with HTCAPTION
        }
    }

    static WM_MOUSEMOVE(wp, lp, msg, hwnd) {
        if !this.TitleBars.Has(hwnd)
            return
        tb := this.TitleBars[hwnd]
        
        MouseGetPos ,,, &ctrlHwnd, 2
        
        for name, ctrl in tb.Buttons {
            if (ctrl.Hwnd == ctrlHwnd) {
                if (name == "Close")
                    ctrl.Opt("+BackgroundE81123") ; Windows Red highlight for close
                else
                    ctrl.Opt("+Background333333") ; Dark gray highlight for minimize/maximize
            } else {
                ctrl.Opt("BackgroundTrans") ; Reset back to transparent
            }
        }
    }
}