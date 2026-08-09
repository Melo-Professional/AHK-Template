#Requires AutoHotkey v2.0

class TrayIconHandler {
    ; --- User-Defined Callbacks ---
    OnLeftClick := ""
    OnDoubleClick := ""
    OnRightClick := ""
    OnHover := ""
    OnLeave := ""
    OnWheelUp := ""
    OnWheelDown := ""

    ; --- Internal State Tracking ---
    HoverDelay := 400
    IsHovering := false
    TrayMouseX := 0
    TrayMouseY := 0
    PaddingBase := 24 ; Base padding before DPI scaling
    
    __New(hoverDelayMs := 400) {
        this.HoverDelay := hoverDelayMs
        this.HoverWatchdogObj := this.HoverWatchdog.Bind(this)
        this.LeaveWatchdogObj := this.LeaveWatchdog.Bind(this)
        
        ; 1. Register Messages via MessageManager if available, fallback to standard OnMessage
        if IsSet(MessageManager) {
            MessageManager.Register(0x404, this.HandleTrayMessage.Bind(this)) ;[cite: 3]
            MessageManager.Register(0x020A, this.HandleMouseWheel.Bind(this)) ; WM_MOUSEWHEEL
        } else {
            OnMessage(0x404, this.HandleTrayMessage.Bind(this)) ;[cite: 2]
            OnMessage(0x020A, this.HandleMouseWheel.Bind(this))
        }
        
        ; Query system for default hover time if not explicitly provided
        if (hoverDelayMs == 400) {
            sysHoverTime := 400
            if DllCall("SystemParametersInfo", "UInt", 0x0066, "UInt", 0, "Int*", &sysHoverTime, "UInt", 0) ;[cite: 2]
                this.HoverDelay := sysHoverTime
        }
    }

    ; --- Core Tray Message Handler ---
    HandleTrayMessage(wParam, lParam, msg, hwnd) {
        ; lParam holds the mouse message type when over the tray icon[cite: 2]
        switch lParam {
            case 0x200: ; WM_MOUSEMOVE
                if (!this.IsHovering) {
                    CoordMode("Mouse", "Screen")
                    MouseGetPos(&x, &y)
                    this.TrayMouseX := x
                    this.TrayMouseY := y
                    
                    ; Start checking if the mouse stays over the icon[cite: 2]
                    SetTimer(this.HoverWatchdogObj, -this.HoverDelay) 
                }
            
            case 0x202: ; WM_LBUTTONUP
                if (this.OnLeftClick)
                    this.OnLeftClick()
                    
            case 0x203: ; WM_LBUTTONDBLCLK
                if (this.OnDoubleClick)
                    this.OnDoubleClick()
                    
            case 0x205: ; WM_RBUTTONUP
                if (this.OnRightClick)
                    this.OnRightClick()
        }
    }

    ; --- Mouse Wheel Hook ---
    HandleMouseWheel(wParam, lParam, msg, hwnd) {
        if (!this.IsHovering)
            return

        delta := (wParam >> 16) & 0xFFFF
        if (delta > 0x7FFF) 
            delta -= 0x10000 ;[cite: 2]

        if (delta > 0 && this.OnWheelUp)
            this.OnWheelUp()
        else if (delta < 0 && this.OnWheelDown)
            this.OnWheelDown()
    }

    ; --- Hover & Bounding Box Logic ---
    HoverWatchdog() {
        CoordMode("Mouse", "Screen")
        MouseGetPos(&currentX, &currentY)
        
        if (this.IsOutsideTrayBounds(currentX, currentY))
            return 
            
        this.IsHovering := true
        if (this.OnHover)
            this.OnHover()
            
        SetTimer(this.LeaveWatchdogObj, 100)
    }

    LeaveWatchdog() {
        CoordMode("Mouse", "Screen")
        MouseGetPos(&currentX, &currentY)
        
        if (this.IsOutsideTrayBounds(currentX, currentY)) {
            this.IsHovering := false
            SetTimer(this.LeaveWatchdogObj, 0)
            
            if (this.OnLeave)
                this.OnLeave()
        }
    }

    ; --- DPI & Multi-Monitor Helpers ---
    IsOutsideTrayBounds(x, y) {
        scaleFactor := A_ScreenDPI / 96 ;[cite: 1]
        padding := Floor(this.PaddingBase * scaleFactor)
        
        return (Abs(x - this.TrayMouseX) > padding || Abs(y - this.TrayMouseY) > padding) ;[cite: 1, 2]
    }

    GetTaskbarPosition() {
        CoordMode("Mouse", "Screen")
        MouseGetPos(&x, &y)
        
        monitorNum := this.MonitorGetFromPoint(x, y) ;[cite: 1]
        MonitorGetWorkArea(monitorNum, &wl, &wt, &wr, &wb) ;[cite: 1]
        MonitorGet(monitorNum, &ml, &mt, &mr, &mb) ;[cite: 1]
        
        if (wt > mt)
            return { Pos: "Top", Monitor: monitorNum, X: x, Y: y, BoundingY: wt } ;[cite: 1]
        if (wb < mb)
            return { Pos: "Bottom", Monitor: monitorNum, X: x, Y: y, BoundingY: wb } ;[cite: 1]
        if (wl > ml)
            return { Pos: "Left", Monitor: monitorNum, X: x, Y: y, BoundingX: wl }
        if (wr < mr)
            return { Pos: "Right", Monitor: monitorNum, X: x, Y: y, BoundingX: wr }
            
        return { Pos: "Bottom", Monitor: monitorNum, X: x, Y: y, BoundingY: mb }
    }

    MonitorGetFromPoint(X, Y) {
        monitorCount := MonitorGetCount()
        Loop monitorCount {
            MonitorGet(A_Index, &Left, &Top, &Right, &Bottom)
            if (X >= Left && X <= Right && Y >= Top && Y <= Bottom)
                return A_Index ;[cite: 1]
        }
        return MonitorGetPrimary() ;[cite: 1]
    }
}