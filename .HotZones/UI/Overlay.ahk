#Requires AutoHotkey v2.0

; UI\Overlay.ahk
; Transparent overlay that draws the zones when a window is being dragged

class Overlay {
    static guiObj := 0
    static hGui := 0
    static pGraphics := 0
    static ActiveMonitor := -1
    static ActiveZone := 0

    static Initialize() {
        if this.hGui
            return

        ; Create an explicitly borderless, layered, click-through GUI
        this.guiObj := Gui("+E0x80000 +E0x20 -Caption +AlwaysOnTop +ToolWindow -DPIScale")
        this.guiObj.BackColor := "Black"
        WinSetTransparent(255, this.guiObj.Hwnd)
        this.hGui := this.guiObj.Hwnd
    }

    static Alpha := 0
    static TargetAlpha := 0

    static Show(monitorIndex) {
        if !this.guiObj
            this.Initialize()

        if (this.ActiveMonitor == monitorIndex)
            return

        this.ActiveMonitor := monitorIndex
        mInfo := Monitor.GetInfo(monitorIndex)

        if (!mInfo)
            return

        ; Update zones based on current monitor
        WindowManager.CalculateZones(mInfo)
        this.ActiveZone := 0

        ; Show layered window spanning the whole monitor work area
        this.guiObj.Show("Hide x" mInfo.WorkLeft " y" mInfo.WorkTop " w" mInfo.Width " h" mInfo.Height)

        DetectHiddenWindows True
        WinSetTransparent(this.Alpha, this.hGui)
        DetectHiddenWindows False

        this.guiObj.Show("NA")

        this.TargetAlpha := 50
        SetTimer(ObjBindMethod(this, "Fade"), 16)

        ; Setup GDI+
        if this.pGraphics
            Gdip_DeleteGraphics(this.pGraphics)

        this.pGraphics := Gdip_GraphicsFromHWND(this.hGui)
        Gdip_SetSmoothingMode(this.pGraphics, 4) ; Anti-alias

        this.Redraw()
    }

    static Hide() {
        if !this.hGui || this.TargetAlpha == 0
            return

        this.TargetAlpha := 0
        SetTimer(ObjBindMethod(this, "Fade"), 16)
    }

    static Fade() {
        if !this.hGui
            return

        step := 30
        if (this.Alpha < this.TargetAlpha)
            this.Alpha := Min(this.Alpha + step, this.TargetAlpha)
        else if (this.Alpha > this.TargetAlpha)
            this.Alpha := Max(this.Alpha - step, this.TargetAlpha)

        WinSetTransparent(this.Alpha, this.hGui)

        if (this.Alpha == this.TargetAlpha) {
            SetTimer(ObjBindMethod(this, "Fade"), 0)
            if (this.Alpha == 0) {
                if this.pGraphics {
                    Gdip_GraphicsClear(this.pGraphics, 0)
                    Gdip_DeleteGraphics(this.pGraphics)
                    this.pGraphics := 0
                }
                this.guiObj.Hide()
                this.ActiveMonitor := -1
                this.ActiveZone := 0
            }
        }
    }

    static UpdateActiveZone(zoneIndex) {
        if (this.ActiveZone == zoneIndex)
            return

        this.ActiveZone := zoneIndex
        this.Redraw()
    }

    static Redraw() {
        if !this.pGraphics
            return

        ; Clear graphics
        Gdip_GraphicsClear(this.pGraphics, 0)

        ; Colors
        ThemeMode := Config.Settings["Theme"]
        ; Adjust colors based on theme, simplified for now
        ; ARGB
        cNormalFill := 0x40000000   ; 25% Opacity Black
        cNormalBorder := 0x80FFFFFF ; 50% Opacity White
        cActiveFill := 0x800078D7   ; Windows Blue
        cActiveBorder := 0xFF0078D7

        bNormal := Gdip_BrushCreateSolid(cNormalFill)
        pNormal := Gdip_PenCreateSolid(cNormalBorder, 2)
        bActive := Gdip_BrushCreateSolid(cActiveFill)
        pActive := Gdip_PenCreateSolid(cActiveBorder, 3)

        ; Draw zones - no padding, no rounding to ensure gap-free rendering
        mInfo := Monitor.GetInfo(this.ActiveMonitor)

        ; Pass 1: Fill all zones (no borders to avoid double-line gaps between adjacent zones)
        for i, zone in WindowManager.CurrentZones {
            relX := zone.X - mInfo.WorkLeft
            relY := zone.Y - mInfo.WorkTop
            relW := zone.W
            relH := zone.H

            if (i == this.ActiveZone) {
                Gdip_FillRectangle(this.pGraphics, bActive, relX, relY, relW, relH)
            } else {
                Gdip_FillRectangle(this.pGraphics, bNormal, relX, relY, relW, relH)
            }
        }

        ; Pass 2: Draw subtle separators and active zone border on top
        pSep := Gdip_PenCreateSolid(0x30FFFFFF, 1) ; Very subtle 1px separator
        for i, zone in WindowManager.CurrentZones {
            relX := zone.X - mInfo.WorkLeft
            relY := zone.Y - mInfo.WorkTop
            relW := zone.W
            relH := zone.H
            Gdip_DrawRectangle(this.pGraphics, pSep, relX, relY, relW, relH)
        }
        Gdip_DeletePen(pSep)

        if (this.ActiveZone >= 1 && this.ActiveZone <= WindowManager.CurrentZones.Length) {
            az := WindowManager.CurrentZones[this.ActiveZone]
            relX := az.X - mInfo.WorkLeft
            relY := az.Y - mInfo.WorkTop
            Gdip_DrawRectangle(this.pGraphics, pActive, relX, relY, az.W, az.H)
        }

        ; Cleanup
        Gdip_DeleteBrush(bNormal)
        Gdip_DeletePen(pNormal)
        Gdip_DeleteBrush(bActive)
        Gdip_DeletePen(pActive)
    }
}