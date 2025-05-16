#!/usr/bin/env bash
###############################################################################
# SENTINEL – secure uninstaller
# -----------------------------------------------
# Version : 2.1.0        (2025-05-16)
# Purpose : Remove ONLY the runtime artefacts living
#           inside $HOME, leaving source trees alone.
###############################################################################
# Hardening principles
#   • Strict mode (`set -euo pipefail`)
#   • Positive-match whitelist: we delete only
#       – $HOME/.sentinel
#       – cache / logs / loaders inside $HOME
#       – dotfiles we *know* we wrote
#   • Any path must start with "$HOME/" or we refuse.
#   • No globbing that can expand outside $HOME
#   • Idempotent – safe to run multiple times.
###############################################################################

set -euo pipefail

###############################
# 0.  Helpers & colour macros #
###############################
# shellcheck disable=SC2034
c_red=$'\033[1;31m'; c_green=$'\033[1;32m'; c_yellow=$'\033[1;33m'; c_blue=$'\033[1;34m'; c_nc=$'\033[0m'

say()   { printf '%b%s%b\n' "$1" "$2" "$c_nc"; }
step()  { say "$c_blue"   "==> $*"; }
ok()    { say "$c_green"  "✔  $*"; }
warn()  { say "$c_yellow" "⚠  $*"; }
fail()  { say "$c_red"    "✖  $*"; exit 1; }

ensure_home_path() {
  # abort if $1 is not under $HOME (prevents repo deletion accidents)
  [[ $1 == "${HOME}/"* ]] || fail "Refusing to touch non-HOME path: $1"
}

trap 'fail "Uninstaller aborted on line $LINENO"' ERR

############################################
# 1.  Confirm user really wants to proceed #
############################################
step "This will remove SENTINEL runtime files *only* from ${HOME}"
read -rp "Continue? (y/N): " ans
[[ ${ans,,} == y ]] || { warn "Abort"; exit 0; }

#######################################
# 2.  Back-up ~/.sentinel if it exists #
#######################################
BACKUP_DIR="${HOME}/.sentinel_backup_$(date +%Y%m%d%H%M%S)"
if [[ -d ${HOME}/.sentinel ]]; then
  step "Backing up .sentinel to ${BACKUP_DIR}"
  mkdir -p "${BACKUP_DIR}"
  cp -a -- "${HOME}/.sentinel" "${BACKUP_DIR}/"
  ok  ".sentinel backed-up"
fi

#################################
# 3.  Whitelist of runtime paths #
#################################
RUNTIME_PATHS=(
  "${HOME}/.sentinel"
  "${HOME}/.local/share/blesh"
  "${HOME}/.cache/blesh"
  "${HOME}/.blerc"
  "${HOME}/.sentinel/blesh_loader.sh"
  "${HOME}/.sentinel/logs"
  "${HOME}/.sentinel/autocomplete"
)

########################################
# 4.  Remove each runtime path safely  #
########################################
for p in "${RUNTIME_PATHS[@]}"; do
  ensure_home_path "$p"
  if [[ -e $p || -L $p ]]; then
    step "Removing ${p}"
    rm -rf -- "$p"
    [[ ! -e $p && ! -L $p ]] && ok "${p} removed" || warn "Could not remove ${p}"
  fi
done

##############################################################
# 5.  Clean SENTINEL/BLE lines from user shell configuration #
##############################################################
CLEAN_FILES=("${HOME}/.bashrc" "${HOME}/.bashrc.postcustom" "${HOME}/.bashrc.precustom")
PATTERN='(SENTINEL|sentinel|blesh_loader\.sh|BLE\.sh|@autocomplete)'
for f in "${CLEAN_FILES[@]}"; do
  ensure_home_path "$f"
  if [[ -f $f ]]; then
    step "Sanitising ${f}"
    # create a temp copy without matching lines, then move in place atomically
    tmp=$(mktemp)
    grep -Ev "${PATTERN}" "$f" > "$tmp" || true
    mv -- "$tmp" "$f"
    bash -n "$f" && ok "${f} cleaned" || warn "syntax check failed for ${f}"
  fi
done

###############################################
# 6.  Restore backups (.bak) where they exist #
###############################################
restore_latest_bak() {
  local target="$1"
  local latest
  latest=$(ls -t "${target}.bak"* 2>/dev/null | head -n1 || true)
  if [[ -n $latest ]]; then
    step "Restoring ${target} from ${latest}"
    cp -- "$latest" "$target"
    ok "Restored ${target}"
  fi
}
for t in "${HOME}/.bashrc" "${HOME}/.bash_aliases" "${HOME}/.bash_functions" "${HOME}/.bash_completion"; do
  restore_latest_bak "$t"
done

########################################################
# 7.  Final scan – report anything SENTINEL-coloured   #
########################################################
step "Scanning for residual SENTINEL/BLE.sh artefacts in \$HOME…"
remain=$(find "${HOME}" -maxdepth 4 \( -name '*sentinel*' -o -name '*blesh*' \) 2>/dev/null \
         | grep -v -E 'sentinel_backup' || true)
if [[ -n $remain ]]; then
  warn "Residual paths detected – inspect manually:"
  echo "$remain"
else
  ok "No SENTINEL artefacts remain in \$HOME"
fi

echo
ok  "SENTINEL uninstalled safely."
echo "Back-up folder: ${BACKUP_DIR}"
echo "Please restart your terminal."
