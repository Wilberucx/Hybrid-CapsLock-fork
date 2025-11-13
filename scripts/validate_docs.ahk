#!/usr/bin/env AutoHotkey
; ============================================================================
; Documentation Validation Script
; ============================================================================
; Purpose: Validate all markdown links in documentation
; Usage: AutoHotkey validate_docs.ahk
; Output: Report of broken links, missing files, and inconsistencies
; ============================================================================

#Requires AutoHotkey v2.0+

; Global configuration
global OUTPUT_FILE := "tmp_rovodev_doc_validation_report.md"
global DOC_ROOT := A_ScriptDir . "\..\doc"
global BROKEN_LINKS := []
global MISSING_FILES := []
global TOTAL_LINKS := 0
global TOTAL_FILES := 0

; ============================================================================
; Main Execution
; ============================================================================

Main() {
    OutputDebug("Starting documentation validation...")
    
    ; Initialize report
    report := "# 📋 Documentation Validation Report`n`n"
    report .= "**Generated**: " . FormatTime(, "yyyy-MM-dd HH:mm:ss") . "`n`n"
    report .= "---`n`n"
    
    ; Scan all markdown files
    files := GetAllMarkdownFiles(DOC_ROOT)
    TOTAL_FILES := files.Length
    
    OutputDebug("Found " . TOTAL_FILES . " markdown files")
    
    ; Validate each file
    for index, filePath in files {
        OutputDebug("Validating: " . filePath)
        ValidateFile(filePath)
    }
    
    ; Generate report
    report .= GenerateReport()
    
    ; Write report to file
    try {
        FileDelete(OUTPUT_FILE)
    }
    FileAppend(report, OUTPUT_FILE, "UTF-8")
    
    ; Display summary
    MsgBox(
        "Documentation Validation Complete!`n`n" .
        "Total Files: " . TOTAL_FILES . "`n" .
        "Total Links: " . TOTAL_LINKS . "`n" .
        "Broken Links: " . BROKEN_LINKS.Length . "`n" .
        "Missing Files: " . MISSING_FILES.Length . "`n`n" .
        "Report saved to: " . OUTPUT_FILE,
        "Validation Complete",
        "Icon!"
    )
    
    ; Open report
    Run(OUTPUT_FILE)
}

; ============================================================================
; File Discovery
; ============================================================================

GetAllMarkdownFiles(rootPath) {
    files := []
    
    Loop Files, rootPath . "\*.md", "R" {
        ; Skip template files and develop notes
        if InStr(A_LoopFileFullPath, "\templates\") 
            continue
        if InStr(A_LoopFileFullPath, "\develop\")
            continue
            
        files.Push(A_LoopFileFullPath)
    }
    
    return files
}

; ============================================================================
; File Validation
; ============================================================================

ValidateFile(filePath) {
    try {
        content := FileRead(filePath, "UTF-8")
    } catch {
        MISSING_FILES.Push({file: filePath, reason: "Cannot read file"})
        return
    }
    
    ; Extract all markdown links: [text](path)
    links := ExtractMarkdownLinks(content)
    
    for index, link in links {
        TOTAL_LINKS++
        ValidateLink(filePath, link)
    }
}

ExtractMarkdownLinks(content) {
    links := []
    pos := 1
    
    ; Regex to match [text](path) but not images ![text](path)
    while (pos := RegExMatch(content, "(?<!!)\\[([^\\]]+)\\]\\(([^\\)]+)\\)", &match, pos)) {
        linkText := match[1]
        linkPath := match[2]
        
        ; Skip external links (http/https)
        if RegExMatch(linkPath, "^https?://")
            continue
            
        ; Skip anchors only (#anchor)
        if RegExMatch(linkPath, "^#")
            continue
        
        links.Push({text: linkText, path: linkPath, fullMatch: match[0]})
        pos += StrLen(match[0])
    }
    
    return links
}

; ============================================================================
; Link Validation
; ============================================================================

ValidateLink(sourceFile, link) {
    linkPath := link.path
    
    ; Remove anchor if present
    if (anchorPos := InStr(linkPath, "#")) {
        linkPath := SubStr(linkPath, 1, anchorPos - 1)
    }
    
    ; Skip if empty (pure anchor link)
    if (linkPath = "")
        return
    
    ; Resolve relative path
    sourcedir := ""
    SplitPath(sourceFile, , &sourceDir)
    targetPath := ResolvePath(sourceDir, linkPath)
    
    ; Check if file exists
    if !FileExist(targetPath) {
        BROKEN_LINKS.Push({
            source: sourceFile,
            linkText: link.text,
            linkPath: link.path,
            resolvedPath: targetPath,
            reason: "File not found"
        })
    }
}

ResolvePath(baseDir, relativePath) {
    ; Handle absolute paths (shouldn't exist in docs, but check anyway)
    if RegExMatch(relativePath, "^[A-Za-z]:\\")
        return relativePath
    
    ; Build full path
    fullPath := baseDir . "\" . relativePath
    
    ; Normalize path (resolve .. and .)
    fullPath := StrReplace(fullPath, "/", "\")
    
    ; Resolve parent directory references (..)
    while InStr(fullPath, "\..\") {
        fullPath := RegExReplace(fullPath, "[^\\]+\\\.\.\\", "")
    }
    
    ; Resolve current directory references (.)
    fullPath := StrReplace(fullPath, "\.\", "\")
    
    return fullPath
}

; ============================================================================
; Report Generation
; ============================================================================

GenerateReport() {
    report := ""
    
    ; Summary
    report .= "## 📊 Summary`n`n"
    report .= "| Metric | Count |`n"
    report .= "|--------|-------|`n"
    report .= "| Total Files Scanned | " . TOTAL_FILES . " |`n"
    report .= "| Total Links Found | " . TOTAL_LINKS . " |`n"
    report .= "| Broken Links | " . BROKEN_LINKS.Length . " |`n"
    report .= "| Missing Files | " . MISSING_FILES.Length . " |`n"
    report .= "`n"
    
    ; Status
    if (BROKEN_LINKS.Length = 0 && MISSING_FILES.Length = 0) {
        report .= "### ✅ All Links Valid!`n`n"
        report .= "No broken links or missing files detected.`n`n"
    } else {
        report .= "### ⚠️ Issues Found`n`n"
    }
    
    ; Broken Links
    if (BROKEN_LINKS.Length > 0) {
        report .= "## 🔴 Broken Links (" . BROKEN_LINKS.Length . ")`n`n"
        
        for index, item in BROKEN_LINKS {
            report .= "### " . index . ". " . item.linkText . "`n`n"
            report .= "- **Source File**: `" . GetRelativePath(item.source) . "``n"
            report .= "- **Link Path**: `" . item.linkPath . "``n"
            report .= "- **Resolved To**: `" . item.resolvedPath . "``n"
            report .= "- **Reason**: " . item.reason . "`n`n"
        }
    }
    
    ; Missing Files
    if (MISSING_FILES.Length > 0) {
        report .= "## 🔴 Missing Files (" . MISSING_FILES.Length . ")`n`n"
        
        for index, item in MISSING_FILES {
            report .= "### " . index . ". " . GetRelativePath(item.file) . "`n`n"
            report .= "- **Reason**: " . item.reason . "`n`n"
        }
    }
    
    ; Recommendations
    report .= "---`n`n"
    report .= "## 💡 Recommendations`n`n"
    
    if (BROKEN_LINKS.Length > 0) {
        report .= "1. **Fix broken links** - Update paths in source files`n"
        report .= "2. **Create missing files** - Add placeholder content if needed`n"
    }
    
    report .= "3. **Run this script regularly** - Before committing documentation changes`n"
    report .= "4. **Update README links** - Ensure main README.md references are valid`n`n"
    
    return report
}

GetRelativePath(fullPath) {
    projectRoot := A_ScriptDir . "\.."
    relativePath := StrReplace(fullPath, projectRoot, "")
    relativePath := LTrim(relativePath, "\")
    return relativePath
}

; ============================================================================
; Execute
; ============================================================================

Main()
