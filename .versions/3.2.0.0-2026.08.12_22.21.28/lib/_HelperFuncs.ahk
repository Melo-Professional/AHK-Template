IsFunctionDefined(Name) {
        try return HasMethod(%Name%)
        return false
    }


ReloadClean() {
    if DllCall("userenv\CreateEnvironmentBlock", "Ptr*", &lpEnv:=0, "Ptr",0, "Int",0) {
        si := Buffer(siSize := A_PtrSize == 8 ? 104 : 68, 0), NumPut("UInt", siSize, si)
        pi := Buffer(A_PtrSize == 8 ? 24 : 16, 0)
        cmd := A_IsCompiled ? '"' A_ScriptFullPath '" /force' : '"' A_AhkPath '" /force "' A_ScriptFullPath '"'

        if DllCall("CreateProcessW", "Ptr",0, "Str",cmd, "Ptr",0, "Ptr",0, "Int",0, "UInt",0x400, "Ptr",lpEnv, "Ptr",0, "Ptr",si, "Ptr",pi)
            ExitApp()
        DllCall("userenv\DestroyEnvironmentBlock", "Ptr", lpEnv)
    }
    Reload()
}