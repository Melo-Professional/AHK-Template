/************************************************************************
 * @description Acrylic Theme
 * @author Melo (melo@meloprofessional.com)
 * @credits Owhs at https://www.autohotkey.com/boards/viewtopic.php?style=2&p=617944#p617944
 * @date 2026/07/14
 * @version 1.1.0
 ***********************************************************************/


/* HOW TO USE IT
; Create a standard AHK GUI
MyGui := Gui("+Resize", "My Frosted App")

; Apply the theme with a single class call
FrostedTheme.Apply(MyGui)

; Add some white text
MyGui.SetFont("s20 cWhite bold", "Segoe UI")
MyGui.Add("Text", "BackgroundTrans Center w260 y40", "Class Applied!")

MyGui.SetFont("s12 cWhite", "Segoe UI")
MyGui.Add("Button", "w100 x100 y120", "Click Me")

MyGui.OnEvent("Close", (*) => ExitApp())
MyGui.Show("w300 h200")

*/


class FrostedTheme {
    static RegisteredGuis := Map()
    static ChildGuis := Map()

    static Apply(guiObj, childGuiObj := "") {
        if !IsObject(guiObj) || !guiObj.Hwnd
            return

        hwnd := guiObj.Hwnd
        
        if (this.RegisteredGuis.Count = 0) {
            OnMessage(0x0018, this.OnShowWindow.Bind(this))  ; WM_SHOWWINDOW
            OnMessage(0x001A, this.OnThemeChange.Bind(this)) ; WM_SETTINGCHANGE
            OnMessage(0x031A, this.OnThemeChange.Bind(this)) ; WM_THEMECHANGED
        }
        this.RegisteredGuis[hwnd] := guiObj

        ; Store associated child GUI if provided
        if (IsObject(childGuiObj) && childGuiObj.Hwnd)
            this.ChildGuis[hwnd] := childGuiObj

        this.ApplyStyles(hwnd, guiObj)
    }

    static ApplyStyles(hwnd, guiObj) {
        ; --- FORCE DWM RESET ---
        ; DWM optimizes out calls if the value hasn't changed. We must set it to DWMSBT_NONE (1)
        ; before setting it back to Acrylic (3) to guarantee DWM throws away the broken opaque 
        ; surface and compiles a fresh acrylic shader when the OS theme changes.
        DllCall("dwmapi\DwmSetWindowAttribute", "Ptr", hwnd, "UInt", 38, "Int*", 1, "UInt", 4)
        
        ; Dark titlebar (DWMWA_USE_IMMERSIVE_DARK_MODE)
        DllCall("dwmapi\DwmSetWindowAttribute", "Ptr", hwnd, "UInt", 20, "Int*", 1, "UInt", 4)

        ; Acrylic backdrop (DWMWA_SYSTEMBACKDROP_TYPE = 3)
        DllCall("dwmapi\DwmSetWindowAttribute", "Ptr", hwnd, "UInt", 38, "Int*", 3, "UInt", 4)

        ; Extend DWM frame into entire client area so acrylic fills the window
        margins := Buffer(16, 0)
        NumPut("Int", -1, margins, 0)
        NumPut("Int", -1, margins, 4)
        NumPut("Int", -1, margins, 8)
        NumPut("Int", -1, margins, 12)
        DllCall("dwmapi\DwmExtendFrameIntoClientArea", "Ptr", hwnd, "Ptr", margins)

        ; Black background: DWM treats pure black as transparent to reveal the acrylic
        guiObj.BackColor := "000000"

        ; Force DWM to recompose
        DllCall("dwmapi\DwmFlush")
        DllCall("user32\RedrawWindow", "Ptr", hwnd, "Ptr", 0, "Ptr", 0, "UInt", 0x0587)

        ; Apply black background to associated child window
        if (this.ChildGuis.Has(hwnd)) {
            child := this.ChildGuis[hwnd]
            if (child && child.Hwnd) {
                child.BackColor := "000000"
                DllCall("user32\RedrawWindow", "Ptr", child.Hwnd, "Ptr", 0, "Ptr", 0, "UInt", 0x0587)
            }
        }
    }

    static OnShowWindow(wp, lp, msg, hwnd) {
        if (wp && this.RegisteredGuis.Has(hwnd)) {  ; wp == 1 when showing
            guiObj := this.RegisteredGuis[hwnd]
            this.ApplyStyles(hwnd, guiObj)
        }
    }

    static ReapplyCallback := ""

    static OnThemeChange(wp, lp, msg, hwnd) {
        if !this.ReapplyCallback
            this.ReapplyCallback := this.ReapplyAll.Bind(this)
        ; Use a 500ms debounce timer to wait for the system theme change to fully settle
        SetTimer(this.ReapplyCallback, -1500)
    }

    static ReapplyAll() {
        for registeredHwnd, guiObj in this.RegisteredGuis {
            if WinExist(registeredHwnd) {
                cb := this.ApplyStyles.Bind(this, registeredHwnd, guiObj)
                this.ForceDWMCompilation(guiObj, cb)
            }
        }
    }
    
    static ForceDWMCompilation(guiObj, applyStylesCallback := "") {
        if (!IsObject(guiObj) || !guiObj.Hwnd || !WinExist(guiObj.Hwnd))
            return
            
        hwnd := guiObj.Hwnd
        prevFocus := WinExist("A")
        
        guiObj.GetPos(&X, &Y)
        wasHidden := (X <= -32000 || Y <= -32000)
        
        if (wasHidden) {
            vx := SysGet(76), vy := SysGet(77), vw := SysGet(78), vh := SysGet(79)
            guiObj.Move(vx + vw - 1, vy + vh - 1)
        }
        
        try WinActivate(hwnd)
        
        if (applyStylesCallback)
            applyStylesCallback()
            
        DllCall("dwmapi\DwmFlush")
        Sleep(50) ; Crucial to wait for DWM to compile the shader
        
        if (wasHidden) {
            guiObj.Move(-32000, -32000)
        }
        
        if (prevFocus)
            try WinActivate(prevFocus)
    }
}