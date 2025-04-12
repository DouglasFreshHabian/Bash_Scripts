#!/bin/bash

# A simple Bash script that randomnly prints to the screen one of 9 methods of getting your hostname on linux
# The script needs figlet in order to function properly

# Define colors for output
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RESET='\033[0m'

if ! command -v figlet &> /dev/null; then
    error_exit "figlet command is not available, please install it."
fi
# List of all 9 ways to get the hostname
commands=(
    "cat /etc/hostname"
    "hostname -A"
    "cat /proc/sys/kernel/hostname"
    "nmcli general hostname"
    "getent hosts \$(hostname -i)"
    "grep \$(hostname) /etc/hosts"
    "hostnamectl --static"
    "uname -n"
    "sysctl kernel.hostname"
)

# Pick a random index from the list of commands
random_index=$((RANDOM % ${#commands[@]}))

# Execute the random command and colorize the output
echo -e "${GREEN}Bonus Tip! Here's another way to get the hostname:${RESET}"
echo -e "${YELLOW}  Command: ${RESET}${BLUE}${commands[$random_index]}${RESET}"
echo -e "${GREEN}  Output:${RESET}"

# Run figlet on the hostname output
figlet_output=$(figlet -f smslant $(hostname))

# Print the figlet output
echo -e "${figlet_output}"
echo -e

# Exit the script
exit 0
