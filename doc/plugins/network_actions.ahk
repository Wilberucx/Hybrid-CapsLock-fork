; ==============================
; Network Actions Plugin
; ==============================
; Enhanced with Public IP fetcher and Tooltip UI.

; ==============================
; NATIVE TOOLTIP HELPERS (Bypass C# system)
; ==============================
ShowNetworkTooltip(Text) {
    ; Force native tooltip with ID 20 to avoid conflicts
    ToolTipX := A_ScreenWidth // 2
    ToolTipY := A_ScreenHeight - 100
    ToolTip(Text, ToolTipX, ToolTipY, 20)
}

HideNetworkTooltip() {
    ToolTip(,,,20)
}

; ==============================
; HELPER FUNCTIONS
; ==============================

GetPublicIP() {
    try {
        ShowTooltipFeedback("Fetching Public IP...", "Info")
        http := ComObject("WinHttp.WinHttpRequest.5.1")
        http.Open("GET", "https://api.ipify.org", true)
        http.Send()
        http.WaitForResponse()
        
        ip := http.ResponseText
        A_Clipboard := ip
        
        ShowTooltipFeedback("Public IP " . ip . " copied to clipboard.", "Success")
        SetTimer(() => HideNetworkTooltip(), -3000)
        return ip
    } catch as e {
        ShowTooltipFeedback("Error fetching Public IP.", "Error")
        SetTimer(() => HideNetworkTooltip(), -3000)
        return ""
    }
}

GetLocalIP() {
    try {
        ; A_IPAddress1 was removed in v2. Use WMI instead.
        svc := ComObjGet("winmgmts:")
        result := svc.ExecQuery("Select IPAddress from Win32_NetworkAdapterConfiguration WHERE IPEnabled = True")
        
        for adapter in result {
            if (adapter.IPAddress) {
                for ip in adapter.IPAddress {
                    ; Return first IPv4 address found
                    if (InStr(ip, ".") && !InStr(ip, ":") && ip != "127.0.0.1") {
                        return ip
                    }
                }
            }
        }
    }
    return "127.0.0.1"
}

; ==============================
; ACTIONS
; ==============================

ShowNetworkStatus() {
    localIP := GetLocalIP()
    
    info := "🌐 NETWORK STATUS`n"
    info .= "------------------`n"
    info .= "Local IP : " . localIP . "`n"
    
    ShowTooltipFeedback(info . "`nFetching Public IP...", "Info")
    
    ; Async fetch public IP to update tooltip
    SetTimer(FetchPublicIPAsync, -10)
}

FetchPublicIPAsync() {
    try {
        http := ComObject("WinHttp.WinHttpRequest.5.1")
        http.Open("GET", "https://api.ipify.org", true)
        http.Send()
        http.WaitForResponse()
        publicIP := http.ResponseText
        
        localIP := GetLocalIP()
        info := "🌐 NETWORK STATUS`n"
        info .= "------------------`n"
        info .= "Local IP : " . localIP . "`n"
        info .= "Public IP: " . publicIP
        
        ShowTooltipFeedback(info, "info")
        SetTimer(() => HideNetworkTooltip(), -4000)
    } catch {
        ShowNetworkTooltip("Network Status:`nLocal IP: " . GetLocalIP() . "`nPublic IP: Error")
    }
}

RunSpeedTest() {
    ShowTooltipFeedback("🚀 Opening Speedtest...")
    Run("https://fast.com")
    SetTimer(() => HideNetworkTooltip(), -2000)
}

ShowIPConfig() {
    ShowTooltipFeedback("Obtaining IP Configuration...", 500)
    Run("cmd.exe /k ipconfig /all")
}

PingGoogle() {
    Run("cmd.exe /k ping -t google.com")
}

ShowNetstat() {
    Run("cmd.exe /k netstat -an")
}

; ===================================================================
; DEFAULT KEYMAPS
; ===================================================================

; Network Commands (leader → n → KEY)
RegisterCategoryKeymap("leader", "n", "Network Commands", 5)
RegisterKeymap("leader", "n", "s", "Network Status", ShowNetworkStatus, false, 1)
RegisterKeymap("leader", "n", "i", "Get Public IP", GetPublicIP, false, 2)
RegisterKeymap("leader", "n", "t", "Speedtest (Fast.com)", RunSpeedTest, false, 3)
RegisterKeymap("leader", "n", "c", "IP Config (CMD)", ShowIPConfig, false, 4)
RegisterKeymap("leader", "n", "p", "Ping Google", PingGoogle, false, 5)
