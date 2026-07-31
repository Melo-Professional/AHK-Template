#Requires AutoHotkey v2.0

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

SettingsLoadStartOnBoot() {
    try {
        currentvalue := RegRead("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run", App.Name)
        return (currentvalue = '"' A_AhkPath '"')
    } catch {
        return false
    }
}

SettingsSaveStartOnBoot(enable) {
    if enable {
        RegWrite('"' A_AhkPath '"', "REG_SZ", "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run", App.Name)
    } else {
        RegDelete("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run", App.Name)
    }
}