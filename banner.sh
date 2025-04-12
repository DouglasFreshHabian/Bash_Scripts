#!/bin/bash

# A simple Bash script that displays a banner in several different randomnized colors
# Change the current banner for the one you wish to use and enjoy!
# Example: figlet -f smslant Paperwork | boxes
# Define color escape codes

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
RESET='\033[0m'
CYAN='\033[0;96m'
PURPLE='\033[0;95m'
WHITE='\033[1;37m'

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

              /********************************************************/
              /*  _____                                         _     */
              /* |  __ \                                       | |    */
              /* | |__) |_ _ _ __   ___ _ ____      _____  _ __| | __ */
              /* |  ___/ _` | '_ \ / _ \ '__\ \ /\ / / _ \| '__| |/ / */
              /* | |  | (_| | |_) |  __/ |   \ V  V / (_) | |  |   <  */
              /* |_|   \__,_| .__/ \___|_|    \_/\_/ \___/|_|  |_|\_\ */
              /*            | |                                       */
              /*            |_|                                       */
              /********************************************************/
  

EOF
    echo -e "${RESET}"  # Reset color
}

# Call the function to test
print_banner

exit 0
