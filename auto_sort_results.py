#!/usr/bin/env python3
"""
Results processor for auto_sort.py
Updates progress.md with new sorted files
"""

import os
import re
from pathlib import Path
import argparse
from datetime import datetime

def extract_current_entries(progress_file):
    """Extract existing entries from progress.md to avoid duplicates"""
    existing_entries = set()
    
    try:
        with open(progress_file, 'r', encoding='utf-8') as f:
            content = f.read()
            
        # Extract filenames from the table
        pattern = r'\| ([\w\-\_]+\.md) \|'
        matches = re.findall(pattern, content)
        existing_entries = set(matches)
    except Exception as e:
        print(f"Error reading progress file: {e}")
    
    return existing_entries

def format_entry(filename, category, subcategory=None, tags=None):
    """Format an entry for the progress.md table"""
    if subcategory is None:
        subcategory = ""
    
    if tags is None:
        tags = []
    
    tags_str = ", ".join(tags)
    
    return f"| {filename} | {category} | {subcategory} | {tags_str} |"

def generate_tags_from_category(category):
    """Generate basic tags based on category"""
    base_tags = {
        "malware": ["malware", "offensive"],
        "malware-rats": ["malware", "rat", "offensive", "remote-access"],
        "network": ["network", "protocol"],
        "osint": ["osint", "recon"],
        "ai": ["ai", "ml"],
        "proxy": ["proxy", "network"],
        "telegram": ["telegram", "communication"],
        "community": ["community", "social"],
        "productivity": ["productivity", "tool"],
        "wireless": ["wireless", "network"],
        "terminalai": ["terminal", "cli"]
    }
    
    return base_tags.get(category, [])

def update_progress_file(progress_file, new_entries, sort_entries=True):
    """Update progress.md with new entries"""
    try:
        with open(progress_file, 'r', encoding='utf-8') as f:
            lines = f.readlines()
        
        # Find the end of the table (before the footer)
        table_end = -1
        for i, line in enumerate(lines):
            if line.startswith('_This table will be updated'):
                table_end = i
                break
        
        if table_end == -1:
            print("Could not find the end of the table in progress.md")
            return False
        
        # Extract the existing table
        table_lines = []
        table_start = -1
        for i, line in enumerate(lines):
            if '|----------|' in line:
                table_start = i - 1
                break
        
        if table_start == -1:
            print("Could not find the start of the table in progress.md")
            return False
        
        # Get existing entries
        table_entries = lines[table_start+2:table_end]
        
        # Add new entries
        all_entries = table_entries + new_entries
        
        # Sort if requested
        if sort_entries:
            all_entries.sort()
        
        # Rebuild the file
        new_content = lines[:table_start+2] + all_entries + lines[table_end:]
        
        # Update timestamp in the footer line
        timestamp = datetime.now().strftime("%Y-%m-%d")
        footer_line = f"_This table will be updated as more files are tagged and classified. Last updated: {timestamp}_ \n"
        new_content[table_end] = footer_line
        
        with open(progress_file, 'w', encoding='utf-8') as f:
            f.writelines(new_content)
        
        print(f"Updated {progress_file} with {len(new_entries)} new entries")
        return True
        
    except Exception as e:
        print(f"Error updating progress file: {e}")
        return False

def main():
    """Main function to update progress.md with auto_sort results"""
    parser = argparse.ArgumentParser(description='Update progress.md with auto_sort results')
    parser.add_argument('--results-file', help='Results file from auto_sort.py (optional)')
    parser.add_argument('--progress-file', default='gitstar/readmes/UNSORTED/progress.md', help='Path to progress.md')
    
    args = parser.parse_args()
    
    # If results file is provided, read from it
    if args.results_file:
        # TODO: Implement reading from results file if needed
        pass
    
    # Get all directories in gitstar/readmes
    readmes_dir = Path('gitstar/readmes')
    categories = [d.name for d in readmes_dir.iterdir() if d.is_dir() and d.name != 'UNSORTED']
    
    # Get existing entries from progress.md
    existing_entries = extract_current_entries(args.progress_file)
    print(f"Found {len(existing_entries)} existing entries in progress.md")
    
    # Collect all .md files in each category directory
    new_entries = []
    for category in categories:
        category_dir = readmes_dir / category
        md_files = list(category_dir.glob('*.md'))
        
        for md_file in md_files:
            filename = md_file.name
            
            # Skip if already in progress.md
            if filename in existing_entries:
                continue
            
            # Generate basic tags
            tags = generate_tags_from_category(category)
            
            # Format and add the new entry
            entry = format_entry(filename, category, None, tags)
            new_entries.append(entry + '\n')
    
    print(f"Found {len(new_entries)} new entries to add")
    
    if new_entries:
        update_progress_file(args.progress_file, new_entries)
    else:
        print("No new entries to add")

if __name__ == "__main__":
    main() 