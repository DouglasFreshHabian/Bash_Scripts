#!/bin/bash

# A Simple Bash Script That Attempts to Install Various Tools

# Bold Colors
RED='\033[1;31m'      # Red
GREEN='\033[1;32m'    # Green
YELLOW='\033[1;33m'   # Yellow
BLUE='\033[1;34m'     # Blue
CYAN='\033[1;36m'     # Cyan
PURPLE='\033[1;35m'   # Purple
WHITE='\033[1;37m'    # White

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

#--------) Display ASCII banner (--------#

   # Print the banner in the chosen color
    echo -e "${color_code}"
    cat << "EOF"
                                   ____________________________
  _____                          ,\\    ___________________    \
 |     `------------------------'  ||  (___________________)   `|
 |_____.------------------------._ ||  ____________________     |
            Fresh Forensics      `//__(____________________)___/

  ______________________
.'   __                 `.
|  .'__`.    = = = =     |_.-----._                          .---.
|  `.__.'    = = = =     | |     | \ _______________        / .-. \
|`.                      | |     |  |  ````````````,)       \ `-' /
|  `.                    |_|     |_/~~~~~~~~~~~~~~~'         `---'
|    `-;___              | `-----'                   ___
|        /\``---..._____.'               _  _...--'''   ``-._
|       |  \                            /\\`                 `._
|       |   )              __..--''\___/  \\     _.-'```''-._   `;
|       |  /              /       .'       \\_.-'            ````
|       | /              |_.-.___|  .-.   .'~
|       `(               | `-'      `-'  ;`._
|         `.              \__       ___.'  //`-._          _,,,
|           )                ``--../   \  //     `-.,,,..-'    `;
`----------'                            \//,_               _.-'
                                         ^   ```--...___..-'
EOF
    echo -e "${RESET}"  # Reset color
}



# Define tools to check
TOOLS=(
    fortune-mod
    cowsay
    cowsay-off
    xcowsay
    figlet
    toilet
    cmatrix
    oneko
    espeak
    libaa-bin
    bb
    pv
    aview
    x11-apps
    sysvbanner
)

ascii_banner

# Arrays to track installed and failed installations
installed_tools=()
failed_tools=()

# Function to check and install tools
check_and_install() {
    local tool=$1
    if command -v $tool &> /dev/null; then
        echo -e "${CYAN}${tool} is installed.${RESET}"
        installed_tools+=("$tool")
    else
        echo -e "${WHITEB}${tool} ${WHITE}is ${WHITEB}NOT ${WHITE}installed. Installing...${RESET}"
        if sudo apt-get install -y $tool; then
            echo -e "${GREEN}${tool} successfully installed.${RESET}"
            installed_tools+=("$tool")
        else
            echo -e "${RED}Failed to install ${tool}.${RESET}"
            failed_tools+=("$tool")
        fi
    fi
}

# Loop through each tool and check/install
for tool in "${TOOLS[@]}"; do
    check_and_install $tool
done

# Final summary
echo -e "\n${GREEN}Successfully installed tools: ${installed_tools[*]:-None}${RESET}"
echo -e "${RED}Failed to install tools: ${failed_tools[*]:-None}${RESET}"
