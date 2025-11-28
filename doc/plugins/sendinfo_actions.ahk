; ==============================
; SendInfo Actions Plugin
; ==============================
; Intelligent text insertion with Snippet Manager
;
; STORAGE NOTE:
; This plugin uses JSON (data/snippets.json) instead of INI for storage.
; Why JSON?
; - Multiline Support: JSON handles newlines (\n) natively, whereas INI files require complex escaping or non-standard formats for multiline values.
; - Special Characters: JSON's escaping rules are standard and robust for storing code snippets, symbols, and Unicode text.
; - Structure: JSON allows for potential future expansion into more complex data structures (e.g., tags, categories) if needed.

; ==============================
; HELPER FUNCTIONS
; ==============================

GetSnippetDataPath() {
    dataPath := "data\snippets.json"
    SplitPath(dataPath, , &dir)
    if !DirExist(dir)
        DirCreate(dir)
    return dataPath
}

LoadSnippets() {
    jsonFile := GetSnippetDataPath()
    if !FileExist(jsonFile)
        return Map()
        
    try {
        content := FileRead(jsonFile)
        if (content == "")
            return Map()
            
        snippets := Map()
        
        ; Remove outer braces and whitespace
        content := Trim(content, "{} `t`n`r")
        
        ; Regex to match "key": "value" pairs, handling escaped quotes and commas inside strings
        ; Pattern explanation:
        ; "((?:[^"\\]|\\.)*)"   -> Match key: quote, then (non-quote-slash OR escaped char)*, then quote
        ; \s*:\s*               -> Match separator
        ; "((?:[^"\\]|\\.)*)"   -> Match value: same pattern as key
        needle := '"((?:[^"\\]|\\.)*)"\s*:\s*"((?:[^"\\]|\\.)*)"'
        
        pos := 1
        while (pos := RegExMatch(content, needle, &match, pos)) {
            key := match[1]
            value := match[2]
            
            ; Unescape JSON escapes
            ; Unescape backslash last to avoid unescaping an escaped escape
            value := StrReplace(value, '\"', '"')
            value := StrReplace(value, '\n', "`n")
            value := StrReplace(value, '\r', "`r")
            value := StrReplace(value, '\t', "`t")
            value := StrReplace(value, '\\', '\')
            
            snippets[key] := value
            
            ; Move position past this match
            pos += match.Len
        }
        
        return snippets
    } catch as err {
        Log.e("Error loading snippets: " . err.Message)
        return Map()
    }
}

SaveSnippets(snippets) {
    jsonFile := GetSnippetDataPath()
    
    content := "{"
    first := true
    
    for key, value in snippets {
        if (!first)
            content .= ","
        first := false
        
        ; Escape value for JSON
        escapedValue := StrReplace(value, '\', '\\')
        escapedValue := StrReplace(escapedValue, '"', '\"')
        escapedValue := StrReplace(escapedValue, "`n", '\n')
        escapedValue := StrReplace(escapedValue, "`r", '\r')
        escapedValue := StrReplace(escapedValue, "`t", '\t')
        
        content .= '`n  "' . key . '": "' . escapedValue . '"'
    }
    content .= "`n}"
    
    try {
        if FileExist(jsonFile)
            FileDelete(jsonFile)
        FileAppend(content, jsonFile)
    }
}

ShowSendInfoFeedback(message) {
    ; Use native tooltip with dedicated ID 16 for SendInfo
    ToolTip(message, , , 16)
    SetTimer(() => ToolTip(, , , 16), -1500)
}

InsertTextHelper(text, tooltipMsg) {
    ; Save current clipboard content (including non-text data)
    savedClip := ClipboardAll()
    
    ; Set clipboard to new text
    A_Clipboard := text
    
    ; Wait for clipboard to update (timeout 0.5s)
    if !ClipWait(0.5) {
        ; Fallback to SendText if clipboard fails
        SendText(text)
    } else {
        ; Use centralized paste shortcut detection
        shortcut := GetPasteShortcut()
        Send(shortcut)
        
        ; Restore original clipboard after a short delay to ensure paste is complete
        ; 200ms is usually enough for the OS to process the paste command
        SetTimer(() => A_Clipboard := savedClip, -200)
    }
    
    ShowSendInfoFeedback(tooltipMsg)
    Log.d("Inserted: " . SubStr(text, 1, 20) . "...", "TEXT_INSERT")
}

; ==============================
; CORE FUNCTIONS
; ==============================

SendInfo(text, tooltipMsg := "TEXT INSERTED") {
    return (*) => InsertTextHelper(text, tooltipMsg)
}

SendInfoMultiline(lines, tooltipMsg := "TEXT INSERTED") {
    text := ""
    for index, line in lines {
        text .= line
        if (index < lines.Length)
            text .= "`n"
    }
    return SendInfo(text, tooltipMsg)
}

; ==============================
; SNIPPET MANAGER
; ==============================

ShowSnippetManager() {
    snippets := LoadSnippets()
    snippetNames := []
    for name, _ in snippets
        snippetNames.Push(name)
        
    if (snippetNames.Length == 0) {
        MsgBox("No snippets found. Add one from clipboard first!", "Snippet Manager", "Icon!")
        return
    }
    
    g := Gui(, "Snippet Manager")
    g.SetFont("s10", "Segoe UI")
    
    g.Add("Text",, "Search Snippet:")
    searchEdit := g.Add("Edit", "w400 vSearchTerm")
    
    g.Add("Text",, "Select Snippet:")
    lb := g.Add("ListBox", "w400 h300 vSelectedSnippet", snippetNames)
    
    searchEdit.OnEvent("Change", (*) => FilterSnippets(lb, snippetNames, searchEdit.Value))
    lb.OnEvent("DoubleClick", (*) => InsertSelected(g, lb.Text, snippets))
    
    g.Add("Button", "Default w100", "Insert").OnEvent("Click", (*) => InsertSelected(g, lb.Text, snippets))
    g.Add("Button", "x+10 w100", "Delete").OnEvent("Click", (*) => DeleteSelected(g, lb, snippets))
    
    g.Show()
    
    FilterSnippets(listBox, allItems, term) {
        filtered := []
        for item in allItems {
            if (term == "" || InStr(item, term))
                filtered.Push(item)
        }
        listBox.Delete()
        listBox.Add(filtered)
    }
    
    InsertSelected(guiObj, name, snippetMap) {
        if (name == "" || !snippetMap.Has(name))
            return
            
        guiObj.Destroy()
        Sleep(100) ; Wait for GUI to close and focus return
        InsertTextHelper(snippetMap[name], "Snippet: " . name)
    }
    
    DeleteSelected(guiObj, listBox, snippetMap) {
        name := listBox.Text
        if (name == "")
            return
            
        if (MsgBox("Delete snippet '" . name . "'?", "Confirm", "YesNo") == "Yes") {
            snippetMap.Delete(name)
            SaveSnippets(snippetMap)
            
            ; Refresh list
            listBox.Delete(listBox.Value)
        }
    }
}

AddClipboardToSnippets() {
    content := A_Clipboard
    if (content == "") {
        ShowSendInfoFeedback("⚠️ Clipboard is empty")
        return
    }
    
    ib := InputBox("Enter name for this snippet:", "Add Snippet", "w300 h130")
    if (ib.Result == "Cancel" || ib.Value == "")
        return
        
    snippets := LoadSnippets()
    snippets[ib.Value] := content
    SaveSnippets(snippets)
    
    ShowSendInfoFeedback("✅ Snippet saved: " . ib.Value)
}

; ===================================================================
; DEFAULT KEYMAPS
; ===================================================================

; Information (leader → i → KEY)
RegisterCategoryKeymap("leader", "i", "Information", 9)
RegisterKeymap("leader", "i", "e", "Email", SendInfo("tu.email@example.com", "EMAIL"), false, 1)
RegisterKeymap("leader", "i", "p", "Phone", SendInfo("+1-555-123-4567", "PHONE"), false, 2)
RegisterKeymap("leader", "i", "m", "Snippet Manager", ShowSnippetManager, false, 3)
RegisterKeymap("leader", "i", "a", "Add from Clipboard", AddClipboardToSnippets, false, 4)
RegisterKeymap("leader", "i", "h", "Hola", SendInfo("Hola, cómo estás?"), false, 5)
