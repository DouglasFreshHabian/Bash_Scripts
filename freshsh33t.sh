#!/bin/bash

# A Simple bash script to remove/copy/list all of the cheatsh33ts in your personal cheatsheet directory

# This script is designed to streamline cheat sheet management while providing some interactive, colorful, and fun elements to the process.

# Define color escape codes
RED='\e[1;31m'
GREEN='\e[1;32m'
YELLOW='\e[1;33m'
BLUE='\e[1;34m'
RESET='\e[0m'
CYAN='\e[1;36m'
PURPLE='\e[1;35m'
WHITE='\e[1;37m'

# PERSONAL_DIR Variable. After the = Replace with output from cheat -d
PERSONAL_DIR=<ADD-DIRECTORY-HERE>

if ! command -v lolcat &> /dev/null; then
    echo "lolcat not found. Please install it with: apt install lolcat"
    exit 1
fi

# Array of color names
allcolors=("RED" "GREEN" "YELLOW" "BLUE" "CYAN" "PURPLE" "WHITE")

# Function to print banner with a random color
ascii_banner() {

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

##########################################
#--------) Display ASCII banner (--------#
##########################################
   # Print the banner in the chosen color
    echo -e "${color_code}"
    cat << "EOF"


                                        .......                 
   ..                             ,lxKNWMMMMMMMNKkl,            
 'NMMXxc,                      :kWMMW0dl:,,,,:ldONMMWO:         
.XMMMMMMMWKxc,.             .lXMM0l'              .c0MMNd.      
.xKWMMMMMMMMMMMXko;.    .dXKNMWd.    ;. .;  ,'  ;.   .oNMWl     
    .;okKWMMMMMMMMMMNOo:KMMMMK.    __            _     .OMM0.   
          .,cdOXWMMMMMMMMMMMk     / _|_ _ ___ __| |_     oMM0   
                 .;lx0WMMMMk     |  _| '_/ -_|_-< ' \     xMMd  
                     .WMMMW.     |_| |_| \___/__/_||_|    .NMW. 
                     ,WMMMK      _____________________     kMMc 
                      .oMM0          _            _        xMMc 
                       .WMN.      __| |_  ___ ___| |_      XMM, 
                        kMMl     (_-< ' \/ -_) -_)  _|     cMM0  
                        .NMW:    /__/_||_\___\___|\__|    'NMW'  
                         .XMWo   ____________________    :NMW;   
                          .0MM0'                      .OMMK'    
                            ;KMM0c.                .c0MMXc      
                              ;OWMMKx:'.      .':dKWMW0;        
                                .:xKWMMMWNXXNWMMMWKx:.          
                                     .;clddddlc;.               
                                                           


EOF
    echo -e "${RESET}"  # Reset color
}



# Display Help Menu
help_menu() {
  # Display the ASCII banner first
  ascii_banner

  # Display the help information
  echo -e "\e[1;34mUsage\e[0m: \e[1;36m./freshcheat.sh\e[0m \e[1;33m[OPTION]\e[0m"
  echo -e "\e[0;31m\nOptions:\e[0m"
  echo -e "\e[1;37m\t-h, --help\t\t\tShow this help menu."
  echo -e "\e[1;37m\t-u, --copy\t\t\tCopy over all of the cheats33ts from the sh33ts directory."
  echo -e "\e[1;37m\t-d, --remove\t\t        Remove all of the cheatsh33ts in the 'personal' directory."
  echo -e "\e[1;37m\t-a, --path\t\t\tVerify the correct path of the 'personal' cheatsh33t directory."
  echo -e "\e[1;37m\t    --ascii\t\t\tDisplay the ASCII banner.\e[0m"
  exit 0
}

# function to find the correct path to the cheetsh33ts

cheat_path() {

# First determine then personal cheatsh33t directory
echo -e "${RED}We need to determine the correct path to the personal cheatsh33t directory${RESET}"
echo -e "${YELLOW}We do this by running the following command 'cheat -d'.${RESET}"
echo -e "${WHITE}"
echo
cheat -d
echo
echo -e "${RESET}"
echo
echo -e "${BLUE}Copy the path from line 2 and paste it into the script after 'PERSONAL_DIR='${RESET}"
echo
echo -e "${BLUE}When the output of running 'ls' on the 'PERSONAL_DIR' variable is correct, continue to next step.${RESET}"

# List every cheatsh33t inside the pesonal directory:
echo -e "Here are all of your current cheatsh33ts..." | lolcat -a
echo -e "${WHITE}"
ls $PERSONAL_DIR
echo -e "${RESET}"
}

# Function for copy_sheets
copy_sheets() {
# Check if the destination directory was found
if [[ ! -d "$PERSONAL_DIR" ]]; then
    echo "Destination directory 'personal' not found. Exiting."
    exit 1
fi

# Get the directory where the script is located
SOURCE_DIR="$(pwd)"

# Get the script file name
script_name="$(basename "$0")"

# Loop through the files in the script's directory
for file in "$SOURCE_DIR"/*; do
    # Skip the script itself
    if [[ "$(basename "$file")" == "$script_name" ]]; then
        continue
    fi

    # Extract the file name from the full path
    file_name="$(basename "$file")"

    # Check if the file is executable (skip if it is)
    if [[ -x "$file" ]]; then
        echo "Skipping $file_name, it is an executable file."
        continue
    fi

    # Check if it's a regular file
    if [[ -f "$file" ]]; then
        # Copy the file to the destination directory
        cp "$file" "$PERSONAL_DIR"
        echo -e "Copied $file_name to $PERSONAL_DIR." | lolcat -a
    fi
done

}

# Function for remove_sheets

remove_sheets() {

# First determine personal cheatsh33t directory

# First verify that these are the cheatsheets you want to remove
echo -e "${RED}These are the cheatsh33ts that will be removed...${RESET} " 
echo -e ${WHITE}
ls "$PERSONAL_DIR"/*
echo -e ${RESET}

# Remove every cheatsh33t inside personal directory
echo -e ${RED}
read -p "Would you like to remove these cheatsh33ts? (y/n): " remove_confirm
if [[ "$remove_confirm" == "y" || "$remove_confirm" == "Y" ]]; then
  rm "$PERSONAL_DIR"/*
echo -e ${RESET}
  echo
  echo -e "All cheatsh33ts have been removed..." | lolcat -a
else
  echo -e "No Cheatsh33ts will be deleted..."
fi
}

# Parse command-line options
while [[ $# -gt 0 ]]; do
  case "$1" in
    -u|--remove)
      remove_sheets
      shift
      ;;
    -d|--copy)
      copy_sheets
      shift
      ;;
    -a|--path)
      cheat_path
      shift
      ;;
    --ascii)
      ascii_banner
      shift
      ;;
    -h|--help)
      help_menu
      ;;
    *)
      echo -e "\e[1;31mInvalid option: $1\e[0m"
      exit 1
      ;;
  esac
done
