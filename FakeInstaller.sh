#!/usr/bin/env bash

# ============================================================
#  ENDLESS FAKE INSTALLER (Bash Edition)
#  Fully Safe – Purely Cosmetic
# ============================================================

# --- Colors ---
RED="\e[31m"; GREEN="\e[32m"; YELLOW="\e[33m"; BLUE="\e[34m"
MAGENTA="\e[35m"; CYAN="\e[36m"; GRAY="\e[90m"; RESET="\e[0m"
BRIGHT="\e[1m"; WHITE="\e[97m"

# --- Data lists ---
PREFIXES=(lib gnome linux python3 node docker k8s vim gcc openssl systemd mesa amd intel)
SUFFIXES=(core dev utils common bin libs daemon plugin base engine mod)
REPOS=(
    "http://archive.ubuntu.com/ubuntu"
    "http://security.ubuntu.com/ubuntu"
    "https://packages.cloud.google.com/apt"
)
DISTROS=(focal jammy noble bionic)
SECTIONS=(main universe multiverse restricted)

# --- Helpers ---
rand() { shuf -i "$1"-"$2" -n 1; }

rand_item() {
    local arr=("$@")
    echo "${arr[$(rand 0 $((${#arr[@]} - 1)))]}"
}

pkg_name() { echo "$(rand_item "${PREFIXES[@]}")-$(rand_item "${SUFFIXES[@]}")"; }
version() { echo "$(rand 0 9).$(rand 0 20).$(rand 0 99)-$(rand 1 5)ubuntu$(rand 1 4)"; }

pause() { sleep "$(awk -v min=$1 -v max=$2 'BEGIN{srand(); print min+rand()*(max-min)}')"; }

progress_bar() {
    local label="$1"
    local width=38

    echo -ne "\e[?25l"  # hide cursor

    for i in $(seq 0 $(rand 95 100)); do
        filled=$((i * width / 100))
        empty=$((width - filled))

        printf "\r${BRIGHT}%s${RESET} " "$label"
        printf "${WHITE}"; printf "█%.0s" $(seq 1 $filled)
        printf "${GRAY}"; printf "░%.0s" $(seq 1 $empty)
        printf "${RESET} ${GREEN}%d%%%s" "$i" "$RESET"

        pause 0.01 0.05
    done

    echo -ne "\r${BRIGHT}$label${RESET} "
    printf "█%.0s" $(seq 1 $width)
    echo -e " ${GREEN}100%${RESET}"

    echo -ne "\e[?25h" # show cursor
}

print_prompt() {
    echo -e "${GREEN}➜${RESET} ${CYAN}~${RESET} ${GRAY}git:(${RED}main${GRAY})${RESET} $1"
    pause 0.15 0.35
}

apt_update_sim() {
    print_prompt "sudo apt-get update"

    for i in $(seq 1 $(rand 15 40)); do
        type="Get"; color="$BLUE"
        r=$(rand 1 100)
        [[ $r -gt 90 ]] && type="Ign" && color="$GRAY"
        [[ $r -gt 75 && $r -le 90 ]] && type="Hit" && color="$GREEN"

        repo=$(rand_item "${REPOS[@]}")
        distro=$(rand_item "${DISTROS[@]}")
        section=$(rand_item "${SECTIONS[@]}")

        size=""
        [[ $type == "Get" ]] && size=" [${YELLOW}$(rand 1000 50000) B${RESET}]"

        echo -e "${color}${type}:${i}${RESET} $repo ${CYAN}$distro${RESET} $section$size"
        pause 0.02 0.12
    done

    echo -e "Fetched ${YELLOW}$(rand 3000 90000) kB${RESET} in $(rand 1 3)s"
    echo -e "${GRAY}Reading package lists...${RESET} Done"
}

apt_install_sim() {
    local count=$(rand 3 12)
    local pkgs=()

    for _ in $(seq 1 $count); do pkgs+=("$(pkg_name)"); done

    print_prompt "sudo apt-get install -y ${pkgs[*]}"

    echo "Reading package lists... Done"
    echo "Building dependency tree..."
    echo "Reading state information... Done"

    echo -e "${CYAN}The following NEW packages will be installed:${RESET}"
    echo -e "  ${BRIGHT}${pkgs[*]}${RESET}"

    echo "Need to get $(rand 10 400) MB of archives."
    echo "After this operation, $(rand 200 1500) MB of disk space will be used."
    pause 0.5 1

    for pkg in "${pkgs[@]}"; do
        echo -e "${BLUE}Get:${RESET} $pkg $(version) [${YELLOW}$(rand 100 8000) kB${RESET}]"
        pause 0.03 0.15
    done

    echo -e "${GRAY}------------------------------------------------------------${RESET}"
    progress_bar "Reading database ..."

    for pkg in "${pkgs[@]}"; do
        v=$(version)
        echo "Preparing to unpack .../$pkg-$v.deb ..."
        pause 0.03 0.12
        echo "Unpacking $pkg ($v) ..."
        pause 0.04 0.2
    done

    for pkg in "${pkgs[@]}"; do
        echo -e "Setting up ${GREEN}${pkg}${RESET} ($(version)) ..."
        [[ $(rand 0 100) -gt 75 ]] && progress_bar "Compiling $pkg"
        pause 0.05 0.25
    done
}

# --- Startup banner ---
clear
echo -e "${GREEN}User:${RESET} $USER"
echo -e "${GREEN}Host:${RESET} $(hostname)"
echo -e "${GRAY}System Check: OK${RESET}"
echo

# Cleanup on Ctrl+C
trap "echo -e \"\n${RED}ABORTED BY USER${RESET}\"; tput cnorm; exit" SIGINT

# Main loop
while true; do
    if (( $(rand 1 100) > 50 )); then
        apt_update_sim
    else
        apt_install_sim
    fi
    pause 0.4 1.2
done
