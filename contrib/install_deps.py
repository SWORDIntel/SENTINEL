#!/usr/bin/env python3
# SENTINEL dependency installer
# Handles installation of Python dependencies for ML and chat features

import os
import sys
import subprocess
import argparse
import platform
from pathlib import Path

# Define dependency groups
DEPENDENCIES = {
    "ml": ["markovify", "numpy"],
    "chat": ["llama-cpp-python", "rich", "readline"],
    "openvino": ["openvino"],
    "all": ["markovify", "numpy", "llama-cpp-python", "rich", "readline", "openvino"]
}

def check_pip():
    """Check if pip is available and install if not"""
    try:
        subprocess.run([sys.executable, "-m", "pip", "--version"], 
                      check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        return True
    except Exception:
        print("pip not found. Attempting to install pip...")
        try:
            subprocess.run([sys.executable, "-m", "ensurepip", "--upgrade"], check=True)
            return True
        except Exception as e:
            print(f"Error installing pip: {e}")
            return False

def check_venv():
    """Check if running in a virtual environment"""
    return hasattr(sys, 'real_prefix') or (hasattr(sys, 'base_prefix') and sys.base_prefix != sys.prefix)

def create_venv():
    """Create a virtual environment if not already in one"""
    if check_venv():
        print("Already running in a virtual environment")
        return True
        
    venv_dir = os.path.expanduser("~/.sentinel/venv")
    Path(venv_dir).parent.mkdir(parents=True, exist_ok=True)
    
    print(f"Creating virtual environment in {venv_dir}...")
    try:
        subprocess.run([sys.executable, "-m", "venv", venv_dir], check=True)
        
        # Generate activation instructions
        if platform.system() == "Windows":
            print("\nTo activate the virtual environment:")
            print(f"    {venv_dir}\\Scripts\\activate.bat")
        else:
            print("\nTo activate the virtual environment:")
            print(f"    source {venv_dir}/bin/activate")
            
        return True
    except Exception as e:
        print(f"Error creating virtual environment: {e}")
        return False

def install_deps(packages, upgrade=False):
    """Install specified packages using pip"""
    if not check_pip():
        return False
        
    cmd = [sys.executable, "-m", "pip", "install"]
    
    if upgrade:
        cmd.append("--upgrade")
        
    # Add packages to install
    cmd.extend(packages)
    
    print(f"Installing: {', '.join(packages)}")
    try:
        subprocess.run(cmd, check=True)
        return True
    except Exception as e:
        print(f"Error installing packages: {e}")
        return False

def check_deps(packages):
    """Check if packages are already installed"""
    missing = []
    for pkg in packages:
        try:
            __import__(pkg.split("[")[0].replace("-", "_"))
        except ImportError:
            missing.append(pkg)
    return missing

def main():
    parser = argparse.ArgumentParser(description="SENTINEL dependency installer")
    parser.add_argument("--group", choices=["ml", "chat", "openvino", "all"], 
                      default="all", help="Dependency group to install")
    parser.add_argument("--venv", action="store_true", 
                      help="Create and use a virtual environment")
    parser.add_argument("--check", action="store_true",
                      help="Check which dependencies are missing")
    parser.add_argument("--upgrade", action="store_true",
                      help="Upgrade existing packages")
    
    args = parser.parse_args()
    
    # Get packages to install
    packages = DEPENDENCIES.get(args.group, [])
    
    # Check if we're creating a venv
    if args.venv:
        create_venv()
        
    # Check or install
    if args.check:
        missing = check_deps(packages)
        if missing:
            print(f"Missing packages: {', '.join(missing)}")
            sys.exit(1)
        else:
            print(f"All {args.group} dependencies are installed")
            sys.exit(0)
    else:
        # Install missing packages
        missing = check_deps(packages)
        if missing or args.upgrade:
            to_install = packages if args.upgrade else missing
            if to_install:
                success = install_deps(to_install, args.upgrade)
                sys.exit(0 if success else 1)
            else:
                print("All dependencies already installed")
                sys.exit(0)
        else:
            print("All dependencies already installed")
            sys.exit(0)

if __name__ == "__main__":
    main() 