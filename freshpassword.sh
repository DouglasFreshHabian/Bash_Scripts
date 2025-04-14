#!/bin/bash

# Simple but Fresh Password Generator that is based of off passwordGenerator.sh

# You can specify not only the number of characters in each password but also the number of passwords generated

# Install lolcat for full functionality

# Define color escape codes
RED='\e[1;31m'
GREEN='\e[1;32m'
YELLOW='\e[1;33m'
BLUE='\e[1;34m'
RESET='\e[0m'
CYAN='\e[1;36m'
PURPLE='\e[1;35m'
WHITE='\e[1;37m'

# Array of color names
allcolors=("RED" "GREEN" "YELLOW" "BLUE" "CYAN" "PURPLE" "WHITE")

# Function to print banner with a random color
print_banner() {
    # Pick a random color from the allcolors array
    random_color="${allcolors[$((RANDOM % ${#allcolors[@]}))]}"

    # Convert the color name to the actual escape code
    case $random_color in
        "RED") color_code=$RED ;;
        "GREEN") color_code=$GREEN ;;
        "YELLOW") color_code=$YELLOW ;;
        "BLUE") color_code=$BLUE ;;
        "CYAN") color_code=$CYAN ;;
        "PURPLE") color_code=$PURPLE ;;
        "WHITE") color_code=$WHITE ;;
    esac

    # Print the banner in the chosen color
    echo -e "${color_code}"
    cat << "EOF"

%===============================================================%
%    ___            __                                       __ %
%   / _/______ ___ / /  ___  ___ ____ ____    _____  _______/ / %
%  / _/ __/ -_|_-</ _ \/ _ \/ _ `(_-<(_-< |/|/ / _ \/ __/ _  /  %
% /_//_/  \__/___/_//_/ .__/\_,_/___/___/__,__/\___/_/  \_,_/   %
%                    /_/                                        %
%===============================================================%
          github.com/DouglasFreshHabian/Bash_Scripts

EOF
    echo -e "${RESET}"  # Reset color
}

# Call the function to test
print_banner

echo -e "${PURPLE}This is a simple but${RESET} ${RED}FRESH${RESET} ${PURPLE}password generator${RESET}"
echo -e "${BLUE}Please enter the${RESET} ${YELLOW}Length${RESET} ${BLUE}of the password${RESET}: "
echo -e "${BLUE}Please enter the${RESET} ${YELLOW}Number${RESET} ${BLUE}passwords you want generated${RESET}: "
echo -e "${WHITE}"
read -p "Password Length: " PASS_LENGTH
read -p "Number of Passwords: " NUM_OF_PASS
echo -e "${RESET}"
echo -e "${CYAN}The Password Length is${RESET}: ${WHITE}$PASS_LENGTH${RESET} ${CYAN}and the Number of Passwords is${RESET}: ${WHITE}$NUM_OF_PASS${RESET}"
echo -e "${WHITE}"
read -p "Is this correct? (y/n): " confirm
echo -e "${RESET}"

if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
	echo -e "Operation cancelled. No Passwords generated..."
fi

for p in $(seq 1 $NUM_OF_PASS);

do
	openssl rand -base64 48 | cut -c1-$PASS_LENGTH | lolcat

done
