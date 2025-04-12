#!/bin/bash

# A simple Bash script that changes the hostname of a linux machine. It has several options,
# if you want to learn more about it check out the repository which includes much more:
# https://github.com/DouglasFreshHabian/H0stnam3

# Define color escape codes
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
RESET='\033[0m'
CYAN='\033[1;96m'
PURPLE='\033[1;95m'
WHITE='\033[1;37m'
UYELLOW='\e[4;33m'
UPURPLE='\e[4;35m'
BPURPLE='\e[1;35m'

# Array of color names
allcolors=("RED" "GREEN" "YELLOW" "BLUE" "CYAN" "PURPLE" "WHITE")

# Log file location
LOG_FILE="./hostname_change.log"

# Function to display error message and exit
error_exit() {
    echo -e "${RED}$1${RESET}"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - ERROR: $1" >> "$LOG_FILE"
    exit 1
}

# Function to write logs
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Help menu
show_help() {
    echo -e "${BLUE}Usage${RESET}: ${CYAN}$0 ${RESET}${YELLOW}<options>${RESET}"
    echo -e "${BPURPLE}Options:"
    echo -e "${WHITE}  -h, --help               Show this help menu."
    echo -e "  -w, --wordlist <path>    Provide a wordlist to generate a hostname."
    echo -e "  -n, --name <hostname>    Manually provide a hostname."
    echo -e "  -r, --random             Generate a random 12-character alphanumeric hostname."
    echo -e "  -l, --log                Enable verbose logging of the hostname change."
    echo -e "  -a, --about              Show the rules for creating a valid hostname."
    echo -e "  -b, --banner		Display the ascii banner.${RESET}"
}

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
          __            __                            __
         / /  ___  ___ / /____  ___ ___ _  ___   ___ / /
        / _ \/ _ \(_-</ __/ _ \/ _ `/  ' \/ -_) (_-</ _ \
       /_//_/\___/___/\__/_//_/\_,_/_/_/_/\__(_)___/_//_/
      ___________________________________________________
                       FRESH FORENSICS
EOF
    echo -e "${RESET}"  # Reset color
}

# Call the function to test
print_banner

# About function to display hostname rules
show_about() {
    echo -e "${GREEN}Rules for creating a hostname:${RESET}"
    echo -e "${YELLOW}1. The hostname must be composed of up to 64 7-bit ASCII lower-case alphanumeric characters or hyphens.${RESET}"
    echo -e "${BLUE}2. The hostname should not contain any dots (only a single label).${RESET}"
    echo -e "${RED}3. The hostname cannot start or end with a hyphen.${RESET}"
    echo -e "${PURPLE}4. The hostname can contain only alphanumeric characters (a-z, 0-9) and hyphens (-).${RESET}"
    echo -e "${CYAN}5. The hostname cannot be longer than 63 characters.${RESET}"
}

# Check if the script is running with sudo privileges
if [ "$(id -u)" -ne 0 ]; then
    echo -e "${YELLOW}Warning: You are not running this script as root. You might need to rerun it with sudo privileges.${RESET}"
    exit 1
fi

if ! command -v hostnamectl &> /dev/null; then
    error_exit "hostnamectl command is not available. Please install it."
fi

# If no arguments are provided, show help
if [ "$#" -eq 0 ]; then
    show_help
    exit 1
fi

# Flag for logging
save_log="n"

# Parse command-line options
while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            show_help
            exit 0
            ;;
        -a|--about)
            show_about
            exit 0
            ;;
        -r|--random)
            new_hostname=$(tr -dc 'a-zA-Z0-9' </dev/urandom | head -c 12)
            echo -e "${BLUE}Generated random hostname: ${new_hostname}${RESET}"
            log_message "Generated random hostname: $new_hostname"
            shift
            ;;
        -w|--wordlist)
            if [[ -z "$2" || ! -f "$2" ]]; then
                error_exit "Invalid or missing wordlist file!"
            fi
            mapfile -t wordlist < "$2"
            if [ ${#wordlist[@]} -eq 0 ]; then
                error_exit "The wordlist is empty!"
            fi
            new_hostname="${wordlist[RANDOM % ${#wordlist[@]}]}"
            # Replace '/' with '-' and remove [!@#$%^&*'] to make the hostname valid
            new_hostname=$(echo "$new_hostname" | sed 's/\//-/g' | sed 's/[\/*!^%?$@#&]//g')
            echo -e "${BLUE}Chosen hostname from wordlist${RESET}:${GREEN}${new_hostname}${RESET}"
            log_message "Chosen hostname from wordlist: $new_hostname"
            shift 2
            ;;
        -n|--name)
            if [[ -z "$2" ]]; then
                error_exit "No hostname provided!"
            fi
            new_hostname="$2"
            # Replace '/' with '-' and apostrophes with '-' to make the hostname valid
            new_hostname=$(echo "$new_hostname" | sed 's/\//-/g')
            echo -e "${BLUE}User-provided hostname${RESET}:${GREEN}${new_hostname}${RESET}"
            log_message "User-provided hostname: $new_hostname"
            shift 2
            ;;
	-b|--banner)
	    print_banner
	    exit 0
	    ;;
        -l|--log)
            save_log="y"
            echo -e "${BLUE}Logging enabled. All output will be logged to $LOG_FILE.${RESET}"
            log_message "Logging enabled."
            shift
            ;;
        *)
            error_exit "Unknown option: $1. Use --help for usage instructions."
            ;;
    esac
done

# Clean the hostname input: Remove carriage returns and trim whitespace
new_hostname=$(echo "$new_hostname" | tr -d '\r' | xargs)

# Validate the hostname
if [[ ! "$new_hostname" =~ ^[a-zA-Z0-9-]+$ || ${#new_hostname} -gt 63 || "$new_hostname" =~ ^- || "$new_hostname" =~ -$ ]]; then
    error_exit "Invalid hostname! Must be alphanumeric with optional hyphens, under 64 characters, and cannot start or end with a hyphen."
fi

# Function to spawn Xterm window with nmcli monitor and lolcat
spawn_xterm() {
  # Spawn Xterm with nmcli monitor | lolcat -a                                                                               
  xterm -bg black -fg red -e "systemctl status systemd-logind.service systemd-hostnamed.service" &                                              
  sleep 2  # Give xterm some time to start                                                                              
                                       
                                                                                                                 
  # Use wmctrl to resize and position the window (quarter of screen)                                                                
  wmctrl -r :ACTIVE: -e 2,600,600,600,600  # Adjust values as needed (800x600 for 1/4 screen)                     
}

spawn_xterm

# Get the current hostname
current_hostname=$(hostname)

# Check if the new hostname is the same as the current one
if [ "$new_hostname" == "$current_hostname" ]; then
    echo -e "${YELLOW}Warning: The new hostname is the same as the current hostname. No changes will be made.${RESET}"
    log_message "No change: New hostname was the same as current"
    exit 0
fi

# Create the log file if logging is enabled
if [[ "$save_log" == "y" ]]; then
    touch "$LOG_FILE" || error_exit "Failed to create log file!"
    log_message "Script started"
fi

# Confirm new hostname with the user
read -p "Do you want to proceed with the new hostname: $new_hostname? (y/n): " confirm
echo "User input: $confirm" >> "$LOG_FILE"  # Log user input
if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
    echo -e "${YELLOW}Operation canceled. No changes were made.${RESET}"
    log_message "Operation canceled by user"
    exit 0
fi

# Display the chosen hostname
echo -e "${BLUE}Applying new hostname${RESET}:${GREEN}${new_hostname}${RESET}"
log_message "Applying new hostname: $new_hostname"
sleep 1
echo -e ["${RED}######################################${RESET}"]
sleep 1
echo -e ["${WHITE}####################################################${RESET}"]
sleep 1
echo -e ["${BLUE}###########################################${RESET}"]
# Update /etc/hostname file
echo "$new_hostname" > /etc/hostname || error_exit "Failed to update /etc/hostname!"
log_message "Updated /etc/hostname with new hostname: $new_hostname"

# Update /etc/hosts file (modify only relevant lines)
sed -i "s/^127\.0\.1\.1\s.*/127.0.1.1       $new_hostname/" /etc/hosts || error_exit "Failed to update /etc/hosts!"
log_message "Updated /etc/hosts with new hostname"

# Run hostnamectl to set the hostname
hostnamectl set-hostname "$new_hostname" || error_exit "Failed to set the hostname with hostnamectl!"
log_message "Ran hostnamectl to set new hostname"

# Log the success message if logs are enabled
if [[ "$save_log" == "y" ]]; then
    log_message "Successfully changed the hostname to '$new_hostname'"
fi
sleep 1

# Let the user know the process is complete
echo -e "_______________________________________________________"
echo -e
echo -e "${GREEN}Successfully changed the hostname to ${RESET}:${UYELLOW}${new_hostname}!${RESET}"
echo -e "_______________________________________________________"
echo -e
log_message "Successfully changed the hostname to '$new_hostname'"

# Offer to restart the shell session
read -p "Do you want to restart your shell session now? (y/n): " restart_shell
echo "User input: $restart_shell" >> "$LOG_FILE"  # Log user input
if [[ "$restart_shell" == "y" || "$restart_shell" == "Y" ]]; then

echo -e "${PURPLE}---------------------------------------------------->${RESET}"
sleep 1

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
figlet_output=$(figlet -f smslant "$new_hostname")

# Print the figlet output
echo -e "${figlet_output}"
echo -e
    sleep 2
    exec bash
    log_message "Restarting shell session"
fi

# Remind the user to restart the shell manually if they chose not to restart automatically
echo -e "${YELLOW}Remember to exit the current shell and open a new one for the new hostname to take effect.${RESET}"
echo -e
echo -e

log_message "User reminded to restart shell manually if needed"

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
#random_index=$((RANDOM % ${#commands[@]}))

# Execute the random command and colorize the output
#echo -e "${GREEN}Bonus Tip! Here's another way to get the hostname:${RESET}"
#echo -e "${YELLOW}  Command: ${RESET}${BLUE}${commands[$random_index]}${RESET}"
#echo -e "${GREEN}  Output:${RESET}"
#echo -e
# Run the selected command and indent the output by 4 spaces
#eval "${commands[$random_index]}" | sed 's/^/        /'  # Adds 4 spaces at the beginning of each line
#echo -e

# Pick a random index from the list of commands
random_index=$((RANDOM % ${#commands[@]}))

# Execute the random command and colorize the output
echo -e "${GREEN}Bonus Tip! Here's another way to get the hostname:${RESET}"
echo -e "${YELLOW}  Command: ${RESET}${BLUE}${commands[$random_index]}${RESET}"
echo -e "${GREEN}  Output:${RESET}"

# Run figlet on the hostname output, if it is not installled, print output
figlet_output=$(figlet -f smslant "$new_hostname")

# Print the figlet output
echo -e "${figlet_output}"

# Exit the script
exit 0
