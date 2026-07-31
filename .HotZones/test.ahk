#Requires AutoHotkey v2.0
CoordMode(Mouse, Screen)
MouseGetPos(&x, &y, &hwnd)
hit := SendMessage(0x84, 0, (y << 16) | (x & 0xFFFF), , hwnd)
FileAppend(hit:  . hit . 
, test.log)
