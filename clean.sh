#!/bin/bash

# Simple Bash Script that accepts a wordlist as input and cleans it by removing 
# both New-line characters & Carriage-Returns as well as all unwanted symbols... 
# It is used in my H0stnam3 repo to clean wordlists for use in changing the hostname

# Define colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
RESET='\033[0m'

# Define log file
LOG_FILE="./wordlist_cleaning.log"

# Function to display error messages
error_exit() {
    echo -e "${RED}$1${RESET}"
    exit 1
}

# Function to write logs
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Help menu
show_help() {
    echo -e "${BLUE}Usage: $0 <wordlist_file>${RESET}"
    echo -e "This script will clean a wordlist and keep only valid hostnames."
    echo -e "It will create a new cleaned wordlist and log any invalid hostnames."
}

# Display ASCII banner
echo -e "\033[1;32m"
cat << "EOF"
/*****************************************/
/*       _                        _      */
/*   ___| | ___  __ _ _ __    ___| |__   */
/*  / __| |/ _ \/ _` | '_ \  / __| '_ \  */
/* | (__| |  __/ (_| | | | |_\__ \ | | | */
/*  \___|_|\___|\__,_|_| |_(_)___/_| |_| */
/*                                       */
/*****************************************/
EOF
echo -e "\033[0m"

# Check if the script is receiving a wordlist file
if [ "$#" -ne 1 ]; then
    show_help
    exit 1
fi

# Set input and output files
input_wordlist="$1"
output_wordlist="cleaned_$1"

# Create the log file if it doesn't exist
touch "$LOG_FILE" || error_exit "Failed to create log file!"

# Start logging
log_message "Script started to clean the wordlist."

# Function to clean the wordlist
clean_wordlist() {
    local wordlist=$1
    local output=$2

    echo -e "${BLUE}Cleaning wordlist...${RESET}"

    # Process each word
    while IFS= read -r word; do
        # Remove carriage returns and newlines (normalize the word)
        word=$(echo "$word" | tr -d '\r\n')

        # Check for valid hostname format (alphanumeric and hyphens)
        if [[ "$word" =~ ^[a-zA-Z0-9-]+$ ]]; then
            # Ensure no word starts or ends with a hyphen
            if [[ "$word" != -* && "$word" != *- ]]; then
                # Check length of the word (valid hostname labels should be between 1 and 63 characters)
                if [[ ${#word} -gt 0 && ${#word} -le 63 ]]; then
                    # Valid hostname, append to output file
                    echo "$word" >> "$output"
                else
                    # Invalid word (too long or too short)
                    echo -e "${YELLOW}Invalid word (length issue): $word${RESET}"
                    log_message "Invalid word (length issue): $word"
                fi
            else
                # Invalid word (starts or ends with a hyphen)
                echo -e "${YELLOW}Invalid word (starts/ends with hyphen): $word${RESET}"
                log_message "Invalid word (starts/ends with hyphen): $word"
            fi
        else
            # Invalid word (contains invalid characters)
            echo -e "${YELLOW}Invalid word (contains invalid characters): $word${RESET}"
            log_message "Invalid word (contains invalid characters): $word"
        fi
    done < "$wordlist"

    echo -e "${GREEN}Wordlist cleaned successfully! Cleaned list saved to $output.${RESET}"
    log_message "Wordlist cleaned successfully. Cleaned list saved to $output."
}

# Call the cleaning function
clean_wordlist "$input_wordlist" "$output_wordlist"

# End script
log_message "Script finished."
exit 0
 
