#!/usr/bin/env python3
"""
sync_repo_data.py

Synchronizes repo_data.json with the README subfolder structure and categories.json.
- Updates each repository's readme_path to reflect the new subfolder (based on cluster/category).
- Validates that the README file exists at the new location.
- Logs all actions and errors.
- Provides a summary report at the end.

Security/Robustness:
- Comprehensive error handling
- Input validation
- Logging to file and stdout
- Dry-run mode for safe testing
- Linux-first, portable

References:
- CWE-915: Improperly Controlled Modification of Dynamically-Determined Object Attributes
- CWE-706: Use of Incorrectly-Resolved Name or Reference

Usage:
    python3 sync_repo_data.py [--dry-run]

Testing:
- Run with --dry-run to preview changes
- Check logs for errors or missing files

"""
import os
import sys
import json
import logging
from argparse import ArgumentParser
from datetime import datetime

# --- CONFIGURATION ---
REPO_DATA_PATH = os.path.join('gitstar', 'repo_data.json')
CATEGORIES_PATH = os.path.join('gitstar', 'categories.json')
README_BASE = os.path.join('gitstar', 'readmes')
LOG_PATH = os.path.join('gitstar', f'sync_repo_data_{datetime.now().strftime("%Y%m%d_%H%M%S")}.log')

# --- LOGGING SETUP ---
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s [%(levelname)s] %(message)s',
    handlers=[
        logging.FileHandler(LOG_PATH),
        logging.StreamHandler(sys.stdout)
    ]
)

def load_json(path):
    try:
        with open(path, 'r', encoding='utf-8') as f:
            return json.load(f)
    except Exception as e:
        logging.error(f"Failed to load {path}: {e}")
        sys.exit(1)

def save_json(path, data):
    try:
        with open(path, 'w', encoding='utf-8') as f:
            json.dump(data, f, indent=2, ensure_ascii=False)
    except Exception as e:
        logging.error(f"Failed to save {path}: {e}")
        sys.exit(1)

def get_category_folder(cluster_id):
    # Map cluster/category ID to folder name (must match your subfolder names)
    mapping = {
        0: 'osint', 1: 'badges', 2: 'network', 3: 'telegram', 4: 'ui', 5: 'license',
        6: 'download', 7: 'ai', 8: 'osint', 9: 'malware', 10: 'cve', 11: 'docs',
        12: 'exploit', 13: 'proxy', 14: 'ci', 15: 'crypto', 16: 'docker',
        17: 'wireless', 18: 'linux', 19: 'telecom'
    }
    return mapping.get(cluster_id, None)

def main(dry_run=False):
    repo_data = load_json(REPO_DATA_PATH)
    categories = load_json(CATEGORIES_PATH)
    updated = 0
    missing = 0
    unchanged = 0
    for repo in repo_data.get('repositories', []):
        cluster = repo.get('cluster')
        old_path = repo.get('readme_path')
        if not old_path:
            logging.warning(f"Repo {repo.get('full_name')} missing readme_path.")
            continue
        filename = os.path.basename(old_path)
        folder = get_category_folder(cluster)
        if not folder:
            logging.warning(f"Repo {repo.get('full_name')} has unknown cluster/category: {cluster}")
            continue
        new_path = os.path.join(README_BASE, folder, filename)
        if os.path.abspath(old_path) == os.path.abspath(new_path):
            unchanged += 1
            continue
        if os.path.exists(new_path):
            logging.info(f"Updating {repo.get('full_name')}: {old_path} -> {new_path}")
            if not dry_run:
                repo['readme_path'] = os.path.abspath(new_path)
            updated += 1
        else:
            logging.error(f"Missing file for {repo.get('full_name')}: {new_path}")
            missing += 1
    if not dry_run:
        save_json(REPO_DATA_PATH, repo_data)
    logging.info(f"Sync complete. Updated: {updated}, Missing: {missing}, Unchanged: {unchanged}")
    print(f"\nSummary:\n  Updated: {updated}\n  Missing: {missing}\n  Unchanged: {unchanged}\n  Log: {LOG_PATH}")

if __name__ == '__main__':
    parser = ArgumentParser(description="Sync repo_data.json with README subfolders and categories.")
    parser.add_argument('--dry-run', action='store_true', help='Preview changes without writing.')
    args = parser.parse_args()
    main(dry_run=args.dry_run) 