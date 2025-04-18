#!/bin/bash

# Color definitions
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[1;96m'
PURPLE='\033[1;95m'
WHITE='\033[1;37m'
RESET='\033[0m'  # Reset to default color

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


                                                  
                  c;            l.                  
                   o            d                   
                   l           .l                   
                   ,;          :,                   
                    k          k                'Nx 
   ,No              l.         O               xN.  
     kN.            ,o        ;l             .Wd    
      .Nx            0        x'            OW      
        dN.          dc       N           :N;       
          N0         ,K      ;0          N0         
           cN:        N,     xo        dN,          
             NN       dx     N,      .N0            
              dXc     'N    ,W.     kX:             
                NN     XOlXO0K    ,NX               
                 dXNNNo'.....'dNXNN'                
                      ,...;...,                     
                      ;xodxxdko         

  _|               |                                 |     
 |    __| _ \  __| __ \  __ `__ \   _` |  __|    __| __ \  
 __| |    __/\__ \ | | | |   |   | (   | (     \__ \ | | | 
_|  _|  \___|____/_| |_|_|  _|  _|\__,_|\___|_)____/_| |_| 
                                                           

EOF
    echo -e "${RESET}"  # Reset color
}

# Call the function to test
print_banner

LOG_FILE="/var/log/mac_randomizer.log"

# Function to log messages
log_message() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") - $1" >> "${LOG_FILE}"
}

# Function to exit the script with an error message
exit_with_error() {
    echo -e "${RED}Error: $1${RESET}" >&2
    log_message "Error: $1"
    exit 1
}

# Check for root privileges
if [[ "${EUID}" -ne 0 ]]; then
    exit_with_error "Please run as root."
fi

# Check for required tools
for cmd in ip macchanger rfkill; do
    if ! command -v "${cmd}" &> /dev/null; then
        exit_with_error "Required command ""${cmd}"" not found. Please install it."
    fi
done
# Print available interfaces to the screen 
echo -e "${GREEN}Here Are All Of Your Available Interfaces...${RESET}"
echo -e "${WHITE}"
ip link show | awk -F': ' '/^[0-9]+: / {print $2}'
echo -e "${RESET}"


# Specify the network interface to use
INTERFACE="$1"
STATIC_MAC="$2"

# Validate input
if [[ -z "$INTERFACE" ]]; then
    exit_with_error "${BLUE}Usage${RESET}:${CYAN} $0 ${RESET}${GREEN}<interface>${RESET} ${WHITE}[static_mac]${RESET}"
fi

if [[ -n "${STATIC_MAC}" ]]; then
    if [[ "${STATIC_MAC}" =~ ^([0-9a-fA-F]{2}[:-]){5}([0-9a-fA-F]{2})$ ]]; then
        echo -e "${YELLOW}Setting static MAC address: ${STATIC_MAC}${RESET}"
    else
        exit_with_error "Invalid MAC address format: ${STATIC_MAC}. Use format XX:XX:XX:XX:XX:XX."
    fi
fi

# Function to randomize MAC address
randomize_mac() {
    echo -e "${YELLOW}Randomizing MAC address for interface ${INTERFACE}...${RESET}"
echo -e "${WHITE}"
    if ! macchanger -r "${INTERFACE}"; then
echo -e "${RESET}"
        exit_with_error "Failed to randomize MAC address for ${INTERFACE}."
    fi
}

# Function to check the rfkill status
check_rfkill() {

echo -e "${WHITE}"
    if rfkill list || grep -q "Soft blocked: yes\|Hard blocked: yes"; then
        echo -e "${YELLOW}The interface ${INTERFACE} is blocked. Unblocking it...${RESET}"
        if ! rfkill unblock all; then
echo -e "${RESET}"

            exit_with_error "Failed to unblock ${INTERFACE}."
        fi
    else
        echo -e "${GREEN}The interface ${INTERFACE} is not blocked.${RESET}"
    fi
}

# Main execution starts here

# Check if the interface exists
if ! ip link show "${INTERFACE}" &> /dev/null; then
    exit_with_error "Interface ${INTERFACE} does not exist."
fi

# Bring the interface down
echo -e "${YELLOW}Bringing down the interface ${INTERFACE}...${RESET}"
if ! sudo ip link set "${INTERFACE}" down && sudo rfkill unblock all; then
    exit_with_error "Failed to bring down the interface ${INTERFACE}."
fi

# Check if the interface is blocked
check_rfkill

# Randomize the MAC address or set static MAC
if [[ -n "${STATIC_MAC}" ]]; then
    echo -e "${YELLOW}Setting static MAC address: ${STATIC_MAC}${RESET}"
    if ! sudo ip link set dev "${INTERFACE}" address "${STATIC_MAC}"; then
        exit_with_error "Failed to set static MAC address ${STATIC_MAC} for ${INTERFACE}."
    fi
else
    randomize_mac

fi

# Bring the interface back up
echo -e "${YELLOW}Bringing up the interface $INTERFACE...${RESET}"
if ! sudo ip link set "$INTERFACE" up; then
    exit_with_error "Failed to bring up the interface ${INTERFACE}."
fi

# Display the new MAC address
echo -e "${GREEN}New MAC address:${RESET}"
if ! ip link show "$INTERFACE" | grep -q 'ether'; then
    exit_with_error "Failed to retrieve MAC address for ${INTERFACE}."

fi
