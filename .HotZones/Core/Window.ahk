#Requires AutoHotkey v2.0

; Core\Window.ahk
; Handles window manipulation and snapping logic

class WindowManager {
    
    ; Array of zone rectangles for the current active grid
    static CurrentZones := []

    ; Calculates zones based on the current profile and monitor
    static CalculateZones(monitorInfo) {
        this.CurrentZones := []
        profile := Config.Profiles[Config.CurrentProfile]
        
        for i, z in profile.Zones {
            ; Use Floor for pixel-precise integer coordinates (no sub-pixel gaps)
            zx := monitorInfo.WorkLeft + Floor(monitorInfo.Width * z.X)
            zy := monitorInfo.WorkTop + Floor(monitorInfo.Height * z.Y)
            ; Compute right/bottom edge and derive W/H for gapless tiling
            zRight := monitorInfo.WorkLeft + Floor(monitorInfo.Width * (z.X + z.W))
            zBottom := monitorInfo.WorkTop + Floor(monitorInfo.Height * (z.Y + z.H))
            zw := zRight - zx
            zh := zBottom - zy
            
            this.CurrentZones.Push({
                X: zx,
                Y: zy,
                W: zw,
                H: zh
            })
        }
        return this.CurrentZones
    }

    ; Find which zone intersects mostly with the cursor
    static GetZoneFromCursor() {
        CoordMode("Mouse", "Screen")
        local cx, cy
        MouseGetPos(&cx, &cy)
        for i, zone in this.CurrentZones {
            if (cx >= zone.X && cx <= zone.X + zone.W && cy >= zone.Y && cy <= zone.Y + zone.H) {
                return i
            }
        }
        return 0
    }

    ; Snaps the given window to the specified zone index
    static SnapWindow(hwnd, zoneIndex) {
        if (zoneIndex < 1 || zoneIndex > this.CurrentZones.Length)
            return

        zone := this.CurrentZones[zoneIndex]
        
        if (WinGetMinMax("ahk_id " hwnd) = 1) {
            WinRestore("ahk_id " hwnd)
        }

        ; Compensate for invisible window borders on Windows 10/11
        rect := Buffer(16, 0)
        DllCall("dwmapi\DwmGetWindowAttribute", "Ptr", hwnd, "UInt", 9, "Ptr", rect, "UInt", 16)
        
        WinGetPos(&wx, &wy, &ww, &wh, "ahk_id " hwnd)
        
        dwmLeft := NumGet(rect, 0, "Int")
        dwmTop := NumGet(rect, 4, "Int")
        dwmRight := NumGet(rect, 8, "Int")
        dwmBottom := NumGet(rect, 12, "Int")
        
        dwmWidth := dwmRight - dwmLeft
        dwmHeight := dwmBottom - dwmTop
        
        offsetX := dwmLeft - wx
        offsetY := dwmTop - wy
        diffW := ww - dwmWidth
        diffH := wh - dwmHeight
        
        targetX := zone.X - offsetX
        targetY := zone.Y - offsetY
        targetW := zone.W + diffW
        targetH := zone.H + diffH
        
        WinMove(targetX, targetY, targetW, targetH, "ahk_id " hwnd)
    }

    ; Determines if a window is snappable (not a desktop, taskbar, tool window)
    static IsSnappable(hwnd) {
        if !hwnd
            return false
        
        ; Must be visible
        if !DllCall("IsWindowVisible", "Ptr", hwnd)
            return false
            
        ; Exclude certain classes
        class := WinGetClass("ahk_id " hwnd)
        if (class = "WorkerW" || class = "Progman" || class = "Shell_TrayWnd" || class = "Windows.UI.Core.CoreWindow")
            return false
            
        ; Must have caption / title bar
        style := WinGetStyle("ahk_id " hwnd)
        if !(style & 0xC00000) ; WS_CAPTION
            return false
            
        return true
    }
}
