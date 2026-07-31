/************************************************************************
 * @description Auto Backup for new versions
 * @author Melo (melo@meloprofessional.com)
 * @date 2026/07/20
 * @version 1.0.0
 ***********************************************************************/

Backup(){
    if A_IsCompiled
        return

    timestamp := FormatTime(A_Now, " yyyy.MM.dd_HH.mm.ss")
    targetDir := A_ScriptDir "\.versions\" AppVersion timestamp
    if !DirExist(targetDir) {
        DirCreate(targetDir)
    }
    
    SplitPath(A_ScriptFullPath, &fullFileName)
    FileCopy(A_ScriptFullPath, targetDir "\" fullFileName, 1)
    
    ; --- Modified Lib Copying Logic ---
    if DirExist(A_ScriptDir "\lib") {
        ; 1. Create the lib folder inside the backup folder structure
        DirCreate(targetDir "\lib")
        
        ; 2. Read the entire content of the main running script
        scriptContent := FileRead(A_ScriptFullPath)
        
        ; 3. Loop through every line of the script to find active #Includes
        Loop Parse, scriptContent, "`n", "`r" {
            ; Check if the line contains a non-commented #Include
            ; Matches variations like: #Include <_Menu>, #Include *i <_Menu>, #Include lib\_Menu.ahk
            if RegExMatch(A_LoopField, "i)^\s*#Include\s+(?:\*i\s+)?<?([^>\s]+)>?", &match) {
                includePath := match[1]
                
                ; Add the standard .ahk extension if it was omitted (e.g., <_Menu>)
                if !(includePath ~= "\.[a-zA-Z0-9]+$") {
                    includePath .= ".ahk"
                }
                
                ; Extract just the file name (e.g., _Menu.ahk) for the destination
                SplitPath(includePath, &libFileName)
                
                ; Determine the true source path on disk
                sourceFile := A_ScriptDir "\lib\" libFileName
                
                ; 4. If the included file exists in your lib folder, copy it!
                if FileExist(sourceFile) {
                    FileCopy(sourceFile, targetDir "\lib\" libFileName, 1)
                }
            }
        }
    }
    ; ----------------------------------

    if DirExist(A_ScriptDir "\images") {
        DirCopy(A_ScriptDir "\images", targetDir "\images", 1)
    }
    if DirExist(A_ScriptDir "\audios") {
        DirCopy(A_ScriptDir "\audios", targetDir "\audios", 1)
    }
}