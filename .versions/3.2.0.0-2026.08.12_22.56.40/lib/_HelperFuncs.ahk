IsFunctionDefined(Name) {
        try return HasMethod(%Name%)
        return false
    }

ReloadClean(args*) {
    argString := ""
    for arg in args {
        if IsSet(arg) && arg != "" {
            argString .= ' "' arg '"'
        } else {
            argString .= ' "<unset>"'
        }
    }

    if DllCall("userenv\CreateEnvironmentBlock", "Ptr*", &lpEnv:=0, "Ptr",0, "Int",0) {
        si := Buffer(siSize := A_PtrSize == 8 ? 104 : 68, 0), NumPut("UInt", siSize, si)
        pi := Buffer(A_PtrSize == 8 ? 24 : 16, 0)
        cmd := (A_IsCompiled ? '"' A_ScriptFullPath '" /force' : '"' A_AhkPath '" /force "' A_ScriptFullPath '"') argString

        if DllCall("CreateProcessW", "Ptr",0, "Str",cmd, "Ptr",0, "Ptr",0, "Int",0, "UInt",0x400, "Ptr",lpEnv, "Ptr",0, "Ptr",si, "Ptr",pi)
            ExitApp()
        DllCall("userenv\DestroyEnvironmentBlock", "Ptr", lpEnv)
    }
    Reload()
}

ReloadWithArgs(args*) {
    argString := ""
    for arg in args {
        if IsSet(arg) && arg != "" {
            argString .= ' "' arg '"'
        } else {
            argString .= ' "<unset>"'
        }
    }

    if A_IsCompiled {
        Run('"' A_ScriptFullPath '" /restart' argString)
    } else {
        Run('"' A_AhkPath '" /restart "' A_ScriptFullPath '"' argString)
    }
    ExitApp()
}

CheckReloadWithArgs() {
	if A_Args.Length && !RegExMatch(A_Args[1], "i)^--signal-update-success=") {
		targetFuncName := A_Args[1]
		try {
			fnParams := A_Args.Clone()
			fnParams.RemoveAt(1)
			for index, param in fnParams {
				if (param = "<unset>") {
					fnParams.Delete(index)
				}
			}
			%targetFuncName%(fnParams*)
		} catch Any as e {
			throw e
		}
	}
}
