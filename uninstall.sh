#!/usr/bin/env bash
set -euo pipefail

# Claude Code Hybrid Model System Uninstaller

BOLD="\033[1m"
GREEN="\033[32m"
YELLOW="\033[33m"
RED="\033[31m"
RESET="\033[0m"

info()  { echo -e "\033[36m[INFO]\033[0m $1"; }
ok()    { echo -e "${GREEN}[OK]${RESET} $1"; }
warn()  { echo -e "${YELLOW}[WARN]${RESET} $1"; }

MARKER_START="# === CLAUDE HYBRID START ==="
MARKER_END="# === CLAUDE HYBRID END ==="

echo ""
echo -e "${BOLD}Uninstalling Claude Code Hybrid Model System${RESET}"
echo "=============================================="
echo ""

# Remove shell functions
for RC in "$HOME/.zshrc" "$HOME/.bashrc"; do
    if [[ -f "$RC" ]] && grep -q "$MARKER_START" "$RC" 2>/dev/null; then
        sed -i.bak "/$MARKER_START/,/$MARKER_END/d" "$RC"
        ok "Removed hybrid functions from $RC"
    fi
done

# Remove tmux hook from config
if [[ -f "$HOME/.tmux.conf" ]]; then
    if grep -q 'tmux-hybrid-hook' "$HOME/.tmux.conf"; then
        sed -i.bak '/HYBRID MODEL HOOK/d; /tmux-hybrid-hook/d' "$HOME/.tmux.conf"
        ok "Removed hook from tmux.conf"
    fi
    tmux source-file "$HOME/.tmux.conf" 2>/dev/null || true
fi

# Remove hook script
rm -f "$HOME/.tmux-hybrid-hook.sh"
ok "Removed hook script"

# Remove marker file
rm -f "$HOME/.claude-hybrid-active"
ok "Removed active marker"

echo ""
echo -e "${YELLOW}Kept:${RESET} ~/.claude-models/ (your API keys are safe)"
echo "  To remove model profiles too: rm -rf ~/.claude-models/"
echo ""
echo -e "${BOLD}Uninstall complete.${RESET} Restart your shell to apply."
echo ""
