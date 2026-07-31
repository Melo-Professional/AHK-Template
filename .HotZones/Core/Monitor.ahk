#Requires AutoHotkey v2.0

; Core\Monitor.ahk
; Handles retrieving monitor dimensions and active monitor for a point or window

class Monitor {
    
    ; Get information for all monitors
    static GetAll() {
        monitors := []
        count := MonitorGetCount()
        loop count {
            local wl, wt, wr, wb, l, t, r, b
            MonitorGetWorkArea(A_Index, &wl, &wt, &wr, &wb)
            MonitorGet(A_Index, &l, &t, &r, &b)
            monitors.Push({
                Index: A_Index,
                Primary: MonitorGetPrimary() == A_Index,
                Left: l, Top: t, Right: r, Bottom: b,
                WorkLeft: wl, WorkTop: wt, WorkRight: wr, WorkBottom: wb,
                Width: wr - wl,
                Height: wb - wt
            })
        }
        return monitors
    }

    ; Get monitor index from cursor position
    static GetFromCursor() {
        local x, y
        MouseGetPos(&x, &y)
        return this.GetFromPoint(x, y)
    }

    ; Get monitor index from a point
    static GetFromPoint(x, y) {
        count := MonitorGetCount()
        loop count {
            local l, t, r, b
            MonitorGet(A_Index, &l, &t, &r, &b)
            if (x >= l && x <= r && y >= t && y <= b) {
                return A_Index
            }
        }
        return MonitorGetPrimary() ; fallback
    }

    ; Get monitor info by index
    static GetInfo(index) {
        try {
            local wl, wt, wr, wb
            MonitorGetWorkArea(index, &wl, &wt, &wr, &wb)
            return {
                Index: index,
                WorkLeft: wl, WorkTop: wt, WorkRight: wr, WorkBottom: wb,
                Width: wr - wl,
                Height: wb - wt
            }
        } catch {
            return false
        }
    }

    ; Get monitor index a window is mostly on
    static GetFromWindow(hwnd) {
        if !WinExist("ahk_id " hwnd)
            return MonitorGetPrimary()
        
        local x, y, w, h
        WinGetPos(&x, &y, &w, &h, "ahk_id " hwnd)
        cx := x + (w / 2)
        cy := y + (h / 2)
        return this.GetFromPoint(cx, cy)
    }
}
