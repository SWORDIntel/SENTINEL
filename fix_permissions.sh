#!/bin/bash
# Script to fix line endings and permissions for SENTINEL ML files

# Fix line endings in shell script
dos2unix bash_modules.d/sentinel_ml
dos2unix contrib/sentinel_suggest.py
dos2unix contrib/sentinel_autolearn.py

# Make Python scripts executable
chmod +x contrib/sentinel_suggest.py
chmod +x contrib/sentinel_autolearn.py

echo "Fixed line endings and permissions for SENTINEL ML files"
