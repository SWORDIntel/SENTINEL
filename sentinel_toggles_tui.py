#!/usr/bin/env python3
"""
SENTINEL Toggle TUI (Standalone)
--------------------------------
A simple, secure terminal UI for toggling SENTINEL feature modules and core/security options.

- Run: ./sentinel_toggles_tui.py
- Uses npyscreen for the interface
- Edits ~/bashrc.postcustom and ~/bashrc.precustom
- Preserves comments and structure, makes backups
- Linux-first, security-focused

Author: SENTINEL Team
"""
import npyscreen
import os
import re
import shutil
import logging

BASHRC_PRECUSTOM = os.path.expanduser('~/bashrc.precustom')
BASHRC_POSTCUSTOM = os.path.expanduser('~/bashrc.postcustom')
BACKUP_SUFFIX = '.bak'

logging.basicConfig(filename=os.path.expanduser('~/.sentinel/toggle_tui.log'),
                    level=logging.INFO,
                    format='%(asctime)s %(levelname)s %(message)s')

def parse_exports(filepath, keys=None):
    exports = {}
    try:
        with open(filepath, 'r') as f:
            for i, line in enumerate(f):
                m = re.match(r'\s*export\s+([A-Za-z0-9_]+)=(\d+)', line)
                if m:
                    var, val = m.group(1), m.group(2)
                    if (keys is None) or (var in keys):
                        exports[var] = (val, i, line.rstrip('\n'))
    except Exception as e:
        logging.error(f"Failed to parse {filepath}: {e}")
    return exports

def update_exports(filepath, updates):
    try:
        with open(filepath, 'r') as f:
            lines = f.readlines()
        for var, new_val in updates.items():
            for i, line in enumerate(lines):
                if re.match(rf'\s*export\s+{re.escape(var)}=', line):
                    lines[i] = re.sub(r'(export\s+' + re.escape(var) + r'=)\d+', rf'\g<1>{new_val}', line)
        shutil.copy2(filepath, filepath + BACKUP_SUFFIX)
        with open(filepath, 'w') as f:
            f.writelines(lines)
        logging.info(f"Updated {filepath}: {updates}")
        return True
    except Exception as e:
        logging.error(f"Failed to update {filepath}: {e}")
        return False

FEATURE_TOGGLES = [
    'SENTINEL_FZF_ENABLED',
    'SENTINEL_ML_ENABLED',
    'SENTINEL_OSINT_ENABLED',
    'SENTINEL_CYBERSEC_ENABLED',
    'SENTINEL_GITSTAR_ENABLED',
    'SENTINEL_CHAT_ENABLED',
]
CORE_TOGGLES = [
    'U_BINS', 'U_FUNCS', 'U_ALIASES', 'U_AGENTS', 'ENABLE_LESSPIPE', 'U_MODULES_ENABLE',
    'VENV_AUTO', 'SENTINEL_SECURE_RM', 'SENTINEL_QUIET_MODULES', 'SENTINEL_SECURE_BASH_HISTORY',
    'SENTINEL_SECURE_SSH_KNOWN_HOSTS', 'SENTINEL_SECURE_CLEAN_CACHE', 'SENTINEL_SECURE_BROWSER_CACHE',
    'SENTINEL_SECURE_RECENT', 'SENTINEL_SECURE_VIM_UNDO', 'SENTINEL_SECURE_CLIPBOARD',
    'SENTINEL_SECURE_CLEAR_SCREEN', 'U_LAZY_LOAD', 'BASHRC_PROFILE'
]

class ToggleForm(npyscreen.ActionForm):
    def create(self):
        self.add(npyscreen.FixedText, value="SENTINEL Toggle TUI", editable=False, color='STANDOUT')
        self.add(npyscreen.FixedText, value="(Use arrows/space to toggle, ^S to save, ^Q to quit)", editable=False)
        self.add(npyscreen.FixedText, value="\n[Security Warning] Only trusted users should edit these files!", editable=False, color='DANGER')
        self.add(npyscreen.FixedText, value="\nFeature Module Toggles:", editable=False, color='LABEL')
        self.feature_toggles = self.add(npyscreen.TitleMultiSelect, max_height=8, name="Feature Modules",
                                        values=FEATURE_TOGGLES, scroll_exit=True)
        self.add(npyscreen.FixedText, value="\nCore/Security Toggles:", editable=False, color='LABEL')
        self.core_toggles = self.add(npyscreen.TitleMultiSelect, max_height=12, name="Core/Security", 
                                     values=CORE_TOGGLES, scroll_exit=True)
        self.status = self.add(npyscreen.FixedText, value="", editable=False, color='CAUTION')
        self.help_btn = self.add(npyscreen.ButtonPress, name="Help", when_pressed_function=self.show_help)
        self.reload_btn = self.add(npyscreen.ButtonPress, name="Reload", when_pressed_function=self.reload)
        self.reload()

    def reload(self):
        self.feature_vals = parse_exports(BASHRC_POSTCUSTOM, FEATURE_TOGGLES)
        self.core_vals = parse_exports(BASHRC_PRECUSTOM, CORE_TOGGLES)
        self.feature_toggles.value = [i for i, k in enumerate(FEATURE_TOGGLES) if self.feature_vals.get(k, ('0',))[0] == '1']
        self.core_toggles.value = [i for i, k in enumerate(CORE_TOGGLES) if self.core_vals.get(k, ('0',))[0] == '1']
        self.status.value = ""
        self.display()

    def on_ok(self):
        feature_updates = {k: '1' if i in self.feature_toggles.value else '0' for i, k in enumerate(FEATURE_TOGGLES)}
        core_updates = {k: '1' if i in self.core_toggles.value else '0' for i, k in enumerate(CORE_TOGGLES)}
        if npyscreen.notify_yes_no("Save changes to toggles? (Backups will be made)", title="Confirm Save"):
            ok1 = update_exports(BASHRC_POSTCUSTOM, feature_updates)
            ok2 = update_exports(BASHRC_PRECUSTOM, core_updates)
            if ok1 and ok2:
                self.status.value = "Toggles updated successfully."
            else:
                self.status.value = "Error updating toggles. Check logs."
            self.display()

    def on_cancel(self):
        if npyscreen.notify_yes_no("Exit without saving changes?", title="Exit"):
            self.parentApp.setNextForm(None)

    def show_help(self):
        npyscreen.notify_confirm(
            "Use arrows/space to select toggles.\n"
            "Checked = enabled (1), unchecked = disabled (0).\n"
            "^S to save, ^Q to quit.\n"
            "Backups are made before writing.\n"
            "Security: Only trusted users should edit these files!\n",
            title="Help / Security Notice")

class SentinelToggleApp(npyscreen.NPSAppManaged):
    def onStart(self):
        self.addForm('MAIN', ToggleForm)

if __name__ == '__main__':
    try:
        app = SentinelToggleApp()
        app.run()
    except Exception as e:
        logging.error(f"Fatal error in TUI: {e}")
        print(f"[ERROR] {e}\nSee ~/.sentinel/toggle_tui.log for details.") 