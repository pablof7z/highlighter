#\!/usr/bin/env python3
import re
import sys

def count_parens(line):
    """Count open and close parentheses in a line."""
    open_count = 0
    close_count = 0
    in_string = False
    escape_next = False
    
    for i, char in enumerate(line):
        if escape_next:
            escape_next = False
            continue
            
        if char == '\\':
            escape_next = True
            continue
            
        if char == '"' and not in_string:
            in_string = True
        elif char == '"' and in_string:
            # Check if it's escaped
            if i > 0 and line[i-1] \!= '\\':
                in_string = False
                
        if not in_string:
            if char == '(':
                open_count += 1
            elif char == ')':
                close_count += 1
                
    return open_count, close_count

def fix_file(filepath):
    """Fix missing closing parentheses in a Swift file."""
    with open(filepath, 'r') as f:
        lines = f.readlines()
    
    modified = False
    paren_balance = 0
    
    for i, line in enumerate(lines):
        open_count, close_count = count_parens(line)
        paren_balance += open_count - close_count
        
        # Check if we need to add closing parentheses at end of line
        if paren_balance > 0 and i < len(lines) - 1:
            next_line = lines[i + 1] if i + 1 < len(lines) else ""
            # If next line starts with a dot (method chaining), don't add parens yet
            if not next_line.strip().startswith('.'):
                # Check if this line ends a statement
                stripped = line.rstrip()
                if stripped and not stripped.endswith(',') and not stripped.endswith('{'):
                    # Add missing parentheses
                    missing_parens = ')' * paren_balance
                    lines[i] = line.rstrip() + missing_parens + '\n'
                    paren_balance = 0
                    modified = True
    
    if modified:
        with open(filepath, 'w') as f:
            f.writelines(lines)
        print(f"Fixed {filepath}")
    
    return modified

if __name__ == "__main__":
    if len(sys.argv) > 1:
        fix_file(sys.argv[1])
    else:
        print("Usage: python fix_parentheses.py <filepath>")
