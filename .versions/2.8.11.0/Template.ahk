;@region Setup
;@region Description
/************************************************************************
 * @description This is a template as a starting point for your AutoHotKey projects.
 * @author Melo (melo@meloprofessional.com)
 * @date 2026/07/10
 * @releasedate 2026/04/24
 * @version 2.8.11.0
 ***********************************************************************/

AppName := "Template"
;@Ahk2Exe-Let U_AppName = %A_PriorLine%
AppVersion := "2.8.11.0"
;@Ahk2Exe-Let U_Version = %A_PriorLine%
AppDescription := "This is a template as a starting point for your AutoHotKey projects."
;@endregion

;@region Directives
#Requires AutoHotkey v2.0
#SingleInstance Force
Persistent()
SetWorkingDir(A_ScriptDir)
A_AllowMainWindow := 0
A_IconHidden := true
A_MenuMaskKey := "vkFF"
; --- Optimization Settings ---
;ProcessSetPriority("High")
;ListLines(False)
;KeyHistory(0)
;A_MaxHotkeysPerInterval := 5000
;A_HotkeyInterval := 1000
;@endregion

;@region Includes
#Include *i <_CompilerDirectives>
#Include *i <_Config&Vars>
#Include *i <_MsgBoxCustom>
#Include *i <_SaveSettings>
#Include *i <_Theme>
#Include *i <_OSDCustom>
;#Include *i <_ModernSlider>
;#Include *i <_Color_Picker_Dialog>
#Include *i <_SplashScreen>
#Include *i <_About>
;#Include *i <_Help>
#Include *i <_Menu>

#Include *i <Vars_Custom>
#Include *i <Menu_Custom>
;@endregion

;@region Startup
; SPLASHSCREEN
if IsSet(SplashScreen){
    SplashScreen("Icon")
}

; TRAY ICON + MENU
StartMenu()
Menu_Custom()

;@endregion
;@endregion

;@region Main

;@endregion
;throw Error('Message', A_ThisFunc, )
;a := "test"
;OutputDebug(a) ; debug tab

^p::ReloadClean()



MyGui := Gui("+Resize", "Ultimate Theme Testing Grounds")

; -------------------------------------------------------------------
; 1. ADD A TAB CONTROL
; -------------------------------------------------------------------
TabCtrl := MyGui.Add("Tab3", "w400 h380", ["Main Inputs", "Lists & Tables", "Settings"])

; --- TAB 1: Main Inputs ---
TabCtrl.UseTab(1)

txt1 := MyGui.Add("Text", "x25 y50", "Profile Information")
txt1.ThemeStyle := "Strong" ; Custom property support

MyGui.Add("Text", "x25 y85 w80", "Full Name:") 
MyGui.Add("Edit", "x110 y80 w250", "John Doe")

MyGui.Add("Text", "x25 y120 w80", "Account Type:")
MyGui.Add("DDL", "x110 y115 w250 Choose1", ["Standard User", "Power User", "Administrator", "Guest"])

MyGui.Add("Text", "x25 y155 w80", "Region/City:")
MyGui.Add("ComboBox", "x110 y150 w250 Choose2", ["New York", "London", "São Paulo", "Tokyo", "Berlin"])

MyGui.Add("GroupBox", "x25 y195 w360 h80 +BackgroundTrans", "Notification Settings")
MyGui.Add("Radio", "x40 y220 Checked", "Email Digests")
MyGui.Add("Radio", "x40 y245", "Instant Push Alerts")

; --- TAB 2: Lists & Tables ---
TabCtrl.UseTab(2)

txt2 := MyGui.Add("Text", "x25 y50", "System Processes Tracker")
txt2.ThemeStyle := "Strong" 

lv := MyGui.Add("ListView", "x25 y85 w360 r6", ["PID", "Process Name", "Memory Allocation"])
lv.Add(, "4212", "AutoHotkey.exe", "14.2 MB")
lv.Add(, "1084", "chrome.exe", "342.1 MB")
lv.Add(, "8944", "Code.exe", "189.5 MB")
lv.Add(, "0216", "explorer.exe", "74.0 MB")
lv.ModifyCol(1, "Integer") 
lv.ModifyCol(2, 150)
lv.ModifyCol(3, 120)

MyGui.Add("Text", "x25 y240", "Select Tag Priority:")
MyGui.Add("ListBox", "x25 y260 w360 r3 Choose1", ["[CRITICAL] Action", "[HIGH] Sprint", "[LOW] Backlog"])

; --- TAB 3: Settings ---
TabCtrl.UseTab(3)

txt3 := MyGui.Add("Text", "x25 y50", "Performance Controls")
txt3.ThemeStyle := "Strong"

MyGui.Add("Text", "x25 y90", "System Thread Limit:")
MyGui.Add("Slider", "x25 y110 w360 Range1-16 ToolTip Checked Choose4", 8)

MyGui.Add("Text", "x25 y160", "Simulated Optimization Progress:")
MyGui.Add("Progress", "x25 y185 w360 h20 c0x00A2FF", 65)

; Loop Generation using custom Weak style properties
loop 2 {
    lbl := MyGui.Add("Text", "x25 y" . (220 + (A_Index * 20)), "* Loop generated footnote item #" . A_Index)
    lbl.ThemeStyle := "Weak" 
}

; -------------------------------------------------------------------
; 2. GLOBAL ACTIONS AREA
; -------------------------------------------------------------------
TabCtrl.UseTab()

MyGui.Add("Button", "x215 y405 w90 Default", "&Save Changes").OnEvent("Click", (*) => MsgBox("Settings Saved!"))
MyGui.Add("Button", "x315 y405 w90", "&Close").OnEvent("Click", CleanDestroy)

MyGui.OnEvent("Close", CleanDestroy)
MyGui.OnEvent("Escape", CleanDestroy)

; -------------------------------------------------------------------
; 3. APPLY ENGINE (Original Procedural Implementation)
; -------------------------------------------------------------------
ApplyThemeToGui(MyGui)
WatchedGUIs.Push(MyGui)
MyGui.Show()

CleanDestroy(*) {
    RemoveGuiFromArray(MyGui)
    MyGui.Destroy()
}