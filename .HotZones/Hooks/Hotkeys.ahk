#Requires AutoHotkey v2.0

; Hooks\Hotkeys.ahk
; Manages keyboard shortcuts for zone navigation and editor launching

class HotkeysHook {

    static Start() {
        ; Win + Shift + ` to open Grid Editor
        Hotkey("#+``", ObjBindMethod(this, "OpenEditor"))

        ; Win + Arrows for zone snapping
        Hotkey("#Left", ObjBindMethod(this, "SnapLeft"))
        Hotkey("#Right", ObjBindMethod(this, "SnapRight"))
        Hotkey("#Up", ObjBindMethod(this, "SnapUp"))
        Hotkey("#Down", ObjBindMethod(this, "SnapDown"))
    }

    static OpenEditor(*) {
        GridEditor.Show()
    }

    static GetActiveWindowAndZone(&hwnd, &currentZoneIndex) {
        hwnd := WinGetID("A")
        if !WindowManager.IsSnappable(hwnd)
            return false

        ; Ensure zones are calculated for the monitor the window is on
        monIdx := Monitor.GetFromWindow(hwnd)
        mInfo := Monitor.GetInfo(monIdx)
        WindowManager.CalculateZones(mInfo)

        ; Try to find which zone the window is currently in by checking its center
        local wx, wy, ww, wh
        WinGetPos(&wx, &wy, &ww, &wh, "ahk_id " hwnd)
        cx := wx + (ww / 2)
        cy := wy + (wh / 2)

        currentZoneIndex := 0
        for i, zone in WindowManager.CurrentZones {
            if (cx >= zone.X && cx <= zone.X + zone.W && cy >= zone.Y && cy <= zone.Y + zone.H) {
                currentZoneIndex := i
                break
            }
        }
        return true
    }

    static MoveZone(dir) {
        if (!Config.Settings["OverrideSnap"]) {
            ; Fallback to standard Windows snap (pass the key through)
            key := (dir == -1) ? "Left" : (dir == 1) ? "Right" : (dir == -2) ? "Up" : "Down"
            Send("{Blind}#" key)
            return
        }

        if !this.GetActiveWindowAndZone(&hwnd, &currentZoneIndex)
            return

        ; Basic logic: next/prev zone based on index
        ; 1D navigation for simplicity in V1 (Left/Right just cycles)
        maxZones := WindowManager.CurrentZones.Length

        if (currentZoneIndex == 0) {
            targetZone := 1
        } else {
            if (dir == -1 || dir == -2) { ; Left / Up
                targetZone := currentZoneIndex - 1
                if (targetZone < 1)
                    targetZone := maxZones
            } else { ; Right / Down
                targetZone := currentZoneIndex + 1
                if (targetZone > maxZones)
                    targetZone := 1
            }
        }

        WindowManager.SnapWindow(hwnd, targetZone)
    }

    static SnapLeft(*) {
        this.MoveZone(-1)
    }

    static SnapRight(*) {
        this.MoveZone(1)
    }

    static SnapUp(*) {
        this.MoveZone(-2)
    }

    static SnapDown(*) {
        this.MoveZone(2)
    }
}