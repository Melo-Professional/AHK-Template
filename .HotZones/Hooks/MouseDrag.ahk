#Requires AutoHotkey v2.0

; Hooks\MouseDrag.ahk
; Detects when the user is dragging a window and holding Shift

class MouseDragHook {
    static IsDragging := false
    static DragHwnd := 0
    static MonitorTimer := 0

    static Start() {
        ; Register ~LButton to detect clicks without blocking them
        Hotkey("~LButton", ObjBindMethod(this, "OnLButtonDown"))
    }

    static Stop() {
        Hotkey("~LButton", "Off")
    }

    static OnLButtonDown(*) {
        ; Check if cursor is over a title bar (HTCAPTION = 2)
        CoordMode("Mouse", "Screen")
        local x, y, hwnd
        MouseGetPos(&x, &y, &hwnd)

        ; SendMessage 0x84 is WM_NCHITTEST
        lParam := ((y & 0xFFFF) << 16) | (x & 0xFFFF)
        hit := SendMessage(0x84, 0, lParam, , "ahk_id " hwnd)
        
        if (hit != 2) {
            WinGetPos(&wx, &wy, &ww, &wh, "ahk_id " hwnd)
            if (y >= wy && y <= wy + 40)
                hit := 2
        }
        
        if (hit == 2 && WindowManager.IsSnappable(hwnd)) {
            ; Start monitoring the drag
            this.DragHwnd := hwnd
            this.IsDragging := true
            SetTimer(ObjBindMethod(this, "MonitorDrag"), 16) ; ~60fps
        }
    }

    static MonitorDrag() {
        ; If user released left click, stop monitoring
        if !GetKeyState("LButton", "P") {
            SetTimer(ObjBindMethod(this, "MonitorDrag"), 0)
            this.IsDragging := false
            
            if (Overlay.ActiveMonitor != -1) {
                zone := Overlay.ActiveZone
                Overlay.Hide()
                if (zone > 0) {
                    WindowManager.SnapWindow(this.DragHwnd, zone)
                }
            }
            this.DragHwnd := 0
            return
        }

        ; If user is holding shift, show the overlay (or if SnapOnShift is disabled, show it always)
        snapOnShift := Config.Settings["SnapOnShift"]
        isShiftDown := GetKeyState("Shift", "P")

        if (snapOnShift && !isShiftDown) {
            Overlay.Hide()
            return
        }

        ; Determine which monitor the cursor is on
        monIdx := Monitor.GetFromCursor()
        Overlay.Show(monIdx)

        ; Determine which zone the cursor is hovering
        hoverZone := WindowManager.GetZoneFromCursor()
        Overlay.UpdateActiveZone(hoverZone)
    }
}
