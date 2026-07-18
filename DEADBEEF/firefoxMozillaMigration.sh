#!/usr/bin/env bash
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

BACKUP_DIR=""

step() {
    echo
    echo -e "${GREEN}[$1]${NC} $2"
}

info() { echo -e "${BLUE}$*${NC}"; }
warn() { echo -e "${YELLOW}$*${NC}"; }
fail() { echo -e "${RED}$*${NC}"; exit 1; }

require_cmd() {
    command -v "$1" >/dev/null 2>&1 || fail "Missing required command: $1"
}

clear
echo -e "${BLUE}"
echo "==============================================="
echo " Firefox Snap → Mozilla APT Migration Utility"
echo "==============================================="
echo -e "${NC}"

[[ -f /etc/os-release ]] || fail "Cannot determine operating system."
source /etc/os-release
[[ "$ID" == "ubuntu" ]] || fail "This script supports Ubuntu only."

for cmd in sudo apt tee curl gpg; do
    require_cmd "$cmd"
done

step "1/10" "Checking Internet connectivity"
ping -c1 archive.ubuntu.com >/dev/null 2>&1 || fail "Internet connection required."

if pgrep -x firefox >/dev/null; then
    warn "Firefox is currently running."
    read -rp "Close Firefox and continue anyway? (y/N): " r
    [[ "$r" =~ ^[Yy]$ ]] || exit 0
fi

SNAP_PROFILE="$HOME/snap/firefox/common/.mozilla"

if snap list firefox >/dev/null 2>&1; then
    step "2/10" "Snap Firefox detected"

    if [[ -d "$SNAP_PROFILE" ]]; then
        echo "Profile: $SNAP_PROFILE"
        read -rp "Create backup? (y/N): " ans
        if [[ "$ans" =~ ^[Yy]$ ]]; then
            BACKUP_DIR="$HOME/firefox-snap-backup-$(date +%F-%H%M%S)"
            cp -a "$SNAP_PROFILE" "$BACKUP_DIR"
            [[ -d "$BACKUP_DIR" ]] || fail "Backup failed."
            info "Backup created:"
            echo "  $BACKUP_DIR"
        fi
    fi
else
    warn "Snap Firefox not installed."
fi

echo
echo "This utility will:"
echo " • Remove the Firefox Snap (if installed)"
echo " • Configure Mozilla's official APT repository"
echo " • Install Firefox from APT"
echo

read -rp "Continue? (y/N): " go
[[ "$go" =~ ^[Yy]$ ]] || exit 0

step "3/10" "Removing Snap Firefox"
if snap list firefox >/dev/null 2>&1; then
    sudo snap remove --purge firefox
fi

step "4/10" "Creating keyring directory"
sudo install -d -m 0755 /etc/apt/keyrings

step "5/10" "Installing Mozilla signing key"
curl -fsSL https://packages.mozilla.org/apt/repo-signing-key.gpg \
| sudo gpg --dearmor -o /etc/apt/keyrings/packages.mozilla.org.gpg

step "6/10" "Adding Mozilla repository"
echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.gpg] https://packages.mozilla.org/apt mozilla main" \
| sudo tee /etc/apt/sources.list.d/mozilla.list >/dev/null

step "7/10" "Configuring APT pinning"
sudo tee /etc/apt/preferences.d/mozilla >/dev/null <<'EOF'
Package: *
Pin: origin packages.mozilla.org
Pin-Priority: 1000
EOF

step "8/10" "Updating package lists"
sudo apt update

step "9/10" "Installing Firefox"
sudo apt install -y firefox

if [[ -d "$SNAP_PROFILE/firefox" && ! -d "$HOME/.mozilla/firefox" ]]; then
    read -rp "Import your old Firefox profile? (y/N): " migrate
    if [[ "$migrate" =~ ^[Yy]$ ]]; then
        mkdir -p "$HOME/.mozilla"
        cp -a "$SNAP_PROFILE/firefox" "$HOME/.mozilla/"
        info "Profile copied."
    fi
fi

step "10/10" "Verifying installation"

command -v firefox >/dev/null || fail "Firefox installation could not be verified."

echo
echo "==============================================="
echo " Migration Complete"
echo "==============================================="
echo

firefox --version
echo
echo "Installation source : Mozilla APT Repository"
echo "Profile location    : $HOME/.mozilla/firefox"

if [[ -n "$BACKUP_DIR" ]]; then
    echo "Backup location     : $BACKUP_DIR"
fi

echo
echo "You can now launch Firefox normally."
