; ==============================
; ADB Actions Plugin
; ==============================
; Standardized and Enhanced with GUI

; ==============================
; HELPER FUNCTIONS
; ==============================

GetAdbDataPath() {
    ; Centralized data path in root/data
    dataPath := "data\\adb_data.ini"
    SplitPath(dataPath, , &dir)
    if !DirExist(dir)
        DirCreate(dir)
    return dataPath
}

RunAdbCommand(cmd, title := "ADB Command") {
    ; Visual feedback
    try {
        ShowTooltipFeedback("Running " . title . "...", "Info")
        SetTimer(() => RemoveToolTip(), -1500)
    }
    
    ; Run command
    Run("cmd.exe /k " . cmd)
}

GetPackageList() {
    ; Get packages via adb
    ; We use a temporary file to capture output because reading stdout directly from adb can be tricky with encoding
    tmpFile := A_Temp . "\adb_packages.txt"
    RunWait("cmd /c adb shell pm list packages > " . tmpFile, , "Hide")
    
    packages := []
    if FileExist(tmpFile) {
        content := FileRead(tmpFile)
        Loop Parse, content, "`n", "`r" 
        {
            if (InStr(A_LoopField, "package:")) {
                pkg := StrReplace(A_LoopField, "package:", "")
                if (pkg != "")
                    packages.Push(pkg)
            }
        }
        FileDelete(tmpFile)
    }
    return packages
}

; ==============================
; GUI FUNCTIONS
; ==============================

ShowConnectGui() {
    g := Gui(, "ADB Connect")
    g.SetFont("s10", "Segoe UI")
    
    g.Add("Text",, "Enter Device IP:Port:")
    
    iniFile := GetAdbDataPath()
    history := LoadHistory("ConnectIP", iniFile)
    cb := g.Add("ComboBox", "w300 vIP", history)
    if (history.Length > 0)
        cb.Text := history[1]
        
    g.Add("Button", "Default w80", "Connect").OnEvent("Click", (*) => Connect(g, cb.Text))
    
    g.Show()
    
    Connect(guiObj, ip) {
        if (ip == "")
            return
            
        guiObj.Destroy()
        iniFile := GetAdbDataPath()
        SaveHistory("ConnectIP", ip, iniFile)
        RunAdbCommand("adb connect " . ip, "Connecting to " . ip)
    }
}

ShowPackageGui(actionType) {
    ; actionType: "Uninstall" or "Clear"
    
    packages := GetPackageList()
    if (packages.Length == 0) {
        MsgBox("No packages found or no device connected.", "ADB Error", "Icon!")
        return
    }
    
    g := Gui(, "ADB " . actionType)
    g.SetFont("s10", "Segoe UI")
    
    g.Add("Text",, "Search Package:")
    searchEdit := g.Add("Edit", "w400 vSearchTerm")
    
    g.Add("Text",, "Select Package:")
    lb := g.Add("ListBox", "w400 h300 vSelectedPkg", packages)
    
    searchEdit.OnEvent("Change", (*) => FilterList(lb, packages, searchEdit.Value))
    
    btnText := (actionType == "Uninstall") ? "Uninstall" : "Clear Data"
    g.Add("Button", "Default w100", btnText).OnEvent("Click", (*) => ProcessPackage(g, lb.Text, actionType))
    
    g.Show()
    
    FilterList(listBox, allItems, term) {
        filtered := []
        for item in allItems {
            if (term == "" || InStr(item, term))
                filtered.Push(item)
        }
        listBox.Delete()
        listBox.Add(filtered)
    }
    
    ProcessPackage(guiObj, pkg, type) {
        if (pkg == "")
            return
            
        guiObj.Destroy()
        
        if (type == "Uninstall") {
            RunAdbCommand("adb uninstall " . pkg, "Uninstalling " . pkg)
        } else {
            RunAdbCommand("adb shell pm clear " . pkg, "Clearing Data for " . pkg)
        }
    }
}


; ==============================
; ACTION FUNCTIONS
; ==============================

ADBListDevices() {
    RunAdbCommand("adb devices", "List Devices")
}

ADBConnect() {
    ShowConnectGui()
}

ADBDisconnect() {
    RunAdbCommand("adb disconnect", "Disconnect All")
}

ADBInstallAPK() {
    selectedFile := FileSelect(3, , "Select APK to Install", "APK Files (*.apk)")
    
    if (selectedFile != "") {
        RunAdbCommand('adb install "' . selectedFile . '"', "Installing APK")
    }
}

ADBUninstallPackage() {
    ShowPackageGui("Uninstall")
}

ADBClearAppData() {
    ShowPackageGui("Clear")
}

ADBLogcat() {
    RunAdbCommand("adb logcat", "Logcat")
}

ADBShell() {
    RunAdbCommand("adb shell", "ADB Shell")
}

ADBRebootDevice() {
    result := MsgBox("Are you sure you want to reboot the connected device?", "Confirm Reboot", "YesNo Icon?")
    if (result == "Yes") {
        RunAdbCommand("adb reboot", "Rebooting Device")
    }
}

; ===================================================================
; DEFAULT KEYMAPS
; ===================================================================
; These keymaps are auto-registered when this plugin is loaded.

; Adb Tools (leader → a → KEY)
RegisterCategoryKeymap("leader", "a", "ADB Tools", 8)
RegisterKeymap("leader", "a", "d", "List Devices", ADBListDevices, false, 1)
RegisterKeymap("leader", "a", "c", "Connect IP", ADBConnect, false, 2)
RegisterKeymap("leader", "a", "x", "Disconnect", ADBDisconnect, false, 3)
RegisterKeymap("leader", "a", "s", "Shell", ADBShell, false, 4)
RegisterKeymap("leader", "a", "l", "Logcat", ADBLogcat, false, 5)
RegisterKeymap("leader", "a", "i", "Install APK", ADBInstallAPK, false, 6)
RegisterKeymap("leader", "a", "u", "Uninstall Pkg", ADBUninstallPackage, false, 7)
RegisterKeymap("leader", "a", "C", "Clear App Data", ADBClearAppData, false, 8)
RegisterKeymap("leader", "a", "r", "Reboot Device", ADBRebootDevice, false, 9)
