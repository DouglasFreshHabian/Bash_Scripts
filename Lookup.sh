#!/bin/bash

# A simple Bash script that accepts a log file as input and extracts the ip address, sorts
# them, getting rid of any duplicates and runs geoiplookup and whois on each address printing 
# the results to the screen and saving the results to a file...

# Define color codes
RESET='\033[0m'
BOLD='\033[1m'
YELLOW='\033[33m'
CYAN='\033[36m'
RED='\033[31m'
MAGENTA='\033[35m'

# Check if the input file is provided
if [ -z "$1" ]; then
  echo -e "${RED}Usage: $0 <log_file>${RESET}"
  exit 1
fi

# Check if the file exists
if [ ! -f "$1" ]; then
  echo -e "${RED}File not found!${RESET}"
  exit 1
fi

# Store the input file
log_file="$1"

# Extract the filename without extension and path
file_name=$(basename "$log_file" | sed 's/\(.*\)\..*/\1/')

# Create a timestamp
timestamp=$(date +"%Y-%m-%d_%H-%M-%S")

# Create the output file name
output_file="${file_name}_results_${timestamp}.txt"

# Print the initial message to indicate what file is being processed
echo -e "${CYAN}Searching $log_file For Any IP Addresses...${RESET}"

# Check if geoiplookup is installed
if ! command -v geoiplookup &> /dev/null; then
  echo -e "${RED}Error: geoiplookup is not installed.${RESET}"
  echo -e "${YELLOW}To install geoiplookup, run the following command:${RESET}"
  echo -e "${YELLOW}sudo apt install geoip-bin${RESET}"
  exit 1
fi

# Extract IP addresses from the log file using regex, remove duplicates, and sort
ip_addresses=$(grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' "$log_file" | sort -u)

# Check if we found any IP addresses
if [ -z "$ip_addresses" ]; then
  echo -e "${RED}No IP addresses found in the log file.${RESET}"
  exit 1
fi

# Count the number of IP addresses found
ip_count=$(echo "$ip_addresses" | wc -l)

# Create or clear the Results file
> "$output_file"

# Print the list of IP addresses found and their count
echo -e "${CYAN}==========================================${RESET}"
echo -e "${BOLD}${GREEN}List Of IP Addresses Found (${ip_count}):${RESET}"
echo "$ip_addresses"
echo -e "${CYAN}==========================================${RESET}"

# Append the list to Results.txt
echo -e "${CYAN}==========================================${RESET}" >> "$output_file"
echo -e "${BOLD}${GREEN}List Of IP Addresses Found (${ip_count}):${RESET}" >> "$output_file"
echo "$ip_addresses" >> "$output_file"
echo -e "${CYAN}==========================================${RESET}" >> "$output_file"

# Check for internet connectivity
echo -e "${CYAN}Checking For Internet...${RESET}"
ping -c 2 1.1.1.1 &> /dev/null

# If the ping fails, print error and exit
if [ $? -ne 0 ]; then
  echo -e "${RED}You Are Not Connected To The Internet${RESET}"
  echo -e "${RED}You Are Not Connected To The Internet${RESET}" >> "$output_file"
  exit 1
else
  echo -e "${GREEN}You Are Connected To The Internet${RESET}"
fi  

# Define the filter patterns for grep
filter_patterns="(OrgAbuseRef|OrgAbuseEmail|#|RTechRef|OrgTechRef|RefRTechEmail|RTechPhone|RTechName|RTechHandle|OrgAbusePhone|OrgAbuseName|OrgAbuseHandle|Ref|RTechEmail|Comment|OrgRoutingRef|OrgRoutingEmail|OrgRoutingPhone|OrgRoutingName|OrgRoutingHandle|OrgNOCRef|OrgNOCEmail|OrgNOCPhone|OrgNOCName|OrgNOCHandle|OrgTechEmail|OrgTechPhone|OrgTechName|OrgTechHandle|Comment)"

# Variable to store IP addresses that return no info
no_info_ips=""

# Process each IP address found in the log file
while IFS= read -r ip_address; do
  # Run geoiplookup and whois for the IP address
  geoip_result=$(geoiplookup "$ip_address" 2>/dev/null)
  whois_result=$(whois "$ip_address" 2>/dev/null)

  # Check if either geoiplookup or whois gives the result "IP Address not found"
  if [[ "$geoip_result" == *"IP Address not found"* || "$whois_result" == *"IP Address not found"* ]]; then
    no_info_ips="$no_info_ips\n${RED}IP Address $ip_address Returns No Info. Perhaps It Is An Internal IP Address?${RESET}"
    continue
  fi

  # Skip if no results from geoiplookup or whois
  if [ -z "$geoip_result" ] && [ -z "$whois_result" ]; then
    continue
  fi

  # Output to the screen with colors
  echo -e "${CYAN}==========================================${RESET}"
  echo -e "${BOLD}${GREEN}Results for IP: $ip_address${RESET}"

  # Output geoiplookup result (filtered and colorized)
  if [ -n "$geoip_result" ]; then
    echo -e "${MAGENTA}GeoIP Lookup:${RESET}"
    echo "$geoip_result" | grep -vwE "$filter_patterns" | sed "s/^/${GREEN}/"
  fi

  # Output whois result (filtered and colorized)
  if [ -n "$whois_result" ]; then
    echo -e "${MAGENTA}Whois Lookup:${RESET}"
    echo "$whois_result" | grep -vwE "$filter_patterns" | sed "s/^/${GREEN}/"
  fi

  # Append results to Results.txt (filtered)
  echo -e "${CYAN}==========================================${RESET}" >> "$output_file"
  echo -e "${BOLD}${GREEN}Results for IP: $ip_address${RESET}" >> "$output_file"
  
  if [ -n "$geoip_result" ]; then
    echo -e "${MAGENTA}GeoIP Lookup:${RESET}" >> "$output_file"
    echo "$geoip_result" | grep -vwE "$filter_patterns" >> "$output_file"
  fi
  
  if [ -n "$whois_result" ]; then
    echo -e "${MAGENTA}Whois Lookup:${RESET}" >> "$output_file"
    echo "$whois_result" | grep -vwE "$filter_patterns" >> "$output_file"
  fi

  echo -e "${CYAN}==========================================${RESET}" >> "$output_file"
  echo >> "$output_file"

done <<< "$ip_addresses"

# Print the "no info" IP addresses at the end of the results
if [ -n "$no_info_ips" ]; then
  echo -e "${CYAN}\n==========================================${RESET}"
  echo -e "${BOLD}${RED}IP Addresses That Returned No Info:${RESET}"
  echo -e "$no_info_ips"
  echo -e "${CYAN}==========================================${RESET}"
  echo -e "${CYAN}\n==========================================${RESET}" >> "$output_file"
  echo -e "${BOLD}${RED}IP Addresses That Returned No Info:${RESET}" >> "$output_file"
  echo -e "$no_info_ips" >> "$output_file"
  echo -e "${CYAN}==========================================${RESET}" >> "$output_file"
fi

# Notify user where the results have been saved
echo -e "${YELLOW}Results saved to $output_file${RESET}"
