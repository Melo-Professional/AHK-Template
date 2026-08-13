/************************************************************************
 * @description QOL helper functions
 * @author Melo (melo@meloprofessional.com) and Pjtor
 * @date 2026/08/12
 * @version 1.0.0
 ***********************************************************************/

/**
 * @description {@link IsFunctionDefined|_HelperFuncs.ahk}
 * Check if a function is available, returning true | false
 * @param {(String)} [FunctionName]
 * @returns {(Boolean)}
 * Returns true or false if the function is defined.
 * @example <caption>Check if ShowHelpGUI() is available and uses it</caption>
 * if IsFunctionDefined("ShowHelpGUI")
 *     MoreMenu.Add("Help", (*) => %"ShowHelpGUI"%())
 */
IsFunctionDefined(FunctionName) {
        try return HasMethod(%FunctionName%)
        return false
    }

/**
 * @description {@link ReloadClean|_HelperFuncs.ahk}
 * Reload current App with clean environment. Option to send arguments.
 * @param {(String)} [args*]
 * @example <caption>Reload current App</caption>  
 * ReloadClean()
 * @example <caption>Reload current App sending 2 arguments</caption>  
 * ReloadClean("showGUI", "foo")
 */
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

/**
 * @description {@link ReloadWithArgs|_HelperFuncs.ahk}
 * Regular Reload current App with arguments. No Clean environment.
 * @param {(String)} [args*]
 * @example <caption>Reload current App sending 2 arguments</caption>  
 * ReloadWithArgs("showGUI", "foo")
 */
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

/**
 * @description {@link CheckReloadArgs|_HelperFuncs.ahk}
 * Use this function after loading your code to check if there was arguments to dynamically call functions with parameters.
 * @param {(String)} [FunctionName]
 * @param {(String)} [parameter #1]
 * @param {(String)} [parameter #2]
 * @param {(String)} [parameter #n]
 * @example <caption>Check if the App received arguments and call function with arg1 and send parameter with arg2.</caption>  
 * CheckReloadArgs()
 * @example <caption>Show a Message Box asking "Continue?", a title "Question" with buttons Yes and No.</caption>  
 * MsgBoxCustom("Continue?", "Question", "YesNo")
 */
CheckReloadArgs() {
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


/**
 * @description {@link MsgBoxCustom|GuiMsgBoxCustom.ahk}
 * Displays a Custom Message Box. Useful for keeping your custom icon and better control of your GUIs.
 * @param {(String)} [Text]
 * @param {(String)} [Title]
 * @param {"OKCancel"|"RetryCancel"|"ContinueExit"|"YesNo"|"OK"} [Options]
 * @param {(ValueError)} [err ValueError]
 * @returns {(String)}
 * Returns the button pressed by the user.
 * @example <caption>Show a Message Box with "This is a message" with a OK button.</caption>  
 * MsgBoxCustom("This is a message")
 * @example <caption>Show a Message Box asking "Continue?", a title "Question" with buttons Yes and No.</caption>  
 * MsgBoxCustom("Continue?", "Question", "YesNo")
 */
DPIScale(val) => Round(val * (A_ScreenDPI / 96))