#!/bin/bash

# A Simple Fresh Bash script to encrypt or decrypt files using GPG
# With some added ascii

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

         __________________________________________________________________
        /                                                                  \
        |    __               _                           _         _      |
        |   / _|             | |                         | |       | |     |
        |  | |_ _ __ ___  ___| |__   ___ _ __ _   _ _ __ | |_   ___| |__   |
        |  |  _| '__/ _ \/ __| '_ \ / __| '__| | | | '_ \| __| / __| '_ \  |
        |  | | | | |  __/\__ \ | | | (__| |  | |_| | |_) | |_ _\__ \ | | | |
        |  |_| |_|  \___||___/_| |_|\___|_|   \__, | .__/ \__(_)___/_| |_| |
        |                                      __/ | |                     |
        |                                     |___/|_|                     |
        \                                                                  /
         ------------------------------------------------------------------
            \
             \
                 .--.
                |o_o |
                |:_/ |
               //   \ \
              (|     | )
             /'\_   _/`\
             \___)=(___/

EOF
    echo -e "${RESET}"  # Reset color
}

# Call the function to test
print_banner


echo "This is a simple file encrypter/decrypter"
echo "Please choose an option:"

options=("Encrypt" "Decrypt" "Quit")
select opt in "${options[@]}"; do
    case $opt in
        "Encrypt")
            echo "You have selected: Encryption"
            read -p "Enter the filename to encrypt: " file
            if [[ -f "$file" ]]; then
                gpg -c "$file"
                echo "The file has been encrypted to ${file}.gpg"
            else
                echo "Error: File '$file' not found."
            fi
            break
            ;;
        "Decrypt")
            echo "You have selected: Decryption"
            read -p "Enter the filename to decrypt (including .gpg): " file
            if [[ -f "$file" ]]; then
                gpg -d "$file" > "${file%.gpg}"
                echo "The file has been decrypted to ${file%.gpg}"
            else
                echo "Error: File '$file' not found."
            fi
            break
            ;;
        "Quit")
            echo "Exiting."
            break
            ;;
        *)
            echo "Invalid option. Please choose 1, 2, or 3."
            ;;
    esac
done
