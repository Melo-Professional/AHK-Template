/************************************************************************
 * @description OSDCustom
 * @author Melo (melo@meloprofessional.com)
 * @date 2026/05/25
 * @version 1.1.0
 ***********************************************************************/


#Requires AutoHotkey v2.0

Global OSDCustomSettings := {
    UseOSD:                     true,
    Monitor:                    "auto",             ; Options: "auto" (active window monitor), 1, 2, 3, etc. Falls back to Primary if invalid.
    MinWidth:                   20,
    MaxWidth:                   600,
    FontSize:                   11,
    TimeOut:                    1800,
    Speed:                      4,                  ; Pixels moved per tick
    Position:                   "x0.50 y0.50",
    SlideDistance:              30,
    FontName:                   "Cascadia Mono",    ; monospace fonts = Cascadia Mono, Consolas, Courier, Courier New, Fixedsys, Lucida Console, and Terminal
    FontWeight:                 1000,               ; Standard Windows weights: 400=Normal, 700=Bold, 1000=Ultra-Bold
    MarginX:                    24,
    MarginY:                    16,
    Opacity:                    245,
    RoundedCorners:             15,
    ProgressMaxValue:           100
}
/**
 * Displays the custom animated OSD on the designated target monitor.
 * @param {String} text - The text content to display inside the OSD. Defaults to A_LineFile.
 * @param {String} position - Percentage-based location (e.g., "x0.50 y0.85"). Defaults to OSDSettings.Position.
 * @param {Integer} duration - Time in ms before sliding away. Set to 0 for a permanent window.
 */
class OSDCustom {

    __New(title := "Custom OSD", options := "-Caption +AlwaysOnTop +ToolWindow +E0x20 -DPIScale") {
        this.Title := title
        this.Options := options
        this.MyGui := ""
        this.TextCtrl := "" 
        
        ; Animation & Opacity Properties
        this.State := "Hidden" 
        this.PosX := 0
        this.CurrentY := 0
        this.StartY := 0
        this.FinalY := 0
        this.CurrentAlpha := 0
        this.AlphaStep := 0
        
        ; Pre-bind timer callbacks for SlideIn / SlideOut 
        this.SlideInCb := ObjBindMethod(this, "AnimateSlideIn")
        this.SlideOutCb := ObjBindMethod(this, "AnimateSlideOut")
        this.DestroyCb := ObjBindMethod(this, "Destroy")
    }

    /**
     * Displays the custom animated OSD on the designated target monitor.
     * @param {String} text - The text content to display inside the OSD. Defaults to A_LineFile.
     * @param {String} position - Percentage-based location (e.g., "x0.50 y0.85"). Defaults to OSDSettings.Position.
     * @param {Integer} duration - Time in ms before sliding away. Set to 0 for a permanent window.
     */
    Show(text := A_LineFile, position := "", duration := "") {
        if (position == "")
            position := OSDCustomSettings.Position
        if (duration == "") 
            duration := OSDCustomSettings.TimeOut

        ; 1. Calculate text sizes using the Windows GDI API (Accounts for FontWeight)
        textBounds := this.CalculateTextSize(text, OSDCustomSettings.FontName, OSDCustomSettings.FontSize, OSDCustomSettings.FontWeight, OSDCustomSettings.MaxWidth - (OSDCustomSettings.MarginX * 2))
        
        idealGuiWidth := textBounds.W + (OSDCustomSettings.MarginX * 2)
        finalGuiWidth := Max(OSDCustomSettings.MinWidth, Min(idealGuiWidth, OSDCustomSettings.MaxWidth))
        finalTextWidth := finalGuiWidth - (OSDCustomSettings.MarginX * 2)

        ; 2. Create or update the GUI structure cleanly
        if (!this.MyGui) {
            this.MyGui := Gui(this.Options, this.Title)
            this.MyGui.OnEvent("Close", (*) => this.Destroy())

            ; shadow
            DllCall("User32.dll\SetClassLongPtr", "Ptr", this.MyGui.Hwnd, "Int", -26, "Ptr", DllCall("User32.dll\GetClassLongPtr", "Ptr", this.MyGui.Hwnd, "Int", -26, "Ptr") | 0x00020000)
            
            this.MyGui.MarginX := OSDCustomSettings.MarginX
            this.MyGui.MarginY := OSDCustomSettings.MarginY
            
            ; Dynamically pass structural FontWeight to AHK styling layer
            this.MyGui.SetFont("s" OSDCustomSettings.FontSize " w" OSDCustomSettings.FontWeight, OSDCustomSettings.FontName)
            this.TextCtrl := this.MyGui.AddText("w" finalTextWidth " h" textBounds.H " Center", text)
        } else {
            ; Cancel any pending auto-destruction timers since we are refreshing content
            SetTimer(this.DestroyCb, 0) 
            
            this.TextCtrl.Move(,, finalTextWidth, textBounds.H)
            this.TextCtrl.Value := text
        }

        ; 3. Render hidden to compute actual layout shapes
        this.MyGui.Show("w" finalGuiWidth " h" (textBounds.H + (OSDCustomSettings.MarginY * 2)) " Hide")
        this.MyGui.GetPos(,, &guiWidth, &guiHeight)

        if (OSDCustomSettings.RoundedCorners > 0) {
            hRgn := DllCall("CreateRoundRectRgn", "Int", 0, "Int", 0, "Int", guiWidth, "Int", guiHeight, "Int", OSDCustomSettings.RoundedCorners, "Int", OSDCustomSettings.RoundedCorners, "Ptr")
            DllCall("SetWindowRgn", "Ptr", this.MyGui.Hwnd, "Ptr", hRgn, "Int", true)
        }

        ; Initialize coordinate variables explicitly so compilation scopes match
        monLeft := 0, monTop := 0, monRight := 0, monBottom := 0
        targetMonIndex := 1 
        
        ; 4. SMART MONITOR DETECTION & RESOLUTION RETRIEVAL
        if (StrLower(OSDCustomSettings.Monitor) == "auto") {
            activeWin := WinExist("A")
            if (activeWin) {
                try targetMonIndex := this.GetMonitorFromWindow(activeWin)
            }
        } else if IsInteger(OSDCustomSettings.Monitor) {
            if (OSDCustomSettings.Monitor <= MonitorGetCount() && OSDCustomSettings.Monitor > 0) {
                targetMonIndex := OSDCustomSettings.Monitor
            }
        }

        ; Fetch the working boundaries (excludes taskbars) via native v2 commands
        try {
            MonitorGetWorkArea(targetMonIndex, &monLeft, &monTop, &monRight, &monBottom)
        } catch {
            MonitorGetWorkArea(1, &monLeft, &monTop, &monRight, &monBottom)
        }

        monWidth := monRight - monLeft
        monHeight := monBottom - monTop

        ; 5. Parse screen positions relative to the target monitor's bounding box
        targetX := monLeft + (monWidth * 0.5)
        targetY := monTop + (monHeight * 0.5)
        
        if RegExMatch(position, "i)x([\d\.]+)", &matchX)
            targetX := monLeft + (monWidth * Float(matchX[1]))
        if RegExMatch(position, "i)y([\d\.]+)", &matchY)
            targetY := monTop + (monHeight * Float(matchY[1]))

        this.PosX := Max(monLeft, Min(targetX - Integer(guiWidth / 2), monRight - guiWidth))
        this.FinalY := Max(monTop, Min(targetY - Integer(guiHeight / 2), monBottom - guiHeight))

        ; 6. Determine animation vectors relative to monitor height split lines
        this.IsBottomHalf := (this.FinalY >= (monTop + (monHeight / 2) - guiHeight / 2))
        this.StartY := this.IsBottomHalf ? (this.FinalY + OSDCustomSettings.SlideDistance) : (this.FinalY - OSDCustomSettings.SlideDistance)

        totalTicks := OSDCustomSettings.SlideDistance / OSDCustomSettings.Speed
        this.AlphaStep := OSDCustomSettings.Opacity / totalTicks

        ; 7. Execution state routing logic
        if (this.State == "Hidden" || this.State == "SlidingOut") {
            SetTimer(this.SlideOutCb, 0) 
            
            this.CurrentY := this.StartY
            this.CurrentAlpha := 0
            WinSetTransparent(Integer(this.CurrentAlpha), this.MyGui.Hwnd)
            
            DllCall("SetWindowPos", "Ptr", this.MyGui.Hwnd, "Ptr", -1, "Int", this.PosX, "Int", this.CurrentY, "Int", 0, "Int", 0, "UInt", 0x0051)
            
            this.State := "SlidingIn"
            this.TargetDuration := duration 
            SetTimer(this.SlideInCb, 5) 
        }
        else if (this.State == "Visible" || this.State == "SlidingIn") {
            this.CurrentY := this.FinalY
            this.CurrentAlpha := OSDCustomSettings.Opacity
            WinSetTransparent(Integer(this.CurrentAlpha), this.MyGui.Hwnd)
            DllCall("SetWindowPos", "Ptr", this.MyGui.Hwnd, "Ptr", -1, "Int", this.PosX, "Int", this.CurrentY, "Int", 0, "Int", 0, "UInt", 0x0051)
            
            this.State := "Visible"
            if (duration > 0)
                SetTimer(this.DestroyCb, -duration)
        }
    }

    ; Internal helper to confidently translate a Window Handle (HWND) into an AHK Monitor Number index
    GetMonitorFromWindow(hwnd) {
        hMonitor := DllCall("User32.dll\MonitorFromWindow", "Ptr", hwnd, "UInt", 2, "Ptr") ; MONITOR_DEFAULTTONEAREST
        loop MonitorGetCount() {
            if (this.GetMonitorHandle(A_Index) == hMonitor)
                return A_Index
        }
        return 1
    }

    ; Internal helper to grab internal Win32 monitor handles for hardware index verification loops
    GetMonitorHandle(monitorIndex) {
        static DISPLAY_DEVICE_SIZE := 424
        dd := Buffer(DISPLAY_DEVICE_SIZE, 0)
        NumPut("UInt", DISPLAY_DEVICE_SIZE, dd, 0)
        
        if DllCall("User32.dll\EnumDisplayDevicesW", "Ptr", 0, "UInt", monitorIndex - 1, "Ptr", dd, "UInt", 0) {
            deviceName := StrGet(dd.Ptr + 4, 32, "UTF-16")
            return DllCall("User32.dll\CreateDCW", "Str", deviceName, "Ptr", 0, "Ptr", 0, "Ptr", 0, "Ptr")
        }
        return 0
    }

/**
     * Uses Windows API layout engines to perfectly pre-calculate multi-line text blocks,
     * fully accounting for real-time monitor DPI scaling and font weight metadata.
     */
    CalculateTextSize(text, fontName, fontSize, fontWeight, maxW) {
        hdc := DllCall("GetDC", "Ptr", 0, "Ptr")
        
        ; --- WINDOWS 10 / 4K DPI CORRECTION ---
        ; Instead of assuming a static 96 DPI (100% scale), fetch the actual system DPI 
        ; of the current display context (e.g., returns 168 DPI when scaling is set to 175%).
        logPixelsY := DllCall("GetDeviceCaps", "Ptr", hdc, "Int", 90) ; 90 = LOGPIXELSY
        
        ; Use the retrieved logPixelsY value to dynamically compute the true font height metrics
        hFont := DllCall("CreateFont", "Int", -DllCall("MulDiv", "Int", fontSize, "Int", logPixelsY, "Int", 72), "Int", 0, "Int", 0, "Int", 0, "Int", fontWeight, "UInt", 0, "UInt", 0, "UInt", 0, "UInt", 0, "UInt", 0, "UInt", 0, "UInt", 0, "UInt", 0, "Str", fontName, "Ptr")
        ; -------------------------------------
        
        obm := DllCall("SelectObject", "Ptr", hdc, "Ptr", hFont, "Ptr")
        
        RECT := Buffer(16, 0)
        NumPut("Int", maxW, RECT, 8) 
        
        ; 0x450 flags = DT_CALCRECT + DT_WORDBREAK + DT_EXPANDTABS
        DllCall("User32.dll\DrawText", "Ptr", hdc, "Str", text, "Int", -1, "Ptr", RECT, "UInt", 0x450)
        
        DllCall("SelectObject", "Ptr", hdc, "Ptr", obm)
        DllCall("DeleteObject", "Ptr", hFont)
        DllCall("ReleaseDC", "Ptr", 0, "Ptr", hdc)
        
        w := NumGet(RECT, 8, "Int") - NumGet(RECT, 0, "Int")
        h := NumGet(RECT, 12, "Int") - NumGet(RECT, 4, "Int")
        return {W: w, H: h}
    }

    AnimateSlideIn() {
        reachedTarget := false
        if (this.IsBottomHalf) {
            this.CurrentY -= OSDCustomSettings.Speed 
            if (this.CurrentY <= this.FinalY) {
                this.CurrentY := this.FinalY
                reachedTarget := true
            }
        } else {
            this.CurrentY += OSDCustomSettings.Speed 
            if (this.CurrentY >= this.FinalY) {
                this.CurrentY := this.FinalY
                reachedTarget := true
            }
        }
        this.CurrentAlpha := Min(OSDCustomSettings.Opacity, this.CurrentAlpha + this.AlphaStep)
        WinSetTransparent(Integer(this.CurrentAlpha), this.MyGui.Hwnd)
        DllCall("SetWindowPos", "Ptr", this.MyGui.Hwnd, "Ptr", -1, "Int", this.PosX, "Int", this.CurrentY, "Int", 0, "Int", 0, "UInt", 0x0051)
        
        if (reachedTarget) {
            SetTimer(this.SlideInCb, 0)
            this.State := "Visible"
            WinSetTransparent(OSDCustomSettings.Opacity, this.MyGui.Hwnd)
            
            ; Only schedule standard timed auto-destruct loops if the duration is greater than 0
            if (this.TargetDuration > 0) {
                SetTimer(this.DestroyCb, -this.TargetDuration)
            }
        }
    }

    AnimateSlideOut() {
        reachedTarget := false
        if (this.IsBottomHalf) {
            this.CurrentY += OSDCustomSettings.Speed 
            if (this.CurrentY >= this.StartY) {
                this.CurrentY := this.StartY
                reachedTarget := true
            }
        } else {
            this.CurrentY -= OSDCustomSettings.Speed 
            if (this.CurrentY <= this.StartY) {
                this.CurrentY := this.StartY
                reachedTarget := true
            }
        }
        this.CurrentAlpha := Max(0, this.CurrentAlpha - this.AlphaStep)
        WinSetTransparent(Integer(this.CurrentAlpha), this.MyGui.Hwnd)
        DllCall("SetWindowPos", "Ptr", this.MyGui.Hwnd, "Ptr", -1, "Int", this.PosX, "Int", this.CurrentY, "Int", 0, "Int", 0, "UInt", 0x0051)
        
        if (reachedTarget) {
            SetTimer(this.SlideOutCb, 0)
            this.MyGui.Hide()
            this.State := "Hidden"
        }
    }

    /**
     * Instantly updates the text value on screen without recalculating layout boundaries.
     * Use this for high-frequency updates where the text length remains relatively similar.
     * @param {String} newText - The text content to push directly into the GUI control.
     */
    UpdateText(newText) {
        if (this.MyGui && this.TextCtrl && (this.State == "Visible" || this.State == "SlidingIn")) {
            this.TextCtrl.Value := newText
        }
    }

    IsVisible {
        get => (this.State == "Visible" || this.State == "SlidingIn")
    }

    /**
     * Gracefully initiates the slide-out exit sequence. 
     * If the OSD is hidden or already exiting, completely unloads memory handles.
     */
    Destroy() {
        SetTimer(this.DestroyCb, 0) 
        
        if (this.State == "Visible" || this.State == "SlidingIn") {
            this.State := "SlidingOut"
            SetTimer(this.SlideInCb, 0)
            SetTimer(this.SlideOutCb, 5)
        } else if (this.State == "Hidden" && this.MyGui) {
            this.MyGui.Destroy()
            this.MyGui := ""
        }
    }
}


/* 
EXAMPLES

osd := OSDCustom()

F1:: {
    ; PERMANENT MODE: Setting duration parameter to 0 forces it to sit indefinitely on active monitor
    osd.Show("Permanent OSD HUD Element Activated!", "x0.50 y0.15", 0)
}

F2:: {
    ; Normal timed notification with dynamic text tracking
    osd.Show("Quick Timed Notification that dynamically sets up boundaries and cuts off absolutely nothing!", "x0.50 y0.50", 2500)
}

F3:: {
    ; Forces the current OSD window to smoothly slide out to close, wherever it is located
    osd.Destroy()
}
*/