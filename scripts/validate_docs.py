#!/usr/bin/env python3
"""
Documentation Validation Script
================================
Purpose: Validate all markdown links in documentation
Usage: python validate_docs.py
Output: Report of broken links, missing files, and inconsistencies
"""

import os
import re
from pathlib import Path
from datetime import datetime

# Configuration
OUTPUT_FILE = "tmp_rovodev_doc_validation_report.md"
DOC_ROOT = Path(__file__).parent.parent / "doc"
BROKEN_LINKS = []
MISSING_FILES = []
TOTAL_LINKS = 0
TOTAL_FILES = 0

def get_all_markdown_files(root_path):
    """Get all markdown files excluding templates and develop folders"""
    files = []
    for md_file in root_path.rglob("*.md"):
        # Skip templates and develop notes
        if "templates" in str(md_file) or "develop" in str(md_file):
            continue
        files.append(md_file)
    return files

def extract_markdown_links(content):
    """Extract all markdown links [text](path) but not images"""
    links = []
    # Pattern: [text](path) but not ![text](path)
    pattern = r'(?<!!)\[([^\]]+)\]\(([^\)]+)\)'
    
    for match in re.finditer(pattern, content):
        link_text = match.group(1)
        link_path = match.group(2)
        
        # Skip external links
        if link_path.startswith(('http://', 'https://', 'mailto:')):
            continue
        
        # Skip pure anchors
        if link_path.startswith('#') and len(link_path) > 1:
            continue
            
        links.append({
            'text': link_text,
            'path': link_path,
            'full_match': match.group(0)
        })
    
    return links

def resolve_path(source_file, relative_path):
    """Resolve relative path from source file"""
    # Remove anchor if present
    if '#' in relative_path:
        relative_path = relative_path.split('#')[0]
    
    # Skip if empty (pure anchor)
    if not relative_path:
        return None
    
    # Get source directory
    source_dir = source_file.parent
    
    # Resolve path
    target_path = (source_dir / relative_path).resolve()
    
    return target_path

def validate_file(file_path):
    """Validate all links in a markdown file"""
    global TOTAL_LINKS
    
    try:
        content = file_path.read_text(encoding='utf-8')
    except Exception as e:
        MISSING_FILES.append({
            'file': str(file_path),
            'reason': f'Cannot read file: {str(e)}'
        })
        return
    
    links = extract_markdown_links(content)
    
    for link in links:
        TOTAL_LINKS += 1
        target_path = resolve_path(file_path, link['path'])
        
        if target_path is None:
            continue
        
        # Check if file exists
        if not target_path.exists():
            BROKEN_LINKS.append({
                'source': str(file_path.relative_to(file_path.parent.parent.parent)),
                'link_text': link['text'],
                'link_path': link['path'],
                'resolved_path': str(target_path),
                'reason': 'File not found'
            })

def generate_report():
    """Generate markdown report"""
    report = []
    report.append("# 📋 Documentation Validation Report\n")
    report.append(f"**Generated**: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
    report.append("\n---\n\n")
    
    # Summary
    report.append("## 📊 Summary\n\n")
    report.append("| Metric | Count |\n")
    report.append("|--------|-------|\n")
    report.append(f"| Total Files Scanned | {TOTAL_FILES} |\n")
    report.append(f"| Total Links Found | {TOTAL_LINKS} |\n")
    report.append(f"| Broken Links | {len(BROKEN_LINKS)} |\n")
    report.append(f"| Missing Files | {len(MISSING_FILES)} |\n")
    report.append("\n")
    
    # Status
    if not BROKEN_LINKS and not MISSING_FILES:
        report.append("### ✅ All Links Valid!\n\n")
        report.append("No broken links or missing files detected.\n\n")
    else:
        report.append("### ⚠️ Issues Found\n\n")
    
    # Broken Links
    if BROKEN_LINKS:
        report.append(f"## 🔴 Broken Links ({len(BROKEN_LINKS)})\n\n")
        
        for idx, item in enumerate(BROKEN_LINKS, 1):
            report.append(f"### {idx}. {item['link_text']}\n\n")
            report.append(f"- **Source File**: `{item['source']}`\n")
            report.append(f"- **Link Path**: `{item['link_path']}`\n")
            report.append(f"- **Resolved To**: `{item['resolved_path']}`\n")
            report.append(f"- **Reason**: {item['reason']}\n\n")
    
    # Missing Files
    if MISSING_FILES:
        report.append(f"## 🔴 Missing Files ({len(MISSING_FILES)})\n\n")
        
        for idx, item in enumerate(MISSING_FILES, 1):
            report.append(f"### {idx}. {item['file']}\n\n")
            report.append(f"- **Reason**: {item['reason']}\n\n")
    
    # Recommendations
    report.append("---\n\n")
    report.append("## 💡 Recommendations\n\n")
    
    if BROKEN_LINKS:
        report.append("1. **Fix broken links** - Update paths in source files\n")
        report.append("2. **Create missing files** - Add placeholder content if needed\n")
    
    report.append("3. **Run this script regularly** - Before committing documentation changes\n")
    report.append("4. **Update README links** - Ensure main README.md references are valid\n\n")
    
    return ''.join(report)

def main():
    """Main execution"""
    global TOTAL_FILES
    
    print("Starting documentation validation...")
    print(f"Scanning: {DOC_ROOT}")
    
    # Get all markdown files
    files = get_all_markdown_files(DOC_ROOT)
    TOTAL_FILES = len(files)
    
    print(f"Found {TOTAL_FILES} markdown files")
    
    # Validate each file
    for file_path in files:
        print(f"Validating: {file_path.name}")
        validate_file(file_path)
    
    # Generate report
    report = generate_report()
    
    # Write report
    output_path = Path(OUTPUT_FILE)
    output_path.write_text(report, encoding='utf-8')
    
    # Display summary
    print("\n" + "="*60)
    print("Documentation Validation Complete!")
    print("="*60)
    print(f"Total Files: {TOTAL_FILES}")
    print(f"Total Links: {TOTAL_LINKS}")
    print(f"Broken Links: {len(BROKEN_LINKS)}")
    print(f"Missing Files: {len(MISSING_FILES)}")
    print(f"\nReport saved to: {output_path.absolute()}")
    print("="*60)

if __name__ == "__main__":
    main()
