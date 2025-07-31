#!/usr/bin/env python3
import os
import re

def fix_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()
    
    original_content = content
    
    # Replace guard let ndk = appState.ndk with let ndk = appState.ndk
    content = re.sub(r'guard let ndk = appState\.ndk else \{ return \}', 'let ndk = appState.ndk', content)
    
    # Replace NDKUserMetadata(event: profile.event) with just profile
    content = re.sub(r'NDKUserMetadata\(event: profile\.event\)', 'profile', content)
    
    # Replace activeSigner references (seems to be a different property)
    # We'll need to handle this differently - commenting out for now
    
    if content != original_content:
        with open(filepath, 'w') as f:
            f.write(content)
        print(f"Fixed: {filepath}")
        return True
    return False

# Fix specific files mentioned in errors
files_to_fix = [
    'Sources/Highlighter/Views/Discovery/HighlightDiscoveryView.swift',
    'Sources/Highlighter/Views/Highlights/HighlightsFeedView.swift',
    'Sources/Highlighter/Views/Home/HomeDataManager.swift'
]

fixed_count = 0
for filepath in files_to_fix:
    if os.path.exists(filepath) and fix_file(filepath):
        fixed_count += 1

print(f"\nTotal files fixed: {fixed_count}")