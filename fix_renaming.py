#!/usr/bin/env python3
import os
import re

def fix_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()
    
    original_content = content
    
    # Replace .observe( with .subscribe(
    content = re.sub(r'\.observe\(', '.subscribe(', content)
    
    # Replace NDKDataSource with NDKSubscription
    content = re.sub(r'\bNDKDataSource\b', 'NDKSubscription', content)
    
    if content != original_content:
        with open(filepath, 'w') as f:
            f.write(content)
        print(f"Fixed: {filepath}")
        return True
    return False

# Find all Swift files
fixed_count = 0
for root, dirs, files in os.walk('Sources'):
    for file in files:
        if file.endswith('.swift'):
            filepath = os.path.join(root, file)
            if fix_file(filepath):
                fixed_count += 1

print(f"\nTotal files fixed: {fixed_count}")