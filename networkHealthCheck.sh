#!/bin/bash

# Color definitions
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
PURPLE='\033[1;35m'
WHITE='\033[1;37m'
RESET='\033[0m'  # Reset to default color

# Array of color names
allcolors=("RED" "GREEN" "YELLOW" "BLUE" "CYAN" "PURPLE" "WHITE")

command -v vnstat >/dev/null 2>&1 || { echo -e "${RED}vnstat not installed. Please install it.${RESET}"; exit 1; }

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


       .:;,
       ccccll:,.
       'ccc:ccccc;  '..'
        'cclo 'ccc: ....
          .ccc:  .c ,...
          .;ll     .'.     ...          
      .,::::::cokKo  .o';c:::::c:'      
    ;::::::::::::::dkl::::::::::::::.   
   :::::::::::::::::::lc:::::::::::::;  
  c::::::::::::::::::lWk::::::::::::::, 
 .::::::::::ckW0::::lNWX::::::::::::::: 
 .::dO000000NNNWl::lNXXWloOOOOOOOOOOO:: 
 .:::oooooooo:xWO:cNNcxWNW0oooooooooo:: 
  ,::::::::::::NWlXWo:cWNd::::::::::::. 
   ,:::::::::::OWWWd:::lc::::::::::::.  
    .::::::::::cWWx:::::::::::::::::    
      ':::::::::dd::::::::::::::::.     
         ::::::::::::::::::::::;        
            ;::::       ::::;   

EOF
    echo -e "${RESET}"  # Reset color
}

# Call the function to test
print_banner


# Network Health Check Script
# Author: Douglas Habian
# Date: $(date)

# Define the target host and DNS server
TARGET_HOST="1.1.1.1"  # Google Public DNS as an example
DNS_SERVER="194.242.2.2"
PING_COUNT=4

# Function to check connectivity
check_connectivity() {
    echo -e "${YELLOW}Checking connectivity to $TARGET_HOST...${RESET}"

    ping -c $PING_COUNT $TARGET_HOST > /dev/null 2>&1

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Connectivity to $TARGET_HOST: SUCCESS${RESET}"
    else
        echo -e "${RED}Connectivity to $TARGET_HOST: FAILED${RESET}"
    fi
}

# Function to check DNS resolution
check_dns() {
    echo -e "${YELLOW}Checking DNS resolution for mullvad.net...${RESET}"

    nslookup mullvad.net $DNS_SERVER > /dev/null 2>&1

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}DNS Resolution: SUCCESS${RESET}"
    else
        echo -e "${RED}DNS Resolution: FAILED${RESET}"
    fi
}

# Function to check network interface status and bandwidth usage
check_bandwidth() {
    echo -e "${YELLOW}Checking network interfaces status...${RESET}"

    echo -e "${WHITE}"
    
    ifconfig | grep -E 'inet |ether' || echo -e "${RED}No network interface found.${RESET}"

    echo -e "${RESET}"

    echo -e "${YELLOW}Checking current bandwidth usage...${RESET}"

    # Displaying download and upload speed - requires 'vnstat'

    echo -e "${WHITE}"

    vnstat -l || echo -e "${RED}VnStat not installed. Please install it for bandwidth monitoring.${RESET}"
}

    echo -e "${RESET}"

# Main Function
main() {
    echo -e "${YELLOW}Starting Network Health Check...${RESET}"

    check_connectivity
    check_dns
    check_bandwidth

    echo -e "${GREEN}Network Health Check completed!${RESET}"
}

# Execute
main
