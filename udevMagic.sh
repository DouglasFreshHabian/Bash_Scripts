#!/bin/bash

#=======================#
#     Color Escape Codes
#=======================#

# Regular Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
WHITE='\033[0;37m'
RESET='\033[0m'

# Bold Colors
REDB='\033[1;31m'
GREENB='\033[1;32m'
YELLOWB='\033[1;33m'
BLUEB='\033[1;34m'
CYANB='\033[1;36m'
PURPLEB='\033[1;35m'
WHITEB='\033[1;37m'

# Bold High Intensity
BLACKH='\e[1;90m'
REDH='\e[1;91m'
GREENH='\e[1;92m'
YELLOWH='\e[1;93m'
BLUEH='\e[1;94m'
PURPLEH='\e[1;95m'
CYANH='\e[1;96m'
WHITEH='\e[1;97m'

#=======================#
#      Script Constants
#=======================#
RULE_PATH="/etc/udev/rules.d/70-external-adapter.rules"
allcolors=("RED" "GREEN" "YELLOW" "BLUE" "CYAN" "PURPLE" "WHITE")

#=======================#
#        Functions
#=======================#

# Ctrl+C Handler
trap ctrl_c INT
function ctrl_c() {
  echo -e "\n${RED}Script was interrupted by the user. Exiting...${RESET}"
  exit 1
}

# Print Random Colored Banner
ascii_banner() {
    random_color="${allcolors[$((RANDOM % ${#allcolors[@]}))]}"
    case $random_color in
        "RED") color_code=$RED ;;
        "GREEN") color_code=$GREEN ;;
        "YELLOW") color_code=$YELLOW ;;
        "BLUE") color_code=$BLUE ;;
        "CYAN") color_code=$CYAN ;;
        "PURPLE") color_code=$PURPLE ;;
        "WHITE") color_code=$WHITE ;;
    esac

    echo -e "${color_code}"
    cat << "EOF"
	        N:                            X         
	    X:    x0.                          K0      .. 
	    cXXN   Xx                         kX    0XXl  
	    'NMN   .Kc                       dX.   .NMW.  
	     NMN.   l0'                     oK'    ;WMx   
	     OWN'    NK.                   lKc     dWW'   
	     lWN:    ,N0                  cXO      XWX    
	     ;NNo     dNk                :KN      ;NWo    
	     .NWk      NNo              ;KN.      xNW'    
	      XWK      ,WXc            ,KNc      .XWN     
	      0WN.      dWK,          'KWx       :NWd     
	      xWN:       XWK         .KWK        OWN,     
	      lNWd       .WWO        KWW        .NWX      
	      ;NW0       xOOokOOkkOOkdOkx       lWWd      
	      'NWWXNNNNN0'','';,'',;'',''kWWWWWWNWN,      
	                .''...',,,,''...';                
	                ''......,;;......';               
	                '''....'''''.....',               
	                      ..   .''.      
EOF
    echo -e "${RESET}"
}

#=======================#
#         Main
#=======================#

# Welcome Banner
ascii_banner
echo -e "${BLUE}Welcome to the Udev Rule Setup Script${RESET}"
echo -e "${YELLOW}This script will help you change the name of your external network adapter.${RESET}"

# User Input: Adapter Name
echo -e "${GREEN}Please enter the name of the adapter you want to change (e.g., eth0, wlan0):${RESET}"
read -p "Adapter Name: " ADAPTER_NAME

if ! ip link show "$ADAPTER_NAME" &>/dev/null; then
  echo -e "${RED}Error: The adapter '$ADAPTER_NAME' does not exist. Please check the name and try again.${RESET}"
  exit 1
fi

# Retrieve MAC Address
MAC_ADDRESS=$(ip link show "$ADAPTER_NAME" | awk '/ether/ {print $2}')
if [[ -z "$MAC_ADDRESS" ]]; then
  echo -e "${RED}Error: Could not retrieve the MAC address for '$ADAPTER_NAME'.${RESET}"
  exit 1
fi

# User Input: New Adapter Name
echo -e "${GREEN}Please enter the new name you want to assign to the adapter (e.g., my_adapter):${RESET}"
read -p "New Name: " NEW_NAME

if [[ -z "$NEW_NAME" ]]; then
  echo -e "${RED}Error: New Name cannot be empty.${RESET}"
  exit 1
fi

# Check for name collision
if ip link show "$NEW_NAME" &>/dev/null; then
  echo -e "${RED}Error: The name '$NEW_NAME' is already in use. Please choose a different name.${RESET}"
  exit 1
fi

# Backup existing Udev rule if present
if [[ -f "$RULE_PATH" ]]; then
    sudo cp "$RULE_PATH" "${RULE_PATH}.bak"
    echo -e "${YELLOW}Backup of existing rule created at ${RULE_PATH}.bak${RESET}"
fi

# Check for existing rule with same MAC address
if grep -q "ATTR{address}==\"$MAC_ADDRESS\"" "$RULE_PATH"; then
    echo -e "${YELLOW}Warning: A rule with MAC address ${MAC_ADDRESS} already exists in ${RULE_PATH}.${RESET}"
    echo -e "${CYAN}Existing rule:${RESET}"
    grep "ATTR{address}==\"$MAC_ADDRESS\"" "$RULE_PATH"

    echo -e "${WHITEB}"
    read -p "Do you want to overwrite the existing rule? (y/n): " OVERWRITE_CHOICE
    echo -e "${RESET}"

    case "$OVERWRITE_CHOICE" in
        [Yy]* )
            echo -e "${YELLOW}Removing old rule and writing new one...${RESET}"
            sudo sed -i "/ATTR{address}==\"$MAC_ADDRESS\"/d" "$RULE_PATH"
            echo "SUBSYSTEM==\"net\", ACTION==\"add\", ATTR{address}==\"$MAC_ADDRESS\", NAME=\"$NEW_NAME\"" | sudo tee -a "$RULE_PATH" > /dev/null
            ;;
        [Nn]* )
            echo -e "${RED}Skipping rule creation for this MAC address.${RESET}"
            ;;
        * )
            echo -e "${RED}Invalid input. Skipping rule creation by default.${RESET}"
            ;;
    esac
else
    echo -e "${BLUE}Creating new Udev rule for your adapter...${RESET}"
    echo "SUBSYSTEM==\"net\", ACTION==\"add\", ATTR{address}==\"$MAC_ADDRESS\", NAME=\"$NEW_NAME\"" | sudo tee -a "$RULE_PATH" > /dev/null
fi

# Apply Udev Rule
echo -e "${BLUE}Reloading Udev rules and applying changes...${RESET}"
sudo udevadm control --reload-rules
sudo udevadm trigger

# Confirmation
echo -e "${GREEN}Udev rule has been successfully created and applied!${RESET}"
echo -e "${YELLOW}Note: You must reboot your system for the changes to take effect.${RESET}"

# Prompt for Reboot
while true; do
  echo -e "${WHITEB}"
  read -p "Would you like to reboot now to apply changes? (y/n): " REBOOT_CHOICE
  echo -e "${RESET}"
  case "$REBOOT_CHOICE" in
    [Yy]* ) echo -e "${BLUE}Rebooting system...${RESET}"; sudo reboot; break ;;
    [Nn]* ) break ;;
    * ) echo -e "${RED}Please answer y or n.${RESET}" ;;
  esac
done

# Done
echo -e "${BLUE}Script completed successfully. Exiting...${RESET}"
