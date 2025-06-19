#!/bin/bash

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[1;36m'
PURPLE='\033[0;35m'
WHITE='\033[0;37m'
BWHITE='\033[1;37m'
NC='\033[0m' # No Color

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
	cat <<"EOF"
░▀█▀░█▀█░░░░░█▀█░█▀▀
░░█░░█░█░▄▄▄░█░█░█░█
░▀▀▀░▀▀▀░░░░░▀░▀░▀▀▀
EOF
	echo -e "${NC}" # Reset color
}

clear
ascii_banner
echo -e "${BWHITE}Monitoring USB devices${NC}."

udevadm monitor --subsystem-match=usb --property | while read -r line; do
	if [[ "$line" == *"add"* ]]; then
		action="add"
		color=$GREEN
	elif [[ "$line" == *"remove"* ]]; then
		action="remove"
		color=$RED
	fi

	if [[ "$line" == DEVPATH=* ]]; then
		devpath="${line#DEVPATH=}"

		# Wait a moment after add
		[[ "$action" == "add" ]] && sleep 0.3

		sys_usb_path="/sys${devpath}"

		# Walk up the directory tree until we find idVendor/idProduct
		while [[ "$sys_usb_path" != "/" ]]; do
			if [[ -f "$sys_usb_path/idVendor" && -f "$sys_usb_path/idProduct" ]]; then
				vendor_id=$(<"$sys_usb_path/idVendor")
				product_id=$(<"$sys_usb_path/idProduct")
				echo -e "${color}${action^^}: ${vendor_id}:${product_id}${NC}"
				break
			fi
			sys_usb_path=$(dirname "$sys_usb_path")
		done
	fi
done
