/************************************************************************
 * @description To handle user settings in a INI file
 * @author Melo (melo@meloprofessional.com)
 * @date 2026/05/14
 * @version 1.2.0
 ***********************************************************************/

#Requires AutoHotkey v2.0

RegisterArrayItems(SaveToINI)
LoadINI()

class INIManager {
    static IniPath := A_ScriptDir "\" App.Name "_UserSettings.ini"
    static Registered := Map()

    static Register(rootName, path) {
        if (!this.Registered.Has(rootName))
            this.Registered[rootName] := []
        this.Registered[rootName].Push(path)
    }

    static RegisterMultiple(rootName, paths*) {
            if (!this.Registered.Has(rootName))
                this.Registered[rootName] := []
            
            for path in paths {
                this.Registered[rootName].Push(path)
            }
        }

    static Load(rootObj, rootName) {
        if (!FileExist(this.IniPath))
            return rootObj

        for path in this.Registered.Get(rootName, []) {
            keyName := StrReplace(path, ".", "_")
            value   := IniRead(this.IniPath, rootName, keyName, "")

            if (value != "") {
                this._SetByPath(rootObj, path, value)
            }
        }
        return rootObj
    }

    static Save(rootObj, rootName) {
        for path in this.Registered.Get(rootName, []) {
            value := this._GetByPath(rootObj, path)
            if (value != "")
                IniWrite value, this.IniPath, rootName, StrReplace(path, ".", "_")
        }
    }

    static LoadAll() {
        for rootName, _ in this.Registered {
            try this.Load(%rootName%, rootName)
        }
    }

    static SaveAll() {
        for rootName, _ in this.Registered {
            try this.Save(%rootName%, rootName)
        }
    }

    static _GetByPath(obj, path) {
        keys := StrSplit(path, ".")
        current := obj
        for key in keys {
            if (!IsObject(current) || !current.HasOwnProp(key))
                return ""
            current := current.%key%
        }
        return current
    }

    static _SetByPath(obj, path, value) {
        keys := StrSplit(path, ".")
        current := obj
        for i, key in keys {
            if (i = keys.Length) {
                current.%key% := IsNumber(value) ? Number(value) : value
            } else {
                if (!current.HasOwnProp(key) || !IsObject(current.%key%))
                    current.%key% := {}
                current := current.%key%
            }
        }
    }
}

LoadINI(*) {
    INIManager.LoadAll()
}

SaveINI(*) {
    INIManager.SaveAll()
}

RegisterArrayItems(itemArray) {
    for index, fullString in itemArray {
        ; Split the string at the first dot
        ; Limit to 2 parts ensures it works even if the Key contains dots
        parts := StrSplit(fullString, ".", , 2)
        
        if (parts.Length == 2) {
            ; parts[1] is the Category, parts[2] is the Key
            INIManager.Register(parts[1], parts[2])
        }
    }
}
