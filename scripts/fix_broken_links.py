#!/usr/bin/env python3
"""
Fix Broken Links Script
=======================
Automatically fixes common broken link patterns in markdown files
"""

import os
import re
from pathlib import Path

# Mapping of old broken links to new correct links
LINK_REPLACEMENTS = {
    # Old UPPERCASE names to new lowercase names
    'NVIM_LAYER.md': 'nvim-layer.md',
    'LEADER_MODE.md': 'leader-mode.md',
    'HOMEROW_MODS.md': 'homerow-mods.md',
    'EXCEL_LAYER.md': 'excel-layer.md',
    'CONFIGURATION.md': 'configuration.md',
    'AUTO_LOADER_USAGE.md': 'auto-loader-system.md',
    'GETTING_STARTED.md': 'quick-start.md',
    
    # Non-existent layers to remove or fix
    'WINDOWS_LAYER.md': None,  # Remove link
    'TIMESTAMP_LAYER.md': None,  # Remove link
    'PROGRAM_LAYER.md': None,  # Remove link
    'COMMAND_LAYER.md': None,  # Remove link
    
    # Scroll layer (doesn't exist yet)
    'scroll-layer.md': None,  # Will be created later
    'capa-scroll.md': None,  # Will be created later
}

# Path corrections for relative links
PATH_CORRECTIONS = {
    # Links to develop folder
    'develop/': '../develop/',
    '../develop/': '../develop/',
    
    # Links to kanata config
    '../kanata.kbd': '../../config/kanata.kbd',
    'kanata.kbd': '../../../config/kanata.kbd',
}

def fix_links_in_file(file_path):
    """Fix broken links in a single markdown file"""
    try:
        content = file_path.read_text(encoding='utf-8')
        original_content = content
        changes_made = []
        
        # Fix old UPPERCASE filenames
        for old_name, new_name in LINK_REPLACEMENTS.items():
            if old_name in content:
                if new_name is None:
                    # Remove the entire link entry if it's in a list
                    pattern = rf'- \*\*\[.*?\]\([^\)]*{re.escape(old_name)}\).*?\n'
                    if re.search(pattern, content):
                        content = re.sub(pattern, '', content)
                        changes_made.append(f"Removed link to {old_name}")
                    else:
                        # Just replace the filename
                        content = content.replace(old_name, '')
                        changes_made.append(f"Removed reference to {old_name}")
                else:
                    content = content.replace(old_name, new_name)
                    changes_made.append(f"Replaced {old_name} → {new_name}")
        
        # Fix path corrections
        for old_path, new_path in PATH_CORRECTIONS.items():
            if old_path in content:
                content = content.replace(old_path, new_path)
                changes_made.append(f"Fixed path: {old_path} → {new_path}")
        
        # Fix LICENSE paths (make them consistent)
        content = re.sub(r'\]\(\.\.\/\.\.\/LICENSE\)', '](../../../LICENSE)', content)
        
        # Only write if changes were made
        if content != original_content:
            file_path.write_text(content, encoding='utf-8')
            return changes_made
        
        return []
        
    except Exception as e:
        print(f"Error processing {file_path}: {e}")
        return []

def main():
    """Main execution"""
    doc_root = Path(__file__).parent.parent / "doc"
    
    print("="*70)
    print("🔧 Fixing Broken Links in Documentation")
    print("="*70)
    print()
    
    total_files = 0
    total_changes = 0
    
    # Process all markdown files
    for md_file in doc_root.rglob("*.md"):
        # Skip templates and develop folders
        if "templates" in str(md_file) or "develop" in str(md_file):
            continue
        
        changes = fix_links_in_file(md_file)
        
        if changes:
            total_files += 1
            total_changes += len(changes)
            relative_path = md_file.relative_to(doc_root.parent)
            print(f"\n📝 {relative_path}")
            for change in changes:
                print(f"   ✓ {change}")
    
    print()
    print("="*70)
    print(f"✅ Complete!")
    print(f"   Files modified: {total_files}")
    print(f"   Total changes: {total_changes}")
    print("="*70)
    print()
    print("Next steps:")
    print("1. Run: python scripts/validate_docs.py")
    print("2. Review remaining broken links")
    print("3. Commit changes")

if __name__ == "__main__":
    main()
