/************************************************************************
 * @description Reload passing a dynamic call with a parameter
 * @author Melo (melo@meloprofessional.com)
 * @date 2026/08/06
 * @version 1.2.0
 ***********************************************************************/

/* 
ReloadWithArgs(callerName := "", paramValue := "") {
    argString := ""
    if (callerName != "") {
        argString .= ' "' callerName '"'
        if (paramValue != "") {
            argString .= ' "' paramValue '"'
        }
    }

    if A_IsCompiled {
        Run('"' A_ScriptFullPath '" /restart' argString)
    } else {
        Run('"' A_AhkPath '" /restart "' A_ScriptFullPath '"' argString)
    }
    ExitApp()
} */


/* 
; CHECK RELOAD ARGUMENTS
if (A_Args.Length > 0)  && !RegExMatch(A_Args[1], "i)^--signal-update-success=") {
    targetFuncName := A_Args[1]
    if !A_IsCompiled && Debug
        ToolTip("reload with args " A_Args[1])
    try {
        if (A_Args.Length >= 2) {
            %targetFuncName%(A_Args[2])
        } else {
            %targetFuncName%()
        }
    } catch Any as e {
        ;MsgBoxCustom("Failed to execute dynamic call: " e.Message, App.Name)
        MsgBoxCustom(,,,e)
    }
}
 */


ReloadWithArgs(args*) {
    argString := ""
    for arg in args {
        if (arg != "") {
            argString .= ' "' arg '"'
        }
    }

    if A_IsCompiled {
        Run('"' A_ScriptFullPath '" /restart' argString)
    } else {
        Run('"' A_AhkPath '" /restart "' A_ScriptFullPath '"' argString)
    }
    ExitApp()
}


/* 
; CHECK RELOAD ARGUMENTS
if (A_Args.Length > 0) && !RegExMatch(A_Args[1], "i)^--signal-update-success=") {
    targetFuncName := A_Args[1]
    if !A_IsCompiled && Debug
        ToolTip("reload with args " A_Args[1])
    try {
        fnParams := A_Args.Clone()
        fnParams.RemoveAt(1) ; Remove function name, leaving only remaining arguments
        %targetFuncName%(fnParams*)
    } catch Any as e {
        ;MsgBoxCustom("Failed to execute dynamic call: " e.Message, App.Name)
        MsgBoxCustom(,,,e)
    }
}
 */

