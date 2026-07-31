;@region Setup
;@region Description
/************************************************************************
 * @description To cycle browser tabs with Mouse wheel.
 * @author Melo (melo@meloprofessional.com)
 * @date 2026/05/18
 * @releasedate 2025/05/06
 * @version 1.3.0
 ***********************************************************************/
;@endregion

;@region Compilation
;@Ahk2Exe-SetName MacMouse
;@Ahk2Exe-SetFileVersion 1.3.0
;@Ahk2Exe-SetCopyright © Melo. All rights reserved.
;@Ahk2Exe-SetProductName MacMouse
;@Ahk2Exe-SetInternalName MacMouse
;@Ahk2Exe-SetCompanyName Melo Professional
;@Ahk2Exe-ExeName MacMouse
;@Ahk2Exe-SetMainIcon MacMouse.ico
;@endregion

;@region Directives
#Requires AutoHotkey v2.0
#SingleInstance Force
SetWorkingDir(A_ScriptDir)
; --- Optimization Settings ---
;ProcessSetPriority("High")
ListLines(False)
KeyHistory(0)

/* 
SendMode("Input")
SetKeyDelay(-1, -1) 
SetMouseDelay(-1)
SetWinDelay(0)
SetControlDelay(0)
SetDefaultMouseSpeed(0)
 */

A_MaxHotkeysPerInterval := 5000
A_HotkeyInterval := 1000

A_IconHidden := true
;@endregion


;@region Configuration
App := {
    Name:                   "MacMouse",
    Description:            "To cycle browser tabs with Mouse wheel.",
    Icon:                   A_IsCompiled ? A_ScriptFullPath : (A_ScriptDir "\MacMouse.ico"),
    Copyright:              "Developed by Melo`nmelo@meloprofessional.com`n©Melo. All rights reserved.",
    Version:                "1.3.0"
}

Settings := {
    ; General GUI
    SplashScreen:               "Icon",       ; "Icon" / "Banner" / "Disabled"
    DesiredTheme:               "Auto",         ; "Auto" / "Light" / "Dark"
    GuiFontSizeSmall:           8,
    GuiFontSizeMedium:          9,
    GuiFontSizeBig:             10,
    GuiFontSizeExtraBig:        14,
    GuiFontName:                "Segoe UI",
    GuiSplashTimer:             500,

; GUI Colors
    Theme: {
        Dark: {
            Bg:                 "202020", 
            TextDefault:        "CCCCCC",
            TextStrong:         "FFFFFF",
            TextSmooth:         "888888" 
        },
        Light: {
            Bg:                 "F0F0F0", 
            TextDefault:        "222222",
            TextStrong:         "000000",
            TextSmooth:         "666666" 
        }
    }
}
;@endregion

;@region Vars
; CUSTOM VARIABLES
Debug                       := false
A_ScriptName                := App.Name
;SaveToINI := [""] ; what to save to INI file
SaveToINI := ["Settings.DesiredTheme", "BaseScrollAmount"] ; what to save to INI file
CurrentActualTheme := "Dark"
global GuiToolTip := false
global UseOSD := false

; --- MOUSETABS RULES ---
global TabAreaHeight    := 50    ; Height in pixels from the top of the window
global EnabledTabApps   := Map(
    "Chrome_WidgetWin_1", true,  ; Chrome, Edge, Brave, Opera, VS Code
    "MozillaWindowClass", true,  ; Firefox
    "Notepad++", true,           ; Notepad++
    "CabinetWClass", true        ; Windows 11 File Explorer
)
Profile := "equilibrium"
ApplyProfile(Profile)
global ProfileList := ["slow", "precise", "equilibrium", "long", "fast", "custom_1", "custom_2"]
ApplyProfile(Profile){
    global

    switch Profile {
        case "slow":
                BaseScrollAmount := 0.170
                Friction         := 1.0869
                FastSpinWindow   := 40.000
                AccelRate        := 3.000
                StopThreshold    := 0.080
        case "precise":
                BaseScrollAmount := 0.170
                Friction         := 1.0869
                FastSpinWindow   := 40.000
                AccelRate        := 8.000
                StopThreshold    := 0.080
        case "equilibrium":
                BaseScrollAmount := 0.170
                Friction         := 1.066
                FastSpinWindow   := 50.000
                AccelRate        := 16.000
                StopThreshold    := 0.101
        case "long":
                BaseScrollAmount := 0.170
                Friction         := 1.0416
                FastSpinWindow   := 50.000
                AccelRate        := 16.000
                StopThreshold    := 0.050
        case "fast":
                BaseScrollAmount := 0.170
                Friction         := 1.066
                FastSpinWindow   := 80.000
                AccelRate        := 25.000
                StopThreshold    := 0.101
        case "custom_1":
                BaseScrollAmount := 0.170
                Friction         := 1.0582
                FastSpinWindow   := 20.000
                AccelRate        := 16.000
                StopThreshold    := 0.100
        case "custom_2":                           ; nota 9
                BaseScrollAmount := 0.25
                Friction         := 1.0526
                FastSpinWindow   := 60
                AccelRate        := 4
                StopThreshold    := 0.07
    }
}

;@endregion

;@region Includes
#Include <SaveSettings>
#Include <Theme>
#Include <SplashScreen>
#Include <SplashIcon>
#Include <About>
#Include <Tweaker>
#Include <Menu>
;@endregion

;@region Startup
; SPLASHSCREEN
switch Settings.SplashScreen {
    case "Icon": SplashIcon.Show()
    case "Banner": Splash.Show()
}

; TRAY ICON + MENU
StartMenu()

;@endregion

switch Settings.SplashScreen {
    case "Icon": SplashIcon.Destroy()
    case "Banner": Splash.Destroy()
}
;@endregion


;@region Main
A_MaxHotkeysPerInterval := 500
A_HotkeyInterval := 1000
global RenderInterval   := 10

; ==============================================================================
; INTERNAL STATE VARIABLES
; ==============================================================================
global CurrentVelocity   := 0.0
global ResidualScroll    := 0.0
global MainLastScrollTime    := 0
global LastScrollTime    := 0
global ScrollTimerActive := false
global LastTimeTimeout := 1000

/* 
*WheelUp:: {
    MainChoose(1)
}

*WheelDown:: {
    MainChoose(-1)
}
 */

$~WheelUp:: {
    MainChoose(1)
}

$~WheelDown:: {
    MainChoose(-1)
}



/* 

$+~WheelUp::
$^~WheelUp::
$!~WheelUp:: {
    Send("{Blind}{WheelUp}")
}

$+~WheelDown::
$^~WheelDown::
$!~WheelDown:: {
    Send("{Blind}{WheelDown}")
}
 */


MainChoose(Direction){
    global MainLastScrollTime

    MainCurrentTime := A_TickCount
    MainTimeDelta := MainCurrentTime - MainLastScrollTime
    MainLastScrollTime := MainCurrentTime
/* 
    ; Check modifiers like Ctrl, Shift or Alt
    if (GetKeyState("Ctrl", "P") || GetKeyState("Shift", "P") || GetKeyState("Alt", "P")) {
        Send(Direction = 1 ? "{Blind}{WheelUp}" : "{Blind}{WheelDown}")
        Debug ? (ToolTip(" CTRL press"), SetTimer(() => ToolTip(), -1000)) : ""
        return
    }
 */
    if MainTimeDelta > LastTimeTimeout {

        MouseGetPos(&mouseXPos, &mouseYPos, &winId)

        ; Check TaskBar
        if MouseIsOverTaskbar(winId){
            MainLastScrollTime := A_TickCount - LastTimeTimeout -1 ; Keep checking mouse
            Debug ? (ToolTip(" TaskBar `n Delta: " MainTimeDelta), SetTimer(() => ToolTip(), -LastTimeTimeout)) : ""
            return
        }

        ; Check Apps
        if CheckCTW(Direction, mouseXPos, mouseYPos, winId){
            MainLastScrollTime := A_TickCount - LastTimeTimeout -1 ; Keep checking mouse
            Debug ? (ToolTip(" CTW `n Delta: " MainTimeDelta), SetTimer(() => ToolTip(), -LastTimeTimeout)) : ""
            return
        }
    }
    HandleScroll(Direction)
}

; ==============================================================================
; SMOOTH PHYSICS ENGINE LOGIC (Original, Fast macmouse)
; ==============================================================================

HandleScroll(Direction) {
    global CurrentVelocity, LastScrollTime, ScrollTimerActive
    global BaseScrollAmount, FastSpinWindow, AccelRate
    
    CurrentTime := A_TickCount
    TimeDelta := CurrentTime - LastScrollTime
    LastScrollTime := CurrentTime
    
    SameDirection := ((Direction = 1 && CurrentVelocity > 0) || (Direction < 0 && CurrentVelocity < 0))
    
    if (SameDirection && TimeDelta < FastSpinWindow) {  ; ACCELERATE
        BoostPercent := (FastSpinWindow - TimeDelta) / FastSpinWindow
        CurrentVelocity += Direction * BaseScrollAmount * (1 + (BoostPercent * AccelRate))
    } else {    ; FIRST WHEEL
        if (!SameDirection) {
            CurrentVelocity := 0
        }
        UseOSD ? UseOSD.Count:=1 : ""
        CurrentVelocity += Direction * BaseScrollAmount
        ;return
    }
    ; ToolTip(CurrentVelocity)
    MaxVelocity := 2080.0
    if (Abs(CurrentVelocity) > MaxVelocity) {
        CurrentVelocity := (CurrentVelocity > 0 ? MaxVelocity : -MaxVelocity)
    }
    
    if (!ScrollTimerActive) {
        ScrollTimerActive := true
        SetTimer(TickScroll, RenderInterval)
    }
}

TickScroll() {
    global CurrentVelocity, ResidualScroll, ScrollTimerActive
    global Friction, RenderInterval, StopThreshold
    
    CurrentVelocity /= Friction
    
    if (Abs(CurrentVelocity) < StopThreshold) {
        CurrentVelocity := 0.0
        ResidualScroll := 0.0
        SetTimer(TickScroll, 0)
        ScrollTimerActive := false
        return
    }
    
    ResidualScroll += CurrentVelocity
    IntScroll := Integer(ResidualScroll)
    
    if (IntScroll != 0) {
        ResidualScroll -= IntScroll
        
        Loop Abs(IntScroll) {
            if (IntScroll > 0) {
;                if (A_Index == 1)       ; BYPASS FIRST WHEEL BECAUSE OF HOTKEY WITH '~'
;                    continue
                SendInput("{WheelUp}")
                UseOSD ? UseOSD.ShowKey("WheelUp") : ""
            } else {
                SendInput("{WheelDown}")
                UseOSD ? UseOSD.ShowKey("WheelDown") : ""
            }
        }
        if GuiToolTip {
            ToolTip(    "`n  CurrentVelocity:    " round(Abs(CurrentVelocity * 10),2)
                    . " `n                                           "
            ,35,265)
        }
    }
}

CheckCTW(Direction, mouseXPos, mouseYPos, winId){
;    global MainLastScrollTime

    CoordMode("Mouse", "Screen")
    ;MouseGetPos(&mouseXPos, &mouseYPos, &winId)
    Debug ? (ToolTip(" > 1000"), SetTimer(() => ToolTip(), -1000)) : ""
    
    try {
        winClass := WinGetClass("ahk_id " winId)
        WinGetPos(&winXPos, &winYPos, , , "ahk_id " winId)
        Debug ? (ToolTip(" Get pos"), SetTimer(() => ToolTip(), -1000)) : ""
        
        ; Verify application type and the horizontal boundary area
        if (EnabledTabApps.Has(winClass) && mouseYPos >= winYPos && mouseYPos <= (winYPos + TabAreaHeight)) {
            Debug ? (ToolTip(" APP SPOT"), SetTimer(() => ToolTip(), -1000)) : ""
            if !WinActive("ahk_id " winId) {
                WinActivate("ahk_id " winId)
            }
            ; Execute tab jump commands
            ;MainLastScrollTime := A_TickCount - LastTimeTimeout
            Send(Direction > 0 ? "{Blind}^{PgUp}" : "{Blind}^{PgDn}")
            return true
        }
    } catch {
        ; Fail-safe: continue to fallback if window elements are inaccessible
    }
    return false
}

MouseIsOverTaskbar(winId) {
    OldMatchMode := SetTitleMatchMode("RegEx")
    IsOver := WinExist("ahk_class ^Shell_(Secondary)?TrayWnd$ ahk_id " winId)
    SetTitleMatchMode(OldMatchMode)
    return IsOver
}


; --- The Optimized Fixed-Size Class ---
class KeyDisplayOSD {
    ; --- Configuration ---
    FontSize  := 14
    TextColor := "FFFFFF"  
    BgColor   := "373f86"  
    
    ; --- Internal State ---
    LastKey := ""
    Count   := 0
    GuiObj  := ""
    TextObj := ""
    TimerRef := ""
    
    ; Fixed coordinates calculated once at startup
    GuiX := 0
    GuiY := 0
    GuiW := 0
    GuiH := 0

    __New() {
        ; 1. Calculate static proportions based on FontSize
        this.GuiW := this.FontSize * 10.5   ; Adjust multiplier to change width
        this.GuiH := this.FontSize * 2.2   ; Adjust multiplier to change height
        
        ; 2. Calculate top-center position based on the fixed width
        MonitorGetWorkArea(, &Left, &Top, &Right, &Bottom)
        this.GuiX := (Right - Left - this.GuiW) / 2
        this.GuiY := Top + 20 

        ; 3. Build the static GUI
        this.CreateGui()
        this.TimerRef := this.ResetDisplay.Bind(this)
    }

    CreateGui() {
        this.GuiObj := Gui("+AlwaysOnTop -Caption +ToolWindow +E0x20")
        this.GuiObj.BackColor := this.BgColor
        
        ; Remove all internal padding so our control matches the window size perfectly
        this.GuiObj.MarginX := 0
        this.GuiObj.MarginY := 0
        this.GuiObj.SetFont("S" . this.FontSize . " Bold", "Segoe UI")
        
        ; FIX: Force text control to match the exact dimensions of the GUI window.
        ; Passing "w" and "h" fixes the Left-alignment issue permanently.
;        this.TextObj := this.GuiObj.Add("Text", "w" . this.GuiW . " h" . this.GuiH . " c" . this.TextColor . " Center -Wrap +0x0200", "")
        this.TextObj := this.GuiObj.Add("Text", "w" . this.GuiW . " h" . this.GuiH . " c" . this.TextColor . " Center +0x0200", "")
        
        ; Prepare the window position without displaying it yet
        this.GuiObj.Show("X" . this.GuiX . " Y" . this.GuiY . " W" . this.GuiW . " H" . this.GuiH . " Hide")
    }

    ShowKey(keyName) {
        SetTimer(this.TimerRef, 0) ; Kill old timer

        if (keyName == this.LastKey) {
            this.Count++
        } else {
            this.LastKey := keyName
            this.Count := 1
        }

        ; Update text string
        this.TextObj.Value := this.LastKey . " " . this.Count
        
        ; Show instantly. Zero layout math, zero movement, ultra-lightweight.
        this.GuiObj.Show("NoActivate")

        ;SetTimer(this.TimerRef, -LastTimeTimeout)
        SetTimer(this.TimerRef, -LastTimeTimeout)
    }

    ResetDisplay() {
        this.LastKey := ""
        this.Count := 0
        this.GuiObj.Hide()
;        SetTimer(this.GuiObj.Hide.Bind(this.GuiObj), -LastTimeTimeout)
    }
}