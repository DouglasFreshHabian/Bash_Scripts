#!/usr/bin/env bash
# BE SAFE...  I am still testing this script
set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

clear

echo -e "${BLUE}"
echo "=========================================="
echo " Firefox Snap → Mozilla APT Migration"
echo "=========================================="
echo -e "${NC}"

# Check root privileges are available
if ! command -v sudo &>/dev/null; then
    echo -e "${RED}Error: sudo is required.${NC}"
    exit 1
fi

# Check Ubuntu
if [ ! -f /etc/os-release ]; then
    echo -e "${RED}Cannot determine operating system.${NC}"
    exit 1
fi

source /etc/os-release

if [[ "$ID" != "ubuntu" ]]; then
    echo -e "${RED}This script is intended for Ubuntu systems only.${NC}"
    exit 1
fi

echo -e "${YELLOW}This script will:${NC}"
echo "  1. Detect and optionally back up Snap Firefox data"
echo "  2. Remove Ubuntu's Snap Firefox package"
echo "  3. Add the Mozilla Team Firefox PPA"
echo "  4. Configure APT pinning"
echo "  5. Install Firefox through APT"
echo
echo "This is intended for users who want:"
echo "  - easier Firefox customization"
echo "  - user.js management"
echo "  - advanced extensions/add-on workflows"
echo "  - scripting and profile control"
echo

# Check if Firefox is running
if pgrep -x firefox >/dev/null; then
    echo -e "${YELLOW}Firefox appears to be running.${NC}"
    echo "Please close Firefox before continuing."
    read -p "Continue anyway? (y/N): " running

    if [[ "$running" != "y" && "$running" != "Y" ]]; then
        echo -e "${RED}Cancelled.${NC}"
        exit 0
    fi
fi

# Detect Snap Firefox
SNAP_INSTALLED=false

if snap list firefox &>/dev/null; then
    SNAP_INSTALLED=true
    echo -e "${GREEN}Snap Firefox detected.${NC}"

    SNAP_PROFILE="$HOME/snap/firefox/common/.mozilla"

    if [ -d "$SNAP_PROFILE" ]; then

        echo
        echo -e "${YELLOW}Firefox Snap profile found:${NC}"
        echo "$SNAP_PROFILE"
        echo

        read -p "Back up your Firefox profile before continuing? (y/N): " backup

        if [[ "$backup" == "y" || "$backup" == "Y" ]]; then

            BACKUP_DIR="$HOME/firefox-snap-backup-$(date +%F-%H%M%S)"

            echo -e "${BLUE}Creating backup...${NC}"

            cp -a "$SNAP_PROFILE" "$BACKUP_DIR"

            echo -e "${GREEN}Backup completed:${NC}"
            echo "$BACKUP_DIR"

        else
            echo -e "${YELLOW}Skipping backup.${NC}"
        fi

    else
        echo -e "${YELLOW}Snap Firefox detected, but no profile directory was found.${NC}"
    fi

else
    echo -e "${YELLOW}Snap Firefox not detected.${NC}"
fi

echo
read -p "Proceed with Firefox migration? (y/N): " answer

if [[ "$answer" != "y" && "$answer" != "Y" ]]; then
    echo -e "${RED}Cancelled.${NC}"
    exit 0
fi


# Remove Snap Firefox only if present
if [[ "$SNAP_INSTALLED" == true ]]; then
    echo -e "${GREEN}[1/5] Removing Snap Firefox...${NC}"
    sudo snap remove --purge firefox
else
    echo -e "${GREEN}[1/5] Snap Firefox not installed. Skipping removal.${NC}"
fi


echo -e "${GREEN}[2/5] Adding Mozilla Team PPA...${NC}"
sudo add-apt-repository -y ppa:mozillateam/ppa


echo -e "${GREEN}[3/5] Configuring Firefox APT priority...${NC}"

sudo tee /etc/apt/preferences.d/mozilla-firefox >/dev/null <<EOF
Package: *
Pin: release o=LP-PPA-mozillateam
Pin-Priority: 1001
EOF


sudo tee /etc/apt/apt.conf.d/51unattended-upgrades-firefox >/dev/null <<EOF
Unattended-Upgrade::Allowed-Origins:: "LP-PPA-mozillateam:${VERSION_CODENAME}";
EOF


echo -e "${GREEN}[4/5] Updating package lists...${NC}"
sudo apt update


echo -e "${GREEN}[5/5] Installing Firefox from APT...${NC}"
sudo apt install -y firefox --allow-downgrades


echo
echo -e "${GREEN}=========================================="
echo " Firefox installation complete!"
echo "==========================================${NC}"

firefox --version

echo
echo -e "${YELLOW}Note:${NC}"
echo "Your Snap Firefox profile was backed up if you selected that option."
echo "Profile migration into the new Firefox installation may require"
echo "additional steps depending on your Firefox profile setup."
